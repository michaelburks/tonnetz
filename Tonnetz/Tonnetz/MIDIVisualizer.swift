//
//  MIDIVisualizer.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/1/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

protocol MIDIVisualizer: LiveMIDIHandlerDelegate {
  var bank: MIDIBank {get}
  func MIDIItem(note: MIDINote) -> MIDISceneNode?
}

extension MIDIVisualizer {
  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8) {
    var ev = event
    if velocity == 0 {
      ev = .off
    }
    if note == 70 {
      print(70)
    }

    bank[note] = ev
    MIDIItem(note: note)?.update(note: note, event: ev, velocity: velocity, count: bank.count(note: note))
  }
}

class MIDIBank {
//  private var data = [MIDINote:MIDIEvent]()
//  private var notesOn = Set<MIDINote>()
  private var noteBitmask = [UInt8:UInt16]()
  init() {
    for k in 0..<12 {
      noteBitmask[UInt8(k)] = 0
    }
  }

  private func bitmask(note: MIDINote) -> UInt16 {
    return noteBitmask[note % 12]!
  }

  subscript(_ note: MIDINote) -> MIDIEvent {
    get {
//      return notesOn.contains(note) ? .on : .off
      return bitmask(note: note) & note.octaveBit == 0 ? .off : .on
    }
    set(newValue) {
      if newValue == .on {
//        notesOn.insert(note)
        noteBitmask[note % 12] = bitmask(note: note) | note.octaveBit
      } else {
//        notesOn.remove(note)
        noteBitmask[note % 12] = bitmask(note: note) & (UInt16.max - note.octaveBit)
      }
    }
  }

  func count(note: MIDINote) -> Int {
//    let id = note % 12
//    return notesOn.reduce(0, { (res, nt) -> Int in
//      if nt % 12 == id {
//        return res + 1
//      } else {
//        return res
//      }
//    })
    return bitmask(note: note) == 0 ? 0 : 1
//    return data.reduce(0) { (res, pair) -> Int in
//      if pair.0 % 12 == n && pair.1 == .on {
//        return res + 1
//      } else {
//        return res
//      }
//    }
  }
}
