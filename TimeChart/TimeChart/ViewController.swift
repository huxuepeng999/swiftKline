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
        let urlStr = "http://img1.money.126.net/data/hs/time/today/1000001.json"
        guard let url = URL.init(string: urlStr) else {
            //
            return
        }
        let config = URLSessionConfiguration.default
        //创建请求实例
        let request = URLRequest(url: url)
        //        进行请求头的设置
        //        request.setValue(Any?, forKey: String)
        //        创建请求Session
        let session = URLSession(configuration: config)
        //        创建请求任务
        let task = session.dataTask(with: request) { (data:Data?,response:URLResponse?,error:Error?) in
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                //type:[NSArray],时间、价格、均价、成交量
                self.chartData.drawFenshi(dic: dictionary as! NSDictionary)
            }catch {
                
            }
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

