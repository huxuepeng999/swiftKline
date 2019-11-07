//
//  DateFormatter.swift
//  PBSwift
//
//  Created by huxuepeng on 17/3/24.
//  Copyright © 2017年 mecrt. All rights reserved.
//

import UIKit

class DateForStyle: NSObject {
    // 第二步 做成单例
    @objc static let sharedFormatter = DateForStyle()
    
    // 第三步 时间格式属性：NSDateFormatter 类型
    
    let rfc3339 = DateFormatter() // 最全时间格式 ("yyyy-MM-dd'T'HH:mm:ssZZZZZ")
    
    let time = DateFormatter() // 年-月-日 周 时：分：秒("yyyy-MM-dd (EEE) HH:mm")
    
    let timeZH = DateFormatter() // 中式： 月 日 时 分 上下午("MMMd日 HH:mm a")
    let timeEN = DateFormatter() // 英式：周 月 日，时 分 上下午("EEE, MMM dd, HH:mm a")
    
    let timeDate = DateFormatter()   // 年-月-日("yyyy-MM-dd")
    let timeHour = DateFormatter()   // HH:mm("HH:mm")
    let timeMinute = DateFormatter() // HH:mm:ss("HH:mm:ss")
    let dateMonthDay = DateFormatter()
    
    // 2017-08-03 胡志超扩展，记录保存密码时间
    let saveTime = DateFormatter()
    
    // huzc 拓展
    let timeDate2 = DateFormatter() // "yyyy-MM-dd HH:mm:ss"
    
    // 第四步 初始化
    override init() {
        rfc3339.locale     = Locale(identifier: "en_US_POSIX")  // 时间本地化
        rfc3339.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"               // 格式
        rfc3339.timeZone   = TimeZone(secondsFromGMT: 0)           // 时区
        
        // 不设置时间本地化，默认是手机系统的时间显示
        time.dateFormat = "yyyy-MM-dd (EEE) HH:mm"
        
        timeZH.locale     = Locale(identifier: "zh_CN")
        timeZH.dateFormat = "MMMd日 HH:mm a"
        
        timeEN.locale     = Locale(identifier: "en_US")
        timeEN.dateFormat = "EEE, MMM dd, HH:mm a"
        
        timeDate.dateFormat   = "yyyy-MM-dd"
        timeDate.locale = Locale(identifier: "zh_CN")//NSTimeZone(abbreviation: "UTC")
        timeDate.timeZone   = TimeZone(secondsFromGMT: 0)
        
        timeHour.dateFormat   = "HH:mm"
        timeHour.locale = Locale(identifier: "zh_CN")//NSTimeZone(abbreviation: "UTC")
        timeHour.timeZone   = TimeZone(secondsFromGMT: 0)
        
        timeMinute.dateFormat = "HH:mm:ss"
        
        self.timeDate2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.timeDate2.locale = Locale(identifier: "zh_CN")
        self.timeDate2.timeZone   = TimeZone(secondsFromGMT: 0)
        
        self.dateMonthDay.dateFormat = "yyyyMMdd"
        self.dateMonthDay.locale = Locale(identifier: "zh_CN")
        self.dateMonthDay.timeZone   = TimeZone(secondsFromGMT: 0)
        
        // 部分说明："en_US_POSIX" 与 "en_US" 的选择
        // "en_US_POSIX" 适用的范围比 "en_US"广，如果与后台交互让"字符串"与"时间"转换建议选择"en_US_POSIX"
        // Apple 官网解释：“en_US_POSIX” is also invariant in time (if the US, at some point in the future, changes the way it formats dates, “en_US” will change to reflect the new behaviour, but “en_US_POSIX” will not), and between machines (“en_US_POSIX” works the same on iPhone OS as it does on Mac OS X, and as it it does on other platforms).
        
        
        // 2017-08-03 胡志超扩展，记录保存密码时间
        saveTime.dateFormat = "yyyy-MM-dd HH:mm:ss"
        saveTime.locale = Locale(identifier: "zh_CN")
        saveTime.timeZone = TimeZone(secondsFromGMT: 0)
    }
}
