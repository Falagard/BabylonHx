package com.babylonhx.materials.shaders;

import com.babylonhx.engine.Engine;
import com.babylonhx.utils.GL.WebGL2Context;

/**
 * Shader Compilation Manager
 * Manages shader compilation across different backends
 * Integrates with Effect.hx and Material systems
 */
class ShaderCompilationManager {
    private var engine:Engine;
    private var compiler:IShaderCompiler;
    private var _shaderCache:Map<String, Dynamic>;
    private var _reflectionCache:Map<String, ShaderReflection>;
    
    public function new(engine:Engine) {
        this.engine = engine;
        this._shaderCache = new Map();
        this._reflectionCache = new Map();
        
        // Initialize with appropriate compiler based on backend
        this._initializeCompiler();
    }
    
    /**
     * Compile a shader program from source code
     * @param vertexSource Vertex shader source
     * @param fragmentSource Fragment shader source
     * @param defines Preprocessor defines
     * @param cacheKey Optional cache key for the compiled shader
     */
    public function compileProgram(vertexSource:String, fragmentSource:String, ?defines:String, ?cacheKey:String):Dynamic {
        // Check cache
        if (cacheKey != null && this._shaderCache.exists(cacheKey)) {
            return this._shaderCache.get(cacheKey);
        }
        
        // Compile vertex shader
        var vertexResult = this.compiler.compileVertexShader(vertexSource, defines);
        if (!vertexResult.success) {
            throw "Vertex shader compilation failed: " + vertexResult.error;
        }
        
        // Compile fragment shader
        var fragmentResult = this.compiler.compileFragmentShader(fragmentSource, defines);
        if (!fragmentResult.success) {
            throw "Fragment shader compilation failed: " + fragmentResult.error;
        }
        
        // Link program
        var linkResult = this.compiler.linkProgram(vertexResult.shader, fragmentResult.shader);
        if (!linkResult.success) {
            throw "Program linking failed: " + linkResult.error;
        }
        
        // Cache if key provided
        if (cacheKey != null) {
            this._shaderCache.set(cacheKey, linkResult.program);
        }
        
        return linkResult.program;
    }
    
    /**
     * Get shader reflection information for a compiled program
     * Useful for automatic descriptor set generation and layout inference
     */
    public function getReflection(cacheKey:String, program:Dynamic):ShaderReflection {
        // Check cache
        if (this._reflectionCache.exists(cacheKey)) {
            return this._reflectionCache.get(cacheKey);
        }
        
        // Create reflection (only works for WebGL for now)
        #if (js || purejs)
        var gl:WebGL2Context = cast this.engine.gl;
        var reflection = new ShaderReflection(gl, program);
        this._reflectionCache.set(cacheKey, reflection);
        return reflection;
        #else
        // Return null for non-WebGL platforms (will be available in Vulkan)
        return null;
        #end
    }
    
    /**
     * Get the current shader compiler
     */
    public function getCompiler():IShaderCompiler {
        return this.compiler;
    }
    
    /**
     * Clear all caches
     */
    public function clearCache():Void {
        this._shaderCache.clear();
        this._reflectionCache.clear();
    }
    
    /**
     * Check if a shader feature is supported
     */
    public function supportsFeature(feature:String):Bool {
        return this.compiler.supportsFeature(feature);
    }
    
    // Private methods
    
    private function _initializeCompiler():Void {
        var backendName = "webgl"; // Default to WebGL
        
        // Check if graphics backend is available
        if (this.engine.graphicsBackend != null) {
            var caps = this.engine.graphicsBackend.getCapabilities();
            backendName = caps.getBackendName().toLowerCase();
        }
        
        try {
            this.compiler = ShaderCompilerFactory.createCompiler(backendName, cast this.engine.gl);
        } catch (e:Dynamic) {
            // Fallback to GLSL compiler
            trace("Failed to create shader compiler: " + e + ", using fallback");
            #if (js || purejs)
            this.compiler = new GLSLCompiler(cast this.engine.gl);
            #else
            this.compiler = new GLSLCompiler(this.engine.gl);
            #end
        }
    }
}
