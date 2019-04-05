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
  var tonnetz: Tonnetz? {
    willSet {
      midiRouter.removeListener(key: "tonnetz")
    }
    didSet {
      liveVC?.setTonnetz(tonnetz)
      if let tn = tonnetz {
        midiRouter.register(listener: tn, key: "tonnetz")
      }
    }
  }

  var liveVC: RootViewController? {
    didSet {
      liveVC?.setTonnetz(tonnetz)
    }
  }

  func reset() {
    player = AudioPlayer(midiURL: LocalMIDI.pathetiqueURL)
    player?.MIDIdelegate = midiRouter

    tonnetz = Lattice(width: 12, height: 12)
//    tonnetz = Torus()

    self.player?.play()
  }
}
