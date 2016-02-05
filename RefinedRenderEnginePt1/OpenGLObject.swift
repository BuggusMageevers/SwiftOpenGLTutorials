//
//  OpenGLObject.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 2/3/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import OpenGL.GL3


protocol OpenGLObject {
    
    var objectID: GLuint { get set }
    
    func bind()
    func unbind()
    mutating func destroy()
    
}

protocol OpenGLUniformObject {
    
    func commitTo(shader: SwiftShader)
    
}
