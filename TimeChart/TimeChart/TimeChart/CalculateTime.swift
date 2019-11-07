//
//  CalculateTime.swift
//  SimsTrade
//
//  Created by huxuepeng on 16/6/23.
//  Copyright © 2016年 mecrt. All rights reserved.
//

import Foundation


class CalculateTime {
    
    var secuCode:String = ""
    
    init(secuCode:String) {
        self.secuCode = secuCode
    }
    
    //是否在晚盘开盘时间之后，晚盘收盘时间之前
    func nightBeginDescendingToNightEndAscending(nowTime:Date) -> Bool {
        
        var nowTimeDeBl:Bool = false
        let curStrTime = DateForStyle.sharedFormatter.timeHour.string(from: nowTime)
        let localeDate = DateForStyle.sharedFormatter.timeHour.date(from: curStrTime)
        
        let amTimeDate = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.amTime)  //上午开始时间
        
        //是否在开盘时间之后
        if localeDate!.compare(amTimeDate!) == ComparisonResult.orderedDescending || localeDate!.compare(amTimeDate!) == ComparisonResult.orderedSame {
            nowTimeDeBl = true
        }else {
            nowTimeDeBl = false
        }
        return nowTimeDeBl
    }
    
    //是否在上午开盘时间之后
    func amTimeDescending(nowTime:Date) -> Bool {
        
        var nowTimeDeBl:Bool = false
        let curStrTime = DateForStyle.sharedFormatter.timeHour.string(from: Date())
        let localeDate = DateForStyle.sharedFormatter.timeHour.date(from: curStrTime)
        
        let amTimeDate = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.amTime)  //上午开始时间

        //是否在开盘时间之后
        if localeDate!.compare(amTimeDate!) == ComparisonResult.orderedDescending || localeDate!.compare(amTimeDate!) == ComparisonResult.orderedSame {
            nowTimeDeBl = true
        }else {
            nowTimeDeBl = false
        }
        return nowTimeDeBl
    }
    
    func isEqualAmTime(curTime:Date,date1:Date) -> Bool {
        
        if curTime.compare(date1) == ComparisonResult.orderedSame {
            return true
        }
        
        return false
    }

    
    //是否是交易时间
    class func isBetweenTime(curStrTime:String) -> Bool {
        
        let date1 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.amTime)  //上午开始时间
        let date2 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.amTimeToMid) //中午结束时间
        let date3 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.midTopmTime) //中午开始时间
        let date4 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.pmTime)  //下午结束时间
        
        let date5 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.nightBegin)  //晚上开始时间
        let date6 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.nightEnd)    //晚上结束时间
        
        let curTime = DateForStyle.sharedFormatter.timeHour.date(from: curStrTime)
        
        //上午时间
        if curTime!.compare(date1!) == ComparisonResult.orderedDescending && curTime!.compare(date2!) == ComparisonResult.orderedAscending {
            return true
        }
        if curTime!.compare(date1!) == ComparisonResult.orderedSame || curTime!.compare(date2!) == ComparisonResult.orderedSame {
            return true
        }
        
        
        //下午时间
        if curTime!.compare(date3!) == ComparisonResult.orderedDescending && curTime!.compare(date4!) == ComparisonResult.orderedAscending {
            return true
        }
        if curTime!.compare(date3!) == ComparisonResult.orderedSame || curTime!.compare(date4!) == ComparisonResult.orderedSame {
            return true
        }
        
        if date5 != nil && date6 != nil {
            //晚上时间
            if curTime!.compare(date5!) == ComparisonResult.orderedDescending && curTime!.compare(date6!) == ComparisonResult.orderedAscending {
                return true
            }
            if curTime!.compare(date5!) == ComparisonResult.orderedSame || curTime!.compare(date6!) == ComparisonResult.orderedSame {
                return true
            }
        }

        return false
    }
    
    //交易时间是否结束
//    func isOverTime(curTime:NSDate,date1:NSDate,date4:NSDate,date5:NSDate?) -> Bool {
//        
//        if curTime.compare(date4) == ComparisonResult.orderedDescending {//下午时间结束之后
//            return true
//        }
//        
//        return false
//    }
    
    //是否某两个字符串时间段之间
    class func isBetweenTwoStrTime(curTimeStr:String,dateStr1:String,dateStr2:String) -> Bool {
        
        let curTime = DateForStyle.sharedFormatter.timeHour.date(from: curTimeStr)  //上午开始时间
        let date1 = DateForStyle.sharedFormatter.timeHour.date(from: dateStr1) //中午结束时间
        let date2 = DateForStyle.sharedFormatter.timeHour.date(from: dateStr2)
        
        if curTime != nil && date1 != nil && date2 != nil {
            if curTime!.compare(date1!) == ComparisonResult.orderedDescending && curTime!.compare(date2!) == ComparisonResult.orderedAscending {
                return true
            }
            
            if curTime!.compare(date1!) == ComparisonResult.orderedSame || curTime!.compare(date2!) == ComparisonResult.orderedSame {
                return true
            }
        }
        return false
    }
        
    //是否是晚盘时间的21:30~02:30
    class func isBetweenNightTime(curTimeStr:String) -> Bool {        
        
        let curTime = DateForStyle.sharedFormatter.timeHour.date(from: curTimeStr)  //上午开始时间
        let date1 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.nightBegin) //中午结束时间
        let date2 = DateForStyle.sharedFormatter.timeHour.date(from: "23:59")
        let date3 = DateForStyle.sharedFormatter.timeHour.date(from: "00:00")
        let date4 = DateForStyle.sharedFormatter.timeHour.date(from: EverMacro.nightEnd)
        
        //日盘
        if curTime == nil || date1 == nil || date4 == nil {
            return false
        }
        
        //上午时间
        if (curTime!.compare(date1!) == ComparisonResult.orderedDescending && curTime!.compare(date2!) == ComparisonResult.orderedAscending) || curTime!.compare(date1!) == ComparisonResult.orderedSame || curTime!.compare(date2!) == ComparisonResult.orderedSame {
            return true
        }
        
        //下午时间
        if (curTime!.compare(date3!) == ComparisonResult.orderedDescending && curTime!.compare(date4!) == ComparisonResult.orderedAscending) || curTime!.compare(date3!) == ComparisonResult.orderedSame || curTime!.compare(date4!) == ComparisonResult.orderedSame {
            return true
        }
        
        return false
    }
    //计算时间差
    class func timeDifference(dateStr1:String, dateStr2:String) -> Double {
        
        let date1 = DateForStyle.sharedFormatter.timeHour.date(from: dateStr1)  //上午开始时间
        let date2 = DateForStyle.sharedFormatter.timeHour.date(from: dateStr2) //中午结束时间
        if date1 != nil && date2 != nil {
            let minute = date2!.timeIntervalSince(date1!) / 60//=date2-date1
            return minute
        }
        return 0
    }
    
    class func nextDateTime(strDate:String) -> Date {
        let curDate = DateForStyle.sharedFormatter.timeHour.date(from: strDate)
        let nextDateTime = Date(timeInterval: 60, since: curDate!)
        return nextDateTime
    }
}
