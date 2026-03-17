package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;

/**
 * Manages Vulkan swapchain creation and lifecycle with surface integration
 */
class VulkanSwapchain {
    
    private var _backend:VulkanBackend;
    private var _device:VkDevice;
    private var _physicalDevice:VkPhysicalDevice;
    private var _surface:VkSurfaceKHR;
    
    private var _swapchain:VkSwapchainKHR;
    private var _swapchainImages:Array<VkImage> = [];
    private var _swapchainImageViews:Array<VkImageView> = [];
    private var _swapchainFormat:Int;
    private var _swapchainExtent:VkExtent2D;
    private var _presentMode:Int = 0; // VK_PRESENT_MODE_FIFO_KHR
    
    private var _created:Bool = false;
    private var _width:Int;
    private var _height:Int;
    
    public function new(backend:VulkanBackend, device:VkDevice, physicalDevice:VkPhysicalDevice, 
            surface:VkSurfaceKHR, width:Int, height:Int) {
        _backend = backend;
        _device = device;
        _physicalDevice = physicalDevice;
        _surface = surface;
        _width = width;
        _height = height;
        
        _swapchainExtent = cpp.Lib.create(VkExtent2D);
        _swapchainExtent.width = width;
        _swapchainExtent.height = height;
    }
    
    /**
     * Query surface capabilities and select best format
     */
    private function querySwapchainSupport():Bool {
        // Get surface capabilities
        var capabilities = cpp.Lib.create(VkSurfaceCapabilitiesKHR);
        var result = Vulkan.getPhysicalDeviceSurfaceCapabilitiesKHR(_physicalDevice, _surface, 
            Pointer.addressOf(capabilities));
        
        if (result != VK_SUCCESS) {
            trace("Failed to query surface capabilities");
            return false;
        }
        
        // Update extent if needed
        if (capabilities.currentExtent.width != 0xFFFFFFFF) {
            _swapchainExtent = capabilities.currentExtent;
        } else {
            // Clamp to supported range
            _swapchainExtent.width = Math.floor(Math.max(capabilities.minImageExtent.width,
                Math.min(_width, capabilities.maxImageExtent.width)));
            _swapchainExtent.height = Math.floor(Math.max(capabilities.minImageExtent.height,
                Math.min(_height, capabilities.maxImageExtent.height)));
        }
        
        return true;
    }
    
    /**
     * Select best surface format (prefer SRGB)
     */
    private function selectSurfaceFormat():Int {
        var formatCount:Int = 0;
        Vulkan.getPhysicalDeviceSurfaceFormatsKHR(_physicalDevice, _surface, 
            Pointer.addressOf(formatCount), null);
        
        if (formatCount == 0) {
            trace("No surface formats available");
            return 50; // VK_FORMAT_B8G8R8A8_SRGB as fallback
        }
        
        // Prefer SRGB format
        _swapchainFormat = 50; // VK_FORMAT_B8G8R8A8_SRGB
        return _swapchainFormat;
    }
    
    /**
     * Create swapchain with surface and configuration
     */
    public function create():Bool {
        if (!querySwapchainSupport()) {
            trace("Failed to query swapchain support");
            return false;
        }
        
        selectSurfaceFormat();
        
        var createInfo = cpp.Lib.create(VkSwapchainCreateInfoKHR);
        createInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
        createInfo.pNext = null;
        createInfo.flags = 0;
        createInfo.surface = _surface;
        createInfo.minImageCount = 2; // Double buffering
        createInfo.imageFormat = _swapchainFormat;
        createInfo.imageColorSpace = 0; // VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
        createInfo.imageExtent = _swapchainExtent;
        createInfo.imageArrayLayers = 1;
        createInfo.imageUsage = 16; // VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT
        createInfo.imageSharingMode = 0; // VK_SHARING_MODE_EXCLUSIVE
        createInfo.queueFamilyIndexCount = 0;
        createInfo.pQueueFamilyIndices = null;
        createInfo.preTransform = 1; // VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR
        createInfo.compositeAlpha = 1; // VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
        createInfo.presentMode = _presentMode; // VK_PRESENT_MODE_FIFO_KHR
        createInfo.clipped = 1; // true
        createInfo.oldSwapchain = null; // VK_NULL_HANDLE
        
        var result = Vulkan.createSwapchainKHR(_device, Pointer.addressOf(createInfo), 
            null, Pointer.addressOf(_swapchain));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create swapchain: " + result);
            return false;
        }
        
