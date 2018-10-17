//
//  GraphicView.swift
//  OpenGLDemo
//
//  Created by Myles Schultz on 6/9/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3


/// Here are two `Vertex` type definitions.  `Vertex` is meant as the most base
/// definition of a 3 dimensional vertex:  having a point in space, a normal
/// for lighting, and a color.  `TexVertex` assumes that the user wants to color
/// the surface of a polygon with textures.  The addition of a solid color to
/// `TexVertex` may also be considered and would have a ZBrush material-like
/// effect (white results in the texture being true to color, other colors would
/// colorize the model, and black removes color).
struct Vertex {
    let position: Float3
    let normal: Float3
    let color: Float4
}
struct TexVertex {
    let position: Float3
    let normal: Float3
    let coordinate: Float2
}
/// 3D space direction definitions:
/// X: Left => negative, Right => positive
/// Y: Down => negative, Up => positive
/// Z: Into screen => negative, Out of screen => positive
let triangle = [
    /*Front*/
    Vertex(position: Float3(x: -0.5, y: -0.5, z:  0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y: -0.5, z:  0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z:  0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*FAngle*/
    Vertex(position: Float3(x:  0.5, y: -0.5, z:  0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z:  0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*Top*/
    Vertex(position: Float3(x:  0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z:  0.5), normal: (Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*Left*/
    Vertex(position: Float3(x: -0.5, y:  0.5, z: -0.5), normal: (Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y: -0.5, z:  0.5), normal: (Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z:  0.5), normal: (Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x: -0.5, y:  0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*BAngle*/
    Vertex(position: Float3(x: -0.5, y: -0.5, z:  0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z: -0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y: -0.5, z: -0.5), normal: (Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x: -0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*Bottom*/
    Vertex(position: Float3(x:  0.5, y: -0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y: -0.5, z:  0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y: -0.5, z:  0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y: -0.5, z:  0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y: -0.5, z:  0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*Right*/
    Vertex(position: Float3(x:  0.5, y: -0.5, z:  0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y: -0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y: -0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z:  0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    /*Back*/
    Vertex(position: Float3(x:  0.5, y: -0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x: -0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)),
    Vertex(position: Float3(x:  0.5, y:  0.5, z: -0.5), normal: (Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x: -0.5, y:  0.5, z: -0.5)).crossProduct(Float3(x:  0.5, y: -0.5, z: -0.5) - Float3(x:  0.5, y:  0.5, z: -0.5)), color: Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0))
]
let origins: [Float3] = [
    Float3(x: light.position[0], y: light.position[1], z: light.position[2])
]
let floor = [
    TexVertex(position: Float3(x: -1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 1.0)),
    TexVertex(position: Float3(x: -1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 0.0)),
    TexVertex(position: Float3(x:  1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 0.0)),
    
    TexVertex(position: Float3(x:  1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 1.0)),
    TexVertex(position: Float3(x: -1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 1.0)),
    TexVertex(position: Float3(x:  1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 0.0))
]
//  Draw a "circular" floor to roate for showcasing different objects and lighting schemes
extension Float3 {
    func unitVector() -> Float3 {
        let magnitude = self.lenght()
        if magnitude == 0 {
            return Float3(x: 0.0, y: 0.0, z: 0.0)
        }
        return Float3(x: self.x / magnitude, y: self.y / magnitude, z: self.z / magnitude)
    }
    static func *(lhs: Float3, rhs: Float3) -> Float3 {
        return (lhs.y * rhs.z - lhs.z * rhs.y) * Float3(x: 1.0, y: 0.0, z: 0.0) + (lhs.z * rhs.x - lhs.x * rhs.z) * Float3(x: 0.0, y: 1.0, z: 0.0) + (lhs.x * rhs.y - lhs.y * rhs.x) * Float3(x:0.0, y: 0.0, z: 1.0)
    }
}
extension FloatMatrix2 {
    static public func *(lhs: Float2, rhs: FloatMatrix2) -> Float2 {
        return Float2(x: lhs.x * rhs.vector1.x + lhs.y * rhs.vector2.x, y: lhs.x * rhs.vector1.y + lhs.y * rhs.vector2.y)
    }
    static public func *(lhs: FloatMatrix2, rhs: Float2) -> Float2 {
        return Float2(x: lhs.vector1.x * rhs.x + lhs.vector2.x * rhs.y, y: lhs.vector1.y * rhs.x + lhs.vector2.y * rhs.y)
    }
    public func affineClockwiseRotate(_ radians: Float) -> FloatMatrix2 {
        return self * FloatMatrix2(vector1: Float2(x: cos(radians), y: -sin(radians)), vector2: Float2(x: sin(radians), y: cos(radians)))
    }
}
func planarMesh(withSides sides: Int, radius: Float, thickness: Float) -> ([UInt32], [TexVertex]) {
    let turnRadians = 2 * Float.pi / Float(sides)
    var rotationMatrix = FloatMatrix2()
    var points: [Float2] = []
    var counter: Int = 0
    while counter <= sides - 1 {
        let pointA = rotationMatrix * Float2(x: 0.0, y: radius - thickness)
        let pointB = rotationMatrix * Float2(x: 0.0, y: radius)
        points.append(pointA)
        points.append(pointB)
        rotationMatrix = rotationMatrix.affineClockwiseRotate(turnRadians)
        counter += 1
    }
    
    var indices: [Int] = []
    counter = 0
    while counter < (sides * 2) - 2 {
        indices += [counter, counter + 1, counter + 2, counter + 3]
        counter += 2
    }
    indices += [counter, counter + 1, counter + 2 - sides * 2, counter + 3 - sides * 2]
    
    var vertices: [TexVertex] = []
    counter = 0
    var zeroCoord = true
    while counter < (2 * sides) - 2 {
        let normalA = Float3(x: (points[counter] - points[counter + 1]).x, y: 0.0, z: (points[counter] - points[counter + 1]).y).crossProduct(Float3(x: (points[counter] - points[counter + 3]).x, y: 0.0, z: (points[counter] - points[counter + 3]).y)).unitVector()
        let normalB = Float3(x: (points[counter] - points[counter + 3]).x, y: 0.0, z: (points[counter] - points[counter + 3]).y).crossProduct(Float3(x: (points[counter] - points[counter + 2]).x, y: 0.0, z: (points[counter] - points[counter + 2]).y)).unitVector()
        let xCoord: Float = zeroCoord ? 0.0 : 1.0
        vertices += [
            TexVertex(position: Float3(x: points[counter].x, y: 0.0, z: points[counter].y), normal: normalA, coordinate: Float2(x: xCoord, y: 0.0)),
            TexVertex(position: Float3(x: points[counter + 1].x, y: 0.0, z: points[counter + 1].y), normal: normalB, coordinate: Float2(x: xCoord, y: 1.0))
        ]
        counter += 2
        zeroCoord = !zeroCoord
    }
    let normalA = Float3(x: (points[counter] - points[counter + 1]).x, y: 0.0, z: (points[counter] - points[counter + 1]).y).crossProduct(Float3(x: (points[counter] - points[counter + 3 - (sides * 2)]).x, y: 0.0, z: (points[counter] - points[counter + 3 - (sides * 2)]).y)).unitVector()
    let normalB = Float3(x: (points[counter] - points[counter + 3 - (sides * 2)]).x, y: 0.0, z: (points[counter] - points[counter + 3 - (sides * 2)]).y).crossProduct(Float3(x: (points[counter] - points[counter + 2 - (sides * 2)]).x, y: 0.0, z: (points[counter] - points[counter + 2 - (sides * 2)]).y)).unitVector()
    let xCoord: Float = zeroCoord ? 0.0 : 1.0
    vertices += [
        TexVertex(position: Float3(x: points[counter].x, y: 0.0, z: points[counter].y), normal: normalA, coordinate: Float2(x: xCoord, y: 0.0)),
        TexVertex(position: Float3(x: points[counter + 1].x, y: 0.0, z: points[counter + 1].y), normal: normalB, coordinate: Float2(x: xCoord, y: 1.0))
    ]
    
    let unsignedIndices = indices.map(){ UInt32($0) }
    
    return (unsignedIndices, vertices)
}
func sphereMesh(withRadius radius: Float, longitudinalCuts longCuts: Int, latitudinalCuts latCuts: Int) -> ([UInt32], [Vertex]) {
    if longCuts >= 3 && latCuts >= 1 {
        let longCutLength = Float.pi / Float(latCuts + 1)
        let latCutLength = (2 * Float.pi) / Float(longCuts)
        
        func arc(segments: Int, segmentSize size: Float) -> [Float] {
            return segments == 1 ? [size] : arc(segments: segments - 1, segmentSize: size) + [size * Float(segments)]
        }
        
        let longSegments = arc(segments: latCuts, segmentSize: longCutLength)
//        print("longitudinal segments: \(longSegments.count), \(longSegments)")
        let latSegments = arc(segments: longCuts, segmentSize: latCutLength)
//        print("latitudinal segments: \(latSegments.count), \(latSegments)")
        
        func unitCircle2DPoints(fromArcs arcs: [Float]) -> [Float2] {
            return arcs.count == 1 ? [Float2(x: cos(arcs[0]), y: sin(arcs[0]))] : unitCircle2DPoints(fromArcs: Array(arcs.dropFirst())) + [Float2(x: cos(arcs[0]), y: sin(arcs[0]))]
        }
        
        let latUnitCircle2DPoints = unitCircle2DPoints(fromArcs: latSegments)
        
        func makeSliceRadii(atIntervals intervals: [Float], forSphere radius: Float) -> [Float] {
            let sliceRadius = sin(intervals[0] / radius)
            return intervals.count == 1 ? [sliceRadius] : [sliceRadius] + makeSliceRadii(atIntervals: Array(intervals.dropFirst()), forSphere: radius)
        }
        
        let latCircleRadii = makeSliceRadii(atIntervals: longSegments, forSphere: radius)
//        print("Radii: \(latCircleRadii.count), \(latCircleRadii)")
        
        func slices(withRadii radii: [Float], toUnitCircle unitCircle: [Float2]) -> [[Float2]] {
            let slice = unitCircle.map(){ $0 * radii[0] }
            return radii.count == 1 ? [slice] : [slice] + slices(withRadii: Array(radii.dropFirst()), toUnitCircle: unitCircle)
        }
        
        let sphereSlices = slices(withRadii: latCircleRadii, toUnitCircle: latUnitCircle2DPoints)
        
        func makeSliceHeights(atIntervals intervals: [Float], intervalRadii radii: [Float], forSphere radius: Float) -> [Float] {
            let angleInRadians = (Float.pi - intervals[0] / radius) / 2
            let sliceHeight = radii[0] / tan(angleInRadians)
            let yDisplacement = radius - sliceHeight
//            print("acrLength: \(intervals[0]), radius: \(radius), slice radius: \(radii[0]), angle at origin: \(angleInRadians), slice height: \(sliceHeight), y value: \(yDisplacement)")
            return intervals.count == 1 ? [yDisplacement] : [yDisplacement] + makeSliceHeights(atIntervals: Array(intervals.dropFirst()), intervalRadii: Array(radii.dropFirst()), forSphere: radius)
        }
        
        let sliceHeights = makeSliceHeights(atIntervals: longSegments, intervalRadii: latCircleRadii, forSphere: radius)
//        print("slice heights: \(sliceHeights)")
        
        func pointsOnSphere(fromSlices slices: [[Float2]], atIntervals intervals: [Float]) -> [Float3] {
            let pointsOnSlice = slices[0].map(){ Float3(x: $0.x, y: intervals[0], z: $0.y)}
            return slices.count == 1 ? pointsOnSlice : pointsOnSlice + pointsOnSphere(fromSlices: Array(slices.dropFirst()), atIntervals: Array(intervals.dropFirst()))
        }
        
        let spherePoints = [Float3(x: 0.0, y: radius, z: 0.0)] + pointsOnSphere(fromSlices: sphereSlices, atIntervals: sliceHeights) + [Float3(x: 0.0, y: -radius, z: 0.0)]
        
        func sphereIndices(fromLongitudinalCuts longitudinalCuts: Int, latitudinalCuts: Int) -> [Int] {
            typealias TriangleSpin = ((Int, Int, Int)) -> [Int]
            typealias QuadrilateralSpin = ((Int, Int, Int, Int)) -> [Int]
            
            let counterClockwiseTriangle = {(triangle: (index0: Int, index1: Int, index2: Int)) -> [Int] in
                return [triangle.index0, triangle.index1, triangle.index2]
            }
            let clockwiseTriangle = {(triangle: (index0: Int, index1: Int, index2: Int)) -> [Int] in
                return [triangle.index0, triangle.index2, triangle.index1]
            }
            let counterClockwiseQuadrilateral = {(quadrilateral: (index0: Int, index1: Int, index2: Int, index3:Int)) -> [Int] in
                return counterClockwiseTriangle((quadrilateral.index0, quadrilateral.index1, quadrilateral.index2)) + counterClockwiseTriangle((quadrilateral.index3, quadrilateral.index0, quadrilateral.index2))
            }
            let clockwiseQuadrilateral = {(quadrilateral: (index0: Int, index1: Int, index2: Int, index3: Int)) in
                return clockwiseTriangle((quadrilateral.index0, quadrilateral.index3, quadrilateral.index2)) + clockwiseTriangle((quadrilateral.index1, quadrilateral.index0, quadrilateral.index2))
            }
            //  Synthesized Quads are meant to be used as the `LINES_ADJACENCY` input for a Geometry shader that produces Quad's
            let synthesizedCounterClockwiseQuadrilateral = {(index0: Int, index1: Int, index2: Int, index3: Int) -> [Int] in
                return [index0, index1, index2, index3]
            }
            let synthesizedlockwiseQuadrilateral = {(index0: Int, index1: Int, index2: Int, index3: Int) -> [Int] in
                return [index0, index3, index2, index1]
            }
            
            func openTriangleFan(withIndices indices: [Int], triangleSpin spin: TriangleSpin, baseIndex: Int) -> [Int] {
                return indices.count <= 1 ? [] : spin((baseIndex, indices[0], indices[1])) + openTriangleFan(withIndices: Array(indices.dropFirst()), triangleSpin: spin, baseIndex: baseIndex)
            }
            func closedTriangleFan(withIndices indices: [Int], triangleSpin spin: TriangleSpin, baseIndex: Int) -> [Int] {
                return openTriangleFan(withIndices: indices, triangleSpin: spin, baseIndex: baseIndex) + spin((baseIndex, indices[indices.count - 1], indices[0]))
            }
            func openQuadrilateralStrip(withTopIndices topIndices: [Int], bottomIndices: [Int], andQuadrilateralSpin spin: QuadrilateralSpin) -> [Int] {
                return topIndices.count <= 1 || bottomIndices.count <= 1 ? [] : spin((topIndices[0], bottomIndices[0], bottomIndices[1], topIndices[1])) + openQuadrilateralStrip(withTopIndices: Array(topIndices.dropFirst()), bottomIndices: Array(bottomIndices.dropFirst()), andQuadrilateralSpin: spin)
            }
            func closedQuadrilateralStip(withTopIndices topIndices: [Int], bottomIndices: [Int], andQuadrilateralSpin spin: QuadrilateralSpin) -> [Int] {
                return openQuadrilateralStrip(withTopIndices: topIndices, bottomIndices: bottomIndices, andQuadrilateralSpin: spin) + spin((topIndices[topIndices.count - 1], bottomIndices[bottomIndices.count - 1], bottomIndices[0], topIndices[0]))
            }
            func closedQuadrilateralStrips(fromSlices slices: [[Int]], quadrilateralSpin spin: QuadrilateralSpin) -> [Int] {
                return slices.count <= 1 ? [] : closedQuadrilateralStrips(fromSlices: Array(slices.dropFirst()), quadrilateralSpin: spin) + closedQuadrilateralStip(withTopIndices: slices[0], bottomIndices: slices[1], andQuadrilateralSpin: spin)
            }
            
            if latitudinalCuts > 1 {
                func sliceIndices(longitudinalCuts: Int, latitudinalCuts: Int) -> [[Int]] {
                    return latitudinalCuts <= 0 ? [] : sliceIndices(longitudinalCuts: longitudinalCuts, latitudinalCuts: latitudinalCuts - 1) + [Array((longitudinalCuts * latitudinalCuts - (longitudinalCuts - 1))...(latitudinalCuts * longitudinalCuts))]
                }
//                let testA = sliceIndices(longitudinalCuts: longitudinalCuts, latitudinalCuts: latitudinalCuts)
//                print("Slices Indices: \(testA), count: \(testA.count)")
//                let testB = closedTriangleFan(withIndices: Array(1...longitudinalCuts), triangleSpin: counterClockwiseTriangle, baseIndex: 0)
//                print("Top Cap Indices: \(testB), count: \(testB.count)")
//                let testC = closedQuadrilateralStrips(fromSlices: sliceIndices(longitudinalCuts: longitudinalCuts, latitudinalCuts: latitudinalCuts), quadrilateralSpin: counterClockwiseQuadrilateral)
//                print("Strip Indices \(testC), count: \(testC.count)")
//                let testD = closedTriangleFan(withIndices: Array((longitudinalCuts * latitudinalCuts - (longitudinalCuts - 1))...longitudinalCuts * latitudinalCuts), triangleSpin: clockwiseTriangle, baseIndex: longitudinalCuts * latitudinalCuts + 1)
//                print("Bottom Cap Indices: \(testD), count: \(testD.count)")
                
                return closedTriangleFan(withIndices: Array(1...longitudinalCuts), triangleSpin: counterClockwiseTriangle, baseIndex: 0) + closedQuadrilateralStrips(fromSlices: sliceIndices(longitudinalCuts: longitudinalCuts, latitudinalCuts: latitudinalCuts), quadrilateralSpin: counterClockwiseQuadrilateral) + closedTriangleFan(withIndices: Array((longitudinalCuts * latitudinalCuts - (longitudinalCuts - 1))...longitudinalCuts * latitudinalCuts), triangleSpin: clockwiseTriangle, baseIndex: longitudinalCuts * latitudinalCuts + 1)
            } else {
                return closedTriangleFan(withIndices: Array(1...longitudinalCuts), triangleSpin: counterClockwiseTriangle, baseIndex: 0) +
                    closedTriangleFan(withIndices: Array((longitudinalCuts * latitudinalCuts - (longitudinalCuts - 1))...longitudinalCuts), triangleSpin: clockwiseTriangle, baseIndex: longitudinalCuts * latitudinalCuts + 1)
            }
        }
        
        let indices = sphereIndices(fromLongitudinalCuts: longCuts, latitudinalCuts: latCuts)
        
        typealias Triangle = (Float3, Float3, Float3)
        func normal(fromTriangle triangle: Triangle) -> Float3 {
            return (triangle.1 - triangle.0) * (triangle.2 - triangle.0)
        }
        func flatSphereNormals(from points: [Float3], faceIndices indices: [Int]) -> [Float3] {
            return indices.count <= 0 ? [] : flatSphereNormals(from: points, faceIndices: Array(indices[3..<indices.count])) + [normal(fromTriangle: (points[indices[0]], points[indices[1]], points[indices[2]]))]
        }
        func sphereNormals(from points: [Float3]) -> [Float3] {
            return points.count <= 0 ? [] : sphereNormals(from: Array(points.dropFirst())) + [points[0].normalize()]
        }
        
        let normals = sphereNormals(from: spherePoints)
        
        func mesh(from points: [Float3], normals: [Float3]) -> [Vertex] {
            return normals.count <= 0 ? [] : mesh(from: Array(points.dropFirst()), normals: Array(normals.dropFirst())) + [Vertex(position: points[0], normal: normals[0], color: Float4(x: points[0].x, y: points[0].y, z: points[0].z, w: 1.0))]
        }
        
        let unsignedIndices = indices.map{ UInt32($0) }
        let meshVertices = mesh(from: spherePoints, normals: normals)
//        print("indices: \(unsignedIndices.count), vertices: \(meshVertices.count)")
        return (unsignedIndices, meshVertices)
    } else {
        return sphereMesh(withRadius: radius, longitudinalCuts: 3, latitudinalCuts: 1)
    }
}
let sphere = sphereMesh(withRadius: 0.5, longitudinalCuts: 20, latitudinalCuts: 20)
let showcaseFloor = planarMesh(withSides: 8, radius: 3, thickness: 1.5)
let light: (color: [Float], position: [Float], ambient: Float, specStrength: Float, specHardness: Float) = (
    color: [1.0, 1.0, 1.0],
    position: [-2, 0.85, 0.0],
    ambient: 0.01,
    specStrength: 0.02,
    specHardness: 80
)

func glLogCall(file: String, line: Int) -> Bool {
    var error = GLenum(GL_NO_ERROR)
    
    repeat {
        error = glGetError()
        
        switch error {
        case  GLenum(GL_INVALID_ENUM):
            print("\(file), line: \(line), ERROR:  invalid Enum")
            return false
        case GLenum(GL_INVALID_VALUE):
            print("\(file), line: \(line), ERROR:  invalid value passed")
            return false
        case GLenum(GL_INVALID_OPERATION):
            print("\(file), line: \(line), ERROR:  invalid operation attempted")
            return false
        case GLenum(GL_INVALID_FRAMEBUFFER_OPERATION):
            print("\(file), line: \(line), ERROR:  invalid framebuffer operation attempted")
            return false
        case GLenum(GL_OUT_OF_MEMORY):
            print("\(file), line: \(line), ERROR:  out of memory")
            return false
        default:
            return true
        }
    } while error != GLenum(GL_NO_ERROR)
}
func glCall<T>(_ function: @autoclosure () -> T, file: String = #file, line: Int = #line) -> T {
    while glGetError() != GL_NO_ERROR {}
    
    let result = function()
    assert(glLogCall(file: file, line: line))
    
    return result
}

class GraphicView: NSOpenGLView {
    var vbo1: GLuint = 0
    var vao1: GLuint = 0
    var vbo2: GLuint = 0
    var vao2: GLuint = 0
    var vbo3: GLuint = 0
    var vao3: GLuint = 0
    var vbo4: GLuint = 0
    var vao4: GLuint = 0
    var vbo4indices: GLuint = 0
    var vbo5: GLuint = 0
    var vao5: GLuint = 0
    var vbo5indices: GLuint = 0
    var tbo: GLuint = 0
    var phongID: GLuint = 0
    var originID: GLuint = 0
    var textureID: GLuint = 0
    var textureInverseBilinearInterpolationID: GLuint = 0
    var fbo: GLuint = 0
    var colorRBO: GLuint = 0
    var depthRBO: GLuint = 0
    
    var displayLink: CVDisplayLink?
    
    var uniformMatrices = [
        "view" : FloatMatrix4().translate(x: 0.0, y: 0.0, z: -25.0).rotateXAxis(0.5),
        "projection" : FloatMatrix4()
    ]
    var viewSize: NSRect!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        viewSize = self.bounds
        
        let attributes = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAllRenderers),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 32,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), 24,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            0
        ]
        
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attributes) else {
            print("Pixel format could not be created")
            return
        }
        self.pixelFormat = pixelFormat
        
        guard let context = NSOpenGLContext(format: pixelFormat, share: nil) else {
            print("Context could not be created.")
            return
        }
        context.setValues([1], for: .swapInterval)
        self.openGLContext = context
        
        //  self.bounds is now available, initialize the projection matrix with the current aspect ratio.
        uniformMatrices["projection"] = uniformMatrices["projection"]?.projection(angeOfView: 6.4,
                                                                                  aspect: Float(bounds.width / bounds.height),
                                                                                  distanceToNearClippingPlane: 0.01,
                                                                                  distanceToFarClippingPlane: 100)
    }
    
    override func prepareOpenGL() {
        //  Set the clear color for the buffers.
        glCall(glClearColor(0.0, 0.0, 0.0, 1.0))
        
        //  //  //  //  //  //  //
        //                      //
        //  Create a Mesh from  //
        //   `triangle` data    //
        //                      //
        //  //  //  //  //  //  //
        /// Setup buffer to hold data (Array Buffers hold arrays of vertex data usually).
        glCall(glGenBuffers(1, &vbo1))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo1))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Vertex>.size * triangle.count, triangle, GLenum(GL_STATIC_DRAW)))
        /// Setup data layout.  When this layout is bound, glDraw* will utilize the data buffer above as it was bound during setup.
        glCall(glGenVertexArrays(1, &vao1))
        glCall(glBindVertexArray(vao1))
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 24)))
        
        //  //  //  //  //  //  //
        //                      //
        //  Create Light origin //
        //   and Other Origins  //
        //                      //
        //  //  //  //  //  //  //
        /// Setup buffers for data
        glCall(glGenBuffers(1, &vbo2))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo2))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Float3>.size * origins.count, origins, GLenum(GL_STATIC_DRAW)))
        /// Setup data layout
        glCall(glGenVertexArrays(1, &vao2))
        glCall(glBindVertexArray(vao2))
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 12, UnsafeRawPointer(bitPattern: 0)))
        
        //  //  //  //  //  //  //  //
        //                          //
        //   Create Square Floor    //
        //                          //
        //  //  //  //  //  //  //  //
        /// Setup buffers for data
        glCall(glGenBuffers(1, &vbo3))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo3))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TexVertex>.size * floor.count, floor, GLenum(GL_STATIC_DRAW)))
        /// Setup data layout
        glCall(glGenVertexArrays(1, &vao3))
        glCall(glBindVertexArray(vao3))
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 24)))
        
        //  //  //  //  //  //  //
        //                      //
        //   Create a Texture   //
        //                      //
        //  //  //  //  //  //  //
        guard let texture = NSImage(named: NSImage.Name(rawValue: "Texture"))?.tiffRepresentation else {
            print("Texture file could not be found or converted to a TIFF.")
            return
        }
        glCall(glGenTextures(1, &tbo))
        glCall(glActiveTexture(GLenum(GL_TEXTURE0)))
        glCall(glBindTexture(GLenum(GL_TEXTURE_2D), tbo))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT))
        glCall(glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (texture as NSData).bytes))
        
        //  //  //  //  //  //  //  //  //
        //                              //
        //  Showcase Floor to be Drawn  //
        //      With drawElements       //
        //                              //
        //  //  //  //  //  //  //  //  //
        glCall(glGenBuffers(1, &vbo4))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo4))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TexVertex>.size * showcaseFloor.1.count, showcaseFloor.1, GLenum(GL_STATIC_DRAW)))
        glCall(glGenBuffers(1, &vbo4indices))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo4indices))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt32>.size * showcaseFloor.0.count, showcaseFloor.0, GLenum(GL_STATIC_DRAW)))
        //  Set up a VAO to later bind when we want to draw what is in the buffer above.
        glCall(glGenVertexArrays(1, &vao4))
        glCall(glBindVertexArray(vao4))
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafePointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 24)))
        
        //  //  //  //  //  //  //  //  //
        //                              //
        //  Create Sphere to be Drawn   //
        //      With drawInstance       //
        //                              //
        //  //  //  //  //  //  //  //  //
        glCall(glGenBuffers(1, &vbo5))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo5))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Vertex>.size * sphere.1.count, sphere.1, GLenum(GL_STATIC_DRAW)))
        glCall(glGenBuffers(1, &vbo5indices))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo5indices))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt32>.size * sphere.0.count, sphere.0, GLenum(GL_STATIC_DRAW)))
        glCall(glGenVertexArrays(1, &vao5))
        glCall(glBindVertexArray(vao5))
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 24)))
        
        //  //  //  //  //  //
        //                  //
        //  Program setup   //
        //                  //
        //  //  //  //  //  //
        originID = glCall(glCreateProgram())
        /// Origin Vertex ///
        var vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        var source = "#version 330 core                                 \n" +
            "uniform vec4 color;                                        \n" +
            "uniform mat4 view;                                         \n" +
            "uniform mat4 projection;                                   \n" +
            "layout (location = 0) in vec3 position;                    \n" +
            "out vec4 passColor;                                        \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    gl_Position = projection * view * vec4(position, 1.0); \n" +
            "    passColor = color;                                     \n" +
            "}                                                          \n"
        var vss = source.cString(using: String.Encoding.ascii)
        var vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        var compiled: GLint = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Origin Fragment ///
        var fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core     \n" +
            "in vec4 passColor;         \n" +
            "out vec4 outColor;         \n" +
            "void main()                \n" +
            "{                          \n" +
            "    outColor = passColor;  \n" +
            "}                          \n"
        var fss = source.cString(using: String.Encoding.ascii)
        var fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile fragement, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Attach and link shaders to the program.
        glCall(glAttachShader(originID, vs))
        glCall(glAttachShader(originID, fs))
        glCall(glLinkProgram(originID))
        var linked: GLint = 0
        glCall(glGetProgramiv(originID, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(originID, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(originID, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  //  //  //  //  //
        //                  //
        //   Phong Shader   //
        //                  //
        //  //  //  //  //  //
        phongID = glCall(glCreateProgram())
        /// Phong Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = "#version 330 core                                     \n" +
            "layout (location = 0) in vec3 position;                    \n" +
            "layout (location = 1) in vec3 normal;                      \n" +
            "layout (location = 2) in vec4 color;                       \n" +
            "out vec3 passPosition;                                     \n" +
            "out vec3 passNormal;                                       \n" +
            "out vec4 passColor;                                        \n" +
            "out vec3 passCameraPosition;                               \n" +
            "uniform mat4 view;                                         \n" +
            "uniform mat4 projection;                                   \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    gl_Position = projection * view * vec4(position, 1.0); \n" +
            "    passPosition = position;                               \n" +
            "    passNormal = normalize(normal);                        \n" +
            "    passColor = color;                                     \n" +
            "    passCameraPosition = view[3].xyz;                      \n" +
            "}                                                          \n"
        vss = source.cString(using: String.Encoding.ascii)
        vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Phong Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core                                                                                         \n" +
            "uniform struct Light {                                                                                         \n" +
            "   vec3 color;                                                                                                 \n" +
            "   vec3 position;                                                                                              \n" +
            "   float ambient;                                                                                              \n" +
            "   float specStrength;                                                                                         \n" +
            "   float specHardness;                                                                                         \n" +
            "} light;                                                                                                       \n" +
            "in vec3 passPosition;                                                                                          \n" +
            "in vec3 passNormal;                                                                                            \n" +
            "in vec4 passColor;                                                                                             \n" +
            "in vec3 passCameraPosition;                                                                                    \n" +
            "out vec4 outColor;                                                                                             \n" +
            "void main()                                                                                                    \n" +
            "{                                                                                                              \n" +
            "    vec3 normal = passNormal;                                                                                  \n" +
            "    vec3 lightRay = normalize(light.position - passPosition);                                                  \n" +
            "    float intensity = clamp(dot(normal, lightRay), 0, 1);                                                      \n" +
            "    vec3 viewer = normalize(passCameraPosition - passPosition);                                                \n" +
            "    vec3 reflection = reflect(lightRay, normal);                                                               \n" +
            "    float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                               \n" +
            "    outColor.rgb = passColor.rgb + light.ambient + light.color * intensity + light.specStrength * specular;    \n" +
            "    outColor.a = passColor.a;                                                                                  \n" +
            "}                                                                                                              \n"
        fss = source.cString(using: String.Encoding.ascii)
        fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile fragement, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Attach and link shaders to program
        glCall(glAttachShader(phongID, vs))
        glCall(glAttachShader(phongID, fs))
        glCall(glLinkProgram(phongID))
        linked = 0
        glCall(glGetProgramiv(phongID, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(phongID, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(phongID, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        /// Set up Uniforms (only required prior to making a call to a glDraw* call--this is an example).
        glCall(glUseProgram(phongID))
        //  Not necessary to do right now, but we can set a program's uniform values
        //  at this time.  More useful, would be to capture the "Locations" of the
        //  Uniform's for later use--fewer OpenGL calls a render time.
        glCall(glUniform1i(glCall(glGetUniformLocation(phongID, "sample")), GL_TEXTURE0))
        glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.color")), 1, light.color))
        glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.position")), 1, light.position))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.ambient")), light.ambient))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specStrength")), light.specStrength))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specHardness")), light.specHardness))
        
        //  //  //  //  //  //  //
        //                      //
        //  Textured Triangles  //
        //                      //
        //  //  //  //  //  //  //
        textureID = glCall(glCreateProgram())
        /// Texture Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = "#version 330 core                                     \n" +
            "layout (location = 0) in vec3 position;                    \n" +
            "layout (location = 1) in vec3 normal;                      \n" +
            "layout (location = 2) in vec2 coordinate;                  \n" +
            "uniform mat4 view;                                         \n" +
            "uniform mat4 projection;                                   \n" +
            "out vec2 uv;                                               \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    gl_Position = projection * view * vec4(position, 1.0); \n" +
            "    uv = coordinate;                                       \n" +
            "}                                                          \n"
        vss = source.cString(using: String.Encoding.ascii)
        vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile vertex shader, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Texture Framgent Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core                 \n" +
            "uniform sampler2D sample;              \n" +
            "in vec2 uv;                            \n" +
            "out vec4 outColor;                     \n" +
            "void main()                            \n" +
            "{                                      \n" +
            "    outColor = texture(sample, uv);    \n" +
            "}                                      \n"
        fss = source.cString(using: String.Encoding.ascii)
        fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile fragement shader, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog))
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        //  Attach shaders to program and link
        glCall(glAttachShader(textureID, vs))
        glCall(glAttachShader(textureID, fs))
        glCall(glLinkProgram(textureID))
        linked = 0
        glCall(glGetProgramiv(textureID, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(textureID, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(textureID, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        //  Mark shaders for deletetion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  //  //  //  //  //  //  //  //  //
        //                                  //
        //   Bilinearly Interpolated Quad   //
        //                                  //
        //  //  //  //  //  //  //  //  //  //
        textureInverseBilinearInterpolationID = glCall(glCreateProgram())
        /// Quad Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = "#version 330 core                                     \n" +
            "layout (location = 0) in vec3 position;                    \n" +
            "layout (location = 1) in vec3 normal;                      \n" +
            "layout (location = 2) in vec2 coordinate;                  \n" +
            "out VertexData {                                           \n" +
            "    vec3 position;                                         \n" +
            "    vec3 normal;                                           \n" +
            "    vec2 coordinate;                                       \n" +
            "    vec3 cameraPosition;                                   \n" +
            "} vs_out;                                                  \n" +
            "uniform mat4 view;                                         \n" +
            "uniform mat4 projection;                                   \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    gl_Position = projection * view * vec4(position, 1.0); \n" +
            "    vs_out.position = position;                            \n" +
            "    vs_out.normal = normalize(normal);                     \n" +
            "    vs_out.coordinate = coordinate;                        \n" +
            "    vs_out.cameraPosition = view[3].xyz;                   \n" +
            "}                                                          \n"
        vss = source.cString(using: String.Encoding.ascii)
        vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile vertex shader, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Quad Geometry Shader ///
        let gs = glCall(glCreateShader(GLenum(GL_GEOMETRY_SHADER)))
        source = "#version 330 core                                     \n" +
            "layout (lines_adjacency) in;                               \n" +
            "layout (triangle_strip, max_vertices = 6) out;             \n" +
            "in VertexData {                                            \n" +
            "    vec3 position;                                         \n" +
            "    vec3 normal;                                           \n" +
            "    vec2 coordinate;                                       \n" +
            "    vec3 cameraPosition;                                   \n" +
            "} gd_in[4];                                                \n" +
            "out GeometryData {                                         \n" +
            "    vec3 position;                                         \n" +
            "    vec3 normal;                                           \n" +
            "    vec2 coordinate;                                       \n" +
            "} gd_out;                                                  \n" +
            "out vec3 points[4];                                        \n" +
            "out vec3 cameraPosition;                                   \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    //  Establish constant parameters across the Quad      \n" +
            "    points = vec3[](                                       \n" +
            "        gd_in[0].position,                                 \n" +
            "        gd_in[1].position,                                 \n" +
            "        gd_in[2].position,                                 \n" +
            "        gd_in[3].position                                  \n" +
            "    );                                                     \n" +
            "    vec3 camera = gd_in[0].cameraPosition;                 \n" +
            "    //  Define individual variants for each vertex         \n" +
            "    gl_Position = gl_in[0].gl_Position;                    \n" +
            "    gd_out.position = gd_in[0].position;                   \n" +
            "    gd_out.normal = gd_in[0].normal;                       \n" +
            "    gd_out.coordinate = gd_in[0].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[1].gl_Position;                    \n" +
            "    gd_out.position = gd_in[1].position;                   \n" +
            "    gd_out.normal = gd_in[1].normal;                       \n" +
            "    gd_out.coordinate = gd_in[1].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[2].gl_Position;                    \n" +
            "    gd_out.position = gd_in[2].position;                   \n" +
            "    gd_out.normal = gd_in[2].normal;                       \n" +
            "    gd_out.coordinate = gd_in[2].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    EndPrimitive();                                        \n" +
            
            "    gl_Position = gl_in[3].gl_Position;                    \n" +
            "    gd_out.position = gd_in[3].position;                   \n" +
            "    gd_out.normal = gd_in[3].normal;                       \n" +
            "    gd_out.coordinate = gd_in[3].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[2].gl_Position;                    \n" +
            "    gd_out.position = gd_in[2].position;                   \n" +
            "    gd_out.normal = gd_in[2].normal;                       \n" +
            "    gd_out.coordinate = gd_in[2].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[1].gl_Position;                    \n" +
            "    gd_out.position = gd_in[1].position;                   \n" +
            "    gd_out.normal = gd_in[1].normal;                       \n" +
            "    gd_out.coordinate = gd_in[1].coordinate;               \n" +
            "    EmitVertex();                                          \n" +
            "    EndPrimitive();                                        \n" +
            "}                                                          \n"
        let gss = source.cString(using: String.Encoding.ascii)
        var gssptr = UnsafePointer<GLchar>(gss)
        glCall(glShaderSource(gs, 1, &gssptr, nil))
        glCall(glCompileShader(gs))
        compiled = 0
        glCall(glGetShaderiv(gs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile geometry shader, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(gs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(gs, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        /// Quad Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core                                                             \n" +
            "uniform sampler2D sample;                                                          \n" +
            "uniform struct Light {                                                             \n" +
            "   vec3 color;                                                                     \n" +
            "   vec3 position;                                                                  \n" +
            "   float ambient;                                                                  \n" +
            "   float specStrength;                                                             \n" +
            "   float specHardness;                                                             \n" +
            "} light;                                                                           \n" +
            "in GeometryData {                                                                  \n" +
            "    vec3 position;                                                                 \n" +
            "    vec3 normal;                                                                   \n" +
            "    vec2 coordinate;                                                               \n" +
            "} fs_in;                                                                           \n" +
            "in vec3 cameraPosition;                                                            \n" +
            "in vec3 points[4];                                                                 \n" +
            "out vec4 outColor;                                                                 \n" +
            "float wedge2D(vec2 a, vec2 b) {                                                    \n" +
            "    return (a.x * b.y - a.y * b.x);                                                \n" +
            "}                                                                                  \n" +
            "void main()                                                                        \n" +
            "{                                                                                  \n" +
            "    vec2 q = fs_in.position.xz - points[0].xz;                                     \n" +
            "    vec2 b1 = points[1].xz - points[0].xz;                                         \n" +
            "    vec2 b2 = points[2].xz - points[0].xz;                                         \n" +
            "    vec2 b3 = points[0].xz - points[1].xz - points[2].xz + points[3].xz;           \n" +
            "    float A = wedge2D(b2, b3);                                                     \n" +
            "    float B = wedge2D(b3, q) - wedge2D(b1, b2);                                    \n" +
            "    float C = wedge2D(b1, q);                                                      \n" +
            "    float v = abs(A) < 0.001 ? -C/B : (0.5 * (-B + sqrt(B * B - 4 * A * C)) / A);  \n" +
            "    float u;                                                                       \n" +
            "    vec2 denominator = b1 + v * b3;                                                \n" +
            "    if (abs(denominator.x) > abs(denominator.y)) {                                 \n" +
            "        u = (q.x - b2.x * v) / denominator.x;                                      \n" +
            "    } else {                                                                       \n" +
            "        u = (q.y - b2.y * v) / denominator.y;                                      \n" +
            "    }                                                                              \n" +
            "    outColor = texture(sample, vec2(u, v));                                        \n" +
            "}                                                                                  \n"
        fss = source.cString(using: String.Encoding.ascii)
        fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile fragement shader, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog))
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        //  Attach shaders to program and link
        glCall(glAttachShader(textureInverseBilinearInterpolationID, vs))
        glCall(glAttachShader(textureInverseBilinearInterpolationID, gs))
        glCall(glAttachShader(textureInverseBilinearInterpolationID, fs))
        glCall(glLinkProgram(textureInverseBilinearInterpolationID))
        linked = 0
        glCall(glGetProgramiv(textureInverseBilinearInterpolationID, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(textureInverseBilinearInterpolationID, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(textureInverseBilinearInterpolationID, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        //  Mark shaers for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(gs))
        glCall(glDeleteShader(fs))
        
        //  Unbind all objects to avoid unexpected changes in state.
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0))
        glCall(glBindVertexArray(0))
        glCall(glUseProgram(0))

        //  //  //  //  //  //  //  //  //  //
        //                                  //
        //  Framebuffer and Renderbuffer    //
        //            Creation              //
        //                                  //
        //  //  //  //  //  //  //  //  //  //
        glCall(glGenRenderbuffers(1, &colorRBO))
        glCall(glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRBO))
        glCall(glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_RGBA), Int32(bounds.width), Int32(bounds.height)))
        glCall(glGenRenderbuffers(1, &depthRBO))
        glCall(glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRBO))
        glCall(glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT24), Int32(bounds.width), Int32(bounds.height)))

        //  Attach the colorand depth renderbuffers to the framebuffer.
        glCall(glGenFramebuffers(1, &fbo))
        glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo))
        glCall(glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRBO))
        glCall(glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRBO))
        glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0))
        
        //  Set general enables:  will require being turned off and then back on during
        //  drawing in some instances.
        glCall(glEnable(GLenum(GL_DEPTH_TEST)))
        glCall(glEnable(GLenum(GL_CULL_FACE)))
        
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
            unsafeBitCast(displayLinkContext, to: GraphicView.self).drawView()

            return kCVReturnSuccess
        }

        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
    }

    func drawView() {
        if let context = openGLContext {
            context.makeCurrentContext()
            context.lock()
            
            //  Clear the context
            glCall(glClearColor(1.0, 1.0, 1.0, 1.0))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT)))
            
            //  Prepare the view matrix, add animation
            uniformMatrices["view"] = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -25.0) * FloatMatrix4().rotateXAxis(0.5) * FloatMatrix4().rotateYAxis(0.008) * FloatMatrix4().rotateXAxis(-0.5) * FloatMatrix4().translate(x: 0.0, y: 0.0, z: 25.0) * uniformMatrices["view"]!
            
            //  Draw triangle polygons
            glCall(glUseProgram(phongID))
            glCall(glBindVertexArray(vao1))

            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))

            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(triangle.count)))
            
            //  Draw triangle outline
            glCall(glUseProgram(originID))

            glCall(glUniform4f(glCall(glGetUniformLocation(originID, "color")), 0.3, 0.3, 0.3, 1.0))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(originID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(originID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))

            glCall(glDrawArrays(GLenum(GL_LINE_STRIP), 0, Int32(triangle.count)))
            
            //  Draw light origin
            glCall(glBindVertexArray(vao2))
            
            glCall(glUniform4f(glCall(glGetUniformLocation(originID, "color")), 0.9, 0.9, 0.2, 1.0))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(originID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(originID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))
            
            glCall(glPointSize(5))
            glCall(glDrawArrays(GLenum(GL_POINTS), 0, Int32(origins.count)))
            
            ////////////
            /// TEST ///
            glCall(glUseProgram(phongID))
            glCall(glBindVertexArray(vao5))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo5indices))
            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.translate(x: 0.0, y: 1.0, z: 0.0).scale(x: 0.5, y: 0.5, z: 0.5).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))
            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(sphere.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))
            /// TEST ///
            ////////////
            
            //  Draw the floor
            glCall(glUseProgram(textureID))
            glCall(glBindVertexArray(vao3))

            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))
            
            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(floor.count)))
            
            glCall(glUseProgram(textureInverseBilinearInterpolationID))
            glCall(glBindVertexArray(vbo4))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo4indices))

            glCall(glUniform3fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))

            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawElements(GLenum(GL_LINES_ADJACENCY), Int32(showcaseFloor.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))
            
            /// Draw the showcase floor models
            glCall(glUseProgram(phongID))
            glCall(glBindVertexArray(vao5))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo5indices))

            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.rotateYAxis(2 * Float.pi / 8 + 0.5 * (2 * Float.pi / 8)).translate(x: 0.0, y: 0.5, z: 3 - 0.75).scale(x: 0.4, y: 0.4, z: 0.4).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))

