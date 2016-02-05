//
//  SwiftShader.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//


import Foundation
import OpenGL.GL3


struct SwiftShader: OpenGLObject {
    
    var objectID: GLuint = 0
    
    init() {
        
        objectID = glCreateProgram()
        
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                                        \n" +
            "layout (location = 0) in vec2 position;                           \n" +
            "layout (location = 1) in vec3 color;                              \n" +
            "layout (location = 2) in vec2 texturePosition;                    \n" +
            "layout (location = 3) in vec3 normal;                             \n" +
            "out vec3 passPosition;                                            \n" +
            "out vec3 passColor;                                               \n" +
            "out vec2 passTexturePosition;                                     \n" +
            "out vec3 passNormal;                                              \n" +
            "uniform mat4 view;                                                \n" +
            "uniform mat4 projection;                                          \n" +
            "void main()                                                       \n" +
            "{                                                                 \n" +
            "    gl_Position = projection * view * vec4(position, 0.0, 1.0);   \n" +
            "    passPosition = vec3(position, 0.0);                           \n" +
            "    passColor = color;                                            \n" +
            "    passTexturePosition = texturePosition;                        \n" +
            "    passNormal = normal;                                          \n" +
            "}                                                                 \n"
        if let vss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            var vssptr = UnsafePointer<GLchar>(vss)
            glShaderSource(vs, 1, &vssptr, nil)
            glCompileShader(vs)
            var compiled: GLint = 0
            glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled)
            if compiled <= 0 {
                Swift.print("Could not compile vertex, getting log")
                var logLength: GLint = 0
                glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength)
                Swift.print(" logLength = \(logLength)")
                if logLength > 0 {
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("log = \(log)")
                        free(cLog)
                    }
                }
            }
        }
        
        
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                                                                                    \n" +
            "uniform sampler2D sample;                                                                                 \n" +
            "uniform struct Light {                                                                                    \n" +
            "   vec3 color;                                                                                            \n" +
            "   vec3 position;                                                                                         \n" +
            "   float ambient;                                                                                         \n" +
            "   float specStrength;                                                                                    \n" +
            "   float specHardness;                                                                                    \n" +
            "} light;                                                                                                  \n" +
            "in vec3 passPosition;                                                                                     \n" +
            "in vec3 passColor;                                                                                        \n" +
            "in vec2 passTexturePosition;                                                                              \n" +
            "in vec3 passNormal;                                                                                       \n" +
            "out vec4 outColor;                                                                                        \n" +
            "void main()                                                                                               \n" +
            "{                                                                                                         \n" +
            "    vec3 normal = normalize(passNormal);                                                                  \n" +
            "    vec3 lightRay = normalize(light.position - passPosition);                                             \n" +
            "    float intensity = dot(normal, lightRay);                                                              \n" +
            "    intensity = clamp(intensity, 0, 1);                                                                   \n" +
            "    vec3 viewer = normalize(vec3(0.0, 0.0, 0.2) - passPosition);                                          \n" +
            "    vec3 reflection = reflect(lightRay, normal);                                                          \n" +
            "    float specular = pow(max(dot(viewer, reflection), 0.0), light.specHardness);                          \n" +
            "    vec3 light = light.ambient + light.color * intensity + light.specStrength * specular * light.color;   \n" +
            "    vec3 surface = texture(sample, passTexturePosition).rgb * passColor;                                  \n" +
            "    vec3 rgb = surface * light;                                                                           \n" +
            "    outColor = vec4(rgb, 1.0);                                                                            \n" +
            "}                                                                                                         \n"
        if let fss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            var fssptr = UnsafePointer<GLchar>(fss)
            glShaderSource(fs, 1, &fssptr, nil)
            glCompileShader(fs)
            var compiled: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
            if compiled <= 0 {
                Swift.print("Could not compile fragement, getting log")
                var logLength: GLint = 0
                glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
                Swift.print(" logLength = \(logLength)")
                if logLength > 0 {
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("log = \(log)")
                        free(cLog)
                    }
                }
            }
        }
        
        glAttachShader(objectID, vs)
        glAttachShader(objectID, fs)
        glLinkProgram(objectID)
        var linked: GLint = 0
        glGetProgramiv(objectID, UInt32(GL_LINK_STATUS), &linked)
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glGetProgramiv(objectID, UInt32(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                glGetProgramInfoLog(objectID, GLsizei(logLength), &logLength, cLog)
                if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                    Swift.print("log: \(log)")
                }
                free(cLog)
            }
        }
        
        glDeleteShader(vs)
        glDeleteShader(fs)
        
    }
    
    func bind() { glUseProgram(objectID) }
    
    func unbind() { glUseProgram(0) }
    
    mutating func destroy() { glDeleteProgram(objectID) }
    
}
