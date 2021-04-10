//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 10/27/15.
//  Copyright © 2015 MyKo. All rights reserved.
//
//  Ver. 10:    Implements view and projection coordinates uisng input passed from
//              the View Controller.
//


import Cocoa
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

func ==(lhs: Matrix4, rhs: Matrix4) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
func *(lhs: Matrix4, rhs: Matrix4) -> Matrix4 {
    
    return Matrix4(
        m00: lhs.m00 * rhs.m00 + lhs.m01 * rhs.m10 + lhs.m02 * rhs.m20 + lhs.m03 * rhs.m30,
        m01: lhs.m00 * rhs.m01 + lhs.m01 * rhs.m11 + lhs.m02 * rhs.m21 + lhs.m03 * rhs.m31,
        m02: lhs.m00 * rhs.m02 + lhs.m01 * rhs.m12 + lhs.m02 * rhs.m22 + lhs.m03 * rhs.m32,
        m03: lhs.m00 * rhs.m03 + lhs.m01 * rhs.m13 + lhs.m02 * rhs.m23 + lhs.m03 * rhs.m33,
        
        m10: lhs.m10 * rhs.m00 + lhs.m11 * rhs.m10 + lhs.m12 * rhs.m20 + lhs.m13 * rhs.m30,
        m11: lhs.m10 * rhs.m01 + lhs.m11 * rhs.m11 + lhs.m12 * rhs.m21 + lhs.m13 * rhs.m31,
        m12: lhs.m10 * rhs.m02 + lhs.m11 * rhs.m12 + lhs.m12 * rhs.m22 + lhs.m13 * rhs.m32,
        m13: lhs.m10 * rhs.m03 + lhs.m11 * rhs.m13 + lhs.m12 * rhs.m23 + lhs.m13 * rhs.m33,
        
        m20: lhs.m20 * rhs.m00 + lhs.m21 * rhs.m10 + lhs.m22 * rhs.m20 + lhs.m23 * rhs.m30,
        m21: lhs.m20 * rhs.m01 + lhs.m21 * rhs.m11 + lhs.m22 * rhs.m21 + lhs.m23 * rhs.m31,
        m22: lhs.m20 * rhs.m02 + lhs.m21 * rhs.m12 + lhs.m22 * rhs.m22 + lhs.m23 * rhs.m32,
        m23: lhs.m20 * rhs.m03 + lhs.m21 * rhs.m13 + lhs.m22 * rhs.m23 + lhs.m23 * rhs.m33,
        
        m30: lhs.m30 * rhs.m00 + lhs.m31 * rhs.m10 + lhs.m32 * rhs.m20 + lhs.m33 * rhs.m30,
        m31: lhs.m30 * rhs.m01 + lhs.m31 * rhs.m11 + lhs.m32 * rhs.m21 + lhs.m33 * rhs.m31,
        m32: lhs.m30 * rhs.m02 + lhs.m31 * rhs.m12 + lhs.m32 * rhs.m22 + lhs.m33 * rhs.m32,
        m33: lhs.m30 * rhs.m03 + lhs.m31 * rhs.m13 + lhs.m32 * rhs.m23 + lhs.m33 * rhs.m33)
    
}
func *(lhs: Matrix4, rhs: Vector3) -> Vector3 {
    return Vector3(v0: lhs.m00 * rhs.v0 + lhs.m01 * rhs.v1 + lhs.m02 * rhs.v2,
        v1: lhs.m10 * rhs.v0 + lhs.m11 * rhs.v1 + lhs.m12 * rhs.v2,
        v2: lhs.m20 * rhs.v0 + lhs.m21 * rhs.v1 + lhs.m22 * rhs.v2)
}

struct Matrix4: CustomStringConvertible, Hashable {
    
    var m00 = Float(), m01 = Float(), m02 = Float(), m03 = Float()
    var m10 = Float(), m11 = Float(), m12 = Float(), m13 = Float()
    var m20 = Float(), m21 = Float(), m22 = Float(), m23 = Float()
    var m30 = Float(), m31 = Float(), m32 = Float(), m33 = Float()
    
    var description: String {
        return "| \(m00) | \(m01) | \(m02) | \(m03) |\n|" +
                 "\(m10) | \(m11) | \(m12) | \(m13) |\n|" +
                 "\(m20) | \(m21) | \(m22) | \(m23) |\n|" +
                 "\(m30) | \(m31) | \(m32) | \(m33) |"
    }
    var hashValue: Int {
        return description.hashValue
    }
    
