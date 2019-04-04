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

  override init() {
    tonnetz = Lattice(width: 12, height: 12)
    super.init()

    for node in tonnetz.auxNodes {
      rootNode.addChildNode(node)
    }

    for node in tonnetz.noteNodes {
      node.reset()
      rootNode.addChildNode(node)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

protocol Tonnetz {
//  func display(_ notes: [MIDINote])
//
//  var notes: [MIDINoteItem] { get } // Nodes for the twelve
  // var chords: [MIDIChordItem] { get }
  // Surfaces

  var auxNodes: [SCNNode] { get }

  var noteNodes: [SCNNode] { get }
  func node(note: Note) -> SCNNode
}

extension Tonnetz {
  func node(note: Note) -> SCNNode {
    let i = Int(log2(Double(note)))
    return noteNodes[i]
  }
}

class Lattice: Tonnetz {
  var auxNodes = [SCNNode]()
  var noteNodes = [SCNNode]()

  let width: Int
  let height: Int

  let spacing: CGFloat = 20.0
  let radius: CGFloat = 5.0

  init(width w: Int, height h: Int) {
    width = w
    height = h

    for _ in 0..<12 {
      noteNodes.append(SCNNode())
    }

    for x in 0...width {
      for y in 0...height {
        let n = (4*x + 3*y) % 12

        let geo = SCNSphere(radius: radius)
        geo.firstMaterial?.diffuse.contents = MIDIMath.colorForMIDI(n)
        let node = SCNNode(geometry: geo)
        node.position = SCNVector3Make(spacing * CGFloat(x), spacing * CGFloat(y), 0)

        noteNodes[n].addChildNode(node)
      }
    }
  }
}

class Torus: Tonnetz {

  let torus: SCNNode = {
    let geo = SCNTorus(ringRadius:60, pipeRadius:15)
    geo.firstMaterial?.diffuse.contents = NSColor(calibratedWhite: 1.0, alpha: 0.3)
    let node = SCNNode(geometry: geo)
    node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2)
    return node
  }()

  var auxNodes: [SCNNode]

  var noteNodes: [SCNNode]

  init() {
    auxNodes = [torus]
    noteNodes = Torus.MIDINodes()
  }

  static func MIDINodes() -> [SCNNode] {
    var nodes = [SCNNode]()
    for i in stride(from: 0, to: 12, by: 1) {
      let (pos, center) = Torus.coordsForMIDI(i)
      let geo = SCNSphere(radius: 5.0)
      geo.firstMaterial?.diffuse.contents = MIDIMath.colorForMIDI(i)

      let node = SCNNode(geometry: geo)
      node.position = pos

      let baseGeo = SCNSphere(radius: 2.0)
      baseGeo.firstMaterial?.diffuse.contents = NSColor(calibratedWhite: 0.0, alpha: 0.0)
      let baseNode = SCNNode(geometry: baseGeo)
      baseNode.position = center
      baseNode.addChildNode(node)

      nodes.append(baseNode)
    }
    return nodes

  }

  static func coordsForMIDI(_ value: Int) -> (SCNVector3, SCNVector3) {
    let bigR: Float = 60
    let littleR: Float = 20

    let v = Float(value)

    let theta = Float.pi * v / 2

    let y = bigR - littleR * cos(theta)
    let z = littleR * sin(theta)
    let baseVec = SCNVector4(0, y, z, 0)

    let phi = Float.pi * v * 5 / 6

    let zRotation = SCNMatrix4MakeRotation(CGFloat(phi), 0, 0, 1)
    let startCoord = baseVec.applyTransform(zRotation).to3()

    let center = SCNVector3Make(CGFloat(-bigR * sin(phi)), CGFloat(bigR * cos(phi)), 0)

    let relative = startCoord - center

    return (relative, center)
  }
}

class MIDIMath {
  static func colorForMIDI(_ value: Int) -> NSColor {
    let hue = CGFloat(value % 12) / 12.0
    return NSColor(hue: hue, saturation: 0.6, brightness: 0.6, alpha: 1.0)
  }
}

extension TonnetzScene: MIDIVisualizer {
  func MIDIItem(note: MIDINote) -> MIDINoteItem? {
    let z = Int(note % 12)
    return tonnetz.noteNodes[safe: z]
  }

//  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8) {
//    DispatchQueue.main.async {
//      var ev = event
//      if velocity == 0 {
//        ev = .off
//      }
//      print("\(ev) \(note)")
//    }
//  }

  func update() {
    for (i, node) in tonnetz.noteNodes.enumerated() {
      let c = bank.count(note: MIDINote(i))
      DispatchQueue.main.async {
        if c > 0 {
          node.on = true
        } else {
          node.on = false
        }
      }
    }
  }
}

extension SCNNode: MIDINoteItem {
  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    print("\(event) \(note)")
    DispatchQueue.main.async {
      if count > 0 {
        self.on = true
      } else {
        self.on = false
      }
    }
  }

  func reset() {
    self.on = false
  }

  var on: Bool {
    get {
      return !self.isHidden
    }
    set(newValue) {
      self.isHidden = !newValue
    }
  }
}

//class MIDINode: SCNNode {
//  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
//    print("\(event) \(note)")
//    DispatchQueue.main.async {
//      if count > 0 {
//        self.on = true
//      } else {
//        self.on = false
//      }
//    }
//  }
//
//  func reset() {
//    self.on = false
//  }
//
//  var on: Bool {
//    get {
//      return !self.isHidden
//    }
//    set(newValue) {
//      self.isHidden = !newValue
//    }
//  }
//}
