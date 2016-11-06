//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    fileprivate var programID: GLuint = 0
    fileprivate var vaoID: GLuint = 0
    fileprivate var vboID: GLuint = 0
    fileprivate var tboID: GLuint = 0
    
    fileprivate var data = [GLfloat]()
    
    //  View and Projection Matrices
    var view = Matrix4()
    var projection = Matrix4()
    
    //  Delegate to drive the drawing loop
    var renderDelegate: ViewRenderDelegate?
    
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
        data = [-1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
                0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
                1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001]
        
        /*  Since we're starting a new target, not just a duplicate, we'll adjust the OpenGL
         texture to take input from the image assests catalog.  We can access these images
         by name as NSImage representations.  The raw data can then be passed by getting
         the TIFF representation and then the a pointer to that data.    */
        guard let textureData = NSImage(named: "Texture")?.tiffRepresentation else {
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
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String(cString: cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
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
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String(cString: cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
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
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetProgramInfoLog(programID, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log: \n\t\(String.init(cString:cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
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
        
        drawView()
        
        renderDelegate?.setup()
        renderDelegate?.start()
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    func drawView() {
        
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.cglContextObj!)
        
        //  calculate a new view matrix
        renderDelegate?.prepare()
        
        glUseProgram(programID)
        
        let value = Float(sin(renderDelegate!.currentTime))
        glUniform3fv(glGetUniformLocation(programID, "light.position"), 1, [value, 1.0, 0.5])
        
        glUniformMatrix4fv(glGetUniformLocation(programID, "view"), 1, GLboolean(GL_FALSE), view.asArray())
        glUniformMatrix4fv(glGetUniformLocation(programID, "projection"), 1, GLboolean(GL_FALSE), projection.asArray())
        
        glBindVertexArray(vaoID)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        CGLFlushDrawable(context.cglContextObj!)
        CGLUnlockContext(context.cglContextObj!)
        
    }
    
    deinit {
        
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
        
    }
    
}
