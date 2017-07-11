//
//  Chord.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 24/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class Chord: NSObject {
    public static let ALL_ROOT_NOTES = ["A", "Bb", "B", "C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#"]
    public static let ALL_CHORD_TYPES = ["maj", "m", "maj7", "m7", "5", "7", "9", "sus2", "sus4", "7sus4", "7#9", "add9", "aug", "dim", "dim7"]
    public let NOISE_CLASS_ROOT_AND_TYPE = ["X","X"]
    
    let root:String
    let type:String
    let baseFret:Int
    let fingerPositions:[FretboardPosition]
    public var name:String {get {
            return self.root + self.type
        }
    }
    
    public init(root:String,type:String){
        self.root = root
        var tmpType = type.lowercased()
        if(tmpType == "min"){
            tmpType = "m"
        }
        self.type = tmpType
        var tmpFingerPositions:[FretboardPosition] = []
        var tmpBaseFret = -1
        if(tmpType == "x" || root.lowercased() == "x"){
            for str in 1...6{
                tmpFingerPositions.append(FretboardPosition(string: str,fret: -1))
            }
        } else {
            if let chord = MusicUtils.getFingering(chordName: root + tmpType){
                tmpBaseFret = chord.baseFret
                tmpFingerPositions.append(FretboardPosition(string: 1,fret: chord.string1))
                tmpFingerPositions.append(FretboardPosition(string: 2,fret: chord.string2))
                tmpFingerPositions.append(FretboardPosition(string: 3,fret: chord.string3))
                tmpFingerPositions.append(FretboardPosition(string: 4,fret: chord.string4))
                tmpFingerPositions.append(FretboardPosition(string: 5,fret: chord.string5))
                tmpFingerPositions.append(FretboardPosition(string: 6,fret: chord.string6))
            }
        }
        self.baseFret = tmpBaseFret
        self.fingerPositions = tmpFingerPositions
        
    }
    
    public func getFingering() -> [FretboardPosition]{
        return self.fingerPositions
    }
    
    public func getRoot()->String{
        return root
    }
    
    public func getType()->String{
        return type
    }
    
    public func getBaseFret()->Int{
        return baseFret
    }
    
    private func getChordFormula()->[Int]{
        let semitoneLookup = [1,3,5,6,8,10,12,13,15,17,18,20,22,24,25]
        var template:[Int]
        var modification:[Int]
        switch self.type {
        case "maj" :
            template = [1,3,5]
            modification = [0,0,0]
        case "m" :
            template = [1,3,5]
            modification = [0,-1,0]
        case "maj7" :
            template = [1,3,5,7]
            modification = [0,0,0,0]
        case "m7" :
            template = [1,3,5,7]
            modification = [0,-1,0,-1]
        case "5" :
            template = [1,5]
            modification = [0,0]
        case "7" :
            template = [1,3,5,7]
            modification = [0,0,0,-1]
        case "9" :
            template = [1,3,5,7,9]
            modification = [0,0,0,-1,0]
        case "sus2" :
            template = [1,2,5]
            modification = [0,0,0]
        case "sus4" :
            template = [1,4,5]
            modification = [0,0,0]
        case "7sus4" :
            template = [1,4,5,7]
            modification = [0,0,0,-1]
        case "7#9" :
            template = [1,3,5,7,9]
            modification = [0,0,0,-1,1]
        case "add9" :
            template = [1,3,5,9]
            modification = [0,0,0,0]
        case "aug" :
            template = [1,3,5]
            modification = [0,0,1]
        case "dim" :
            template = [1,3,5]
            modification = [0,-1,-1]
        case "dim7" :
            template = [1,3,5,7]
            modification = [0,-1,-1,-2]
        case "x" :
            template = [1,2,3,4,5,6,7,8,9,10,11,12]
            modification = [0,0,0,0,0,0,0,0,0,0,0,0]
        default:
            //This shouldn't happen
            template = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
            modification = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            print("switch default \(type + root)");
        }
        var formula = [Int](repeating:0 , count:template.count)
        for i in 0..<formula.count {
            formula[i] = semitoneLookup[template[i]-1] + modification[i]
        }
        return formula
    }
 
    public func getNotes()->[Int]{
        if(type == "x"){
            return [1,2,3,4,5,6,7,8,9,10,11,12]
        } else {
            let rootNumber = MusicUtils.noteNameToSemitoneNumber(noteName: self.root)
            let formula = self.getChordFormula()
            var notes = [Int](repeating:0,count:formula.count)
            for i in 0..<notes.count {
                notes[i] = (formula[i] + rootNumber - 1) % 12
                if(notes[i]==0) {notes[i] = 12}
            }
            return notes
        }
    }

    public func getNoteNames()->[String]{
        if self.type == "x" {
            return []
        } else {
            let notes = self.getNotes()
            var noteNames = [String](repeating: "", count: notes.count)
            for i in 0..<noteNames.count {
                noteNames[i] = MusicUtils.semitoneNumberToNoteName(number: notes[i])
            }
            return noteNames
        }
    }
    
    public func getMidiNotes()->[Int]{
        var playedNotes = 0;
        for fp in self.fingerPositions {
            if(fp.fret > -1){playedNotes += 1}
        }
        var midiNotes = [Int](repeating:0,count:playedNotes)
        var midiNotesIndex = 0;
        for fp in self.fingerPositions {
            if(fp.fret > -1){
                midiNotes[midiNotesIndex] = fp.toMidi()
                midiNotesIndex += 1
            }
        }
        return midiNotes
    }
    
    public static func ==(lhs:Chord,rhs:Chord)->Bool{
        return lhs.name == rhs.name
    }
}


// chord data - currently explicit representation for 6 string guitar, standard tuning only, and
// each chord is an array of alternate positions
// 0" : 1st (open) position
// 1" : 1st barre position, generally at 12/13/14th fret
// - minimum, only required for CAGED chords where open strings are used in the 1st (open) position
// since the main purpose of this is to provide barre fingering positions for CAGED-based chords
// 2.." : alternative positions/fingerings
// each position is an array comprising: 1. base fret (0==nut); 2. 6x note definitions (strings 6,5,4,3,2,1)
// each note is an array: (fret position), (left hand fingering if applicable 1,2,3,4,T)
// fret position: -1 = muted/not played; 0 = open; 1,2,3... = fret position
