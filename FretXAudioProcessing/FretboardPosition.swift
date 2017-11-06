//
//  FretboardPosition.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 24/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class FretboardPosition:NSObject{
    let string:Int
    let fret:Int
    
    public init(string:Int,fret:Int){
        if(string >= 1 && string <= 6 ){
            self.string = string
        } else {self.string = -1}
        //-1 means "don't play this string", 0 means "open string"
        if(fret >= -1 && fret <= 18){
            self.fret = fret
        } else {self.fret = -1}
        if(fret > 4){
            print("FretboardPosition: Fret value \(fret) is outside FretX display range")
        }
    }
    
    public func getByteCode() -> UInt8 {
        let ledCode = string + 10*fret
        if(ledCode < 0){
            return UInt8(99)
            //This is for avoiding the representation problem with negative numbers in UInt8
            //It won't be displayed on FretX device even if it's sent
        } else {
            return UInt8(ledCode)
        }
    }
    
    public func toMidi() -> Int{
        var midiNote = 40 + (self.string - 1) * 5 + fret
        if(string >= 5) {
            midiNote -= 1
        }
        return midiNote
    }
    
    public func getString()->Int{
        return string
    }
    
    public func getFret()->Int{
        return fret
    }
    
}
