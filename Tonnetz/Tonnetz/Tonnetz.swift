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
    DispatchQueue.main.async {
      n?.update(note: note, event: event, velocity: velocity, count: count)
    }
  }
}

class HexLattice: Tonnetz {
  var noteNodes = [MIDISceneNode]()
  var auxNodes = [SCNNode]()

  let width: Int
  let height: Int

  let spacing: CGFloat = 20.0

  init(width w: Int, height h: Int) {
    width = w
    height = h

    for _ in 0..<12 {
      noteNodes.append(MIDISceneNode())
    }

    let ln = SCNNode()
    let light = SCNLight()
    light.type = .ambient
    light.intensity = 10
    ln.light = light
    auxNodes.append(ln)

    for x in 0...width {
      var yShift: Int = 7
      for y in 0...height {
        var xOffset: CGFloat = 0.0

        if y % 2 == 1 {
          xOffset = spacing * 0.5
        } else {
          yShift += 5
        }

        let n = (7*x + 4*y + yShift) % 12

        let vSpacing = sqrt(3.0) * 0.5 * spacing
//        let comp = MIDISphereComponent(midi: MIDINote(n))
//        let comp = MIDIParticleComponent(midi: MIDINote(n))

        let comp = MIDILightComponent(midi: MIDINote(n))
        comp.node.position = SCNVector3Make(spacing * CGFloat(x) + xOffset, vSpacing * CGFloat(y), 0)

        noteNodes[n].addComponent(comp)
      }
    }
  }
}

class SquareLattice: Tonnetz {
  var noteNodes = [MIDISceneNode]()
  var auxNodes = [SCNNode]()

  let width: Int
  let height: Int

  let spacing: CGFloat = 20.0

  init(width w: Int, height h: Int) {
    width = w
    height = h

    for _ in 0..<12 {
      noteNodes.append(MIDISceneNode())
    }

    for x in 0...width {
      for y in 0...height {
        let n = (4*x + 3*y) % 12

        //        let comp = MIDISphereComponent(midi: MIDINote(n))
        //        let comp = MIDIParticleComponent(midi: MIDINote(n))
        let light = MIDILightComponent(midi: MIDINote(n))
        light.node.position = SCNVector3Make(spacing * CGFloat(x), spacing * CGFloat(y), 0)

        noteNodes[n].addComponent(light)
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

      let node = MIDISphereBinaryComponent(midi: MIDINote(i))
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

extension NSColor {
  static func midiColor(_ value: MIDINote) -> NSColor {
    let hue = CGFloat(value % 12) / 12.0
    return NSColor(hue: hue, saturation: 0.6, brightness: 0.6, alpha: 1.0)
  }
}
