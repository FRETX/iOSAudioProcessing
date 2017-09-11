//
//  MusicUtils.swift
//  FretX_prototype
//
//  Created by Onur Babacan on 26/06/2017.
//  Copyright © 2017 Onur Babacan. All rights reserved.
//

import Foundation

@objc public class MusicUtils:NSObject{
    
    private static let chordDb:[String:FingerPositions] = MusicUtils.readChordDbJson()
    
    public static func noteNameToSemitoneNumber(noteName:String) -> Int{
        var semitone = 0
        switch noteName {
        case "A":  semitone = 1
        case "Bb": semitone = 2
        case "B":  semitone = 3
        case "C":  semitone = 4
        case "C#": semitone = 5
        case "D":  semitone = 6
        case "Eb": semitone = 7
        case "E":  semitone = 8
        case "F":  semitone = 9
        case "F#": semitone = 10
        case "G":  semitone = 11
        case "G#": semitone = 12
        default:   semitone = 0
        }
        return semitone
    }
    
    public static func semitoneNumberToNoteName(number:Int) -> String {
        switch number {
        case 1: return "A"
        case 2: return "Bb"
        case 3: return "B"
        case 4: return "C"
        case 5: return "C#"
        case 6: return "D"
        case 7: return "Eb"
        case 8: return "E"
        case 9: return "F"
        case 10: return "F#"
        case 11: return "G"
        case 12: return "G#"
        default: return "NONE"
        }
    }
    
    public static func validateNoteName(name:String)->String{
        var newName = name
        if(name.characters.count == 2){
            if(name[name.index(name.startIndex, offsetBy: 1)] == "b"){
                switch name[name.startIndex] {
                case "A": newName = "G#"
                case "D": newName = "C#"
                case "G": newName = "F#"
                default: newName = "NONE"
                }
            }
            if(name[name.index(name.startIndex, offsetBy: 1)] == "#"){
                switch name[name.startIndex] {
                case "A": newName = "Bb"
                case "D": newName = "Eb"
                default:
                    newName = "NONE"
                }
            }
        }
        return newName
    }
    
    public static func hzToMidiNote(hertz:Double)->Double{
        return 69 + (12 * log10(hertz / 440) / log10(2))
    }
    
    public static func midiNoteToHz(note:Int)->Double{
        return 440 * pow(2 , ((Double(note) - 69) / 12) )
    }

    public static func midiNoteToName(note:Int)->String{
        let noteString = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B"]
        let octave = (note/12)-1
        let noteIndex = note % 12
        return noteString[noteIndex] + String(octave)
    }

    public static func noteNameToMidiNotes(name:String)->[Int]{
        var lowestMidiNote = 0
        let upperMidiBound = 108
        switch name {
        case "A":  lowestMidiNote = 21
        case "Bb": lowestMidiNote = 22
        case "B":  lowestMidiNote = 23
        case "C":  lowestMidiNote = 24
        case "D":  lowestMidiNote = 25
        case "Eb": lowestMidiNote = 26
        case "E":  lowestMidiNote = 27
        case "F":  lowestMidiNote = 29
        case "F#": lowestMidiNote = 30
        case "G":  lowestMidiNote = 31
        case "G#": lowestMidiNote = 32
        default:
            lowestMidiNote = 0
        }
        let arraySize = Int(floor(Double(upperMidiBound-lowestMidiNote) / 12 ))
        var notes = [Int](repeating: 0, count: arraySize)
        for i in 0..<arraySize {
            notes[i] = lowestMidiNote + i*12
        }
        return notes
    }
    
    public static func midiNoteToFretboardPosition(note:Int)->FretboardPosition{
        var newNote = note
        if(note<40){
            print("MusicUtils.midiNoteToFretboardPosition: This note (\(note)) is outside the display range of FretX")
            return FretboardPosition(string: 6, fret: 0)
        }
        if(note>68){
            print("MusicUtils.midiNoteToFretboardPosition: This note (\(note)) is outside the display range of FretX")
            return FretboardPosition(string: 1, fret: 4)
        }
        if(note>59){
            newNote += 1
        }
        let fret = (newNote-40) % 5
        let string = 6 - ( (newNote-40) / 5 )
        return FretboardPosition(string: string, fret: fret)
    }
    
    public static func hzToCent(hz:Double)->Double{
        return (1200*log2(hz))
    }
    
    public static func centToHz(cent:Double)->Double{
        return pow(2,cent/1200)
    }
    
    public static func frequencyFromInterval(baseNote:Float, intervalInSemitones:Int)->Float{
        return baseNote * pow(2,Float(intervalInSemitones)/12)
    }
    
    public enum TuningName {
        case STANDARD
        case DROP_D
        //to be expanded later on
    }
    
    public static func getTuningMidiNotes(tuning:TuningName)->[Int]{
        switch tuning {
        case .STANDARD:
            return [40,45,50,55,59,64]
        case .DROP_D:
            return [38,45,50,55,59,64]
        }
    }
    
    private static func readChordDbJson()->[String:FingerPositions] {
        var tmpChordDb:[String:FingerPositions] = [:]
        do {
            if let file = Bundle(for: MusicUtils.self).url(forResource: "chorddb", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [Any] {
                    for element in object {
                        let entry = element as! NSDictionary
                        let name = entry["name"] as! String
                        let baseFret = entry["baseFret"] as! Int
                        
                        let string6 = entry["string6"] as! Int
                        let string5 = entry["string5"] as! Int
                        let string4 = entry["string4"] as! Int
                        let string3 = entry["string3"] as! Int
                        let string2 = entry["string2"] as! Int
                        let string1 = entry["string1"] as! Int
                        
                        let chord = FingerPositions(
                            name: name,
                            baseFret: baseFret,
                            string6: string6,
                            string5: string5,
                            string4: string4,
                            string3: string3,
                            string2: string2,
                            string1: string1
                        )
                        tmpChordDb[chord.name] = chord
                    }
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        return tmpChordDb
    }
    
    public static func getFingering(chordName:String)->FingerPositions?{
        var fp:FingerPositions?
        if let chord = chordDb[chordName]{
            fp = chord
        }
        return fp
    }
    
    public static func getBluetoothArrayFromChord(chordName:String)->[UInt8]{
        if chordName == "noise" {
            return [0]
        } else {
            if let fp = getFingering(chordName: chordName){
                var fingerPositions = [Int](repeating:-1,count:6)
                fingerPositions[0] = fp.string1
                fingerPositions[1] = fp.string2
                fingerPositions[2] = fp.string3
                fingerPositions[3] = fp.string4
                fingerPositions[4] = fp.string5
                fingerPositions[5] = fp.string6
                var bluetoothArray:[UInt8] = []
                for i in 0..<fingerPositions.count{
                    if(fingerPositions[i] > -1){
                        bluetoothArray.append( UInt8(fingerPositions[i]*10 + (i+1)) )
                    }
                }
                bluetoothArray.append(UInt8(0))
                return bluetoothArray
            } else {return [0]}
        }
    }
    
    public static func getBluetoothArrayFromScale(scale:Scale)->[UInt8]{
        var bluetoothArray:[UInt8] = []
        let fretboardPositions = scale.getFingering()
        for fp in fretboardPositions {
            bluetoothArray.append(fp.getByteCode())
        }
        return bluetoothArray
    }
    
}
