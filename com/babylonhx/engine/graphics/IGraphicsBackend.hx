package com.babylonhx.engine.graphics;

/**
 * Main graphics backend interface
 * Implementations: WebGL, Vulkan, DirectX12, Metal, etc.
 */
interface IGraphicsBackend {
    /**
     * Initialize the graphics backend
     * @param canvas The canvas element (DOM or platform-specific)
     */
    function initialize(canvas:Dynamic):Void;
    
    /**
     * Create a vertex/index/uniform buffer
     * @param data Initial data (can be null)
     * @param usage Buffer usage hint (GL_STATIC_DRAW, GL_DYNAMIC_DRAW, etc.)
     */
    function createBuffer(data:ArrayBufferView, usage:Int):IGraphicsBuffer;
    
    /**
     * Create a texture
     * @param width Texture width
     * @param height Texture height
     * @param format Texture format (e.g., "RGBA8", "RGB32F")
     * @param data Initial texture data (optional)
     */
    function createTexture(width:Int, height:Int, format:String, ?data:ArrayBufferView):IGraphicsTexture;
    
    /**
     * Create a shader program
     * @param vertexSource Vertex shader source code
     * @param fragmentSource Fragment shader source code
     */
    function createProgram(vertexSource:String, fragmentSource:String):IGraphicsProgram;
    
    /**
     * Create a render pipeline
     */
    function createPipeline():IRenderPipeline;
    
    /**
     * Begin rendering a frame
     */
    function beginFrame():Void;
    
    /**
     * End rendering a frame and present to screen
     */
    function endFrame():Void;
    
    /**
     * Clear the current render target
     * @param color Clear color as [R,G,B,A] where each is 0-1
     * @param depth Clear depth value (0-1)
     * @param stencil Clear stencil value
     */
    function clear(?color:Array<Float>, ?depth:Float, ?stencil:Int):Void;
    
    /**
     * Draw vertices
     * @param vertexCount Number of vertices to draw
     * @param instanceCount Number of instances (1 for non-instanced)
     * @param firstVertex First vertex index
     * @param firstInstance First instance index
     */
    function draw(vertexCount:Int, ?instanceCount:Int, ?firstVertex:Int, ?firstInstance:Int):Void;
    
    /**
     * Draw indexed vertices
     * @param indexCount Number of indices to draw
     * @param indexType Index type (GL_UNSIGNED_SHORT, GL_UNSIGNED_INT)
     * @param indexOffset Byte offset into index buffer
     * @param instanceCount Number of instances
     * @param baseVertex Base vertex index
     */
    function drawIndexed(indexCount:Int, indexType:Int, ?indexOffset:Int, ?instanceCount:Int, ?baseVertex:Int):Void;
    
    /**
     * Get graphics capabilities
     */
    function getCapabilities():IGraphicsCapabilities;
    
    /**
     * Set viewport
     * @param x X position
     * @param y Y position
     * @param width Viewport width
     * @param height Viewport height
     */
    function setViewport(x:Int, y:Int, width:Int, height:Int):Void;
    
    /**
     * Set scissor rect
     * @param x X position
     * @param y Y position
     * @param width Scissor width
     * @param height Scissor height
     */
    function setScissor(x:Int, y:Int, width:Int, height:Int):Void;
    
    /**
     * Resize the rendering context
     * @param width New width
     * @param height New height
     */
    function resize(width:Int, height:Int):Void;
    
    /**
     * Dispose the backend and free all resources
     */
    function dispose():Void;
}
