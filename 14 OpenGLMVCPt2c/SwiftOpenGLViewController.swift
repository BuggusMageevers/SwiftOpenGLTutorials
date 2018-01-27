//
//  ViewController.swift
//  OpenGLMVCPt2b
//
//  Created by Myles Schultz on 10/16/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 6:
//

import Cocoa
import OpenGL.GLTypes


class SwiftOpenGLViewController: NSViewController, NSWindowDelegate, RenderDelegate {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    private var globalCamera = SwiftCamera()
    private var assetManager = AssetManager()
    
    override func viewDidLoad() {
        print("Initializing views and controls...")
        super.viewDidLoad()
        
        interactiveView.renderDelegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowWillClose(_:)),
                                               name: NSWindow.willCloseNotification,
                                               object: nil)
    }
    
    // MARK: - User Interactions
    override func keyDown(with event: NSEvent) {
        if let key = UserInput.Key(rawValue: event.keyCode) {
            assetManager.respond(to: UserInput.keyboard(key), at: event.timestamp)
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
    func mayPrepareContent() {
        assetManager.prepare()
        assetManager.get(viewSize: Float(interactiveView.bounds.size.width / interactiveView.bounds.size.height))
    }
    func prepareToRender(_ scene: String?, at time: Double) {
        if let scene = scene {
            assetManager.updateAssets(in: scene, for: time)
        } else {
            print("Creating Scene...")
            assetManager.load("Scene")
            interactiveView.sceneName = "Scene"
        }
    }
    func retrieve(_ scene: String) -> Scene? {
        return assetManager.scenes[scene]
    }
    
    deinit {
        assetManager.deleteAssets()
    }
}
