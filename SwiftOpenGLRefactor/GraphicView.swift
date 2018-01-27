//
//  GraphicView.swift
//  SwiftOpenGLRefactor
//
//  Created by Myles Schultz on 1/17/18.
//  Copyright © 2018 MyKo. All rights reserved.
//

import Cocoa
import OpenGL.GL3


protocol RenderDelegate {
    typealias SceneName = String
    
    func loadScene()
    func prepareToRender(_ scene: SceneName, for time: Double)
    func render(_ scene: SceneName, with renderer: Renderer)
}

enum RenderElementType: UInt32 {
    case triangles = 4
    case lines = 1
    case points = 0
}
protocol Renderer {
    func render(_ elementCount: Int32, as elementType: RenderElementType)
}
extension NSOpenGLContext: Renderer {
    func render(_ elementCount: Int32, as elementType: RenderElementType) {
        glCall(glDrawArrays(elementType.rawValue, 0, elementCount))
    }
}
extension _CGLContextObject: Renderer {
    func render(_ elementCount: Int32, as elementType: RenderElementType) {
        glCall(glDrawArrays(elementType.rawValue, 0, elementCount))
    }
}

final class GraphicView: NSOpenGLView {
    typealias SceneName = String
    
    var scene: SceneName?
    var displayLink: DisplayLink?
    var renderDelegate: RenderDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        let attributes: [NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAllRenderers),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 32,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            0
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attributes) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        
        guard let context = NSOpenGLContext(format: pixelFormat, share: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
        
        //  Set the context's swap interval parameter to 60Hz (i.e. 1 frame per swamp)
        self.openGLContext?.setValues([1], for: .swapInterval)
        
        displayLink = DisplayLink(forView: self)
    }
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        
        glClearColor(0.5, 0.5, 0.5, 1.0)
        
        renderDelegate?.loadScene()
        displayLink?.start()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawView()
    }
    
    func drawView() {
        guard let context = self.openGLContext?.cglContextObj else {
            Swift.print("oops")
            return
        }
        
        CGLSetCurrentContext(context)
        CGLLockContext(context)
        
        if let time = displayLink?.currentTime {
            glCall(glClear(GLbitfield(GL_COLOR_BUFFER_BIT)))
            glCall(glCullFace(GLenum(GL_BACK)))
            glCall(glEnable(GLenum(GL_CULL_FACE)))
            
            if let scene = scene {
                renderDelegate?.prepareToRender(scene, for: time)
                
                renderDelegate?.render(scene, with: context.pointee)
            }
        }
        
        CGLFlushDrawable(context)
        CGLUnlockContext(context)
    }
    
    deinit {
        displayLink?.stop()
    }
}
