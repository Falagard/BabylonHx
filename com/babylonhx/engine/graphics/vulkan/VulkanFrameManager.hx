package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;

/**
 * Manages frame synchronization and GPU submission
 */
class VulkanFrameManager {
    
    private var _backend:VulkanBackend;
    private var _commandBuffers:Array<VulkanCommandBuffer> = [];
    private var _fences:Array<VkFence> = [];
    private var _presentSemaphores:Array<VkSemaphore> = [];
    private var _renderSemaphores:Array<VkSemaphore> = [];
    private var _frameIndex:Int = 0;
    private var _maxFramesInFlight:Int;
    
    private var _imageAvailableSemaphores:Array<VkSemaphore> = [];
    private var _renderFinishedSemaphores:Array<VkSemaphore> = [];
    private var _inFlightFences:Array<VkFence> = [];
    private var _imagesInFlight:Array<VkFence> = [];
    
    public function new(backend:VulkanBackend, maxFramesInFlight:Int = 2) {
        _backend = backend;
        _maxFramesInFlight = maxFramesInFlight;
    }
    
    /**
     * Initialize synchronization primitives
     */
    public function initialize():Bool {
        // Get swapchain image count
        var swapchainImages = _backend.getSwapchainImages();
        if (swapchainImages == null || swapchainImages.length == 0) {
            trace("No swapchain images available");
            return false;
        }
        
        var imageCount = swapchainImages.length;
        
        // Create semaphores and fences for each frame in flight
        for (i in 0..._maxFramesInFlight) {
            var imageSemaphore = createSemaphore();
            var renderSemaphore = createSemaphore();
            var fence = createFence(true); // Create signaled
            
            if (imageSemaphore == null || renderSemaphore == null || fence == null) {
                trace("Failed to create synchronization primitives");
                return false;
            }
            
            _imageAvailableSemaphores.push(imageSemaphore);
            _renderFinishedSemaphores.push(renderSemaphore);
            _inFlightFences.push(fence);
        }
        
        // Initialize images in flight fences (one per swapchain image)
        for (i in 0...imageCount) {
            _imagesInFlight.push(null);
        }
        
        return true;
    }
    
    /**
     * Create synchronization semaphore
     */
    private function createSemaphore():VkSemaphore {
        var createInfo = cpp.Lib.create(VkSemaphoreCreateInfo);
        createInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;
        createInfo.pNext = null;
        createInfo.flags = 0;
        
        var semaphore:VkSemaphore = null;
        var result = Vulkan.createSemaphore(_backend.getDevice(), Pointer.addressOf(createInfo), null, Pointer.addressOf(semaphore));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create semaphore");
            return null;
        }
        
