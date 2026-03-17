package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.*;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.math.Color4;

/**
 * WebGL2 graphics backend implementation
 * Wraps the existing WebGL2 functionality with the IGraphicsBackend interface
 */
class WebGLBackend implements IGraphicsBackend {
    private var gl:WebGL2Context;
    private var canvas:Dynamic;
    private var capabilities:WebGLCapabilities;
    
    public function new() {
    }
    
    public function initialize(canvas:Dynamic):Void {
        this.canvas = canvas;
        
        // Get WebGL2 context
        #if js
        var context:Dynamic = null;
        if (canvas.getContext != null) {
            context = canvas.getContext("webgl2") ?? canvas.getContext("webgl") ?? canvas.getContext("experimental-webgl");
        }
        this.gl = cast context;
        #else
        // For native platforms, use Lime's OpenGL context
        this.gl = GL.gl;
        #end
        
        if (this.gl == null) {
            throw "WebGL context could not be created";
        }
        
        // Initialize capabilities
        this.capabilities = new WebGLCapabilities(this.gl);
    }
    
    public function createBuffer(data:ArrayBufferView, usage:Int):IGraphicsBuffer {
        var buffer = this.gl.createBuffer();
        var wrapper = new WebGLGraphicsBuffer(this.gl, buffer, data, usage);
        return wrapper;
    }
    
    public function createTexture(width:Int, height:Int, format:String, ?data:ArrayBufferView):IGraphicsTexture {
        var texture = this.gl.createTexture();
        var wrapper = new WebGLGraphicsTexture(this.gl, texture, width, height, format, data);
        return wrapper;
    }
    
    public function createProgram(vertexSource:String, fragmentSource:String):IGraphicsProgram {
        var vertexShader = this.compileShader(vertexSource, GL.VERTEX_SHADER);
        var fragmentShader = this.compileShader(fragmentSource, GL.FRAGMENT_SHADER);
        var program = this.gl.createProgram();
        
        this.gl.attachShader(program, vertexShader);
        this.gl.attachShader(program, fragmentShader);
        this.gl.linkProgram(program);
        
        if (!this.gl.getProgramParameter(program, GL.LINK_STATUS)) {
            var info = this.gl.getProgramInfoLog(program);
            throw "Shader program failed to link: " + info;
        }
        
        this.gl.deleteShader(vertexShader);
        this.gl.deleteShader(fragmentShader);
        
        return new WebGLGraphicsProgram(this.gl, program);
    }
    
    public function createPipeline():IRenderPipeline {
        return new WebGLRenderPipeline(this.gl);
    }
    
    public function beginFrame():Void {
        // Nothing special needed for WebGL
    }
    
    public function endFrame():Void {
        // Nothing special needed for WebGL
    }
    
    public function clear(?color:Array<Float>, ?depth:Float, ?stencil:Int):Void {
        var clearBits = 0;
        
        if (color != null) {
            this.gl.clearColor(color[0], color[1], color[2], color[3]);
            clearBits |= GL.COLOR_BUFFER_BIT;
        }
        
        if (depth != null) {
            this.gl.clearDepth(depth);
            clearBits |= GL.DEPTH_BUFFER_BIT;
        }
        
        if (stencil != null) {
            this.gl.clearStencil(stencil);
            clearBits |= GL.STENCIL_BUFFER_BIT;
        }
        
        if (clearBits != 0) {
            this.gl.clear(clearBits);
        }
    }
    
    public function draw(vertexCount:Int, ?instanceCount:Int, ?firstVertex:Int, ?firstInstance:Int):Void {
        if (instanceCount == null) instanceCount = 1;
        if (firstVertex == null) firstVertex = 0;
        if (firstInstance == null) firstInstance = 0;
        
        if (instanceCount == 1) {
            this.gl.drawArrays(GL.TRIANGLES, firstVertex, vertexCount);
        } else {
            this.gl.drawArraysInstanced(GL.TRIANGLES, firstVertex, vertexCount, instanceCount);
        }
    }
    
    public function drawIndexed(indexCount:Int, indexType:Int, ?indexOffset:Int, ?instanceCount:Int, ?baseVertex:Int):Void {
        if (indexOffset == null) indexOffset = 0;
        if (instanceCount == null) instanceCount = 1;
        if (baseVertex == null) baseVertex = 0;
        
        if (instanceCount == 1) {
            this.gl.drawElements(GL.TRIANGLES, indexCount, indexType, indexOffset);
        } else {
            this.gl.drawElementsInstanced(GL.TRIANGLES, indexCount, indexType, indexOffset, instanceCount);
        }
    }
    
    public function getCapabilities():IGraphicsCapabilities {
        return this.capabilities;
    }
    
    public function setViewport(x:Int, y:Int, width:Int, height:Int):Void {
        this.gl.viewport(x, y, width, height);
    }
    
    public function setScissor(x:Int, y:Int, width:Int, height:Int):Void {
        this.gl.scissor(x, y, width, height);
    }
    
    public function resize(width:Int, height:Int):Void {
        #if js
        if (this.canvas != null) {
            this.canvas.width = width;
            this.canvas.height = height;
        }
        #end
    }
    
    public function dispose():Void {
        // Nothing to dispose for WebGL
    }
    
    // Helper method to compile shaders
    private function compileShader(source:String, shaderType:Int):Dynamic {
        var shader = this.gl.createShader(shaderType);
        this.gl.shaderSource(shader, source);
        this.gl.compileShader(shader);
        
        if (!this.gl.getShaderParameter(shader, GL.COMPILE_STATUS)) {
            var info = this.gl.getShaderInfoLog(shader);
            throw "Shader compilation failed: " + info;
        }
        
        return shader;
    }
}
