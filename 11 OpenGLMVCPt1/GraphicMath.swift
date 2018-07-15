//
//  GraphicMath.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
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
        return (x.hashValue ^ y.hashValue) &* 65_537
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
        return (x.hashValue ^ y.hashValue ^ z.hashValue) &* 65_537
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
    mutating func move(_ direction: Float3, over time: Float, at speed: Float) {
        self = self + (direction * time * speed)
    }
    func formTranlation() -> FloatMatrix4 {
        return FloatMatrix4().translate(x: self.x, y: self.y, z: self.z)
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
        return (x.hashValue ^ y.hashValue ^ z.hashValue ^ w.hashValue) &* 65_537
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

struct FloatMatrix2: Hashable, Equatable {
    let vector1: Float2
    let vector2: Float2
    
    var hashValue: Int {
        return (vector1.hashValue ^ vector2.hashValue) &* 65_537
    }
    
    init() {
        vector1 = Float2(x: 1.0, y: 0.0)
        vector2 = Float2(x: 0.0, y: 1.0)
    }
    init(vector1: Float2, vector2: Float2) {
        self.vector1 = vector1
        self.vector2 = vector2
    }
    
    func transpose() -> FloatMatrix2 {
        return FloatMatrix2(vector1: Float2(x: vector1.x, y: vector2.x), vector2: Float2(x: vector1.y, y: vector2.y))
    }
    func determinant() -> Float {
        return (vector1.x * vector2.y) - (vector1.y * vector2.x)
    }
    func inverse() -> FloatMatrix2 {
        return FloatMatrix2(vector1: Float2(x: vector2.y / determinant(), y: -vector1.y / determinant()),
                            vector2: Float2(x: -vector2.x / determinant(), y: vector1.x / determinant()))
    }
    
    static func ==(lhs: FloatMatrix2, rhs: FloatMatrix2) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: FloatMatrix2, rhs: FloatMatrix2) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    static func +(lhs: FloatMatrix2, rhs: FloatMatrix2) -> FloatMatrix2 {
        return FloatMatrix2(vector1: lhs.vector1 + rhs.vector1, vector2: lhs.vector2 + rhs.vector2)
    }
    static func -(lhs: FloatMatrix2, rhs: FloatMatrix2) -> FloatMatrix2 {
        return FloatMatrix2(vector1: lhs.vector1 - rhs.vector1, vector2: lhs.vector2 - rhs.vector2)
    }
    static func *(lhs: FloatMatrix2, rhs: Float) -> FloatMatrix2 {
        return FloatMatrix2(vector1: lhs.vector1 * rhs, vector2: lhs.vector2 * rhs)
    }
    static func *(lhs: Float, rhs: FloatMatrix2) -> FloatMatrix2 {
        return FloatMatrix2(vector1: lhs * rhs.vector1, vector2: lhs * rhs.vector2)
    }
    static func *(lhs: FloatMatrix2, rhs: FloatMatrix2) -> FloatMatrix2 {
        let transpose = rhs.transpose()
        return FloatMatrix2(vector1: Float2(x: lhs.vector1.dotProduct(transpose.vector1), y: lhs.vector1.dotProduct(transpose.vector2)),
                            vector2: Float2(x: lhs.vector2.dotProduct(transpose.vector1), y: lhs.vector2.dotProduct(transpose.vector2)))
    }
    static func /(lhs: FloatMatrix2, rhs: FloatMatrix2) -> FloatMatrix2 {
        return lhs * rhs.inverse()
    }
}
struct FloatMatrix3: Hashable, Equatable {
    let vector1: Float3
    let vector2: Float3
    let vector3: Float3
    
    var hashValue: Int {
        return (vector1.hashValue ^ vector2.hashValue ^ vector3.hashValue) &* 65_537
    }
    
    init() {
        vector1 = Float3(x: 1.0, y: 0.0, z: 0.0)
        vector2 = Float3(x: 0.0, y: 1.0, z: 0.0)
        vector3 = Float3(x: 0.0, y: 0.0, z: 1.0)
    }
    init(vector1: Float3, vector2: Float3, vector3: Float3) {
        self.vector1 = vector1
        self.vector2 = vector2
        self.vector3 = vector3
    }
    
