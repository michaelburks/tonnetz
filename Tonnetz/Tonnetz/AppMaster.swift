//
//  AppMaster.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/1/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import Cocoa

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

      liveVC?.playButton?.target = self
      liveVC?.playButton?.action = #selector(AppMaster.togglePlay(_:))

      liveVC?.setTonnetz(tonnetz)
    }
  }

  func reset() {
    player = AudioPlayer()
    player?.MIDIdelegate = midiRouter

    tonnetz = Lattice(style: .Hex, componentType: MIDILightComponent.self, width: 12, height: 12)
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
        liveVC?.playButton?.title = "Pause"
        liveVC?.playButton?.isEnabled = true
      }
    } else {
      // User clicked on "Cancel"
      // No-op.
    }
  }

  @objc func togglePlay(_ button: NSButton) {
    if player?.isPlaying ?? false {
      player?.pause()
      liveVC?.playButton?.title = "Play"
    } else {
      player?.play()
      liveVC?.playButton?.title = "Pause"
    }
  }
}
