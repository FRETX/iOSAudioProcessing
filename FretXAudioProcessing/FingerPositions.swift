//
//  FingerPositions.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 24/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class FingerPositions:NSObject {
    public var name:String = "x"
    public var baseFret:Int = -1
    public var string6:Int = -1
    public var string5:Int = -1
    public var string4:Int = -1
    public var string3:Int = -1
    public var string2:Int = -1
    public var string1:Int = -1
    
    public init(name:String, baseFret:Int,string6:Int,string5:Int,string4:Int,string3:Int,string2:Int,string1:Int){
        self.name = name
        self.baseFret = baseFret
        self.string6 = string6
        self.string5 = string5
        self.string4 = string4
        self.string3 = string3
        self.string2 = string2
        self.string1 = string1
    }
}
