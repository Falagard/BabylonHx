package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;
import cpp.Native;

/**
 * Platform-specific window surface for Vulkan rendering
 */
class VulkanWindowSurface extends VulkanSurface {
    
    #if windows
    private var _hwnd:cpp.Pointer<cpp.Void>;
    private var _hinstance:cpp.Pointer<cpp.Void>;
    #elseif linux
    private var _display:cpp.Pointer<cpp.Void>;
    private var _window:cpp.UInt64;
    #elseif mac
    private var _nsWindow:cpp.Pointer<cpp.Void>;
    private var _nsView:cpp.Pointer<cpp.Void>;
    #end
    
    public function new(instance:VkInstance, width:Int, height:Int) {
        super(instance);
        _width = width;
        _height = height;
        
        #if windows
        _platformType = "windows";
        _hwnd = null;
        _hinstance = null;
        #elseif linux
        _platformType = "linux";
        _display = null;
        _window = 0;
        #elseif mac
        _platformType = "macos";
        _nsWindow = null;
        _nsView = null;
        #else
        _platformType = "unknown";
        #end
    }
    
    /**
     * Windows: Set window handle and instance for surface creation
     */
    #if windows
    public function setWindowHandle(hwnd:cpp.Pointer<cpp.Void>, hinstance:cpp.Pointer<cpp.Void>):VulkanWindowSurface {
        _hwnd = hwnd;
        _hinstance = hinstance;
        return this;
    }
    #end
    
    /**
     * Linux: Set X11 display and window for surface creation
     */
    #if linux
    public function setX11Display(display:cpp.Pointer<cpp.Void>, window:cpp.UInt64):VulkanWindowSurface {
        _display = display;
        _window = window;
        return this;
    }
    #end
    
    /**
     * macOS: Set NSWindow and NSView for surface creation
     */
    #if mac
    public function setMacOSWindow(nsWindow:cpp.Pointer<cpp.Void>, nsView:cpp.Pointer<cpp.Void>):VulkanWindowSurface {
        _nsWindow = nsWindow;
        _nsView = nsView;
        return this;
    }
    #end
    
    /**
     * Create platform-specific Vulkan surface
     */
    public override function create():Bool {
        #if windows
        return createWindowsSurface();
        #elseif linux
        return createLinuxSurface();
        #elseif mac
        return createMacOSSurface();
        #else
        trace("Platform not supported for Vulkan surface creation");
        return false;
        #end
    }
    
    /**
     * Create Windows surface using VK_KHR_win32_surface
     */
    #if windows
    private function createWindowsSurface():Bool {
        if (_hwnd == null || _hinstance == null) {
            trace("Window handle or instance not set for Windows surface");
            return false;
        }
        
        var createInfo = cpp.Lib.create("VkWin32SurfaceCreateInfoKHR");
        untyped __cpp__("createInfo.sType = 1000009000"); // VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR
        untyped __cpp__("createInfo.flags = 0");
        untyped __cpp__("createInfo.hinstance = {0}", _hinstance);
        untyped __cpp__("createInfo.hwnd = {0}", _hwnd);
        
        var result = Vulkan.createWin32SurfaceKHR(_instance, Pointer.addressOf(createInfo), null, Pointer.addressOf(_surface));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create Windows surface: " + result);
            return false;
        }
        
        _created = true;
        return true;
    }
    #end
    
    /**
     * Create Linux/X11 surface using VK_KHR_xcb_surface
     */
    #if linux
    private function createLinuxSurface():Bool {
        if (_display == null || _window == 0) {
            trace("X11 display or window not set for Linux surface");
            return false;
        }
        
        // Try XCB surface first (modern X11)
        return createXcbSurface();
    }
    
    private function createXcbSurface():Bool {
        var createInfo = cpp.Lib.create("VkXcbSurfaceCreateInfoKHR");
        untyped __cpp__("createInfo.sType = 1000005000"); // VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR
        untyped __cpp__("createInfo.flags = 0");
        untyped __cpp__("createInfo.connection = (xcb_connection_t*){0}", _display);
        untyped __cpp__("createInfo.window = (xcb_window_t){0}", _window);
        
        var result = Vulkan.createXcbSurfaceKHR(_instance, Pointer.addressOf(createInfo), null, Pointer.addressOf(_surface));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create XCB surface: " + result);
            return false;
        }
        
        _created = true;
        return true;
    }
    #end
    
    /**
     * Create macOS surface using VK_EXT_metal_surface or MoltenVK
     */
    #if mac
    private function createMacOSSurface():Bool {
        if (_nsView == null) {
            trace("NSView not set for macOS surface");
            return false;
        }
        
        // macOS uses Metal surface (MoltenVK wraps this)
        var createInfo = cpp.Lib.create("VkMetalSurfaceCreateInfoEXT");
        untyped __cpp__("createInfo.sType = 1000217000"); // VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT
        untyped __cpp__("createInfo.flags = 0");
        untyped __cpp__("createInfo.pLayer = (CAMetalLayer*){0}", _nsView);
        
        var result = Vulkan.createMetalSurfaceEXT(_instance, Pointer.addressOf(createInfo), null, Pointer.addressOf(_surface));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create Metal surface: " + result);
            return false;
        }
        
        _created = true;
        return true;
    }
    #end
    
    /**
     * Get platform-specific extension names required for surface creation
     */
    public static function getPlatformExtensions():Array<String> {
        #if windows
        return ["VK_KHR_surface", "VK_KHR_win32_surface"];
        #elseif linux
        return ["VK_KHR_surface", "VK_KHR_xcb_surface"];
        #elseif mac
        return ["VK_KHR_surface", "VK_EXT_metal_surface"];
        #else
        return ["VK_KHR_surface"];
        #end
    }
    
    /**
     * Get the name of the platform extension for surface
     */
    public static function getSurfaceExtensionName():String {
        #if windows
        return "VK_KHR_win32_surface";
        #elseif linux
        return "VK_KHR_xcb_surface";
        #elseif mac
        return "VK_EXT_metal_surface";
        #else
        return "VK_KHR_surface";
        #end
    }
}
