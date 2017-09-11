//
//  Audio.swift
//  FretX
//
//  Created by Onur Babacan on 11/07/2017.
//  Copyright © 2017 Developer. All rights reserved.
//

import Foundation

@objc public protocol AudioListener{
    func onProgress()
    func onLowVolume()
    func onHighVolume()
    func onTimeout()
}


@objc public class Audio:NSObject{
    public static let shared = Audio()
    
    private static let TIMER_TICK:TimeInterval = 0.01
//    private static let ONSET_IGNORE_DURATION = 0
//    private static let CHORD_LISTEN_DURATION = 500
//    private static let TIMER_DURATION_MS = 500
    private static let CORRECTLY_PLAYED_DURATION:Float = 0.16
    private static let VOLUME_THRESHOLD:Float = -8.8
//    private static let TIMEOUT_MS = 10000
    
//    private var enabled = false
    private var audio:AudioProcessing?
    private var mode:AudioProcessing.modeOptimization = AudioProcessing.modeOptimization.CHORD
    
    private var targetChord:Chord = Chord(root: "x", type: "x")
    private var correctlyPlayedAccumulator:Float = 0
    private var upsideThreshold:Bool = false
    private var timeoutCounter:Int = 0
    private var timeoutNotified:Bool = false
    private var countDownTimer:Timer = Timer()
    
    private var listener:AudioListener?
    
    private override init(){
        print("optimizing for:")
        print(self.mode)
        self.audio = AudioProcessing.init(optimizeFor: self.mode)
//        self.enabled = true
    }

    
    public func start(){
        if(self.audio == nil){
            self.reInit()
            print("reinitialized audio")
        }
        if let aud = self.audio{
            aud.startRecording()
            self.startListening()
            print("started recording")
            //TODO: Timeout counter stuff here
        }
        
    }
    
    public func stop(){
        if let aud = self.audio{
            print("stop: audio unwrapped")
            self.stopListening()
            aud.stopRecording()
            print("stopped recording")
            self.releaseAudio()
            print("released audio resources")
        }
        
    }
    
    public func releaseAudio(){
        self.audio = nil
        
    }
    
    public func reInit(){
        self.setMode(optimizeFor: self.mode)
    }
    
    public func setMode(optimizeFor:AudioProcessing.modeOptimization){
        self.stop()
        self.mode = optimizeFor
        print("optimizing for:")
        print(self.mode)
        self.audio = AudioProcessing.init(optimizeFor:self.mode)
    }
    
    @objc public func optimizeForTuner(){
        self.setMode(optimizeFor: AudioProcessing.modeOptimization.TUNER)
    }
    
    @objc public func optimizeForChord(){
        self.setMode(optimizeFor: AudioProcessing.modeOptimization.CHORD)
    }
    
    public func getPitch()->Float{
        if let aud = self.audio{
            return aud.getPitch()
        } else {
            return -1
        }
        
    }
    
    public func getProgress()->Float{
        return correctlyPlayedAccumulator / Audio.CORRECTLY_PLAYED_DURATION * 100
    }
    
    public func setTargetChord(chord:Chord){
        self.targetChord = chord
        print("target chord set to" + self.targetChord.name)
    }
    
    public func setTargetChords(chords:[Chord]){
        if let aud = self.audio{
            var tmpChords = chords
            ////////////
            //temporary heuristic for making chord recognition more accurate
//            var majorChords:[Chord] = [];
//            majorChords.append(Chord.init(root: "A", type: "maj"))
//            majorChords.append(Chord.init(root: "B", type: "maj"))
//            majorChords.append(Chord.init(root: "C", type: "maj"))
//            majorChords.append(Chord.init(root: "D", type: "maj"))
//            majorChords.append(Chord.init(root: "E", type: "maj"))
//            majorChords.append(Chord.init(root: "F", type: "maj"))
//            majorChords.append(Chord.init(root: "G", type: "maj"))
//            for majorChord:Chord in majorChords {
//                var rootExists = false
//                for chord:Chord in chords {
//                    if (chord.root == majorChord.root ||
//                        (chord.root == "A" && majorChord.root == "F") ||
//                        (chord.root == "F" && majorChord.root == "A")
//                        ) {
//                        rootExists = true
//                        break
//                    }
//                }
//                if(!rootExists){
//                    tmpChords.append(majorChord)
//                }
//            }
            ////////////
            aud.setTargetChords(chords: tmpChords)
            print("target set of chords set to:")
            print(chords)
        }

    }
    
    public func setAudioListener(listener:AudioListener){
        self.listener = listener
        print("audio listener set to:")
        print(listener)
    }
    
    public func updateTimer(){
        if let aud = self.audio{
            if let vol = aud.getVolume(){
//                print(vol)
                //nothing heard
                if(vol < Audio.VOLUME_THRESHOLD){
                    self.correctlyPlayedAccumulator = 0
                    self.listener?.onProgress()
                    if(self.upsideThreshold){
                        self.upsideThreshold = false
                        self.listener?.onLowVolume()
                    }
                }
                    //chord heard
                else {
                    if(!self.upsideThreshold){
                        self.upsideThreshold = true
                        self.listener?.onHighVolume()
                    }
                    //update progress
                    let playedChord = aud.getChord()
                    if(playedChord.name == self.targetChord.name){
                        self.correctlyPlayedAccumulator += Float(Audio.TIMER_TICK)
                        print("correctly played -> \(self.correctlyPlayedAccumulator*1000)")
                    } else {
                        self.correctlyPlayedAccumulator = 0
                    }
                    self.listener?.onProgress()
                    //stop the countdown timer
                    if(self.correctlyPlayedAccumulator >= Audio.CORRECTLY_PLAYED_DURATION){
                        self.correctlyPlayedAccumulator = 0
                        self.listener?.onProgress()
                        
                    }
                }
            }
        }
    }
    

    public func startListening(){
        correctlyPlayedAccumulator = 0
        timeoutCounter = 0
        countDownTimer.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: Audio.TIMER_TICK, repeats: true, block: { (timer) -> Void in
            self.updateTimer()
        })
        
    }
    
    public func stopListening(){
        self.countDownTimer.invalidate()
    }
    
}
