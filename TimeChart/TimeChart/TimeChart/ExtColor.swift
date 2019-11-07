//
//  ExtColor.swift
//  NXCJSwift
//
//  Created by huxuepeng on 2019/1/18.
//  Copyright © 2019年 com.huixiang zhitong.cn. All rights reserved.
//

import Foundation
import UIKit

struct colorModel {
    var R = UInt32()
    var G = UInt32()
    var B = UInt32()
    var alpha = CGFloat()
    
    init(r: UInt32, g:UInt32, b:UInt32, alpha:CGFloat) {
        self.R = r
        self.G = g
        self.B = b
        self.alpha = alpha
    }
}

extension UIColor {
    class func colorWithHexString(color: String, alpha: CGFloat) -> UIColor {
        let rgb = self.RGBWithHexString(hexString: color, alpha: alpha)
        let r = rgb?.R ?? 255
        let g = rgb?.G ?? 255
        let b = rgb?.B ?? 255
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    class func RGBWithHexString(hexString:String, alpha:CGFloat) -> colorModel? {
        var cString:String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if cString.count < 6 {
            return nil
        }
        if cString.hasPrefix("0X") || cString.hasPrefix("0x") {
            let index = cString.index(cString.startIndex, offsetBy: 2)
            cString = String(cString.suffix(from: index))
        }
        
        if cString.hasPrefix("#") {
            let index = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString.suffix(from: index))
        }
        if cString.count != 6 {
            return nil
        }
        
        var range:NSRange = NSMakeRange(0, 2)
        //r
        let rString = (cString as NSString).substring(with: range)
        
        //g
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        
        //b
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r:UInt32 = 0x0
        var g:UInt32 = 0x0
        var b:UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        var rgb = colorModel(r: r, g: g, b: b, alpha: alpha)
        rgb.R = r
        rgb.G = g
        rgb.B = b
        rgb.alpha = alpha
        
        return rgb
    }
}
