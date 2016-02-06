//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 1/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 11:  Refactored view definition. Vector3, Matrix4, VBO, VAO, TBO, Camera,
//            Shader, and RenderLoop are pulled out into separate file.
//


import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    private var shader: SwiftShader!
    private var vao: SwiftVAO!
    private var vbo: SwiftVBO!
    private var tbo: SwiftTBO!
    
    private var data = [GLfloat]()
    
    private var light = SwiftLight()
    
    var camera = SwiftCamera()
    
    var renderLoop: RenderLoop!
    
    override var acceptsFirstResponder: Bool { return true }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        guard let context = NSOpenGLContext(format: pixelFormat, shareContext: NSOpenGLContext()) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        
        self.openGLContext?.setValues([1], forParameter: .GLCPSwapInterval)
        
    }
    
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        //format: x,    y,    r,   g,   b,    s,   t,    nx,   ny,   nz
        data = [-1.0, -1.0,  1.0, 0.0, 1.0,  0.0, 2.0,  -1.0, -1.0, 0.0001,
                 0.0,  1.0,  0.0, 1.0, 0.0,  1.0, 0.0,   0.0,  1.0, 0.0001,
                 1.0, -1.0,  0.0, 0.0, 1.0,  2.0, 2.0,   1.0, -1.0, 0.0001]
        
        tbo = SwiftTBO(fileName: "Texture")
                
        vbo = SwiftVBO(data: data)
        
        vao = SwiftVAO()
        
        shader = SwiftShader()
        
        tbo.commitTo(shader)
        
        shader.bind()
        
        light.commitTo(shader)
        
        camera = SwiftCamera(offset: 5.0, fieldOfView: 35, aspect: Float(bounds.size.width) / Float(bounds.size.height), nearZ: 0.001, farZ: 1000)
        
        renderLoop = RenderLoop(forView: self)
        renderLoop.start()
        
        drawView()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    func drawView() {
        
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        CGLLockContext(context.CGLContextObj)
        
        let value = Float(sin(renderLoop.currentTime))
        
        camera.updateViewMatrixFor(renderLoop.deltaTime)
        
        glClearColor(GLfloat(value), GLfloat(value), GLfloat(value), 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        shader.bind()
        vao.bind()
        
        light.position(value, y: 1.0, z: 0.4).commitTo(shader)
        
        camera.commitTo(shader)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        vao.unbind()
        
        CGLFlushDrawable(context.CGLContextObj)
        CGLUnlockContext(context.CGLContextObj)
        
    }
    
    deinit {

        renderLoop.stop()
        vao.destroy()
        vbo.destroy()
        tbo.destroy()
        shader.destroy()
        
    }
    
}

