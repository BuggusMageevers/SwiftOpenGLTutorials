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

/// 3D space direction definitions:
/// X: Left => negative, Right => positive
/// Y: Down => negative, Up => positive
/// Z: Into screen => negative, Out of screen => positive
let triangle: [Float3] = [
    Float3(x: -0.5, y: -0.5, z: 0.0), Float3(x: 0.5, y: -0.5, z: 0.0), Float3(x: 0.0, y: 0.5, z: 0.0)
]
let texturedCube: (indices: [GLuint], vertices: [TexVertex]) = (
    indices: [
        0, 1, 2, 0, 2, 3,
        3, 2, 6, 3, 6, 5,
        4, 5, 6, 4, 6, 7,
        7, 6, 1, 7, 1, 0,
        7, 0, 3, 7, 3, 4,
        1, 6, 5, 1, 5, 2
    ],
    vertices: [
        TexVertex(position: Float3(x: -0.5, y:  0.5, z:  0.5), normal: Float3(x: -0.5, y:  0.5, z:  0.5), coordinate: Float2(x: 0.0, y: 1.0)),
        TexVertex(position: Float3(x: -0.5, y: -0.5, z:  0.5), normal: Float3(x: -0.5, y: -0.5, z:  0.5), coordinate: Float2(x: 0.0, y: 0.0)),
        TexVertex(position: Float3(x:  0.5, y: -0.5, z:  0.5), normal: Float3(x:  0.5, y: -0.5, z:  0.5), coordinate: Float2(x: 1.0, y: 0.0)),
        TexVertex(position: Float3(x:  0.5, y:  0.5, z:  0.5), normal: Float3(x:  0.5, y:  0.5, z:  0.5), coordinate: Float2(x: 1.0, y: 1.0)),
        
        TexVertex(position: Float3(x:  0.5, y:  0.5, z: -0.5), normal: Float3(x:  0.5, y:  0.5, z: -0.5), coordinate: Float2(x: 1.0, y: 1.0)),
        TexVertex(position: Float3(x:  0.5, y: -0.5, z: -0.5), normal: Float3(x:  0.5, y: -0.5, z: -0.5), coordinate: Float2(x: 1.0, y: 0.0)),
        TexVertex(position: Float3(x: -0.5, y: -0.5, z: -0.5), normal: Float3(x: -0.5, y: -0.5, z: -0.5), coordinate: Float2(x: 0.0, y: 0.0)),
        TexVertex(position: Float3(x: -0.5, y:  0.5, z: -0.5), normal: Float3(x: -0.5, y:  0.5, z: -0.5), coordinate: Float2(x: 0.0, y: 1.0))
    ]
)
let sphere = sphereMesh(withRadius: 0.5, longitudinalCuts: 20, latitudinalCuts: 20)
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

struct viewOrganizer {
    private var numberOfPanels: Int = 0
    private var spaces: [[(UInt, UInt)]] = [[]]
    private var viewBounds: (width: UInt, height: UInt) = (0, 0)
    
