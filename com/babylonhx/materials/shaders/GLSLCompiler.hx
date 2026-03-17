package com.babylonhx.materials.shaders;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.utils.GL.GLShader;

/**
 * GLSL Shader Compiler
 * Wraps WebGL shader compilation with the IShaderCompiler interface
 */
class GLSLCompiler implements IShaderCompiler {
    private var gl:WebGL2Context;
    private var version:String = "GLSL ES 3.0";
    
    public function new(gl:WebGL2Context) {
        this.gl = gl;
    }
    
    public function compileVertexShader(source:String, ?defines:String, ?version:String):ShaderCompilationResult {
        return this._compileShader(source, "vertex", defines, version);
    }
    
    public function compileFragmentShader(source:String, ?defines:String, ?version:String):ShaderCompilationResult {
        return this._compileShader(source, "fragment", defines, version);
    }
    
    public function linkProgram(vertexShader:Dynamic, fragmentShader:Dynamic):ProgramLinkResult {
        if (vertexShader == null || fragmentShader == null) {
            return new ProgramLinkResult(false, null, "One or both shaders are null");
        }
        
        var program = this.gl.createProgram();
        
        try {
            this.gl.attachShader(program, vertexShader);
            this.gl.attachShader(program, fragmentShader);
            this.gl.linkProgram(program);
            
            if (!this.gl.getProgramParameter(program, GL.LINK_STATUS)) {
                var info = this.gl.getProgramInfoLog(program);
                return new ProgramLinkResult(false, null, "Program linking failed: " + info, vertexShader, fragmentShader);
            }
            
            return new ProgramLinkResult(true, program, null, vertexShader, fragmentShader);
        } catch (e:Dynamic) {
            return new ProgramLinkResult(false, null, "Linking error: " + Std.string(e), vertexShader, fragmentShader);
        }
    }
    
    public function getVersion():String {
        return this.version;
    }
    
    public function supportsFeature(feature:String):Bool {
        return switch(feature.toLowerCase()) {
            case "geometry_shaders": false; // WebGL doesn't support geometry shaders
            case "tessellation_shaders": false; // WebGL doesn't support tessellation
            case "compute_shaders": false; // WebGL doesn't support compute shaders natively
            case "integer_attributes": true; // WebGL2 supports integer attributes
            case "instancing": true; // WebGL2 supports instancing
            case "texture_arrays": true; // WebGL2 supports texture arrays
            case "transform_feedback": true; // WebGL2 supports transform feedback
            case "ubo": true; // WebGL2 supports uniform buffer objects
            case "ssbo": false; // WebGL doesn't support shader storage buffers
            case "bindless_textures": false;
            default: false;
        }
    }
    
    // Private Methods
    
    /**
     * Compile a shader with proper error handling
     */
    private function _compileShader(source:String, type:String, ?defines:String, ?version:String):ShaderCompilationResult {
        if (source == null || source.length == 0) {
            return new ShaderCompilationResult(false, null, "Source is null or empty", type, source);
        }
        
        // Prepare full shader source
        var fullSource = this._buildShaderSource(source, defines, version, type);
        
        var shaderType = type == "vertex" ? GL.VERTEX_SHADER : GL.FRAGMENT_SHADER;
        var shader:GLShader = this.gl.createShader(shaderType);
        
        try {
            this.gl.shaderSource(shader, fullSource);
            this.gl.compileShader(shader);
            
            if (!this.gl.getShaderParameter(shader, GL.COMPILE_STATUS)) {
                var info = this.gl.getShaderInfoLog(shader);
                return new ShaderCompilationResult(false, null, info, type, fullSource);
            }
            
            return new ShaderCompilationResult(true, shader, null, type, fullSource);
        } catch (e:Dynamic) {
            return new ShaderCompilationResult(false, null, "Compilation error: " + Std.string(e), type, fullSource);
        }
    }
    
    /**
     * Build complete shader source with version and defines
     */
    private function _buildShaderSource(source:String, ?defines:String, ?version:String, ?type:String):String {
        var parts = [];
        
        // Add GLSL version directive
        if (version == null || version.length == 0) {
            version = "300 es";
        }
        
        #if (js || purejs)
        // JavaScript (web) - use GLSL ES
        parts.push("#version " + version + "\n");
        #else
        // Native/Desktop - use standard GLSL
        if (version == "300 es" || version == "100") {
            version = "330";
        }
        if (version == "450 es") {
            version = "450";
        }
        parts.push("#version " + version + "\n");
        #end
        
        // Add defines
        if (defines != null && defines.length > 0) {
            parts.push(defines);
            if (!defines.endsWith("\n")) {
                parts.push("\n");
            }
        }
        
        // Add source
        parts.push(source);
        
        return parts.join("");
    }
}
