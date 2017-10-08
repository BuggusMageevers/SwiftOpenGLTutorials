//
//  SwiftCamera.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 11/6/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation

struct SwiftCamera {
    
    enum KeyCodeName: UInt16 {
        case forward = 13   // W
        case backward = 1   // S
        case left = 0       // A
        case right = 2      // D
    }
    var directionKeys: [KeyCodeName: Bool] = [ .forward : false, .backward : false, .left : false, .right : false ]
    var cameraPosition = Vector3(v0: 0.0, v1: 0.0, v2: -5.0)
    var cameraOrientation = Vector3(v0: 0.0, v1: 0.0, v2: 0.0)
    var cameraOffset = Vector3(v0: 0.0, v1: 0.0, v2: 0.0)
    
    mutating func updateViewMatrix(forTime time: CFTimeInterval) -> Matrix4 {
        //  We can use deltaTime now instead of previousTime
        let amplitude = 10 * Float(time)
        
        //  Find new position
        let directionX = (sin(cameraOrientation.v1) * cos(cameraOrientation.v2))
        //  Moving off of the Y = 0 plane is as easy as adding the y values (instead of multiplying) them together,
        //    otherwise looking up while moving forward does not affect the elevation of the viewer.  Give it a try.
        //  In order to get the camera to pitch up when you look up, negate the y value
        let directionY = -(sin(cameraOrientation.v0) + sin(cameraOrientation.v2))
        let directionZ = (cos(cameraOrientation.v0) * cos(cameraOrientation.v1))
        
        //  Create a vector, normalize it, and apply the amplitude value
        let displacement = Vector3(v0: directionX, v1: directionY, v2: directionZ).normalize() * amplitude
        
        //  For strafing, calculate the vector perpendicular to the current forward and up vectors by rotating
        //    the normalized X vector (1.0, 0.0, 0.0) according to current orientation, then re-normalize
        //    before applying the amplitude value
        let rightVector = Matrix4().rotateAlongXAxis(radians: cameraOrientation.v0).rotateAlongYAxis(radians: cameraOrientation.v1).inverse() * Vector3(v0: 1.0, v1: 0.0, v2: 0.0)
        
        let strafe = rightVector.normalize() * amplitude
        
        for direction in directionKeys {
            switch direction {
            case (KeyCodeName.forward, true):
                cameraPosition = Vector3(v0: cameraPosition.v0 + displacement.v0, v1: cameraPosition.v1 + displacement.v1, v2: cameraPosition.v2 + displacement.v2)
            case (KeyCodeName.backward, true):
                cameraPosition = Vector3(v0: cameraPosition.v0 + (-displacement.v0), v1: cameraPosition.v1 + (-displacement.v1), v2: cameraPosition.v2 + (-displacement.v2))
            case (KeyCodeName.left, true):
                cameraPosition = Vector3(v0: cameraPosition.v0 + strafe.v0, v1: cameraPosition.v1 + strafe.v1, v2: cameraPosition.v2 + strafe.v2)
            case (KeyCodeName.right, true):
                //  Strafing to the right is done with a negative strafe vector
                cameraPosition = Vector3(v0: cameraPosition.v0 + -strafe.v0, v1: cameraPosition.v1 + -strafe.v1, v2: cameraPosition.v2 + -strafe.v2)
            case (_, false):
                //  Covers the over possible cases so we don't have to define a default case
                break
            }
        }
        
        return Matrix4().rotateAlongXAxis(radians: cameraOrientation.v0).rotateAlongYAxis(radians: cameraOrientation.v1).translate(x: cameraPosition.v0, y: cameraPosition.v1, z: cameraPosition.v2)
        
    }
    
    mutating func rotateCamera(pitch xRotation: Float, yaw yRotation: Float) {
        
        let xRadians = cameraOrientation.v0 + -xRotation * Float.pi / 180
        
        if 0 <= xRadians || xRadians <= Float(M_2_PI) {
            cameraOrientation.v0 = xRadians
        } else if xRadians > Float(M_2_PI) {
            cameraOrientation.v0 = xRadians - Float(M_2_PI)
        } else {
            cameraOrientation.v0 = xRadians + Float(M_2_PI)
        }
        
        let yRadians = cameraOrientation.v1 + -yRotation * Float.pi / 180
        
        if 0 <= yRadians || yRadians <= Float(M_2_PI) {
            cameraOrientation.v1 = yRadians
        } else if yRadians > Float(M_2_PI) {
            cameraOrientation.v1 = yRadians - Float(M_2_PI)
        } else {
            cameraOrientation.v1 = yRadians + Float(M_2_PI)
        }
        
    }
    
}
