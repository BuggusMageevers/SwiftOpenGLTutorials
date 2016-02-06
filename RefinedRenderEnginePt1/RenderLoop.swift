//
//  RenderLoop.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import Quartz


func displayLinkOutputCallback(displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
    
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
    
    let rootTotalSeconds = inNow.memory.hostTime
    let rootDays = inNow.memory.hostTime / (1_000_000_000 * 60 * 60 * 24) % 365
    let rootHours = inNow.memory.hostTime / (1_000_000_000 * 60 * 60) % 24
    let rootMinutes = inNow.memory.hostTime / (1_000_000_000 * 60) % 60
    let rootSeconds = inNow.memory.hostTime / 1_000_000_000 % 60
    Swift.print("rootTotalSeconds: \(rootTotalSeconds) rootDays: \(rootDays) rootHours: \(rootHours) rootMinutes: \(rootMinutes) rootSeconds: \(rootSeconds)")
    
    let totalSeconds = inNow.memory.videoTime / Int64(inNow.memory.videoTimeScale)
    let days = (totalSeconds / (60 * 60 * 24)) % 365
    let hours = (totalSeconds / (60 * 60)) % 24
    let minutes = (totalSeconds / 60) % 60
    let seconds = totalSeconds % 60
    Swift.print("totalSeconds: \(totalSeconds) Days: \(days) Hours: \(hours) Minutes: \(minutes) Seconds: \(seconds)")
    
    Swift.print("fps: \(Double(inNow.memory.videoTimeScale) / Double(inNow.memory.videoRefreshPeriod)) seconds: \(inNow.memory.videoTime / Int64(inNow.memory.videoTimeScale))")
    
    let view = unsafeBitCast(displayLinkContext, SwiftOpenGLView.self)
    
    view.renderLoop.currentTime = Double(inNow.memory.videoTime) / Double(inNow.memory.videoTimeScale)
    view.drawView()
    
    return kCVReturnSuccess
    
}

struct RenderLoop {
    
    var link: CVDisplayLink?
    
    var currentTime = Double() {
        willSet {
            deltaTime = newValue - currentTime
        }
    }
    var deltaTime = Double()
    
    init(forView view: SwiftOpenGLView) {
        
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        CVDisplayLinkSetOutputCallback(link!, displayLinkOutputCallback, UnsafeMutablePointer<Void>(unsafeAddressOf(view)))
        
    }
    
    func start() { CVDisplayLinkStart(link!) }
    
    func stop() { CVDisplayLinkStop(link!) }
    
}
