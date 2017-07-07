//
//  PitchDetectionResult.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 24/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class PitchDetectionResult:NSObject{
    var probability:Float = -1
    var pitch:Float = -1
    var pitched:Bool = false
}
