//
//  EverColumnModel.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class EverColumnModel: ChartModel {

    override func drawSerie(chart: EverChart, serie: NSMutableDictionary, context:CGContext) {
        
        let data = serie["data"] as! NSMutableArray
        if data.count == 0 {
            return
        }

        context.setShouldAntialias(true)
        context.setLineWidth(1.0)
        
        let yAxis = 0//serie.objectForKey("yAxis")?.integerValue
        let section = (serie["section"] as! String).stringToInt()
        let sec = chart.sections!.object(at: section) as! Section
        let yaxis = (chart.sections!.object(at: section) as! Section).yAxises!.object(at: Int(yAxis)) as! YAxis
        
        //画柱状图
        context.setLineWidth(0.8)

        for i in chart.rangeFrom! ..< chart.rangeTo! {
            if i == data.count {
                break
            }
            
            var value = (data.object(at: i) as! NSArray)[0] as! Int//成交量
            let nowPri = CGFloat((data.object(at: i) as! NSArray)[1] as! Double) //取实时价格
            var prePri:CGFloat = 0
            
            if i == 0 {
                let closeYesterday = CGFloat((data.object(at: i) as! NSArray)[2] as! Double)
                prePri = closeYesterday
            }else {
                prePri = CGFloat((data.object(at: i-1) as! NSArray)[1] as! Double)
            }
            value = (data.object(at: i) as! NSArray)[0] as! Int
            
            let ix = sec.frame!.origin.x + sec.paddingLeft + CGFloat(i)*chart.plotWidth!//i - chart.rangeFrom!
            let iy = chart.getLocalY(val: CGFloat(value), withSection: section, withAxis: yAxis)
            //显示颜色：实时价格和上一分钟相比较；第一条和昨天收盘价比较；
            if nowPri < prePri {//下跌
                context.setStrokeColor(color63b527.cgColor)
                context.setFillColor(color63b527.cgColor)
                
                context.fill(CGRect(x:ix+CGFloat(chart.plotPadding!), y:CGFloat(iy), width:CGFloat(chart.plotWidth!-chart.plotPadding!),height:CGFloat(chart.getLocalY(val: CGFloat(yaxis.baseValue!), withSection: section, withAxis: yAxis)-iy)))
            }else if nowPri > prePri {//上涨
                context.setStrokeColor(colorTheme.cgColor)
                context.setFillColor(colorTheme.cgColor);
                
                context.fill(CGRect(x:ix+CGFloat(chart.plotPadding!), y:CGFloat(iy), width:CGFloat(chart.plotWidth!-chart.plotPadding!), height:CGFloat(chart.getLocalY(val: CGFloat(yaxis.baseValue!), withSection: section, withAxis: yAxis)-iy)));
                
            }else if nowPri == prePri {
                context.setStrokeColor(color999999.cgColor)
                context.setFillColor(color999999.cgColor);
                context.fill(CGRect(x:ix+CGFloat(chart.plotPadding!), y:CGFloat(iy), width:CGFloat(chart.plotWidth!-chart.plotPadding!), height:CGFloat(chart.getLocalY(val: CGFloat(yaxis.baseValue!), withSection: section, withAxis: yAxis)-iy)));
            }
        }
        
        var fromDate:String!
        var toDate:String!
        //标记X轴时间，只标记首尾
        fromDate = "\(EverMacro.amTime)"
        let middleDate = "\(EverMacro.amTimeToMid)/\(EverMacro.midTopmTime)"
        toDate = "\(EverMacro.pmTime)"
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        (fromDate as NSString).draw(in: CGRect(x:sec.frame!.origin.x + sec.paddingLeft, y:sec.frame!.origin.y + 4, width:100, height:EverMacro.kYFontSizeFenShi*2), withAttributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: EverMacro.kYFontSizeFenShi),NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:color333333])
        
        style.alignment = NSTextAlignment.center
        let attributes = [NSAttributedStringKey.font:UIFont.systemFont(ofSize: EverMacro.kYFontSizeFenShi),NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:color333333]
        let width = (middleDate as NSString).size(withAttributes: attributes).width
        let mx = (sec.frame!.size.width - sec.paddingLeft)/2
        (middleDate as NSString).draw(in: CGRect(x:mx - width/2 + sec.paddingLeft + sec.frame!.origin.x, y:sec.frame!.origin.y + 4, width:width, height:EverMacro.kYFontSizeFenShi*2), withAttributes: attributes)
        
        style.alignment = NSTextAlignment.right
        (toDate as NSString).draw(in: CGRect(x:sec.frame!.origin.x + sec.frame!.size.width - 100, y:sec.frame!.origin.y + 4, width:100, height:EverMacro.kYFontSizeFenShi*2), withAttributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: EverMacro.kYFontSizeFenShi),NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:color333333])
    }
    
    override func drawLines(chart: EverChart, serie: NSMutableDictionary, context: CGContext) {
        
        let data = serie["data"] as! NSMutableArray
        let yAxis = 0//serie.objectForKey("yAxis")?.integerValue
        let section = (serie["section"] as! String).stringToInt()
        let sec = chart.sections!.object(at: section) as! Section
        
        
        //设置选中点小球
        if chart.selectedIndex != -1 && chart.selectedIndex < data.count {
            var value = CGFloat((data.object(at: chart.selectedIndex) as! NSArray)[0] as! Int)
            
            //判断颜色
            let nowPri = CGFloat((data.object(at: chart.selectedIndex) as! NSArray)[1] as! Double)
            var prePri:CGFloat = 0
            if chart.selectedIndex == 0 {
                let closeYesterday = CGFloat((data.object(at: chart.selectedIndex) as! NSArray)[2] as! Double)
                prePri = closeYesterday
            }else {
                prePri = CGFloat((data.object(at: chart.selectedIndex - 1) as! NSArray)[1] as! Double)
            }
            value = CGFloat((data.object(at: chart.selectedIndex) as! NSArray)[0] as! Int)
            
            var color = colorTheme
            if nowPri < prePri {
                color = color63b527
            }else if nowPri > prePri {
                color = colorTheme
            }else {
                color = color999999
            }
            
            context.setStrokeColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor)
            context.move(to: CGPoint(x: sec.frame!.origin.x+sec.paddingLeft+CGFloat(chart.selectedIndex)*chart.plotWidth!+CGFloat(chart.plotWidth!/2), y: sec.frame!.origin.y+sec.paddingTop))//chart.selectedIndex-chart.rangeFrom!
            context.addLine(to: CGPoint(x: sec.frame!.origin.x+sec.paddingLeft+CGFloat(chart.selectedIndex)*chart.plotWidth!+CGFloat(chart.plotWidth!/2), y: sec.frame!.size.height+sec.frame!.origin.y))
            
            context.strokePath()
            context.setShouldAntialias(true)
            context.beginPath()
            context.setFillColor(color.cgColor);
            let y = chart.getLocalY(val: value, withSection: section, withAxis: yAxis)
            if !y.isNaN {
//                CGContextAddArc(context, sec.frame!.origin.x+sec.paddingLeft+CGFloat(chart.selectedIndex)*chart.plotWidth!+CGFloat(chart.plotWidth!/2), y, 3, 0, CGFloat(2*M_PI), 1);
                context.addArc(center: CGPoint(x:sec.frame!.origin.x+sec.paddingLeft+CGFloat(chart.selectedIndex)*chart.plotWidth!+CGFloat(chart.plotWidth!/2), y:y), radius: 3, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            }
            context.fillPath();
        }
    }
    
    override func setValuesForYAxis(chart: EverChart, serie: NSDictionary, context:CGContext) {
        
        let data = serie["data"] as! NSMutableArray
        if data.count == 0 {
            return
        }
        
        let yAxis = 0
        let section = (serie["section"] as! String).stringToInt()
        
        let yaxis = (chart.sections.object(at:section) as! Section).yAxises.object(at:yAxis) as! YAxis
        if serie["decimal"] != nil {
            yaxis.decimal = serie["decimal"] as? Int
        }
        
        var value = CGFloat((data[chart.rangeFrom] as! NSArray)[0] as! Int)//Int:Int64
        if !yaxis.isUsed! {
            yaxis.max = value
            yaxis.min = value
            yaxis.isUsed = true
        }
        var values:[CGFloat] = []
        
        for i in chart.rangeFrom ..< chart.rangeTo {
            if i == data.count {
                break
            }
            value = CGFloat((data.object(at:i) as! NSArray)[0] as! Int)
            values.append(value)
            //比较取出成交量y的最大值
            
            if value > yaxis.max {
                yaxis.max = value// * 1.1
            }
            
            if value < yaxis.min {
                yaxis.min = value
            }
        }
        if yaxis.max < 2 {
            yaxis.max = 2
        }
    }
}
