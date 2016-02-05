//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 2/20/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//
//  Ver. 2:  Draws a vertex to the screen with OpenGL shaders
//


import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    private var programID: GLuint = 0
    private var vaoID: GLuint = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //  OpenGL view setup
        //  NSOpenGLPixelFormatAttribute is a typealias for UInt32 in Swift and GLbitfield in OpenGL, cast each attribute
        //  Set the view's PixelFormat and Context to the custom pixelFormat and context
        
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFAAccelerated),
            UInt32(NSOpenGLPFAColorSize), UInt32(32),
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core),
            UInt32(0)
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes: attrs) else {
            Swift.print("pixelFormat could not be constructed")
            return
        }
        self.pixelFormat = pixelFormat
        guard let context = NSOpenGLContext(format: pixelFormat, shareContext: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        //  Setup OpenGL
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()
        
        glGenVertexArrays(1, &vaoID)
        
        //  Here we see an example of converting a variable into a pointer to a pointer
        //  This function from sbennett912 takes an UnsafePointer of a certain type and
        //  returns an UnsafePointer of the same type: to the compiler, you've created
        //  a variable that passes as an UnsafePointer<UnsafePointer<type>>
        //  As an alternative, you can cast the varible as an UnsafePointer<type>
        //  i.e. UnsafePointer<CChar>(variable)
        func getPointer <T> (pointer: UnsafePointer<T>)->UnsafePointer<T> { return pointer }
        
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                             \n" +
                     "void main()                                   \n" +
                     "{                                             \n" +
                     "    gl_Position = vec4(0.0, 0.0, 0.0, 1.0);   \n" +
                     "}                                             \n"
        if let vss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            //  Here we cast instead of using the getPointer() function
            var vssptr = UnsafePointer<GLchar>(vss)
            glShaderSource(vs, 1, &vssptr, nil)
            glCompileShader(vs)
            var compiled: GLint = 0
            glGetShaderiv(vs, GLbitfield(GL_COMPILE_STATUS), &compiled)
            if compiled <= 0 {
                Swift.print("Could not compile, getting log")
                var logLength: GLint = 0
                glGetShaderiv(vs, GLenum(GL_INFO_LOG_LENGTH), &logLength)
                Swift.print(" logLength = \(logLength)")
                if logLength > 0 {
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("Vert Error Log = \(log)")
                        free(cLog)
                    }
                }
            }
        }
        
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                     \n" +
                 "out vec4 color;                       \n" +
                 "void main()                           \n" +
                 "{                                     \n" +
                 "    color = vec4(1.0, 1.0, 1.0, 1.0); \n" +
                 "}                                     \n"
        if let fss = source.cStringUsingEncoding(NSASCIIStringEncoding) {
            var fssptr = getPointer(fss)
            glShaderSource(fs, 1, &fssptr, nil)
            glCompileShader(fs)
            var compiled: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
            if compiled <= 0 {
                Swift.print("Could not compile, getting log")
                var logLength: GLint = 0
                glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
                Swift.print(" logLength = \(logLength)")
                if logLength > 0 {
                    let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                    glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                    if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                        Swift.print("Frag Error Log = \(log)")
                        free(cLog)
                    }
                }
            }
        }
        
        glAttachShader(programID, vs)
        glAttachShader(programID, fs)
        glLinkProgram(programID)
        var linked: GLint = 0
        glGetProgramiv(programID, UInt32(GL_LINK_STATUS), &linked)
        if linked <= 0 {
            Swift.print("Could not link, getting log")
            var logLength: GLint = 0
            glGetProgramiv(programID, UInt32(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>(malloc(Int(logLength)))
                glGetProgramInfoLog(programID, GLsizei(logLength), &logLength, cLog)
                if let log = String(CString: cLog, encoding: NSASCIIStringEncoding) {
                    Swift.print("Program Error Log: \(log)")
                }
                free(cLog)
            }
        }
        
        //  These shaders are currently being used by the Shader Program, so they are just
        //  flagged for deletion.  They shall be automatically detached and deleted when 
        //  when glDeleteShader() is called on the associated shader program.
        glDeleteShader(vs)
        glDeleteShader(fs)
        
        //  Run a test render
        
        drawView()
        
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    private func drawView() {
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programID)
        glBindVertexArray(vaoID)
        
        glPointSize(40)
        glDrawArrays(GLenum(GL_POINTS), 0, 1)
        
        glBindVertexArray(0)
        
        glFlush()
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteProgram(programID)
    }
}
