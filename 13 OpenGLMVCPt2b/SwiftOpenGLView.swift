//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3


/**
 The RenderDelegate is used by an instance of SwiftOpenGLView to
 outsource the drawing methods.  This allows a controller to take
 over non-view-related code.
 */
protocol RenderDelegate {
    
    func prepareToDraw()
    
}


final class SwiftOpenGLView: NSOpenGLView, RenderLoopDelegate {
    
    fileprivate var programID: GLuint = 0
    fileprivate var vaoID: GLuint = 0
    fileprivate var vboID: GLuint = 0
    fileprivate var tboID: GLuint = 0
    
    fileprivate var data = [GLfloat]()
    
    var view = Matrix4()
    fileprivate var projection = Matrix4()
    // FIXME: remove me
    var value: Float = 0.0
    
    /** The delegate is used to prepare a scene and the view for drawing.
        Through this method, we'll be able to update the view matrices,
        thus we'll move the viewProjectionMatrix related code to the 
        controller.  */
    var delegate: RenderDelegate?
    
    /** CVDisplayLink for driving the render loop. After several attempts
        at trying to pull the CVDisplayLink out of the view, I have
        decided to leave it.  While taking the link out of the view would
        seem more appropriate, it is very awkward to have to reference the
        the view to set the current time from within the controller. Not
        only does leaving the link in the view remove this awkward line of
        code, it also allows us to use view.startDrawLoop() which is very
        clear in it's purpose.  Starting the link through a delegate
        produces more ambiguous lines of code.  Another reason for using
        this format is that Apple's MTLView does something very similar.
        In moving to Metal eventually, this would allow for better symmetry.  */
    internal var link: CVDisplayLink?
    var currentTime: Double = 0.0 {
        didSet(previousTime) {
            
            deltaTime = currentTime - previousTime
            
        }
    }
    var deltaTime: Double = 0.0
    /** Both running and callback are for use within the view alone so
        they have been designated as internal--thus protecting them from
        being tampered with from outside. */
    internal var running = false
    /**
     CVTimeStamp has five fields.  Three of the five are very useful
     for keeping track of the current time, calculating delta time, the
     frame number, and the number of frames per second.  Two of the
     fields are a little more ambiguous as to what they are and how
     they may be useful.  The useful fields are videoTime,
     videoTimeScale, and videoRefreshPeriod.  The reason not all of the
     fields are readily understandable is that the developer
     documentation is very bad about using alternate names for each of
     fields and thus does not do a good job of describing the fields or
     comparing the fields to one another.
     Thankfully, CaptainRedmuff on StackOverflow asked a question that
     provided the equation that calculates frames per second.  From
     that equation, we can extrapolate the value of each field.
    - hostTime: Current time in Units of the "root".  Yeah, I don't know.  The key to this field is to understand that it is in nanoseconds (e.g. 1/1_000_000_000 of a second) not units.  To convert it to seconds divide by 1_000_000_000.  Interestingly, dividing by videoRefreshPeriod and videoTimeScale in a calculation for frames per second still yields the appropriate number of frames.  This works as a result of proportionality-- dividing seconds by seconds. by videoTimeScale to get the time in seconds does not work like it   does for viedoTime.
        ````
        framesPerSecond: (videoTime / videoRefreshPeriod) / (videoTime / videoTimeScale) = 59
        ````
        and
        ````
        (hostTime / videoRefreshPeriod) / (hostTime / videoTimeScale) = 59
        ````
        but `hostTime * videoTimeScale ≠ seconds`, but Units (i.e. `seconds * (Units / seconds) = Units`)
    - rateScalar Ratio of "rate of device in CVTimeStamp/unitOfTime" to the "Nominal Rate".  I think the "Nominal Rate" is videoRefreshPeriod, but unfortunately, the documentation doesn't just say videoRefreshPeriod is the Nominal rate and then define what that means.  Regardless, because this is a ratio, and we know the value of one of the parts (e.g. Units/frame), we know that the "rate of the device" is frame/Units (the units of measure need to cancel out for the ratio to be a ratio).  This makes sense in that rateScalar's definition tells us the rate is "measured by timeStamps".  Since there is a frame for every timeStamp, the rate of the device equals CVTimeStamp/Unit or frame/Unit.  Thus,
        ````
        rateScalar = frame/Units : Units/frame
        ````
    - videoTime: the time the frame was created since computer started up.  If you turn your computer off and then turn it back on, this timer returns to zero.  The timer is paused when you put your computer to sleep, but it is paused.This value is in Units not seconds.  To get the number of seconds this value represents, you have to apply videoTimeScale.
    - videoRefreshPeriod: the number of Units per frame (i.e. Units/frame) This is useful in calculating the frame number or frames per second.  The documentation calls this the "nominal update period"
        ````
        frame = videoTime / videoRefreshPeriod
        ````
    - videoTimeScale: Units/second, used to convert videoTime into seconds and may also be used with videoRefreshPeriod to calculate the expected framesPerSecond.  I say expected, because videoTimeScale and videoRefreshPeriod don't change while videoTime does change.  Thus, to to calculate fps in the case of system slow down, one would need to use videoTime with videoTimeScale to calculate the actual fps value.
        ````
        seconds = videoTime / videoTimeScale

        framesPerSecondConstant = videoTimeScale / videoRefreshPeriod
        ````
     Time in DD:HH:mm:ss using hostTime
     ````
     let rootTotalSeconds = inNow.pointee.hostTime
     let rootDays = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60 * 24) % 365
     let rootHours = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60) % 24
     let rootMinutes = inNow.pointee.hostTime / (1_000_000_000 * 60) % 60
     let rootSeconds = inNow.pointee.hostTime / 1_000_000_000 % 60
     Swift.print("rootTotalSeconds: \(rootTotalSeconds) rootDays: \(rootDays) rootHours: \(rootHours) rootMinutes: \(rootMinutes) rootSeconds: \(rootSeconds)")
     ````
     Time in DD:HH:mm:ss using videoTime
     ````
     let totalSeconds = inNow.pointee.videoTime / Int64(inNow.pointee.videoTimeScale)
     let days = (totalSeconds / (60 * 60 * 24)) % 365
     let hours = (totalSeconds / (60 * 60)) % 24
     let minutes = (totalSeconds / 60) % 60
     let seconds = totalSeconds % 60
     Swift.print("totalSeconds: \(totalSeconds) Days: \(days) Hours: \(hours) Minutes: \(minutes) Seconds: \(seconds)")
    
     Swift.print("fps: \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod)) seconds: \(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))")
     ````
     */
    internal let callback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
 
