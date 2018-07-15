//
//  SwiftOpenGLView.swift
//  SwiftOpenGL
//
//  Created by Myles Schultz on 9/30/16.
//  Copyright © 2016 MyKo. All rights reserved.
//
//  Ver. 11:    Part 1 of MVC design.  Vector and Matrix related
//      code removed to separate files.  This marks the first
//      step in creating the model of the framework.
//

import Cocoa
import OpenGL.GL3


final class SwiftOpenGLView: NSOpenGLView {
    // Replace the previous properties with out Shader, VertexArrayObject
    // VertexBufferObject, and TextureBufferObject types.  We don't have
    // to worry about crashing the system if we initialize them right
    // away because the OpenGL code will be initiated later in
    // `prepareOpenGL`.
    // Also decalre the data array to be of type [Vertex]
    fileprivate var shader = Shader()
    fileprivate var vao = VertexArrayObject()
    fileprivate var vbo = VertexBufferObject()
    fileprivate var tbo = TextureBufferObject()
    fileprivate var data = [Vertex]()
    
    fileprivate var previousTime = CFTimeInterval()
    
    // Make the view and projection matrices of type `FloatMatrix4`
    fileprivate var view = FloatMatrix4()
    fileprivate var projection = FloatMatrix4()
    
    //  The CVDisplayLink for animating.  Optional value initialized to nil.
    fileprivate var displayLink: CVDisplayLink?
    
    //  In order to recieve keyboard input, we need to enable the view to accept first responder status
    override var acceptsFirstResponder: Bool { return true }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        //  We'll use double buffering this time (one buffer is displayed while the other is
        //  calculated, then we swap them.
        let attrs: [NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), 32,
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            0
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
        
        //  Set the context's swap interval parameter to 60Hz (i.e. 1 frame per swamp)
        self.openGLContext?.setValues([1], for: .swapInterval)
    }
    
    override func prepareOpenGL() {
        super.prepareOpenGL()
        
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        // Fill the data array with our new `Vertex` type.  We'll also take
        // this opportunity to make a new 3D mesh.
        data = [
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
        
        // This is where OpenGL initialization is going to happen.  Also of our
        // OpenGLObject's may now safely run their initialization code here.
        
        // Load the texture--make sure you have a texture named "Texture" in your
        // Assets.xcassets folder.
        tbo.loadTexture(named: "Texture")
        
        // Load our new data into the VBO.
        vbo.load(data)
        
        // Now we tell OpenGL what our vertex layout looks like.
        vao.layoutVertexPattern()
        
        // Define our view and projection matrices
        view = FloatMatrix4().translate(x: 0.0, y: 0.0, z: -5.0)
        projection = FloatMatrix4.projection(aspect: Float(bounds.size.width / bounds.size.height))
        
        // Declare our Vertex and Fragment shader source code.
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
        
        // Pass in the source code to create our shader object and then set
        // it's uniforms.
        shader.create(withVertex: vertexSource, andFragment: fragmentSource)
        shader.setInitialUniforms()
        
        // We'll deal with this guy soon, but for now no changes here.
        let displayLinkOutputCallback: CVDisplayLinkOutputCallback = {(displayLink: CVDisplayLink, inNow: UnsafePointer<CVTimeStamp>, inOutputTime: UnsafePointer<CVTimeStamp>, flagsIn: CVOptionFlags, flagsOut: UnsafeMutablePointer<CVOptionFlags>, displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn in
            unsafeBitCast(displayLinkContext, to: SwiftOpenGLView.self).drawView()
            
            return kCVReturnSuccess
        }
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(displayLink!)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawView()
    }
    
    fileprivate func drawView() {
        guard let context = self.openGLContext else {
            Swift.print("oops")
            return
        }
        
        context.makeCurrentContext()
        context.lock()
        
        let time = CACurrentMediaTime()
        
        let value = Float(sin(time))
        previousTime = time
        
        glClearColor(GLfloat(value), GLfloat(value), GLfloat(value), 1.0)
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glEnable(GLenum(GL_CULL_FACE))
        
        // Bind the shader and VAO
        shader.bind()
        vao.bind()
        
        // reset any uniforms we want to update.  We're going to fix this later,
        // but for fight now, we'll leave the camera out so we can adjust it's position
        glUniform3fv(glGetUniformLocation(shader.id, "light.position"), 1, [value, 2.0, 2.0])
        shader.update(view: view, projection: projection)
        
        // "The moment we've all been waiting for", was ask OpenGL to draw our
        // scene.  Make sure that you adjust the `count` parameter or else you
        // won't see anything more than one triangle.  We'll use our `data`
        // property's `count` property, but cast it into an Int32 which is
        // what glDraw* is expecting.
        glDrawArrays(GLenum(GL_TRIANGLES), 0, Int32(data.count))
        
        // Unbind the shader.
        shader.unbind()
        
        context.flushBuffer()
        context.unlock()
    }
    
    deinit {
        CVDisplayLinkStop(displayLink!)
        // Don't forget to be a good memory manager and delete what we don't
        // need anymore.
        shader.delete()
        vao.delete()
        vbo.delete()
        tbo.delete()
    }
}
