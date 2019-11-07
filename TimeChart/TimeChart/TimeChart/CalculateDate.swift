//
//  CalculateDate.swift
//  SimsTrade
//
//  Created by huxuepeng on 16/6/27.
//  Copyright © 2016年 mecrt. All rights reserved.
//

import UIKit

class CalculateDate:NSObject {

    var oldStr:String!
    var newStr:String!
    let D_DAY = 86400
    
    @objc init(oldDate:String) {
        super.init()
        
        self.oldStr = oldDate
        self.newStr = DateForStyle.sharedFormatter.timeDate.string(from: Date())
        
        let firstTime:Date? = DateForStyle.sharedFormatter.timeDate.date(from: self.oldStr)
        let secondTime:Date? = DateForStyle.sharedFormatter.timeDate.date(from: self.newStr)
        
        guard firstTime != nil && secondTime != nil else {
            return
        }
        UserDefault.setUserDefaults(object: firstTime!, value: "oldDate")
        UserDefault.setUserDefaults(object: secondTime!, value: "newDate")
        
        calculateDate(firstTime: firstTime!, secondTime:secondTime!)
    }
    
    //计算时间
    @objc func calculateDate(firstTime:Date, secondTime:Date) {
        //如果第二次登录和第一次登录的时间差
        let interval:TimeInterval = firstTime.timeIntervalSince(secondTime)
        print("interval====\(interval)")
    }
    
    @objc class func lastDateDay(strDate:String,n:Double) -> Date {
        let curDate = DateForStyle.sharedFormatter.timeDate.date(from: strDate)
//        guard curDate != nil else {
//            return
//        }
        let lastTimeDate = Date(timeInterval: -24*60*60*n, since: curDate!)
        return lastTimeDate
    }
}
