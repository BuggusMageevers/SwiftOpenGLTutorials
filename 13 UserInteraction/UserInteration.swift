//
//  UserInteraction.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/23/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


enum UserInput: Hashable, Equatable {
    case key(Keyboard)
    
    enum Keyboard: UInt16 {
        case a = 0
        case s = 1
        case d = 2
        case w = 13
    }
    
    var hashValue: Int {
        switch self {
        case .key(let key):
            return key.hashValue &* 65_537
        }
    }
    static func ==(lhs: UserInput, rhs: UserInput) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    static func !=(lhs: UserInput, rhs: UserInput) -> Bool {
        return lhs.hashValue != rhs.hashValue
    }
}
enum Instruction {
    case move(Float3)
}
struct InstructionSet {
    let target: String
    let instruction: Instruction
}
protocol Respondable {
    var instructions: [ UserInput : InstructionSet ] { get set }
    
    mutating func respond(to input: UserInput, at time: Double)
}
protocol Asset {
    var name: String { get set }
}
protocol Moveable {
    var position: Float3 { get set }
}

