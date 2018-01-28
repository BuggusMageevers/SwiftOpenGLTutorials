//
//  SwiftOpenGLViewDelegates.swift
//  OpenGLMVCPt2a
//
//  Created by Myles Schultz on 1/27/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import CoreVideo.CVDisplayLink


struct DisplayLink {
    let id: CVDisplayLink
    let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
        //        print("fps:  \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod))")
        
        let view = unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self)
        view.displayLink?.currentTime = Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale)
        let result = view.drawView()
        
        return result
    }
    var currentTime: Double = 0.0 {
        willSet {
            deltaTime = currentTime - newValue
        }
    }
    var deltaTime: Double = 0.0
    
    init?(forView view: SwiftOpenGLView) {
        var newID: CVDisplayLink?
        
        if CVDisplayLinkCreateWithActiveCGDisplays(&newID) == kCVReturnSuccess {
            self.id = newID!
            CVDisplayLinkSetOutputCallback(id, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(view).toOpaque()))
        } else {
            return nil
        }
    }
    
    func start() {
        CVDisplayLinkStart(id)
    }
    func stop() {
        CVDisplayLinkStop(id)
    }
}

protocol RenderDelegate {
    func loadScene()
    func prepareToRender(_ scene: SceneName, for time: Double)
    func render(_ scene: SceneName, with renderer: Renderer)
}
