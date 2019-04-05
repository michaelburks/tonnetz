//
//  Tonnetz.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/4/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

protocol Tonnetz: MIDIResponder {
  var auxNodes: [SCNNode] { get }
  var noteNodes: [MIDISceneNode] { get }
}

extension Tonnetz {
  func handleMIDIEvent(_ event: MIDIEvent, note: MIDINote, velocity: UInt8, count: Int) {
    let z = Int(note % 12)
    let n = noteNodes[safe: z]
    n?.update(note: note, event: event, velocity: velocity, count: count)
  }
}

class Lattice: Tonnetz {
  var noteNodes = [MIDISceneNode]()
  var auxNodes = [SCNNode]()

  let width: Int
  let height: Int

  let spacing: CGFloat = 20.0
  let radius: CGFloat = 5.0

  init(width w: Int, height h: Int) {
    width = w
    height = h

    for _ in 0..<12 {
      noteNodes.append(MIDISceneNode())
    }

    for x in 0...width {
      for y in 0...height {
        let n = (4*x + 3*y) % 12

        let node = MIDISphereComponent(midi: MIDINote(n))
        node.position = SCNVector3Make(spacing * CGFloat(x), spacing * CGFloat(y), 0)

//        let ps = SCNParticleSystem(named: "particles", inDirectory:nil)!
//        ps.particleColor = color
//        node.addParticleSystem(ps)

        noteNodes[n].addComponent(node)
      }
    }
  }
}

class Torus: Tonnetz {
  var noteNodes: [MIDISceneNode]
  var auxNodes: [SCNNode]

  let torus: SCNNode = {
    let geo = SCNTorus(ringRadius:60, pipeRadius:15)
    geo.firstMaterial?.diffuse.contents = NSColor(calibratedWhite: 1.0, alpha: 0.3)
    let node = SCNNode(geometry: geo)
    node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2)
    return node
  }()

  init() {
    auxNodes = [torus]
    noteNodes = Torus.MIDINodes()
  }

  static func MIDINodes() -> [MIDISceneNode] {
    var nodes = [MIDISceneNode]()
    for i in stride(from: 0, to: 12, by: 1) {
      let (pos, center) = Torus.coordsForMIDI(i)

      let node = MIDISphereComponent(midi: MIDINote(i))
      node.position = pos

      let baseNode = MIDISceneNode()
      baseNode.position = center
      baseNode.addComponent(node)

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
  static func colorForMIDI(_ value: MIDINote) -> NSColor {
    let hue = CGFloat(value % 12) / 12.0
    return NSColor(hue: hue, saturation: 0.6, brightness: 0.6, alpha: 1.0)
  }
}
