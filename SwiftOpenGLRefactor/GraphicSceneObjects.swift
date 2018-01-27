//
//  GraphicSceneObjects.swift
//  SwiftOpenGLRefactor
//
//  Created by Myles Schultz on 1/19/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import Quartz
import OpenGL.GL3


func glLogCall(file: String, line: Int) -> Bool {
    var error = GLenum(GL_NO_ERROR)
    
    repeat {
        error = glGetError()
        
        switch error {
        case  GLenum(GL_INVALID_ENUM):
            print("\(file), line: \(line), ERROR:  invalid Enum")
            return false
        case GLenum(GL_INVALID_VALUE):
            print("\(file), line: \(line), ERROR:  invalid value passed")
            return false
        case GLenum(GL_INVALID_OPERATION):
            print("\(file), line: \(line), ERROR:  invalid operation attempted")
            return false
        case GLenum(GL_INVALID_FRAMEBUFFER_OPERATION):
            print("\(file), line: \(line), ERROR:  invalid framebuffer operation attempted")
            return false
        case GLenum(GL_OUT_OF_MEMORY):
            print("\(file), line: \(line), ERROR:  out of memory")
            return false
        default:
            return true
        }
    } while error != GLenum(GL_NO_ERROR)
}
func glCall<T>(_ function: @autoclosure () -> T, file: String = #file, line: Int = #line) -> T {
    while glGetError() != GL_NO_ERROR {}
    
    let result = function()
    assert(glLogCall(file: file, line: line))
    
    return result
}

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
        
        glCall(glGenBuffers(1, &id))
        bind()
        glCall(glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<Vertex>.size, data, GLenum(GL_STATIC_DRAW)))
    }
    
    func bind() {
        glCall(glBindBuffer(type, id))
    }
    
    func unbind() {
        glCall(glBindBuffer(type, id))
    }
    
    mutating func delete() {
        glCall(glDeleteBuffers(1, &id))
    }
}
struct VertexArrayObject: OpenGLObject {
    var id: GLuint = 0
    
    mutating func layoutVertexPattern() {
        glCall(glGenVertexArrays(1, &id))
        bind()
        
        glCall(glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 0)))
        glCall(glEnableVertexAttribArray(0))
        
        glCall(glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 12)))
        glCall(glEnableVertexAttribArray(1))
        
        glCall(glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern: 24)))
        glCall(glEnableVertexAttribArray(2))
        
        glCall(glVertexAttribPointer(3, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 44, UnsafePointer<GLuint>(bitPattern:32)))
        glCall(glEnableVertexAttribArray(3))
    }
    
    func bind() {
        glCall(glBindVertexArray(id))
    }
    func unbind() {
        glCall(glBindVertexArray(id))
    }
    
    mutating func delete() {
        glCall(glDeleteVertexArrays(1, &id))
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
        
        glCall(glGenTextures(1, &id))
        bind()
        
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT))
        glCall(glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT))
        
        glCall(glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), (textureData as NSData).bytes))
    }
    
    func bind() {
        glCall(glBindTexture(GLenum(GL_TEXTURE_2D), id))
    }
    func unbind() {
        glCall(glBindTexture(GLenum(GL_TEXTURE_2D), 0))
    }
    
    mutating func delete() {
        glCall(glDeleteTextures(1, &id))
    }
}
enum ShaderType: UInt32 {
    case vertex = 35633     /* GL_VERTEX_SHADER */
    case fragment = 35632   /* GL_FRAGMENT_SHADER */
}
struct Shader: OpenGLObject {
    var id: GLuint = 0
    
    mutating func create(withVertex vertexSource: String, andFragment fragmentSource: String) {
        id = glCall(glCreateProgram())
        
        let vertex = compile(shaderType: .vertex, withSource: vertexSource)
        let fragment = compile(shaderType: .fragment, withSource: fragmentSource)
        
        link(vertexShader: vertex, fragmentShader: fragment)
    }
    
