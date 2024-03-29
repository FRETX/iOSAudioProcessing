//
//  Scale.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 26/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class Scale:NSObject{
    public static let ALL_ROOT_NOTES = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
    public static let ALL_SCALE_TYPES = ["Major","Minor","Major Pentatonic","Minor Pentatonic","Blues","Melodic Minor","Ionian","Dorian","Phrygian","Lydian","Mixolydian","Aeolian","Locrian","Whole Tone"]
    let root:String
    let type:String
    private let rootNoteMidi:Int
    private let lowerBoundMidiNote = 40
    private let upperBoundMidiNote = 68
    private let notes:[Int]
    private let fretboardPositions:[FretboardPosition]
    private let scaleFormula:[Int]
    
    public init(root:String,type:String){
        self.root = root
        self.type = type
        
        switch type {
        case "Major":
            scaleFormula = [2,2,1,2,2,2,1]
        case "Minor":
            scaleFormula = [2,1,2,2,1,2,2]
        case "Major Pentatonic":
            scaleFormula = [2,2,3,2,3]
        case "Minor Pentatonic":
            scaleFormula = [3,2,2,3,2]
        case "Blues":
            scaleFormula = [3,2,1,1,3,2]
        case "Harmonic Minor":
            scaleFormula = [2,1,2,2,1,3,2]
        case "Melodic Minor":
            scaleFormula = [2,1,2,2,2,2,1]
        case "Ionian":
            scaleFormula = [2,2,1,2,2,2,1]
        case "Dorian":
            scaleFormula = [2,1,2,2,2,1,2]
        case "Phrygian":
            scaleFormula = [1,2,2,2,1,2,2]
        case "Lydian":
            scaleFormula = [2,2,2,1,2,2,1]
        case "Mixolydian":
            scaleFormula = [2,2,1,2,2,1,2]
        case "Aeolian":
            scaleFormula = [2,1,2,2,1,2,2]
        case "Locrian":
            scaleFormula = [1,2,2,1,2,2,2]
        case "Whole Tone":
            scaleFormula = [2,2,2,2,2,2]
        default:
            scaleFormula = []
        }
        
        let rootNotesMidi = MusicUtils.noteNameToMidiNotes(name: root)
        var rootNoteCandidate:Int = upperBoundMidiNote
        let maxNote = upperBoundMidiNote
        let minNote = lowerBoundMidiNote
        var lowestRootNoteIndex = 0;
        for i in (0...rootNotesMidi.count-1).reversed() {
            if(rootNotesMidi[i] <= maxNote && rootNotesMidi[i] >= minNote){
                rootNoteCandidate = rootNotesMidi[i]
                lowestRootNoteIndex = i;
            }
        }
        self.rootNoteMidi = rootNoteCandidate
        
        
        
        var lowerPartialOctaveRootNote = rootNoteMidi;
        if(lowestRootNoteIndex > 0){
            lowerPartialOctaveRootNote = rootNotesMidi[lowestRootNoteIndex-1]
        }
        
        var lowerPartialNotes:[Int] = []
        
        var accumulator = 0
        var nNotesInPartialOctave = 0
        
        for i in 0..<scaleFormula.count {
            accumulator += scaleFormula[i]
            if(lowerPartialOctaveRootNote + accumulator < lowerBoundMidiNote){
                continue;
            }
            lowerPartialNotes.append(lowerPartialOctaveRootNote+accumulator)
            if(lowerPartialOctaveRootNote + accumulator > rootNoteMidi){
                break;
            }
        }
        
        
        let octavesToGenerate = Int(ceil(Double(upperBoundMidiNote - rootNoteCandidate)/12))
        let endOfLastFullOctave = (rootNoteCandidate + (octavesToGenerate-1)*12)
//        let semitonesInPartialOctave = upperBoundMidiNote - endOfLastFullOctave
        
        accumulator = 0
        nNotesInPartialOctave = 0
        
        for i in 0..<scaleFormula.count {
            accumulator += scaleFormula[i]
            if(endOfLastFullOctave + accumulator > upperBoundMidiNote){
                nNotesInPartialOctave = i
                break
            }
        }
        
        let tmpNotesSize = (octavesToGenerate-1)*scaleFormula.count + nNotesInPartialOctave + 1
        var tmpNotes = [Int](repeating:0,count:tmpNotesSize)
        tmpNotes[0] = rootNoteMidi
        
        var i = 1
        var scaleFormulaIndex = 0
        while i < tmpNotes.count {
            tmpNotes[i] = tmpNotes[i-1] + scaleFormula[scaleFormulaIndex]
            i += 1
            scaleFormulaIndex += 1
            if(scaleFormulaIndex == scaleFormula.count){
                scaleFormulaIndex = 0
            }
        }
        
        let fullNotes = lowerPartialNotes + tmpNotes
        
        self.notes = fullNotes
        
        var tmpFretboardPositions:[FretboardPosition] = []
        for j in 0..<notes.count {
            let fp = MusicUtils.midiNoteToFretboardPosition(note: notes[j])
            let newFp:FretboardPosition
            if(fp.string == 2 && fp.fret == 0){
                newFp = FretboardPosition(string: 3, fret: 4)
            } else{
                newFp = fp
            }
            tmpFretboardPositions.append(newFp)
        }
        fretboardPositions = tmpFretboardPositions
    }
    
    public func getFingering() -> [FretboardPosition]{
        return self.fretboardPositions
    }
    
    public func getRoot()->String{
        return root
    }
    
    public func getType()->String{
        return type
    }
}
