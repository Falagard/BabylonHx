package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.IGraphicsCapabilities;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;

/**
 * WebGL capabilities query implementation
 */
class WebGLCapabilities implements IGraphicsCapabilities {
    private var gl:WebGL2Context;
    private var maxTextureSize:Int;
    private var maxRenderTargetSize:Int;
    private var maxTextureUnits:Int;
    private var maxVertexAttribs:Int;
    
    public function new(gl:WebGL2Context) {
        this.gl = gl;
        
        // Query capabilities
        this.maxTextureSize = this.gl.getParameter(GL.MAX_TEXTURE_SIZE);
        this.maxRenderTargetSize = this.gl.getParameter(GL.MAX_RENDERBUFFER_SIZE);
        this.maxTextureUnits = this.gl.getParameter(GL.MAX_TEXTURE_IMAGE_UNITS);
        this.maxVertexAttribs = this.gl.getParameter(GL.MAX_VERTEX_ATTRIBS);
    }
    
    public function getMaxTextureSize():Int {
        return this.maxTextureSize;
    }
    
    public function getMaxRenderTargetSize():Int {
        return this.maxRenderTargetSize;
    }
    
    public function getMaxTextureUnits():Int {
        return this.maxTextureUnits;
    }
    
    public function getMaxVertexAttributes():Int {
        return this.maxVertexAttribs;
    }
    
    public function supportsTextureFormat(format:String):Bool {
        // WebGL2 supports most common formats
        return switch(format.toUpperCase()) {
            case "RGBA8" | "RGB8" | "RGBA32F" | "RGB32F" | "R32F" | "DEPTH24" | "DEPTH32F": true;
            default: false;
        }
    }
    
    public function supportsCompression(compression:String):Bool {
        return switch(compression.toUpperCase()) {
            case "S3TC": checkExtension("WEBGL_compressed_texture_s3tc");
            case "ETC2": checkExtension("WEBGL_compressed_texture_etc");
            case "ASTC": checkExtension("WEBGL_compressed_texture_astc");
            default: false;
        }
    }
    
    public function supportsAnisotropicFiltering():Bool {
        return checkExtension("EXT_texture_filter_anisotropic");
    }
    
    public function getMaxAnisotropy():Float {
        if (!supportsAnisotropicFiltering()) {
            return 1.0;
        }
        var ext = this.gl.getExtension("EXT_texture_filter_anisotropic");
        if (ext != null) {
            return this.gl.getParameter(cast(ext.MAX_TEXTURE_MAX_ANISOTROPY_EXT, Int));
        }
        return 1.0;
    }
    
    public function getBackendName():String {
        return "WebGL2";
    }
    
    public function getBackendVersion():String {
        var version = this.gl.getParameter(GL.VERSION);
        return Std.string(version);
    }
    
    private function checkExtension(name:String):Bool {
        return this.gl.getExtension(name) != null;
    }
}
