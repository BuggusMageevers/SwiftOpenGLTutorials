//
//  SwiftOpenGLObjects.swift
//  OpenGLMVCPt1
//
//  Created by Myles Schultz on 1/27/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import Quartz


protocol OpenGLObject {
    var id: GLuint { get set }
    
    func bind()
    func unbind()
    mutating func delete()
}

struct Vertex {
    var position: Float3
    var normal: Float3
    var textureCoordinate: Float2
    var color: Float3
}
struct VertexBufferObject: OpenGLObject {
    var id: GLuint = 0
    let type: GLenum = GLenum(GL_ARRAY_BUFFER)
    var vertexCount: Int32 {
        return Int32(data.count)
    }
    var data: [Vertex] = []
    
    mutating func load(_ data: [Vertex]) {
        self.data = data
        
        glGenBuffers(1, &id)
        bind()
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<Vertex>.size, data, GLenum(GL_STATIC_DRAW))
    }
    
    func bind() {
        glBindBuffer(type, id)
    }
    
    func unbind() {
        glBindBuffer(type, id)
    }
    
    mutating func delete() {
        glDeleteBuffers(1, &id)
    }
}
struct VertexArrayObject: OpenGLObject {
    var id: GLuint = 0
    
    mutating func layoutVertexPattern() {
        glGenVertexArrays(1, &id)
        bind()
        
        /* Position */
        glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        
        /* Normal */
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 12))
        glEnableVertexAttribArray(1)
        
        /* Texture Coordinate */
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 24))
        glEnableVertexAttribArray(2)
        
        /* Color */
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern:32))
        glEnableVertexAttribArray(3)
    }
    
    func bind() {
        glBindVertexArray(id)
    }
    func unbind() {
        glBindVertexArray(id)
    }
    
    mutating func delete() {
        glDeleteVertexArrays(1, &id)
    }
}
enum TextureSlot: GLint {
    case texture1 = 33984
}
struct TextureBufferObject: OpenGLObject {
    var id: GLuint = 0
    var textureSlot: GLint = TextureSlot.texture1.rawValue
    
    mutating func loadTexture(named name: String) {
        guard let textureData = NSImage(named: NSImage.Name(rawValue: name))?.tiffRepresentation else {
            Swift.print("Image name not located in Image Asset Catalog")
            return
        }
        
        glGenTextures(1, &id)
        bind()
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (textureData as NSData).bytes)
    }
    
    func bind() {
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
    }
    func unbind() {
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
    }
    
    mutating func delete() {
        glDeleteTextures(1, &id)
    }
}
enum ShaderType: UInt32 {
    case vertex = 35633     /* GL_VERTEX_SHADER */
    case fragment = 35632   /* GL_FRAGMENT_SHADER */
}
struct Shader: OpenGLObject {
    var id: GLuint = 0
    
    mutating func create(withVertex vertexSource: String, andFragment fragmentSource: String) {
        id = glCreateProgram()
        
        let vertex = compile(shaderType: .vertex, withSource: vertexSource)
        let fragment = compile(shaderType: .fragment, withSource: fragmentSource)
        
        link(vertexShader: vertex, fragmentShader: fragment)
    }
    
    func compile(shaderType type: ShaderType, withSource source: String) -> GLuint {
        let shader = glCreateShader(type.rawValue)
        var pointerToShader = UnsafePointer<GLchar>(source.cString(using: String.Encoding.ascii))
        glShaderSource(shader, 1, &pointerToShader, nil)
        glCompileShader(shader)
        var compiled: GLint = 0
        glGetShaderiv(shader, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            print("Could not compile shader type: \(type), getting log...")
            var logLength: GLint = 0
            print("Log length: \(logLength)")
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(shader, GLsizei(logLength), &logLength, cLog)
                print("\n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        return shader
    }
    
    func link(vertexShader vertex: GLuint, fragmentShader fragment: GLuint) {
        glAttachShader(id, vertex)
        glAttachShader(id, fragment)
        glLinkProgram(id)
        var linked: GLint = 0
        glGetProgramiv(id, UInt32(GL_LINK_STATUS), &linked)
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glGetProgramiv(id, UInt32(GL_INFO_LOG_LENGTH), &logLength)
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetProgramInfoLog(id, GLsizei(logLength), &logLength, cLog)
                print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        
        glDeleteShader(vertex)
        glDeleteShader(fragment)
    }
    
    func setInitialUniforms() {
        let location = glGetUniformLocation(id, "sample")
        glUniform1i(location, GLint(GL_TEXTURE0))
        
        bind()
        glUniform3fv(glGetUniformLocation(id, "light.color"), 1, [1.0, 1.0, 1.0])
        glUniform3fv(glGetUniformLocation(id, "light.position"), 1, [0.0, 2.0, 2.0])
        glUniform1f(glGetUniformLocation(id, "light.ambient"), 0.25)
        glUniform1f(glGetUniformLocation(id, "light.specStrength"), 3.0)
        glUniform1f(glGetUniformLocation(id, "light.specHardness"), 32)
    }
    func update(view: FloatMatrix4, projection: FloatMatrix4) {
        glUniformMatrix4fv(glGetUniformLocation(id, "view"), 1, GLboolean(GL_FALSE), view.columnMajorArray())
        glUniformMatrix4fv(glGetUniformLocation(id, "projection"), 1, GLboolean(GL_FALSE), projection.columnMajorArray())
    }
    
    func bind() {
        glUseProgram(id)
    }
    func unbind() {
        glUseProgram(0)
    }
    
    func delete() {
        glDeleteProgram(id)
    }
}
