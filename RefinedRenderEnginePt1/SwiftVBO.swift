//
//  SwiftVBO.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import OpenGL.GL3


struct SwiftVBO: OpenGLObject {
    
    var objectID: GLuint = 0
    
    init(data: [GLfloat]) {
        
        glGenBuffers(1, &objectID)
        bind()
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * sizeof(GLfloat), data, GLenum(GL_STATIC_DRAW))
        
    }
    
    func bind() { glBindBuffer(GLenum(GL_ARRAY_BUFFER), objectID) }
    
    func unbind() { glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0) }
    
    mutating func destroy() { glDeleteBuffers(1, &objectID) }
    
}