        return semaphore;
    }
    
    /**
     * Create fence
     */
    private function createFence(signaled:Bool = false):VkFence {
        var createInfo = cpp.Lib.create(VkFenceCreateInfo);
        createInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
        createInfo.pNext = null;
        createInfo.flags = signaled ? 1 : 0; // VK_FENCE_CREATE_SIGNALED_BIT = 1
        
        var fence:VkFence = null;
        var result = Vulkan.createFence(_backend.getDevice(), Pointer.addressOf(createInfo), null, Pointer.addressOf(fence));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create fence");
            return null;
        }
        
        return fence;
    }
    
    /**
     * Acquire next swapchain image
     */
    public function acquireNextImage():Int {
        var device = _backend.getDevice();
        var swapchain = _backend.getSwapchain();
        var imageAvailableSemaphore = _imageAvailableSemaphores[_frameIndex % _maxFramesInFlight];
        
        var imageIndex:Int = 0;
        var result = Vulkan.acquireNextImageKHR(device, swapchain, 
            0xFFFFFFFFFFFFFFFF, // Timeout: ~infinite
            imageAvailableSemaphore, null, Pointer.addressOf(imageIndex));
        
        if (result != VK_SUCCESS) {
            trace("Failed to acquire next image: " + result);
            return -1;
        }
        
        // Check if image is in flight, wait for fence if so
        if (_imagesInFlight[imageIndex] != null) {
            Vulkan.waitForFences(device, 1, Pointer.addressOf(_imagesInFlight[imageIndex]), true, 0xFFFFFFFFFFFFFFFF);
        }
        
        // Mark image as in flight
        _imagesInFlight[imageIndex] = _inFlightFences[_frameIndex % _maxFramesInFlight];
        
        return imageIndex;
    }
    
    /**
     * Submit command buffer for execution
     */
    public function submitCommandBuffer(commandBuffer:VulkanCommandBuffer, imageIndex:Int):Bool {
        var device = _backend.getDevice();
        var queue = _backend.getGraphicsQueue();
        
        var currentFrame = _frameIndex % _maxFramesInFlight;
        var waitSemaphore = _imageAvailableSemaphores[currentFrame];
        var signalSemaphore = _renderFinishedSemaphores[currentFrame];
        var fence = _inFlightFences[currentFrame];
        
        var vkCommandBuffer = commandBuffer.getVkCommandBuffer();
        
        // Wait for previous frame fence
        Vulkan.waitForFences(device, 1, Pointer.addressOf(fence), true, 0xFFFFFFFFFFFFFFFF);
        Vulkan.resetFences(device, 1, Pointer.addressOf(fence));
        
        // Create submit info
        var submitInfo = cpp.Lib.create(VkSubmitInfo);
        submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
        submitInfo.pNext = null;
        submitInfo.waitSemaphoreCount = 1;
        submitInfo.pWaitSemaphores = Pointer.addressOf(waitSemaphore);
        
        var waitStage = cpp.Lib.create(VkPipelineStageFlags);
        waitStage = 1; // VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
        submitInfo.pWaitDstStageMask = Pointer.addressOf(waitStage);
        
        submitInfo.commandBufferCount = 1;
        submitInfo.pCommandBuffers = Pointer.addressOf(vkCommandBuffer);
        submitInfo.signalSemaphoreCount = 1;
        submitInfo.pSignalSemaphores = Pointer.addressOf(signalSemaphore);
        
        var result = Vulkan.queueSubmit(queue, 1, Pointer.addressOf(submitInfo), fence);
        
        if (result != VK_SUCCESS) {
            trace("Failed to submit command buffer: " + result);
            return false;
        }
        
        return true;
    }
    
    /**
     * Present image to display
     */
    public function presentImage(imageIndex:Int):Bool {
        var device = _backend.getDevice();
        var queue = _backend.getPresentQueue();
        var swapchain = _backend.getSwapchain();
        
        var currentFrame = _frameIndex % _maxFramesInFlight;
        var renderFinishedSemaphore = _renderFinishedSemaphores[currentFrame];
        
        var presentInfo = cpp.Lib.create(VkPresentInfoKHR);
        presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
        presentInfo.pNext = null;
        presentInfo.waitSemaphoreCount = 1;
        presentInfo.pWaitSemaphores = Pointer.addressOf(renderFinishedSemaphore);
        presentInfo.swapchainCount = 1;
        presentInfo.pSwapchains = Pointer.addressOf(swapchain);
        presentInfo.pImageIndices = Pointer.addressOf(imageIndex);
        presentInfo.pResults = null;
        
        var result = Vulkan.queuePresentKHR(queue, Pointer.addressOf(presentInfo));
        
        if (result != VK_SUCCESS && result != 1000001004) { // Ignore VK_SUBOPTIMAL_KHR
            trace("Failed to present image: " + result);
            return false;
        }
        
        _frameIndex++;
        return true;
    }
    
    /**
     * Wait for device to finish all work
     */
    public function waitForDevice():Bool {
        var result = Vulkan.deviceWaitIdle(_backend.getDevice());
        return result == VK_SUCCESS;
    }
    
    /**
     * Create command buffer for this frame
     */
    public function createCommandBuffer():VulkanCommandBuffer {
        var commandPool = _backend.getCommandPool();
        var device = _backend.getDevice();
        
        var allocInfo = cpp.Lib.create(VkCommandBufferAllocateInfo);
        allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
        allocInfo.pNext = null;
        allocInfo.commandPool = commandPool;
        allocInfo.level = 0; // VK_COMMAND_BUFFER_LEVEL_PRIMARY
        allocInfo.commandBufferCount = 1;
        
        var vkCommandBuffer:VkCommandBuffer = null;
        var result = Vulkan.allocateCommandBuffers(device, Pointer.addressOf(allocInfo), Pointer.addressOf(vkCommandBuffer));
        
        if (result != VK_SUCCESS) {
            trace("Failed to allocate command buffer");
            return null;
        }
        
        var commandBuffer = new VulkanCommandBuffer(this._backend, vkCommandBuffer);
        _commandBuffers.push(commandBuffer);
        
        return commandBuffer;
    }
    
    /**
     * Reset command buffers for next frame
     */
    public function resetCommandBuffers():Bool {
        var result = Vulkan.resetCommandPool(_backend.getDevice(), _backend.getCommandPool(), 0);
        return result == VK_SUCCESS;
    }
    
    /**
     * Get current frame index
     */
    public function getCurrentFrameIndex():Int {
        return _frameIndex;
    }
    
    /**
     * Get max frames in flight
     */
    public function getMaxFramesInFlight():Int {
        return _maxFramesInFlight;
    }
    
    /**
     * Cleanup resources
     */
    public function dispose():Void {
        waitForDevice();
        
        var device = _backend.getDevice();
        
        for (semaphore in _imageAvailableSemaphores) {
            Vulkan.destroySemaphore(device, semaphore, null);
        }
        _imageAvailableSemaphores = [];
        
        for (semaphore in _renderFinishedSemaphores) {
            Vulkan.destroySemaphore(device, semaphore, null);
        }
        _renderFinishedSemaphores = [];
        
        for (fence in _inFlightFences) {
            Vulkan.destroyFence(device, fence, null);
        }
        _inFlightFences = [];
        
        _commandBuffers = [];
        _imagesInFlight = [];
    }
}
