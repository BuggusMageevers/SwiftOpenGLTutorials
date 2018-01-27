//
//  AssetManager.swift
//  OpenGLMVCPt2c
//
//  Created by Myles Schultz on 10/21/17.
//  Copyright © 2017 MyKo. All rights reserved.
//

import Foundation


final class AssetManager: Respondable {
    typealias AssetName = String
    typealias SceneName = String
    
    var instructions: [ UserInput : InstructionSet ] = [
        UserInput.keyboard(.w) : InstructionSet(target: "globalCamera", instruction: Instruction.move(Float3(x: 0.0, y: 0.0, z: 1.0)))
    ]
    var assets: [ AssetName : Asset ] = [:]
    var scenes: [SceneName : Scene] = [:]
    var objectGraph = ObjectGraph()
    
    func prepare() {
        assets = [
            "globalCamera" : Camera(),
            "Light" : Light(),
            "Triangle" : Mesh(),
            "Texture" : SwiftTexture()
        ]
    }
    
    func load(_ scene: SceneName) {
        let mesh = assets["Triangle"] as? Mesh
        //FIXME: IMPLEMENT true scene loading
        if let cameras = assets["globalCamera"], let lights = assets["Light"], let meshes = assets["Triangle"] {
            scenes[scene] = Scene(cameras: [cameras as! Camera], lights: [lights as! Light], meshes: [meshes as! Mesh])
            (assets["Texture"] as! SwiftTexture).load("Texture")
            scenes[scene]?.shader.setUniforms()
        }
    }
    func get(viewSize ratio: Float) {
        var camera = assets["globalCamera"] as! Camera
        camera.projection = FloatMatrix4.projection(fieldOfView: 35, aspect: ratio, nearZ: 0.001, farZ: 1000)
        assets["globalCamera"] = camera
    }
    
    func respond(to input: UserInput, at time: Double) {
        if let instructionSet = instructions[input] {
            switch instructionSet.instruction {
            case .move(let direction):
                objectGraph.move(instructionSet.target, in: direction, with: time)
            }
        }
    }
    
    func updateAssets(in scene: SceneName, for time: Double) {
        
    }
    
    func deleteAssets() {
        for (_, var asset) in assets {
            asset.delete()
        }
    }
}

struct ObjectGraph {
    typealias AssetName = String
    
    var assetPositions: [ AssetName : Float3 ] = [ "globalCamera" : Float3(x: 0.0, y: 0.0, z: 0.0) ]
    
    mutating func move(_ asset: AssetName, in direction: Float3, with timeInterval: Double) {
        if let position = assetPositions[asset] {
            assetPositions[asset] = position.move(direction, over: Float(timeInterval))
            print("\(asset) moved to \(assetPositions[asset]!)")
        }
    }
}
