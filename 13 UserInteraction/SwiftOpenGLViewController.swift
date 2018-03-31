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


class SwiftOpenGLViewController: NSViewController, GraphicViewDataSource {
    @IBOutlet weak var interactiveView: SwiftOpenGLView!
    let assetManager = AssetManager()
    var mode = InstructionMode.edit
    var sceneName = SceneName()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactiveView.dataSource = self
    }
    
    func requestingScene(for time: Float) -> Scene? {
        return assetManager.process(frameRequest: FrameRequest(scene: sceneName, timeStamp: time)).scene
    }
}
