//
//  ViewController.swift
//  OpenGLMVCPt2b
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 5: Implements SwiftOpenGLViewController as the
//      Data Source of the SwiftOpenGLView instance.
//

import Cocoa
import OpenGL.GLTypes


class SwiftOpenGLViewController: NSViewController, NSWindowDelegate, RenderDelegate {
    
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    fileprivate var camera = SwiftCamera()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        interactiveView.delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillClose(_:)),
                                               name: .NSWindowWillClose,
                                               object: nil)
    }
    
    // MARK: - User Interaction
    override func keyDown(with theEvent: NSEvent) {
        
        if let keyName = SwiftCamera.KeyCodeName(rawValue: theEvent.keyCode) {
            
            if camera.directionKeys[keyName] != true {
                
                camera.directionKeys[keyName] = true
                
            }
            
        } else { super.keyDown(with: theEvent) }
        
    }
    
    override func keyUp(with theEvent: NSEvent) {
        
        if let keyName = SwiftCamera.KeyCodeName(rawValue: theEvent.keyCode) {
            
            camera.directionKeys[keyName] = false
            
        } else { super.keyUp(with: theEvent) }
        
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        camera.rotateCamera(pitch: Float(theEvent.deltaY), yaw: Float(theEvent.deltaX))
        
    }
    
    func windowWillClose(_ notification: Notification) {
        
        interactiveView.stopDrawing()
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .NSWindowWillClose,
                                                  object: nil)
        
    }
    
    //  MARK: - Render Delegate
    func prepareToDraw() {
        
        interactiveView.value = Float(sin(interactiveView.currentTime))
        
        interactiveView.view = camera.updateViewMatrix(forTime: interactiveView.deltaTime)
        
    }
    
}
