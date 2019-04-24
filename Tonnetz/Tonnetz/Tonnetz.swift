//
//  Tonnetz.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/4/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

protocol Tonnetz: MIDIResponder, SCNSceneRendererDelegate, AnyObject {
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

protocol LatticeStyleProtocol {
  func noteAtLatticePoint(_ x: Int, _ y: Int) -> Int
  func positionForLatticePoint(_ x: Int, _ y: Int, spacing: CGFloat) -> SCNVector3
}

enum LatticeStyle: LatticeStyleProtocol {
  case Square
  case Hex

  func noteAtLatticePoint(_ x: Int, _ y: Int) -> Int {
    var n = 0

    switch self {
    case .Square:
      n = (4*x + 3*y) % 12
    case .Hex:
      let shift = 7 + (y/2) * 5
      n = (7*x + 4*y + shift) % 12
    }

    return n
  }

  func positionForLatticePoint(_ x: Int, _ y: Int, spacing: CGFloat) -> SCNVector3 {
    var vx: CGFloat = 0.0
    var vy: CGFloat = 0.0

    switch self {
    case .Square:
      vx = spacing * CGFloat(x)
      vy = spacing * CGFloat(y)
    case .Hex:
      vx = spacing * CGFloat(x) + CGFloat(y % 2) * spacing * 0.5
      vy = spacing * sqrt(3.0) * 0.5 * CGFloat(y)
    }

    return SCNVector3Make(vx, vy, 0.0)
  }
}

class Lattice<Component: MIDISceneComponent>: NSObject, Tonnetz {

  var noteNodes = [MIDISceneNode]()
  var auxNodes = [SCNNode]()

  var width: Int { return _width }
  var height: Int { return _height }

  let _width: Int
  let _height: Int
  let style: LatticeStyle

  let spacing: CGFloat = 20.0

  required init(style s: LatticeStyle, componentType: Component.Type, width w: Int, height h: Int) {
    _width = w
    _height = h
    style = s

    super.init()

    for _ in 0..<12 {
      noteNodes.append(MIDISceneNode())
    }

    for x in 0...width {
      for y in 0...height {
        let note = style.noteAtLatticePoint(x, y)
        let comp = Component.init(midi: MIDINote(note))
        comp.node.position = style.positionForLatticePoint(x, y, spacing: spacing)
        noteNodes[note].addComponent(comp)
      }
    }
  }
}

class Torus: NSObject, Tonnetz {
  var noteNodes: [MIDISceneNode]
  var auxNodes: [SCNNode]

  let torus: SCNNode = {
    let geo = SCNTorus(ringRadius:60, pipeRadius:15)
    geo.firstMaterial?.diffuse.contents = NSColor(calibratedWhite: 1.0, alpha: 0.3)
    let node = SCNNode(geometry: geo)
    node.rotation = SCNVector4(x: 1, y: 0, z: 0, w: .pi / 2)
    return node
  }()

  override init() {
    auxNodes = [torus]
    noteNodes = Torus.MIDINodes()
    super.init()
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
