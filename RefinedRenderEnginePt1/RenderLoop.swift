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
    
//    let hostTime = inNow.memory.hostTime
    let rateScalar = inNow.memory.rateScalar
    let videoRefreshPeriod = inNow.memory.videoRefreshPeriod
    let videoTime = inNow.memory.videoTime
    let videoTimeScale = inNow.memory.videoTimeScale
    
//    Swift.print("hostTime: \(hostTime), rateScalar: \(rateScalar), videoRefreshPeriod: \(videoRefreshPeriod), videoTime: \(videoTime), videoTimeScale: \(videoTimeScale)")
    Swift.print("fps: \((rateScalar * Double(videoTimeScale) / Double(videoRefreshPeriod))), time: \(Double(videoTime) / Double(videoTimeScale))")
    
    let view = unsafeBitCast(displayLinkContext, SwiftOpenGLView.self)
    
    view.renderLoop.currentTime = Double(videoTime) / Double(videoTimeScale)
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