    init() {
        
        m00 = 1.0
        m01 = Float()
        m02 = Float()
        m03 = Float()
        
        m10 = Float()
        m11 = 1.0
        m12 = Float()
        m13 = Float()
        
        m20 = Float()
        m21 = Float()
        m22 = 1.0
        m23 = Float()
        
        m30 = Float()
        m31 = Float()
        m32 = Float()
        m33 = 1.0
        
    }
    
    init(m00: Float, m01: Float, m02: Float, m03: Float,
        m10: Float, m11: Float, m12: Float, m13: Float,
        m20: Float, m21: Float, m22: Float, m23: Float,
        m30: Float, m31: Float, m32: Float, m33: Float) {
            
        self.m00 = m00
        self.m01 = m01
        self.m02 = m02
        self.m03 = m03
        
        self.m10 = m10
        self.m11 = m11
        self.m12 = m12
        self.m13 = m13
        
        self.m20 = m20
        self.m21 = m21
        self.m22 = m22
        self.m23 = m23
        
        self.m30 = m30
        self.m31 = m31
        self.m32 = m32
        self.m33 = m33
            
    }
    
    init(fieldOfView fov: Float, aspect: Float, nearZ: Float, farZ: Float) {
        
        m00 = (1 / tanf(fov * (Float.pi / 180.0) * 0.5)) / aspect
        m01 = 0.0
        m02 = 0.0
        m03 = 0.0
        
        m10 = 0.0
        m11 = 1 / tanf(fov * (Float.pi / 180.0) * 0.5)
        m12 = 0.0
        m13 = 0.0
        
        m20 = 0.0
        m21 = 0.0
        m22 = (farZ + nearZ) / (nearZ - farZ)
        m23 = (2 * farZ * nearZ) / (nearZ - farZ)
        
        m30 = 0.0
        m31 = 0.0
        m32 = -1.0
        m33 = 0.0
        
    }
    
    func asArray() -> [Float] {
        return [self.m00, self.m10, self.m20, self.m30,
                self.m01, self.m11, self.m21, self.m31,
                self.m02, self.m12, self.m22, self.m32,
                self.m03, self.m13, self.m23, self.m33]
    }
    