    func compile(shaderType type: ShaderType, withSource source: String) -> GLuint {
        let shader = glCall(glCreateShader(type.rawValue))
        var pointerToShader = UnsafePointer<GLchar>(source.cString(using: String.Encoding.ascii))
        glCall(glShaderSource(shader, 1, &pointerToShader, nil))
        glCall(glCompileShader(shader))
        var compiled: GLint = 0
        glCall(glGetShaderiv(shader, GLbitfield(GL_COMPILE_STATUS), &compiled))
        if compiled <= 0 {
            print("Could not compile shader type: \(type), getting log...")
            var logLength: GLint = 0
            print("Log length: \(logLength)")
            glCall(glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &logLength))
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetShaderInfoLog(shader, GLsizei(logLength), &logLength, cLog))
                Swift.print("\n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        return shader
    }
    
    func link(vertexShader vertex: GLuint, fragmentShader fragment: GLuint) {
        glCall(glAttachShader(id, vertex))
        glCall(glAttachShader(id, fragment))
        glCall(glLinkProgram(id))
        var linked: GLint = 0
        glCall(glGetProgramiv(id, UInt32(GL_LINK_STATUS), &linked))
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glCall(glGetProgramiv(id, UInt32(GL_INFO_LOG_LENGTH), &logLength))
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glCall(glGetProgramInfoLog(id, GLsizei(logLength), &logLength, cLog))
                Swift.print("log: \(String.init(cString:cLog))")
                free(cLog)
            }
        }
        
        glCall(glDeleteShader(vertex))
        glCall(glDeleteShader(fragment))
    }
    
    func setInitialUniforms(for scene: inout Scene) {
//        let location = glCall(glGetUniformLocation(id, "sample"))
//        glCall(glUniform1i(location, scene.tbo.textureSlot))
        
        bind()
        
        scene.light.attach(toShader: self)
        scene.light.updateParameters(for: self)
        
        scene.camera.attach(toShader: self)
        scene.camera.updateParameters(for: self)
    }
    
    func bind() {
        glCall(glUseProgram(id))
    }
    func unbind() {
        glCall(glUseProgram(0))
    }
    
    func delete() {
        glCall(glDeleteProgram(id))
    }
}

struct DisplayLink {
    let id: CVDisplayLink
    let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
//        print("fps:  \(Double(inNow.pointee.videoTimeScale) / Double(inNow.pointee.videoRefreshPeriod))")
        
        let view = unsafeBitCast(displayLinkContext, to: GraphicView.self)
        view.displayLink?.currentTime = Double(inNow.pointee.videoTime) / Double(inNow.pointee.videoTimeScale)
        view.drawView()
        
        return kCVReturnSuccess
    }
    var currentTime: Double = 0.0 {
        willSet {
            deltaTime = currentTime - newValue
        }
    }
    var deltaTime: Double = 0.0
    
    init?(forView view: GraphicView) {
        var newID: CVDisplayLink?
        
        if CVDisplayLinkCreateWithActiveCGDisplays(&newID) == kCVReturnSuccess {
            self.id = newID!
            CVDisplayLinkSetOutputCallback(id, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(view).toOpaque()))
        } else {
            return nil
        }
    }
    
    func start() {
        CVDisplayLinkStart(id)
    }
    func stop() {
        CVDisplayLinkStop(id)
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
    
    var color: [GLfloat] = [1.0, 1.0, 1.0] {
        didSet {
            parametersToUpdate.append(.color)
        }
    }
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
    
    mutating func attach(toShader shader: Shader) {
        let shader = shader.id
        var parameterLocations = [Parameter : Int32]()
        
        parameterLocations[.color] = glCall(glGetUniformLocation(shader, Parameter.color.rawValue))
        parameterLocations[.position] = glCall(glGetUniformLocation(shader, Parameter.position.rawValue))
        parameterLocations[.ambientStrength] = glCall(glGetUniformLocation(shader, Parameter.ambientStrength.rawValue))
        parameterLocations[.specularStrength] = glCall(glGetUniformLocation(shader, Parameter.specularStrength.rawValue))
        parameterLocations[.specularHardness] = glCall(glGetUniformLocation(shader, Parameter.specularHardness.rawValue))
        
        shaderParameterLocations[shader] = parameterLocations
    }
    mutating func updateParameters(for shader: Shader) {
        if let parameterLocations = shaderParameterLocations[shader.id] {
            for parameter in parametersToUpdate {
                switch parameter {
                case .color:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniform3fv(location, 1, color))
                    }
                case .position:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniform3fv(location, 1, position))
                    }
                case .ambientStrength:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniform1f(location, ambietStrength))
                    }
                case .specularStrength:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniform1f(location, specularStrength))
                    }
                case .specularHardness:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniform1f(location, specularHardness))
                    }
                }
            }
            parametersToUpdate.removeAll()
        }
    }
}
struct Camera: Asset {
    private enum Parameter: String {
        case position = "view"
        case projection = "projection"
    }
    
