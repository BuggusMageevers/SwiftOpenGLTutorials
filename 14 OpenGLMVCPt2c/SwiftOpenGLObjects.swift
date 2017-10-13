//
//  SwiftOpenGLObjects.swift
//  OpenGLMVCPt2c
//
//  Created by Myles Schultz on 10/12/17.
//  Copyright © 2017 MyKo. All rights reserved.
//

import Foundation
import Quartz
import OpenGL.GL3


protocol SwiftOpenGLObject {
    var id: GLuint { get set }
    
    init()
    mutating func create()
    mutating func delete()
    
    func bind()
    func unbind()
    
}
protocol Drawable {
    func draw()
}
extension Drawable {
    func draw() {
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
    }
}

struct SwiftTexture: SwiftOpenGLObject {
    var id: GLuint = 0
    init() {}
    
    internal mutating func create() {
        glGenTextures(1, &id)
        bind()
    }
    mutating func create(from image: String) {
        create()
        
        guard let textureData = NSImage(named: NSImage.Name(rawValue: image))?.tiffRepresentation else {
            Swift.print("Image name not located in Image Asset Catalog")
            return
        }
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
        
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (textureData as NSData).bytes)
    }
    mutating func delete() {
        glDeleteTextures(1, &id)
    }
    
    func bind() {
        glBindTexture(GLenum(GL_TEXTURE_2D), id)
    }
    func unbind() {
        
    }
}
struct SwiftModel: SwiftOpenGLObject, Drawable {
    var id: GLuint = 0
    fileprivate var data: [GLfloat] = [
//format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        -1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
         0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
         1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001
    ]
    init() {}
    
    mutating func create() {
        glGenBuffers(1, &id)
        bind()
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<GLfloat>.size, data, GLenum(GL_STATIC_DRAW))
    }
    mutating func delete() {
        glDeleteBuffers(1, &id)
    }

    func bind() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), id)
    }
    func unbind() {
        
    }
}

struct SwiftModelGroup: SwiftOpenGLObject {
    var id: GLuint = 0
    
    init() {}
    
    mutating func create() {
        glGenVertexArrays(1, &id)
        bind()
        
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 8))
        glEnableVertexAttribArray(1)
        
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 20))
        glEnableVertexAttribArray(2)
        
        glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28))
        glEnableVertexAttribArray(3)
        
        unbind()
    }
    mutating func delete() {
        glDeleteVertexArrays(1, &id)
    }
    
    func bind() {
        glBindVertexArray(id)
    }
    func unbind() {
        glBindVertexArray(0)
    }
}

struct SwiftShader: SwiftOpenGLObject {
    var id: GLuint = 0
    init() {}
    
    private var vs = """
            #version 330 core                                                 \n
            layout (location = 0) in vec2 position;                           \n
            layout (location = 1) in vec3 color;                              \n
            layout (location = 2) in vec2 texturePosition;                    \n
            layout (location = 3) in vec3 normal;                             \n
            out vec3 passPosition;                                            \n
            out vec3 passColor;                                               \n
            out vec2 passTexturePosition;                                     \n
            out vec3 passNormal;                                              \n
            uniform mat4 view;                                                \n
            uniform mat4 projection;                                          \n
            void main()                                                       \n
            {                                                                 \n
                gl_Position = projection * view * vec4(position, 0.0, 1.0);   \n
                passPosition = vec3(position, 0.0);                           \n
                passColor = color;                                            \n
                passTexturePosition = texturePosition;                        \n
                passNormal = normal;                                          \n
            }                                                                 \n
        """
    private var fs = """
            #version 330 core                                                                                    \n
            uniform sampler2D sample;                                                                                 \n
            uniform struct Light {                                                                                    \n
               vec3 color;                                                                                            \n
               vec3 position;                                                                                         \n
               float ambient;                                                                                         \n
               float specStrength;                                                                                    \n
               float specHardness;                                                                                    \n
            } light;                                                                                                  \n
            in vec3 passPosition;                                                                                     \n
            in vec3 passColor;                                                                                        \n
            in vec2 passTexturePosition;                                                                              \n
            in vec3 passNormal;                                                                                       \n
            out vec4 outColor;                                                                                        \n
            void main()                                                                                               \n
            {                                                                                                         \n
                vec3 normal = normalize(passNormal);                                                                  \n
                vec3 lightRay = normalize(light.position - passPosition);                                             \n
                float intensity = dot(normal, lightRay);                                                              \n
                intensity = clamp(intensity, 0, 1);                                                                   \n
                vec3 viewer = normalize(vec3(0.0, 0.0, 0.2) - passPosition);                                          \n
                vec3 reflection = reflect(lightRay, normal);                                                          \n
                float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                          \n
                vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;   \n
                vec3 surface = texture(sample, passTexturePosition).rgb * passColor;                                  \n
                vec3 rgb = surface * light;                                                                           \n
                outColor = vec4(rgb, 1.0);                                                                            \n
            }                                                                                                         \n
        """
    
