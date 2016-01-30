//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 11:  Refactored view definition. Vector3, Matrix4, VBO, VAO, TBO, Camera,
//            Shader are pulled out into separate file.
//


import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    private var programID: GLuint = 0
    private var vaoID: GLuint = 0
    private var vboID: GLuint = 0
    private var tboID: GLuint = 0
    
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
    private var previousTime = CFTimeInterval()
    
    private var data = [GLfloat]()
    
    private var view = Matrix4()
    private var projection = Matrix4()
    
    //  The CVDisplayLink for animating.  Optional value initialized to nil.
    private var displayLink: CVDisplayLink?
    
    //  In order to recieve keyboard input, we need to enable the view to accept first responder status
    override var acceptsFirstResponder: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //  We'll use double buffering this time (one buffer is displayed while the other is
        //  calculated, then we swap them.
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        guard let context = NSOpenGLContext(format: pixelFormat, shareContext: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        
        //  Set the context's swap interval parameter to 60Hz (i.e. 1 frame per swamp)
        self.openGLContext?.setValues([1], forParameter: .GLCPSwapInterval)
        
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()
        
        //format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        data = [-1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
                 0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
                 1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001]
        
        /*  Since we're starting a new target, not just a duplicate, we'll adjust the OpenGL
        texture to take input from the image assests catalog.  We can access these images
        by name as NSImage representations.  The raw data can then be passed by getting
        the TIFF representation and then the a pointer to that data.    */
        guard let textureData = NSImage(named: "Texture")?.TIFFRepresentation else {
            Swift.print("Image name not located in Image Asset Catalog")
            return
        }
        
        let textureBuffer = UnsafeMutablePointer<Void>.alloc(textureData.length)
        textureData.getBytes(textureBuffer, length: textureData.length)
        
        glGenTextures(1, &tboID)
        glBindTexture(GLenum(GL_TEXTURE_2D), tboID)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureBuffer)
        
        free(textureBuffer)
        
        glGenBuffers(1, &vboID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * sizeof(GLfloat), data, GLenum(GL_STATIC_DRAW))
        
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
        if let vss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
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
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("log = \(log)")
                        free(cLog)
                    }
                }
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
        if let fss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            var fssptr = UnsafePointer<GLchar>(fss)
            glShaderSource(fs, 1, &fssptr, nil)
            glCompileShader(fs)
            var compiled: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
            if compiled <= 0 {
                Swift.print("Could not compile fragement, getting log")
                var logLength: GLint = 0
                glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
                Swift.print(" logLength = \(logLength)")
                if logLength > 0 {
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("log = \(log)")
                        free(cLog)
                    }
                }
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
                let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                glGetProgramInfoLog(programID, GLsizei(logLength), &logLength, cLog)
                if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                    Swift.print("log: \(log)")
                }
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
        
        func displayLinkOutputCallback(displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
            unsafeBitCast(displayLinkContext, SwiftOpenGLView.self).drawView()
            
            return kCVReturnSuccess
        }
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
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
        let rightVector = Matrix4().rotateAlongXAxis(cameraOrientation.v0).rotateAlongYAxis(cameraOrientation.v1).inverse() * Vector3(v0: 1.0, v1: 0.0, v2: 0.0)
        
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
        
        view = Matrix4().rotateAlongXAxis(cameraOrientation.v0).rotateAlongYAxis(cameraOrientation.v1).translate(x: cameraPosition.v0, y: cameraPosition.v1, z: cameraPosition.v2)
        
    }
    
    func rotateCamera(pitch xRotation: Float, yaw yRotation: Float) {
        
        let xRadians = cameraOrientation.v0 + -xRotation * Float(M_PI) / 180
        
        if 0 <= xRadians || xRadians <= Float(M_2_PI) {
            cameraOrientation.v0 = xRadians
        } else if xRadians > Float(M_2_PI) {
            cameraOrientation.v0 = xRadians - Float(M_2_PI)
        } else {
            cameraOrientation.v0 = xRadians + Float(M_2_PI)
        }
        
        let yRadians = cameraOrientation.v1 + -yRotation * Float(M_PI) / 180
        
        if 0 <= yRadians || yRadians <= Float(M_2_PI) {
            cameraOrientation.v1 = yRadians
        } else if yRadians > Float(M_2_PI) {
            cameraOrientation.v1 = yRadians - Float(M_2_PI)
        } else {
            cameraOrientation.v1 = yRadians + Float(M_2_PI)
        }
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    private func drawView() {
        
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.CGLContextObj)
        
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
        
        CGLFlushDrawable(context.CGLContextObj)
        CGLUnlockContext(context.CGLContextObj)
        
    }
    
    deinit {
        CVDisplayLinkStop(displayLink!)
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
    }
    
}

