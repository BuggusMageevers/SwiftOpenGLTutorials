//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles La Verne Schultz on 8/30/15.
//  Copyright (c) 2015 MyKo. All rights reserved.
//
//  Ver. 5:  Draws a triangle with a texture using CGImage
//

import Cocoa
import OpenGL.GL3

final class SwiftOpenGLView: NSOpenGLView {
    
    private var programID: GLuint = 0
    private var vaoID: GLuint = 0
    private var vboID: GLuint = 0
    private var tboID: GLuint = 0
    
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
        guard let context = NSOpenGLContext(format: pixelFormat, shareContext: nil) else {
            Swift.print("context could not be constructed")
            return
        }
        self.openGLContext = context
    }
    
    override func prepareOpenGL() {
        
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        programID = glCreateProgram()
        
        //  This time we'll add texture coordinates to each vertex.  When appliced to a model,
        //  These coordinates are named U and V.  When these same coordinates are applied to a
        //  texture, they are named S and T.  I am not really sure why a separate naming
        //  convention is used, but it is.  either way, they values are clamped between 0.0-1.0
        //  As a side, texture coordinates may be described in four dimensions like position
        //  and color:  s, t, r, and q.  However, in GLSL, r is already used for red, so it is
        //  replaced by p.  Thus, in GLSL only, texture coordinates are defined as s, t, p, and q
        //  We only need two dimensions for our texture--we'll add s and t coordinates to each
        //  vertex after each color.
        
        let data: [GLfloat] = [-1.0, -1.0,  1.0, 0.0, 0.0,  0.0, 1.0,
                                0.0,  1.0,  0.0, 1.0, 0.0,  0.5, 0.0,
                                1.0, -1.0,  0.0, 0.0, 1.0,  1.0, 1.0]
        
        //  Now we'll take the time to create the texture data.  We're using the Core Graphics
        //  Framework which allows us to generate and load images that can be placed into bitmaps
        
        //  Get the URL for the texture we added to the TextureTriangle file.
        //  The NSBundle is used to access files packaged with the app, URL's are preferred
        //  over paths
        let fileURL = NSBundle.mainBundle().URLForResource("Texture", withExtension: "png")
        
        //  To get the file's contents into the CGImage, we need a data provider
        //  The dataProvider is what actually writes the data into the the CGImage from the file
        //  The second parameter of our CGImageCreate function is for a decode
        let dataProvider = CGDataProviderCreateWithURL(fileURL)
        let image = CGImageCreateWithPNGDataProvider(dataProvider, nil, false, .RenderingIntentDefault)
        
        //  Declare a pointer to a collection of memory that will hold the texture data.
        //  If you don't use this step, you cannot access the data when you need it
        //  The space in memory must be allocated before we send it into our context
        //  we use malloc to reserve a space of memory 256 * 4 bytes wide (4 bytes, 8 bits
        //  each for r, g, b, and a for 256 pixels), and a height of 256
        let textureData = UnsafeMutablePointer<Void>(malloc(256 * 4 * 256))
        
        //  create a context and pass in the textureData UnsafeMutablePointer as the storage location
        //  for the image data
        let context = CGBitmapContextCreate(textureData, 256, 256, 8, 4 * 256, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), CGImageAlphaInfo.PremultipliedLast.rawValue)
        
        //  Draw the image into the context, this transfers the CGImage data into the
        //  CGContext
        CGContextDrawImage(context, CGRectMake(0.0, 0.0, 256.0, 256.0), image)
        
        //  Generate and bind a texture buffer object
        glGenTextures(1, &tboID)
        glBindTexture(GLenum(GL_TEXTURE_2D), tboID)
        
        //  Set up the parameters regarding how the bounds of the texture are handled
        //  The min and mag filters tell OpenGL how to handle choosing pixels when the
        //  the image is made bigger or smaller than it's actual size, we'll just set it
        //  to linear interplation for now.
        //  The wrap s and t paramters tell OpenGL what do do when the texture position
        //  is outside the range of the texture.  clamp to edge just continues the color.
        //  Note that only the min and mag parameters are required, the wrapping parameters
        //  are not.
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        //  Transfer the bitmap image data to the TBO
        //      The target is the type of texture, we are using a 2D texture
        //      The mipmap level is not turned on if you choose 0
        //      The format we want the texture to be is rgba (GL_RGBA)
        //      The number of pixels along the width
        //      The number of pixel along the height
        //      The number of pixels desired as a border around the texture (we want 0)
        //      The format of the incoming bitamp data is also rgb (GL_RGBA)
        //      The type of data coming in is in bytes which are > 0, so unsigned (GL_UNSIGNED_BYTE)
        //      A pointer to the data itself
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, 256, 256, 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), textureData)
        
        //  Free up the textureData space we reserved from earlier.
        free(textureData)
        
        glGenBuffers(1, &vboID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vboID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), data.count * sizeof(GLfloat), data, GLenum(GL_STATIC_DRAW))
        
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
        glVertexAttribPointer(0, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 28, UnsafePointer<GLuint>(bitPattern: 0))
        glEnableVertexAttribArray(0)
        //  The second pointer is to the color data.
        glVertexAttribPointer(1, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 28, UnsafePointer<GLuint>(bitPattern: 8))
        glEnableVertexAttribArray(1)
        //  The third pointer is to the texture data
        glVertexAttribPointer(2, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 28, UnsafePointer<GLuint>(bitPattern: 20))
        glEnableVertexAttribArray(2)
        
        //  Unbind the VAO so no further changes are made.
        glBindVertexArray(0)
        
        //  Add a texture coordinate in and out attribute to pass the coordinates to the
        //  fragment shader--make sure the set the out att. to the in att. value in main()
        //  We'll use location 2 for texture coordinates
        let vs = glCreateShader(GLenum(GL_VERTEX_SHADER))
        var source = "#version 330 core                     \n" +
            "layout (location = 0) in vec2 position;        \n" +
            "layout (location = 1) in vec3 color;           \n" +
            "layout (location = 2) in vec2 texturePosition; \n" +
            "out vec3 passColor;                            \n" +
            "out vec2 passTexturePosition;                  \n" +
            "void main()                                    \n" +
            "{                                              \n" +
            "    gl_Position = vec4(position, 0.0, 1.0);    \n" +
            "    passColor = color;                         \n" +
            "    passTexturePosition = texturePosition;     \n" +
            "}                                              \n"
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
        
        //  It is really important to name the in attribute the same as the out attribute from
        //  the vertex shader--otherwise the connection won't be between them.  The name of the
        //  out attribute does not matter.  You just have to have an out and it has to be a
        //  vec4:  we have to account for the alpha component of a color.  We can use the same
        //  syntax for creating the vec4 color as we did the position in the vertex shader
        //  (i.e. passing passColor for the frist three vertices and 1.0 for the fourth to make
        //  a complete vec4
        //  The uniform sampler2D is how the texture data gets into the shader.  It's a uniform
        //  because it is the same data every time the fragment is run, whereas the in attributes
        //  change every time the fragment is run.
        //  The outColor attribute uses a combination of the texture and color to produce an
        //  output.  The color part we have already seen.  The texture() function has two
        //  arguments:  the texture to be used, and the position on the texture.
        let fs = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
        source = "#version 330 core                                                         \n" +
            "uniform sampler2D sample;                                                      \n" +
            "in vec3 passColor;                                                             \n" +
            "in vec2 passTexturePosition;                                                   \n" +
            "out vec4 outColor;                                                             \n" +
            "void main()                                                                    \n" +
            "{                                                                              \n" +
            "    outColor = texture(sample, passTexturePosition) * vec4(passColor, 1.0);    \n" +
            "}                                                                              \n"
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
                    Swift.print("log: \(log)")
                }
                free(cLog)
            }
        }
        
        glDeleteShader(vs)
        glDeleteShader(fs)
        
        //  Set the Texture Uniform with glGetUniformLocation
        //  take care to type in "sample" properly otherwise you'll get an error
        //  Pass in the location and the predefined variable that states which texture slot
        //  we are filling--there are a total of 30 slots available.
        let sampleLocation = glGetUniformLocation(programID, "sample")
        glUniform1i(sampleLocation, GL_TEXTURE0)
        
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
        
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)
        
        glBindVertexArray(0)
        
        glFlush()
    }
    
    deinit {
        glDeleteVertexArrays(1, &vaoID)
        glDeleteBuffers(1, &vboID)
        glDeleteProgram(programID)
        glDeleteTextures(1, &tboID) //  Delete the TBO
    }
    
}
