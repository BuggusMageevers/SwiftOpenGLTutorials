//
//  ViewController.swift
//  OpenGLMVCPt1
//
//  Created by Myles Schultz on 9/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Cocoa


class SwiftOpenGLViewController: NSViewController {
    
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