    var name: String = "Camera"
    var position = FloatMatrix4() {
        didSet {
            parametersToUpdate.insert(.position)
        }
    }
    var projection = FloatMatrix4() {
        didSet {
            parametersToUpdate.insert(.projection)
        }
    }
    
    private var shaderParameterLocations = [GLuint : [Parameter : Int32]]()
    private var parametersToUpdate: Set<Parameter> = [.position, .projection]
    
    mutating func attach(toShader shader: Shader) {
        let shader = shader.id
        var parameterLocations = [Parameter : Int32]()
        
        parameterLocations[.position] = glCall(glGetUniformLocation(shader, Parameter.position.rawValue))
        parameterLocations[.projection] = glCall(glGetUniformLocation(shader, Parameter.projection.rawValue))
        
        shaderParameterLocations[shader] = parameterLocations
    }
    mutating func updateParameters(for shader: Shader) {
        if let parameterLocations = shaderParameterLocations[shader.id] {
            for parameter in parametersToUpdate {
                switch parameter {
                case .position:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniformMatrix4fv(location, 1, GLboolean(GL_FALSE), position.columnMajorArray()))
                    }
                case .projection:
                    if let location = parameterLocations[parameter] {
                        glCall(glUniformMatrix4fv(location, 1, GLboolean(GL_FALSE), projection.columnMajorArray()))
                    }
                }
            }
            parametersToUpdate.removeAll()
        }
    }
}
struct Scene {
    var shader = Shader()
    var vao = VertexArrayObject()
    var vbo =  VertexBufferObject()
    var tbo = TextureBufferObject()
    var light = Light()
    var camera = Camera()
    
    let data: [Vertex] = [
        Vertex(position: Float3(x: -1.0, y: -1.0, z: 1.0),  /* Front face 1 */
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 1.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 0.0)),
        
        Vertex(position: Float3(x: 1.0, y: 1.0, z: 1.0),    /* Front face 2 */
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 1.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 0.0, z: 1.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 0.0, z: 0.0)),
        
        Vertex(position: Float3(x: 1.0, y: -1.0, z: 1.0),   /* Right face 1 */
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: -1.0),
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 0.0),
               color: Float3(x: 1.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: -1.0),
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 1.0)),
        
        Vertex(position: Float3(x: 1.0, y: 1.0, z: -1.0),   /* Right face 2 */
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: 1.0),
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: 1.0),
               normal: Float3(x: 1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 1.0)),
        
        Vertex(position: Float3(x: 1.0, y: -1.0, z: -1.0),  /* Back face 1 */
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 1.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 0.0, z: 1.0)),
        
        Vertex(position: Float3(x: -1.0, y: 1.0, z: -1.0),  /* Back face 2 */
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 0.0, z: -1.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 1.0, z: 0.0)),
        
        Vertex(position: Float3(x: -1.0, y: -1.0, z: -1.0), /* Left face 1 */
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: 1.0),
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 0.0),
               color: Float3(x: 1.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: 1.0),
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 1.0, z: 1.0)),
        
        Vertex(position: Float3(x: -1.0, y: 1.0, z: 1.0),   /* Left face 2 */
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: -1.0),
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 1.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: -1.0),
               normal: Float3(x: -1.0, y: 0.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 0.0)),
        
        Vertex(position: Float3(x: -1.0, y: -1.0, z: 1.0),  /* Bottom face 1 */
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: -1.0),
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 0.0),
               color: Float3(x: 0.0, y: 0.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: -1.0),
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 1.0, z: 0.0)),
        
        Vertex(position: Float3(x: 1.0, y: -1.0, z: -1.0),  /* Bottom face 2 */
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 1.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: -1.0, z: 1.0),
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 0.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: -1.0, z: 1.0),
               normal: Float3(x: 0.0, y: -1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 0.0, z: 0.0)),
        
        Vertex(position: Float3(x: -1.0, y: 1.0, z: 1.0),   /* Top face 1 */
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 0.0)),
        Vertex(position: Float3(x: 1.0, y: 1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 1.0)),
        
        Vertex(position: Float3(x: 1.0, y: 1.0, z: -1.0),   /* Top face 2 */
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 1.0, y: 1.0),
               color: Float3(x: 0.0, y: 1.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: -1.0),
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 1.0),
               color: Float3(x: 1.0, y: 0.0, z: 1.0)),
        Vertex(position: Float3(x: -1.0, y: 1.0, z: 1.0),
               normal: Float3(x: 0.0, y: 1.0, z: 0.0),
               textureCoordinate: Float2(x: 0.0, y: 0.0),
               color: Float3(x: 1.0, y: 1.0, z: 1.0))
        ]
    
    mutating func load(into view: GraphicView) {
        tbo.loadTexture(named: "Texture")
        
        vbo.load(data)
        
        vao.layoutVertexPattern()
        vao.unbind()
        
        camera.position = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0)
