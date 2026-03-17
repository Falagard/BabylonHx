package com.babylonhx.engine.graphics;

/**
 * Interface for shader program abstraction
 */
interface IGraphicsProgram {
    /**
     * Bind this program as the active shader program
     */
    function bind():Void;
    
    /**
     * Set a uniform value
     * @param name The uniform variable name
     * @param value The value to set (can be Float, Int, Array, etc.)
     */
    function setUniform(name:String, value:Dynamic):Void;
    
    /**
     * Set a matrix uniform
     * @param name The uniform variable name
     * @param matrix The matrix data (as Float32Array or similar)
     */
    function setMatrixUniform(name:String, matrix:Float32Array):Void;
    
    /**
     * Set a vector uniform
     * @param name The uniform variable name
     * @param x X component
     * @param y Y component (optional)
     * @param z Z component (optional)
     * @param w W component (optional)
     */
    function setVectorUniform(name:String, x:Float, ?y:Float, ?z:Float, ?w:Float):Void;
    
    /**
     * Set vertex attribute pointer
     * @param name The attribute variable name
     * @param buffer The buffer containing the attribute data
     * @param size Number of components per attribute (1-4)
     * @param stride Byte offset between consecutive attributes
     * @param offset Byte offset to the first attribute
     */
    function setAttribute(name:String, buffer:IGraphicsBuffer, size:Int, ?stride:Int, ?offset:Int):Void;
    
    /**
     * Enable a vertex attribute
     * @param name The attribute variable name
     */
    function enableAttribute(name:String):Void;
    
    /**
     * Disable a vertex attribute
     * @param name The attribute variable name
     */
    function disableAttribute(name:String):Void;
    
    /**
     * Get the attribute location
     * @param name The attribute variable name
     */
    function getAttributeLocation(name:String):Int;
    
    /**
     * Get the uniform location
     * @param name The uniform variable name
     */
    function getUniformLocation(name:String):Dynamic;
    
    /**
     * Dispose the program and free GPU resources
     */
    function dispose():Void;
}
