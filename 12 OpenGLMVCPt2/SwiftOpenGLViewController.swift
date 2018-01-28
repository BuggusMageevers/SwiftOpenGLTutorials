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


class SwiftOpenGLViewController: NSViewController, RenderDelegate {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    var scenes = [String : Scene]()
    
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
}
