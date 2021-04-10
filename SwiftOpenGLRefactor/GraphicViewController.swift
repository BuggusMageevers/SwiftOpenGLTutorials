//
//  ViewController.swift
//  SwiftOpenGLRefactor
//
//  Created by Myles Schultz on 1/17/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Cocoa

final class GraphicViewController: NSViewController, RenderDelegate {
    @IBOutlet weak var graphicView: GraphicView!
    var scene = Scene()
    var scenes = [String : Scene]()
    var sceneLoaded = false
    var assetManager = AssetManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scenes["Scene"] = self.scene
        graphicView.renderDelegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func loadScene() {
        scenes["Scene"]?.load(into: graphicView)
        graphicView.scene = "Scene"
        sceneLoaded = true
    }
    func prepareToRender(_ scene: RenderDelegate.SceneName, for time: Double) {
        scenes[scene]!.update(with: Float(time))
    }
    func render(_ scene: RenderDelegate.SceneName, with renderer: Renderer) {
        scenes[scene]!.draw(with: renderer)
    }
    
    override func mouseDown(with event: NSEvent) {
        if sceneLoaded == false {
            print("Loading scene...")
            graphicView.openGLContext?.makeCurrentContext()
            scenes["Scene"]?.load(into: graphicView)
            graphicView.scene = "Scene"
            sceneLoaded = true
        } else {
            print("Scene already loaded.")
        }
    }
    override func keyDown(with event: NSEvent) {
        if let input = UserInput.Keyboard(rawValue: event.keyCode) {
            assetManager.respond(to: UserInput.key(input), at: event.timestamp)
        }
    }
    
    deinit {
        scene.delete()
        scenes["Scene"]!.delete()
    }
}

