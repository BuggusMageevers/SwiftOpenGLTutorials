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
    
    //  MARK: DisplayLink
    /**
     A referrence to a `CVDisplayLink`.
     */
    var link: CVDisplayLink? { get set }
    var callback: CVDisplayLinkOutputCallback { get }
    /**
     A property to indicate if the callback is being called with each
     refresh of the screen.
     */
    var running: Bool { get set }
    
    /**
     To be used for the creation of a `CVDisplayLink` and the setting
     of the callback function.
     */
    func setupLink()
    
    /**
     Starts the `CVDisplayLink` which will cyclicly call the callback
     function.
     */
    func startDrawing()
    /**
     Stops the `CVDisplayLink`.  Should be called anytime the view is not
     being seen by the user so as to save resources.
     */
    func stopDrawing()
    
    //  MARK: Time, Time Calculations
    /**
     The current elapsed time from the start of the application.
     */
    var currentTime: Double { get set }
    /**
     Idealy set everytime currentTime is set.  Use didSet on currentTime
     to acheive this update.  This is the amount of time between the
     previous frame and the current frame.
     */
    var deltaTime: Double { get }
    
}
