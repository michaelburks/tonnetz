//
//  MIDISceneItems.swift
//  Tonnetz
//
//  Created by Michael Burks on 4/4/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

import SceneKit

// Node representing a MIDI note. There is expected to be a 1-1 correspondence between notes and MIDISceneNodes.
class MIDISceneNode: SCNNode {
  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    _components.forEach { (comp) in
      comp.update(note: note, event: event, velocity: velocity, count: count)
    }
  }

  func reset() {
    _components.forEach { (comp) in
      comp.reset()
    }
  }

  var components: [MIDISceneComponent] {
    get {
      return _components
    }
  }

  private var _components = [MIDISceneComponent]()

  func addComponent(_ comp: MIDISceneComponent) {
    _components.append(comp)
    self.addChildNode(comp.node)
  }
}

// Component to attach to a MIDISceneNode.
protocol MIDISceneComponent {
  var node: SCNNode { get }
  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int)
  func reset()
}

// Binary Components simply turn on or off to display activity of a note.
protocol MIDISceneBinaryComponent: MIDISceneComponent {
  var isOn: Bool { get }
  func turnOn()
  func turnOff()
}

extension MIDISceneBinaryComponent {
  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    if count > 0 {
      turnOn()
    } else {
      turnOff()
    }
  }

  func reset() {
    turnOff()
  }
}

class MIDISphereBinaryComponent: SCNNode, MIDISceneBinaryComponent {
  init(midi: MIDINote) {
    let geo = SCNSphere(radius: 5.0)
    geo.firstMaterial?.diffuse.contents = NSColor.midiColor(midi)
    super.init()
    self.geometry = geo
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var node: SCNNode {
    get {
      return self
    }
  }

  var isOn: Bool {
    get {
      return !self.isHidden
    }
  }

  func turnOn() {
    DispatchQueue.main.async {
      self.isHidden = false
    }
  }

  func turnOff() {
    DispatchQueue.main.async {
      self.isHidden = true
    }
  }
}

class MIDISphereComponent: MIDISceneComponent {
  private let _node: SCNNode

  var node: SCNNode {
    get {
      return _node
    }
  }

  init(midi: MIDINote) {
    _node = SCNNode(geometry: SCNSphere(radius: 5.0))
    _node.geometry?.firstMaterial?.diffuse.contents = NSColor.midiColor(midi)
  }

  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    if event == .off {
      if count == 0 {
        reset()
      } else {
        _node.opacity *= 0.8
      }
    } else {
      _node.opacity = 1.0
//      let d = log2(Double(velocity) + 128)
      let d = Double(velocity) / 10
      let hold = SCNAction.wait(duration: d)
      let fade = SCNAction.fadeOpacity(by: -1.0, duration: d)
      let group = SCNAction.sequence([hold, fade])
      _node.runAction(group)
    }
  }

  func reset() {
    _node.opacity = 0
  }
}

class MIDIParticleComponent: MIDISceneComponent {

  private let _particleSystem: SCNParticleSystem
  private let _node: SCNNode

  init(midi: MIDINote) {
    _node = SCNNode(geometry: SCNSphere(radius: 1.0))
    _particleSystem = SCNParticleSystem(named: "particles", inDirectory: nil)!
    _particleSystem.particleColor = NSColor.midiColor(midi)
    _node.addParticleSystem(_particleSystem)

    let decay = SCNAction.customAction(duration: 1.0) { (node, time) in
      if let ps = node.particleSystems?.first {
        ps.birthRate *= 0.5
      }
    }
    let repeatDecay = SCNAction.repeatForever(decay)

    _node.runAction(repeatDecay)
  }

  var node: SCNNode {
    get {
      return _node
    }
  }

  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    if event == .off {
      if count == 0 {
        reset()
      } else {
        _particleSystem.birthRate *= 0.5
      }
    } else {
      _particleSystem.birthRate += CGFloat(velocity) * 100.0 /// 10.0s
    }
  }

  func reset() {
    _particleSystem.birthRate = 0.0
    _particleSystem.reset()
  }
}

class MIDILightComponent: MIDISceneComponent {
  private let _node: SCNNode
  private let _light: SCNLight

  let spacing: CGFloat = 5.0

  init(midi: MIDINote) {
    _node = SCNNode(geometry: SCNSphere(radius: 5.0))
    let m = MIDILightComponent.nodeMaterial()
    _node.geometry?.firstMaterial = m
    _node.opacity = 0.5

    _light = SCNLight()
    _light.type = .omni
    _light.color = NSColor.midiColor(midi)
    _light.attenuationEndDistance = 30.0

    _light.intensity = 4000
    _node.light = _light
    _node.rotation = SCNVector4Make(0.0, 1.0, 0.0, CGFloat(Double.pi * -0.5))

    let decay = SCNAction.customAction(duration: 1.0) { (node, time) in
      if let l = node.light {
        l.intensity *= 0.98
      }
    }
    let repeatDecay = SCNAction.repeatForever(decay)

    _node.runAction(repeatDecay)
  }

  static func nodeMaterial() -> SCNMaterial {
    let mat = SCNMaterial()
    mat.lightingModel = .lambert
    mat.isDoubleSided = true
    mat.diffuse.contents = NSColor(calibratedWhite: 0.9, alpha: 0.7)
    return mat
  }

  var node: SCNNode {
    get {
       return _node
    }
  }

  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    if event == .off {
      if count == 0 {
        reset()
      } else {
        _light.intensity *= 0.6
      }
    } else {
      _light.intensity += CGFloat(velocity) * 1000.0 /// 10.0s
    }
  }

  func reset() {
    _light.intensity = 0.0
  }

}
