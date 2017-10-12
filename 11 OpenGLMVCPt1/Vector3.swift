//
//  Vector3.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import OpenGL.GL3


func ==(lhs: Vector3, rhs: Vector3) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
func *(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(v0: lhs.v0 * rhs.v0, v1: lhs.v1 * rhs.v1, v2: lhs.v2 * rhs.v2)
}
func *(lhs: Vector3, rhs: Float) -> Vector3 {
    return Vector3(v0: lhs.v0 * rhs, v1: lhs.v1 * rhs, v2: lhs.v2 * rhs)
}
func /(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(v0: lhs.v0 / rhs.v0, v1: lhs.v1 / rhs.v1, v2: lhs.v2 / rhs.v2)
}
func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(v0: lhs.v0 + rhs.v0, v1: lhs.v1 + rhs.v1, v2: lhs.v2 + rhs.v2)
}
func -(lhs: Vector3, rhs: Vector3) -> Vector3 {
    return Vector3(v0: lhs.v0 - rhs.v0, v1: lhs.v1 - rhs.v1, v2: lhs.v2 - rhs.v2)
}
struct Vector3: CustomStringConvertible, Hashable {
    
    var v0 = Float()
    var v1 = Float()
    var v2 = Float()
    
    init() {}
    
    init(v0: Float, v1: Float, v2: Float) {
        self.v0 = v0
        self.v1 = v1
        self.v2 = v2
    }
    
    var description: String { return "\(v0), \(v1), \(v2)" }
    var hashValue: Int { return description.hashValue }
    
    func normalize() -> Vector3 {
        let length = sqrt(v0 * v0 + v1 * v1 + v2 * v2)
        
        return Vector3(v0: self.v0 / length, v1: self.v1 / length, v2: self.v2 / length)
    }
    
}
