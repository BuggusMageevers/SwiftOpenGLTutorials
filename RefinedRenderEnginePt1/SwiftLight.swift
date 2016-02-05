//
//  SwiftLight.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 2/1/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import OpenGL.GL3


struct SwiftLight: OpenGLUniformObject {
    
    private var position: [GLfloat] = [0.0, 1.0, 0.5]
    private var color: [GLfloat] = [1.0, 1.0, 1.0]
    private var ambient: GLfloat = 0.25
    private var specularStrength: GLfloat = 3.0
    private var specularHardness: GLfloat = 32
    
    mutating func position(x: GLfloat, y: GLfloat, z: GLfloat) -> SwiftLight {
        
        position = [x, y, z]
        
        return self
        
    }
    mutating func color(r: GLfloat, g: GLfloat, b: GLfloat) -> SwiftLight {
        
        color = [r, g, b]
        
        return self
        
    }
    mutating func ambient(ambient: GLfloat) -> SwiftLight {
        
        self.ambient = ambient
        
        return self
        
    }
    mutating func specularStrength(strength: GLfloat) -> SwiftLight {
        
        specularStrength = strength
        
        return self
        
    }
    mutating func specularHardness(hardness: GLfloat) -> SwiftLight {
        
        specularHardness = hardness
        
        return self
        
    }
    
    func commitTo(shader: SwiftShader) {
        
        commitPositionTo(shader)
        commitColorTo(shader)
        commitAmbientTo(shader)
        commitSpecularStrengthTo(shader)
        commitSpecularHardnessTo(shader)
        
    }
    
    func commitPositionTo(shader: SwiftShader) { glUniform3fv(glGetUniformLocation(shader.objectID, "light.position"), 1, position) }
    func commitColorTo(shader: SwiftShader) { glUniform3fv(glGetUniformLocation(shader.objectID, "light.color"), 1, color) }
    func commitAmbientTo(shader: SwiftShader) { glUniform1f(glGetUniformLocation(shader.objectID, "light.ambient"), ambient) }
    func commitSpecularStrengthTo(shader: SwiftShader) { glUniform1f(glGetUniformLocation(shader.objectID, "light.specStrength"), specularStrength) }
    func commitSpecularHardnessTo(shader: SwiftShader) { glUniform1f(glGetUniformLocation(shader.objectID, "light.specHardness"), specularHardness) }
    
}