    func inverse() -> Matrix4 {
        //
        let m = self
        let minors = Matrix4(
            m00: (m.m11 * (m.m22 * m.m33 - m.m23 * m.m32)) - (m.m12 * (m.m21 * m.m33 - m.m23 * m.m31)) + (m.m13 * (m.m21 * m.m32 - m.m22 * m.m31)),
            m01: (m.m10 * (m.m22 * m.m33 - m.m23 * m.m32)) - (m.m12 * (m.m20 * m.m33 - m.m23 * m.m30)) + (m.m13 * (m.m20 * m.m32 - m.m22 * m.m30)),
            m02: (m.m10 * (m.m21 * m.m33 - m.m23 * m.m31)) - (m.m11 * (m.m20 * m.m33 - m.m23 * m.m30)) + (m.m13 * (m.m20 * m.m31 - m.m21 * m.m30)),
            m03: (m.m10 * (m.m21 * m.m32 - m.m22 * m.m31)) - (m.m11 * (m.m20 * m.m32 - m.m22 * m.m30)) + (m.m12 * (m.m20 * m.m31 - m.m21 * m.m30)),
            
            m10: (m.m01 * (m.m22 * m.m33 - m.m23 * m.m32)) - (m.m02 * (m.m21 * m.m33 - m.m23 * m.m31)) + (m.m03 * (m.m21 * m.m32 - m.m22 * m.m31)),
            m11: (m.m00 * (m.m22 * m.m33 - m.m23 * m.m32)) - (m.m02 * (m.m20 * m.m33 - m.m23 * m.m30)) + (m.m03 * (m.m20 * m.m32 - m.m22 * m.m30)),
            m12: (m.m00 * (m.m21 * m.m33 - m.m23 * m.m31)) - (m.m01 * (m.m20 * m.m33 - m.m23 * m.m30)) + (m.m03 * (m.m20 * m.m31 - m.m21 * m.m30)),
            m13: (m.m00 * (m.m21 * m.m32 - m.m22 * m.m31)) - (m.m01 * (m.m20 * m.m32 - m.m22 * m.m30)) + (m.m02 * (m.m20 * m.m31 - m.m21 * m.m30)),
            
            m20: (m.m01 * (m.m12 * m.m33 - m.m13 * m.m32)) - (m.m02 * (m.m11 * m.m33 - m.m13 * m.m31)) + (m.m03 * (m.m11 * m.m32 - m.m12 * m.m31)),
            m21: (m.m00 * (m.m12 * m.m33 - m.m13 * m.m32)) - (m.m02 * (m.m10 * m.m33 - m.m13 * m.m30)) + (m.m03 * (m.m10 * m.m32 - m.m12 * m.m30)),
            m22: (m.m00 * (m.m11 * m.m33 - m.m13 * m.m31)) - (m.m01 * (m.m10 * m.m33 - m.m13 * m.m30)) + (m.m03 * (m.m10 * m.m31 - m.m11 * m.m30)),
            m23: (m.m00 * (m.m11 * m.m32 - m.m12 * m.m31)) - (m.m01 * (m.m10 * m.m32 - m.m12 * m.m30)) + (m.m02 * (m.m10 * m.m31 - m.m11 * m.m30)),
            
            m30: (m.m01 * (m.m12 * m.m23 - m.m13 * m.m22)) - (m.m02 * (m.m11 * m.m23 - m.m13 * m.m21)) + (m.m03 * (m.m11 * m.m22 - m.m12 * m.m21)),
            m31: (m.m00 * (m.m12 * m.m23 - m.m13 * m.m22)) - (m.m02 * (m.m10 * m.m23 - m.m13 * m.m20)) + (m.m03 * (m.m10 * m.m22 - m.m12 * m.m20)),
            m32: (m.m00 * (m.m11 * m.m23 - m.m13 * m.m21)) - (m.m01 * (m.m10 * m.m23 - m.m13 * m.m20)) + (m.m03 * (m.m10 * m.m21 - m.m11 * m.m20)),
            m33: (m.m00 * (m.m11 * m.m22 - m.m12 * m.m21)) - (m.m01 * (m.m10 * m.m22 - m.m12 * m.m20)) + (m.m02 * (m.m10 * m.m21 - m.m11 * m.m20)))
        
        let invDeterminant = 1 / (m.m00 * minors.m00 - m.m01 * minors.m01 + m.m02 * minors.m02 - m.m03 * minors.m03)
        
        let im = Matrix4(
            m00: +minors.m00 * invDeterminant,
            m01: -minors.m10 * invDeterminant,
            m02: +minors.m20 * invDeterminant,
            m03: -minors.m30 * invDeterminant,
            
            m10: -minors.m01 * invDeterminant,
            m11: +minors.m11 * invDeterminant,
            m12: -minors.m21 * invDeterminant,
            m13: +minors.m31 * invDeterminant,
            
            m20: +minors.m02 * invDeterminant,
            m21: -minors.m12 * invDeterminant,
            m22: +minors.m22 * invDeterminant,
            m23: -minors.m32 * invDeterminant,
            
            m30: -minors.m03 * invDeterminant,
            m31: +minors.m13 * invDeterminant,
            m32: -minors.m23 * invDeterminant,
            m33: +minors.m33 * invDeterminant)
        
        return im
        
    }
    
    func translate(x: Float, y: Float, z: Float) -> Matrix4 {
        
        var m = Matrix4()
        
        m.m03 += m.m00 * x + m.m01 * y + m.m02 * z
        m.m13 += m.m10 * x + m.m11 * y + m.m12 * z
        m.m23 += m.m20 * x + m.m21 * y + m.m22 * z
        m.m33 += m.m30 * x + m.m31 * y + m.m32 * z
        
        return self * m
        
    }
    
    func rotateAlongXAxis(radians: Float) -> Matrix4 {
        
        var m = Matrix4()
        
        m.m11 = cos(radians)
        m.m12 = sin(radians)
        m.m21 = -sin(radians)
        m.m22 = cos(radians)
        
        return self * m
        
    }
    func rotateAlongYAxis(radians: Float) -> Matrix4 {
        
        var m = Matrix4()
        
        m.m00 = cos(radians)
        m.m02 = -sin(radians)
        m.m20 = sin(radians)
        m.m22 = cos(radians)
        
        return self * m
        
    }
    func rotate(radians angle: Float, alongAxis axis: Vector3) -> Matrix4 {
        
        let cosine = cos(angle)
        let inverseCosine = 1.0 - cosine
        let sine = sin(angle)
        
        return self * Matrix4(
            m00: cosine + inverseCosine * axis.v0 * axis.v0,
            m01: inverseCosine * axis.v0 * axis.v1 + axis.v2 * sine,
            m02: inverseCosine * axis.v0 * axis.v2 - axis.v1 * sine,
            m03: 0.0,
            
            m10: inverseCosine * axis.v0 * axis.v1 - axis.v2 * sine,
            m11: cosine + inverseCosine * axis.v1 * axis.v1,
            m12: inverseCosine * axis.v1 * axis.v2 + axis.v0 * sine,
            m13: 0.0,
            
            m20: inverseCosine * axis.v0 * axis.v2 + axis.v1 * sine,
            m21: inverseCosine * axis.v1 * axis.v2 - axis.v0 * sine,
            m22: cosine + inverseCosine * axis.v2 * axis.v2,
            m23: 0.0,
            
            m30: 0.0,
            m31: 0.0,
            m32: 0.0,
            m33: 1.0)
        
    }
    
}

