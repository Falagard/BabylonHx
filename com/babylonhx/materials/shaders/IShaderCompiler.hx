package com.babylonhx.materials.shaders;

/**
 * Result of shader compilation
 */
class ShaderCompilationResult {
    public var success:Bool;
    public var shader:Dynamic;
    public var error:String;
    public var type:String; // "vertex" or "fragment"
    public var source:String;
    
    public function new(success:Bool, shader:Dynamic, ?error:String, ?type:String, ?source:String) {
        this.success = success;
        this.shader = shader;
        this.error = error;
        this.type = type;
        this.source = source;
    }
}

/**
 * Result of program linking
 */
class ProgramLinkResult {
    public var success:Bool;
    public var program:Dynamic;
    public var error:String;
    public var vertexShader:Dynamic;
    public var fragmentShader:Dynamic;
    
    public function new(success:Bool, program:Dynamic, ?error:String, ?vertexShader:Dynamic, ?fragmentShader:Dynamic) {
        this.success = success;
        this.program = program;
        this.error = error;
        this.vertexShader = vertexShader;
        this.fragmentShader = fragmentShader;
    }
}

/**
 * Interface for shader compilation abstraction
 * Supports multiple compilation backends (GLSL, SPIRV, etc.)
 */
interface IShaderCompiler {
    /**
     * Compile a vertex shader
     * @param source The shader source code
     * @param defines Shader preprocessor defines (optional)
     * @param version GLSL version (e.g., "100", "300 es", "450")
     */
    function compileVertexShader(source:String, ?defines:String, ?version:String):ShaderCompilationResult;
    
    /**
     * Compile a fragment shader
     * @param source The shader source code
     * @param defines Shader preprocessor defines (optional)
     * @param version GLSL version (e.g., "100", "300 es", "450")
     */
    function compileFragmentShader(source:String, ?defines:String, ?version:String):ShaderCompilationResult;
    
    /**
     * Link a complete program from compiled shaders
     * @param vertexShader Compiled vertex shader
     * @param fragmentShader Compiled fragment shader
     */
    function linkProgram(vertexShader:Dynamic, fragmentShader:Dynamic):ProgramLinkResult;
    
    /**
     * Get shader compiler version/type
     */
    function getVersion():String;
    
    /**
     * Check if a shader feature is supported
     */
    function supportsFeature(feature:String):Bool;
}
