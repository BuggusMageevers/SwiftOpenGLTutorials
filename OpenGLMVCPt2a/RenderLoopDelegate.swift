//
//  RenderLoopDelegate.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 10/8/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver 1:  Initial implementation of a delegate to drive views
//      that continuously render scenes.
//

import Foundation
import CoreVideo.CVDisplayLink


protocol RenderLoopDelegate {
    
    //Mark: DisplayLink
    var link: CVDisplayLink? { get set }
    var callback: CVDisplayLinkOutputCallback { get }
    var running: Bool { get set }
    
    func setupLink(forView view: SwiftOpenGLView)
    
    func startDrawLoop()
    func stopDrawLoop()
    
    //MARK: Time, Time Calculations
    var currentTime: Double { get set }
    var deltaTime: Double { get }
    
}