//            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(sphere.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))
            glCall(glDrawElementsInstanced(GLenum(GL_TRIANGLES), Int32(sphere.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0), Int32(showcaseFloor.0.count / 6)))
            //  Draw into offline framebuffer
            glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo))

            glCall(glClearColor(1.0, 1.0, 1.0, 1.0))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT)))

            //  Draw with top-down viewpoint
            let topDown = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0) * FloatMatrix4().rotateXAxis(Float.pi / 2) * FloatMatrix4().rotateYAxis(0.008) * FloatMatrix4().translate(x: 0.0, y: 0.0, z: 25.0) * uniformMatrices["view"]!

            //  Draw triangle polygons
            glCall(glUseProgram(phongID))
            glCall(glBindVertexArray(vao1))

            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(phongID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(phongID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "view")), 1, GLboolean(GL_FALSE), topDown.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongID, "projection")), 1, GLboolean(GL_FALSE), FloatMatrix4().projection(aspect: 1.0).columnMajorArray()))

            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(triangle.count)))

            //  Draw the floor
            glCall(glUseProgram(textureID))
            glCall(glBindVertexArray(vao3))

            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "view")), 1, GLboolean(GL_FALSE), topDown.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "projection")), 1, GLboolean(GL_FALSE), FloatMatrix4().projection(angeOfView: 35, aspect: 1.0, distanceToNearClippingPlane: 0.01, distanceToFarClippingPlane: 100).columnMajorArray()))

            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(floor.count)))

            glCall(glUseProgram(textureInverseBilinearInterpolationID))
            glCall(glBindVertexArray(vbo4))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo4indices))

            glCall(glUniform3fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "view")), 1, GLboolean(GL_FALSE), topDown.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureInverseBilinearInterpolationID, "projection")), 1, GLboolean(GL_FALSE), FloatMatrix4().projection(angeOfView: 35, aspect: 1.0, distanceToNearClippingPlane: 0.01, distanceToFarClippingPlane: 100).columnMajorArray()))

            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawElements(GLenum(GL_LINES_ADJACENCY), Int32(showcaseFloor.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))

            // Prepare frame transfer from offline framebuffer to default for display to the screen
            glCall(glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), fbo))
            glCall(glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), 0))

            //  Copy the information over
            glCall(glBlitFramebuffer(0, 0, Int32(viewSize.width), Int32(viewSize.height), 5, 5, 80, 80, GLbitfield(GL_COLOR_BUFFER_BIT), GLenum(GL_NEAREST)))
            
            glCall(glBindVertexArray(0))
            glCall(glUseProgram(0))
            
            context.flushBuffer()
            context.unlock()
        } else { print("OpenGL context could not be retrieved.") }
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawView()
    }

    deinit {
        CVDisplayLinkStop(displayLink!)
        glCall(glDeleteTextures(1, &tbo))
        glCall(glDeleteBuffers(1, &vbo1))
        glCall(glDeleteVertexArrays(1, &vao1))
        glCall(glDeleteBuffers(1, &vbo2))
        glCall(glDeleteVertexArrays(1, &vao2))
        glCall(glDeleteBuffers(1, &vbo3))
        glCall(glDeleteVertexArrays(1, &vao3))
        glCall(glDeleteBuffers(1, &vbo4))
        glCall(glDeleteBuffers(1, &vbo4indices))
        glCall(glDeleteVertexArrays(1, &vao4))
        glCall(glDeleteBuffers(1, &vbo5))
        glCall(glDeleteBuffers(1, &vbo5indices))
        glCall(glDeleteVertexArrays(1, &vao5))
        glCall(glDeleteProgram(phongID))
        glCall(glDeleteProgram(originID))
        glCall(glDeleteProgram(textureID))
        glCall(glDeleteProgram(textureInverseBilinearInterpolationID))
        glCall(glDeleteRenderbuffers(1, &colorRBO))
        glCall(glDeleteRenderbuffers(1, &depthRBO))
        glCall(glDeleteFramebuffers(1, &fbo))
    }
}
