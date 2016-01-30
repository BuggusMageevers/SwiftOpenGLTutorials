//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 10/24/15.
//  Copyright © 2015 MyKo. All rights reserved.
//
//  Ver. 9:  Draws a simple animation using CVDisplayLink
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    private var programID: GLuint = 0
    private var vaoID: GLuint = 0
    private var vboID: GLuint = 0
    private var tboID: GLuint = 0
    
    private var data = [GLfloat]()
    
    //  The CVDisplayLink for animating.  Optional value initialized to nil.
    private var displayLink: CVDisplayLink?
    
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
        
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28))
        glEnableVertexAttribArray(3)
        
        glBindVertexArray(0)
        
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
        
        
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                                                                                     \n" +
            "uniform sampler2D sample;                                                                                  \n" +
            "uniform struct Light {                                                                                     \n" +
            "    vec3 color;                                                                                            \n" +
            "    vec3 position;                                                                                         \n" +
            "    float ambient;                                                                                         \n" +
            "    float specStrength;                                                                                    \n" +
            "    float specHardness;                                                                                    \n" +
            "} light;                                                                                                   \n" +
            "in vec3 passPosition;                                                                                      \n" +
            "in vec3 passColor;                                                                                         \n" +
            "in vec2 passTexturePosition;                                                                               \n" +
            "in vec3 passNormal;                                                                                        \n" +
            "out vec4 outColor;                                                                                         \n" +
            "void main()                                                                                                \n" +
            "{                                                                                                          \n" +
            "     vec3 normal = normalize(passNormal);                                                                  \n" +
            "     vec3 lightRay = normalize(light.position - passPosition);                                             \n" +
            "     float intensity = dot(normal, lightRay);                                                              \n" +
            "     intensity = clamp(intensity, 0, 1);                                                                   \n" +
            "     vec3 viewer = normalize(vec3(0.0, 0.0, 0.2) - passPosition);                                          \n" +
            "     vec3 reflection = reflect(lightRay, normal);                                                          \n" +
            "     float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                          \n" +
            "     vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;   \n" +
            "     vec3 surface = texture(sample, passTexturePosition).rgb * passColor;                                  \n" +
            "     vec3 rgb = surface * light;                                                                           \n" +
            "     outColor = vec4(rgb, 1.0);                                                                            \n" +
        "}                                                                                                          \n"
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
        
        //  Uniforms for the light struct.  Each component is accessed using dot notation.
        glUniform3fv(glGetUniformLocation(programID, "light.color"), 1, [1.0, 1.0, 1.0])
        glUniform3fv(glGetUniformLocation(programID, "light.position"), 1, [0.0, 1.0, 0.1])
        glUniform1f(glGetUniformLocation(programID, "light.ambient"), 0.25)
        glUniform1f(glGetUniformLocation(programID, "light.specStrength"), 1.0)
        glUniform1f(glGetUniformLocation(programID, "light.specHardness"), 32)
        
        //  Set up the CVDisplayLink not that the pipeline is defined.
        //
        //  The following code was developed in response to personal endeavor as well as an answer to 
        //  a stackoverflow question that I initially answered before the CFunctionPointer worked.
        //  We'll cover the Swift/Obj-C/C implementation I developed for the same answer next time.
        //  I feel it is still worthwhile should you require briding between Obj-C and Swift.
        //
        //  The callback function is called everytime CVDisplayLink says its time to get a new frame.
        func displayLinkOutputCallback(displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
            
            /*  The displayLinkContext is CVDisplayLink's parameter definition of the view in which we are working.
            In order to access the methods of a given view we need to specify what kind of view it is as right
            now the UnsafeMutablePointer<Void> just means we have a pointer to "something".  To cast the pointer
            such that the compiler at runtime can access the methods associated with our SwiftOpenGLView, we use
            an unsafeBitCast.  The definition of which states, "Returns the the bits of x, interpreted as having
            type U."  We may then call any of that view's methods.  Here we call drawView() which we draw a
            frame for rendering.  */
            unsafeBitCast(displayLinkContext, SwiftOpenGLView.self).drawView()
            
            //  We are going to assume that everything went well for this mock up, and pass success as the CVReturn
            return kCVReturnSuccess
        }
        
        //  Grab the a link to the active displays, set the callback defined above, and start the link.
        /*  An alternative to a nested function is a global function or a closure passed as the argument--a local function
        (i.e. a function defined within the class) is NOT allowed. */
        //  The UnsafeMutablePointer<Void>(unsafeAddressOf(self)) passes a pointer to the instance of our class.
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
        CVDisplayLinkStart(displayLink!)
        
        //  Test render
        drawView()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    private func drawView() {
        
        //  Grab a context, make it the active context for drawing, and then lock the focus
        //  before making OpenGL calls that change state or data within objects.
        guard let context = self.openGLContext else {
            //  Just a filler error
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.CGLContextObj)
        
        //  To make the animation visible, we'll change the background color over time.
        //  CACurrentMediaTime() returns the amount of time since the app started.
        //  sin() is applied to this value and then a float value is made from it.
        //  glClearColor() takes four floats to create an rgba color.  We have not activated
        //  blending, so no matter what value we pass here is ignored.
        let value = Float(sin(CACurrentMediaTime()))
        glClearColor(value, value, value, 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programID)
        glBindVertexArray(vaoID)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(data.count))
        
        glBindVertexArray(0)
        
        //  glFlush() is replaced with CGLFlushDrawable() and swaps the buffer being displayed
        CGLFlushDrawable(context.CGLContextObj)
        CGLUnlockContext(context.CGLContextObj)
    }
    
    deinit {
        //  Stop the display link.
        CVDisplayLinkStop(displayLink!)
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
    }
    
}
