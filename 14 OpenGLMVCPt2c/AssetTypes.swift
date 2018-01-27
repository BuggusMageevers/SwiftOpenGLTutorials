//
//  AssetTypes.swift
//  OpenGLMVCPt2c
//
//  Created by Myles Schultz on 1/12/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Foundation
import OpenGL.GL3


protocol Asset {
    var name: String { get set }
    mutating func delete()
}

struct Camera: Asset {
    var name: String = "Camera"
    var position: Float3 = Float3(x: 0.0, y: 0.0, z: 0.0)
    var viewAspectRatio: Float = 0.0
    var view: FloatMatrix4 = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0)
    var projection: FloatMatrix4 = FloatMatrix4()
    func delete() {}
}

protocol Drawable {
    func draw()
}
extension Drawable {
    func draw() {
        glCall(glDrawArrays(GLenum(GL_TRIANGLES), 0, 3))
    }
}

struct Vertex3D {
    let position: Float3
    let normal: Float3
    let textureCoordinate: Float2
    let color: Float4
}
struct Mesh: Asset {
    var name: String = "Triangle"
    var vertices: [Vertex3D] = [
            Vertex3D(position: Float3(x: -1.0, y: -1.0, z: 0.0),
                     normal: Float3(x: -1.0, y: -1.0, z: 0.0001),
                     textureCoordinate: Float2(x: 0.0, y: 2.0),
                     color: Float4(x: 1.0, y: 0.0, z: 1.0, w: 1.0)),
            Vertex3D(position: Float3(x: 0.0, y: 1.0, z: 0.0),
                     normal: Float3(x: 0.0, y: 1.0, z: 0.0001),
                     textureCoordinate: Float2(x: 1.0, y: 0.0),
                     color: Float4(x: 0.0, y: 1.0, z: 0.0, w: 1.0)),
            Vertex3D(position: Float3(x: 1.0, y: -1.0, z: 0.0),
                     normal: Float3(x: 1.0, y: -1.0, z: 0.0001),
                     textureCoordinate: Float2(x: 2.0, y: 2.0),
                     color: Float4(x: 0.0, y: 0.0, z: 1.0, w: 1.0))
    ]
    var vertexCount: Int32 {
        return Int32(vertices.count)
    }
    
    var vao = VAO()
    var vbo = VBO()
    
    init() {
        vbo.load()
        vao.load()
    }
    
    mutating func delete() {
        vbo.delete()
        vao.delete()
    }
}
struct Light: Asset {
    var name: String = "Light"
    var cyclicValue: Float = 0.0
    
    func delete() {
    }
}

final class Scene {
    /// Accessible and modifiable by the `AssetManager` ONLY.  This ensures
    /// the `AssetManager` maintains **all** assets not any particular
    /// scene.
    private var cameras = [String : Camera]()
    private var lights = [String : Light] ()
    private var meshes = [String : Mesh]()
    
    var shader = SwiftShader()
    
    init(cameras: [Camera], lights: [Light], meshes: [Mesh]) {
        print("Initializing Scene...")
        for camera in cameras {
            self.cameras[camera.name] = camera
        }
        for light in lights {
            self.lights[light.name] = light
        }
        for mesh in meshes {
            self.meshes[mesh.name] = mesh
        }
    }
    
    func draw(with renderer: Renderer) {
        shader.bind()
        for (_, mesh) in meshes {
            mesh.vao.bind()
            if let light = lights["Light"], let camera = cameras["globalCamera"] {
                shader.updateUniforms(lightData: light, cameraData: camera)
            }
            renderer.draw(triangels: 0, to: mesh.vertexCount)
            mesh.vao.unbind()
        }
        shader.unbind()
    }
}
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
