//
//  EverChart.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class EverChart: UIView {
    
    var enableSelection:Bool?    //是否可以选中
    var isInitialized:Bool?  //是否初始化
    var isSectionInitialized:Bool?
    var borderWidth:CGFloat?
    var plotWidth:CGFloat?   //单位宽度
    var plotPadding:CGFloat? //单位水平间距
    var plotCount:CGFloat?   //单位数量:data.count
    var paddingLeft:CGFloat!
    var paddingRight:CGFloat!
    var paddingTop:CGFloat!
    var paddingBottom:CGFloat!
    var rangeFrom:Int!   //显示开始下标
    var rangeTo:Int! //显示结束下标
    var range:Int!   //显示条数
    var selectedIndex:Int!
    var selectedTimeStr:String!
    var padding:Array<CGFloat>!
    var series:NSMutableArray!
    var sections:NSMutableArray!
    var ratios:NSMutableArray!  //上下比率
    var models:NSMutableDictionary!
    var borderColor:UIColor?
    var title:String?
    var sec1BtnRect = CGRect()  //k线 btn 区域：用于检测手势是否触摸到该区域
    var sec2BtnRect = CGRect()  //成交量等 btn 区域
    var touchOne:CGFloat?
    var touchTwo:CGFloat?
    var touchY:CGFloat = 0  //记录选中点的Y坐标
    
    var context:CGContext!
    var chartLineView:ChartLineView!
    
    var nightRange:Int = 0//晚盘的晚上的数量
    var amTimeRange:Int = 0//晚盘的上午的数量
    var pmTimeRange:Int = 0//晚盘的下午的数量
    var midTimeToMidTime:Int = 0//中午的时间差数量
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.enableSelection = true;
        self.isInitialized   = false;
        self.isSectionInitialized   = false;
        self.selectedIndex   = -1;
        self.selectedTimeStr = ""
        self.padding         = [5,10,5,5]//设置内边距;
        self.paddingTop      = 0;
        self.paddingRight    = 0;
        self.paddingBottom   = 0;
        self.paddingLeft     = 0;
        self.rangeFrom       = 0;
        self.rangeTo         = 0;
        self.range           = 240
        
        self.ratios = NSMutableArray()
        self.models = NSMutableDictionary()
        self.sections = NSMutableArray()
        self.isMultipleTouchEnabled = true
        
        self.initModels()
        chartLineView = ChartLineView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(chartLineView)
        chartLineView.chart = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        self.initChart()
        self.initSections()
        self.initXAxis()
        self.initYAxis()
        self.drawXAxis()    //x轴的上下边线
        self.drawYAxis()
        self.drawChart()
    }
    @objc func drawChart() {
        for secIndex in 0 ..< self.sections.count {
            let sec = self.sections.object(at: secIndex) as! Section
            
            if self.rangeTo! >= self.range! {
                plotWidth = CGFloat(sec.frame!.size.width - sec.paddingLeft)/CGFloat(self.rangeTo!)
            }else {
                plotWidth = CGFloat(sec.frame!.size.width - sec.paddingLeft)/CGFloat(self.range!)
            }
            
            for sIndex in 0 ..< sec.series.count {
                let serie = sec.series.object(at: sIndex) as AnyObject
                
                if sec.hidden! {
                    continue
                }
                if serie.isKind(of:NSMutableArray.self) {
                    let se = serie as! NSMutableArray
                    for i in 0 ..< se.count {
                        self.drawSerie(serie: se.object(at: i) as! NSMutableDictionary)
                    }
                }else {
                    self.drawSerie(serie: serie as! NSMutableDictionary)
                }
            }
        }
    }
    @objc func drawSerie(serie:NSMutableDictionary) {
        let type = serie.object(forKey: "type") as! String
        let model:ChartModel = self.getModel(name: type)
        model.drawSerie(chart: self, serie: serie, context:context!)
    }
    
    @objc func drawYAxis() {
        context.setShouldAntialias(true)
        context.setLineWidth(1.0)
        context.setStrokeColor(color999999.cgColor)
        
        for secIndex in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: secIndex) as! Section
            if sec.hidden! {
                continue
            }
            
            //左边Y轴
            context.move(to:CGPoint(x:sec.frame!.origin.x+CGFloat(sec.paddingLeft),y:sec.frame!.origin.y+CGFloat(sec.paddingTop)))
            context.addLine(to:CGPoint(x:sec.frame!.origin.x+CGFloat(sec.paddingLeft),y:sec.frame!.size.height+sec.frame!.origin.y))
            //右边Y轴
            context.move(to:CGPoint(x:sec.frame!.origin.x+sec.frame!.size.width,y:sec.frame!.origin.y+CGFloat(sec.paddingTop)))
            context.addLine(to:CGPoint(x:sec.frame!.origin.x+sec.frame!.size.width,y:sec.frame!.size.height+sec.frame!.origin.y))
        }
        context.strokePath()
        
        for secIndex in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: secIndex) as! Section
            if sec.hidden! {
                continue
            }
            
            //中间竖线（虚线）
            if EverMacro.nightBegin != "" {//判断是否有晚盘
                
                let interWidth = (sec.frame!.size.width - CGFloat(sec.paddingLeft)) / CGFloat(self.range!)//（24点-晚上的时间）+ 下午结束时间 - 上午开盘时间
                for i in 1...self.range! {
                    if i == nightRange || i == (nightRange + amTimeRange)  {
                        let lengths:[CGFloat] = [1,0]
                        context.setLineDash(phase: 0, lengths: lengths)//设置图形上下文中的虚线的模式
                        context.setLineWidth(0.5)
                        
                        context.move(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft) + interWidth * CGFloat(i), y: sec.frame!.origin.y+CGFloat(sec.paddingTop)))
                        context.addLine(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft) + interWidth * CGFloat(i), y: sec.frame!.size.height+sec.frame!.origin.y))
                        context.strokePath()
                    }else {
                        //设置虚线
                        //                        let dash:[CGFloat] = [1,1]//绘制一个点，跳过一个点
                        //                        CGContextSetLineDash(context, 20, dash, dash.count)
                        //                        CGContextSetLineWidth(context, 0.5)
                    }
                    
                }
            }else {
                let interWidth = (sec.frame!.size.width - CGFloat(sec.paddingLeft)) / 4.0
                for i in 1 ..< 4 {
                    if i == 2 {//设置实线|| i == 0 || i == 4
                        let lengths:[CGFloat] = [1,0]
                        context.setLineDash(phase: 0, lengths: lengths)//设置图形上下文中的虚线的模式
                        context.setLineWidth(0.5)
                    }else {
                        //设置虚线
                        let dash:[CGFloat] = [1,1]//绘制一个点，跳过一个点
                        context.setLineDash(phase: 20, lengths: dash)
                        context.setLineWidth(0.5)
                    }
                    context.move(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft) + interWidth * CGFloat(i), y: sec.frame!.origin.y+CGFloat(sec.paddingTop)))
                    context.addLine(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft) + interWidth * CGFloat(i), y: sec.frame!.size.height+sec.frame!.origin.y))
                    context.strokePath()
                }
            }
        }
        
        for secIndex in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: secIndex) as! Section
            if sec.hidden! {
                continue
            }
            
            for aIndex in 0 ..< sec.yAxises!.count {
                let yaxis = sec.yAxises!.object(at: aIndex) as! YAxis
                //获取Y轴类型
                let seriesY = sec.series.object(at: aIndex) as AnyObject
                var yAxisType = String()
                if seriesY.isKind(of: NSMutableDictionary.self) {
                    yAxisType = seriesY["type"] as! String
                }
                
                let step = (yaxis.max! - yaxis.min!)/CGFloat(yaxis.tickInterval)
                let baseY = self.getLocalY(val: yaxis.baseValue!, withSection: secIndex, withAxis: aIndex)
                let middleValue = yaxis.baseValue! + 2 * step
                
                let style = NSMutableParagraphStyle()
                style.alignment = NSTextAlignment.left
                
                let style2 = NSMutableParagraphStyle()
                style2.alignment = NSTextAlignment.right
                
                
                //原点处的Y轴刻度
                if yAxisType == EverMacro.kFenShiLine {
                    //显示分时图原点处左侧价格刻度
                    String(format: "%.\(yaxis.decimal!)f", yaxis.baseValue!).draw(in: CGRect(x:sec.frame!.origin.x+2, y:CGFloat(baseY) - EverMacro.kYFontSizeFenShi, width:sec.frame!.origin.x + 60, height:EverMacro.kYFontSizeFenShi * 2), withAttributes: [NSAttributedStringKey.font:UIFont(name: EverMacro.KYFontName, size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:color63b527])
                    
                    //显示分时图原点处右侧值
                    let percentText = String(format: "%.\(yaxis.decimal!)f", (yaxis.baseValue! - middleValue))
                    (percentText as NSString).draw(in: CGRect(x:sec.frame!.origin.x + sec.frame!.size.width - 62, y:CGFloat(baseY) - EverMacro.kYFontSizeFenShi, width:60, height:EverMacro.kYFontSizeFenShi * 2), withAttributes: [NSAttributedStringKey.font:UIFont(name: EverMacro.KYFontName, size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.paragraphStyle:style2,NSAttributedStringKey.foregroundColor:color63b527])
                }
                
                if yaxis.tickInterval % 2 == 1 {//刻度间隔
                    yaxis.tickInterval! += 1
                }
                
                for i in 1...yaxis.tickInterval {
                    //设置X横轴的虚线
                    let dash:[CGFloat] = [1,1]
//                    CGContextSetLineDash(context, 20, dash, 2)
                    context.setLineDash(phase: 20, lengths: dash)
                    context.setLineWidth(1)
                    //                    print("\(i)1===\(yaxis.baseValue! + Float(i)*step)===\(yaxis.max)")
                    if yaxis.baseValue! <= yaxis.max && yaxis.min < CGFloat(MAXFLOAT) {//if yaxis.baseValue! + Float(i)*step <= yaxis.max && yaxis.min < MAXFLOAT {
                        let iy = self.getLocalY(val: yaxis.baseValue! + CGFloat(i)*step, withSection: secIndex, withAxis: aIndex)
                        //                        print("\(i)2===\(iy)")
                        var textColor = color666666
                        
                        //Y轴最大刻度，显示位置靠下
                        let offset = (i == yaxis.tickInterval) ? 0 : EverMacro.kYFontSizeFenShi/2
                        //成交量显示缩写
                        var valueY = String(format: "%.\(yaxis.decimal!)f", yaxis.baseValue! + CGFloat(i)*step)
                        if yAxisType == EverMacro.kFenShiColumn {//成交量的Y
                            valueY = self.roundFloatDisplay(v: CGFloat(yaxis.baseValue!+CGFloat(i)*step), index:i)
                            textColor = color333333
                        }else {
                            if i == 1 {
                                textColor = color63b527
                            }else if i == 2 {
                                textColor = UIColor.black
                                context.setLineDash(phase: 0, lengths: [1,0])
                                context.setLineWidth(0.5)
                            }else if i > 2 {
                                textColor = colorTheme
                            }
                        }
                        //显示分时图左侧价格刻度
                        (valueY as NSString).draw(in: CGRect(x:sec.frame!.origin.x + 2, y:CGFloat(iy) - offset, width:sec.frame!.origin.x + 60, height:EverMacro.kYFontSizeFenShi * 2), withAttributes: [NSAttributedStringKey.font:UIFont(name: EverMacro.KYFontName, size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.paragraphStyle:style,NSAttributedStringKey.foregroundColor:textColor])
                        
                        //显示分时图右侧百分比
                        if yAxisType == EverMacro.kFenShiLine {
                            var percentText = String(format: "%.\(yaxis.decimal!)f", (yaxis.baseValue! + CGFloat(i) * step - middleValue))
                            if (percentText as NSString).floatValue > 0 {
                                percentText = "+"+percentText
                            }
                            (percentText as NSString).draw(in: CGRect(x:sec.frame!.origin.x + sec.frame!.size.width - 60, y:CGFloat(iy) - offset, width:60, height:EverMacro.kYFontSizeFenShi * 2), withAttributes: [NSAttributedStringKey.font : UIFont(name: EverMacro.KYFontName, size: EverMacro.kYFontSizeFenShi)!,NSAttributedStringKey.paragraphStyle:style2,NSAttributedStringKey.foregroundColor:textColor])
                        }
                        if yaxis.baseValue! + CGFloat(i) * step < yaxis.max {
                            context.setStrokeColor(UIColor.darkGray.cgColor) //图表虚线颜色
                            context.move(to: CGPoint(x: sec.frame!.origin.x + CGFloat(sec.paddingLeft), y: CGFloat(iy)))
                            context.addLine(to: CGPoint(x: sec.frame!.origin.x+sec.frame!.size.width, y: CGFloat(iy)))
                        }
                        context.strokePath()
                    }
                }
            }
        }
        context.setLineDash(phase: 0, lengths: [])
    }
    
    @objc func roundFloatDisplay(v:CGFloat, index:Int) -> String {
        
        var value = v
        var unit:String = "手"
        
        if value > 10000 {
            value /= 10000.0
            unit = "万手"
        }
        
        if value > 100000000 {
            value /= 100000000
            unit = "亿手"
        }
        if index == 1 {
            return ""
        }else {
            return String(format: "%.2f", value) + unit
        }
    }
    
    //当前点的Y值
    @objc func getLocalY(val:CGFloat, withSection sectionIndex:Int, withAxis yAxisIndex:Int) -> CGFloat {
        
        let sec = self.sections!.object(at: sectionIndex) as! Section
        let yaxis = sec.yAxises!.object(at: yAxisIndex) as! YAxis
        let fra = sec.frame!
        let max = yaxis.max!
        let min = yaxis.min!
        
        //        if max == min {
        //            return 0
        //        }
        
        let localY = CGFloat(fra.size.height) - CGFloat(fra.size.height - sec.paddingTop) * (val - min)/(max - min) + CGFloat(fra.origin.y)
        return localY
    }
    //x轴的上下边线
    @objc func drawXAxis() {
        context.setShouldAntialias(false)
        context.setLineWidth(0.5)
        context.setStrokeColor(color999999.cgColor)
        
        for i in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: i) as! Section
            if sec.hidden! {
                continue
            }
            
            if i == 0 {
                sec.paddingTop = 0
            }else {
                sec.paddingTop = 20
            }
            //上边X轴
            context.move(to: CGPoint(x: sec.frame!.origin.x + CGFloat(sec.paddingLeft), y: sec.frame!.origin.y + CGFloat(sec.paddingTop)))
            context.addLine(to: CGPoint(x: sec.frame!.origin.x+sec.frame!.size.width, y: sec.frame!.origin.y+CGFloat(sec.paddingTop)))
            //下边X轴
            context.move(to: CGPoint(x: sec.frame!.origin.x+CGFloat(sec.paddingLeft), y: sec.frame!.size.height+sec.frame!.origin.y))
            context.addLine(to: CGPoint(x: sec.frame!.origin.x+sec.frame!.size.width, y: sec.frame!.size.height+sec.frame!.origin.y))
        }
        context.strokePath()
    }
    
    @objc func initYAxis() {
        for secIndex in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: secIndex) as! Section
            for sIndex in 0 ..< sec.yAxises!.count {
                let yaxis = sec.yAxises!.object(at: sIndex) as! YAxis
                yaxis.isUsed = false
            }
        }
        
        
        for secIndex in 0 ..< self.sections!.count {
            let sec = self.sections!.object(at: secIndex) as! Section
            for sIndex in 0 ..< sec.series.count {
                let serie = sec.series[sIndex] as AnyObject
                if serie.isKind(of:NSMutableArray.self) {
                    let se = serie as! NSMutableArray
                    for i in 0 ..< se.count {
                        self.setValuesForYAxis(serie: se.object(at: i) as! NSDictionary)
                    }
                }else {
                    self.setValuesForYAxis(serie: serie as! NSDictionary)
                }
            }
            
            //y的初始值
            for i in 0 ..< sec.yAxises!.count {
                let yaxis = sec.yAxises!.object(at: i) as! YAxis
                
                if !yaxis.baseValueSticky! {
                    if yaxis.max >= 0 && yaxis.min >= 0 {
                        yaxis.baseValue = yaxis.min!
                    }else if yaxis.max < 0 && yaxis.min < 0 {
                        yaxis.baseValue = yaxis.max!
                    }else {
                        yaxis.baseValue = 0
                    }
                }else {
                    if yaxis.baseValue < yaxis.min {
                        yaxis.min = yaxis.baseValue
                    }
                    
                    if yaxis.baseValue > yaxis.max {
                        yaxis.max = yaxis.baseValue
                    }
                }
            }
        }
    }
    
    @objc func setValuesForYAxis(serie:NSDictionary) {
        let type = serie.object(forKey: "type") as! String
        let model = self.getModel(name: type)
        model.setValuesForYAxis(chart: self, serie: serie, context:context!)
    }
    
    @objc func getModel(name:String) -> ChartModel {
        return self.models!.object(forKey: name) as! ChartModel
    }
    
    @objc func initXAxis() {
        
    }
    
    @objc func initSections() {
        let height = (self.frame.size.height) - CGFloat(self.paddingTop + self.paddingBottom)
        let width = (self.frame.size.width) - CGFloat(self.paddingLeft + self.paddingRight)
        
        var total:Int = 0
        for i in 0 ..< self.ratios!.count {
            if (self.sections!.object(at: i) as! Section).hidden! {
                continue
            }
            let ratio = (self.ratios!.object(at: i) as! String).stringToInt()
            total += ratio
        }
        var prevSec = Section()
        for i in 0 ..< self.sections!.count {
            let ratio = (self.ratios!.object(at: i) as! String).stringToInt()
            let sec = self.sections!.object(at: i) as! Section
            if sec.hidden! {
                continue
            }
            let h = height * CGFloat(ratio) / CGFloat(total)
            let w = width
            if i == 0 {
                sec.frame = CGRect(x:0 + CGFloat(self.paddingLeft), y:0 + CGFloat(self.paddingTop), width:w, height:h)
            }else {
                if i == self.sections!.count - 1 {
                    sec.frame = CGRect(x:0 + CGFloat(self.paddingLeft), y:prevSec.frame!.origin.y + prevSec.frame!.size.height, width:w, height:CGFloat(self.paddingTop) + height - (prevSec.frame!.origin.y + prevSec.frame!.size.height))
                }else {
                    sec.frame = CGRect(x:0 + CGFloat(self.paddingLeft), y:prevSec.frame!.origin.y + prevSec.frame!.size.height, width:w,height:h)
                }
            }
            prevSec = sec
        }
        self.isSectionInitialized = true
    }
    
    @objc func initChart() {
        if !self.isInitialized! {//true
            self.plotPadding = 0.5  //单位水平间距
            self.paddingTop = self.padding[0]
            self.paddingBottom = self.padding[1]
            self.paddingLeft = self.padding[2]
            self.paddingRight = self.padding[3]
            if self.series != nil {
                self.rangeTo = ((self.series.object(at: 0) as! NSDictionary)["data"]! as! NSMutableArray).count
                //                if rangeTo! - range! >= 0 {
                //                    self.rangeFrom = rangeTo! - range!
                //                }else {
                self.rangeFrom = 0
                //                }
            }else {
                self.rangeTo = 0
                self.rangeFrom = 0
            }
            //            self.selectedIndex = self.rangeTo! - 1
            self.isInitialized = true
        }
        
        if self.series != nil {
            self.plotCount = CGFloat(((self.series.object(at: 0) as! NSDictionary)["data"]! as! NSMutableArray).count)
        }
        
        //横屏页面公用这个方法
        self.amTimeRange = Int(CalculateTime.timeDifference(dateStr1: EverMacro.amTime, dateStr2: EverMacro.amTimeToMid)) + 1//包括11：30那个点
        self.pmTimeRange = Int(CalculateTime.timeDifference(dateStr1: EverMacro.midTopmTime, dateStr2: EverMacro.pmTime)) + 1//包括15：00那个点
        self.midTimeToMidTime = Int(CalculateTime.timeDifference(dateStr1: EverMacro.amTimeToMid, dateStr2: EverMacro.midTopmTime))//中午之间的时间差,这个计算有点慢
        if EverMacro.nightBegin == "" {//日盘
            self.range = self.amTimeRange + self.pmTimeRange
        }else {//晚盘
            //判断晚盘的结束时间是否在24点之前和晚盘开盘时间之后
            let nightEndTimeBl = CalculateTime.isBetweenTwoStrTime(curTimeStr: EverMacro.nightEnd, dateStr1: EverMacro.nightBegin, dateStr2: "23:59")
            if nightEndTimeBl {//在
                let minute1 = CalculateTime.timeDifference(dateStr1: EverMacro.nightBegin, dateStr2: EverMacro.nightEnd) + 1//包括23：00那个点
                self.nightRange = Int(minute1)//晚盘的晚上的数量
            }else {//在24点之后
                let minute1 = CalculateTime.timeDifference(dateStr1: EverMacro.nightBegin, dateStr2: "23:59")
                let minute2 = CalculateTime.timeDifference(dateStr1: "00:00", dateStr2: EverMacro.nightEnd) + 1//包括02：00那个点
                self.nightRange = Int(minute1 + minute2)//晚盘的晚上的数量
            }
            self.range = self.nightRange + self.amTimeRange + self.pmTimeRange
        }
        
        context = UIGraphicsGetCurrentContext()
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1.0) //白色画布
        context.fill(CGRect(x:0, y:0,width:self.frame.size.width,height:self.frame.size.height))
    }
    
    @objc func judleNightTime(lastTimeStr:String) -> Int {
        let midTime = CalculateTime.timeDifference(dateStr1: lastTimeStr, dateStr2: EverMacro.amTimeToMid)
        var timeDifference = CalculateTime.timeDifference(dateStr1: EverMacro.amTime, dateStr2: lastTimeStr)//时间差
        if midTime < 0 {//如果时间是在11:30之后的，timeDifference - 90（13:00-11:30=90分钟）
            timeDifference = timeDifference - Double(midTimeToMidTime)
        }
        return Int(timeDifference)
    }
    
    @objc func initModels() {
        //line
        var model:ChartModel = EverLineModel()
        self.addModel(model: model, withName: EverMacro.kFenShiLine)
        
        //column
        model = EverColumnModel()
        self.addModel(model: model, withName: EverMacro.kFenShiColumn)
    }
    @objc func addModel(model:ChartModel, withName name:String) {
        self.models[name] = model
    }
    
    @objc func getYAxis(section:Int, withIndex index:Int) -> YAxis {
        let sec = self.sections.object(at: section) as! Section
        let yaxis = sec.yAxises.object(at: index) as! YAxis
        return yaxis
    }
    
    @objc func removeSection(index:Int) {
        
    }
    
    @objc func addSections(num:Int, withRatios rats:NSArray) {
        for i in 0 ..< num {
            let sec = Section()
            self.sections.add(sec)
            self.ratios.add(rats.object(at:i))
        }
    }
    
    @objc func appendToData(data:NSMutableArray, forName name:String) {
        for i in 0 ..< self.series.count {//series是数组
            let seriesI = self.series[i] as! NSMutableDictionary
            if (seriesI["name"] as! String) == name {
                if (seriesI["data"] as? NSMutableArray) == nil {
                    let tempData = NSMutableArray()
                    seriesI["data"] = tempData
                }
                
                for j in 0 ..< data.count {//data是数组
                    (seriesI["data"] as! NSMutableArray).add(data[j])
                }
            }
        }
    }
    
    @objc func appendToCategory(category:NSMutableArray,forName name:String) {
        for i in 0 ..< self.series.count {//series是数组
            let seriesI = self.series[i] as! NSMutableDictionary
            if (seriesI["name"] as! String) == name {
                if (seriesI["category"] as? NSMutableArray) == nil {
                    let tempData = NSMutableArray()
                    seriesI["category"] = tempData
                }
                
                for j in 0 ..< category.count {
                    (seriesI["category"] as! NSMutableArray).add(category[j])
                }
            }
        }
    }
    
    @objc func reset() {
        self.isInitialized = false
    }
    
    @objc func clearData() {
        for i in 0 ..< self.series.count {
            ((self.series.object(at:i) as! NSMutableDictionary)["data"] as! NSMutableArray).removeAllObjects()
        }
    }
    
    @objc func clearCategory() {
        for i in 0..<self.series.count {
            ((self.series.object(at:i) as! NSMutableDictionary)["category"] as! NSMutableArray).removeAllObjects()
        }
    }
    
}

class Mypiont:NSObject{
    var x:CGFloat!;
    var y:CGFloat!;
    @objc init(x:CGFloat,y:CGFloat){
        self.x = x;
        self.y = y;
    }
}
