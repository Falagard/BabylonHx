package com.babylonhx.engine.graphics;

/**
 * Interface for GPU buffer abstraction
 * Supports vertex buffers, index buffers, uniform buffers, and storage buffers
 */
interface IGraphicsBuffer {
    /**
     * Bind the buffer to a target location
     * @param target The binding target (GL_ARRAY_BUFFER, GL_ELEMENT_ARRAY_BUFFER, etc.)
     */
    function bind(target:Int):Void;
    
    /**
     * Write data to the buffer
     * @param data The data to write
     * @param offset The offset in the buffer to write to
     */
    function write(data:ArrayBufferView, offset:Int):Void;
    
    /**
     * Update the entire buffer with new data
     * @param data The new data
     */
    function update(data:ArrayBufferView):Void;
    
    /**
     * Get the size of the buffer in bytes
     */
    function getSize():Int;
    
    /**
     * Dispose the buffer and free GPU resources
     */
    function dispose():Void;
}
