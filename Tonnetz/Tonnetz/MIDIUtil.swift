//
//  MIDIUtil.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/1/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

class MIDICommand {
  static let off = 0x08
  static let on = 0x09
}

enum MIDIEvent {
  case off
  case on
}

typealias MIDINote = UInt8

extension MIDINote {
  static let max: UInt8 = 127

  var letter: String {
    get {
      let n = self % 12
      switch n {
      case 0:
        return "C"
      case 1:
        return "C#"
      case 2:
        return "D"
      case 3:
        return "D#"
      case 4:
        return "E"
      case 5:
        return "F"
      case 6:
        return "F#"
      case 7:
        return "G"
      case 8:
        return "G#"
      case 9:
        return "A"
      case 10:
        return "A#"
      case 11:
        return "B"
      default:
        return "X"
      }
    }
  }
  var octaveBit: UInt16 {
    get {
      return UInt16(1 << (self / 12))
    }
  }
  var octave: String {
    get {
      let o = Int(self / 12) - 1
      return String(o)
    }
  }
  var name: String {
    get {
      return self.letter + self.octave
    }
  }
}