final class SwiftOpenGLView: NSOpenGLView {
    
    fileprivate var programID: GLuint = 0
    fileprivate var vaoID: GLuint = 0
    fileprivate var vboID: GLuint = 0
    fileprivate var tboID: GLuint = 0
    
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
    fileprivate var previousTime = CFTimeInterval()
    
    fileprivate var data = [GLfloat]()
    
    fileprivate var view = Matrix4()
    fileprivate var projection = Matrix4()
    
    //  The CVDisplayLink for animating.  Optional value initialized to nil.
    fileprivate var displayLink: CVDisplayLink?
    
    //  In order to recieve keyboard input, we need to enable the view to accept first responder status
    override var acceptsFirstResponder: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //  We'll use double buffering this time (one buffer is displayed while the other is
        //  calculated, then we swap them.
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 32,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            0
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        guard let context = NSOpenGLContext(format: pixelFormat, share: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        
        //  Set the context's swap interval parameter to 60Hz (i.e. 1 frame per swamp)
        self.openGLContext?.setValues([1], for: .swapInterval)
        
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()
        
        //format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        data = [-1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 1.0,  -1.0, -1.0, 0.0001,
                 0.0,  1.0,  0.0, 1.0, 0.0,  0.5, 0.0,   0.0,  1.0, 0.0001,
                 1.0, -1.0,  0.0, 0.0, 1.0,  1.0, 1.0,   1.0, -1.0, 0.0001]
        
        /*  Since we're starting a new target, not just a duplicate, we'll adjust the OpenGL
            texture to take input from the image assests catalog.  We can access these images
            by name as NSImage representations.  The raw data can then be passed by getting
            the TIFF representation and then the a pointer to that data.    */
        guard let textureData = NSImage(named: NSImage.Name(rawValue: "Texture"))?.tiffRepresentation else {
            Swift.print("Image name not located in Image Asset Catalog")
            return
        }
        
