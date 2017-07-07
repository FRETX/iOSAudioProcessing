//
//  AudioAnalyzer.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 23/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class AudioAnalyzer: NSObject {
    internal let sampleRate:Float
    internal let frameShift: Int
    internal let frameLength: Int
    internal var head: Int
    internal var atFrame: Int
    internal var maxFrames: Int
    internal var output: Float
    internal var audioData: AudioData
    internal var enabled: Bool
    internal var parameterAnalyzers:[ParameterAnalyzer]
    
    init (sampleRate:Float, frameShift:Int, frameLength:Int){
        self.sampleRate = sampleRate
        self.frameShift = frameShift
        self.frameLength = frameLength
        self.head = -1
        self.atFrame = -1
        self.maxFrames = -1
        self.output = -1
        self.parameterAnalyzers = []
        self.enabled = false
        self.audioData = AudioData(sampleRate: sampleRate, audioBuffer: [])
    }
    
    public func addParameterAnalyzer(pa:ParameterAnalyzer){
        self.parameterAnalyzers.append(pa)
    }
    
    public func removeParameterAnalyzerAt(index:Int){
        self.parameterAnalyzers.remove(at: index)
    }
    
    
    public func process(audioData:AudioData){
        if(enabled){
            self.audioData = audioData
            if(audioData.length < frameLength){
                maxFrames = Int(ceil((Double(audioData.length-frameLength) / Double(frameShift))))
            } else {
                maxFrames = 1
            }
            atFrame = 1
            head = 0
            
            internalProcess()
            processingFinished()
            sendOutput()
        }
    }
    
    internal func internalProcess(){
        //MARK: Override in subclass!
    }
    
    internal func processingFinished(){
        //MARK: Override in subclass!
    }
    
    internal func sendOutput(){
        for pa in parameterAnalyzers {
            pa.process(input: output)
        }
    }
    
    public func enable(){
        enabled = true
    }
    
    public func disable(){
        enabled = false
    }
    
    public func isEnabled()->Bool{
        return enabled
    }
    
    internal func getNextFrame()->[Float]{
        var outputBuffer:[Float]
        if(atFrame <= maxFrames){
            atFrame += 1
            if(head + frameLength > audioData.length){
                //zero pad the end
                outputBuffer = Array(audioData.audioBuffer[head..<audioData.length])
                outputBuffer += [Float](repeating:0.0,count:frameLength-outputBuffer.count)
                head = audioData.length - 1
                return outputBuffer
            } else {
                //get regular frame
                outputBuffer = Array(audioData.audioBuffer[head..<head+frameLength])
                head += frameShift - 1
                return outputBuffer
            }
        } else {
            return []
        }
    }
    
//    public static func getHammingWindow(windowLength:Int)->[Float]{
//        let alpha:Float = 0.54
//        let beta:Float = 1 - alpha
//        var window = [Float](repeating:0.0,count:windowLength)
//        for i in 0..<window.count {
//            window[i] = alpha - beta * cos( (2 * Float.pi * Float(i) ) / Float(windowLength-1) )
//        }
//        return window
//    }
    
    public static func median(m:[Float])->Float{
        let middle:Int = m.count/2
        if(m.count % 2 == 1){
            return m[middle]
        } else {
            return (m[middle]+m[middle])/2
        }
    }
    
    public static func findMaxValue(array:[Float],beginIndex:Int,endIndex:Int)->Float{
        var maxVal = -1 * Float.greatestFiniteMagnitude
        for ele in array {
            if(ele > maxVal){
                maxVal = ele
            }
        }
        return maxVal
    }
    
    public static func findMaxIndex(array:[Float])->Int{
        var maxVal = -1 * Float.greatestFiniteMagnitude
        var maxIndex = -1
        for (i,ele) in array.enumerated() {
            if(ele > maxVal){
                maxVal = ele
                maxIndex = i
            }
        }
        return maxIndex
    }
    
}
