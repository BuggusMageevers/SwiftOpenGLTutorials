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


class SwiftOpenGLViewController: NSViewController, NSWindowDelegate, RenderDelegate, Respondable {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    private var globalCamera = SwiftCamera()
    internal var instructables: [InstructionTarget : Instructable] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional set after loading the view.
        interactiveView.renderDelegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillClose(_:)),
                                               name: NSWindow.willCloseNotification,
                                               object: nil)
        
        instructables = [
            InstructionTarget.globalCamera : globalCamera
        ]
    }
    
    // MARK: - User Interactions
    override func keyDown(with event: NSEvent) {
        if let key = UserInput.Key(rawValue: event.keyCode) {
            respondTo(InputDevice.keyboard(key), in: .move)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        
        
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        
        
    }
    
    func windowWillClose(_ notification: Notification) {
        interactiveView.stopDrawing()
        NotificationCenter.default.removeObserver(self,
                                                  name: NSWindow.willCloseNotification,
                                                  object: nil)
    }
    
    // MARK: - Render Delegate
    func prepareToDraw(frame atTime: Double) {
        
        
        
    }
}
