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
    mutating func delete()
    
    func bind()
    func unbind()
    
}

struct SwiftTexture: SwiftOpenGLObject, Asset {
    var name: String = "Texture"
    var id: GLuint = 0
    init() {
        print("Initializing texture...")
        glCall(glGenTextures(1, &id))
    }
    
    func load(_ image: String) {
        bind()
        guard let textureData = NSImage(named: NSImage.Name(rawValue: image))?.tiffRepresentation else {
            print("Image name not located in Image Asset Catalog")
            return
        }
        
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT))
        
        glCall(glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (textureData as NSData).bytes))
    }
    
    mutating func delete() {
        glCall(glDeleteTextures(1, &id))
    }
    
    func bind() {
        glCall(glBindTexture(GLenum(GL_TEXTURE_2D), id))
    }
    func unbind() {
        
    }
}

struct VBO: SwiftOpenGLObject, Drawable {
    var id: GLuint = 0
    fileprivate var data: [GLfloat] = [
//format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        -1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
         0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
         1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001
    ]
    init() {
        print("Initializing Model...")
        glCall(glGenBuffers(1, &id))
        bind()
    }
    
    func load() {
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<GLfloat>.size, data, GLenum(GL_STATIC_DRAW)))
    }

    func bind() {
        glCall(glBindBuffer(GLenum(GL_ARRAY_BUFFER), id))
    }
    func unbind() {
        glCall(glBindBuffer(0, 0))
    }
    
    mutating func delete() {
        glCall(glDeleteBuffers(1, &id))
    }
}

struct VAO: SwiftOpenGLObject {
    var id: GLuint = 0
    
    init() {
        print("Initializing Model Group ...")
        glCall(glGenVertexArrays(1, &id))
        bind()
    }
    
    func load() {
        glCall(glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(0))
        
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 8)))
        glCall(glEnableVertexAttribArray(1))
        
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern: 20)))
        glCall(glEnableVertexAttribArray(2))
        
        glCall(glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 40, UnsafePointer<GLuint>(bitPattern:28)))
        glCall(glEnableVertexAttribArray(3))
    }
    mutating func delete() {
        glCall(glDeleteVertexArrays(1, &id))
    }
    
    func bind() {
        glCall(glBindVertexArray(id))
    }
    func unbind() {
        glCall(glBindVertexArray(0))
    }
}

struct SwiftShader: SwiftOpenGLObject {
    var id: GLuint = 0
    init() {
        print("Initializing Shader...")
        id = glCall(glCreateProgram())
        create()
    }
    
    private var vertexShaderSourceCode = """
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
    private var fragmentShaderSourceCode = """
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
        let vertexPiece = create(GL_VERTEX_SHADER, from: vertexShaderSourceCode)
        let fragmentPiece = create(GL_FRAGMENT_SHADER, from: fragmentShaderSourceCode)

        glCall(glAttachShader(id, vertexPiece))
        glCall(glAttachShader(id, fragmentPiece))

        link()
        
        glCall(glDeleteShader(vertexPiece))
        glCall(glDeleteShader(fragmentPiece))
    
        glCall(glValidateProgram(id))
        var validated: GLint = 0
        glCall(glGetProgramiv(id, GLenum(GL_VALIDATE_STATUS), &validated))
        if validated == GL_FALSE {
            print("Program \(id) is invalid, getting log...")
            var logLength: GLint = 0
            glCall(glGetProgramiv(id, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(id, GLsizei(logLength), &logLength, cLog))
                print(" log: \n\t\(String.init(cString:cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
            }
        } else {
            print("Valid program: \(id)")
        }
        
        bind()
    }
    typealias ShaderPieceType = Int32
    func create(_ shaderPieceType: ShaderPieceType, from source: String) -> GLuint {
        let shaderPiece = glCall(glCreateShader(GLenum(shaderPieceType)))
        
        let sourceCodeString = source.cString(using: String.Encoding.ascii)
        var sourceCodePointer = UnsafePointer<GLchar>(sourceCodeString)
        glCall(glShaderSource(shaderPiece, 1, &sourceCodePointer, nil))
        glCall(glCompileShader(shaderPiece))
        var compiled: GLint = 0
        glCall(glGetShaderiv(shaderPiece, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile shader piece, getting log")
            var logLength: GLint = 0
            glCall(glGetShaderiv(shaderPiece, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(shaderPiece, GLsizei(logLength), &logLength, cLog))
                print(" log = \n\t\(String(cString: cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
            }
        }
        
        return shaderPiece
    }
    func link() {
        glCall(glLinkProgram(id))
        var linked: GLint = 0
        glCall(glGetProgramiv(id, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(id, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(id, GLsizei(logLength), &logLength, cLog))
                print(" log: \n\t\(String.init(cString:cLog))")
                cLog.deinitialize()
                cLog.deallocate(capacity: Int(logLength))
            }
        }
    }
    
    mutating func delete() {
        glCall(glDeleteProgram(id))
    }
    
    func bind() {
        glCall(glUseProgram(id))
    }
    func unbind() {
        glCall(glUseProgram(0))
    }
    
    func setUniforms() {
        let sampleLocation = glCall(glGetUniformLocation(id, "sample"))
        glCall(glUniform1i(sampleLocation, GL_TEXTURE0))
        
        bind()
        
        glCall(glUniform3fv(glGetUniformLocation(id, "light.color"), 1, [1.0, 1.0, 1.0]))
        glCall(glUniform3fv(glGetUniformLocation(id, "light.position"), 1, [0.0, 1.0, 0.5]))
        glCall(glUniform1f(glGetUniformLocation(id, "light.ambient"), 0.25))
        glCall(glUniform1f(glGetUniformLocation(id, "light.specStrength"), 3.0))
        glCall(glUniform1f(glGetUniformLocation(id, "light.specHardness"), 32))
    }
    func updateUniforms(lightData: Light, cameraData: Camera) {
        glCall(glUniform3fv(glGetUniformLocation(id, "light.position"), 1, [lightData.cyclicValue, 1.0, 0.5]))
        
        glCall(glUniformMatrix4fv(glGetUniformLocation(id, "view"), 1, GLboolean(GL_FALSE), cameraData.view.columnMajorArray()))
        glCall(glUniformMatrix4fv(glGetUniformLocation(id, "projection"), 1, GLboolean(GL_FALSE), cameraData.projection.columnMajorArray()))
    }
}
