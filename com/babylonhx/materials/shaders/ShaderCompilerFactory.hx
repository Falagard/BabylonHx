package com.babylonhx.materials.shaders;

import com.babylonhx.utils.GL.WebGL2Context;

/**
 * Factory for creating shader compilers based on backend
 */
class ShaderCompilerFactory {
    private static var _compilers:Map<String, IShaderCompiler> = new Map();
    
    /**
     * Create or get a shader compiler for the specified backend
     * @param backend The backend name ("webgl", "vulkan", etc.)
     * @param gl The WebGL context (required for WebGL backend)
     */
    public static function createCompiler(backend:String, ?gl:WebGL2Context):IShaderCompiler {
        var key = backend.toLowerCase();
        
        if (_compilers.exists(key)) {
            return _compilers.get(key);
        }
        
        var compiler:IShaderCompiler = null;
        
        switch(key) {
            case "webgl":
                if (gl == null) {
                    throw "WebGL backend requires a WebGL context";
                }
                compiler = new GLSLCompiler(gl);
                
            #if vulkan_support
            case "vulkan":
                compiler = new SPIRVCompiler();
            #end
                
            default:
                throw "Unknown shader compiler backend: " + backend;
        }
        
        if (compiler != null) {
            _compilers.set(key, compiler);
        }
        
        return compiler;
    }
    
    /**
     * Get GLSL compiler directly
     */
    public static function getGLSLCompiler(gl:WebGL2Context):GLSLCompiler {
        return new GLSLCompiler(gl);
    }
    
    /**
     * Get SPIRV compiler directly (Phase 4)
     */
    #if vulkan_support
    public static function getSPIRVCompiler():SPIRVCompiler {
        return new SPIRVCompiler();
    }
    #end
    
    /**
     * Clear cached compilers
     */
    public static function clearCache():Void {
        _compilers.clear();
    }
}