    mutating func addPanel() { numberOfPanels += 1 }
    private mutating func generateSpacesPanel() {
        var remaining = numberOfPanels
        var columnCount: Int = 0
        var rowCount: Int = 0
        var rawDimensions: ((UInt, UInt), (UInt, UInt), (UInt, UInt), UInt, UInt, UInt, UInt)!
        repeat {
            //  add a column
            columnCount += 1
            //  add a row to square the panel field
            rowCount += 1
            //  calculate spaces that need to be filled in the working column and row
            let fill = columnCount + (rowCount - 1)
            //  check if there are remaining panels to fill the spaces
            if remaining <= fill {
                //  spread remaining panels evenly across the last column and row
                let columnFill = remaining / 2 > 1 ? remaining / 2 : 1
                let rowFill = remaining - columnFill
                
                //  calculate view dimensions
                let width = viewBounds.width / UInt(columnCount)
                let height = viewBounds.height / UInt(rowCount)
                //  find left over pixels
                let nudgeWidth = viewBounds.width % UInt(columnCount)
                let nudgeHeight = viewBounds.height % UInt(rowCount)
                //  calculate the bounds for the spread panels (width or height will be different)
                let stretchWidth = viewBounds.width / UInt(columnFill)
                let stretchHeight = viewBounds.height / UInt(rowFill)
                //  find left over pixels
                let nudgeStretchWidth = viewBounds.width % UInt(columnFill)
                let nudgeStretchHeight = viewBounds.height % UInt(rowFill)
                
                //  calculate base space bounds
                let basicSpaceBounds = (width, height)
                //  calculate column stretched space bounds
                let columnStretchedSpaceBounds = (width, stretchHeight)
                //  calculate row stretched space bounds
                let rowStretchedSpaceBounds = (stretchWidth, height)
                
                rawDimensions = (basicSpaceBounds, columnStretchedSpaceBounds, rowStretchedSpaceBounds, nudgeWidth, nudgeHeight, nudgeStretchWidth, nudgeStretchHeight)
            } else {
                remaining -= fill
            }
        } while remaining > 0
        
        for column in 0..<(columnCount - 1) {
            for row in 0..<(rowCount - 1) {
                spaces[column][row] = (rawDimensions.0.0, rawDimensions.0.1)
            }
        }
    }
}

class GraphicView: NSOpenGLView {
    var triangleVBO: GLuint = 0
    var triangleVAO: GLuint = 0
    var texturedCubeVBO: [GLuint] = [0, 0]
    var texturedCubeVAO: GLuint = 0
    var cubeTexture: GLuint = 0
    var texturedCubeTBO: GLuint = 0
    var sphereVBO: [GLuint] = [0, 0]
    var sphereVAO: GLuint = 0
    var basicProgram: GLuint = 0
    var phongProgram: GLuint = 0
    var textureProgram: GLuint = 0
    var textureInverseBilinearInterpolationID: GLuint = 0
    var fbo: GLuint = 0
    var colorRBO: GLuint = 0
    var depthRBO: GLuint = 0
    
    var displayLink: CVDisplayLink?
    
    var modelMatrices = [
        FloatMatrix4().translate(x: -4, y:  4, z: 0),
        FloatMatrix4().translate(x: -2, y:  4, z: 0),
        FloatMatrix4().translate(x: -0, y:  4, z: 0),
        FloatMatrix4().translate(x:  2, y:  4, z: 0),
        FloatMatrix4().translate(x:  4, y:  4, z: 0),
        FloatMatrix4().translate(x: -4, y:  2, z: 0),
        FloatMatrix4().translate(x: -2, y:  2, z: 0),
        FloatMatrix4().translate(x: -0, y:  2, z: 0),
        FloatMatrix4().translate(x:  2, y:  2, z: 0),
        FloatMatrix4().translate(x:  4, y:  2, z: 0),
        FloatMatrix4().translate(x: -4, y:  0, z: 0),
        FloatMatrix4().translate(x: -2, y:  0, z: 0),
        FloatMatrix4().translate(x: -0, y:  0, z: 0),
        FloatMatrix4().translate(x:  2, y:  0, z: 0),
        FloatMatrix4().translate(x:  4, y:  0, z: 0),
        FloatMatrix4().translate(x: -4, y: -2, z: 0),
        FloatMatrix4().translate(x: -2, y: -2, z: 0),
        FloatMatrix4().translate(x: -0, y: -2, z: 0),
        FloatMatrix4().translate(x:  2, y: -2, z: 0),
        FloatMatrix4().translate(x:  4, y: -2, z: 0),
        FloatMatrix4().translate(x: -4, y: -4, z: 0),
        FloatMatrix4().translate(x: -2, y: -4, z: 0),
        FloatMatrix4().translate(x: -0, y: -4, z: 0),
        FloatMatrix4().translate(x:  2, y: -4, z: 0),
        FloatMatrix4().translate(x:  4, y: -4, z: 0)
    ]
    
