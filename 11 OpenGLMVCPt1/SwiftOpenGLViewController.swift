//
//  ViewController.swift
//  OpenGLMVCPt1
//
//  Created by Myles Schultz on 9/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver 3:  First step in developing our app to be MVC compliant.  Uses
//      an IBOutlet to reference the instance of SwiftOpenGLView we
//      created in interface builder.
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
