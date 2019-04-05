//
//  TonnetzScene.swift
//  Tonnetz
//
//  Created by Michael Burks on 3/30/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

class TonnetzScene: SCNScene {
  let tonnetz: Tonnetz

  let bank = MIDIBank()

  init(tonnetz initVal: Tonnetz) {
    tonnetz = initVal
    super.init()

    for node in tonnetz.auxNodes {
      rootNode.addChildNode(node)
    }

    for item in tonnetz.noteNodes {
      item.reset()
      rootNode.addChildNode(item)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
