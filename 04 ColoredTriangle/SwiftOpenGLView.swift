//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 8/24/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//
//  Ver. 4:  Draws a triangle where each corner is a different color
//

import Cocoa
import OpenGL.GL3

final class SwiftOpenGLView: NSOpenGLView {
    
    fileprivate var programID: GLuint = 0
    fileprivate var vaoID: GLuint = 0
    fileprivate var vboID: GLuint = 0
    
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
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()
        
        //  We'll add color information to the position information such that the position is 
        //  listed first with two components (x and y) and the color is listed second with 
        //  three components (r, g, and b).
        
        let data: [GLfloat] = [-1.0, -1.0,  1.0, 0.0, 0.0,
                                0.0,  1.0,  0.0, 1.0, 0.0,
                                1.0, -1.0,  0.0, 0.0, 1.0]
        
        glGenBuffers(1, &vboID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * MemoryLayout<GLfloat>.size, data, GLenum(GL_STATIC_DRAW))
        
        glGenVertexArrays(1, &vaoID)
        glBindVertexArray(vaoID)
        
        //  The first pointer is to the position data -- note the last two arguments:  stride 
        //  and offset.
        //  Stride - number of bytes from the start of one vertex to the start of the next
        //      In other words, each vertex is made of 5 elements from the array (x, y, r, g, 
        //      and b).  Each element is a GLfloat with is 4 bytes of data; therefore, 
        //      5(4) = 20 bytes
        //  Offset - number of bytes from the vertex's start address that must be passed by
        //  before reaching the appropriate data
        //      The position data starts at the start address; therefore, offset = 0
        //      The color data starts 2 floats (2(4) = 8 bytes) from the vertex address; 
        //      therefore, offset = 8
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 20, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        //  The second pointer is to the color data.
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 20, UnsafePointer<GLuint>(bitPattern: 8))
        glEnableVertexAttribArray(1)
        
        //  Unbind the VAO so no further changes are made.
        glBindVertexArray(0)

        //  Adjust the shader attributes.  There are two ways to do this, but the simplest is 
        //  the use the layout keyword.  This allows us to use simple indicies when defining 
        //  our vertex attributes as you saw above (i.e. 0 and 1 for position and color, 
        //  respectively).  The alternative is to use glGetAttribLocation().  It's certainly 
        //  more declarative to use this method so we have a named variable instead of a "magic 
        //  number" like 0 or 1, but it's a more common convention to just use the indices.  
        //  The other caveat is that the function assumes the shader has already been 
        //  compiled--in our case it has not.  layout allows us to specifically tell OpenGL 
        //  what index we want for a particular attribute.
        //      layout (location = 0) means the attribute declared thereafter will be located 
        //      at position 0.  It is a little weird that you are forced to use the layout 
        //      keyword to force the convention considering that if you use the functionand 
        //      then print() the result, you'll find that 0 and 1 are assigned as we have them 
        //      below.  If you don't use the layout keyword though, you'll get unexpected 
        //      results (perhaps a black screen, at the worst).  Don't fight the system, just
        //      use layout (location = x)!
        //
        //  Notice the addition of two attributes:  color and passColor.  Color is what is 
        //  passed in from the VBO while passColor is the color that is given to the fragment 
        //  shader.  Note that they are both vec3's and not vec2's because they have three 
        //  values, r, g, and b.
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                    \n" +
            "layout (location = 0) in vec2 position;       \n" +
            "layout (location = 1) in vec3 color;          \n" +
            "out vec3 passColor;                           \n" +
            "void main()                                   \n" +
            "{                                             \n" +
            "    gl_Position = vec4(position, 0.0, 1.0);   \n" +
            "    passColor = color;                        \n" +
            "}                                             \n"
        let vss = source.cString(using: String.Encoding.ascii)
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
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(vs, GLsizei(logLength), &logLength, cLog)
                Swift.print("log = \(String.init(cString: cLog))")
                free(cLog)
            }
        }
        
        //  It is really important to name the in attribute the same as the out attribute from
        //  the vertex shader--otherwise the connection won't be between them.  The name of the
        //  out attribute does not matter.  You just have to have an out and it has to be a 
        //  vec4:  we have to account for the alpha component of a color.  We can use the same 
        //  syntax for creating the vec4 color as we did the position in the vertex shader 
        //  (i.e. passing passColor for the frist three vertices and 1.0 for the fourth to make 
        //  a complete vec4
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                 \n" +
            "in vec3 passColor;                     \n" +
            "out vec4 outColor;                     \n" +
            "void main()                            \n" +
            "{                                      \n" +
            "    outColor = vec4(passColor, 1.0);   \n" +
            "}                                      \n"
        let fss = source.cString(using: String.Encoding.ascii)
        var fssptr = UnsafePointer<GLchar>(fss)
        glShaderSource(fs, 1, &fssptr, nil)
        glCompileShader(fs)
        compiled = 0
        glGetShaderiv(fs, GLbitfield(GL_COMPILE_STATUS), &compiled)
        if compiled <= 0 {
            Swift.print("Could not compile fragement, getting log")
            var logLength: GLint = 0
            glGetShaderiv(fs, GLbitfield(GL_INFO_LOG_LENGTH), &logLength)
            Swift.print(" logLength = \(logLength)")
            if logLength > 0 {
                let cLog = UnsafeMutablePointer<CChar>.allocate(capacity: Int(logLength))
                glGetShaderInfoLog(fs, GLsizei(logLength), &logLength, cLog)
                Swift.print("log = \(String.init(cString: cLog))")
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
        glBindVertexArray(vaoID)
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        glFlush()
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
    }
    
}
