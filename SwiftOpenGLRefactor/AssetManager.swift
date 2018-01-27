//
//  AssetManager.swift
//  SwiftOpenGLRefactor
//
//  Created by Myles Schultz on 1/23/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


private struct ObjectGraph {
    typealias AssetName = String
    
    var assetPositions: [ AssetName : Float3 ] = [ "globalCamera" : Float3(x: 0.0, y: 0.0, z: 0.0) ]
    
    mutating func move(_ asset: AssetName, in direction: Float3, with timeInterval: Float) {
        if let position = assetPositions[asset] {
            assetPositions[asset] = position.move(direction, over: timeInterval)
            print("\(asset) moved to \(assetPositions[asset]!)")
        }
    }
}
struct AssetManager: Respondable {
    typealias AssetName = String
    
    var instructions: [ UserInput : InstructionSet ] = [
        UserInput.key(.w) : InstructionSet(target: "globalCamera", instruction: Instruction.move(Float3(x: 0.0, y: 0.0, z: 1.0))),
        UserInput.key(.a) : InstructionSet(target: "globalCamera", instruction: Instruction.move(Float3(x: -1.0, y: 0.0, z: 0.0)))
    ]
    var assets: [ AssetName : Asset ] = [
        "globalCamera" : Camera()
    ]
    private var objectGraph = ObjectGraph()
    
    mutating func respond(to input: UserInput, at time: Double) {
        if let instructionSet = instructions[input] {
            switch instructionSet.instruction {
            case .move(let direction):
                objectGraph.move(instructionSet.target, in: direction, with: Float(time))
            }
        }
    }
}
