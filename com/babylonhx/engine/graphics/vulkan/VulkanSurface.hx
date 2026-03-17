package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;

/**
 * Abstract Vulkan surface for platform-specific window integration
 */
class VulkanSurface {
    
    protected var _instance:VkInstance;
    protected var _surface:VkSurfaceKHR;
    protected var _created:Bool = false;
    protected var _width:Int;
    protected var _height:Int;
    protected var _platformType:String;
    
    public function new(instance:VkInstance) {
        _instance = instance;
    }
    
    /**
     * Create surface (implemented by platform-specific subclasses)
     */
    public function create():Bool {
        trace("VulkanSurface.create() - Override in platform-specific class");
        return false;
    }
    
    /**
     * Get Vulkan surface handle
     */
    public function getSurface():VkSurfaceKHR {
        return _surface;
    }
    
    /**
     * Check if surface is created
     */
    public function isCreated():Bool {
        return _created;
    }
    
    /**
     * Get surface width
     */
    public function getWidth():Int {
        return _width;
    }
    
    /**
     * Get surface height
     */
    public function getHeight():Int {
        return _height;
    }
    
    /**
     * Get platform type (windows, linux, macos, web)
     */
    public function getPlatformType():String {
        return _platformType;
    }
    
    /**
     * Cleanup surface
     */
    public function dispose():Void {
        if (_created && _surface != null) {
            Vulkan.destroySurfaceKHR(_instance, _surface, null);
            _created = false;
        }
    }
}
