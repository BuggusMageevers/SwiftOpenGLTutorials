//
//  ViewController.swift
//  OnTheMove
//
//  Created by Myles La Verne Schultz on 10/27/15.
//  Copyright © 2015 MyKo. All rights reserved.
//
//  Ver. 2:  Initial implementation of user interaction to move through
//           the 3D world.  AWSD keys move the camera position along the
//           x, r, and z planes while mouse movement re-oritents the
//           camera direction.
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
            
            if let keyName = SwiftOpenGLView.KeyCodeName(rawValue: theEvent.keyCode) {
                
                if view.directionKeys[keyName] != true {
                    
                    view.directionKeys[keyName] = true
                
                }
                
            }
            
        } else { super.keyDown(theEvent) }
        
    }
    override func keyUp(theEvent: NSEvent) {
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            if let keyName = SwiftOpenGLView.KeyCodeName(rawValue: theEvent.keyCode) {
                
                view.directionKeys[keyName] = false
                
            }
            
        } else { super.keyUp(theEvent) }
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            view.rotateCamera(pitch: Float(theEvent.deltaY), yaw: Float(theEvent.deltaX))
            
        }
        
    }

}

