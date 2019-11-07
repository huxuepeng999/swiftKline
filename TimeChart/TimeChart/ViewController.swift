//
//  ViewController.swift
//  TimeChart
//
//  Created by huxp on 2019/11/1.
//  Copyright © 2019 huxp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var chartData:ChartData!
    var timeChart:EverChart!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //分时图获取数据依次是count节点数量、symbol股票代码、name股票名称、data数据，其中数据依次是小时分钟时间、价格、均价、成交量
        //http://img1.money.126.net/data/hs/time/today/1000001.json
        self.timeChart = EverChart(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 300))
        self.view.addSubview(self.timeChart)
        
        self.chartData = ChartData(fenshiChart: self.timeChart)
        
        self.requestUrl()
        
    }
    func requestUrl() {
        let data = self.testData()
        self.chartData.drawFenshi(dic: data as NSDictionary)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func testData() -> [String:Any] {
        let data:[String:Any] = ["count":242,"symbol":"000001","name":"test","data":[["0930",16.93,16.93,366700],["0931",17.0,16.965,1016840],["0932",17.03,16.987,653000],["0933",17.0,16.99,334875],["0934",17.01,16.994,265885],["0935",16.95,16.987,464240],["0936",16.98,16.986,171200],["0937",17.01,16.989,201463],["0938",16.99,16.989,147322],["0939",16.99,16.989,231015],["0940",17.01,16.991,297700],["0941",16.97,16.989,292600],["0942",16.98,16.988,167800],["0943",16.99,16.989,212700],["0944",16.94,16.985,374260],["0945",16.9,16.98,570700],["0946",16.9,16.975,677254],["0947",16.92,16.972,165400],["0948",16.9,16.968,391700],["0949",16.9,16.965,276400],["0950",16.89,16.961,319600],["0951",16.88,16.958,524886],["0952",16.85,16.953,634600],["0953",16.86,16.949,1111400],["0954",16.85,16.945,469719],["0955",16.84,16.941,345881],["0956",16.85,16.938,380919],["0957",16.89,16.936,313200],["0958",16.88,16.934,271900],["0959",16.85,16.931,394400],["1000",16.84,16.928,210500],["1001",16.86,16.926,225200],["1002",16.86,16.924,188200],["1003",16.89,16.923,205080],["1004",16.91,16.923,200385],["1005",16.91,16.923,228800],["1006",16.93,16.923,236500],["1007",16.92,16.923,182100],["1008",16.92,16.923,422100],["1009",16.91,16.922,258100],["1010",16.94,16.923,310200],["1011",16.91,16.922,270100],["1012",16.9,16.922,290700]],"yestclose":16.96,"lastVolume":0,"date":"20191107"]
        
        return data
    }
}