    func transpose() -> FloatMatrix3 {
        return FloatMatrix3(vector1: Float3(x: vector1.x, y: vector2.x, z: vector3.x),
                            vector2: Float3(x: vector1.y, y: vector2.y, z: vector3.y),
                            vector3: Float3(x: vector1.z, y: vector2.z, z: vector3.z))
    }
    func cofactors() -> FloatMatrix3 {
        return FloatMatrix3(vector1: Float3(x: vector1.x, y: -(vector1.y), z: vector1.z),
                            vector2: Float3(x: -(vector2.x), y: vector2.y, z: -(vector2.z)),
                            vector3: Float3(x: vector3.x, y: -(vector3.y), z: vector3.z))
    }
    func inverse() -> FloatMatrix3 {
        let minors = FloatMatrix3(vector1: Float3(x: vector2.y * vector3.z - vector2.z * vector3.y, y: vector2.x * vector3.z - vector2.z * vector3.x, z: vector2.x * vector3.y - vector2.y * vector3.x),
                                  vector2: Float3(x: vector1.y * vector3.z - vector1.z * vector3.y, y: vector1.x * vector3.z - vector1.z * vector3.x, z: vector1.x * vector3.y - vector1.y * vector3.x),
                                  vector3: Float3(x: vector1.y * vector2.z - vector1.z * vector2.y, y: vector1.x * vector2.z - vector1.z * vector2.x, z: vector1.x * vector2.y - vector1.y * vector2.x))
        let adjugate = minors.cofactors().transpose()
        let inverseDeterminant = 1 / (vector1.x * minors.vector1.x - vector1.y * minors.vector1.y + vector1.z * minors.vector1.z)
        return adjugate * inverseDeterminant
    }
    
    static func ==(lhs: FloatMatrix3, rhs: FloatMatrix3) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: FloatMatrix3, rhs: FloatMatrix3) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    static func +(lhs: FloatMatrix3, rhs: FloatMatrix3) -> FloatMatrix3 {
        return FloatMatrix3(vector1: lhs.vector1 + rhs.vector1, vector2: lhs.vector2 + rhs.vector2, vector3: lhs.vector3 + rhs.vector3)
    }
    static func -(lhs: FloatMatrix3, rhs: FloatMatrix3) -> FloatMatrix3 {
        return FloatMatrix3(vector1: lhs.vector1 - rhs.vector1, vector2: lhs.vector2 - rhs.vector2, vector3: lhs.vector3 - rhs.vector3)
    }
    static func *(lhs: FloatMatrix3, rhs: Float) -> FloatMatrix3 {
        return FloatMatrix3(vector1: lhs.vector1 * rhs, vector2: lhs.vector2 * rhs, vector3: lhs.vector3 * rhs)
    }
    static func *(lhs: Float, rhs: FloatMatrix3) -> FloatMatrix3 {
        return FloatMatrix3(vector1: lhs * rhs.vector1, vector2: lhs * rhs.vector2, vector3: lhs * rhs.vector3)
    }
    static func *(lhs: FloatMatrix3, rhs: FloatMatrix3) -> FloatMatrix3 {
        let transpose = rhs.transpose()
        return FloatMatrix3(vector1: Float3(x: lhs.vector1.dotProduct(transpose.vector1), y: lhs.vector1.dotProduct(transpose.vector2), z: lhs.vector1.dotProduct(transpose.vector3)),
                            vector2: Float3(x: lhs.vector2.dotProduct(transpose.vector1), y: lhs.vector2.dotProduct(transpose.vector2), z: lhs.vector2.dotProduct(transpose.vector3)),
                            vector3: Float3(x: lhs.vector3.dotProduct(transpose.vector1), y: lhs.vector3.dotProduct(transpose.vector3), z: lhs.vector3.dotProduct(transpose.vector3)))
    }
    static func /(lhs: FloatMatrix3, rhs: FloatMatrix3) -> FloatMatrix3 {
        return lhs * rhs.inverse()
    }
}
struct FloatMatrix4: Hashable, Equatable {
    typealias StringLiteralType = String
    
    let vector1: Float4
    let vector2: Float4
    let vector3: Float4
    let vector4: Float4
    
    var hashValue: Int {
        return (vector1.hashValue ^ vector2.hashValue ^ vector3.hashValue ^ vector4.hashValue) &* 65_537
    }
    
