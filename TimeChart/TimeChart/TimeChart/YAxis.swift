//
//  YAxis.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class YAxis: NSObject {

    var isUsed:Bool!
    var frame:CGRect?
    var max:CGFloat!
    var min:CGFloat!
    var ext:CGFloat!
    var baseValue:CGFloat!
    var baseValueSticky:Bool!
    var paddingTop:CGFloat!
    var tickInterval:Int!
    var pos:Int!
    var decimal:Int!
    
    override init() {
        super.init()
        self.reset()
    }
    
    @objc func reset() {
        self.isUsed = false;
        self.min = CGFloat(MAXFLOAT);
        self.max = CGFloat(MAXFLOAT);
        self.ext = 0;
        self.baseValue = 0;
        self.baseValueSticky = false;
        self.paddingTop=15;
        self.tickInterval = 4;
        self.pos = 0;
        self.decimal = 0;
    }
}
