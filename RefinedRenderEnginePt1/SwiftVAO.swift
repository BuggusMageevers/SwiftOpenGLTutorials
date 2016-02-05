//
//  SwiftVAO.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation
import OpenGL.GL3


struct SwiftVAO: OpenGLObject {
    
    var objectID: GLuint = 0
    
    init() {
        
        glGenVertexArrays(1, &objectID)
        glBindVertexArray(objectID)
        
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 8))
        glEnableVertexAttribArray(1)
        
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 20))
        glEnableVertexAttribArray(2)
        
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28))
        glEnableVertexAttribArray(3)
        
        glBindVertexArray(0)
        
    }
    
    func bind() { glBindVertexArray(objectID) }
    
    func unbind() { glBindVertexArray(0) }
    
    mutating func destroy() { glDeleteVertexArrays(1, &objectID) }
    
}
