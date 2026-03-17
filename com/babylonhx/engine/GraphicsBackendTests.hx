/**
 * GraphicsBackend Integration Test
 * 
 * This file can be used to verify that the graphics abstraction layer
 * is properly initialized and working with the Engine.
 * 
 * Usage:
 * - Include this file in your test runner
 * - Call GraphicsBackendTests.runAll()
 * - Check console output for test results
 */

#if (js || purejs)
import js.Browser;
#end

import com.babylonhx.engine.Engine;
import com.babylonhx.engine.GraphicsBackendFactory;
import com.babylonhx.Scene;

class GraphicsBackendTests {
    
    public static function runAll():Void {
        trace("======================================");
        trace("Graphics Backend Integration Tests");
        trace("======================================");
        
        testBackendFactory();
        testEngineInitialization();
        testAvailableBackends();
        
        trace("======================================");
        trace("Tests Complete");
        trace("======================================");
    }
    
    private static function testBackendFactory():Void {
        trace("\n[Test] GraphicsBackendFactory");
        
        try {
            var backends = GraphicsBackendFactory.getAvailableBackends();
            trace("  ✓ Available backends: " + backends.toString());
            
            if (backends.length == 0) {
                trace("  ✗ No backends available!");
            } else {
                trace("  ✓ At least one backend is available");
            }
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
        }
    }
    
    private static function testEngineInitialization():Void {
        trace("\n[Test] Engine with Graphics Backend");
        
        try {
            #if (js || purejs)
            var canvas:Dynamic = Browser.document.getElementById("renderCanvas");
            if (canvas == null) {
                trace("  ⚠ No canvas element found - skipping engine test");
                return;
            }
            
            var options = { stencil: true };
            var engine = new Engine(canvas, null, false, options);
            
            if (engine.graphicsBackend != null) {
                trace("  ✓ Graphics backend initialized");
                
                var caps = engine.graphicsBackend.getCapabilities();
                trace("    Backend Name: " + caps.getBackendName());
                trace("    Backend Version: " + caps.getBackendVersion());
                trace("    Max Texture Size: " + caps.getMaxTextureSize());
                trace("    Max Texture Units: " + caps.getMaxTextureUnits());
            } else {
                trace("  ⚠ Graphics backend is null (optional)");
                trace("  ✓ Engine still initialized with direct GL calls");
            }
            
            // Clean up
            engine.dispose();
            trace("  ✓ Engine disposed successfully");
            #else
            trace("  ⚠ Skipped (non-JS platform)");
            #end
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
        }
    }
    
    private static function testAvailableBackends():Void {
        trace("\n[Test] Conditional Backend Compilation");
        
        #if vulkan_support
        trace("  ✓ Vulkan support enabled (compiled with -D vulkan_support)");
        #else
        trace("  ℹ Vulkan support disabled (standard build)");
        #end
        
        trace("  ✓ WebGL support always enabled");
    }
}
