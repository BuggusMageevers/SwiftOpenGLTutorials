//
//  VectorMath.swift
//  OpenGLMVCPt2c
//
//  Created by Myles Schultz on 1/12/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


struct Float2: Hashable, Equatable {
    let x: Float
    let y: Float
    
    init() {
        x = 0.0
        y = 0.0
    }
    init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
     var hashValue: Int {
        return (x.hashValue &+ y.hashValue) &* 65_537
    }
    
    static func ==(lhs: Float2, rhs: Float2) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: Float2, rhs: Float2) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    
    static func +(lhs: Float2, rhs: Float2) -> Float2 {
        return Float2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    static func -(lhs: Float2, rhs: Float2) -> Float2 {
        return Float2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func *(lhs: Float2, rhs: Float) -> Float2 {
        return Float2(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func *(lhs: Float, rhs: Float2) -> Float2 {
        return Float2(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    func dotProduct(_ vector: Float2) -> Float {
        return (x * vector.x) + (y * vector.y)
    }
    
    func lenght() -> Float {
        return sqrtf((x * x) + (y * y))
    }
}
extension Float2 {
    func move(_ direction: Float2, over time: Float) -> Float2 {
        return self + (direction * time)
    }
}

struct Float3: Hashable, Equatable {
    let x: Float
    let y: Float
    let z: Float
    
    init() {
        x = 0.0
        y = 0.0
        z = 0.0
    }
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    var hashValue: Int {
        return (x.hashValue &+ y.hashValue &+ z.hashValue) &* 65_537
    }
    
    static func ==(lhs: Float3, rhs: Float3) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: Float3, rhs: Float3) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    static func +(lhs: Float3, rhs: Float3) -> Float3 {
        return Float3(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    static func -(lhs: Float3, rhs: Float3) -> Float3 {
        return Float3(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    static func *(lhs: Float3, rhs: Float) -> Float3 {
        return Float3(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    static func *(lhs: Float, rhs: Float3) -> Float3 {
        return Float3(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
    }
    func dotProduct(_ vector: Float3) -> Float {
        return (x * vector.x) + (y * vector.y) + (z * vector.z)
    }
    func crossProduct(_ vector: Float3) -> Float3 {
        return Float3(x: (y * vector.z) - (z * vector.y), y: (z * vector.x) - (x * vector.z), z: (x * vector.y) - (y * vector.x))
    }
    
    func lenght() -> Float {
        return sqrtf((x * x) + (y * y) + (z * z))
    }
}
extension Float3 {
    func move(_ direction: Float3, over time: Float) -> Float3 {
        return self + (direction * time)
    }
}

struct Float4: Hashable, Equatable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float
    
    init() {
        x = 0.0
        y = 0.0
        z = 0.0
        w = 0.0
    }
    init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    var hashValue: Int {
        return (x.hashValue &+ y.hashValue &+ z.hashValue &+ w.hashValue) &* 65_537
    }
    
    static func ==(lhs: Float4, rhs: Float4) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: Float4, rhs: Float4) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    static func +(lhs: Float4, rhs: Float4) -> Float4 {
        return Float4(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z, w: lhs.w + rhs.w)
    }
    static func -(lhs: Float4, rhs: Float4) -> Float4 {
        return Float4(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z, w: lhs.w - rhs.w)
    }
    static func *(lhs: Float4, rhs: Float) -> Float4 {
        return Float4(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs, w: lhs.w * rhs)
    }
    static func *(lhs: Float, rhs: Float4) -> Float4 {
        return Float4(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z, w: lhs * rhs.w)
    }
    func dotProduct(_ vector: Float4) -> Float {
        return (x * vector.x) + (y * vector.y) + (z * vector.z) + (w * vector.w)
    }
    
    func lenght() -> Float {
        let normx = x / w
        let normy = y / w
        let normz = z / w
        
        return sqrtf((normx * normx) + (normy * normy) + (normz * normz))
    }
}
