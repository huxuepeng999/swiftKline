//
//  UserDefault.swift
//  SimsTrade
//
//  Created by huxuepeng on 16/6/30.
//  Copyright © 2016年 mecrt. All rights reserved.
//

import UIKit

class UserDefault: NSObject {
    
    @objc static let userDefault:UserDefaults = UserDefaults.standard
    
    @objc class func setUserDefaults(object:Any, value:String) {
        userDefault.set(object, forKey: value)
        userDefault.synchronize()
    }
    
    @objc class func getUserDefaults(name:String) -> NSArray? {
        return userDefault.array(forKey: name) as NSArray?
    }
    
    @objc class func getUserDefaultsStr(name:String) -> String? {
        return userDefault.string(forKey: name)
    }
    
    @objc class func getUserDefaultsBool(name:String) -> Bool {
        return userDefault.bool(forKey: name)
    }
    
    @objc class func getUserDefaultsInt(name:String) -> Int {
        return userDefault.integer(forKey: name)
    }
}
