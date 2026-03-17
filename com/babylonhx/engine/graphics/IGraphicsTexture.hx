package com.babylonhx.engine.graphics;

/**
 * Interface for GPU texture abstraction
 */
interface IGraphicsTexture {
    /**
     * Bind the texture to a sampler slot
     * @param slot The texture slot/unit (0-31)
     */
    function bind(slot:Int):Void;
    
    /**
     * Set texture data
     * @param data The texture data (should be in RGBA format)
     * @param width The texture width in pixels
     * @param height The texture height in pixels
     */
    function setData(data:ArrayBufferView, width:Int, height:Int):Void;
    
    /**
     * Get texture width
     */
    function getWidth():Int;
    
    /**
     * Get texture height
     */
    function getHeight():Int;
    
    /**
     * Update a region of the texture
     * @param data The data to update with
     * @param x X offset in pixels
     * @param y Y offset in pixels
     * @param width Width of region to update
     * @param height Height of region to update
     */
    function updateRegion(data:ArrayBufferView, x:Int, y:Int, width:Int, height:Int):Void;
    
    /**
     * Generate mipmaps for the texture
     */
    function generateMipmaps():Void;
    
    /**
     * Dispose the texture and free GPU resources
     */
    function dispose():Void;
}
