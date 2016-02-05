//
//  SwiftTBO.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//

import Foundation
import OpenGL.GL3
import Quartz


struct SwiftTBO: OpenGLObject {
    
    var objectID: GLuint = 0
    
    init(fileName: String) {
        
        /*  Since we're starting a new target, not just a duplicate, we'll adjust the OpenGL
        texture to take input from the image assests catalog.  We can access these images
        by name as NSImage representations.  The raw data can then be passed by getting
        the TIFF representation and then the a pointer to that data.    */
        guard let textureData = NSImage(named: fileName)?.TIFFRepresentation else {
            Swift.print("Image name not located in Image Asset Catalog")
            return
        }
        
        let textureBuffer = UnsafeMutablePointer<Void>.alloc(textureData.length)
        textureData.getBytes(textureBuffer, length: textureData.length)
        
        glGenTextures(1, &objectID)
        bind()
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureBuffer)
        
        free(textureBuffer)

    }
    
    func bind() { glBindTexture(GLenum(GL_TEXTURE_2D), objectID) }
    
    func unbind() { glBindTexture(GLenum(GL_TEXTURE_2D), 0) }
    
    mutating func destroy() { glDeleteTextures(1, &objectID) }
    
}

extension SwiftTBO: OpenGLUniformObject {
    
    func commitTo(shader: SwiftShader) { glUniform1i(glGetUniformLocation(shader.objectID, "sample"), GL_TEXTURE0) }
    
}
