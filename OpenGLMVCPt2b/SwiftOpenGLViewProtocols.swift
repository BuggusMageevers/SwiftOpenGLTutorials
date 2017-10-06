//
//  SwiftOpenGLViewProtocols.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 2/12/17.
//  Copyright © 2017 MyKo. All rights reserved.
//
//  Ver 2:  Protocols to drive redraws of an OpenGLView, provide
//      view management, and eventually, a data source.
//

import Cocoa

/**
 A delegate to be used in driving redraws to a view that draws OpenGL
 content. The protocol ensures the driver is initialized, and has controls
 to start and stop the driver.  Additionally, properties for time
 calculations are required.
 */
protocol RenderLoopDelegate {
    
    //  MARK: DisplayLink
    /**
     A referrence to a `CVDisplayLink`.
     */
    var link: CVDisplayLink? { get set }
    var callback: CVDisplayLinkOutputCallback { get }
    /**
     A property to indicate if the callback is being called with each
     refresh of the screen.
     */
    var running: Bool { get set }
    
    /**
     To be used for the creation of a `CVDisplayLink` and the setting
     of the callback function.
     */
    func setupLink()
    
    /**
     Starts the `CVDisplayLink` which will cyclicly call the callback
     function.
     */
    func startDrawing()
    /**
     Stops the `CVDisplayLink`.  Should be called anytime the view is not
     being seen by the user so as to save resources.
     */
    func stopDrawing()
    
    //  MARK: Time, Time Calculations
    /**
     The current elapsed time from the start of the application.
     */
    var currentTime: Double { get set }
    /**
     Idealy set everytime currentTime is set.  Use didSet on currentTime
     to acheive this update.  This is the amount of time between the
     previous frame and the current frame.
     */
    var deltaTime: Double { get }
    
}

/**
 The RenderDelegate is used by an instance of SwiftOpenGLView to
 outsource the drawing methods.  This allows a controller to take
 over non-view-related code.
 */
protocol RenderDelegate {
    
    func prepareToDraw(frame atTime: Double)
    
}


// MARK: - User Interaction


/**
 An `Instructable` takes instruction from a respondable. Each instructable
 must have a definition for each accepted instruction. For example, a
 camera object may accept the instruction move.forward and defines a move
 method to move the camera position foward.
 */
protocol Instructable {
    func register(_ name: String)
    func perform(_ instruction: Instruction)
}
extension Instructable {
    func register(_ name: String) {
        instructables[name] = self
    }
}

/**
 A `Respondable` receives an event and notifies an `Instructable` to
 perform a predesignated action according to input provided by the user. A
 view controller is an example of a respondable: accepts user input and has
 a number of objects that accept instruction. User interaction may initiate
 a global change
 */
protocol Respondable {
    associatedtype activeObject
    func respondTo(_ input: UserInput)
}
extension Respondable {
    func respondTo(_ input: UserInput) {
        
    }
}

struct UserInput {
    private enum InputType {
        case keyboard(KeyboardKeyMap)
        case mouse
        case tablet
    }
    
    private var input: InputType
    
    static func from(_ event: NSEvent) -> UserInput {
        return UserInput(input: InputType.keyboard(KeyboardKeyMap.a))
    }
}
enum KeyboardKeyMap: UInt16 {
    case a = 0
    case s = 1
    case d = 2
    case w = 13
}
extension KeyboardKeyMap {
    var hashValue: Int {
        switch self {
        default:
            return self.hashValue
        }
    }
    
    static func ==(lhs: KeyboardKeyMap, rhs: KeyboardKeyMap) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: KeyboardKeyMap, rhs: KeyboardKeyMap) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
}

protocol Instruction{}
enum Move: Instruction {
    case forward
    case backward
    case left
    case right
    case up
    case down
}
enum Orient: Instruction {
    case pitchUp
    case pitchDown
    case yawLeft
    case yawRight
    case rollLeft
    case rollRight
}
struct InstructionSet {
    let instructable: String
    let instruction: Instruction
}

private var instructables = [ String : Instructable ]()
private var instructions: [ UserInput : InstructionSet ] = [
    KeyboardKeyMap.w : InstructionSet(instructable: "camera", instruction: Move.forward)
]
struct UserInteraction {
    
    static func performingInstruction(forKey key: UInt16) {
        print("Creating KeyboardKey enum from UInt16")
        if let keyboardKey = KeyboardKeyMap(rawValue: key) {
            print("Retreiving instruction for KeyboardKey")
            if let instruction = instructions[keyboardKey] {
                
            }
        }
    }
    
}
