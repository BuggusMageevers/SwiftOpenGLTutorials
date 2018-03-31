//
//  GraphicObjects.swift
//  UserInteraction
//
//  Created by Myles Schultz on 3/8/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation


struct Camera: ShaderInput {
    var name: String
    var shaderInputLocation: Int32 = 0
    var aspectRatio: CGFloat
    var projection = FloatMatrix4()
    
    init(named name: String, in rect: CGRect) {
        self.name = name
        self.aspectRatio = rect.width / rect.height
    }
    
    mutating func attach(toShader shader: Shader) {
        
    }
}

struct Model {
    
}

typealias SceneName = String
struct Scene {
    var name: String = ""
    var pointOfView: ObjectName = ""
    var lights = Layout()
    var models = Layout()
    var cameras = Layout()
    
    func draw(with renderer: Renderer) {
        
    }
}

typealias ObjectName = String
typealias DeltaTime = Float
typealias Layout = [ObjectName : ObjectPositionData]
final class ObjectGraph {
    static var layouts: [String : Layout] = [:]
    
    static func layout(for frameRequest: FrameRequest) -> Layout? {
        if let layout = layouts[frameRequest.scene] {
            return recalculated(layout, at: frameRequest.timeStamp)
        } else { return nil }
    }
    static func recalculated(_ layout: Layout, at time: Float) -> Layout {
        
    }
}
typealias ForceName = String
struct Force {
    let direction: Float3
    let speed: Float
}
struct ObjectPositionData {
    let position: Float3
    let transformedPosition: FloatMatrix4
    let forces: [ForceName : Force]
    
    func applyForces(at time: DeltaTime) -> ObjectPositionData {
        var newPosition = position
        for (_, force) in self.forces {
            newPosition.move(force.direction, over: time, at: force.speed)
        }
        
        return ObjectPositionData(position: newPosition, transformedPosition: newPosition.formTranlation(), forces: forces)
    }
}
