package com.babylonhx.engine;

import com.babylonhx.engine.graphics.*;
import com.babylonhx.engine.graphics.webgl.*;

#if vulkan_support
import com.babylonhx.engine.graphics.vulkan.*;
#end

/**
 * Factory for creating graphics backends based on availability and preferences
 */
class GraphicsBackendFactory {
    /**
     * Create and initialize an appropriate graphics backend
     * @param canvas The rendering canvas
     * @param options Initialization options
     * @return An initialized IGraphicsBackend instance
     */
    public static function createBackend(canvas:Dynamic, ?options:Dynamic):IGraphicsBackend {
        options = options != null ? options : {};
        
        // Check if Vulkan is preferred and available
        #if vulkan_support
        var preferVulkan = Reflect.getProperty(options, "preferVulkan");
        if (preferVulkan == true) {
            try {
                var vulkanBackend = new VulkanBackend();
                vulkanBackend.initialize(canvas);
                trace("[Engine] Using Vulkan graphics backend");
                return vulkanBackend;
            } catch (e:Dynamic) {
                trace("[Engine] Vulkan initialization failed: " + e + ", falling back to WebGL");
            }
        }
        #end
        
        // Default to WebGL backend
        var webglBackend = new WebGLBackend();
        webglBackend.initialize(canvas);
        trace("[Engine] Using WebGL graphics backend");
        return webglBackend;
    }
    
    /**
     * Get list of available backends
     */
    public static function getAvailableBackends():Array<String> {
        var backends = ["WebGL"];
        
        #if vulkan_support
        backends.push("Vulkan");
        #end
        
        return backends;
    }
}
