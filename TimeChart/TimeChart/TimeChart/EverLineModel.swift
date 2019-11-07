//
//  EverLineModel.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class EverLineModel: ChartModel {
    
    override func drawSerie(chart:EverChart, serie:NSMutableDictionary, context:CGContext) {
        
        let data = serie["data"] as! NSMutableArray
        if data.count == 0 {
            return
        }
        
        context.setShouldAntialias(true)
        context.setLineWidth(1.0)
        
        let yAxis = 0//serie.objectForKey("yAxis")?.integerValue
        let section = (serie["section"] as! String).stringToInt()
        let color = serie.object(forKey: "color") as! UIColor
        let sec = chart.sections!.object(at: section) as! Section
        
        //画分时
        context.setShouldAntialias(true)
        for i in chart.rangeFrom! ..< chart.rangeTo {
            if i == data.count - 1 {
                break
            }
            
            if i < chart.rangeTo! - 1 {
                let value = CGFloat((data[i] as! NSArray)[0] as! Double)//均价或实时价格
                let ix = sec.frame!.origin.x+CGFloat(sec.paddingLeft)+CGFloat(i)*chart.plotWidth!;
                let iNx = sec.frame!.origin.x+CGFloat(sec.paddingLeft)+CGFloat(i+1)*chart.plotWidth!
                let iy = chart.getLocalY(val: value, withSection: section, withAxis: yAxis)
                let y = chart.getLocalY(val: CGFloat((data[i+1] as! NSArray)[0] as! Double), withSection: section, withAxis: yAxis)
                
                context.setStrokeColor(color.cgColor)
                if !y.isNaN && !iy.isNaN {
                    context.move(to: CGPoint(x: ix+CGFloat(chart.plotWidth!/2), y: iy))
                    context.addLine(to: CGPoint(x: iNx+CGFloat(chart.plotWidth!)/2, y: y))
                }
                context.strokePath()
            }
        }
    }
    
    override func drawLines(chart: EverChart, serie: NSMutableDictionary, context: CGContext) {

        let data = serie["data"] as! NSMutableArray
        let yAxis = 0//serie.objectForKey("yAxis")?.integerValue
        let section = (serie["section"] as! String).stringToInt()
        let color = serie["color"] as! UIColor
        let yAxisType = serie["yAxisType"] as! String
        let sec = chart.sections!.object(at: section) as! Section
        
        
        //设置选中点，竖线以及小球颜色
        if chart.selectedIndex != -1 && chart.selectedIndex < data.count {
            
            //设置选中点竖线
            let value = CGFloat((data[chart.selectedIndex!] as! NSArray)[0] as! Double)
            //画竖线
            context.move(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft)+CGFloat(chart.selectedIndex!)*chart.plotWidth!+CGFloat(chart.plotWidth!)/2, y: sec.frame!.origin.y+CGFloat(sec.paddingTop)))
            context.addLine(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft)+CGFloat(chart.selectedIndex!)*chart.plotWidth!+CGFloat(chart.plotWidth!)/2, y: sec.frame!.size.height+sec.frame!.origin.y))
            context.setStrokeColor(color333333.cgColor)
            context.strokePath()
            
            //设置选中点小球颜色
            context.beginPath();
            context.setFillColor(color.cgColor)
            let y = chart.getLocalY(val: value, withSection: section, withAxis: yAxis)
            if !y.isNaN {
                context.addArc(center: CGPoint(x:sec.frame!.origin.x+CGFloat(sec.paddingLeft)+CGFloat(chart.selectedIndex!)*chart.plotWidth!+CGFloat(chart.plotWidth!)/2, y:y), radius: 3, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            }
            context.fillPath();
            if yAxisType == "1" {
                //画点击时的横线
                if chart.touchY > sec.paddingTop && chart.touchY < sec.frame!.size.height {
                    let value = CGFloat((data[chart.selectedIndex!] as! NSArray)[0] as! Double)
                    
                    context.move(to: CGPoint(x: sec.frame!.origin.x + CGFloat(sec.paddingLeft), y: y))
                    context.addLine(to: CGPoint(x: sec.frame!.origin.x + sec.frame!.size.width, y: y))
                    context.setStrokeColor(color333333.cgColor)
                    context.strokePath()
                    
                    //计算横线对应刻度
                    let yaxis = sec.yAxises![0] as! YAxis
                    
                    //画横线左侧刻度标记
                    let text:String?
                    if yaxis.decimal == 0 {
                        text = "\(value)"//touchPointValue
                    }else {
                        text = String(format: "%.\(yaxis.decimal!)f", value) + " "//touchPointValue
                    }
                    
                    let style = NSMutableParagraphStyle()
                    style.alignment = NSTextAlignment.center
                    
                    let attributes = [NSAttributedStringKey.font:UIFont(name: "Helvetica", size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:color1200ff]
                    let textSize = (text! as NSString).size(withAttributes: attributes)
                    let rect = CGRect(x:sec.frame!.origin.x + 1, y:CGFloat(chart.getLocalY(val: value, withSection: section, withAxis: yAxis)) - (textSize.height + 2)/2.0, width:textSize.width + 1, height:textSize.height + 2)
                    
                    context.setShouldAntialias(true)
                    context.setStrokeColor(color1200ff.cgColor)
                    context.setFillColor(UIColor.white.cgColor)
                    context.setLineWidth(1)
                    
                    context.fill(rect)
                    
                    let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
                    context.addPath(path.cgPath)
                    context.strokePath()
                    
                    (text! as NSString).draw(in: rect, withAttributes: attributes)
                }
            }
        }
    }
    
    //上边的实时分时图的Y轴
    override func setValuesForYAxis(chart:EverChart, serie:NSDictionary, context:CGContext) {
        let data = serie["data"] as! NSMutableArray
        if data.count == 0 {
            return
        }
        let section = (serie["section"] as! String).stringToInt()
        let yAxisType = serie["yAxisType"] as! String
        
        let yaxis = (chart.sections![section] as! Section).yAxises!.object(at:0) as! YAxis
        if serie["decimal"] != nil {
           yaxis.decimal = serie["decimal"] as! Int
        }
        //data是NSMutableArray类型，data[chart.rangeFrom]是NSArray类型
        let value = CGFloat((data[chart.rangeFrom] as! NSArray)[0] as! Double)
        if !yaxis.isUsed! {
            yaxis.max = value
            yaxis.min = value
            yaxis.isUsed = true
        }
        
        //实时价格线：Y轴区间：昨日收盘价，上下浮动最大涨跌幅，当前最大涨跌幅：（最大/最小 - 昨天收盘价）/ 昨天收盘价
        if yAxisType == "1" {
            var maxNow:CGFloat = 0
            var minNow:CGFloat = CGFloat(MAXFLOAT)
            let closeYesterday = CGFloat((data[0] as! NSArray)[1] as! Double)
            
            for i in 0 ..< data.count {
                let tempArray = data[i] as! NSArray
                let now = CGFloat(tempArray[0] as! Double)
                if minNow > now {
                    minNow = now
                }else if maxNow < now {
                    maxNow = now
                }
            }
            
            let percentMax = (maxNow - closeYesterday)/closeYesterday
            let percentMin = (minNow - closeYesterday)/closeYesterday
            let percent:CGFloat = CGFloat(max(fabs(percentMax), fabs(percentMin)))
            let maxY = closeYesterday * (1 + percent + 0.001)
            let minY = closeYesterday * (1 - percent - 0.001)
            
            //Y轴最大值和最小值的刻度
            yaxis.max = maxY
            yaxis.min = minY
            
            return
        }
        
        for i in chart.rangeFrom..<chart.rangeTo {
            if i == data.count {
                break
            }
            
            let value = CGFloat((data[i] as! NSArray)[0] as! Double)
            if value > yaxis.max {
                yaxis.max = value
            }
            if value < yaxis.min {
                yaxis.min = value
            }
            
        }
    }
    
    //点击分时图时，显示竖线上面的label
    override func drawTips(chart:EverChart, serie:NSMutableDictionary, context:CGContext) {
        
        context.setShouldAntialias(false)
        context.setLineWidth(1.0)
        
        let data = serie["data"] as! NSMutableArray
        let type = serie["type"] as! String
        let section = (serie["section"] as! String).stringToInt()
        let category = serie["category"] as! NSMutableArray
        
        let sec = chart.sections.object(at: section) as! Section
        
        if type == EverMacro.kFenShiLine {
            for i in chart.rangeFrom ..< chart.rangeTo {
                if i == data.count {
                    break
                }
                
                let ix = sec.frame!.origin.x+sec.paddingLeft+CGFloat(CGFloat(chart.selectedIndex!)*chart.plotWidth!)
                
                if i == chart.selectedIndex && chart.selectedIndex < data.count {
                    let tipsText = category.object(at:chart.selectedIndex) as! String//"第\(chart.selectedIndex!)"//
                    context.setShouldAntialias(true)
                    context.setStrokeColor(color1200ff.cgColor)
                    context.setFillColor(UIColor.white.cgColor)
                    
                    let size:CGSize = tipsText.size(withAttributes: [NSAttributedStringKey.font:UIFont(name: "Helvetica", size: EverMacro.kYFontSizeFenShi)!])
                    
                    var x = ix + CGFloat(chart.plotWidth!/2)
                    let y = sec.frame!.origin.y + sec.paddingTop
                    if x + size.width > sec.frame!.size.width + sec.frame!.origin.x {
                        x = x - (size.width + 4)
                    }
                    context.fill(CGRect(x:x,y:y, width:size.width+4,height:size.height+2))
                    let path = UIBezierPath(roundedRect: CGRect(x:x, y:y, width:size.width+4,height:size.height+2), cornerRadius: 4)
                    context.addPath(path.cgPath);
                    context.strokePath()
                    
                    tipsText.draw(at: CGPoint(x:x+2,y:y+1), withAttributes: [NSAttributedStringKey.font:UIFont(name: "Helvetica", size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.foregroundColor:color1200ff])
                    context.setShouldAntialias(false)
                }
                
            }
        }
    }
}