        glGenTextures(1, &tboID)
        glBindTexture(GLenum(GL_TEXTURE_2D), tboID)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (textureData as NSData).bytes)
        
        
        glGenBuffers(1, &vboID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<GLfloat>.size, data, GLenum(GL_STATIC_DRAW))
        
        glGenVertexArrays(1, &vaoID)
        glBindVertexArray(vaoID)
        
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 8))
        glEnableVertexAttribArray(1)
        
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 20))
        glEnableVertexAttribArray(2)
        
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28))
        glEnableVertexAttribArray(3)
        
        glBindVertexArray(0)
        
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                                        \n" +
            "layout (location = 0) in vec2 position;                           \n" +
            "layout (location = 1) in vec3 color;                              \n" +
            "layout (location = 2) in vec2 texturePosition;                    \n" +
            "layout (location = 3) in vec3 normal;                             \n" +
            "out vec3 passPosition;                                            \n" +
            "out vec3 passColor;                                               \n" +
            "out vec2 passTexturePosition;                                     \n" +
            "out vec3 passNormal;                                              \n" +
            "uniform mat4 view;                                                \n" +
            "uniform mat4 projection;                                          \n" +
            "void main()                                                       \n" +
            "{                                                                 \n" +
            "    gl_Position = projection * view * vec4(position, 0.0, 1.0);   \n" +
            "    passPosition = vec3(position, 0.0);                           \n" +
            "    passColor = color;                                            \n" +
            "    passTexturePosition = texturePosition;                        \n" +
            "    passNormal = normal;                                          \n" +
            "}                                                                 \n"
        let vss = source.cString(using: String.Encoding.ascii)
        var vssptr = UnsafePointer<GLchar>(vss)
        glShaderSource(vs, 1, &vssptr, nil)
        glCompileShader(vs)
        var compiled: GLint = 0
        glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            Swift.print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                                                                                    \n" +
            "uniform sampler2D sample;                                                                                 \n" +
            "uniform struct Light {                                                                                    \n" +
            "   vec3 color;                                                                                            \n" +
            "   vec3 position;                                                                                         \n" +
            "   float ambient;                                                                                         \n" +
            "   float specStrength;                                                                                    \n" +
            "   float specHardness;                                                                                    \n" +
            "} light;                                                                                                  \n" +
            "in vec3 passPosition;                                                                                     \n" +
            "in vec3 passColor;                                                                                        \n" +
            "in vec2 passTexturePosition;                                                                              \n" +
            "in vec3 passNormal;                                                                                       \n" +
            "out vec4 outColor;                                                                                        \n" +
            "void main()                                                                                               \n" +
            "{                                                                                                         \n" +
            "    vec3 normal = normalize(passNormal);                                                                  \n" +
            "    vec3 lightRay = normalize(light.position - passPosition);                                             \n" +
            "    float intensity = dot(normal, lightRay);                                                              \n" +
            "    intensity = clamp(intensity, 0, 1);                                                                   \n" +
            "    vec3 viewer = normalize(vec3(0.0, 0.0, 0.2) - passPosition);                                          \n" +
            "    vec3 reflection = reflect(lightRay, normal);                                                          \n" +
            "    float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                          \n" +
            "    vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;   \n" +
            "    vec3 surface = texture(sample, passTexturePosition).rgb * passColor;                                  \n" +
            "    vec3 rgb = surface * light;                                                                           \n" +
            "    outColor = vec4(rgb, 1.0);                                                                            \n" +
            "}                                                                                                         \n"
        let fss = source.cString(using: String.Encoding.ascii)
        var fssptr = UnsafePointer<GLchar>(fss)
        glShaderSource(fs, 1, &fssptr, nil)
        glCompileShader(fs)
        compiled = 0
        glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            Swift.print("Could not compile fragement, getting log")
            var logLength: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        glAttachShader(programID, vs)
        glAttachShader(programID, fs)
        glLinkProgram(programID)
        var linked: GLint = 0
        glGetProgramiv(programID, UInt32(GL_LINK_STATUS), &linked)
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glGetProgramiv(programID, UInt32(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetProgramInfoLog(programID, GLsizei(logLength), &logLength, cLog)
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        
        glDeleteShader(vs)
        glDeleteShader(fs)
        
        let sampleLocation = glGetUniformLocation(programID, "sample")
        glUniform1i(sampleLocation, GL_TEXTURE0)
        
        glUseProgram(programID)
        
        glUniform3fv(glGetUniformLocation(programID, "light.color"), 1, [1.0, 1.0, 1.0])
        glUniform3fv(glGetUniformLocation(programID, "light.position"), 1, [0.0, 1.0, 0.5])
        glUniform1f(glGetUniformLocation(programID, "light.ambient"), 0.25)
        glUniform1f(glGetUniformLocation(programID, "light.specStrength"), 3.0)
        glUniform1f(glGetUniformLocation(programID, "light.specHardness"), 32)
        
        //  Push the triangle back from the viewer
        view.m23 = -5.0
        projection = Matrix4(fieldOfView: 35, aspect: Float(bounds.size.width) / Float(bounds.size.height), nearZ: 0.001, farZ: 1000)
        
        drawView()
        
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
            unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self).drawView()
            
            return kCVReturnSuccess
        }
    
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
        
    }
    
    func updateViewMatrix(atTime time: CFTimeInterval) {
        
        let amplitude = 10 * Float(time - previousTime)
        
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
        
        view = Matrix4().rotateAlongXAxis(radians: cameraOrientation.v0).rotateAlongYAxis(radians: cameraOrientation.v1).translate(x: cameraPosition.v0, y: cameraPosition.v1, z: cameraPosition.v2)
        
    }
    
    func rotateCamera(pitch xRotation: Float, yaw yRotation: Float) {
        
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
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    fileprivate func drawView() {
        
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.cglContextObj!)
        
        let time = CACurrentMediaTime()
        
        let value = Float(sin(time))
        
        updateViewMatrix(atTime: time)
        //  Update previousTime regardless so delta time is appropriately calculated between frames.
        previousTime = time
        
        glClearColor(GLfloat(value), GLfloat(value), GLfloat(value), 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programID)
        glBindVertexArray(vaoID)
        
        glUniform3fv(glGetUniformLocation(programID, "light.position"), 1, [value, 1.0, 0.5])
        
        glUniformMatrix4fv(glGetUniformLocation(programID, "view"), 1, GLboolean(GL_FALSE), view.asArray())
        glUniformMatrix4fv(glGetUniformLocation(programID, "projection"), 1, GLboolean(GL_FALSE), projection.asArray())
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        CGLFlushDrawable(context.cglContextObj!)
        CGLUnlockContext(context.cglContextObj!)
        
    }
    
    deinit {
        CVDisplayLinkStop(displayLink!)
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
    }
    
}
