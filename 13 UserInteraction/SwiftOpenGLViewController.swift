//
//  SwiftOpenGLViewController.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/28/18.
//  Copyright © 2018 MyKo. All rights reserved.
//
//  Ver 5:  Takes in user input and sends it to an AssetManager
//      where the appropriate action is applied to the model.
//

import Cocoa


class SwiftOpenGLViewController: NSViewController, RenderDelegate {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    var scenes = [String : Scene]()
    var assetManager = AssetManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scenes["Scene"] = Scene(named: "Scene")
        interactiveView.renderDelegate = self
    }
    
    func loadScene() {
        scenes["Scene"]?.load(into: interactiveView)
    }
    
    func prepareToRender(_ scene: SceneName, for time: Double) {
        scenes[scene]!.update(with: Float(time))
    }
    
    func render(_ scene: SceneName, with renderer: Renderer) {
        scenes[scene]!.draw(with: renderer)
    }
    
    override func keyDown(with event: NSEvent) {
        if let input = UserInput.Keyboard(rawValue: event.keyCode) {
            assetManager.respond(to: UserInput.key(input), at: event.timestamp)
        }
    }
}
