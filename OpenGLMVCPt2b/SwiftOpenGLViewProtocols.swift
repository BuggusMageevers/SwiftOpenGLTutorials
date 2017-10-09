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
    func perform(_ instruction: Instruction)
}

/**
 A `Respondable` receives an event and notifies an `Instructable` to
 perform a predesignated action according to input provided by the user. A
 view controller is an example of a respondable: accepts user input and has
 a number of objects that accept instruction. User interaction may initiate
 a global change
 */
protocol Respondable {
    func respondTo(_ input: InputDevice, in mode: ViewControllerMode) -> Instruction?
}
extension Respondable {
    func respondTo(_ input: InputDevice, in mode: ViewControllerMode) -> Instruction? {
        // Is the instruction global?
        if let instructionMap = keyInstructionMaps[input] {
            if let instruction = instructionMap[input] {
                return instruction
            }
        }
        return nil
    }
}

enum ViewControllerMode {
    case move
    case edit
}
enum InputDevice: Hashable, Equatable {
    case keyboard(UserInput.Key)
    case mouse(UserInput.Action)
    
    var hashValue: Int {
        switch self {
        case .keyboard(let key):
            return key.rawValue.hashValue
        case .mouse(let action):
            return action.hashValue
        }
    }
    
    static func ==(lhs: InputDevice, rhs: InputDevice) -> Bool {
        switch lhs {
        case .keyboard(let leftKey):
            switch rhs {
            case .keyboard(let rightKey):
                return leftKey.rawValue == rightKey.rawValue
            case .mouse(_):
                return false
            }
        case .mouse(let leftAction):
            switch rhs {
            case .keyboard(_):
                return false
            case .mouse(let rightAction):
                return leftAction == rightAction
            }
        }
    }
    static func !=(lhs: InputDevice, rhs: InputDevice) -> Bool {
        switch lhs {
        case .keyboard(let leftKey):
            switch rhs {
            case .keyboard(let rightKey):
                return leftKey.rawValue != rightKey.rawValue
            case .mouse(_):
                return false
            }
        case .mouse(let leftAction):
            switch rhs {
            case .keyboard(_):
                return false
            case .mouse(let rightAction):
                return leftAction != rightAction
            }
        }
    }
}
enum UserInput {
    enum Key : UInt16 {
        case a = 0
        case s = 1
        case d = 2
        case w = 13
    }
    
    enum Action {
        case leftButton
        case rightButton
        case move
    }
}
enum Instruction {
    enum Camera {
        enum Move {
            case forward
            case backward
            case left
            case right
        }
        enum Orient {
            case pitchUp
            case pitchDown
            case yawLeft
            case yawRight
            case rollLeft
            case rollRight
        }
    }
    
}
fileprivate var keyInstructionMaps = [InputDevice : [InputDevice : Instruction]]()
fileprivate var globalInstructions = [InputDevice : Instruction]()
fileprivate var moveInstructions = [InputDevice : Instruction]()
fileprivate var editInstructions = [InputDevice : Instruction]()


