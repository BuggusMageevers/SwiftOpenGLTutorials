//
//  Misc.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation


struct Vertex: CustomStringConvertible {
    var x = GLfloat()
    var y = GLfloat()
    
    var r = GLfloat()
    var g = GLfloat()
    var b = GLfloat()
    
    var s = GLfloat()
    var t = GLfloat()
    
    var nx = GLfloat()
    var ny = GLfloat()
    var nz = GLfloat()
    
    var description: String {
        return "position: \(x), \(y)\ncolor: \(r), \(g), \(b)\ntexturePosition: \(s), \(t)\nnormal: \(nx), \(ny), \(nz)"
    }
}
func +(lhs: Vertex, rhs: Vertex) -> Vertex {
    return Vertex(x: lhs.x + rhs.x, y: lhs.y + rhs.y, r: lhs.r + rhs.r, g: lhs.g + rhs.g, b: lhs.b + rhs.b, s: lhs.s + rhs.s, t: lhs.t + rhs.t, nx: lhs.nx + rhs.nx, ny: lhs.ny + rhs.ny, nz: lhs.nz + rhs.nz)
}
func /(lhs: Vertex, rhs: GLfloat) -> Vertex {
    return Vertex(x: lhs.x / rhs, y: lhs.y / rhs, r: lhs.r / rhs, g: lhs.g / rhs, b: lhs.b / rhs, s: lhs.s / rhs, t: lhs.t / rhs, nx: lhs.nx / rhs, ny: lhs.ny / rhs, nz: lhs.nz / rhs)
}

func makeGasketFromTriangle(pointA: Vertex, pointB: Vertex, pointC: Vertex, atSubdivisionLevel subdivisionLevel: Int) -> [Vertex] {
    
    var points = [Vertex]()
    
    var pointAB = Vertex()
    var pointAC = Vertex()
    var pointBC = Vertex()
    
    if subdivisionLevel > 0 {
        pointAB = (pointA + pointB) / 2.0
        pointAC = (pointA + pointC) / 2.0
        pointBC = (pointB + pointC) / 2.0
        
        points += makeGasketFromTriangle(pointA: pointA, pointB: pointAB, pointC: pointAC, atSubdivisionLevel: subdivisionLevel - 1)
        points += makeGasketFromTriangle(pointA: pointC, pointB: pointAC, pointC: pointBC, atSubdivisionLevel: subdivisionLevel - 1)
        points += makeGasketFromTriangle(pointA: pointB, pointB: pointBC, pointC: pointAB, atSubdivisionLevel: subdivisionLevel - 1)
    } else {
        points += [pointA, pointB, pointC]
    }
    
    return points
}
