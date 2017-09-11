//
//  PitchDetector.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 26/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class PitchDetector:AudioAnalyzer{
    
    private let threshold:Float
    private var tempBuffer:[Float] = []
    private var yinBuffer:[Float]
    private var result:PitchDetectionResult = PitchDetectionResult()
    private var lastValues = [Float](repeating: -1 , count:9)
    internal var medianPitch:Float = -1
    
    public init(sampleRate:Float, frameShift:Int, frameLength:Int , threshold:Float) {
        self.threshold = threshold
        yinBuffer = [Float](repeating:0.0,count:frameLength/2)
        super.init(sampleRate: sampleRate, frameShift: frameShift, frameLength: frameLength)
    }

    override func internalProcess() {
        tempBuffer = getNextFrame()
        while tempBuffer.count > 0 {
            result = getPitch(audioBuffer: tempBuffer)
            output = result.pitch
            tempBuffer = getNextFrame()
        }
    }
    
    override func processingFinished() {
        
    }
    
    internal func getPitch(audioBuffer:[Float])->PitchDetectionResult{
        var tauEstimate:Int
        var pitchInHertz:Float
        difference(buf: audioBuffer)
        cumulativeMeanNormalizedDifference()
        tauEstimate = absoluteThreshold()
        if(tauEstimate != -1){
            let betterTau = parabolicInterpolation(tauEstimate: tauEstimate)
            pitchInHertz = sampleRate / betterTau
            if pitchInHertz > sampleRate/4 {//This is mentioned in the YIN paper
                pitchInHertz = -1
            }
        } else {
            //no pitch found
            pitchInHertz = -1
        }
        result.pitch = pitchInHertz
        //Shift the last values by one to right
        for i in (1...lastValues.count-1).reversed() {
            lastValues[i] = lastValues[i-1]
        }
        lastValues[0] = pitchInHertz
        updateMedianPitch()
        return result
        
    }
    
    internal func difference(buf:[Float]){
        yinBuffer = [Float](repeating:0, count:yinBuffer.count)
        for tau in 1..<yinBuffer.count {
            for t in 0..<yinBuffer.count {
                yinBuffer[tau] += pow(buf[t] - buf[t+tau],2)
            }
        }
    }
    
    internal func cumulativeMeanNormalizedDifference(){
        yinBuffer[0] = 1
        var runningSum:Float = 0
        for tau in 1..<yinBuffer.count {
            runningSum += yinBuffer[tau]
            yinBuffer[tau] = yinBuffer[tau] / runningSum * Float(tau)
        }
    }
    
    internal func absoluteThreshold()->Int{
        var tau = 0
        var i = 0
        var tauFound = false
        
        while !tauFound && (i+1 < yinBuffer.count-2) {
            if(yinBuffer[i] < threshold){
                if(i+1 >= yinBuffer.count-2){
                    break
                }
                while(yinBuffer[i+1] < yinBuffer[i]){
                    i += 1
                    tau = i
                }
                tauFound = true
                result.probability = 1-yinBuffer[tau]
            } else {
                i += 1
            }
        }
        
        if(!tauFound){
            tau = -1
            result.probability = 0
            result.pitched = false
        } else {
            result.pitched = true
        }
        return tau
    }
    
    internal func parabolicInterpolation(tauEstimate:Int)->Float{
        let betterTau:Float
        if(tauEstimate > 0 && tauEstimate < yinBuffer.count-1){
            var y1:Float,y2:Float,y3:Float
            y1 = yinBuffer[tauEstimate-1]
            y2 = yinBuffer[tauEstimate]
            y3 = yinBuffer[tauEstimate+1]
            betterTau = Float(tauEstimate) + (y3-y1) / (2 * (2 * y2 - y3 - y1))
        } else {
            //TODO: implement proper boundary conditions
            betterTau = Float(tauEstimate)
        }
        return betterTau
    }
    
    internal func updateMedianPitch(){
        var pitchedValuesCount = 0
        for val in lastValues {
            if(val > 0){
                pitchedValuesCount += 1
            }
        }
        if(pitchedValuesCount > 3){
            var sortedPitchValues = [Float](repeating:0.0, count:pitchedValuesCount)
            var y = 0
            for i in 0..<lastValues.count {
                if(lastValues[i] > 0){
                    sortedPitchValues[y] = lastValues[i]
                    y += 1
                }
            }
            sortedPitchValues.sort()
            medianPitch = AudioAnalyzer.median(m: sortedPitchValues)
        } else {
            medianPitch = -1
        }
    }
}
