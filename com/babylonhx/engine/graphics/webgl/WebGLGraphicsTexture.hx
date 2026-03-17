package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.IGraphicsTexture;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.utils.GL.GLTexture;

/**
 * WebGL texture implementation
 */
class WebGLGraphicsTexture implements IGraphicsTexture {
    private var gl:WebGL2Context;
    private var texture:GLTexture;
    private var width:Int;
    private var height:Int;
    private var format:String;
    private var internalFormat:Int;
    private var type:Int;
    
    public function new(gl:WebGL2Context, texture:GLTexture, width:Int, height:Int, format:String, ?data:ArrayBufferView) {
        this.gl = gl;
        this.texture = texture;
        this.width = width;
        this.height = height;
        this.format = format;
        
        // Parse format string and map to WebGL constants
        this.mapFormat(format);
        
        // Initialize texture
        bind(0);
        this.gl.texImage2D(GL.TEXTURE_2D, 0, this.internalFormat, width, height, 0, this.internalFormat, this.type, data);
    }
    
    public function bind(slot:Int):Void {
        this.gl.activeTexture(GL.TEXTURE0 + slot);
        this.gl.bindTexture(GL.TEXTURE_2D, this.texture);
    }
    
    public function setData(data:ArrayBufferView, width:Int, height:Int):Void {
        this.width = width;
        this.height = height;
        
        bind(0);
        this.gl.texImage2D(GL.TEXTURE_2D, 0, this.internalFormat, width, height, 0, this.internalFormat, this.type, data);
    }
    
    public function getWidth():Int {
        return this.width;
    }
    
    public function getHeight():Int {
        return this.height;
    }
    
    public function updateRegion(data:ArrayBufferView, x:Int, y:Int, width:Int, height:Int):Void {
        bind(0);
        this.gl.texSubImage2D(GL.TEXTURE_2D, 0, x, y, width, height, this.internalFormat, this.type, data);
    }
    
    public function generateMipmaps():Void {
        bind(0);
        this.gl.generateMipmap(GL.TEXTURE_2D);
    }
    
    public function dispose():Void {
        this.gl.deleteTexture(this.texture);
    }
    
    private function mapFormat(format:String):Void {
        // Simple format string to WebGL format mapping
        switch (format.toUpperCase()) {
            case "RGBA8":
                this.internalFormat = GL.RGBA;
                this.type = GL.UNSIGNED_BYTE;
            case "RGB8":
                this.internalFormat = GL.RGB;
                this.type = GL.UNSIGNED_BYTE;
            case "RGBA32F":
                this.internalFormat = GL.RGBA32F;
                this.type = GL.FLOAT;
            case "RGB32F":
                this.internalFormat = GL.RGB32F;
                this.type = GL.FLOAT;
            case "R32F":
                this.internalFormat = GL.R32F;
                this.type = GL.FLOAT;
            case "DEPTH24":
                this.internalFormat = GL.DEPTH_COMPONENT24;
                this.type = GL.UNSIGNED_INT;
            case "DEPTH32F":
                this.internalFormat = GL.DEPTH_COMPONENT32F;
                this.type = GL.FLOAT;
            default:
                this.internalFormat = GL.RGBA;
                this.type = GL.UNSIGNED_BYTE;
        }
    }
}
