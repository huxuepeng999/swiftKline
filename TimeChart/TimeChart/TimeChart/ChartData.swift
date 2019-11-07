//
//  ChartData.swift
//  PBSwift
//
//  Created by huxuepeng on 16/6/21.
//  Copyright © 2016年 mecrt. All rights reserved.
//

import Foundation

class ChartData {
    
    var fenshiChart:EverChart!
    var decimal:Int = 2
    
    init(fenshiChart:EverChart) {
        self.fenshiChart = fenshiChart
    }
    
    func drawFenshi(dic:NSDictionary) {
        self.initFenShiChart(decimal: decimal)
        self.renderChart(dic:dic)
    }
    
    // 绘制分时图
    func initFenShiChart(decimal:Int) {
                
        if fenshiChart.sections!.count == 0 {
            let secs = NSMutableArray()
            secs.add("2") //设置上下两部分比例
            secs.add("1")
            fenshiChart.addSections(num: 2, withRatios: secs)
            (fenshiChart.sections!.object(at: 0) as! Section).addYAxis(pos: 0)
            (fenshiChart.sections!.object(at: 1) as! Section).addYAxis(pos: 0)
        }
        
        fenshiChart.getYAxis(section: 0, withIndex: 0).tickInterval = 4    //设置虚线数量
        fenshiChart.getYAxis(section: 1, withIndex: 0).tickInterval = 2    //设置虚线数量
        
        let series = NSMutableArray()
        let secOne = NSMutableArray()
        let secTwo = NSMutableArray()
        
        //均价
        var serie = NSMutableDictionary()
        var data = NSMutableArray()
        serie["name"] = EverMacro.kFenShiAvgNameLine//用于标记线段名称
        serie["label"] = "均价"//当选中时，label要显示的名称
        serie["data"] = data//均线数据（当获取到实时数据后，就是对此字段赋值；然后实时刷新UI）
        serie["type"] = EverMacro.kFenShiLine//标记当前绘图类型
        serie["yAxisType"] = "0"//标记当前Y轴类型
        serie["section"] = "0"//标记当前所属部分
        serie["color"] = colorTheme//均线线段的颜色
        series.add(serie)
        secOne.add(serie)
        
        //实时价
        serie = NSMutableDictionary()
        data = NSMutableArray()
        serie["name"] = EverMacro.kFenShiNowNameLine
        serie["label"] = "数值"
        serie["data"] = data
        serie["type"] = EverMacro.kFenShiLine
        serie["yAxisType"] = "1"
        serie["section"] = "0"
        serie["color"] = color1200ff
        serie["decimal"] = decimal
        series.add(serie)
        secOne.add(serie)
        
        //VOL
        serie = NSMutableDictionary()
        data = NSMutableArray()
        serie["name"] = EverMacro.kFenShiVolNameColumn
        serie["label"] = "量"
        serie["data"] = data
        serie["type"] = EverMacro.kFenShiColumn
        serie["section"] = "1"
        serie["decimal"] = decimal//保留几位小数
        series.add(serie)
        secTwo.add(serie)
        
        fenshiChart.series = series
        (fenshiChart.sections!.object(at: 0) as! Section).series = secOne
        (fenshiChart.sections!.object(at: 1) as! Section).series = secTwo
    }
    
    func renderChart(dic:NSDictionary) {
        
        fenshiChart.reset()
        
        let allData = NSMutableArray()
        let data1 = NSMutableArray()
        let data2 = NSMutableArray()
        let data3 = NSMutableArray()
        let category = NSMutableArray()
        
        let listArray = dic["data"] as! [NSArray]
        let closeYesterday = dic["yestclose"] as! Double//昨日收盘价
        for i in 0 ..< listArray.count {
            //时间、价格、均价、成交量
            let item1:NSArray = [listArray[i][2],closeYesterday]   //均价
            let item2:NSArray = [listArray[i][1],closeYesterday]    //实时价格
            //NSArray只能保存32整形，有的数据过大32位不够
            let item3:NSArray = [listArray[i][3],listArray[i][1],closeYesterday]  //成交量
            if !category.contains(listArray[i][0]) {
                category.add(listArray[i][0])//当前时间
                data1.add(item1)
                data2.add(item2)
                data3.add(item3)
            }
        }
        //添加到对应的plist的数据中
        allData.add(data1)
        allData.add(data2)
        allData.add(data3)
        allData.add(category)
        //上面构造数据的方法，可以按照需求更改，数据源构建完毕后，赋值到分时图上
        self.fenshiChart.appendToData(data: allData[0] as! NSMutableArray, forName: EverMacro.kFenShiAvgNameLine)
        self.fenshiChart.appendToData(data: allData[1] as! NSMutableArray, forName: EverMacro.kFenShiNowNameLine)
        self.fenshiChart.appendToData(data: allData[2] as! NSMutableArray, forName: EverMacro.kFenShiVolNameColumn)
        
        //当被选中时，要显示的数据or文字
        self.fenshiChart.appendToCategory(category: allData[3] as! NSMutableArray, forName: EverMacro.kFenShiAvgNameLine)
        self.fenshiChart.appendToCategory(category: allData[3] as! NSMutableArray, forName: EverMacro.kFenShiNowNameLine)
        self.fenshiChart.appendToCategory(category: allData[3] as! NSMutableArray, forName: EverMacro.kFenShiVolNameColumn)
        
        DispatchQueue.main.async {
            //重绘图标
            self.fenshiChart.setNeedsDisplay()
        }
    }
}
