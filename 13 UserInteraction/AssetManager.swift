//
//  AssetManager.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/23/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


private struct ObjectGraph {
    typealias AssetName = String
    
    var assetPositions: [ AssetName : Float3 ] = [ "Global Camera" : Float3(x: 0.0, y: 0.0, z: 0.0) ]
    
    mutating func move(_ asset: AssetName, in direction: Float3, with timeInterval: Float) {
        if let position = assetPositions[asset] {
            assetPositions[asset] = position.move(direction, over: timeInterval)
            print("\(asset) moved to \(assetPositions[asset]!)")
        }
    }
}
struct AssetManager: Respondable, GraphicViewDataSource {
    typealias AssetName = String
    
    var instructions: [ UserInput : InstructionSet ] = [
        UserInput.key(.w) : InstructionSet(target: "Global Camera", instruction: Instruction.move(Float3(x: 0.0, y: 0.0, z: 1.0))),
        UserInput.key(.a) : InstructionSet(target: "Global Camera", instruction: Instruction.move(Float3(x: -1.0, y: 0.0, z: 0.0)))
    ]
    private var assets: [ AssetName : Asset ] = [
        "Global Camera" : Camera(named: "Global Camera")
    ]
    private var scenes: [ SceneName : Scene ] = [:]
    private var objectGraph = ObjectGraph()
    
    mutating func load(sceneNamed name: SceneName, into view: SwiftOpenGLView) {
        var scene = Scene(named: name)
        scene.load(into: view)
        scenes[name] = scene
    }
    mutating func prepareToRender(_ scene: SceneName, for time: Float) {
        scenes[scene]?.update(with: time)
    }
    mutating func draw(_ scene: SceneName, with renderer: Renderer) {
        scenes[scene]?.draw(with: renderer)
    }
    
    mutating func respond(to input: UserInput, at time: Double) {
        if let instructionSet = instructions[input] {
            switch instructionSet.instruction {
            case .move(let direction):
                objectGraph.move(instructionSet.target, in: direction, with: Float(time))
            }
        }
    }
}

