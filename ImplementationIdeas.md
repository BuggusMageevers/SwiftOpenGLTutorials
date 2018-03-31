#  Implementation Ideas
## Rendering
At first I thought it prudent to prepare a scene and then draw a scene.  However, passing a `SceneName` and a `Float` (the current time) twice (once per call to the `GraphicViewDataSource`) seemed too redundat.  I've opted to remove the `prepare` function and opt to use only the `draw` function at this time.

With `draw` then, we need to prepare the scene, and then render it into the context.

### FrameRequest
I have gone over so many iterations of *what* to send and then return as part of the preparation process, that my head is spinning.  I think it best to prototype a `Frame` to hold the name of the scene being drawn, and a time stamp marking that's scene's configuration at a given time.
```Swift
struct Frame {
    let sceneName: String
    let timeStamp: Float
}
```
Better yet, consider this a `FrameRequest` which will be used to create a `Frame` for display.
```Swift
struct FrameRequest {
    let sceneName: String
    let timeStamp: Float
}
```
### ObjectGraph
The `FrameRequest`  could then be passed around as need for the purpose of creating the individual representations of a given `Frame`.  For instance, the locations of various objects in a scene may be considered a separately and then brought together once each is prepared.  These locations could be managed in `ObjectGraph`:  holds different `Layout`'s of all of the objects available to the `AssetManager`.  To `ObjectGraph` get the current position of the "point of view" into a seen, or the position of a model, the current instance of `Frame` is passed, and the transformations for each object are calculated and return as a `Layout`.  This `Layout` is used to create an instance of `Scene` which is part of the `Frame` we are creating.
Separately, the user may apply `Force`'s to an object to cause the object to move (e.g. pushes down the 'w' key to make the camera move forward).  A `Force` is added to a stack of `Force`'s which each have a time stamp of the last time stamp in which they were applied.  If the user withdraw's input (e.g. stops pressing 'w'), a message is sent to remove the associated `Force` at the time the user stopped the input.  Therefore, at 60 fps, if a user happens to remove a given `Force` between frames, the `Force` is only applied for the actual duration if was being applied (i.e. a delta time is calculated using the "removed force time" instead of the `FrameRequest` time.)
### Scene
A `Scene` could provide the order in which objects are drawn by housing an array of drawing instructions.  Each instruction would then be pulled from the array and performed accordingly by the renderer.  Additionaly, a `Scene` could have `Layer`'s which specifiy which objects in a scene are grouped (and thus "drawn") together.  The `Scene` object is still very much in development:
```Swift
struct Scene {
    // Draw this, enable that, switch texture...
    let process: [Process]
    // Lights, aux cameras (which may be switched to for recording),
    // models all assumed to be drawn together before the next layer.
    let layers: [Layer]
}
```
### NSOpenGLContext Extension
A number of calls to OpenGL require passing in the "ID"'s provided by OpenGL.  The question is where to store them.  Initially I was going to have all of the OpenGL code mixed through the Model section, but I have come to realize that this code belongs with the View.  When looking at CoreGraphics, CGContext is the interface through which state is created/modified, and graphic context is created:
```Swift
// If we have an instance of CGContext
let context = <#AnInstanceOfCGContext>
// Then we may create context *through* the context
context.move(to: <#SomePoint>)
```
In this same way, I believe it prudent to add my implementation of OpenGL code as an extention on `NSOpenGLContext`.  This way state changes, uniform updates, etc. would be done through the current context as has already been modeled by Apple with CoreGraphics.  This also makes better sense as I have discovered recently that calls to the GPU with OpenGL code are not processed unless an NSOpenGLContext (e.g. CGContext) is currently "bound".  I discovered this while trying to cause a new `Scene` to be loaded when the user clicked any where in the view.  By creating an instance of a context within `keyDown(_:)`, I was able to get the OpenGL objects created so the scene would render out.
### The True Frame
A `Frame` then, would hold the `FrameRequest` information for debugging or cataloging purposes, while additionally contianing a `pointOfView` (i.g. `Camera`) to look into a `Scene`.
```Swift
struct Frame {
    let sceneName: String
    let timeStamp: Float
    let pointOfView: Camera
    let scene: Scene
}
```
## Conclusions
This process is more modular that my previous ideas, but also more complicated.  I have created several working examples already, but each was so limited in potential--it would need refactoring just as soon as I commited to it.  By increasing some complexity now, I can compartmentalize data such that making one thing more complicated internally does not affect the other parts (as far as code communication is concerned).  Yes, I realize this is the whole point of OOP, but these are tutorials, and I trying to take the most understandable route.  All in all, I realized that my method of developing these tutorials is flawed anyway.  I ought to have fully implemented the OpenGL pipeline prior to makig it conform to an MVC design.  The tutorials have become about the nuances of OOP and POP--and maybe a granule of FP--instead of the OpenGL.  I'll remedy this later, after I have a better look at what the end point is, and then reverse engineer the tutorials knowing where I want to get.
