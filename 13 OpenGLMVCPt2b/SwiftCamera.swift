//
//  SwiftCamera.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 11/6/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation

//  Eventually, we'll implement an object graph that manages all of the positions of the available objects.  It will calculate their displacements, orientations, and animations.
struct SwiftCamera {
    //  var instructions: [Instruction]
    
    func plan(_ instruction: Instruction) {
        print("Instruction \"\(instruction)\" sent to camera")
    }
    func executeInstructions(for time: Double) {
        
    }
}