    init() {
        vector1 = Float4(x: 1.0, y: 0.0, z: 0.0, w: 0.0)
        vector2 = Float4(x: 0.0, y: 1.0, z: 0.0, w: 0.0)
        vector3 = Float4(x: 0.0, y: 0.0, z: 1.0, w: 0.0)
        vector4 = Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
    }
    init(vector1: Float4, vector2: Float4, vector3: Float4, vector4: Float4) {
        self.vector1 = vector1
        self.vector2 = vector2
        self.vector3 = vector3
        self.vector4 = vector4
    }
    
    func transpose() -> FloatMatrix4 {
        return FloatMatrix4(vector1: Float4(x: vector1.x, y: vector2.x, z: vector3.x, w: vector4.x),
                            vector2: Float4(x: vector1.y, y: vector2.y, z: vector3.y, w: vector4.y),
                            vector3: Float4(x: vector1.z, y: vector2.z, z: vector3.z, w: vector4.z),
                            vector4: Float4(x: vector1.w, y: vector2.w, z: vector3.w, w: vector4.w))
    }
    func cofactors() -> FloatMatrix4 {
        return FloatMatrix4(vector1: Float4(x: vector1.x, y: -(vector1.y), z: vector1.z, w: -(vector1.w)),
                            vector2: Float4(x: -(vector2.x), y: vector2.y, z: -(vector2.z), w: vector2.w),
                            vector3: Float4(x: vector3.x, y: -(vector3.y), z: vector3.z, w: -(vector3.w)),
                            vector4: Float4(x: -(vector4.x), y: vector4.y, z: -(vector4.z), w: vector4.w))
    }
    func inverse() -> FloatMatrix4 {
        let a = (vector3.z * vector4.w - vector3.w * vector4.z)
        let b = (vector3.y * vector4.w - vector3.w * vector4.y)
        let c = (vector3.y * vector4.z - vector3.z * vector4.y)
        let d = (vector3.x * vector4.w - vector3.w * vector4.x)
        let e = (vector3.x * vector4.z - vector3.z * vector4.x)
        let f = (vector3.x * vector4.y - vector3.y * vector4.x)
        let g = (vector2.z * vector4.w - vector2.w * vector4.z)
        let h = (vector2.y * vector4.w - vector2.w * vector4.y)
        let i = (vector2.y * vector4.z - vector2.z * vector4.y)
        let j = (vector2.x * vector4.w - vector2.w * vector4.x)
        let k = (vector2.x * vector4.z - vector2.z * vector4.x)
        let l = (vector2.x * vector4.y - vector2.y * vector4.x)
        let m = (vector2.z * vector3.w - vector2.w * vector3.z)
        let n = (vector2.y * vector3.w - vector2.w * vector3.y)
        let o = (vector2.y * vector3.z - vector2.z * vector3.y)
        let p = (vector2.x * vector3.w - vector2.w * vector3.x)
        let q = (vector2.x * vector3.z - vector2.z * vector3.x)
        let r = (vector2.x * vector3.y - vector2.y * vector3.x)
        
        let minors = FloatMatrix4(vector1: Float4(x: vector2.y * a - vector2.z * b + vector2.w * c, y: vector2.x * a - vector2.z * d + vector2.w * e, z: vector2.x * b - vector2.y * d + vector2.w * f, w: vector2.x * c - vector2.y * e + vector2.z * f),
                                  vector2: Float4(x: vector1.y * a - vector1.z * b + vector1.w * c, y: vector1.x * a - vector1.z * d + vector1.w * e, z: vector1.x * b - vector1.y * d + vector1.w * f, w: vector1.x * c - vector1.y * e + vector1.z * f),
                                  vector3: Float4(x: vector1.y * g - vector1.z * h + vector1.w * i, y: vector1.x * g - vector1.z * j + vector1.w * k, z: vector1.x * h - vector1.y * j + vector1.w * l, w: vector1.x * i - vector1.y * k + vector1.z * l),
                                  vector4: Float4(x: vector1.y * m - vector1.z * n + vector1.w * o, y: vector1.x * m - vector1.z * p + vector1.w * q, z: vector1.x * n - vector1.y * p + vector1.w * r, w: vector1.x * o - vector1.y * q + vector1.z * r))
        
        let adjugate = minors.cofactors().transpose()
        let inverseDeterminant = 1 / (vector1.x * minors.vector1.x - vector1.y * minors.vector1.y + vector1.z * minors.vector1.z - vector1.w * minors.vector1.w)
        return adjugate * inverseDeterminant
    }
    
