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


class SwiftOpenGLViewController: NSViewController, NSWindowDelegate, Respondable, RenderDelegate {
    
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    private var camera = SwiftCamera()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        interactiveView.renderDelegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillClose(_:)),
                                               name: .NSWindowWillClose,
                                               object: nil)
        camera.register("camera")
    }
    
    // MARK: - User Interactions
    func respondTo(_ input: UserInput) {
        <#code#>
    }
    override func keyDown(with theEvent: NSEvent) {
        
    }
    
    override func keyUp(with theEvent: NSEvent) {
        
        
        
    }
    
    override func mouseDragged(with theEvent: NSEvent) {
        
        
        
    }
    
    func windowWillClose(_ notification: Notification) {
        
        interactiveView.stopDrawing()
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .NSWindowWillClose,
                                                  object: nil)
        
    }
    
    //  MARK: - Render Delegate
    func prepareToDraw(frame atTime: Double) {
        
    }
    
}
