//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 8/23/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//
//  Ver. 3:  Draws a triangle to the screen with OpenGL shaders
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    
    fileprivate var programID: GLuint = 0
    fileprivate var vaoID: GLuint = 0
    fileprivate var vboID: GLuint = 0    //  The VBO handle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
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
        guard let context = NSOpenGLContext(format: pixelFormat, share: nil) else {
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
        
        //  A triangle is one of three primitives used for drawing in OpenGL:
        //      points, lines, triangles
        //  To draw a solid triangle to the screen, we'll need three points.  OpenGL defines
        //  drawing space as being Unit length (Normalized) in positive and negative directions.
        //  The top of the view is y 1.0, bottom -1.0, left -1.0, right 1.0, etc.
        //  This is different from the way other Mac API's define screen space:
        //      the origin x 0.0, y 0.0 is the middle of the view in OpenGL and the bottom left
        //      of the view in Mac.
        //  We'll define a triangle that fits these coordinates in an array that we can send to
        //  a VBO.  We don't need to access it later, so we'll define it within the method such
        //  that upon method completion, the memory will be released.
        //  We are drawing a two dimensional object, so for right now, we only need to define an
        //  x and y coordinate.  The z and w coordinates will be added in the shader (see below).
        
        let data: [GLfloat] = [-1.0, -1.0, 0.0, 1.0, 1.0, -1.0]  //  Three vertices
        
        //  The ampersand is used when passing a variable of type <Type> (i.e. a: <Type>)
        //  You may drop the ampersand if you define the variable as an UnsafeMutablePointer
        //      a: UnsafeMutablePointer<Type>
        //  We choose the former because we'll be using the <GLuint> form far more than the
        //  UnsafeMutablePointer<GLuint> form--this makes the code look nicer.
        
        glGenBuffers(1, &vboID)                             //  Allocate a buffer with the handle
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboID)    //  Initialize the buffer
        
        //  The next line fills the VBO with the data in our array "data".  The first argument is
        //  the type of VBO--GL_ARRAY_BUFFER is used when we are drawing vertices one after
        //  another in an array.  The alternative is GL_ELEMENT_ARRAY_BUFFER which feeds the
        //  shader by indices--more on this later.  The second argument tells OpenGL how many
        //  bytes are required (each element in data is a float and there are data.count number of
        //  elements or 6 elements (4 bytes) = 24 bytes).  The third argument is supposed to be a
        //  a pointer to the data.  Swift does not directly expose pointers, but it does allow you
        //  to pass variable names to UnsafePointer<Type> parameters.  The fourth argument tells
        //  tells OpenGL how to optimize memory for drawing.  GL_STATIC_DRAW states that the data
        //  will mostly read from and won't be changed often (it's just a hint to the GPU).
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<GLfloat>.size, data, GLenum(GL_STATIC_DRAW))
        
        glGenVertexArrays(1, &vaoID)
        //  We have to bind the VAO before we can add a pointer to an attribute
        glBindVertexArray(vaoID)
        
        //  Vertex attribute pointers set up connections between VBO data and shader input
        //  attributes.  The first parameter is the index location of the attribute in the shader.
        //  You see this later, but the first defined attribute is 0, the second is 1, etc.  The
        //  second parameter tells OpenGL how many "pieces" of data are being supplied--we're
        //  passing a location with an x and why coordinate, or 2 values.  The third parameter
        //  tells OpenGL what type the data is so it knows how many bytes are needed.  The fourth
        //  parameter tells OpenGL if the data needs to be normalized (converted to a value
        //  between -1.0 and 1.0).  We are already doing so in our array so we pass in false.  The
        //  fifth parameter is the stride and tells OpenGL how large a vertex is in bytes.  If you
        //  pass 0, OpenGL assumes the vertex size is the same as the number of pieces of data
        //  times the data type (here that is 2 * 4bytes = 8).  The sixth parameter tells OpenGL
        //  how many bytes from the vertex's address must be skipped over to reach the data.  0
        //  tells OpenGL the data is at the start of the vertex's address.
        //  NOTE:  The VAO knows which VBO to access because it is bound when this attribute is
        //      created.  A VAO does not store the VBO handle itself.
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)    //  Unbind the VAO so no further changes are made.
        
        //  Now we'll add input attributes to the shader.  Inputs are marked as in, uniform, or
        //  Sample2D, Sample3D, etc.  They are defined after the shader version, but before the
        //  main function.  Our in attribute is a 2 point vector (vec2).  In the main function
        //  we set the predefined variable gl_Position.  Remember that it expects a vec4.  We make
        //  a new vec4 by using our vec2 for the first two arguments and passing in 0.0 for the z,
        //  and 1.0 for w arguments.
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                    \n" +
            "in vec2 position;                             \n" +
            "void main()                                   \n" +
            "{                                             \n" +
            "    gl_Position = vec4(position, 0.0, 1.0);   \n" +
            "}                                             \n"
        let vss = source.cString(using: String.Encoding.ascii)
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
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                \n" +
            "out vec4 color;                       \n" +
            "void main()                           \n" +
            "{                                     \n" +
            "    color = vec4(1.0, 1.0, 1.0, 1.0); \n" +
            "}                                     \n"
        let fss = source.cString(using: String.Encoding.ascii)
        var fssptr = UnsafePointer<GLchar>(fss)
        glShaderSource(fs, 1, &fssptr, nil)
        glCompileShader(fs)
        compiled = 0
        glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            Swift.print("Could not compile, getting log")
            var logLength: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                Swift.print(" log = \n\t\(String.init(cString: cLog))")
                free(cLog)
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
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetProgramInfoLog(programID, GLsizei(logLength), &logLength, cLog)
                Swift.print("log: \(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        glDeleteShader(vs)
        glDeleteShader(fs)
        
        drawView()
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        
        drawView()
        
    }
    
    fileprivate func drawView() {
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glUseProgram(programID)
        glBindVertexArray(vaoID)     //  VBO's are used indirectly through VAO's
        
        //  To draw a solid triangle, we pass GL_TRIANGLES as the first argument and 3 as the last
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        glFlush()
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)        //  All objects must be deleted manually
        glDeleteProgram(programID)
    }
    
}
