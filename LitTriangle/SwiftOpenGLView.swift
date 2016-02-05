//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 9/8/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//
//  Ver. 6:  Draws a textured and colored triangle using a single diffuse area light
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    private var programID: GLuint = 0
    private var vaoID: GLuint = 0
    private var vboID: GLuint = 0
    private var tboID: GLuint = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
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
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()

        //format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        let data: [GLfloat] = [-1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
                 0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
                 1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001]

        let fileURL = NSBundle.mainBundle().URLForResource("Texture", withExtension: "png")

        let dataProvider = CGDataProviderCreateWithURL(fileURL)
        let image = CGImageCreateWithPNGDataProvider(dataProvider, nil, false, CGColorRenderingIntent.RenderingIntentDefault)

        let textureData = UnsafeMutablePointer<Void>(malloc(256 * 4 * 256))

        let context = CGBitmapContextCreate(textureData, 256, 256, 8, 4 * 256, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB),  CGImageAlphaInfo.PremultipliedLast.rawValue)

        CGContextDrawImage(context, CGRectMake(0.0, 0.0, 256.0, 256.0), image)

        glGenTextures(1, &tboID)
        glBindTexture(GLenum(GL_TEXTURE_2D), tboID)

        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)

        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        
        free(textureData)
        
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
        
        //  The fourth attribute, the normal.  This adds an addition 12 bytes to the vertex
        //  The vertex's total byte count is now 40 and the normal may be found at the end
        //  of the previous attribute, byte 28
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28))
        glEnableVertexAttribArray(3)
        
        glBindVertexArray(0)

        //  The fragment shader is going to need the vertex position and normal, so we pass
        //  those values on.  The vertex shader remains otherwise unchanged.
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                     \n" +
            "layout (location = 0) in vec2 position;        \n" +
            "layout (location = 1) in vec3 color;           \n" +
            "layout (location = 2) in vec2 texturePosition; \n" +
            "layout (location = 3) in vec3 normal;          \n" +
            "out vec3 passPosition;                         \n" +
            "out vec3 passColor;                            \n" +
            "out vec2 passTexturePosition;                  \n" +
            "out vec3 passNormal;                           \n" +
            "void main()                                    \n" +
            "{                                              \n" +
            "     gl_Position = vec4(position, 0.0, 1.0);   \n" +
            "     passPosition = vec3(position, 0.0);       \n" +
            "     passColor = color;                        \n" +
            "     passTexturePosition = texturePosition;    \n" +
            "     passNormal = normal;                      \n" +
            "}                                              \n"
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
        
        //  Here is where the bulk of the changes take place and where the actual computing
        //  change takes place.
        //  The light source is defined by a color and a position that are the same for every
        //    fragment.  Therefore, we pass them in as uniform variables.
        //  The normal must be renormalized as it is an interpolated value when passed from the
        //  vertex shader.
        //  The light ray incident to this fragment is calculated from the interpolated position
        //    and the light position.  This vector should also be normalized to simplify our 
        //    calculations--as we shall see in a moment.
        //  The intensity of light upon the fragment, is calculated using the dot product and it's
        //    equivalent equation |A||B|cos𝛉.  Solving for cos𝛉, we get the euqation
        //        dot(A, B) / length(A) * length(B)
        //    Because we normalized the normal and the light ray vectors, we can simplify this to
        //        dot(A, B)
        //  This value is clamped to a value between 0 and 1 because the calculation may return a
        //    a negative value.
        //  The light variable is simple now, but will become complete later.  For now it is a
        //    simple pass on.
        //  The model color is calculated the same as before.
        //  Then the final color of the fragment is calculated by combining the light and surface
        //    colors and added on the alpha value.
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                                                                 \n" +
            "uniform sampler2D sample;                                                              \n" +
            "uniform vec3 lightColor;                                                               \n" +
            "uniform vec3 lightPosition;                                                            \n" +
            "in vec3 passPosition;                                                                  \n" +
            "in vec3 passColor;                                                                     \n" +
            "in vec2 passTexturePosition;                                                           \n" +
            "in vec3 passNormal;                                                                    \n" +
            "out vec4 outColor;                                                                     \n" +
            "void main()                                                                            \n" +
            "{                                                                                      \n" +
            "     vec3 normal = normalize(passNormal);                                              \n" +
            "     vec3 lightRay = normalize(lightPosition - passPosition);                          \n" +
            "     float intensity = dot(normal, lightRay);                                          \n" +
            "     intensity = clamp(intensity, 0, 1);                                               \n" +
            "     vec3 light = lightColor * intensity;                                              \n" +
            "     vec3 surface = texture(sample, passTexturePosition).rgb * passColor;              \n" +
            "     vec3 rgb = surface * light;                                                       \n" +
            "     outColor = vec4(rgb, 1.0);                                                        \n" +
            "}                                                                                      \n"
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
        
        //  Before we define our light's attributes, we need to select a program
        glUseProgram(programID)
        
        //  Define the parameters for a light.
        //  We'll start our light definition with a color and a position.
        //  The color and position contain three components -- use a 3fv uniform
        //  3 for three components, f for float, v for variable
        //  Alternatively, you could use a uniform3f which allows you to send three floats as
        //    separate parameters
        glUniform3fv(glGetUniformLocation(programID, "lightColor"), 1, [1.0, 1.0, 1.0])
        glUniform3fv(glGetUniformLocation(programID, "lightPosition"), 1, [0.0, 1.0, 0.0])
        
        drawView()
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    private func drawView() {
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programID)
        glBindVertexArray(vaoID)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        glFlush()
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
    }
    
}