//        camera.projection = FloatMatrix4.orthographic(width: Float(view.bounds.size.width), height: Float(view.bounds.size.height))
        camera.projection = FloatMatrix4.projection(aspect: Float(view.bounds.size.width / view.bounds.size.height))
        
        let vertexSource = "#version 330 core                                  \n" +
            "layout (location = 0) in vec3 position;                           \n" +
            "layout (location = 1) in vec3 normal;                             \n" +
            "layout (location = 2) in vec2 texturePosition;                    \n" +
            "layout (location = 3) in vec3 color;                              \n" +
            "out vec3 passPosition;                                            \n" +
            "out vec3 passNormal;                                              \n" +
            "out vec2 passTexturePosition;                                     \n" +
            "out vec3 passColor;                                               \n" +
            "uniform mat4 view;                                                \n" +
            "uniform mat4 projection;                                          \n" +
            "void main()                                                       \n" +
            "{                                                                 \n" +
            "    gl_Position = projection * view * vec4(position, 1.0);        \n" +
            "    passPosition = position;                                      \n" +
            "    passNormal = normal;                                          \n" +
            "    passTexturePosition = texturePosition;                        \n" +
            "    passColor = color;                                            \n" +
            "}                                                                 \n"
        let fragmentSource = "#version 330 core                                                                        \n" +
            "uniform sampler2D sample;                                                                                 \n" +
            "uniform struct Light {                                                                                    \n" +
            "   vec3 color;                                                                                            \n" +
            "   vec3 position;                                                                                         \n" +
            "   float ambient;                                                                                         \n" +
            "   float specStrength;                                                                                    \n" +
            "   float specHardness;                                                                                    \n" +
            "} light;                                                                                                  \n" +
            "in vec3 passPosition;                                                                                     \n" +
            "in vec3 passNormal;                                                                                       \n" +
            "in vec2 passTexturePosition;                                                                              \n" +
            "in vec3 passColor;                                                                                        \n" +
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
        shader.create(withVertex: vertexSource, andFragment: fragmentSource)
        shader.setInitialUniforms(for: &self)
    }
    mutating func update(with value: Float) {
        light.position = [sin(value), -5.0, 5.0]
        camera.position = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0).rotateYAxis(value).rotateXAxis(-0.5)
    }
    mutating func draw(with renderer: Renderer) {
        shader.bind()
        vao.bind()

        light.updateParameters(for: shader)
        camera.updateParameters(for: shader)

        renderer.render(vbo.vertexCount, as: .triangles)

        vao.unbind()
    }
    
    mutating func delete() {
        vao.delete()
        vbo.delete()
        tbo.delete()
        shader.delete()
    }
}
