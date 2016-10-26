//
//  ViewController.swift
//  OpenGLMVCPt2b
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 5: Implements SwiftOpenGLViewController as the
//      Data Source of the SwiftOpenGLView instance.
//

import Cocoa
import OpenGL.GLTypes


class SwiftOpenGLViewController: NSViewController, ViewRenderDelegate {
    
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        interactiveView.renderDelegate = self
    }
    
    // MARK: - User Interaction
    override func keyDown(with theEvent: NSEvent) {
        
        if let keyName = KeyCodeName(rawValue: theEvent.keyCode) {
            
            if directionKeys[keyName] != true {
                
                directionKeys[keyName] = true
                
            }
            
        } else { super.keyDown(with: theEvent) }
        
    }
    
    override func keyUp(with theEvent: NSEvent) {
        
        if let keyName = KeyCodeName(rawValue: theEvent.keyCode) {
            
            directionKeys[keyName] = false
            
        } else { super.keyUp(with: theEvent) }
        
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        rotateCamera(pitch: Float(theEvent.deltaY), yaw: Float(theEvent.deltaX))
        
    }
    
    // MARK: - CVDisplayLink
    var currentTime: Double = 0.0 {
        didSet(previousTime) {
            
            deltaTime = currentTime - previousTime
            
        }
    }
    var deltaTime: Double = 0.0
    var link: CVDisplayLink?
    let callback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
        
        //  CVTimeStamp has five fields.  Three of the five are very useful for
        //  keeping track of the current time, calculating delta time, the frame
        //  number, and the number of frames per second.  Two of the fields are
        //  a little more ambiguous as to what they are and how they may be
        //  useful.  The useful fields are videoTime, videoTimeScale, and
        //  videoRefreshPeriod.  The reason not all of the fields are readily
        //  understandable is that the developer documentation is very bad about
        //  using alternate names for each of fields and thus does not do a good
        //  job of describing the fields or comparing the fields to one another.
        //  Thankfully, CaptainRedmuff on StackOverflow asked a question that
        //  provided the equation that calculates frames per second.  From that
        //  equation, we can extrapolate the value of each field.
        //
        //  @hostTime = current time in Units of the "root".  Yeah, I don't know.
        //    The key to this field is to understand that it is in nanoseconds
        //    (e.g. 1/1_000_000_000 of a second) not units.  To convert it to
        //    seconds divide by 1_000_000_000.  Interestingly, dividing by
        //    videoRefreshPeriod and videoTimeScale in a calculation for frames
        //    per second still yields the appropriate number of frames.  This
        //    works as a result of proportionality--dividing seconds by seconds.
        //    by videoTimeScale to get the time in seconds does not work like it
        //    does for viedoTime.
        //
        //    framesPerSecond:
        //      (videoTime / videoRefreshPeriod) / (videoTime / videoTimeScale) = 59
        //          and
        //      (hostTime / videoRefreshPeriod) / (hostTime / videoTimeScale) = 59
        //          but
        //      hostTime * videoTimeScale ≠ seconds, but Units
        //      i.e. seconds * (Units / seconds) = Units
        //
        //  @rateScalar = ratio of "rate of device in CVTimeStamp/unitOfTime" to
        //    the "Nominal Rate".  I think the "Nominal Rate" is
        //    videoRefreshPeriod, but unfortunately, the documentation doesn't
        //    just say videoRefreshPeriod is the Nominal rate and then define
        //    what that means.  Regardless, because this is a ratio, and we know
        //    the value of one of the parts (e.g. Units/frame), we know that the
        //    "rate of the device" is frame/Units (the units of measure need to
        //    cancel out for the ratio to be a ratio).  This makes sense in that
        //    rateScalar's definition tells us the rate is "measured by timeStamps".
        //    Since there is a frame for every timeStamp, the rate of the device
        //    equals CVTimeStamp/Unit or frame/Unit.  Thus,
        //
        //      rateScalar = frame/Units : Units/frame
        //
        //  @videoTime = the time the frame was created since computer started up.
        //    If you turn your computer off and then turn it back on, this timer
        //    returns to zero.  The timer is paused when you put your computer to
        //    sleep, but it is paused.This value is in Units not seconds.  To get
        //    the number of seconds this value represents, you have to apply
        //    videoTimeScale.
        //  @videoRefreshPeriod = the number of Units per frame (i.e. Units/frame)
        //    This is useful in calculating the frame number or frames per second.
        //    The documentation calls this the "nominal update period"
        //
        //      frame = videoTime / videoRefreshPeriod
        //
        //  @videoTimeScale = Units/second, used to convert videoTime into seconds
        //    and may also be used with videoRefreshPeriod to calculate the expected
        //    framesPerSecond.  I say expected, because videoTimeScale and
        //    videoRefreshPeriod don't change while videoTime does change.  Thus,
        //    to to calculate fps in the case of system slow down, one would need to
        //    use videoTime with videoTimeScale to calculate the actual fps value.
        //
        //      seconds = videoTime / videoTimeScale
        //
        //      framesPerSecondConstant = videoTimeScale / videoRefreshPeriod
        
        //  Time in DD:HH:mm:ss using hostTime
        let rootTotalSeconds = inNow.pointee.hostTime
        let rootDays = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60 * 24) % 365
        let rootHours = inNow.pointee.hostTime / (1_000_000_000 * 60 * 60) % 24
        let rootMinutes = inNow.pointee.hostTime / (1_000_000_000 * 60) % 60
        let rootSeconds = inNow.pointee.hostTime / 1_000_000_000 % 60
        //    Swift.print("rootTotalSeconds: \(rootTotalSeconds) rootDays: \(rootDays) rootHours: \(rootHours) rootMinutes: \(rootMinutes) rootSeconds: \(rootSeconds)")
        
        //  Time in DD:HH:mm:ss using videoTime
        let totalSeconds = inNow.pointee.videoTime / Int64(inNow.pointee.videoTimeScale)
        let days = (totalSeconds / (60 * 60 * 24)) % 365
        let hours = (totalSeconds / (60 * 60)) % 24
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        //            Swift.print("totalSeconds: \(totalSeconds) Days: \(days) Hours: \(hours) Minutes: \(minutes) Seconds: \(seconds)")
        
        //            Swift.print("fps: \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod)) seconds: \(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))")
        
        let view = unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self)
        
        view.renderDelegate?.currentTime = Double(Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale))
        view.drawView()
        
        return kCVReturnSuccess
        
    }
    
    func setup() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        CVDisplayLinkSetOutputCallback(link!, callback, UnsafeMutableRawPointer(Unmanaged.passUnretained(interactiveView).toOpaque()))
        
        //  Push the triangle back from the viewer
        viewMatrix.m23 = -5.0
        projection = Matrix4(fieldOfView: 35, aspect: Float(interactiveView.bounds.size.width) / Float(interactiveView.bounds.size.height), nearZ: 0.001, farZ: 1000)
        interactiveView.view = viewMatrix
        interactiveView.projection = projection
    }
    
    func start() {
        if let link = self.link {
            CVDisplayLinkStart(link)
        }
    }
    
    func stop() {
        if let link = self.link {
            CVDisplayLinkStop(link)
        }
    }
    
    func prepare() {
        
        let value = Float(sin(currentTime))
        
        updateViewMatrix(atTime: currentTime)
        
        glClearColor(GLfloat(value), GLfloat(value), GLfloat(value), 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
    }
    
    deinit {
        stop()
    }
    
    //  TODO: - REMOVE INTO CAMERA OBJECT
    var viewMatrix = Matrix4()
    var projection = Matrix4()
    
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
    func updateViewMatrix(atTime time: CFTimeInterval) {
            
        let amplitude = 10 * Float(deltaTime)
        
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
            
            viewMatrix = Matrix4().rotateAlongXAxis(radians: cameraOrientation.v0).rotateAlongYAxis(radians: cameraOrientation.v1).translate(x: cameraPosition.v0, y: cameraPosition.v1, z: cameraPosition.v2)
            interactiveView.view = viewMatrix
            
        }
        
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
    
}