    lazy var uniformMatrices = [
        "view" : FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0).rotateXAxis(0.5),
        "projection" : FloatMatrix4().perspective(angeOfView: 120,
                                                  aspect: Float(bounds.width / bounds.height),
                                                  distanceToNearClippingPlane: 0.01,
                                                  distanceToFarClippingPlane: 100)
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
        
    }
    
    override func prepareOpenGL() {
        //  Set the clear color for the buffers.
        glCall(glClearColor(0.0, 0.0, 0.0, 1.0))
        
        //  //  //  //  //  //  //  //  //  //  //  //
        //                                          //
        //   Load triangle data into OpenGL Object  //
        //                                          //
        //  //  //  //  //  //  //  //  //  //  //  //
        glCall(glGenBuffers(1, &triangleVBO))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), triangleVBO))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Float3>.size * triangle.count, triangle, GLenum(GL_STATIC_DRAW)))
        
        glCall(glGenVertexArrays(1, &triangleVAO))
        glCall(glBindVertexArray(triangleVAO))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 12, UnsafeRawPointer(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(0))
        //  //  //  //  //  //  //  //  //  //  //  //  //
        //                                              //
        //  Load textured cube data into OpenGL Object  //
        //                                              //
        //  //  //  //  //  //  //  //  //  //  //  //  //
        /// Request two VBO's:  returned as an array of VBO ID's.  Then fill the index and vertex buffers.
        withUnsafeMutablePointer(to: &texturedCubeVBO[0]) { texturedCubeVBOPointer in
            glCall(glGenBuffers(2, texturedCubeVBOPointer))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), texturedCubeVBOPointer[0]))
            glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.size * texturedCube.indices.count, texturedCube.indices, GLenum(GL_STATIC_DRAW)))
            glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), texturedCubeVBOPointer[1]))
            glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TexVertex>.size * texturedCube.vertices.count, texturedCube.vertices, GLenum(GL_STATIC_DRAW)))
        }
        withUnsafeMutablePointer(to: &texturedCubeVAO) { texturedCubeVAOPointer in
            /// Setup the VAO to assign segments of the buffer as inputs for a shader.
            glCall(glGenVertexArrays(1, texturedCubeVAOPointer))
            glCall(glBindVertexArray(texturedCubeVAOPointer.pointee))
            glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 0)))
            glCall(glEnableVertexAttribArray(0))
            glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 12)))
            glCall(glEnableVertexAttribArray(1))
            glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 32, UnsafeRawPointer(bitPattern: 24)))
            glCall(glEnableVertexAttribArray(2))
        }
        withUnsafeMutablePointer(to: &texturedCubeTBO) { texturedCubeTBOPointer in
            glCall(glGenTextures(1, texturedCubeTBOPointer))
            glCall(glActiveTexture(GLenum(GL_TEXTURE0)))
            glCall(glBindTexture(GLenum(GL_TEXTURE_2D), texturedCubeTBOPointer.pointee))
            glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR))
            glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR))
            glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT))
            glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT))
            /// Setup the texture by loading the image from the XCAsset catalog, then loading it into the TBO.
            guard let texture = NSImage(named: NSImage.Name(rawValue: "Texture"))?.tiffRepresentation else {
                print("Texture file could not be found or converted to a TIFF.")
                return
            }
            glCall(glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (texture as NSData).bytes))
        }

        //  //  //  //  //  //  //  //  //  //  //  //
        //                                          //
        //   Load sphere data into OpenGL Object    //
        //                                          //
        //  //  //  //  //  //  //  //  //  //  //  //
        /// Setup buffer to hold data (Array Buffers hold arrays of vertex data usually).
        withUnsafeMutablePointer(to: &sphereVBO[0]) { sphereVBOPointer in
            glCall(glGenBuffers(2, sphereVBOPointer))
            glCall((glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), sphereVBOPointer[0])))
            glCall(glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<UInt32>.size * sphere.1.count, sphere.0, GLenum(GL_STATIC_DRAW)))
            glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), sphereVBOPointer[1]))
            glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Vertex>.size * sphere.1.count, sphere.1, GLenum(GL_STATIC_DRAW)))
        }
        withUnsafeMutablePointer(to: &sphereVAO) { sphereVAOPointer in
            /// Setup data layout.  When this layout is bound, glDraw* will utilize the data buffer above as it was bound during setup.
            glCall(glGenVertexArrays(1, sphereVAOPointer))
            glCall(glBindVertexArray(sphereVAOPointer.pointee))
            glCall(glEnableVertexAttribArray(0))
            glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 0)))
            glCall(glEnableVertexAttribArray(1))
            glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer(bitPattern: 12)))
            glCall(glEnableVertexAttribArray(2))
            glCall(glVertexAttribPointer(2, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafeRawPointer(bitPattern: 24)))
        }
        
        //  //  //  //  //  //
        //                  //
        //  Program setup   //
        //                  //
        //  //  //  //  //  //
        basicProgram = glCall(glCreateProgram())
        /// Origin Vertex ///
        var vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        var source = """
        #version 330 core

        uniform vec4 color;
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        
        layout (location = 0) in vec3 position;

        out vec4 passColor;

        void main() {
            gl_Position = projection * view * model * vec4(position, 1.0);

            passColor = vec4(0, 0, 0, 1);
        }
        """
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
        source = """
        #version 330 core
        
        in vec4 passColor;
        
        out vec4 outColor;
        
        void main() {
            outColor = passColor;
        }
        """
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
        glCall(glAttachShader(basicProgram, vs))
        glCall(glAttachShader(basicProgram, fs))
        glCall(glLinkProgram(basicProgram))
        var linked: GLint = 0
        glCall(glGetProgramiv(basicProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(basicProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(basicProgram, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        ///  Mark shaders for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  //  //  //  //  //  //
        //                      //
        //    Phong Program     //
        //                      //
        //  //  //  //  //  //  //
        phongProgram = glCall(glCreateProgram())
        /// Phong Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec3 normal;
        layout (location = 2) in vec4 color;
        
        out vec3 passPosition;
        out vec3 passNormal;
        out vec4 passColor;
        out vec3 passCameraPosition;
        
        void main() {
            gl_Position = projection * view * model * vec4(position, 1.0);
            passPosition = position;
            passNormal = normalize(normal);
            passColor = color;
            passCameraPosition = view[3].xyz;
        }
        """
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
        source = """
        #version 330 core
        
        uniform struct Light {
           vec3 color;
           vec3 position;
           float ambient;
           float specStrength;
           float specHardness;
        } light;
        
        in vec3 passPosition;
        in vec3 passNormal;
        in vec4 passColor;
        in vec3 passCameraPosition;
        
        out vec4 outColor;
        
        void main() {
            vec3 normal = passNormal;
            vec3 lightRay = normalize(light.position - passPosition);
            float intensity = clamp(dot(normal, lightRay), 0, 1);
            vec3 viewer = normalize(passCameraPosition - passPosition);
            vec3 reflection = reflect(lightRay, normal);
            float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);
            outColor.rgb = passColor.rgb + light.ambient + light.color * intensity + light.specStrength * specular;
            outColor.a = passColor.a;
        }
        """
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
        glCall(glAttachShader(phongProgram, vs))
        glCall(glAttachShader(phongProgram, fs))
        glCall(glLinkProgram(phongProgram))
        linked = 0
        glCall(glGetProgramiv(phongProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(phongProgram, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(phongProgram, GLsizei(logLength), &logLength, cLog))
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        /// Mark shaders for deletion
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        /// Set up Uniforms (only required prior to making a call to a glDraw* call--this is an example).
        glCall(glUseProgram(phongProgram))
        //  Not necessary to do right now, but we can set a program's uniform values
        //  at this time.  More useful, would be to capture the "Locations" of the
        //  Uniform's for later use--fewer OpenGL calls a render time.
        glCall(glUniform1i(glCall(glGetUniformLocation(phongProgram, "sample")), GL_TEXTURE0))
        glCall(glUniform3fv(glCall(glGetUniformLocation(phongProgram, "light.color")), 1, light.color))
        glCall(glUniform3fv(glCall(glGetUniformLocation(phongProgram, "light.position")), 1, light.position))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongProgram, "light.ambient")), light.ambient))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongProgram, "light.specStrength")), light.specStrength))
        glCall(glUniform1f(glCall(glGetUniformLocation(phongProgram, "light.specHardness")), light.specHardness))
        
        //  //  //  //  //  //  //
        //                      //
        //  Textured Triangles  //
        //                      //
        //  //  //  //  //  //  //
        textureProgram = glCall(glCreateProgram())
        /// Texture Vertex Shader ///
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = """
        #version 330 core
        
        layout (location = 0) in vec3 position;
        layout (location = 1) in vec3 normal;
        layout (location = 2) in vec2 coordinate;
        
        uniform mat4 model;
        uniform mat4 view;
        uniform mat4 projection;
        
        out vec2 uv;
        
        void main() {
            gl_Position = projection * view * model * vec4(position, 1.0);
            uv = coordinate;
        }
        """
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
        source = """
        #version 330 core
        
        uniform sampler2D sample;
        
        in vec2 uv;
        
        out vec4 outColor;
        
        void main() {
            outColor = texture(sample, uv);
        }
        """
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
        glCall(glAttachShader(textureProgram, vs))
        glCall(glAttachShader(textureProgram, fs))
        glCall(glLinkProgram(textureProgram))
        linked = 0
        glCall(glGetProgramiv(textureProgram, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
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
        //  Mark shaders for deletion.
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
            //  Not sure why, but when trying to work with the UnsafeMutableRawPointer
            //  directly through the instance methods bindMemory(_:_:) and assumingMemoryBound(_:)
            //  an EXC_I386_GPFLT is generated.  By the documentation, it would seem
            //  preferable to use either of these methods instead of unsafeBitCast(_:_:).
//            displayLinkContext?.bindMemory(to: GraphicView.self, capacity: MemoryLayout<GraphicView>.size).pointee.drawView()
//            displayLinkContext?.assumingMemoryBound(to: GraphicView.self).pointee.drawView()
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
            
            //  Draw triangle
            glCall(glUseProgram(basicProgram))
            glCall(glBindVertexArray(triangleVAO))

            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(basicProgram, "model")), 1, GLboolean(GL_FALSE), modelMatrices[0].columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(basicProgram, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(basicProgram, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))
            
            glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(triangle.count)))
            
            //  Draw Cube
            glCall(glUseProgram(textureProgram))
            glCall(glBindVertexArray(texturedCubeVAO))

            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureProgram, "model")), 1, GLboolean(GL_FALSE), modelMatrices[1].columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureProgram, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureProgram, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))

            glCall(glDrawElements(GLenum(GL_TRIANGLES), Int32(texturedCube.indices.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))
            
            glCall(glUseProgram(phongProgram))
            glCall(glBindVertexArray(texturedCubeVAO))

            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongProgram, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]?.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(phongProgram, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]?.columnMajorArray()))

            glCall(glDrawElementsInstanced(GLenum(GL_TRIANGLES), Int32(texturedCube.indices.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0), 23))
            
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
        glCall(glDeleteBuffers(1, &triangleVBO))
        glCall(glDeleteVertexArrays(1, &triangleVAO))
        glCall(glDeleteBuffers(2, texturedCubeVBO))
        glCall(glDeleteVertexArrays(1, &texturedCubeVAO))
        glCall(glDeleteTextures(1, &texturedCubeTBO))
        glCall(glDeleteBuffers(2, &sphereVBO))
        glCall(glDeleteVertexArrays(1, &sphereVAO))
        glCall(glDeleteProgram(basicProgram))
        glCall(glDeleteProgram(phongProgram))
        glCall(glDeleteProgram(textureProgram))
        glCall(glDeleteProgram(textureInverseBilinearInterpolationID))
        glCall(glDeleteRenderbuffers(1, &colorRBO))
        glCall(glDeleteRenderbuffers(1, &depthRBO))
        glCall(glDeleteFramebuffers(1, &fbo))
    }
}

