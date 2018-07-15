//
//  OpenGLObjects.swift
//  UserInteraction
//
//  Created by Myles Schultz on 1/28/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import Quartz


protocol OpenGLObject {
    var id: GLuint { get }
    
    func bind()
    func unbind()
    mutating func delete()
}
protocol ShaderInput {
    var shaderInputLocation: Int32 { get set }
}

struct Vertex {
    var position: Float3
    var normal: Float3
    var textureCoordinate: Float2
    var color: Float3
}
struct VertexBufferObject: OpenGLObject {
    let id: GLuint
    var vertexCount: Int32 {
        return Int32(data.count)
    }
    var data: [Vertex] = []
    
    init() {
        var tempID: GLuint = 0
        glGenBuffers(1, &tempID)
        self.id = tempID
    }
    mutating func load(_ data: [Vertex]) {
        self.data = data
        bind()
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<Vertex>.size, data, GLenum(GL_STATIC_DRAW))
    }
    
    func bind() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), id)
    }
    
    func unbind() {
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), id)
    }
    
    mutating func delete() {
        glDeleteBuffers(1, [id])
    }
}
struct VertexArrayObject: OpenGLObject {
    let id: GLuint
    
    init() {
        var tempID: GLuint = 0
        glGenVertexArrays(1, &tempID)
        self.id = tempID
    }
    
    mutating func layoutVertexPattern() {
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
        glDeleteVertexArrays(1, [id])
    }
}
enum TextureSlot: GLint {
    case texture0 = 33984   /* GL_TEXTURE0 */
}
struct TextureBufferObject: OpenGLObject {
    let id: GLuint
    var textureSlot: GLint = TextureSlot.texture0.rawValue
    
    init() {
        var tempID: GLuint = 0
        glGenTextures(1, &tempID)
        self.id = tempID
    }
    
    mutating func loadTexture(named name: String) {
        guard let textureData = NSImage(named: NSImage.Name(rawValue: name))?.tiffRepresentation else {
            print("Image name not located in Image Asset Catalog")
            return
        }
        
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
        glDeleteTextures(1, [id])
    }
}
enum ShaderType: GLenum {
    case vertex = 35633     /* GL_VERTEX_SHADER */
    case fragment = 35632   /* GL_FRAGMENT_SHADER */
}
struct Shader: OpenGLObject {
    let id: GLuint
    
    init() {
        self.id = glCreateProgram()
    }
    
    mutating func connect(vertexShaderSource vertexSource: String, andFragmentShaderSource fragmentSource: String) {
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
    
    func setInitialUniforms(for scene: inout Scene) {
//        let location = glCall(glGetUniformLocation(id, "sample"))
//        glCall(glUniform1i(location, scene.tbo.textureSlot))
//
//        bind()
//
//        scene.light.attach(toShader: self)
//        scene.light.updateParameters(for: self)
//
//        scene.camera.attach(toShader: self)
//        scene.camera.updateParameters(for: self)
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

struct Light {
    private enum Parameter: String {
        case color = "light.color"
        case position = "light.position"
        case ambientStrength = "light.ambient"
        case specularStrength = "light.specStrength"
        case specularHardness = "light.specHardness"
    }
    
    var name: String = ""
    var color: [GLfloat] = [1.0, 1.0, 1.0] {
        didSet {
            parametersToUpdate.append(.color)
        }
    }
    var offset = Float3() // FIXME: Unused
    var position: [GLfloat] = [0.0, 1.0, 0.5] {
        didSet {
            parametersToUpdate.append(.position)
        }
    }
    var ambietStrength: GLfloat = 0.25 {
        didSet {
            parametersToUpdate.append(.ambientStrength)
        }
    }
    var specularStrength: GLfloat = 3.0 {
        didSet {
            parametersToUpdate.append(.specularStrength)
        }
    }
    var specularHardness: GLfloat = 32 {
        didSet {
            parametersToUpdate.append(.specularHardness)
        }
    }
    private var shaderParameterLocations = [GLuint : [Parameter : Int32]]()
    private var parametersToUpdate: [Parameter] = [.color, .position, .ambientStrength, .specularStrength, .specularHardness]
    
    private init() {}
    init(named name: String) {
        self.name = name
    }
    
    mutating func attach(toShader shader: Shader) {
        let shader = shader.id
        var parameterLocations = [Parameter : Int32]()
        
        parameterLocations[.color] = glGetUniformLocation(shader, Parameter.color.rawValue)
        parameterLocations[.position] = glGetUniformLocation(shader, Parameter.position.rawValue)
        parameterLocations[.ambientStrength] = glGetUniformLocation(shader, Parameter.ambientStrength.rawValue)
        parameterLocations[.specularStrength] = glGetUniformLocation(shader, Parameter.specularStrength.rawValue)
        parameterLocations[.specularHardness] = glGetUniformLocation(shader, Parameter.specularHardness.rawValue)
        
        shaderParameterLocations[shader] = parameterLocations
    }
    mutating func updateParameters(for shader: Shader) {
        if let parameterLocations = shaderParameterLocations[shader.id] {
            for parameter in parametersToUpdate {
                switch parameter {
                case .color:
                    if let location = parameterLocations[parameter] {
                        glUniform3fv(location, 1, color)
                    }
                case .position:
                    if let location = parameterLocations[parameter] {
                        glUniform3fv(location, 1, position)
                    }
                case .ambientStrength:
                    if let location = parameterLocations[parameter] {
                        glUniform1f(location, ambietStrength)
                    }
                case .specularStrength:
                    if let location = parameterLocations[parameter] {
                        glUniform1f(location, specularStrength)
                    }
                case .specularHardness:
                    if let location = parameterLocations[parameter] {
                        glUniform1f(location, specularHardness)
                    }
                }
            }
            parametersToUpdate.removeAll()
        }
    }
}
