//
//  AudioData.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 23/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class AudioData:NSObject {
    var sampleRate: Float = 16000
    var audioBuffer: [Float] = []
    var length: Int {
        get{
            return audioBuffer.count
        }
    }
    
    public init(sampleRate: Float, audioBuffer: [Float]) {
        self.sampleRate = sampleRate
        self.audioBuffer = audioBuffer
    }
    
    public func normalize(){
        var tmpBuffer = audioBuffer
        for (i,sample) in tmpBuffer.enumerated() {
            tmpBuffer[i] = abs(sample)
        }
        if let maxVal = tmpBuffer.max(){
            for (i,sample) in audioBuffer.enumerated(){
                audioBuffer[i] = sample/maxVal*0.99
            }
        }
    }
    
    public func getSignalPower() -> Float {
        var acc:Float = 0
        for sample in audioBuffer{
            acc += sample * sample
        }
        return acc / Float(audioBuffer.count)
    }
    
}
