//
//  ViewController.swift
//  Tonnetz
//
//  Created by Michael Burks on 3/30/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import Cocoa
import SceneKit

class ViewController: NSViewController {
  var sceneView: SCNView? {
    get {
      return self.view as? SCNView
    }
  }

  override func loadView() {
    let scnView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
    scnView.backgroundColor = .black

//    scene = TonnetzScene()
//    sceneView.scene = scene
//    scnView.allowsCameraControl = true
    self.view = scnView
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

}
