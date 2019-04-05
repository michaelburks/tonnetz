//
//  MIDIVisualizer.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/1/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

protocol MIDIResponder {
  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8, count: Int)
}

class MIDIRouter: LiveMIDIHandlerDelegate {
  let bank = MIDIBank()

  var listeners = [String:MIDIResponder]()

  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8) {
    var ev = event
    if velocity == 0 {
      ev = .off
    }
    bank[note] = ev

    let count = bank.count(note: note)

    listeners.forEach { (key: String, value: MIDIResponder) in
      value.handleMIDIEvent(event, note: note, velocity: velocity, count: count)
    }
  }

  func register(listener: MIDIResponder, key: String) {
    listeners[key] = listener
  }

  func removeListener(key: String) {
    listeners[key] = nil
  }
}

class MIDIBank {
  private var noteBitmask = [UInt8:UInt32]()
  init() {
    for k in 0..<12 {
      noteBitmask[UInt8(k)] = 0
    }
  }

  private func bitmask(note: MIDINote) -> UInt32 {
    return noteBitmask[note % 12]!
  }

  subscript(_ note: MIDINote) -> MIDIEvent {
    get {
      return bitmask(note: note) & note.octaveBit == 0 ? .off : .on
    }
    set(newValue) {
      if newValue == .on {
        noteBitmask[note % 12] = bitmask(note: note) | note.octaveBit
      } else {
        noteBitmask[note % 12] = bitmask(note: note) & (UInt32.max - note.octaveBit)
      }
    }
  }

  func count(note: MIDINote) -> Int {
   return Int(_mm_popcnt_u32(bitmask(note: note)))
  }
}