        weak var view = unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self)
        
        view!.currentTime = Double(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))
        view!.drawView()
        
        return kCVReturnSuccess
        
    }
    
    /// In order to recieve keyboard input, we need to enable the view to accept first responder status
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
        guard let textureData = NSImage(named: NSImage.Name("Texture"))?.tiffRepresentation else {
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
        var source = """
            #version 330 core                                        \n
            layout (location = 0) in vec2 position;                           \n
            layout (location = 1) in vec3 color;                              \n
            layout (location = 2) in vec2 texturePosition;                    \n
            layout (location = 3) in vec3 normal;                             \n
            out vec3 passPosition;                                            \n
            out vec3 passColor;                                               \n
            out vec2 passTexturePosition;                                     \n
            out vec3 passNormal;                                              \n
            uniform mat4 view;                                                \n
            uniform mat4 projection;                                          \n
            void main()                                                       \n
            {                                                                 \n
                gl_Position = projection * view * vec4(position, 0.0, 1.0);   \n
                passPosition = vec3(position, 0.0);                           \n
                passColor = color;                                            \n
                passTexturePosition = texturePosition;                        \n
                passNormal = normal;                                          \n
            }                                                                 \n
        """
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
        source = """
            #version 330 core                                                                                    \n
            uniform sampler2D sample;                                                                                 \n
            uniform struct Light {                                                                                    \n
               vec3 color;                                                                                            \n
               vec3 position;                                                                                         \n
               float ambient;                                                                                         \n
               float specStrength;                                                                                    \n
               float specHardness;                                                                                    \n
            } light;                                                                                                  \n
            in vec3 passPosition;                                                                                     \n
            in vec3 passColor;                                                                                        \n
            in vec2 passTexturePosition;                                                                              \n
            in vec3 passNormal;                                                                                       \n
            out vec4 outColor;                                                                                        \n
            void main()                                                                                               \n
            {                                                                                                         \n
                vec3 normal = normalize(passNormal);                                                                  \n
                vec3 lightRay = normalize(light.position - passPosition);                                             \n
                float intensity = dot(normal, lightRay);                                                              \n
                intensity = clamp(intensity, 0, 1);                                                                   \n
                vec3 viewer = normalize(vec3(0.0, 0.0, 0.2) - passPosition);                                          \n
                vec3 reflection = reflect(lightRay, normal);                                                          \n
                float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                          \n
                vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;   \n
                vec3 surface = texture(sample, passTexturePosition).rgb * passColor;                                  \n
                vec3 rgb = surface * light;                                                                           \n
                outColor = vec4(rgb, 1.0);                                                                            \n
            }                                                                                                         \n
        """
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
        
        //  Push the triangle back from the viewer
        view.m23 = -5.0
        projection = Matrix4(fieldOfView: 35, aspect: Float(bounds.size.width) / Float(bounds.size.height), nearZ: 0.001, farZ: 1000)
        
        drawView()
        
        setupLink()
        startDrawing()
        
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
        
        delegate?.prepareToDraw()
        
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
    
    
    //  MARK: - CVDisplayLink functions
    internal func setupLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        CVDisplayLinkSetOutputCallback(link!, callback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    
    func startDrawing() {
        
        if running == false, let link = self.link {
            
            CVDisplayLinkStart(link)
            
        }
        
    }
    
    func stopDrawing() {
        
        if running == true, let link = self.link {
            
            CVDisplayLinkStop(link)
            
        }
        
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID)
    }
    
}
