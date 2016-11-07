//
//  ViewController.swift
//  OpenGLMVCPt2a
//
//  Created by Myles Schultz on 10/5/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver 4:  Incorporates a render delegate to the drive the
//      drawing loop of the interactive view.  The view
//      controller or an dedicated object could accomplish this
//      task.
//

import Cocoa


class SwiftOpenGLViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillClose(_:)),
                                               name: Notification.Name.NSWindowWillClose,
                                               object: nil)
    }
    
    // MARK: - User Interaction
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
    
    func windowWillClose(_ notification: Notification) {
        interactiveView.stopDrawLoop()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.NSWindowWillClose,
                                                  object: nil)
        
    }
    
}
