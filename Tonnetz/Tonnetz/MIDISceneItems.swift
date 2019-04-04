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
    comp.attachToNode(node: self)
  }
}

// Component to attach to a MIDISceneNode.
protocol MIDISceneComponent {
  func attachToNode(node: SCNNode)

  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int)
  func reset()
}

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

class MIDISphereComponent: SCNNode, MIDISceneBinaryComponent {
  init(midi: MIDINote) {
    let geo = SCNSphere(radius: 5.0)
    geo.firstMaterial?.diffuse.contents = MIDIMath.colorForMIDI(midi)
    super.init()
    self.geometry = geo
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func attachToNode(node: SCNNode) {
    node.addChildNode(self)
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

class MIDIParticleComponent: MIDISceneComponent {
  private let defaultBirthrate: CGFloat = 10.0
  private let particleSystem: SCNParticleSystem

  init() {
    particleSystem = SCNParticleSystem(named: "particles", inDirectory: nil)!
  }

  func attachToNode(node: SCNNode) {
    node.addParticleSystem(particleSystem)
  }

  func update(note: MIDINote, event: MIDIEvent, velocity: UInt8, count: Int) {
    if event == .off {
      if count == 0 {
        reset()
      } else {
        particleSystem.birthRate *= 0.5
      }
    } else {
      particleSystem.birthRate += CGFloat(velocity)
    }
  }

  func reset() {
    particleSystem.birthRate = 0.0
    particleSystem.reset()
  }

}
