//
//  SceneKitAdditions.swift
//  Tonnetz
//
//  Created by Michael Burks on 3/30/19.
//  Copyright © 2019 Michael Burks. All rights reserved.
//

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

  static func * (left: CGFloat, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left * right.x, left * right.y, left * right.z)
  }

  static func * (left: SCNVector3, right: CGFloat) -> SCNVector3 {
    return right * left
  }

  static func + (left: CGFloat, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left + right.x, left + right.y, left + right.z)
  }

  static func + (left: SCNVector3, right: CGFloat) -> SCNVector3 {
    return right + left
  }
}
