//
//  RenderLoopDelegate.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation
import CoreVideo.CVDisplayLink

//
protocol ViewRenderDelegate {
    
    //  Mark: DisplayLink
    var link: CVDisplayLink? { get set }
    var callback: CVDisplayLinkOutputCallback { get }
    
    func setup()
    
    func start()
    func stop()
    
    //  MARK:   Time, Time Calculations
    var currentTime: Double { get set }
    var deltaTime: Double { get }
    
    //  MARK:   Scene Preparation
    func prepare()
    
}