    internal mutating func create() {
        id = glCreateProgram()
        
        let vertexPiece = create(GL_VERTEX_SHADER, from: vs)
        let fragmentPiece = create(GL_FRAGMENT_SHADER, from: fs)
        
        glAttachShader(id, vertexPiece)
        glAttachShader(id, fragmentPiece)
        
        link()
        
        glDeleteShader(vertexPiece)
        glDeleteShader(fragmentPiece)
    }
    typealias ShaderPieceType = Int32
    func create(_ shaderPiece: ShaderPieceType, from source: String) -> GLuint {
        let shaderPiece = glCreateShader(GLenum(shaderPiece))
        
        let sourceCodeString = source.cString(using: String.Encoding.ascii)
        var sourceCodePointer = UnsafePointer<GLchar>(sourceCodeString)
        glShaderSource(shaderPiece, 1, &sourceCodePointer, nil)
        glCompileShader(shaderPiece)
        var compiled: GLint = 0
        glGetShaderiv(shaderPiece, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            print("Could not compile vertex, getting log")
            var logLength: GLint = 0
            glGetShaderiv(shaderPiece, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(shaderPiece, GLsizei(logLength), &logLength, cLog)
                print(" log = \n\t\(String(cString: cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
            }
        }
        
        return shaderPiece
    }
    func link() {
        glLinkProgram(id)
        var linked: GLint = 0
        glGetProgramiv(id, UInt32(GL_LINK_STATUS), &linked)
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glGetProgramiv(id, UInt32(GL_INFO_LOG_LENGTH), &logLength)
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetProgramInfoLog(id, GLsizei(logLength), &logLength, cLog)
                print(" log: \n\t\(String.init(cString:cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
            }
        }
    }
    
    mutating func delete() {
        glDeleteProgram(id)
    }
    
    func bind() {
        glUseProgram(id)
    }
    
    func unbind() {
        glUseProgram(0)
    }
    
    func setUniforms() {
        let sampleLocation = glGetUniformLocation(id, "sample")
        glUniform1i(sampleLocation, GL_TEXTURE0)
        
        bind()
        
        glUniform3fv(glGetUniformLocation(id, "light.color"), 1, [1.0, 1.0, 1.0])
        glUniform3fv(glGetUniformLocation(id, "light.position"), 1, [0.0, 1.0, 0.5])
        glUniform1f(glGetUniformLocation(id, "light.ambient"), 0.25)
        glUniform1f(glGetUniformLocation(id, "light.specStrength"), 3.0)
        glUniform1f(glGetUniformLocation(id, "light.specHardness"), 32)
    }
    func updateAnimatedUniforms(with parameters: (Float, [Matrix4])) {
        let value = parameters.0
        let view = parameters.1[0]
        let projection = parameters.1[1]
        glUniform3fv(glGetUniformLocation(id, "light.position"), 1, [value, 1.0, 0.5])
        
        glUniformMatrix4fv(glGetUniformLocation(id, "view"), 1, GLboolean(GL_FALSE), view.asArray())
        glUniformMatrix4fv(glGetUniformLocation(id, "projection"), 1, GLboolean(GL_FALSE), projection.asArray())
    }
}
