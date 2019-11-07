//
//  EverMacro.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class EverMacro: NSObject {
    
    @objc static var KYFontName = "Helvetica"             //Y轴刻度文字字体
    @objc static var kYFontSizeFenShi:CGFloat = 10        //Y轴刻度文字大小
        
    @objc static var kMA5Color = color666666    // 5日均线    灰色
    @objc static var kMA10Color = UIColor.colorWithHexString(color: "0x8700d4", alpha: 1.0)   // 10日均线   紫色
    @objc static var kMA20Color = UIColor.colorWithHexString(color: "0xeaad18", alpha: 1.0)   // 20日均线   黄色
    @objc static var kMA30Color = UIColor.colorWithHexString(color: "0x103bdc", alpha: 1.0)   // 30日均线   蓝色
    
    @objc static var kFenShiLine = "fenShiLine"   //线段图类型标记
    @objc static var kFenShiColumn = "fenShiColumn"   //成交量图类型标记
    @objc static var kFenShiNowNameLine = "nowLine"   //分时图实时线名称标记
    @objc static var kFenShiAvgNameLine = "avgLine"   //分时图均线名称标记
    @objc static var kFenShiVolNameColumn = "column"   //分时图成交量名称标记
    
    @objc static var amTime = "09:30"
    @objc static var amTimeToMid = "11:30"
    @objc static var midTopmTime = "13:00"
    @objc static var pmTime = "15:00"
    @objc static var nightBegin = ""
    @objc static var nightEnd = ""
}
