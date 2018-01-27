//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3

protocol Renderer {
    func draw(triangels start: Int32, to end: Int32)
}
extension Renderer {
    func draw(triangels start: Int32, to end: Int32) {
        glDrawArrays(GLenum(GL_TRIANGLES), start, end)
    }
}
extension NSOpenGLContext: Renderer {}

final class SwiftOpenGLView: NSOpenGLView, RenderLoopDelegate {
    var sceneName: String? {
        didSet {
            if !running {
                startDrawing()
            }
        }
    }
    
    private var value: Float = 0.0
    
    var view = FloatMatrix4()
    var projection = FloatMatrix4()
    
    /** The delegate is used to prepare a scene and the view for drawing.
        Through this method, we'll be able to update the view matrices,
        thus we'll move the viewProjectionMatrix related code to the 
        controller.  */
    var renderDelegate: RenderDelegate?
    
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
     EXAMPLE: Time in DD:HH:mm:ss using `hostTime`
     ````
     let rootTotalSeconds = inNow.pointee.hostTime
     let rootDays = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60 * 24) % 365
     let rootHours = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60) % 24
     let rootMinutes = inNow.pointee.hostTime / (1_000_000_000 * 60) % 60
     let rootSeconds = inNow.pointee.hostTime / 1_000_000_000 % 60
     print("rootTotalSeconds: \(rootTotalSeconds) rootDays: \(rootDays) rootHours: \(rootHours) rootMinutes: \(rootMinutes) rootSeconds: \(rootSeconds)")
     ````
     EXAMPLE: Time in DD:HH:mm:ss using `videoTime`
     ````
     let totalSeconds = inNow.pointee.videoTime / Int64(inNow.pointee.videoTimeScale)
     let days = (totalSeconds / (60 * 60 * 24)) % 365
     let hours = (totalSeconds / (60 * 60)) % 24
     let minutes = (totalSeconds / 60) % 60
     let seconds = totalSeconds % 60
     print("totalSeconds: \(totalSeconds) Days: \(days) Hours: \(hours) Minutes: \(minutes) Seconds: \(seconds)")
    
     print("fps: \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod)) seconds: \(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))")
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
        
        print("Preparing OpenGL parameters...")
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        setupLink()
        startDrawing()
        
        renderDelegate?.mayPrepareContent()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
//        drawView()
    }
    
    func drawView() {
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.cglContextObj!)

        renderDelegate?.prepareToRender(sceneName, at: currentTime)
        
        guard let sceneName = sceneName else {
            print("Default scene does not exist.")
            stopDrawing()
            return
        }
        value = sinf(Float(currentTime))
        
        glClearColor(GLfloat(value), GLfloat(value), GLfloat(value), 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        renderDelegate?.retrieve(sceneName)?.draw(with: context)
        
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
            print("Currently not drawing:  drawing initiated...")
            CVDisplayLinkStart(link)
            running = true
        }
    }
    
    func stopDrawing() {
        if running == true, let link = self.link {
            print("Drawing stopped.")
            CVDisplayLinkStop(link)
            running = false
        }
    }
}
