//
//  AppMaster.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/1/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import Cocoa

class LocalMIDI {
  static var pathetiqueURL: URL {
    get {
      return Bundle.main.url(forResource: "pathetique_2", withExtension: "mid")!
    }
  }
}

class AppMaster {
  static let sharedInstance = AppMaster()
  private init() {}

  var player: AudioPlayer?
  let midiRouter: MIDIRouter = MIDIRouter()
  var scene: TonnetzScene? {
    willSet {
      midiRouter.removeListener(key: "scene")
    }
    didSet {
      liveVC?.sceneView?.scene = scene
      if let s = scene {
        midiRouter.register(listener: s, key: "scene")
      }
    }
  }

  var liveVC: ViewController? {
    didSet {
      liveVC?.sceneView?.scene = scene
    }
  }

  func reset() {
    player = AudioPlayer(midiURL: LocalMIDI.pathetiqueURL)
    player?.MIDIdelegate = midiRouter

    scene = TonnetzScene()

    self.player?.play()

  }

}

class MIDIRouter: LiveMIDIHandlerDelegate {
  var listeners = [String:LiveMIDIHandlerDelegate]()
  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8) {
    listeners.forEach { (key: String, value: LiveMIDIHandlerDelegate) in
      value.handleMIDIEvent(event, note: note, velocity: velocity)
    }
  }

  func register(listener: LiveMIDIHandlerDelegate, key: String) {
    listeners[key] = listener
  }

  func removeListener(key: String) {
    listeners[key] = nil
  }
}
