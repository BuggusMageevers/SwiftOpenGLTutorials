//
//  UserInteraction.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/23/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


typealias InstructionList = [UserInput : Instruction]
final class UserInteraction {
    private static var editInstructions: InstructionList = [:]
    
    private init() {}
    
    public static func instructionList(for mode: InstructionMode) -> (UserInput) -> Instruction? {
        switch mode {
        case .edit:
            return {(input: UserInput) -> Instruction? in
                return editInstructions[input]
            }
        }
    }
}

enum UserInput: Hashable {
    case keyboard(Key)
    
    var hashValue: Int {
        switch self {
        case .keyboard(let key):
            return (0 &+ key.hashValue) &* 65_567
        }
    }
    
    static func ==(lhs: UserInput, rhs: UserInput) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    enum Key: UInt16 {
        case a = 0
        case s = 1
        case d = 2
        case w = 13
    }
}
enum Instruction {
    case move(Float3)
}
struct InstructionSet {
    let target: String
    let instruction: Instruction
}
enum InstructionMode {
    case edit
}
protocol Respondable {
    var instructions: [ UserInput : InstructionSet ] { get set }
    
    mutating func respond(to input: UserInput, at time: Double)
}
protocol Asset {
    var name: String { get set }
    
    init(named name: String)
}
protocol Moveable {
    var position: Float3 { get set }
}

