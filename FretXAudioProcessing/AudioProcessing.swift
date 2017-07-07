//
//  Audio.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 25/05/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc final public class AudioProcessing:NSObject{
    static let shared = AudioProcessing()
    
    var audioHandler : AudioInputHandler?
    let sampleRate:Float = 16000
    let nChannels:Int = 1
    let pitchDetector:PitchDetector
    let chordDetector:ChordDetector
    var bufferSizeInSeconds = 0.05

   
    private override init(){
        audioHandler = AudioInputHandler.init(sampleRate: sampleRate, numberOfChannels: nChannels , bufferSizeInSeconds: bufferSizeInSeconds)
        let bufferSize = Int(pow(2,ceil(log2(Float(sampleRate)*Float(bufferSizeInSeconds)))))
        pitchDetector = PitchDetector(sampleRate: sampleRate, frameShift: bufferSize/4, frameLength: bufferSize/2, threshold: 0.1)
        let targetChords = [Chord(root: "C", type: "maj") , Chord(root: "G", type: "maj") , Chord(root: "D", type: "maj"),Chord(root: "x", type: "x"),Chord(root: "E", type: "maj")]
        chordDetector = ChordDetector(sampleRate: sampleRate, frameShift: bufferSize/4, frameLength: bufferSize/2, targetChords: targetChords)
        audioHandler?.audioAnalyzers.append(pitchDetector)
        audioHandler?.audioAnalyzers.append(chordDetector)
        
        pitchDetector.enable()
        chordDetector.enable()
        
    }

    
    func startRecording(){
        audioHandler?.startRecording()
    }
    
    func stopRecording(){
        audioHandler?.stopRecording()
    }
    
}
