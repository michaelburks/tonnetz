//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

import SceneKit

extension SCNVector4 {
  public func applyTransform(_ t: SCNMatrix4) -> SCNVector4 {
    let x = t.m11 * self.x + t.m21 * self.y + t.m31 * self.z + t.m41 * self.w
    let y = t.m12 * self.x + t.m22 * self.y + t.m32 * self.z + t.m42 * self.w
    let z = t.m13 * self.x + t.m23 * self.y + t.m33 * self.z + t.m43 * self.w
    let w = t.m14 * self.x + t.m24 * self.y + t.m43 * self.z + t.m44 * self.w

    return SCNVector4(x: x, y: y, z: z, w: w)
  }

  public func to3() -> SCNVector3 {
    return SCNVector3(self.x , self.y, self.z)
  }
}

extension SCNVector3 {
  static func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
  }
}

class TonnetzScene: SCNScene {
  lazy var lightNode: SCNNode = {
    let light = SCNLight()
    light.type = .ambient
    let node = SCNNode()
    node.light = light
    return node
  }()

  override init() {
    super.init()
    //rootNode.addChildNode(self.lightNode)

    for node in TonnetzScene.torusMIDINodes() {
      rootNode.addChildNode(node)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  static func MIDINodes() -> [SCNNode] {
    var nodes = [SCNNode]()
    for i in 0..<63 {
      let pos = coordsForMIDI(i)
      let geo = SCNSphere(radius: 5.0)
      geo.firstMaterial?.diffuse.contents = colorForMIDI(i)

      let node = SCNNode(geometry: geo)
      node.position = pos
      
      nodes.append(node)
    }
    return nodes
  }

  static func torusMIDINodes() -> [SCNNode] {
    var nodes = [SCNNode]()
    for i in stride(from: 0, to: 12, by: 1) {
      let (pos, center) = torusCoordsForMIDI(i)
      let geo = SCNSphere(radius: 5.0)
      geo.firstMaterial?.diffuse.contents = colorForMIDI(i)

      let node = SCNNode(geometry: geo)
      node.position = pos

      let baseGeo = SCNSphere(radius: 2.0)
      baseGeo.firstMaterial?.diffuse.contents = UIColor.gray
      let baseNode = SCNNode(geometry: baseGeo)
      baseNode.position = center
      baseNode.addChildNode(node)

      let axis = SCNVector3Make(center.y, -center.x, 0)

      let rotate = SCNAction.rotate(by: CGFloat.pi * 2, around: axis, duration: 10)
      let infinite = SCNAction.repeatForever(rotate)
      baseNode.runAction(infinite)

      nodes.append(baseNode)
    }
    return nodes

  }
}

func colorForMIDI(_ value: Int) -> UIColor {
  let hue = CGFloat(value % 12) / 12.0
  return UIColor(hue: hue, saturation: 0.6, brightness: 0.6, alpha: 1.0)
}

func coordsForMIDI(_ value: Int) -> SCNVector3 {
  let r: CGFloat = 40
  var x: CGFloat = 0
  var z: CGFloat = 0
  let h: CGFloat = 40
  var y = CGFloat(value) * h/4

  switch value % 4 {
  case 0:
    x = r
  case 1:
    z = r
  case 2:
    x = -r
  case 3:
    z = -r
  default:
    break
  }

  switch value % 3 {
  case 1:
    y += h
  case 2:
    y -= h
  default:
    break
  }

  return SCNVector3(x, y, z)
}

func torusCoordsForMIDI(_ value: Int) -> (SCNVector3, SCNVector3) {
  let bigR: Float = 60
  let littleR: Float = 20

  let v = Float(value)

  let theta = Float.pi * v / 2

  let y = bigR - littleR * cos(theta)
  let z = littleR * sin(theta)
  let baseVec = SCNVector4(0, y, z, 0)

  let phi = Float.pi * v * 5 / 6

  let zRotation = SCNMatrix4MakeRotation(phi, 0, 0, 1)
  let startCoord = baseVec.applyTransform(zRotation).to3()

  let center = SCNVector3Make(-bigR * sin(phi), bigR * cos(phi), 0)

  let relative = startCoord - center

  return (relative, center)
}

let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
sceneView.backgroundColor = .black

let scene = TonnetzScene()
sceneView.scene = scene
sceneView.allowsCameraControl = true

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView


