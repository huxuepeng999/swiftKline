//
//  ExtString.swift
//  TimeChart
//
//  Created by huxp on 2019/11/6.
//  Copyright © 2019 huxp. All rights reserved.
//

import UIKit

extension String {
    //字符串转整数
    func stringToInt()->(Int){
        let string = self
        var int: Int = 0
        if let doubleValue = Int(string) {
            int = Int(doubleValue)
        }
        return int
    }
}
