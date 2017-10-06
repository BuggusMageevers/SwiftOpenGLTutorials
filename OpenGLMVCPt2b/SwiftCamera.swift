//
//  SwiftCamera.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 11/6/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation

//  Eventually, we'll implement an object graph that manages all of the positions of the available objects.  It will calculate their displacements, orientations, and animations.
struct SwiftCamera: Instructable {
    func perform(_ instruction: Instruction) {
        print("Instruction \"\(instruction)\" sent to camera")
    }
    
    private var displacementVector = Vector3(v0: 0.0, v1: 0.0, v2: 0.0)
    
    mutating func move(_ direction: Vector3) {
        
        print("Displacement Vector: \(displacementVector)")
        
        let newVector = displacementVector + direction
        print("New Vector: \(newVector)")
        
        let normalizedVector = newVector.normalize()
        print("Normalized Vector: \(normalizedVector)")
        
        displacementVector = normalizedVector
        
    }
    
    mutating func stop(_ vector: String) {
        switch vector {
        case "x":
            displacementVector.v0 = 0.0
        case "y":
            displacementVector.v1 = 0.0
        case "z":
            displacementVector.v2 = 0.0
        default:
            break
        }
    }
    
}
