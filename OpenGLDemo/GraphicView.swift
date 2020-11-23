//
//  GraphicView.swift
//  OpenGLDemo
//
//  Created by Myles Schultz on 6/9/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Cocoa
import simd
import OpenGL.GL3
import CoreGraphics


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
///  Draw a "circular" floor to roate for showcasing different objects and lighting schemes
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

//  MARK: Primitives
/// 3D space direction definitions:
/// X: Left => negative, Right => positive
/// Y: Down => negative, Up => positive
/// Z: Into screen => negative, Out of screen => positive
let triangle: [Float3] = [
    Float3(x: -0.5, y: -0.5, z: -1.0), Float3(x: 0.5, y: -0.5, z: 1.0), Float3(x: 0.0, y: 0.5, z: 0.0)
]
let coloredTriangle: [(Float3, Float4)] = [
    (Float3(x: -0.5, y: -0.5, z: 0.0), Float4(x: 1.0, y: 0.0, z: 0.0, w: 1.0)),
    (Float3(x:  0.5, y: -0.5, z: 0.0), Float4(x: 0.0, y: 1.0, z: 0.0, w: 1.0)),
    (Float3(x:  0.0, y:  0.5, z: 0.0), Float4(x: 0.0, y: 0.0, z: 1.0, w: 1.0))
]
let texturedTriangle: [(Float3, Float2)] = [
    (Float3(x: -0.5, y: -0.5, z: 0.0), Float2(x: 0.0, y: 0.0)),
    (Float3(x:  0.5, y: -0.5, z: 0.0), Float2(x: 1.0, y: 0.0)),
    (Float3(x:  0.0, y:  0.5, z: 0.0), Float2(x: 0.5, y: 1.0))
]
let texturedCube: (indices: [GLuint], vertices: [(Float3, Float4, Float2)]) = (
    indices: [
        1, 2, 3, 1, 3, 0,
        2, 5, 4, 2, 4, 3,
        5, 6, 7, 5, 7, 4,
        6, 1, 0, 6, 0, 7,
        0, 3, 4, 0, 4, 7,
        6, 5, 2, 6, 2, 1
    ],
    vertices: [
        (Float3(x: -0.5, y:  0.5, z:  0.5), Float4(x: 1.0, y: 0.0, z: 0.0, w: 1.0), Float2(x: 0.0, y: 1.0)),
        (Float3(x: -0.5, y: -0.5, z:  0.5), Float4(x: 0.0, y: 1.0, z: 0.0, w: 1.0), Float2(x: 0.0, y: 0.0)),
        (Float3(x:  0.5, y: -0.5, z:  0.5), Float4(x: 0.0, y: 0.0, z: 1.0, w: 1.0), Float2(x: 1.0, y: 0.0)),
        (Float3(x:  0.5, y:  0.5, z:  0.5), Float4(x: 0.0, y: 0.0, z: 0.0, w: 1.0), Float2(x: 1.0, y: 1.0)),
        
        (Float3(x:  0.5, y:  0.5, z: -0.5), Float4(x: 1.0, y: 1.0, z: 0.0, w: 1.0), Float2(x: 0.0, y: 1.0)),
        (Float3(x:  0.5, y: -0.5, z: -0.5), Float4(x: 0.0, y: 1.0, z: 1.0, w: 1.0), Float2(x: 0.0, y: 0.0)),
        (Float3(x: -0.5, y: -0.5, z: -0.5), Float4(x: 1.0, y: 0.0, z: 1.0, w: 1.0), Float2(x: 1.0, y: 0.0)),
        (Float3(x: -0.5, y:  0.5, z: -0.5), Float4(x: 1.0, y: 1.0, z: 1.0, w: 1.0), Float2(x: 1.0, y: 1.0))
    ]
)
let litCube: (indices: [GLuint], vertices: [(Float3, Float3, Float4)]) = (
    indices: [
        1, 2, 3, 1, 3, 0,
        2, 5, 4, 2, 4, 3,
        5, 6, 7, 5, 7, 4,
        6, 1, 0, 6, 0, 7,
        0, 3, 4, 0, 4, 7,
        6, 5, 2, 6, 2, 1
    ],
    vertices: [
        (Float3(x: -0.5, y:  0.5, z:  0.5), Float3(x: -0.5, y:  0.5, z:  0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x: -0.5, y: -0.5, z:  0.5), Float3(x: -0.5, y: -0.5, z:  0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x:  0.5, y: -0.5, z:  0.5), Float3(x:  0.5, y: -0.5, z:  0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x:  0.5, y:  0.5, z:  0.5), Float3(x:  0.5, y:  0.5, z:  0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),

        (Float3(x:  0.5, y:  0.5, z: -0.5), Float3(x:  0.5, y:  0.5, z: -0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x:  0.5, y: -0.5, z: -0.5), Float3(x:  0.5, y: -0.5, z: -0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x: -0.5, y: -0.5, z: -0.5), Float3(x: -0.5, y: -0.5, z: -0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0)),
        (Float3(x: -0.5, y:  0.5, z: -0.5), Float3(x: -0.5, y:  0.5, z: -0.5), Float4(x: 0.8, y: 0.8, z: 0.85, w: 1.0))
    ]
)
let litTextureCube: (indices: [GLuint], vertices: [(Float3, Float3, Float2)]) = (
    indices: [
        1, 2, 3, 1, 3, 0,
        2, 5, 4, 2, 4, 3,
        5, 6, 7, 5, 7, 4,
        6, 1, 0, 6, 0, 7,
        0, 3, 4, 0, 4, 7,
        6, 5, 2, 6, 2, 1
    ],
    vertices: [
        (Float3(x: -0.5, y:  0.5, z:  0.5), Float3(x: -0.5, y:  0.5, z:  0.5), Float2(x: 0.0, y: 1.0)),
        (Float3(x: -0.5, y: -0.5, z:  0.5), Float3(x: -0.5, y: -0.5, z:  0.5), Float2(x: 0.0, y: 0.0)),
        (Float3(x:  0.5, y: -0.5, z:  0.5), Float3(x:  0.5, y: -0.5, z:  0.5), Float2(x: 1.0, y: 0.0)),
        (Float3(x:  0.5, y:  0.5, z:  0.5), Float3(x:  0.5, y:  0.5, z:  0.5), Float2(x: 1.0, y: 1.0)),

        (Float3(x:  0.5, y:  0.5, z: -0.5), Float3(x:  0.5, y:  0.5, z: -0.5), Float2(x: 0.0, y: 1.0)),
        (Float3(x:  0.5, y: -0.5, z: -0.5), Float3(x:  0.5, y: -0.5, z: -0.5), Float2(x: 0.0, y: 0.0)),
        (Float3(x: -0.5, y: -0.5, z: -0.5), Float3(x: -0.5, y: -0.5, z: -0.5), Float2(x: 1.0, y: 0.0)),
        (Float3(x: -0.5, y:  0.5, z: -0.5), Float3(x: -0.5, y:  0.5, z: -0.5), Float2(x: 1.0, y: 1.0))
    ]
)

let sphere = sphereMesh(withRadius: 0.5, longitudinalCuts: 20, latitudinalCuts: 20)
let directionLight: (ambient: [Float], color: [Float], direction: [Float], halfVector: [Float], shininess: Float, strength: Float) = (
    ambient: [0.0, 0.5, 0.7],
    color: [0.0, 0.5, 1.0],
    direction: [-1, 0.85, 2.0],
    halfVector: [-1, 0.85, 2.0],
    shininess: 1.0,
    strength: 0.15
)
let pointLight: (ambient: [Float], color: [Float], position: [Float], shininess: Float, strength: Float) = (
    ambient: [0.0, 0.5, 0.7],
    color: [0.0, 0.5, 1.0],
    position: [-1, 0.85, 1.0],
    shininess: 1.0,
    strength: 0.7
)
let spotLight: (ambient: [Float], color: [Float], position: [Float], shininess: Float, strength: Float, coneDirection: [Float], cosCutOff: Float, exponent: Float) = (
    ambient: [0.0, 0.5, 0.7],
    color: [0.0, 0.5, 1.0],
    position: [-1, 0.85, 1.0],
    shininess: 1.0,
    strength: 0.1,
    coneDirection: [1, -0.85, -1.0],
    cosCutOff: 0.9,
    exponent: 0.9
)
let hemisphereLight: (position: [Float], skyColor: [Float], groundColor: [Float]) = (
    position: [1.0, 1.0, 1.0],
    skyColor: [0.98, 0.95, 1.0],
    groundColor: [0.0, 0.0, 0.0]
)

//  MARK:  ERROR Messages
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

//  MARK: ViewOrganizer
struct ViewOrganizer {
    struct GridSize: Equatable {
        var width: Int = 0
        var height: Int = 0
        
        init(width: Int = 0, height: Int = 0) {
            self.width = width
            self.height = height
        }
    }
    typealias PixelDimensions = GridSize
    typealias LocationOnGrid = GridSize
    struct Space: Equatable {
        var x: Int
        var y: Int
        var width: Int
        var height: Int
        var backgroundColor: Float4
    }
    private var viewSize: PixelDimensions
    private var numberOfSpaces: UInt
    private var spaceGrid: GridSize!
    var layout: [[Space]]!
    private var nextUnusedSpace = LocationOnGrid()
    
    func printGrid() {
        print("View size:", viewSize)
        print("Number of spaces:", numberOfSpaces)
        for row in layout {
            for space in row {
                print("|", space.x, space.y, space.width, space.height, "|")
            }
        }
    }
    
    init(numberOfSpaces: UInt = 0, viewSize: GridSize = GridSize()) {
        self.numberOfSpaces = numberOfSpaces
        self.viewSize = viewSize
    }
    
    mutating func addASpace() {
        numberOfSpaces += 1
    }
    mutating func generateGrid() -> GridSize {
        var gridSize = GridSize(width: 0, height: 0)
        
        if numberOfSpaces > 0 {
            repeat {
                gridSize.width == gridSize.height ? (gridSize.width += 1) : (gridSize.height += 1)
            } while gridSize.width * gridSize.height < numberOfSpaces
        } else {
            gridSize.width = 1
            gridSize.height = 1
        }
        spaceGrid = gridSize
        return gridSize
    }
    func calculateSpaceSize(forGrid grid: GridSize) -> GridSize {
        let spaceWidth = viewSize.width / grid.width
        let spaceHeight = viewSize.height / grid.height
        
        return GridSize(width: spaceWidth, height: spaceHeight)
    }
    mutating func layoutSpaces(withSize spaceSize: GridSize, forGrid grid: GridSize) {
        var layout: [[Space]] = [[Space]].init()
        
        for column in 0..<grid.width {
            layout.append([])
            for row in 0..<grid.height {
                let space: Space!
                if layout[0].first == nil {
                    space = Space(x: 0,
                                  y: 0,
                                  width: spaceSize.width,
                                  height: spaceSize.height,
                                  backgroundColor: Float4(x: Float.random(in: 0.0...1.0), y: Float.random(in: 0.0...1.0), z: Float.random(in: 0.0...1.0), w: 1.0))
                } else if layout[column].first == nil {
                    space = Space(x: layout[column - 1][0].x + spaceSize.width,
                                  y: 0,
                                  width: spaceSize.width,
                                  height: spaceSize.height,
                                  backgroundColor: Float4(x: Float.random(in: 0.0...1.0), y: Float.random(in: 0.0...1.0), z: Float.random(in: 0.0...1.0), w: 1.0))
                } else {
                    space = Space(x: layout[column][row - 1].x,
                                  y: layout[column][row - 1].y + spaceSize.height,
                                  width: spaceSize.width,
                                  height: spaceSize.height,
                                  backgroundColor: Float4(x: Float.random(in: 0.0...1.0), y: Float.random(in: 0.0...1.0), z: Float.random(in: 0.0...1.0), w: 1.0))
                }
                layout[column].append(space)
            }
        }
        
        self.layout = layout
    }
    mutating func getNextSpace() -> Space {
        //  Get current next space
        let space = layout![nextUnusedSpace.width][nextUnusedSpace.height]
        
        //  Increment nextSpace to fill the grid by row
        if nextUnusedSpace.width < spaceGrid.width {
            if (nextUnusedSpace.width + 1) >= spaceGrid.width {
                nextUnusedSpace.width = 0
                nextUnusedSpace.height += 1
            } else {
                nextUnusedSpace.width += 1
            }
        }
        
        return space
    }
    mutating func resetNextSpace() {
        nextUnusedSpace = GridSize(width: 0, height: 0)
    }
}
extension ViewOrganizer: CustomStringConvertible {
    var description: String {
        var columnString = ""
        for column in layout {
            for space in column {
                columnString += "|" + "x: \(space.x)\t" + "y: \(space.y)\t" + "width: \(space.width)\t" + "height: \(space.height)" + "|"
            }
            columnString += "\n"
        }
        return columnString
    }
}

//  MARK:  GraphicView
class GraphicView: NSOpenGLView {
    ///  ViewOrganizer was created for this demo to tile multiple glDraw* calls
    ///  into one OpenGL view.  By tiling individual draw calls, or sets of
    ///  draw calls together, a progression of the complexity of OpenGL
    ///  procedures may be displayed simultaneously in a similar way that this
    ///  block of code has each OpenGL procedure defined one after the other
    ///  with relatively increasing complexity.
    var organizer: ViewOrganizer!
    
    var pointVAO: GLuint = 0
    var triangleVBO: GLuint = 0
    var triangleVAO: GLuint = 0
    var coloredTriangleVBO: GLuint = 0
    var coloredTriangleVAO: GLuint = 0
    var texturedTriangleVBO: GLuint = 0
    var texturedTriangleVAO: GLuint = 0
    var texturedCubeVBOIndex: GLuint = 0
    var texturedCubeVBOVertex: GLuint = 0
    var texturedCubeVAO: GLuint = 0
    var litCubeVBOIndex: GLuint = 0
    var litCubeVBOVertex: GLuint = 0
    var litCubeVAO: GLuint = 0
    var litTextureCubeVBOIndex: GLuint = 0
    var litTextureCubeVBOVertex: GLuint = 0
    var litTextureCubeVAO: GLuint = 0
    var checkerTextureTBO: GLuint = 0
    var sphereVBOIndex: GLuint = 0
    var sphereVBOVertex: GLuint = 0
    var sphereVAO: GLuint = 0
    var hardcodedPointProgram: GLuint = 0
    var positionProgram: GLuint = 0
    var colorProgram: GLuint = 0
    var textureProgram:  GLuint = 0
    var threeDimensionalProgram: GLuint = 0
    var threeDimensionalWithViewerProgram: GLuint = 0
    var directionLightProgram: GLuint = 0
    var pointLightProgram: GLuint = 0
    var spotLightProgram: GLuint = 0
    var hemisphereLightProgram: GLuint = 0
    var textureInverseBilinearInterpolationID: GLuint = 0
    var fbo: GLuint = 0
    var colorRBO: GLuint = 0
    var depthRBO: GLuint = 0
    
    var numberOfTrianglesToDraw: UInt = 12
    var startTriangle: UInt = 0
    
    var displayLink: CVDisplayLink?
    
    var cameraPosition = Float3(x: 0.0, y: 0.0, z: 0.0)
    var cameraRotation = Float3(x: 0.0, y: 0.0, z: 0.0)
    lazy var uniformMatrices: [String : OpenGLMatrixFormat] = [
        "view" : FloatMatrix4().translate(x: 0.0, y: 0.0, z: 0.0),
        "orthographicProgjection" : FloatMatrix4().orthographic(width: Float(bounds.width),
                                                                height: Float(bounds.height),
                                                                nearZ: -10,
                                                                farZ: 100),
        "perspectiveProjection" : FloatMatrix4().perspective(angeOfView: 120,
                                                  aspect: Float(bounds.width / bounds.height),
                                                  distanceToNearClippingPlane: 0.01,
                                                  distanceToFarClippingPlane: 100),
        "simdOrthographicProjection" : simd_float4x4().orthographic(width: Float(bounds.width),
                                                                    height: Float(bounds.height),
                                                                    nearZ: -10,
                                                                    farZ: 100),
        "simdPerspectiveProjection" : simd_float4x4().perspective(angeOfView: 120,
                                                 aspect: Float(bounds.width / bounds.height),
                                                 distanceToNearClippingPlane: 0.01,
                                                 distanceToFarClippingPlane: 100)
    ]
    var viewSize: NSRect!
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        viewSize = bounds
        
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
        
    }
    
    override func prepareOpenGL() {
        //  Set the clear color for the buffers.
        glCall(glClearColor(0.0, 0.0, 0.0, 1.0))
        
        //  //  //  //  //
        //              //
        //  Point VAO   //
        //              //
        //  //  //  //  //
        //  In order to draw with a glDraw* command, we need a VAO.  This VAO
        //  doesn't point to any input variables in a program because the
        //  hardcodedPointProgram is going to do all of the work.
        glCall(glGenVertexArrays(1, &pointVAO))
        //  //  //  //  //  //  //  //  //  //  //  //
        //                                          //
        //   Load triangle data into OpenGL Object  //
        //                                          //
        //  //  //  //  //  //  //  //  //  //  //  //
        glCall(glGenVertexArrays(1, &triangleVAO))
        glCall(glBindVertexArray(triangleVAO))
        
        glCall(glGenBuffers(1, &triangleVBO))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), triangleVBO))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Float3>.size * triangle.count, triangle, GLenum(GL_STATIC_DRAW)))
        
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 12, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(0))
        //  //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                                  //
        //   Load colored triangle data into OpenGL Object  //
        //                                                  //
        //  //  //  //  //  //  //  //  //  //  //  //  //  //
        glCall(glGenVertexArrays(1, &coloredTriangleVAO))
        glCall(glBindVertexArray(coloredTriangleVAO))
        
        glCall(glGenBuffers(1, &coloredTriangleVBO))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), coloredTriangleVBO))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<(Float3, Float4)>.size * coloredTriangle.count, coloredTriangle, GLenum(GL_STATIC_DRAW)))
        
        //  This VAO has been defined with the expectation that the shader to be
        //  used does not define a "layout" for each input.  When layout is not
        //  specified, the order of inputs counts down instead of up:
        //      if three inputs are defined, the first is equal to layout 2, and
        //      the last (third) is equal to layout 0
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float4)>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(0, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float4)>.stride), UnsafeRawPointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(0))
        //  //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                                  //
        //   Load textured triangle data into OpenGL Object  //
        //                                                  //
        //  //  //  //  //  //  //  //  //  //  //  //  //  //
        glCall(glGenVertexArrays(1, &texturedTriangleVAO))
        glCall(glBindVertexArray(texturedTriangleVAO))
        
        glCall(glGenBuffers(1, &texturedTriangleVBO))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), texturedTriangleVBO))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<(Float3, Float2)>.stride * texturedTriangle.count, texturedTriangle, GLenum(GL_STATIC_DRAW)))
        //  This VAO has been defined with the expectation that the shader to be
        //  used does not define a "layout" for each input.  When layout is not
        //  specified, the order of inputs counts down instead of up:
        //      if three inputs are defined, the first is equal to layout 2, and
        //      the last (third) is equal to layout 0
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float2)>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(1))
        glCall(glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float2)>.stride), UnsafeRawPointer(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(0))
        //  Load the texture to be drawn
        glCall(glGenTextures(1, &checkerTextureTBO))
        glCall(glBindTexture(GLenum(GL_TEXTURE_2D), checkerTextureTBO))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR))
        
        /// Setup the texture by loading the image from the XCAsset catalog, then loading it into the TBO.
        /// Procedurally generated rainbow cross checker board
        let width = 512
        let height = 512
        let componentsPerPoint = 4

        let bitmap = UnsafeMutableRawPointer.allocate(byteCount: width * componentsPerPoint * height, alignment: 1)
        bitmap.initializeMemory(as: UInt32.self, repeating: 0xFFFF_FFFF, count: width * componentsPerPoint * height)
        
        if let context = CGContext(data: bitmap,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: width * componentsPerPoint,
                                   space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
    
    //  MARK: CoreGraphics Texture
            /// 1. Write a call callback
            /// 2. Set up colored pattern color space
            /// 3. Set up anatomy of colored pattern
            /// 4. Specify colored pattern as fill or stroke pattern
            /// 5. Draw with colored pattern
            ///
            /// 1. Create the callback function which holds the draw pattern that is to be repeated.
            let drawCheckerCallback: CGPatternDrawPatternCallback = { (info: UnsafeMutableRawPointer?, context: CGContext) in
                let patternSize = 96
                let squareSize = 48
                
                context.setFillColor(CGColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1))
                context.fill(CGRect(x: 0, y: 0, width: patternSize, height: patternSize))
                
                context.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
                context.fill(CGRect(x: 0, y: 0, width: squareSize, height: squareSize))
                context.setFillColor(CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
                context.fill(CGRect(x: squareSize, y: squareSize, width: squareSize, height: squareSize))
            }
            if let patternSpace = CGColorSpace(patternBaseSpace: nil) {
                context.setFillColorSpace(patternSpace)
            }
            var checkerCallbacks = CGPatternCallbacks(version: 0,
                                                      drawPattern: drawCheckerCallback,
                                                      releaseInfo: nil)
            if let pattern = CGPattern(info: nil,
                                    bounds: CGRect(x: 0, y: 0, width: 96, height: 96),
                                    matrix: CGAffineTransform.identity,
                                    xStep: 96,
                                    yStep: 96,
                                    tiling: .constantSpacing,
                                    isColored: true,
                                    callbacks: &checkerCallbacks) {
                var alpha: CGFloat = 1
                context.setFillPattern(pattern,
                                   colorComponents: &alpha)
                context.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            }
            
            let drawRainbowCallback: CGPatternDrawPatternCallback = { (info: UnsafeMutableRawPointer?, context: CGContext) in
                let thickness = 8
                let length = 32
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 8, y: 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 8, y: 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 8, y: 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 8, y: 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 8, y: 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 20, y: 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 8, y: 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 2 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 2 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 20, y: 3 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 8, y: 3 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 4 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 4 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 20, y: 5 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 8, y: 5 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 6 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 6 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 20, y: 7 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 8, y: 7 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 8 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 8 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 2 * 48 + 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 4 * 48 + 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 6 * 48 + 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 8 * 48 + 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 20, y: 9 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 10 * 48 + 8, y: 9 * 48 + 20, width: length, height: thickness))
                
                
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 3 * 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 5 * 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 7 * 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1))
                context.fill(CGRect(x: 9 * 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
                
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 20, y: 10 * 48 + 8, width: thickness, height: length))
                context.setFillColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1))
                context.fill(CGRect(x: 11 * 48 + 8, y: 10 * 48 + 20, width: length, height: thickness))
            }
            var colorCallbacks = CGPatternCallbacks(version: 0,
                                                    drawPattern: drawRainbowCallback,
                                                    releaseInfo: nil)
            if let pattern = CGPattern(info: nil,
                                       bounds: CGRect(x: 0, y: 0, width: 576, height: 576),
                                       matrix: CGAffineTransform.identity,
                                       xStep: 576,
                                       yStep: 576,
                                       tiling: .constantSpacing,
                                       isColored: true,
                                       callbacks: &colorCallbacks) {
                var alpha: CGFloat = 1
                context.setFillPattern(pattern,
                                       colorComponents: &alpha)
                context.fill(CGRect(x: 0, y: 0, width: 512, height: 512))
            }
            glCall(glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 512, 512, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), context.data))
        }

        bitmap.deallocate()

        //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                              //
        //  Load textured cube data into OpenGL Object  //
        //                                              //
        //  //  //  //  //  //  //  //  //  //  //  //  //
        /// Request two VBO's:   indices and vertices.  Then fill the index and vertex buffers.
        glCall(glGenVertexArrays(1, &texturedCubeVAO))
        glCall(glBindVertexArray(texturedCubeVAO))
        
        glCall(glGenBuffers(1, &texturedCubeVBOIndex))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), texturedCubeVBOIndex))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.stride * texturedCube.indices.count, texturedCube.indices, GLenum(GL_STATIC_DRAW)))
        glCall(glGenBuffers(1, &texturedCubeVBOVertex))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), texturedCubeVBOVertex))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<(Float3, Float4, Float2)>.stride * texturedCube.vertices.count, texturedCube.vertices, GLenum(GL_STATIC_DRAW)))
        /// Setup the VAO to assign segments of the buffer as inputs for a shader.
        glCall(glEnableVertexAttribArray(0))
        glCall(glEnableVertexAttribArray(1))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float4, Float2)>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glVertexAttribPointer(1, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float4, Float2)>.stride), UnsafeRawPointer(bitPattern: 12)))
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float4, Float2)>.stride), UnsafeRawPointer(bitPattern: 28)))
        //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                              //
        //    Load lit cube data into OpenGL Object     //
        //                                              //
        //  //  //  //  //  //  //  //  //  //  //  //  //
        /// Request two VBO's:  returned as an array of VBO ID's.  Then fill the index and vertex buffers.
        glCall(glGenVertexArrays(1, &litCubeVAO))
        glCall(glBindVertexArray(litCubeVAO))
        
        glCall(glGenBuffers(1, &litCubeVBOIndex))
        glCall(glGenBuffers(1, &litCubeVBOVertex))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), litCubeVBOIndex))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), litCubeVBOVertex))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.stride * litCube.indices.count, litCube.indices, GLenum(GL_STATIC_DRAW)))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<(Float3, Float3, Float4)>.stride * litCube.vertices.count, litCube.vertices, GLenum(GL_STATIC_DRAW)))
        /// Setup the VAO to assign segments of the buffer as inputs for a shader.
        glCall(glEnableVertexAttribArray(0))
        glCall(glEnableVertexAttribArray(1))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float4)>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float4)>.stride), UnsafeRawPointer(bitPattern: 12)))
        glCall(glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float4)>.stride), UnsafeRawPointer(bitPattern: 24)))
        //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                                      //
        //    Load lit textured cube data into OpenGL Object    //
        //                                                      //
        //  //  //  //  //  //  //  //  //  //  //  //  //  //  //
        glCall(glGenVertexArrays(1, &litTextureCubeVAO))
        glCall(glBindVertexArray(litTextureCubeVAO))
        
        glCall(glGenBuffers(1, &litTextureCubeVBOIndex))
        glCall(glGenBuffers(1, &litTextureCubeVBOVertex))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), litTextureCubeVBOIndex))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), litTextureCubeVBOVertex))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.stride * litTextureCube.indices.count, litTextureCube.indices, GLenum(GL_STATIC_DRAW)))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<(Float3, Float3, Float2)>.stride * litTextureCube.vertices.count, litTextureCube.vertices, GLenum(GL_STATIC_DRAW)))
        /// Setup the VAO to assign segments of the buffer as inputs for a shader.
        glCall(glEnableVertexAttribArray(0))
        glCall(glEnableVertexAttribArray(1))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float2)>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float2)>.stride), UnsafeRawPointer(bitPattern: 12)))
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<(Float3, Float3, Float2)>.stride), UnsafeRawPointer(bitPattern: 24)))
        //  //  //  //  //  //  //  //  //  //  //  //
        //                                          //
        //   Load sphere data into OpenGL Object    //
        //                                          //
        //  //  //  //  //  //  //  //  //  //  //  //
        /// Setup buffer to hold data (Array Buffers hold arrays of vertex data usually).
        glCall(glGenVertexArrays(1, &sphereVAO))
        glCall(glBindVertexArray(sphereVAO))
        
        glCall(glGenBuffers(1, &sphereVBOIndex))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), sphereVBOIndex))
        glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt32>.size * sphere.0.count, sphere.0, GLenum(GL_STATIC_DRAW)))
        glCall(glGenBuffers(1, &sphereVBOVertex))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), sphereVBOVertex))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Vertex>.size * sphere.1.count, sphere.1, GLenum(GL_STATIC_DRAW)))
        /// Setup data layout.  When this layout is bound, glDraw* will utilize the data buffer above as it was bound during setup.
        glCall(glEnableVertexAttribArray(0))
        glCall(glEnableVertexAttribArray(1))
        glCall(glEnableVertexAttribArray(2))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), UnsafeRawPointer(bitPattern: 0)))
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), UnsafePointer(bitPattern: 12)))
        glCall(glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<Vertex>.stride), UnsafeRawPointer(bitPattern: 24)))
        
        glCall(glBindVertexArray(0))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0))
        glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0))
        
        //  //  //  //  //  //
        //                  //
        //  Program setup   //
        //                  //
        //  //  //  //  //  //
        // MARK: - OpenGL Demo Programs
        
        
        
        //  MARK: Hardcoded Point
        /// hardecodedPointProgram
        ///   - draws a single vertex to the center of the screen.
        hardcodedPointProgram = glCall(glCreateProgram())
        var vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        var source = """
        #version 330 core

        void main() {
            gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
        }
        """
        var sourcePtr: [CChar]? = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        var compiled: GLint = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile hardcoded vertex, getting log")
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
        var fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        out vec4 outColor;
        
        void main() {
            outColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile hardcoded fragment, getting log")
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
        glCall(glAttachShader(hardcodedPointProgram, vs))
        glCall(glAttachShader(hardcodedPointProgram, fs))
        glCall(glLinkProgram(hardcodedPointProgram))
        var linked: GLint = 0
        glCall(glGetProgramiv(hardcodedPointProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link hardcodedProgram, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(hardcodedPointProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(hardcodedPointProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        // MARK: Input Vertex Position
        /// positionProgram
        ///   - allows vertex input to draw complex models
        positionProgram = glCall(glCreateProgram())
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        in vec3 position;
        
        void main() {
            gl_Position = vec4(position, 1.0);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile position vertex, getting log")
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
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core

        out vec4 outColor;
        
        void main() {
            outColor = vec4(1.0, 1.0, 1.0, 1.0);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile position fragement, getting log")
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
        glCall(glAttachShader(positionProgram, vs))
        glCall(glAttachShader(positionProgram, fs))
        glCall(glLinkProgram(positionProgram))
        linked = 0
        glCall(glGetProgramiv(positionProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link positionProgram, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(positionProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(positionProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK: colorProgram
        /// Input Position and Color
        ///   - allows position and color input into the program
        colorProgram = glCall(glCreateProgram())
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core

        in vec3 position;
        in vec4 inColor;

        out vec4 color;

        void main() {
            gl_Position = vec4(position, 1.0);

            color = inColor;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile color vertex, getting log")
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
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        in vec4 color;
        
        out vec4 outColor;
        
        void main() {
            outColor = color;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile color fragement, getting log")
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
        glCall(glAttachShader(colorProgram, vs))
        glCall(glAttachShader(colorProgram, fs))
        glCall(glLinkProgram(colorProgram))
        linked = 0
        glCall(glGetProgramiv(colorProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link color program, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(colorProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(colorProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))

        //  MARK: textureProgram
        /// Input Position and Texture
        ///   - allows input of position and texture in the program
        textureProgram = glCall(glCreateProgram())
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        in vec3 position;
        in vec2 inUV;
        
        out vec2 uv;
        
        void main() {
            gl_Position = vec4(position, 1.0);
        
            uv = inUV;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile texture vertex, getting log")
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
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform sampler2D sample;
        
        in vec2 uv;
        
        out vec4 outColor;
        
        void main() {
            outColor = vec4(1.0, 1.0, 1.0, 1.0) * texture(sample, uv);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile texture fragement, getting log")
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
        glCall(glAttachShader(textureProgram, vs))
        glCall(glAttachShader(textureProgram, fs))
        glCall(glLinkProgram(textureProgram))
        linked = 0
        glCall(glGetProgramiv(textureProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link texture program, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(textureProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(textureProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK: threeDimensionalProgram
        /// threeDimensionalProgram
        ///   - draws a three dimensional shape
        threeDimensionalProgram = glCall(glCreateProgram())
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        uniform mat4 projection;
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec4 inColor;
        layout (location = 2) in vec2 inUV;
        
        out vec4 color;
        out vec2 uv;
        
        void main() {
            gl_Position = projection * vec4(position, 1.0);
        
            color = inColor;
            uv = inUV;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile 3D vertex, getting log")
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
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform sampler2D sample;
        
        in vec4 color;
        in vec2 uv;
        
        out vec4 outColor;
        
        void main() {
            outColor = color * texture(sample, uv);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile 3D fragement, getting log")
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
        glCall(glAttachShader(threeDimensionalProgram, vs))
        glCall(glAttachShader(threeDimensionalProgram, fs))
        glCall(glLinkProgram(threeDimensionalProgram))
        linked = 0
        glCall(glGetProgramiv(threeDimensionalProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link 3D program, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(threeDimensionalProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(threeDimensionalProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK: threeDimensionalWithViewerProgram
        /// threeDimensionalWithViewerProgram
        ///   - draws a three dimensional shape
        threeDimensionalWithViewerProgram = glCall(glCreateProgram())
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        uniform mat4 projection;
        uniform mat4 view;
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec4 inColor;
        layout (location = 2) in vec2 inUV;
        
        out vec4 color;
        out vec2 uv;
        
        void main() {
            gl_Position = projection * view * vec4(position, 1.0);
        
            color = inColor;
            uv = inUV;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile 3D vertex, getting log")
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
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform sampler2D sample;
        
        in vec4 color;
        in vec2 uv;
        
        out vec4 outColor;
        
        void main() {
            outColor = color * texture(sample, uv);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile 3D fragement, getting log")
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
        glCall(glAttachShader(threeDimensionalWithViewerProgram, vs))
        glCall(glAttachShader(threeDimensionalWithViewerProgram, fs))
        glCall(glLinkProgram(threeDimensionalWithViewerProgram))
        linked = 0
        glCall(glGetProgramiv(threeDimensionalWithViewerProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link 3D program, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(threeDimensionalWithViewerProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(threeDimensionalWithViewerProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK: directionLightProgram
        /// Phong Shading:  direction light
        ///   - draws a three dimensional shape with a light source that shines equally in all directions
        directionLightProgram = glCall(glCreateProgram())
        /// Direction Light Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        layout (location = 0) in vec3 vPosition;
        layout (location = 1) in vec3 vNormal;
        layout (location = 2) in vec4 vColor;
        
        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 normalMatrix;
        
        out vec3 normal;
        out vec4 color;

        void main() {
            gl_Position = projection * view * vec4(vPosition, 1.0);
            normal = normalize(normalMatrix * vec4(vNormal, 0.0)).xyz;
            color = vColor;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
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
        /// Direction Light  Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform struct Light {
           vec3 ambient;
           vec3 color;
           vec3 direction;
           vec3 halfVector;
           float shininess;
           float strength;
        } light;
        
        in vec3 normal;
        in vec4 color;
        
        out vec4 outColor;
        
        void main() {
            //  Compute the cosine to use for calculating reflections
            float diffuse = max(0.0, dot(normal, light.direction));
            float specular = max(0.0, dot(normal, light.halfVector));

            //  Show surfaces facing away from the light in shadow
            if (diffuse <= 0.0) {
                specular = 0.0;
            } else {
                specular = pow(specular, light.shininess);    //  Sharpens light
            }

            vec3 scatteredLight = light.ambient + light.color * diffuse;
            vec3 reflectedLight = light.color * specular * light.strength;

            vec3 rgb = min(color.rgb * scatteredLight + reflectedLight, vec3(1.0));
            outColor = vec4(rgb, color.a);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
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
        glCall(glAttachShader(directionLightProgram, vs))
        glCall(glAttachShader(directionLightProgram, fs))
        glCall(glLinkProgram(directionLightProgram))
        linked = 0
        glCall(glGetProgramiv(directionLightProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(directionLightProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(directionLightProgram, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK:  pointLightProgram
        /// Phong Shading:  point light
        ///   - draws a three dimensional shape with a light source that shines equally in all directions,
        ///     but unlike direction lights the diffuse portion fades as a surface faces away from the source
        pointLightProgram = glCall(glCreateProgram())
        /// Point Light Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core

        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 normalMatrix;

        layout (location = 0) in vec3 vPosition;
        layout (location = 1) in vec3 vNormal;
        layout (location = 2) in vec4 vColor;

        out vec3 viewerPosition;
        out vec3 position;
        out vec3 normal;
        out vec4 color;

        void main() {
            viewerPosition = view[3].xyz;
            gl_Position = projection * view * vec4(vPosition, 1.0);
            position = (view * vec4(vPosition, 1.0)).xyz;
            normal = normalize(normalMatrix * vec4(vNormal, 1.0)).xyz;
            color = vColor;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
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
        /// Point Light  Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform struct Light {
           vec3 ambient;
           vec3 color;
           vec3 position;
           float shininess;
           float strength;
        } light;
        
        uniform float constantAttenuation;
        uniform float linearAttenuation;
        uniform float quadraticAttenuation;

        in vec3 viewerPosition;
        in vec3 position;
        in vec3 normal;
        in vec4 color;
        
        out vec4 outColor;
        
        void main() {
            //  Find direction and distance to light from this fragment
            vec3 lightDirection = light.position - position;
            float lightDistance = length(lightDirection);

            //  Normalize the light direction vector in order to calculate cosine
            lightDirection = lightDirection / lightDistance;

            //  Find the amount of light available for this fragment
            float attenuation = 1.0 / (constantAttenuation + linearAttenuation * lightDistance + quadraticAttenuation * lightDistance * lightDistance);

            //  Find intensity of highlight at this fragment
            vec3 halfVector = normalize(lightDirection + viewerPosition);

            float diffuse = max(0.0, dot(normal, lightDirection));
            float specular = max(0.0, dot(normal, halfVector));

            if (diffuse <= 0.0) {
                specular = 0.0;
            } else {
                specular = pow(specular, light.shininess) * light.strength;
            }

            vec3 scatteredLight = light.ambient + light.color * diffuse * attenuation;
            vec3 reflectedLight = light.color * specular * attenuation;
            vec3 rgb = min(color.rgb * scatteredLight + reflectedLight, vec3(1.0));

            outColor = vec4(rgb, color.a);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
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
        glCall(glAttachShader(pointLightProgram, vs))
        glCall(glAttachShader(pointLightProgram, fs))
        glCall(glLinkProgram(pointLightProgram))
        linked = 0
        glCall(glGetProgramiv(pointLightProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(pointLightProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(pointLightProgram, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK:  spotLightProgram
        /// Phong Shading:  spot light
        ///   - draws a three dimensional shape with a light source that shines a focused
        ///     beam of light in a given direction
        spotLightProgram = glCall(glCreateProgram())
        /// Spot Light Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core

        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 normalMatrix;

        layout (location = 0) in vec3 vPosition;
        layout (location = 1) in vec3 vNormal;
        layout (location = 2) in vec4 vColor;

        out vec3 viewerPosition;
        out vec3 position;
        out vec3 normal;
        out vec4 color;

        void main() {
            viewerPosition = view[3].xyz;
            gl_Position = projection * view * vec4(vPosition, 1.0);
            position = (view * vec4(vPosition, 1.0)).xyz;
            normal = normalize(normalMatrix * vec4(vNormal, 1.0)).xyz;
            color = vColor;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
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
        /// Spot Light  Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform struct Light {
            vec3 ambient;
            vec3 color;
            vec3 position;
            float shininess;
            float strength;
            vec3 coneDirection;
            float cosCutOff;
            float exponent;
        } light;
        
        uniform float constantAttenuation;
        uniform float linearAttenuation;
        uniform float quadraticAttenuation;

        in vec3 viewerPosition;
        in vec3 position;
        in vec3 normal;
        in vec4 color;
        
        out vec4 outColor;
        
        void main() {
            //  Find direction and distance to light from this fragment
            vec3 lightDirection = light.position - position;
            float lightDistance = length(lightDirection);

            //  Normalize the light direction vector in order to calculate cosine
            lightDirection = lightDirection / lightDistance;

            //  Find the amount of light available for this fragment
            float attenuation = 1.0 / (constantAttenuation + linearAttenuation * lightDistance + quadraticAttenuation * lightDistance * lightDistance);

            //  Find proximity to the spot
            float spotCos = dot(lightDirection, -light.coneDirection);

            if (spotCos < light.cosCutOff)
                attenuation = 0.0;
            else
                attenuation *= pow(spotCos, light.exponent);

            //  Find intensity of highlight at this fragment
            vec3 halfVector = normalize(lightDirection + viewerPosition);

            float diffuse = max(0.0, dot(normal, lightDirection));
            float specular = max(0.0, dot(normal, halfVector));

            if (diffuse <= 0.0)
                specular = 0.0;
            else
                specular = pow(specular, light.shininess) * light.strength;

            vec3 scatteredLight = light.ambient + light.color * diffuse * attenuation;
            vec3 reflectedLight = light.color * specular * attenuation;
            vec3 rgb = min(color.rgb * scatteredLight + reflectedLight, vec3(1.0));

            outColor = vec4(rgb, color.a);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
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
        glCall(glAttachShader(spotLightProgram, vs))
        glCall(glAttachShader(spotLightProgram, fs))
        glCall(glLinkProgram(spotLightProgram))
        linked = 0
        glCall(glGetProgramiv(spotLightProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(spotLightProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(spotLightProgram, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  MARK:  hemisphereLightProgram
        /// Phong Shading:  hemisphere light
        ///   - draws a three dimensional shape with a sky and ground lighting model
        hemisphereLightProgram = glCall(glCreateProgram())
        /// Hemisphere Light Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core

        uniform mat4 projection;
        uniform mat4 view;
        uniform mat4 normalMatrix;

        layout (location = 0) in vec3 vPosition;
        layout (location = 1) in vec3 vNormal;
        layout (location = 2) in vec2 vUV;

        out vec3 position;
        out vec3 normal;
        out vec2 uv;

        void main() {
            gl_Position = projection * view * vec4(vPosition, 1.0);
            position = (view * vec4(vPosition, 1.0)).xyz;
            normal = normalize(normalMatrix * vec4(vNormal, 1.0)).xyz;
            uv = vUV;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
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
        /// Hemisphere Light  Fragment Shader ///
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = """
        #version 330 core
        
        uniform sampler2D sample;

        uniform struct Light {
            vec3 position;
            vec3 skyColor;
            vec3 groundColor;
        } light;

        in vec3 position;
        in vec3 normal;
        in vec2 uv;
        
        out vec4 outColor;
        
        void main() {
            vec3 lightVector = normalize(light.position - position);
            float cosTheta = dot(normal, lightVector);
            float a = cosTheta * 0.5 + 0.5;
            vec4 textureColor =  texture(sample, uv);
            vec3 environmentColor = mix(light.groundColor, light.skyColor, a);
            outColor = vec4(environmentColor * textureColor.rgb, textureColor.a);
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
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
        glCall(glAttachShader(hemisphereLightProgram, vs))
        glCall(glAttachShader(hemisphereLightProgram, fs))
        glCall(glLinkProgram(hemisphereLightProgram))
        linked = 0
        glCall(glGetProgramiv(hemisphereLightProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(hemisphereLightProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(hemisphereLightProgram, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
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
        source = """
        #version 330 core
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec3 normal;
        layout (location = 2) in vec2 coordinate;
        out VertexData {
            vec3 position;
            vec3 normal;
            vec2 coordinate;
            vec3 cameraPosition;
        } vs_out;
        uniform mat4 view;
        uniform mat4 projection;
        void main()
        {
            gl_Position = projection * view * vec4(position, 1.0);
            vs_out.position = position;
            vs_out.normal = normalize(normal);
            vs_out.coordinate = coordinate;
            vs_out.cameraPosition = view[3].xyz;
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(vs, 1, sourcePtrPtr, nil))
        }
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
        source = """
        #version 330 core
        layout (lines_adjacency) in;
        layout (triangle_strip, max_vertices = 6) out;
        in VertexData {
            vec3 position;
            vec3 normal;
            vec2 coordinate;
            vec3 cameraPosition;
        } gd_in[4];
        out GeometryData {
            vec3 position;
            vec3 normal;
            vec2 coordinate;
        } gd_out;
        out vec3 points[4];
        out vec3 cameraPosition;
        void main() {
            //  Establish constant parameters across the Quad
            points = vec3[](
                gd_in[0].position,
                gd_in[1].position,
                gd_in[2].position,
                gd_in[3].position
            );
            vec3 camera = gd_in[0].cameraPosition;
            //  Define individual variants for each vertex
            gl_Position = gl_in[0].gl_Position;
            gd_out.position = gd_in[0].position;
            gd_out.normal = gd_in[0].normal;
            gd_out.coordinate = gd_in[0].coordinate;
            EmitVertex();
            gl_Position = gl_in[1].gl_Position;
            gd_out.position = gd_in[1].position;
            gd_out.normal = gd_in[1].normal;
            gd_out.coordinate = gd_in[1].coordinate;
            EmitVertex();
            gl_Position = gl_in[2].gl_Position;
            gd_out.position = gd_in[2].position;
            gd_out.normal = gd_in[2].normal;
            gd_out.coordinate = gd_in[2].coordinate;
            EmitVertex();
            EndPrimitive();
            gl_Position = gl_in[3].gl_Position;
            gd_out.position = gd_in[3].position;
            gd_out.normal = gd_in[3].normal;
            gd_out.coordinate = gd_in[3].coordinate;
            EmitVertex();
            gl_Position = gl_in[2].gl_Position;
            gd_out.position = gd_in[2].position;
            gd_out.normal = gd_in[2].normal;
            gd_out.coordinate = gd_in[2].coordinate;
            EmitVertex();
            gl_Position = gl_in[1].gl_Position;
            gd_out.position = gd_in[1].position;
            gd_out.normal = gd_in[1].normal;
            gd_out.coordinate = gd_in[1].coordinate;
            EmitVertex();
            EndPrimitive();
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(gs, 1, sourcePtrPtr, nil))
        }
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
        source = """
        #version 330 core
        uniform sampler2D sample;
        uniform struct Light {
            vec3 color;
            vec3 position;
            float ambient;
            float specStrength;
            float specHardness;
        } light;
        in GeometryData {                                                                  
            vec3 position;
            vec3 normal;
            vec2 coordinate;
        } fs_in;
        in vec3 cameraPosition;
        in vec3 points[4];
        out vec4 outColor;
        float wedge2D(vec2 a, vec2 b) {
            return (a.x * b.y - a.y * b.x);
        }
        void main() {
            vec2 q = fs_in.position.xz - points[0].xz;
            vec2 b1 = points[1].xz - points[0].xz;
            vec2 b2 = points[2].xz - points[0].xz;
            vec2 b3 = points[0].xz - points[1].xz - points[2].xz + points[3].xz;
            float A = wedge2D(b2, b3);
            float B = wedge2D(b3, q) - wedge2D(b1, b2);
            float C = wedge2D(b1, q);
            float v = abs(A) < 0.001 ? -C/B : (0.5 * (-B + sqrt(B * B - 4 * A * C)) / A);
            float u;
            vec2 denominator = b1 + v * b3;
            if (abs(denominator.x) > abs(denominator.y)) {
                u = (q.x - b2.x * v) / denominator.x;
            } else {
                u = (q.y - b2.y * v) / denominator.y;
            }
            outColor = texture(sample, vec2(u, v));
        }
        """
        sourcePtr = source.cString(using: String.Encoding.ascii)
        withUnsafePointer(to: sourcePtr) { (sourcePtrPtr: UnsafePointer<UnsafePointer<CChar>?>) in
            glCall(glShaderSource(fs, 1, sourcePtrPtr, nil))
        }
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
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(gs))
        glCall(glDeleteShader(fs))
        
        ///  Unbind the program
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

        ///  Attach the colorand depth renderbuffers to the framebuffer.
        glCall(glGenFramebuffers(1, &fbo))
        glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo))
        glCall(glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRBO))
        glCall(glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRBO))
        glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0))
        
        ///  Set general enables:  will require being turned off and then back on during
        ///  drawing in some instances.
        glCall(glEnable(GLenum(GL_DEPTH_TEST)))
        glCall(glEnable(GLenum(GL_CULL_FACE)))
        
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
            ///  Not sure why, but when trying to work with the UnsafeMutableRawPointer
            ///  directly through the instance methods bindMemory(_:_:) and assumingMemoryBound(_:)
            ///  an EXC_I386_GPFLT is generated.  By the documentation, it would seem
            ///  preferable to use either of these methods instead of unsafeBitCast(_:_:).
//            displayLinkContext?.bindMemory(to: GraphicView.self, capacity: MemoryLayout<GraphicView>.size).pointee.drawView()
//            displayLinkContext?.assumingMemoryBound(to: GraphicView.self).pointee.drawView()
            unsafeBitCast(displayLinkContext, to: GraphicView.self).drawView()

            return kCVReturnSuccess
        }

        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
        
    //  MARK: Set up Organizer
        /// Set up the View Organizer to display the current set of OpenGL
        /// The orgainizer's viewSize is multiplied by 2 to accomodate for the increased resolution  on some high resolution displays.
        /// The OS stores view sizes as "pointer" and not "pixels".  Older displays use a 1:1 display, while newer displayers have twice
        /// or three times the number of pixels per point.
        organizer = ViewOrganizer(viewSize: ViewOrganizer.GridSize(width: Int(viewSize.width) * 2, height: Int(viewSize.height) * 2))
        /// concepts being discussed
        ///
        /// view 0:  cleared context
        organizer.addASpace()
        /// view 1:  point in 2D space
        organizer.addASpace()
        /// view 2:  colored triangle
        organizer.addASpace()
        /// view 3:  textured triangle
        organizer.addASpace()
        /// view 4:  textured cube in 3D space
        organizer.addASpace()
        /// view 5:  textured cube with view projection matrix
        organizer.addASpace()
        /// view 6:  lit cube (direction light)
        organizer.addASpace()
        /// view 7:  lit cube (point light)
        organizer.addASpace()
        /// view 8:  lit cube (spot light)
        organizer.addASpace()
        /// view 8:  lit cube (hemisphere light)
        organizer.addASpace()
        ///
        /// generate the view spaces for the current collection of views
        let grid = organizer.generateGrid()
        let spaceSize = organizer.calculateSpaceSize(forGrid: grid)
        organizer.layoutSpaces(withSize: spaceSize, forGrid: grid)
    }

    func drawView() {
        if let context = openGLContext {
            context.makeCurrentContext()
            context.lock()
            
            //  Clear the context
            glCall(glClearColor(1.0, 1.0, 1.0, 1.0))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT)))
            
            //  View Space 0 - display a cleared context
            //  Set current draw space using the organizer
            //  Set background to a random color for now
            var currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glEnable(GLenum(GL_SCISSOR_TEST)))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw a cleared view
            //  No draw calls

            //  View Space 1 - draw a point in 2D space
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(0.0, 0.0, 0.0, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw a point in 2D space
            glCall(glUseProgram(hardcodedPointProgram))
            glBindVertexArray(pointVAO)

            glCall(glPointSize(10))
            glCall(glDrawArrays(GLenum(GL_POINTS), 0, 1))

            //  View Space 2 - draw a colored triangle
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw colored triangle
            glCall(glUseProgram(colorProgram))
            glCall(glBindVertexArray(coloredTriangleVAO))

            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(coloredTriangle.count)))

            //  View Space 3 - draw a textured triangle
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw textured triangle
            glCall(glUseProgram(textureProgram))
            glCall(glBindVertexArray(texturedTriangleVAO))
            glCall(glBindTexture(GLenum(GL_TEXTURE_2D), checkerTextureTBO))
            
            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(texturedTriangle.count)))
            
            //  View Space 4 - draw a cube in 3D space
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw textured Cube
            glCall(glUseProgram(threeDimensionalProgram))
            glCall(glBindVertexArray(texturedCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(threeDimensionalProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))
            
            //  View Space 5 - draw a cube in 3D space with user defined viewing position
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw textured Cube
            glCall(glUseProgram(threeDimensionalWithViewerProgram))
            glCall(glBindVertexArray(texturedCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(threeDimensionalWithViewerProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(threeDimensionalWithViewerProgram, "view")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))
            
            //  View Space 6 - draw cube lit with a direction light
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw lit cube
            glCall(glUseProgram(directionLightProgram))
            glCall(glBindVertexArray(litCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(directionLightProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(directionLightProgram, "view")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(directionLightProgram, "normalMatrix")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniform3fv(glCall(glGetUniformLocation(directionLightProgram, "light.ambient")), 1, directionLight.ambient))
            glCall(glUniform3fv(glCall(glGetUniformLocation(directionLightProgram, "light.color")), 1, directionLight.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(directionLightProgram, "light.direction")), 1, directionLight.direction))
            glCall(glUniform3fv(glCall(glGetUniformLocation(directionLightProgram, "light.halfVector")), 1, directionLight.halfVector))
            glCall(glUniform1f(glCall(glGetUniformLocation(directionLightProgram, "light.shininess")), directionLight.shininess))
            glCall(glUniform1f(glCall(glGetUniformLocation(directionLightProgram, "light.strength")), directionLight.strength))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))
            
            //  View Space 7 - draw cube lit with a point light
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw lit cube
            glCall(glUseProgram(pointLightProgram))
            glCall(glBindVertexArray(litCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(pointLightProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(pointLightProgram, "view")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(pointLightProgram, "normalMatrix")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniform3fv(glCall(glGetUniformLocation(pointLightProgram, "light.ambient")), 1, pointLight.ambient))
            glCall(glUniform3fv(glCall(glGetUniformLocation(pointLightProgram, "light.color")), 1, pointLight.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(pointLightProgram, "light.position")), 1, pointLight.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(pointLightProgram, "light.shininess")), pointLight.shininess))
            glCall(glUniform1f(glCall(glGetUniformLocation(pointLightProgram, "light.strength")), pointLight.strength))
            glCall(glUniform1f(glCall(glGetUniformLocation(pointLightProgram, "constantAttenuation")), 0.5))
            glCall(glUniform1f(glCall(glGetUniformLocation(pointLightProgram, "linearAttenuation")), 0.5))
            glCall(glUniform1f(glCall(glGetUniformLocation(pointLightProgram, "quadraticAttenuation")), 0.5))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))
            
            //  View Space 8 - draw cube lit with a spot light
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw lit cube
            glCall(glUseProgram(spotLightProgram))
            glCall(glBindVertexArray(litCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(spotLightProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(spotLightProgram, "view")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(spotLightProgram, "normalMatrix")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniform3fv(glCall(glGetUniformLocation(spotLightProgram, "light.ambient")), 1, spotLight.ambient))
            glCall(glUniform3fv(glCall(glGetUniformLocation(spotLightProgram, "light.color")), 1, spotLight.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(spotLightProgram, "light.position")), 1, spotLight.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "light.shininess")), spotLight.shininess))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "light.strength")), spotLight.strength))
            glCall(glUniform3fv(glCall(glGetUniformLocation(spotLightProgram, "light.coneDirection")), 1, spotLight.coneDirection))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "light.cosCutOff")), spotLight.cosCutOff))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "light.exponent")), spotLight.exponent))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "constantAttenuation")), 0.5))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "linearAttenuation")), 0.5))
            glCall(glUniform1f(glCall(glGetUniformLocation(spotLightProgram, "quadraticAttenuation")), 0.5))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))

            //  View Space 9 - draw cube lit with a spot light
            currentDrawSpace = organizer.getNextSpace()
            glCall(glClearColor(currentDrawSpace.backgroundColor.x, currentDrawSpace.backgroundColor.y, currentDrawSpace.backgroundColor.z, 1.0))
            glCall(glScissor(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glViewport(GLint(currentDrawSpace.x), GLint(currentDrawSpace.y), GLsizei(currentDrawSpace.width), GLsizei(currentDrawSpace.height)))
            //  Draw lit cube
            glCall(glUseProgram(hemisphereLightProgram))
            glCall(glBindVertexArray(litTextureCubeVAO))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(hemisphereLightProgram, "projection")), 1, GLboolean(GL_FALSE), simd_float4x4().orthographic(width: Float(currentDrawSpace.width), height: Float(currentDrawSpace.height), nearZ: -Float(currentDrawSpace.width) * 2, farZ: Float(currentDrawSpace.width) * 2).scale(x: Float(currentDrawSpace.height) * 0.45, y: Float(currentDrawSpace.height) * 0.45, z: Float(currentDrawSpace.height) * 0.45).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(hemisphereLightProgram, "view")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(hemisphereLightProgram, "normalMatrix")), 1, GLboolean(GL_FALSE), simd_float4x4.identity().translate(x: cameraPosition.x, y: cameraPosition.y, z: cameraPosition.z).rotateAroundX(cameraRotation.x).rotateAroundY(cameraRotation.y).rotateAroundZ(cameraRotation.z).columnMajorArray()))
            glCall(glUniform3fv(glCall(glGetUniformLocation(hemisphereLightProgram, "light.position")), 1, hemisphereLight.position))
            glCall(glUniform3fv(glCall(glGetUniformLocation(hemisphereLightProgram, "light.skyColor")), 1, hemisphereLight.skyColor))
            glCall(glUniform3fv(glCall(glGetUniformLocation(hemisphereLightProgram, "light.groundColor")), 1, hemisphereLight.groundColor))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(numberOfTrianglesToDraw) * 3, GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: startTriangle * 12)))
            
            /// Reset Organizer queque so that we start from the first space at the next draw call
            organizer.resetNextSpace()
            
            /// Unbind OpenGL Objects now that drawing is complete
            /// This will avoid making unintended changes to the last bound VAO
            glCall(glBindVertexArray(0))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), 0))
            glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0))
            glCall(glDisable(GLenum(GL_SCISSOR_TEST)))
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
        if let context = openGLContext {
            context.makeCurrentContext()
            context.lock()
            glCall(glDeleteVertexArrays(1, &pointVAO))
            glCall(glDeleteBuffers(1, &triangleVBO))
            glCall(glDeleteVertexArrays(1, &triangleVAO))
            glCall(glDeleteBuffers(1, &coloredTriangleVBO))
            glCall(glDeleteVertexArrays(1, &coloredTriangleVAO))
            glCall(glDeleteBuffers(1, &texturedTriangleVBO))
            glCall(glDeleteVertexArrays(1, &texturedTriangleVAO))
            glCall(glDeleteBuffers(1, &texturedCubeVBOIndex))
            glCall(glDeleteBuffers(1, &texturedCubeVBOVertex))
            glCall(glDeleteVertexArrays(1, &texturedCubeVAO))
            glCall(glDeleteBuffers(1, &litCubeVBOIndex))
            glCall(glDeleteBuffers(1, &litCubeVBOVertex))
            glCall(glDeleteVertexArrays(1, &litCubeVAO))
            glCall(glDeleteBuffers(1, &litTextureCubeVBOIndex))
            glCall(glDeleteBuffers(1, &litTextureCubeVBOVertex))
            glCall(glDeleteVertexArrays(1, &litTextureCubeVAO))
            glCall(glDeleteTextures(1, &checkerTextureTBO))
            glCall(glDeleteBuffers(1, &sphereVBOIndex))
            glCall(glDeleteBuffers(1, &sphereVBOVertex))
            glCall(glDeleteVertexArrays(1, &sphereVAO))
            glCall(glDeleteProgram(hardcodedPointProgram))
            glCall(glDeleteProgram(positionProgram))
            glCall(glDeleteProgram(colorProgram))
            glCall(glDeleteProgram(textureProgram))
            glCall(glDeleteProgram(threeDimensionalProgram))
            glCall(glDeleteProgram(threeDimensionalWithViewerProgram))
            glCall(glDeleteProgram(directionLightProgram))
            glCall(glDeleteProgram(pointLightProgram))
            glCall(glDeleteProgram(spotLightProgram))
            glCall(glDeleteProgram(hemisphereLightProgram))
            glCall(glDeleteProgram(textureInverseBilinearInterpolationID))
            glCall(glDeleteRenderbuffers(1, &colorRBO))
            glCall(glDeleteRenderbuffers(1, &depthRBO))
            glCall(glDeleteFramebuffers(1, &fbo))
            context.unlock()
        }
    }
}

