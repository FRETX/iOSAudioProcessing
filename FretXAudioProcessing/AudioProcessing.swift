//
//  Audio.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 25/05/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

public class AudioProcessing:NSObject{
    
    var audioHandler : AudioInputHandler?
    let sampleRate:Float = 16000
    let nChannels:Int = 1
    let pitchDetector:PitchDetector
    let chordDetector:ChordDetector
    var bufferSizeInSeconds:Double
    var initialized = false
    var targetChords:[Chord] = []
    
    public enum modeOptimization{
        case CHORD
        case TUNER
    }
    
    public init(bufferSize:Double){
        self.bufferSizeInSeconds = bufferSize
        audioHandler = AudioInputHandler.init(sampleRate: sampleRate, numberOfChannels: nChannels , bufferSizeInSeconds: bufferSizeInSeconds)
        let bufferSize = Int(pow(2,ceil(log2(Float(sampleRate)*Float(bufferSizeInSeconds)))))
        pitchDetector = PitchDetector(sampleRate: sampleRate, frameShift: bufferSize/4, frameLength: bufferSize/2, threshold: 0.1)
        let targetChords = [Chord(root: "C", type: "maj") , Chord(root: "G", type: "maj") , Chord(root: "D", type: "maj"),Chord(root: "x", type: "x"),Chord(root: "E", type: "maj")]
        chordDetector = ChordDetector(sampleRate: sampleRate, frameShift: bufferSize/4, frameLength: bufferSize/2, targetChords: targetChords)
        audioHandler?.audioAnalyzers.append(pitchDetector)
        audioHandler?.audioAnalyzers.append(chordDetector)
        pitchDetector.enable()
        chordDetector.enable()
        initialized = true
    }
    
    public convenience init(optimizeFor:modeOptimization){
        switch optimizeFor {
        case modeOptimization.TUNER:
            self.init(bufferSize:0.05)
        case modeOptimization.CHORD:
            self.init(bufferSize:0.1)
        }
    }
    
    public func isInitialized() -> Bool{
        return initialized
    }
    
    public func startRecording(){
        if let aud = self.audioHandler{
            aud.startRecording()
        }
    }
    
    public func stopRecording(){
        if let aud = self.audioHandler{
            aud.stopRecording()
        }
    }
    
    public func getChord()->Chord{
        return self.chordDetector.detectedChord
    }
    
    public func setTargetChords(chords:[Chord]){
        self.targetChords = chords;
        self.targetChords.append(Chord(root: "x", type: "x"))
        self.chordDetector.setTargetChords(chords: self.targetChords)
    }
    
    public func getTargetChords()->[Chord]{
        return targetChords
    }
    
    public func getPitch()->Float{
        return pitchDetector.medianPitch
    }
    
    public func getVolume()->Float?{
        return audioHandler?.getVolume()
    }
}