    static func ==(lhs: FloatMatrix4, rhs: FloatMatrix4) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: FloatMatrix4, rhs: FloatMatrix4) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
    static func +(lhs: FloatMatrix4, rhs: FloatMatrix4) -> FloatMatrix4 {
        return FloatMatrix4(vector1: lhs.vector1 + rhs.vector1, vector2: lhs.vector2 + rhs.vector2, vector3: lhs.vector3 + rhs.vector3, vector4: lhs.vector4 + rhs.vector4)
    }
    static func -(lhs: FloatMatrix4, rhs: FloatMatrix4) -> FloatMatrix4 {
        return FloatMatrix4(vector1: lhs.vector1 - rhs.vector1, vector2: lhs.vector2 - rhs.vector2, vector3: lhs.vector3 - rhs.vector3, vector4: lhs.vector4 - rhs.vector4)
    }
    static func *(lhs: FloatMatrix4, rhs: Float) -> FloatMatrix4 {
        return FloatMatrix4(vector1: lhs.vector1 * rhs, vector2: lhs.vector2 * rhs, vector3: lhs.vector3 * rhs, vector4: lhs.vector4 * rhs)
    }
    static func *(lhs: Float, rhs: FloatMatrix4) -> FloatMatrix4 {
        return FloatMatrix4(vector1: lhs * rhs.vector1, vector2: lhs * rhs.vector2, vector3: lhs * rhs.vector3, vector4: lhs * rhs.vector4)
    }
    static func *(lhs: FloatMatrix4, rhs: FloatMatrix4) -> FloatMatrix4 {
        let transpose = rhs.transpose()
        return FloatMatrix4(vector1: Float4(x: lhs.vector1.dotProduct(transpose.vector1), y: lhs.vector1.dotProduct(transpose.vector2), z: lhs.vector1.dotProduct(transpose.vector3), w: lhs.vector1.dotProduct(transpose.vector4)),
                            vector2: Float4(x: lhs.vector2.dotProduct(transpose.vector1), y: lhs.vector2.dotProduct(transpose.vector2), z: lhs.vector2.dotProduct(transpose.vector3), w: lhs.vector2.dotProduct(transpose.vector4)),
                            vector3: Float4(x: lhs.vector3.dotProduct(transpose.vector1), y: lhs.vector3.dotProduct(transpose.vector2), z: lhs.vector3.dotProduct(transpose.vector3), w: lhs.vector3.dotProduct(transpose.vector4)),
                            vector4: Float4(x: lhs.vector4.dotProduct(transpose.vector1), y: lhs.vector4.dotProduct(transpose.vector2), z: lhs.vector4.dotProduct(transpose.vector3), w: lhs.vector4.dotProduct(transpose.vector4)))
    }
    static func /(lhs: FloatMatrix4, rhs: FloatMatrix4) -> FloatMatrix4 {
        return lhs * rhs.inverse()
    }
    
    func rowMajorArray() -> [Float] {
        return [vector1.x, vector1.y, vector1.z, vector1.w,
                vector2.x, vector2.y, vector2.z, vector2.w,
                vector3.x, vector3.y, vector3.z, vector3.w,
                vector4.x, vector4.y, vector4.z, vector4.w]
    }
    func columnMajorArray() -> [Float] {
        return [vector1.x, vector2.x, vector3.x, vector4.x,
                vector1.y, vector2.y, vector3.y, vector4.y,
                vector1.z, vector2.z, vector3.z, vector4.z,
                vector1.w, vector2.w, vector3.w, vector4.w]
    }
    
    static func projection(angeOfView theta: Float = 35, aspect: Float, distanceToNearClippingPlane nearZ: Float = 0.1, distanceToFarClippingPlane farZ: Float = 1000) -> FloatMatrix4 {
        let scale = 1 / tanf(theta * 0.5 * Float.pi / 180)
        return FloatMatrix4(vector1: Float4(x: scale / aspect, y: 0.0, z: 0.0, w: 0.0),
                            vector2: Float4(x: 0.0, y: scale, z: 0.0, w: 0.0),
                            vector3: Float4(x: 0.0, y: 0.0, z: (farZ + nearZ) / (nearZ - farZ), w: (2 * farZ * nearZ) / (nearZ - farZ)),
                            vector4: Float4(x: 0.0, y: 0.0, z: -1.0, w: 0.0))
    }
    static func orthographic(width: Float, height: Float, nearZ: Float = 0.001, farZ: Float = 1000) -> FloatMatrix4 {
        let right = width * 0.5
        let left = -right
        let top = height * 0.5
        let bottom = -top
        return FloatMatrix4(vector1: Float4(x: 2 / (right - left), y: 0.0, z: 0.0, w: -((right + left) / (right - left))),
                            vector2: Float4(x: 0.0, y: 2 / (top - bottom), z: 0.0, w: -((top + bottom) / (top - bottom))),
                            vector3: Float4(x: 0.0, y: 0.0, z: -2 / (farZ - nearZ), w: -(farZ + nearZ) / (farZ - nearZ)),
                            vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    
    func translate(x: Float, y: Float, z: Float) -> FloatMatrix4 {
        return self * FloatMatrix4(vector1: Float4(x: 1.0, y: 0.0, z: 0.0, w: x),
                                   vector2: Float4(x: 0.0, y: 1.0, z: 0.0, w: y),
                                   vector3: Float4(x: 0.0, y: 0.0, z: 1.0, w: z),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    static func translate(to position: Float3) -> FloatMatrix4 {
        return FloatMatrix4(vector1: Float4(x: 1.0, y: 0.0, z: 0.0, w: position.x),
                            vector2: Float4(x: 0.0, y: 1.0, z: 0.0, w: position.y),
                            vector3: Float4(x: 0.0, y: 0.0, z: 1.0, w: position.z),
                            vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    
    func rotateXAxis(_ radians: Float) -> FloatMatrix4 {
        return self * FloatMatrix4(vector1: Float4(x: 1.0, y: 0.0, z: 0.0, w: 0.0),
                                   vector2: Float4(x: 0.0, y: cos(radians), z: -sin(radians), w: 0.0),
                                   vector3: Float4(x: 0.0, y: sin(radians), z: cos(radians), w: 0.0),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    func rotateYAxis(_ radians: Float) -> FloatMatrix4 {
        return self * FloatMatrix4(vector1: Float4(x: cos(radians), y: 0.0, z: sin(radians), w: 0.0),
                                   vector2: Float4(x: 0.0, y: 1.0, z: 0.0, w: 0.0),
                                   vector3: Float4(x: -sin(radians), y: 0.0, z: cos(radians), w: 0.0),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    func rotateZAxis(_ radians: Float) -> FloatMatrix4 {
        return self * FloatMatrix4(vector1: Float4(x: cos(radians), y: -sin(radians), z: 0.0, w: 0.0),
                                   vector2: Float4(x: sin(radians), y: cos(radians), z: 0.0, w: 0.0),
                                   vector3: Float4(x: 0.0, y: 0.0, z: 1.0, w: 0.0),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    func rotate(_ angle: Float, along axis: Float3) -> FloatMatrix4 {
        let cosine = cos(angle)
        let inverseCosine = 1.0 - cosine
        let sine = sin(angle)
        
        return self * FloatMatrix4(vector1: Float4(x: cosine + inverseCosine * axis.x * axis.x, y: inverseCosine * axis.x * axis.y + axis.z * sine, z: inverseCosine * axis.x * axis.z - axis.y * sine, w: 0.0),
                                   vector2: Float4(x: inverseCosine * axis.x * axis.y - axis.z * sine, y: cosine + inverseCosine * axis.y * axis.y, z: inverseCosine * axis.y * axis.z + axis.x * sine, w: 0.0),
                                   vector3: Float4(x: inverseCosine * axis.x * axis.z + axis.y * sine, y: inverseCosine * axis.y * axis.z - axis.x * sine, z: cosine + inverseCosine * axis.z * axis.z, w: 0.0),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    func scale(x: Float, y: Float, z: Float) -> FloatMatrix4 {
        return self * FloatMatrix4(vector1: Float4(x: x, y: 0.0, z: 0.0, w: 0.0),
                                   vector2: Float4(x: 0.0, y: y, z: 0.0, w: 0.0),
                                   vector3: Float4(x: 0.0, y: 0.0, z: z, w: 0.0),
                                   vector4: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
    }
    func uniformScale(by value: Float) -> FloatMatrix4 {
        return self.scale(x: value, y: value, z: value)
    }
}
