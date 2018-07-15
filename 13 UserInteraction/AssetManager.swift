//
//  AssetManager.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/23/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


final class AssetManager {
    private var scenes: [SceneName : Scene] = [:]
    
    func process(frameRequest: FrameRequest) -> Frame {
        let objectLayout = ObjectGraph.layout(for: frameRequest)
        return Frame(sceneName: frameRequest.scene, timeStamp: frameRequest.timeStamp, scene: nil)
    }
}

