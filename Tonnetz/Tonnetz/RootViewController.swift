//
//  ViewController.swift
//  Tonnetz
//
//  Created by Michael Burks on 3/30/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import Cocoa
import SceneKit

class RootViewController: NSViewController {
  @IBOutlet var fileLabel: NSTextField?
  @IBOutlet var fileButton: NSButton?
  @IBOutlet var playButton: NSButton?
  @IBOutlet var sceneContainer: NSView?

  private var sceneView: SCNView?

  override func viewDidLoad() {
    sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    sceneView?.translatesAutoresizingMaskIntoConstraints = false
    sceneView!.backgroundColor = .black

    sceneContainer?.addSubview(sceneView!)

    sceneView?.widthAnchor.constraint(equalToConstant: 600).isActive = true
    sceneView?.heightAnchor.constraint(equalToConstant: 600).isActive = true

    sceneView?.centerXAnchor.constraint(equalTo: sceneContainer!.centerXAnchor).isActive = true
    sceneView?.topAnchor.constraint(equalTo: sceneContainer!.topAnchor).isActive = true

    playButton?.isEnabled = false
    playButton?.title = "Play"
  }

  override func viewWillAppear() {
    super.viewWillAppear()
    AppMaster.sharedInstance.liveVC = self
  }

  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }

  func setTonnetz(_ tonnetz: Tonnetz?) {
    if let t = tonnetz {
      let ts = TonnetzScene(tonnetz: t)
      self.sceneView?.scene = ts
    } else {
      self.sceneView?.scene = nil
    }
  }
}
