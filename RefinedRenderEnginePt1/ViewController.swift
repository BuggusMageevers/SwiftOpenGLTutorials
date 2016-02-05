//
//  ViewController.swift
//  RefinedRenderEnginePt1
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 3:  Camera controlls have been redirected to a SwiftCamera
//           instance held by the view.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            if let keyName = SwiftCamera.KeyCodeName(rawValue: theEvent.keyCode) {
                
                if view.camera.directionKeys[keyName] != true {
                    
                    view.camera.directionKeys[keyName] = true
                    
                }
                
            }
            
        } else { super.keyDown(theEvent) }
        
    }

    override func keyUp(theEvent: NSEvent) {
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            if let keyName = SwiftCamera.KeyCodeName(rawValue: theEvent.keyCode) {
                
                view.camera.directionKeys[keyName] = false
                
            }
            
        } else { super.keyUp(theEvent) }
        
    }

    override func mouseDragged(theEvent: NSEvent) {
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            view.camera.rotateCamera(pitch: Float(theEvent.deltaY), yaw: Float(theEvent.deltaX))
            
        }
        
    }
    
}
