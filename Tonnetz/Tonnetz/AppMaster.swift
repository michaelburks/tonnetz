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
      liveVC?.fileButton?.target = self
      liveVC?.fileButton?.action = #selector(AppMaster.selectFile(_:))
      liveVC?.setTonnetz(tonnetz)
    }
  }

  func reset() {
    player = AudioPlayer()
    player?.MIDIdelegate = midiRouter

    tonnetz = Lattice(width: 12, height: 12)
//    tonnetz = Torus()

//    self.player?.play()
  }

  @objc func selectFile(_ button: NSButton) {
    let dialog = NSOpenPanel()
    dialog.title = "Select a MIDI file"
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.canChooseDirectories    = true;
    dialog.canCreateDirectories    = false;
    dialog.allowsMultipleSelection = false;
    dialog.allowedFileTypes        = ["mid", "midi"];

    if (dialog.runModal() == .OK) {
      if let result = dialog.url {
        player?.midiURL = result
        liveVC?.fileLabel?.stringValue = result.lastPathComponent
        player?.play()
      }
    } else {
      // User clicked on "Cancel"
      return
    }
  }
}
