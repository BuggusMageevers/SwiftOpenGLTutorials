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


class SwiftOpenGLViewController: NSViewController {

    var interactiveView: SwiftOpenGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let view = self.view.subviews[0] as? SwiftOpenGLView {
            
            interactiveView = view
            
        }
        
    }
    
    override func keyDown(with theEvent: NSEvent) {
            
        if let keyName = SwiftOpenGLView.KeyCodeName(rawValue: theEvent.keyCode) {
            
            if interactiveView.directionKeys[keyName] != true {
                
                interactiveView.directionKeys[keyName] = true
            
            }
            
        } else { super.keyDown(with: theEvent) }
        
    }
    
    override func keyUp(with theEvent: NSEvent) {
            
        if let keyName = SwiftOpenGLView.KeyCodeName(rawValue: theEvent.keyCode) {
            
            interactiveView.directionKeys[keyName] = false
            
        } else { super.keyUp(with: theEvent) }
        
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
            
        interactiveView.rotateCamera(pitch: Float(theEvent.deltaY), yaw: Float(theEvent.deltaX))
        
    }

}
