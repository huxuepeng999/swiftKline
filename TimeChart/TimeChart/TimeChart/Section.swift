//
//  Section.swift
//  分时图-h
//
//  Created by huxuepeng on 16/6/2.
//  Copyright © 2016年 huxuepeng. All rights reserved.
//

import UIKit

class Section: NSObject {
    
    var hidden:Bool!
    var isInitialized:Bool!
    var selectedIndex:Int!
    var frame:CGRect?
    var paddingLeft:CGFloat!
    var paddingRight:CGFloat!
    var paddingTop:CGFloat!
    var paddingBottom:CGFloat!
    
    var padding:NSMutableArray!
    var series:NSMutableArray!
    var yAxises:NSMutableArray!
    var xAxises:NSMutableArray!
    
    
    
    override init() {
        super.init()
        
        self.hidden          = false;
        self.isInitialized   = false;
        self.selectedIndex   = 0;
        self.paddingLeft     = 0;
        self.paddingRight    = 0;
        self.paddingTop      = 20;
        self.paddingBottom   = 0;
        self.padding = NSMutableArray(array: ["5","10","5","5"])//设置内边距,这里暂时没用到
        self.series = NSMutableArray()
        self.yAxises = NSMutableArray()
        self.xAxises = NSMutableArray()
    }
    
    @objc func addYAxis(pos:Int) {
        let yaix = YAxis()
        
        yaix.pos = pos
        self.yAxises.add(yaix)
    }
    
    @objc func removeYAxis(index:Int) {
        self.yAxises.removeObject(at: index)
    }
    
    @objc func removeYAxises() {
        self.yAxises.removeAllObjects()
    }
}
