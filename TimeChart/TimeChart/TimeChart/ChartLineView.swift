//
//  ChartLineView.swift
//  SimsTrade
//
//  Created by huxuepeng on 16/7/21.
//  Copyright © 2016年 mecrt. All rights reserved.
//

import UIKit

class ChartLineView: UIView {

    var lineContext:CGContext!
    var chart:EverChart!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        lineContext = UIGraphicsGetCurrentContext()
        self.lineContext.clear(rect);
        
        self.initLineChart()
        self.drawLines()
    }
 
    @objc func initLineChart() {
        self.lineContext.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.0001) //白色画布
        self.lineContext.fill(CGRect(x:0, y:0,width:self.frame.size.width,height:self.frame.size.height))
    }
    
    @objc func drawLines() {
        for secIndex in 0 ..< chart.sections!.count {
            let sec = chart.sections!.object(at: secIndex) as! Section
            if sec.hidden! {
                continue
            }
            
            for sIndex in 0 ..< sec.series!.count {
                let serie = sec.series!.object(at: sIndex) as AnyObject
                
                if sec.hidden! {
                    continue
                }
                if serie.isKind(of: NSMutableArray.self) {
                    let se = serie as! NSMutableArray
                    for i in 0 ..< se.count {
                        self.drawLine(serie: se.object(at: i) as! NSMutableDictionary)
                    }
                }else {
                    self.drawLine(serie: serie as! NSMutableDictionary)
                }
            }
        }
    }
    @objc func drawLine(serie:NSMutableDictionary) {
        let type = serie.object(forKey: "type") as! String
        let model:ChartModel = chart.getModel(name: type)
        model.drawLines(chart: chart, serie: serie, context:lineContext!)
        
        let enumerator = chart.models!.keyEnumerator()
        while let key = enumerator.nextObject() {
            let m:ChartModel = chart.models!.object(forKey: key) as! ChartModel
            m.drawTips(chart: chart, serie: serie, context:lineContext!)
        }
    }
    
    //touch delegate
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toucheskBtnView(touches: touches, withEvent: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        toucheskRightView2(touches: touches, withEvent: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        toucheskBtnView(touches: touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        toucheskRightView2(touches: touches, withEvent: event)
    }
    
    @objc func toucheskBtnView(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let ts:NSArray = (touches as NSSet).allObjects as NSArray
        
        if ts.count == 1 {
            let touch:UITouch = ts.object(at: 0) as! UITouch
            chart.touchY = touch.location(in: self).y//获取触摸点坐标
            
            let i = self.getIndexOfSection(point: touch.location(in: self))
            if i != -1 {
                let sec = chart.sections!.object(at: i) as! Section
                if touch.location(in: self).x >= sec.paddingLeft {
                    self.setSelectedIndexByPoint(point: touch.location(in: self))
                }
            }
        }
    }
    
    @objc func getIndexOfSection(point:CGPoint) -> Int {
        for i in 0 ..< chart.sections!.count {
            let sec = chart.sections!.object(at: i) as! Section
            if sec.frame!.contains(point) {
                return i
            }
        }
        return -1
    }
    
    @objc func toucheskRightView2(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //点击结束时重新绘制一下，去掉十字线
        chart.selectedIndex = -1
        self.setNeedsDisplay()
    }
    
    @objc func setSelectedIndexByPoint(point:CGPoint) {
        if self.getIndexOfSection(point: point) == -1 {
            return
        }
        
        let intXPoint = Int((point.x - CGFloat(chart.paddingLeft))/CGFloat(chart.plotWidth!));
        if point.x > CGFloat(chart.paddingLeft + CGFloat(chart.rangeTo) * chart.plotWidth!) {
            return
        }
        chart.selectedIndex = intXPoint
        self.setNeedsDisplay()
    }
}
