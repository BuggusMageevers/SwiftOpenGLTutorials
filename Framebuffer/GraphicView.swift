//
//  GraphicView.swift
//  Framebuffer
//
//  Created by Myles Schultz on 6/9/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3

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
// X: negative = Left, positive = Right
// Y: negative = Down, positive = Up
// Z: negative = Into screen, positive = Out of screen
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
    TexVertex(position: Float3(x: -1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 0.0)),
    TexVertex(position: Float3(x:  1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 0.0)),
    TexVertex(position: Float3(x: -1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 1.0)),
    
    TexVertex(position: Float3(x:  1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 1.0)),
    TexVertex(position: Float3(x: -1.0, y:  0.0, z:  1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 0.0, y: 1.0)),
    TexVertex(position: Float3(x:  1.0, y:  0.0, z: -1.0), normal: Float3( x:  0.0,  y:  1.0,  z:  0.0), coordinate: Float2(x: 1.0, y: 0.0))
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
    var counter: UInt32 = 0
    while counter <= sides - 1 {
        let pointA = rotationMatrix * Float2(x: 0.0, y: radius - thickness)
        let pointB = rotationMatrix * Float2(x: 0.0, y: radius)
        points.append(pointA)
        points.append(pointB)
        rotationMatrix = rotationMatrix.affineClockwiseRotate(turnRadians)
        counter += 1
    }
    
    var indices: [UInt32] = []
    counter = 0
    while counter < (sides * 2) - 2 {
        indices += [counter, counter + 1, counter + 2, counter + 3]
        counter += 2
    }
    indices += [counter, counter + 1, (counter + 2) - UInt32(sides * 2), (counter + 3) - UInt32(sides * 2)]
    
    var vertices: [TexVertex] = []
    counter = 0
    var zeroCoord = true
    while counter < (2 * sides) - 2 {
        let normalA = Float3(x: (points[Int(counter)] - points[Int(counter + 1)]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 1)]).y).crossProduct(Float3(x: (points[Int(counter)] - points[Int(counter + 3)]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 3)]).y)).unitVector()
        let normalB = Float3(x: (points[Int(counter)] - points[Int(counter + 3)]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 3)]).y).crossProduct(Float3(x: (points[Int(counter)] - points[Int(counter + 2)]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 2)]).y)).unitVector()
        let xCoord: Float = zeroCoord ? 0.0 : 1.0
        vertices += [
            TexVertex(position: Float3(x: points[Int(counter)].x, y: 0.0, z: points[Int(counter)].y), normal: normalA, coordinate: Float2(x: xCoord, y: 0.0)),
            TexVertex(position: Float3(x: points[Int(counter + 1)].x, y: 0.0, z: points[Int(counter + 1)].y), normal: normalB, coordinate: Float2(x: xCoord, y: 1.0))
        ]
        counter += 2
        zeroCoord = !zeroCoord
    }
    let normalA = Float3(x: (points[Int(counter)] - points[Int(counter + 1)]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 1)]).y).crossProduct(Float3(x: (points[Int(counter)] - points[Int(counter + 3 - UInt32(sides * 2))]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 3 - UInt32(sides * 2))]).y)).unitVector()
    let normalB = Float3(x: (points[Int(counter)] - points[Int(counter + 3 - UInt32(sides * 2))]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 3 - UInt32(sides * 2))]).y).crossProduct(Float3(x: (points[Int(counter)] - points[Int(counter + 2 - UInt32(sides * 2))]).x, y: 0.0, z: (points[Int(counter)] - points[Int(counter + 2 - UInt32(sides * 2))]).y)).unitVector()
    let xCoord: Float = zeroCoord ? 0.0 : 1.0
    vertices += [
        TexVertex(position: Float3(x: points[Int(counter)].x, y: 0.0, z: points[Int(counter)].y), normal: normalA, coordinate: Float2(x: xCoord, y: 0.0)),
        TexVertex(position: Float3(x: points[Int(counter + 1)].x, y: 0.0, z: points[Int(counter + 1)].y), normal: normalB, coordinate: Float2(x: xCoord, y: 1.0))
    ]
    
    return (indices, vertices)
}
//  Algorythm only works for 6 sides right now
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
    var vbo4indices: GLuint = 0
    var vao4: GLuint = 0
    var tbo: GLuint = 0
    var phongID: GLuint = 0
    var originID: GLuint = 0
    var textureID: GLuint = 0
    var fbo: GLuint = 0
    var colorRBO: GLuint = 0
    var depthRBO: GLuint = 0
    
    var displayLink: CVDisplayLink?
    
    var uniformMatrices = [
        "view" : FloatMatrix4().translate(x: 0.0, y: 0.0, z: -20.0).rotateXAxis(0.5),
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
        glCall(glGenBuffers(1, &vbo1))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo1))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Vertex>.size * triangle.count, triangle, GLenum(GL_STATIC_DRAW)))
        
        //  Set up a VAO to later bind when we want to draw what is in the buffer above.
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
        //  Program and Shader  //
        //       Creation       //
        //                      //
        //  //  //  //  //  //  //
        phongID = glCall(glCreateProgram())
        
        var vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        var source = "#version 330 core                                        \n" +
            "layout (location = 0) in vec3 position;                           \n" +
            "layout (location = 1) in vec3 normal;                             \n" +
            "layout (location = 2) in vec4 color;                              \n" +
            "out vec3 passPosition;                                            \n" +
            "out vec3 passNormal;                                              \n" +
            "out vec4 passColor;                                               \n" +
            "out vec3 passCameraPosition;                                      \n" +
            "uniform mat4 view;                                                \n" +
            "uniform mat4 projection;                                          \n" +
            "void main()                                                       \n" +
            "{                                                                 \n" +
            "    gl_Position = projection * view * vec4(position, 1.0);        \n" +
            "    passPosition = position;                                      \n" +
            "    passNormal = normalize(normal);                               \n" +
            "    passColor = color;                                            \n" +
            "    passCameraPosition = view[3].xyz;                             \n" +
            "}                                                                 \n"
        var vss = source.cString(using: String.Encoding.ascii)
        var vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        var compiled: GLint = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        var fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core                                                                                    \n" +
            "uniform struct Light {                                                                                    \n" +
            "   vec3 color;                                                                                            \n" +
            "   vec3 position;                                                                                         \n" +
            "   float ambient;                                                                                         \n" +
            "   float specStrength;                                                                                    \n" +
            "   float specHardness;                                                                                    \n" +
            "} light;                                                                                                  \n" +
            "in vec3 passPosition;                                                                                     \n" +
            "in vec3 passNormal;                                                                                       \n" +
            "in vec4 passColor;                                                                                        \n" +
            "in vec3 passCameraPosition;                                                                               \n" +
            "out vec4 outColor;                                                                                        \n" +
            "void main()                                                                                               \n" +
            "{                                                                                                         \n" +
            "    vec3 normal = passNormal;                                                                             \n" +
            "    vec3 lightRay = normalize(light.position - passPosition);                                             \n" +
            "    float intensity = clamp(dot(normal, lightRay), 0, 1);                                                 \n" +
            "    vec3 viewer = normalize(passCameraPosition - passPosition);                                           \n" +
            "    vec3 reflection = reflect(lightRay, normal);                                                               \n" +
            "    float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                               \n" +
            "    outColor.rgb = passColor.rgb + light.ambient + light.color * intensity + light.specStrength * specular;    \n" +
            "    outColor.a = passColor.a;                                                                                  \n" +
            "}                                                                                                              \n"
        var fss = source.cString(using: String.Encoding.ascii)
        var fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile fragement, getting log")
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
        
        glCall(glAttachShader(phongID, vs))
        glCall(glAttachShader(phongID, fs))
        glCall(glLinkProgram(phongID))
        var linked: GLint = 0
        glCall(glGetProgramiv(phongID, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(phongID, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(phongID, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
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
        
        //  //  //  //  //  //  //  //
        //                          //
        //  Create Light origin and //
        //       Other Origins      //
        //                          //
        //  //  //  //  //  //  //  //
        
        glCall(glGenBuffers(1, &vbo2))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo2))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Float3>.size * origins.count, origins, GLenum(GL_STATIC_DRAW)))
        
        glCall(glGenVertexArrays(1, &vao2))
        glCall(glBindVertexArray(vao2))
        
        glCall(glEnableVertexAttribArray(0))
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 12, UnsafeRawPointer(bitPattern: 0)))
        
        originID = glCall(glCreateProgram())
        
        vs = glCall(glCreateShader(GLenum(GL_VERTEX_SHADER)))
        source = "#version 330 core                                     \n" +
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
        vss = source.cString(using: String.Encoding.ascii)
        vssptr = UnsafePointer<GLchar>(vss)
        glCall(glShaderSource(vs, 1, &vssptr, nil))
        glCall(glCompileShader(vs))
        compiled = 0
        glCall(glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog))
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core     \n" +
            "in vec4 passColor;         \n" +
            "out vec4 outColor;         \n" +
            "void main()                \n" +
            "{                          \n" +
            "    outColor = passColor;  \n" +
            "}                          \n"
        fss = source.cString(using: String.Encoding.ascii)
        fssptr = UnsafePointer<GLchar>(fss)
        glCall(glShaderSource(fs, 1, &fssptr, nil))
        glCall(glCompileShader(fs))
        compiled = 0
        glCall(glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            Swift.print("Could not compile fragement, getting log")
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
        
        glCall(glAttachShader(originID, vs))
        glCall(glAttachShader(originID, fs))
        glCall(glLinkProgram(originID))
        linked = 0
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
        
        //  The shaders have been compiled and linked to the program.  Mark them for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(fs))
        
        //  //  //  //  //  //  //  //  //
        //                              //
        //   Create Floor and Texture   //
        //            Program           //
        //                              //
        //  //  //  //  //  //  //  //  //
        
        glCall(glGenBuffers(1, &vbo3))
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo3))
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<TexVertex>.size * floor.count, floor, GLenum(GL_STATIC_DRAW)))
        
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
        
        textureID = glCall(glCreateProgram())
        
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
        
        //  //  //  //  //  //
        //                  //
        // Geometry Shader  //
        //                  //
        //  //  //  //  //  //
        let gs = glCall(glCreateShader(GLenum(GL_GEOMETRY_SHADER)))
        source = "#version 330 core                                     \n" +
            "layout (lines_adjacency) in;                               \n" +
            "layout (triangle_strip, max_vertices = 6) out;             \n" +
            "in VertexData {                                            \n" +
            "    vec3 position;                                         \n" +
            "    vec3 normal;                                           \n" +
            "    vec2 coordinate;                                       \n" +
            "    vec3 cameraPosition;                                   \n" +
            "} gs_in[4];                                                \n" +
            "out GeometryData {                                         \n" +
            "    vec3 position;                                         \n" +
            "    vec4 positions[4];                                     \n" +
            "    vec3 normal;                                           \n" +
            "    vec2 coordinate;                                       \n" +
            "    vec3 cameraPosition;                                   \n" +
            "} gs_out;                                                  \n" +
            "void main()                                                \n" +
            "{                                                          \n" +
            "    gl_Position = gl_in[0].gl_Position;                    \n" +
            "    gs_out.position = gl_in[0].gl_Position.xyz;            \n" +
            "    gs_out.normal = gs_in[0].normal;                       \n" +
            "    gs_out.coordinate = gs_in[0].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[0].cameraPosition;       \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[1].gl_Position;                    \n" +
            "    gs_out.position = gl_in[1].gl_Position.xyz;            \n" +
            "    gs_out.normal = gs_in[1].normal;                       \n" +
            "    gs_out.coordinate = gs_in[1].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[1].cameraPosition;       \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[2].gl_Position;                    \n" +
            "    gs_out.position = gl_in[2].gl_Position.xyz;            \n" +
            "    gs_out.positions[0] = gl_in[0].gl_Position;            \n" +
            "    gs_out.positions[1] = gl_in[1].gl_Position;            \n" +
            "    gs_out.positions[2] = gl_in[2].gl_Position;            \n" +
            "    gs_out.positions[3] = gl_in[3].gl_Position;            \n" +
            "    gs_out.normal = gs_in[2].normal;                       \n" +
            "    gs_out.coordinate = gs_in[2].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[2].cameraPosition;       \n" +
            "    EmitVertex();                                          \n" +
            "    EndPrimitive();                                        \n" +
            
            "    gl_Position = gl_in[3].gl_Position;                    \n" +
            "    gs_out.position = gl_in[3].gl_Position.xyz;            \n" +
            "    gs_out.normal = gs_in[3].normal;                       \n" +
            "    gs_out.coordinate = gs_in[3].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[3].cameraPosition;       \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[2].gl_Position;                    \n" +
            "    gs_out.position = gl_in[2].gl_Position.xyz;            \n" +
            "    gs_out.normal = gs_in[2].normal;                       \n" +
            "    gs_out.coordinate = gs_in[2].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[2].cameraPosition;       \n" +
            "    EmitVertex();                                          \n" +
            "    gl_Position = gl_in[1].gl_Position;                    \n" +
            "    gs_out.position = gl_in[1].gl_Position.xyz;            \n" +
            "    gs_out.positions[0] = gl_in[0].gl_Position;            \n" +
            "    gs_out.positions[1] = gl_in[1].gl_Position;            \n" +
            "    gs_out.positions[2] = gl_in[2].gl_Position;            \n" +
            "    gs_out.positions[3] = gl_in[3].gl_Position;            \n" +
            "    gs_out.normal = gs_in[1].normal;                       \n" +
            "    gs_out.coordinate = gs_in[1].coordinate;               \n" +
            "    gs_out.cameraPosition = gs_in[1].cameraPosition;       \n" +
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
        
        fs = glCall(glCreateShader(GLenum(GL_FRAGMENT_SHADER)))
        source = "#version 330 core                                                                                     \n" +
            "uniform sampler2D sample;                                                                                  \n" +
            "uniform struct Light {                                                                                     \n" +
            "   vec3 color;                                                                                             \n" +
            "   vec3 position;                                                                                          \n" +
            "   float ambient;                                                                                          \n" +
            "   float specStrength;                                                                                     \n" +
            "   float specHardness;                                                                                     \n" +
            "} light;                                                                                                   \n" +
            "in GeometryData {                                                                                          \n" +
            "    vec3 position;                                                                                         \n" +
            "    vec4 positions[4];                                                                                     \n" +
            "    vec3 normal;                                                                                           \n" +
            "    vec2 coordinate;                                                                                       \n" +
            "    vec3 cameraPosition;                                                                                   \n" +
            "} fs_in;                                                                                                   \n" +
            "out vec4 outColor;                                                                                         \n" +
            "void main()                                                                                                \n" +
            "{                                                                                                          \n" +
            "    vec2 s = mix(fs_in.positions[0].xy, fs_in.positions[1].xy, fs_in.coordinate.x);                        \n" +
            "    vec2 t = mix(fs_in.positions[2].xy, fs_in.positions[3].xy, fs_in.coordinate.x);                        \n" +
            "    vec2 uv = mix(s, t, fs_in.coordinate.y);                                                               \n" +
            "    vec3 normal = fs_in.normal;                                                                            \n" +
            "    vec3 lightRay = normalize(light.position - fs_in.position);                                            \n" +
            "    float intensity = clamp(dot(normal, lightRay), 0, 1);                                                  \n" +
            "    vec3 viewer = normalize(fs_in.cameraPosition - fs_in.position);                                        \n" +
            "    vec3 reflection = reflect(lightRay, normal);                                                           \n" +
            "    float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                           \n" +
            "    vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;    \n" +
            //  To get the image to warp appropriately to the Quad, we need to transform the coordinate to the warped
            //  Quad's coordinate space - Not sure how to, yet.
            "    outColor = vec4(texture(sample, uv).rgb * light, 1.0);                                   \n" +
            "}                                                                                                          \n"
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
        
        glCall(glAttachShader(textureID, vs))
        glCall(glAttachShader(textureID, gs))
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
        
        //  The shaders have been compiled and linked to the program.  Mark them for deletion.
        glCall(glDeleteShader(vs))
        glCall(glDeleteShader(gs))
        glCall(glDeleteShader(fs))
        
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
            uniformMatrices["view"] = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -20.0) * FloatMatrix4().rotateXAxis(0.5) * FloatMatrix4().rotateYAxis(0.008) * FloatMatrix4().rotateXAxis(-0.5) * FloatMatrix4().translate(x: 0.0, y: 0.0, z: 20.0) * uniformMatrices["view"]!
            
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
            
            //  Draw the floor
            glCall(glUseProgram(textureID))
            glCall(glBindVertexArray(vao3))
            
