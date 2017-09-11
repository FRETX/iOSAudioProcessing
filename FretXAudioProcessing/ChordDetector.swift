//
//  ChordDetector.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 27/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class ChordDetector:AudioAnalyzer{
    private var tempBuffer:[Float] = []
    private var targetChords:[Chord]
    internal var detectedChord:Chord = Chord(root: "x",type: "x")
    private var chordSimilarity:Float = -1
    
//    private var magnitudeSpectrum:[Float] = []
    private let NOISE_CLASS_BITMASK_MAGNITUDE = 1
    
    public init(sampleRate:Float, frameShift:Int, frameLength:Int , targetChords:[Chord]){
        self.targetChords = targetChords
        super.init(sampleRate: sampleRate, frameShift: frameShift, frameLength: frameLength)
    }
    
    override func internalProcess() {
        tempBuffer = getNextFrame()
        while tempBuffer.count > 0 {
            let chromagram = getChromagram(audioBuffer: tempBuffer)
            detectedChord = detectChord(targetChords: self.targetChords, chromagram: chromagram)
//            print(detectedChord.name)
            output = Float(Int(targetChords.index(of: detectedChord)!))
            tempBuffer = getNextFrame()
        }
    }
    
    public func setTargetChords(chords:[Chord]){
        if(chords.count > 0){
            targetChords = chords
        }
    }
    
    private func getChromagram(audioBuffer:[Float])->[Float]{
        var tmpAudio:[Float] = audioBuffer
        //ensure that buffer size is even
        if(audioBuffer.count % 2 == 1){
            tmpAudio.append(audioBuffer[audioBuffer.count])
        }
        let fft = TempiFFT(withSize: tmpAudio.count, sampleRate: sampleRate)
        fft.windowType = TempiFFTWindowType.hamming
        fft.fftForward(tmpAudio)
        let A1:Float = 55
//        let E1 = 82.4
//        let C3 = 130.81
        
        var chromagram = [Float](repeating:0,count:12)
        
        for interval in 0..<12 {
            for phi in 1...5 {
                for harmonic in 1...2 {
                    chromagram[interval] += fft.magnitudeAtFrequency(MusicUtils.frequencyFromInterval(baseNote: A1, intervalInSemitones: interval)*Float(phi)*Float(harmonic))
                }
            }
        }
        
        for i in 0..<chromagram.count {
            chromagram[i] /= chromagram.max()!
        }
        return chromagram
    }
    
    private func detectChord(targetChords:[Chord] , chromagram:[Float])-> Chord {
        //Take the square of chromagram so the peak differences are more pronounced. see paper.
        var tmpChromagram = chromagram
        for i in 0..<chromagram.count {
            tmpChromagram[i] *= tmpChromagram[i]
        }
        var deltas = [Float](repeating:0, count:targetChords.count)
        for i in 0..<targetChords.count {
            deltas[i] = calculateDistanceToChord(chromagram: tmpChromagram, chord: targetChords[i])
        }
        let chordIndex = AudioAnalyzer.findMaxIndex(array: deltas)
        if(chordIndex >= 0 && chordIndex < deltas.count){
            chordSimilarity = deltas[chordIndex]
        } else {
            chordSimilarity = 0
        }
        
        if(chordIndex > -1 && chordIndex < targetChords.count){
            return targetChords[chordIndex]
        } else {
            return Chord(root: "x", type: "x")
        }
    }
    
    public func getChordSimilarity()->Float{
        return chordSimilarity
    }
    
    private func calculateDistanceToChord(chromagram:[Float],chord:Chord)->Float{
        var bitMask = [Float](repeating:0, count:12)
        var notes = chord.getNotes()
        if(chord.name != "noise"){
            for j in 0..<notes.count {
                bitMask[notes[j] - 1] = 1
            }
        }
        var distance:Float = 0
        for j in 0..<chromagram.count {
            distance += chromagram[j] * bitMask[j]
        }
        distance /= Float(notes.count)
        return distance
    }
    
    
    
}
