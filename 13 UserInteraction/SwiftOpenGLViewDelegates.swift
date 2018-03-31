//
//  SwiftOpenGLViewDelegates.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/28/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import CoreVideo.CVDisplayLink


struct DisplayLink {
    let id: CVDisplayLink
    let callback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
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
    var running: Bool = false
    
    init?(forView view: SwiftOpenGLView) {
        var newID: CVDisplayLink?
        
        if CVDisplayLinkCreateWithActiveCGDisplays(&newID) == kCVReturnSuccess {
            self.id = newID!
            CVDisplayLinkSetOutputCallback(id, callback, UnsafeMutableRawPointer(Unmanaged.passUnretained(view).toOpaque()))
        } else {
            return nil
        }
    }
    
    mutating func start() {
        if !running {
            CVDisplayLinkStart(id)
            running = true
        }
    }
    mutating func stop() {
        if running == true {
            CVDisplayLinkStop(id)
            running = false
        }
    }
}

struct FrameRequest {
    let scene: SceneName
    let timeStamp: Float
}
struct Frame {
    let sceneName: SceneName
    let timeStamp: Float
    let scene: Scene?
}
protocol GraphicViewDataSource {
    func requestingScene(for time: Float) -> Scene?
}