//            glCall(glUniform1i(glCall(glGetUniformLocation(textureID, "sample")), GL_TEXTURE0))
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "view")), 1, GLboolean(GL_FALSE), uniformMatrices["view"]!.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "projection")), 1, GLboolean(GL_FALSE), uniformMatrices["projection"]!.columnMajorArray()))
            
            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawArrays(GLenum(GL_LINES_ADJACENCY), 0, Int32(floor.count)))
            
            glCall(glBindVertexArray(vbo4))
            glCall(glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vbo4indices))
            
            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawElements(GLenum(GL_LINES_ADJACENCY), Int32(showcaseFloor.0.count), GLenum(GL_UNSIGNED_INT), UnsafeRawPointer(bitPattern: 0)))
            
            //  Draw into offline framebuffer
            glCall(glBindFramebuffer(GLenum(GL_FRAMEBUFFER), fbo))
            
            glCall(glClearColor(1.0, 1.0, 1.0, 1.0))
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT) | GLbitfield(GL_DEPTH_BUFFER_BIT)))
            
            //  Draw with top-down viewpoint
            let topDown = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0) * FloatMatrix4().rotateXAxis(Float.pi / 2) * FloatMatrix4().rotateYAxis(0.008) * FloatMatrix4().translate(x: 0.0, y: 0.0, z: 20.0) * uniformMatrices["view"]!
            
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
            
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureID, "light.color")), 1, light.color))
            glCall(glUniform3fv(glCall(glGetUniformLocation(textureID, "light.position")), 1, light.position))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.ambient")), light.ambient))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.specStrength")), light.specStrength))
            glCall(glUniform1f(glCall(glGetUniformLocation(textureID, "light.specHardness")), light.specHardness))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "view")), 1, GLboolean(GL_FALSE), topDown.columnMajorArray()))
            glCall(glUniformMatrix4fv(glCall(glGetUniformLocation(textureID, "projection")), 1, GLboolean(GL_FALSE), FloatMatrix4().projection(angeOfView: 35, aspect: 1.0, distanceToNearClippingPlane: 0.01, distanceToFarClippingPlane: 100).columnMajorArray()))
            
            //  Drawing with Texture Program requires Lines Adjacency due to Geometry shader input
            glCall(glDrawArrays(GLenum(GL_LINES_ADJACENCY), 0, Int32(floor.count)))
            
            // Transfer from offline framebuffer to default to display to the screen
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
        glCall(glDeleteProgram(phongID))
        glCall(glDeleteProgram(originID))
        glCall(glDeleteProgram(textureID))
        glCall(glDeleteRenderbuffers(1, &colorRBO))
        glCall(glDeleteRenderbuffers(1, &depthRBO))
        glCall(glDeleteFramebuffers(1, &fbo))
    }
}