        // Get swapchain images
        if (!getSwapchainImages()) {
            trace("Failed to get swapchain images");
            return false;
        }
        
        // Create image views
        if (!createImageViews()) {
            trace("Failed to create image views");
            return false;
        }
        
        _created = true;
        return true;
    }
    
    /**
     * Get swapchain images from device
     */
    private function getSwapchainImages():Bool {
        var imageCount:Int = 0;
        var result = Vulkan.getSwapchainImagesKHR(_device, _swapchain, 
            Pointer.addressOf(imageCount), null);
        
        if (result != VK_SUCCESS || imageCount == 0) {
            trace("Failed to get swapchain image count");
            return false;
        }
        
        var images = new cpp.NativeArray<VkImage>(imageCount);
        result = Vulkan.getSwapchainImagesKHR(_device, _swapchain, 
            Pointer.addressOf(imageCount), Pointer.arrayElem(images, 0));
        
        if (result != VK_SUCCESS) {
            trace("Failed to get swapchain images");
            return false;
        }
        
        // Convert to Haxe array
        for (i in 0...imageCount) {
            _swapchainImages.push(images[i]);
        }
        
        return true;
    }
    
    /**
     * Create image views for swapchain images
     */
    private function createImageViews():Bool {
        _swapchainImageViews = [];
        
        for (image in _swapchainImages) {
            var viewCreateInfo = cpp.Lib.create(VkImageViewCreateInfo);
            viewCreateInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
            viewCreateInfo.pNext = null;
            viewCreateInfo.flags = 0;
            viewCreateInfo.image = image;
            viewCreateInfo.viewType = 1; // VK_IMAGE_VIEW_TYPE_2D
            viewCreateInfo.format = _swapchainFormat;
            
            var components = cpp.Lib.create(VkComponentMapping);
            components.r = 0; // VK_COMPONENT_SWIZZLE_IDENTITY
            components.g = 0;
            components.b = 0;
            components.a = 0;
            viewCreateInfo.components = components;
            
            var subresourceRange = cpp.Lib.create(VkImageSubresourceRange);
            subresourceRange.aspectMask = 1; // VK_IMAGE_ASPECT_COLOR_BIT
            subresourceRange.baseMipLevel = 0;
            subresourceRange.levelCount = 1;
            subresourceRange.baseArrayLayer = 0;
            subresourceRange.layerCount = 1;
            viewCreateInfo.subresourceRange = subresourceRange;
            
            var imageView:VkImageView = null;
            var result = Vulkan.createImageView(_device, Pointer.addressOf(viewCreateInfo), 
                null, Pointer.addressOf(imageView));
            
            if (result != VK_SUCCESS) {
                trace("Failed to create image view");
                return false;
            }
            
            _swapchainImageViews.push(imageView);
        }
        
        return true;
    }
    
    /**
     * Get swapchain handle
     */
    public function getSwapchain():VkSwapchainKHR {
        return _swapchain;
    }
    
    /**
     * Get swapchain images
     */
    public function getImages():Array<VkImage> {
        return _swapchainImages;
    }
    
    /**
     * Get swapchain image views
     */
    public function getImageViews():Array<VkImageView> {
        return _swapchainImageViews;
    }
    
    /**
     * Get swapchain format
     */
    public function getFormat():Int {
        return _swapchainFormat;
    }
    
    /**
     * Get swapchain extent
     */
    public function getExtent():VkExtent2D {
        return _swapchainExtent;
    }
    
    /**
     * Get image count
     */
    public function getImageCount():Int {
        return _swapchainImages.length;
    }
    
    /**
     * Check if created
     */
    public function isCreated():Bool {
        return _created;
    }
    
    /**
     * Cleanup swapchain resources
     */
    public function dispose():Void {
        if (_created) {
            // Destroy image views
            for (imageView in _swapchainImageViews) {
                Vulkan.destroyImageView(_device, imageView, null);
            }
            _swapchainImageViews = [];
            
            // Destroy swapchain
            Vulkan.destroySwapchainKHR(_device, _swapchain, null);
            _created = false;
        }
    }
}
