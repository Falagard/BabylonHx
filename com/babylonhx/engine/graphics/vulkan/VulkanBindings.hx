package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.vulkan.VulkanTypes;

/**
 * Vulkan C API FFI bindings.
 * This provides access to core Vulkan functions for instance, device, and command management.
 */

extern class Vulkan {
    // Instance functions
    @:native("vkCreateInstance")
    static function createInstance(
        pCreateInfo:cpp.Pointer<VkInstanceCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pInstance:cpp.Pointer<VkInstance>
    ):VkResult;

    @:native("vkDestroyInstance")
    static function destroyInstance(
        instance:VkInstance,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkEnumeratePhysicalDevices")
    static function enumeratePhysicalDevices(
        instance:VkInstance,
        pPhysicalDeviceCount:cpp.Pointer<Int>,
        pPhysicalDevices:cpp.Pointer<VkPhysicalDevice>
    ):VkResult;

    @:native("vkGetPhysicalDeviceProperties")
    static function getPhysicalDeviceProperties(
        physicalDevice:VkPhysicalDevice,
        pProperties:cpp.Pointer<VkPhysicalDeviceProperties>
    ):Void;

    @:native("vkGetPhysicalDeviceMemoryProperties")
    static function getPhysicalDeviceMemoryProperties(
        physicalDevice:VkPhysicalDevice,
        pMemoryProperties:cpp.Pointer<VkPhysicalDeviceMemoryProperties>
    ):Void;

    @:native("vkGetPhysicalDeviceQueueFamilyProperties")
    static function getPhysicalDeviceQueueFamilyProperties(
        physicalDevice:VkPhysicalDevice,
        pQueueFamilyPropertyCount:cpp.Pointer<Int>,
        pQueueFamilyProperties:cpp.Pointer<VkQueueFamilyProperties>
    ):Void;

    @:native("vkCreateDevice")
    static function createDevice(
        physicalDevice:VkPhysicalDevice,
        pCreateInfo:cpp.Pointer<VkDeviceCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pDevice:cpp.Pointer<VkDevice>
    ):VkResult;

    @:native("vkDestroyDevice")
    static function destroyDevice(
        device:VkDevice,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkGetDeviceQueue")
    static function getDeviceQueue(
        device:VkDevice,
        queueFamilyIndex:Int,
        queueIndex:Int,
        pQueue:cpp.Pointer<VkQueue>
    ):Void;

    // Buffer operations
    @:native("vkCreateBuffer")
    static function createBuffer(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkBufferCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pBuffer:cpp.Pointer<VkBuffer>
    ):VkResult;

    @:native("vkDestroyBuffer")
    static function destroyBuffer(
        device:VkDevice,
        buffer:VkBuffer,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkGetBufferMemoryRequirements")
    static function getBufferMemoryRequirements(
        device:VkDevice,
        buffer:VkBuffer,
        pMemoryRequirements:cpp.Pointer<VkMemoryRequirements>
    ):Void;

    @:native("vkBindBufferMemory")
    static function bindBufferMemory(
        device:VkDevice,
        buffer:VkBuffer,
        memory:VkDeviceMemory,
        memoryOffset:VkDeviceSize
    ):VkResult;

    // Image operations
    @:native("vkCreateImage")
    static function createImage(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkImageCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pImage:cpp.Pointer<VkImage>
    ):VkResult;

    @:native("vkDestroyImage")
    static function destroyImage(
        device:VkDevice,
        image:VkImage,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkGetImageMemoryRequirements")
    static function getImageMemoryRequirements(
        device:VkDevice,
        image:VkImage,
        pMemoryRequirements:cpp.Pointer<VkMemoryRequirements>
    ):Void;

    @:native("vkBindImageMemory")
    static function bindImageMemory(
        device:VkDevice,
        image:VkImage,
        memory:VkDeviceMemory,
        memoryOffset:VkDeviceSize
    ):VkResult;

    @:native("vkCreateImageView")
    static function createImageView(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkImageViewCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pView:cpp.Pointer<VkImageView>
    ):VkResult;

    @:native("vkDestroyImageView")
    static function destroyImageView(
        device:VkDevice,
        imageView:VkImageView,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    // Memory operations
    @:native("vkAllocateMemory")
    static function allocateMemory(
        device:VkDevice,
        pAllocateInfo:cpp.Pointer<VkMemoryAllocateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pMemory:cpp.Pointer<VkDeviceMemory>
    ):VkResult;

    @:native("vkFreeMemory")
    static function freeMemory(
        device:VkDevice,
        memory:VkDeviceMemory,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkMapMemory")
    static function mapMemory(
        device:VkDevice,
        memory:VkDeviceMemory,
        offset:VkDeviceSize,
        size:VkDeviceSize,
        flags:Int,
        ppData:cpp.Pointer<cpp.Pointer<Void>>
    ):VkResult;

    @:native("vkUnmapMemory")
    static function unmapMemory(
        device:VkDevice,
        memory:VkDeviceMemory
    ):Void;

    // Shader operations
    @:native("vkCreateShaderModule")
    static function createShaderModule(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkShaderModuleCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pShaderModule:cpp.Pointer<VkShaderModule>
    ):VkResult;

    @:native("vkDestroyShaderModule")
    static function destroyShaderModule(
        device:VkDevice,
        shaderModule:VkShaderModule,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    // Command buffer operations
    @:native("vkCreateCommandPool")
    static function createCommandPool(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkCommandPoolCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pCommandPool:cpp.Pointer<VkCommandPool>
    ):VkResult;

    @:native("vkDestroyCommandPool")
    static function destroyCommandPool(
        device:VkDevice,
        commandPool:VkCommandPool,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkResetCommandPool")
    static function resetCommandPool(
        device:VkDevice,
        commandPool:VkCommandPool,
        flags:Int
    ):VkResult;

    @:native("vkAllocateCommandBuffers")
    static function allocateCommandBuffers(
        device:VkDevice,
        pAllocateInfo:cpp.Pointer<VkCommandBufferAllocateInfo>,
        pCommandBuffers:cpp.Pointer<VkCommandBuffer>
    ):VkResult;

    @:native("vkFreeCommandBuffers")
    static function freeCommandBuffers(
        device:VkDevice,
        commandPool:VkCommandPool,
        commandBufferCount:Int,
        pCommandBuffers:cpp.Pointer<VkCommandBuffer>
    ):Void;

    @:native("vkBeginCommandBuffer")
    static function beginCommandBuffer(
        commandBuffer:VkCommandBuffer,
        pBeginInfo:cpp.Pointer<VkCommandBufferBeginInfo>
    ):VkResult;

    @:native("vkEndCommandBuffer")
    static function endCommandBuffer(
        commandBuffer:VkCommandBuffer
    ):VkResult;

    @:native("vkResetCommandBuffer")
    static function resetCommandBuffer(
        commandBuffer:VkCommandBuffer,
        flags:Int
    ):VkResult;

    @:native("vkCmdBindPipeline")
    static function cmdBindPipeline(
        commandBuffer:VkCommandBuffer,
        pipelineBindPoint:Int,
        pipeline:VkPipeline
    ):Void;

    @:native("vkCmdSetViewport")
    static function cmdSetViewport(
        commandBuffer:VkCommandBuffer,
        firstViewport:Int,
        viewportCount:Int,
        pViewports:cpp.Pointer<VkViewport>
    ):Void;

    @:native("vkCmdSetScissor")
    static function cmdSetScissor(
        commandBuffer:VkCommandBuffer,
        firstScissor:Int,
        scissorCount:Int,
        pScissors:cpp.Pointer<VkRect2D>
    ):Void;

    @:native("vkCmdClearColorImage")
    static function cmdClearColorImage(
        commandBuffer:VkCommandBuffer,
        image:VkImage,
        imageLayout:Int,
        pColor:cpp.Pointer<VkClearColorValue>,
        rangeCount:Int,
        pRanges:cpp.Pointer<VkImageSubresourceRange>
    ):Void;

    @:native("vkCmdDraw")
    static function cmdDraw(
        commandBuffer:VkCommandBuffer,
        vertexCount:Int,
        instanceCount:Int,
        firstVertex:Int,
        firstInstance:Int
    ):Void;

    @:native("vkCmdDrawIndexed")
    static function cmdDrawIndexed(
        commandBuffer:VkCommandBuffer,
        indexCount:Int,
        instanceCount:Int,
        firstIndex:Int,
        vertexOffset:Int,
        firstInstance:Int
    ):Void;

    @:native("vkCmdBindVertexBuffers")
    static function cmdBindVertexBuffers(
        commandBuffer:VkCommandBuffer,
        firstBinding:Int,
        bindingCount:Int,
        pBuffers:cpp.Pointer<VkBuffer>,
        pOffsets:cpp.Pointer<VkDeviceSize>
    ):Void;

    @:native("vkCmdBindIndexBuffer")
    static function cmdBindIndexBuffer(
        commandBuffer:VkCommandBuffer,
        buffer:VkBuffer,
        offset:VkDeviceSize,
        indexType:Int
    ):Void;

    @:native("vkCmdBindDescriptorSets")
    static function cmdBindDescriptorSets(
        commandBuffer:VkCommandBuffer,
        pipelineBindPoint:Int,
        layout:VkPipelineLayout,
        firstSet:Int,
        descriptorSetCount:Int,
        pDescriptorSets:cpp.Pointer<VkDescriptorSet>,
        dynamicOffsetCount:Int,
        pDynamicOffsets:cpp.Pointer<Int>
    ):Void;

    @:native("vkCmdPushConstants")
    static function cmdPushConstants(
        commandBuffer:VkCommandBuffer,
        layout:VkPipelineLayout,
        stageFlags:Int,
        offset:Int,
        size:Int,
        pValues:cpp.Pointer<Void>
    ):Void;

    // Pipeline operations
    @:native("vkCreateGraphicsPipelines")
    static function createGraphicsPipelines(
        device:VkDevice,
        pipelineCache:VkPipelineCache,
        createInfoCount:Int,
        pCreateInfos:cpp.Pointer<VkGraphicsPipelineCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pPipelines:cpp.Pointer<VkPipeline>
    ):VkResult;

    @:native("vkDestroyPipeline")
    static function destroyPipeline(
        device:VkDevice,
        pipeline:VkPipeline,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkCreatePipelineLayout")
    static function createPipelineLayout(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkPipelineLayoutCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pPipelineLayout:cpp.Pointer<VkPipelineLayout>
    ):VkResult;

    @:native("vkDestroyPipelineLayout")
    static function destroyPipelineLayout(
        device:VkDevice,
        pipelineLayout:VkPipelineLayout,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    // Descriptor set operations
    @:native("vkCreateDescriptorSetLayout")
    static function createDescriptorSetLayout(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkDescriptorSetLayoutCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pSetLayout:cpp.Pointer<VkDescriptorSetLayout>
    ):VkResult;

    @:native("vkDestroyDescriptorSetLayout")
    static function destroyDescriptorSetLayout(
        device:VkDevice,
        descriptorSetLayout:VkDescriptorSetLayout,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkCreateDescriptorPool")
    static function createDescriptorPool(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkDescriptorPoolCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pDescriptorPool:cpp.Pointer<VkDescriptorPool>
    ):VkResult;

    @:native("vkDestroyDescriptorPool")
    static function destroyDescriptorPool(
        device:VkDevice,
        descriptorPool:VkDescriptorPool,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkAllocateDescriptorSets")
    static function allocateDescriptorSets(
        device:VkDevice,
        pAllocateInfo:cpp.Pointer<VkDescriptorSetAllocateInfo>,
        pDescriptorSets:cpp.Pointer<VkDescriptorSet>
    ):VkResult;

    @:native("vkFreeDescriptorSets")
    static function freeDescriptorSets(
        device:VkDevice,
        descriptorPool:VkDescriptorPool,
        descriptorSetCount:Int,
        pDescriptorSets:cpp.Pointer<VkDescriptorSet>
    ):VkResult;

    @:native("vkUpdateDescriptorSets")
    static function updateDescriptorSets(
        device:VkDevice,
        descriptorWriteCount:Int,
        pDescriptorWrites:cpp.Pointer<VkWriteDescriptorSet>,
        descriptorCopyCount:Int,
        pDescriptorCopies:cpp.Pointer<VkCopyDescriptorSet>
    ):Void;

    // Sampler operations
    @:native("vkCreateSampler")
    static function createSampler(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkSamplerCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pSampler:cpp.Pointer<VkSampler>
    ):VkResult;

    @:native("vkDestroySampler")
    static function destroySampler(
        device:VkDevice,
        sampler:VkSampler,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    // Rendering operations (render pass and framebuffer)
    @:native("vkCreateRenderPass")
    static function createRenderPass(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkRenderPassCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pRenderPass:cpp.Pointer<VkRenderPass>
    ):VkResult;

    @:native("vkDestroyRenderPass")
    static function destroyRenderPass(
        device:VkDevice,
        renderPass:VkRenderPass,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkCreateFramebuffer")
    static function createFramebuffer(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkFramebufferCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pFramebuffer:cpp.Pointer<VkFramebuffer>
    ):VkResult;

    @:native("vkDestroyFramebuffer")
    static function destroyFramebuffer(
        device:VkDevice,
        framebuffer:VkFramebuffer,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkCmdBeginRenderPass")
    static function cmdBeginRenderPass(
        commandBuffer:VkCommandBuffer,
        pRenderPassBegin:cpp.Pointer<VkRenderPassBeginInfo>,
        contents:Int
    ):Void;

    @:native("vkCmdEndRenderPass")
    static function cmdEndRenderPass(
        commandBuffer:VkCommandBuffer
    ):Void;

    // Synchronization
    @:native("vkCreateFence")
    static function createFence(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkFenceCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pFence:cpp.Pointer<VkFence>
    ):VkResult;

    @:native("vkDestroyFence")
    static function destroyFence(
        device:VkDevice,
        fence:VkFence,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkWaitForFences")
    static function waitForFences(
        device:VkDevice,
        fenceCount:Int,
        pFences:cpp.Pointer<VkFence>,
        waitAll:Int,
        timeout:Int64
    ):VkResult;

    @:native("vkResetFences")
    static function resetFences(
        device:VkDevice,
        fenceCount:Int,
        pFences:cpp.Pointer<VkFence>
    ):VkResult;

    @:native("vkCreateSemaphore")
    static function createSemaphore(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkSemaphoreCreateInfo>,
        pAllocator:cpp.Pointer<Void>,
        pSemaphore:cpp.Pointer<VkSemaphore>
    ):VkResult;

    @:native("vkDestroySemaphore")
    static function destroySemaphore(
        device:VkDevice,
        semaphore:VkSemaphore,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    // Queue submission
    @:native("vkQueueSubmit")
    static function queueSubmit(
        queue:VkQueue,
        submitCount:Int,
        pSubmits:cpp.Pointer<VkSubmitInfo>,
        fence:VkFence
    ):VkResult;

    @:native("vkQueueWaitIdle")
    static function queueWaitIdle(
        queue:VkQueue
    ):VkResult;

    @:native("vkDeviceWaitIdle")
    static function deviceWaitIdle(
        device:VkDevice
    ):VkResult;

    // Swapchain (KHR extension)
    @:native("vkCreateSwapchainKHR")
    static function createSwapchainKHR(
        device:VkDevice,
        pCreateInfo:cpp.Pointer<VkSwapchainCreateInfoKHR>,
        pAllocator:cpp.Pointer<Void>,
        pSwapchain:cpp.Pointer<VkSwapchainKHR>
    ):VkResult;

    @:native("vkDestroySwapchainKHR")
    static function destroySwapchainKHR(
        device:VkDevice,
        swapchain:VkSwapchainKHR,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkGetSwapchainImagesKHR")
    static function getSwapchainImagesKHR(
        device:VkDevice,
        swapchain:VkSwapchainKHR,
        pSwapchainImageCount:cpp.Pointer<Int>,
        pSwapchainImages:cpp.Pointer<VkImage>
    ):VkResult;

    @:native("vkAcquireNextImageKHR")
    static function acquireNextImageKHR(
        device:VkDevice,
        swapchain:VkSwapchainKHR,
        timeout:Int64,
        semaphore:VkSemaphore,
        fence:VkFence,
        pImageIndex:cpp.Pointer<Int>
    ):VkResult;

    @:native("vkQueuePresentKHR")
    static function queuePresentKHR(
        queue:VkQueue,
        pPresentInfo:cpp.Pointer<VkPresentInfoKHR>
    ):VkResult;

    // Surface (KHR extension)
    @:native("vkDestroySurfaceKHR")
    static function destroySurfaceKHR(
        instance:VkInstance,
        surface:VkSurfaceKHR,
        pAllocator:cpp.Pointer<Void>
    ):Void;

    @:native("vkGetPhysicalDeviceSurfaceSupportKHR")
    static function getPhysicalDeviceSurfaceSupportKHR(
        physicalDevice:VkPhysicalDevice,
        queueFamilyIndex:Int,
        surface:VkSurfaceKHR,
        pSupported:cpp.Pointer<Int>
    ):VkResult;

    @:native("vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
    static function getPhysicalDeviceSurfaceCapabilitiesKHR(
        physicalDevice:VkPhysicalDevice,
        surface:VkSurfaceKHR,
        pSurfaceCapabilities:cpp.Pointer<VkSurfaceCapabilitiesKHR>
    ):VkResult;

    @:native("vkGetPhysicalDeviceSurfaceFormatsKHR")
    static function getPhysicalDeviceSurfaceFormatsKHR(
        physicalDevice:VkPhysicalDevice,
        surface:VkSurfaceKHR,
        pSurfaceFormatCount:cpp.Pointer<Int>,
        pSurfaceFormats:cpp.Pointer<VkSurfaceFormatKHR>
    ):VkResult;

    @:native("vkGetPhysicalDeviceSurfacePresentModesKHR")
    static function getPhysicalDeviceSurfacePresentModesKHR(
        physicalDevice:VkPhysicalDevice,
        surface:VkSurfaceKHR,
        pPresentModeCount:cpp.Pointer<Int>,
        pPresentModes:cpp.Pointer<Int>
    ):VkResult;

    // Platform-specific surface creation (KHR/EXT extensions)
    #if windows
    @:native("vkCreateWin32SurfaceKHR")
    static function createWin32SurfaceKHR(
        instance:VkInstance,
        pCreateInfo:cpp.Pointer<Void>,
        pAllocator:cpp.Pointer<Void>,
        pSurface:cpp.Pointer<VkSurfaceKHR>
    ):VkResult;
    #end

    #if linux
    @:native("vkCreateXcbSurfaceKHR")
    static function createXcbSurfaceKHR(
        instance:VkInstance,
        pCreateInfo:cpp.Pointer<Void>,
        pAllocator:cpp.Pointer<Void>,
        pSurface:cpp.Pointer<VkSurfaceKHR>
    ):VkResult;

    @:native("vkCreateWaylandSurfaceKHR")
    static function createWaylandSurfaceKHR(
        instance:VkInstance,
        pCreateInfo:cpp.Pointer<Void>,
        pAllocator:cpp.Pointer<Void>,
        pSurface:cpp.Pointer<VkSurfaceKHR>
    ):VkResult;
    #end

    #if mac
    @:native("vkCreateMetalSurfaceEXT")
    static function createMetalSurfaceEXT(
        instance:VkInstance,
        pCreateInfo:cpp.Pointer<Void>,
        pAllocator:cpp.Pointer<Void>,
        pSurface:cpp.Pointer<VkSurfaceKHR>
    ):VkResult;
    #end
}

// Additional KHR extension structures needed for Vulkan bindings

@:include("vulkan/vulkan.h")
@:native("VkSurfaceCapabilitiesKHR")
extern class VkSurfaceCapabilitiesKHR {
    var minImageCount:Int;
    var maxImageCount:Int;
    var currentExtent:VkExtent2D;
    var minImageExtent:VkExtent2D;
    var maxImageExtent:VkExtent2D;
    var maxImageArrayLayers:Int;
    var supportedTransforms:Int;
    var currentTransform:Int;
    var supportedCompositeAlpha:Int;
    var supportedUsageFlags:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkSurfaceFormatKHR")
extern class VkSurfaceFormatKHR {
    var format:Int;
    var colorSpace:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkSwapchainCreateInfoKHR")
extern class VkSwapchainCreateInfoKHR {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var surface:VkSurfaceKHR;
    var minImageCount:Int;
    var imageFormat:Int;
    var imageColorSpace:Int;
    var imageExtent:VkExtent2D;
    var imageArrayLayers:Int;
    var imageUsage:Int;
    var imageSharingMode:Int;
    var queueFamilyIndexCount:Int;
    var pQueueFamilyIndices:cpp.Pointer<Int>;
    var preTransform:Int;
    var compositeAlpha:Int;
    var presentMode:Int;
    var clipped:Int;
    var oldSwapchain:VkSwapchainKHR;
}

@:include("vulkan/vulkan.h")
@:native("VkPresentInfoKHR")
extern class VkPresentInfoKHR {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var waitSemaphoreCount:Int;
    var pWaitSemaphores:cpp.Pointer<VkSemaphore>;
    var swapchainCount:Int;
    var pSwapchains:cpp.Pointer<VkSwapchainKHR>;
    var pImageIndices:cpp.Pointer<Int>;
    var pResults:cpp.Pointer<VkResult>;
}

@:include("vulkan/vulkan.h")
@:native("VkSubmitInfo")
extern class VkSubmitInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var waitSemaphoreCount:Int;
    var pWaitSemaphores:cpp.Pointer<VkSemaphore>;
    var pWaitDstStageMask:cpp.Pointer<Int>;
    var commandBufferCount:Int;
    var pCommandBuffers:cpp.Pointer<VkCommandBuffer>;
    var signalSemaphoreCount:Int;
    var pSignalSemaphores:cpp.Pointer<VkSemaphore>;
}

@:include("vulkan/vulkan.h")
@:native("VkViewport")
extern class VkViewport {
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
    var minDepth:Float;
    var maxDepth:Float;
}

@:include("vulkan/vulkan.h")
@:native("VkRect2D")
extern class VkRect2D {
    var offset:VkOffset2D;
    var extent:VkExtent2D;
}

@:include("vulkan/vulkan.h")
@:native("VkOffset2D")
extern class VkOffset2D {
    var x:Int;
    var y:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkClearColorValue")
extern class VkClearColorValue {
    var float32:cpp.Float32;
}

@:include("vulkan/vulkan.h")
@:native("VkGraphicsPipelineCreateInfo")
extern class VkGraphicsPipelineCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var stageCount:Int;
    var pStages:cpp.Pointer<VkPipelineShaderStageCreateInfo>;
    var pVertexInputState:cpp.Pointer<VkPipelineVertexInputStateCreateInfo>;
    var pInputAssemblyState:cpp.Pointer<VkPipelineInputAssemblyStateCreateInfo>;
    var pTessellationState:cpp.Pointer<VkPipelineTessellationStateCreateInfo>;
    var pViewportState:cpp.Pointer<VkPipelineViewportStateCreateInfo>;
    var pRasterizationState:cpp.Pointer<VkPipelineRasterizationStateCreateInfo>;
    var pMultisampleState:cpp.Pointer<VkPipelineMultisampleStateCreateInfo>;
    var pDepthStencilState:cpp.Pointer<VkPipelineDepthStencilStateCreateInfo>;
    var pColorBlendState:cpp.Pointer<VkPipelineColorBlendStateCreateInfo>;
    var pDynamicState:cpp.Pointer<VkPipelineDynamicStateCreateInfo>;
    var layout:VkPipelineLayout;
    var renderPass:VkRenderPass;
    var subpass:Int;
    var basePipelineHandle:VkPipeline;
    var basePipelineIndex:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineVertexInputStateCreateInfo")
extern class VkPipelineVertexInputStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var vertexBindingDescriptionCount:Int;
    var pVertexBindingDescriptions:cpp.Pointer<VkVertexInputBindingDescription>;
    var vertexAttributeDescriptionCount:Int;
    var pVertexAttributeDescriptions:cpp.Pointer<VkVertexInputAttributeDescription>;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineInputAssemblyStateCreateInfo")
extern class VkPipelineInputAssemblyStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var topology:Int;
    var primitiveRestartEnable:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineTessellationStateCreateInfo")
extern class VkPipelineTessellationStateCreateInfo {}

@:include("vulkan/vulkan.h")
@:native("VkPipelineViewportStateCreateInfo")
extern class VkPipelineViewportStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var viewportCount:Int;
    var pViewports:cpp.Pointer<VkViewport>;
    var scissorCount:Int;
    var pScissors:cpp.Pointer<VkRect2D>;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineRasterizationStateCreateInfo")
extern class VkPipelineRasterizationStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var depthClampEnable:Int;
    var rasterizerDiscardEnable:Int;
    var polygonMode:Int;
    var cullMode:Int;
    var frontFace:Int;
    var depthBiasEnable:Int;
    var depthBiasConstantFactor:Float;
    var depthBiasClamp:Float;
    var depthBiasSlopeFactor:Float;
    var lineWidth:Float;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineMultisampleStateCreateInfo")
extern class VkPipelineMultisampleStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var rasterizationSamples:Int;
    var sampleShadingEnable:Int;
    var minSampleShading:Float;
    var pSampleMask:cpp.Pointer<Int>;
    var alphaToCoverageEnable:Int;
    var alphaToOneEnable:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkStencilOpState")
extern class VkStencilOpState {
    var failOp:Int;
    var passOp:Int;
    var depthFailOp:Int;
    var compareOp:Int;
    var compareMask:Int;
    var writeMask:Int;
    var reference:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineDepthStencilStateCreateInfo")
extern class VkPipelineDepthStencilStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var depthTestEnable:Int;
    var depthWriteEnable:Int;
    var depthCompareOp:Int;
    var depthBoundsTestEnable:Int;
    var stencilTestEnable:Int;
    var front:VkStencilOpState;
    var back:VkStencilOpState;
    var minDepthBounds:Float;
    var maxDepthBounds:Float;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineColorBlendAttachmentState")
extern class VkPipelineColorBlendAttachmentState {
    var blendEnable:Int;
    var srcColorBlendFactor:Int;
    var dstColorBlendFactor:Int;
    var colorBlendOp:Int;
    var srcAlphaBlendFactor:Int;
    var dstAlphaBlendFactor:Int;
    var alphaBlendOp:Int;
    var colorWriteMask:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineColorBlendStateCreateInfo")
extern class VkPipelineColorBlendStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var logicOpEnable:Int;
    var logicOp:Int;
    var attachmentCount:Int;
    var pAttachments:cpp.Pointer<VkPipelineColorBlendAttachmentState>;
    var blendConstants:cpp.Float32;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineDynamicStateCreateInfo")
extern class VkPipelineDynamicStateCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var dynamicStateCount:Int;
    var pDynamicStates:cpp.Pointer<Int>;
}

@:include("vulkan/vulkan.h")
@:native("VkCommandBufferBeginInfo")
extern class VkCommandBufferBeginInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var pInheritanceInfo:cpp.Pointer<VkCommandBufferInheritanceInfo>;
}

@:include("vulkan/vulkan.h")
@:native("VkCommandBufferInheritanceInfo")
extern class VkCommandBufferInheritanceInfo {}

@:include("vulkan/vulkan.h")
@:native("VkRenderPassBeginInfo")
extern class VkRenderPassBeginInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var renderPass:VkRenderPass;
    var framebuffer:VkFramebuffer;
    var renderArea:VkRect2D;
    var clearValueCount:Int;
    var pClearValues:cpp.Pointer<VkClearValue>;
}

@:include("vulkan/vulkan.h")
@:native("VkClearValue")
extern class VkClearValue {
    var color:VkClearColorValue;
}

@:include("vulkan/vulkan.h")
@:native("VkFramebufferCreateInfo")
extern class VkFramebufferCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var renderPass:VkRenderPass;
    var attachmentCount:Int;
    var pAttachments:cpp.Pointer<VkImageView>;
    var width:Int;
    var height:Int;
    var layers:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkAttachmentDescription")
extern class VkAttachmentDescription {
    var flags:Int;
    var format:Int;
    var samples:Int;
    var loadOp:Int;
    var storeOp:Int;
    var stencilLoadOp:Int;
    var stencilStoreOp:Int;
    var initialLayout:Int;
    var finalLayout:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkAttachmentReference")
extern class VkAttachmentReference {
    var attachment:Int;
    var layout:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkSubpassDescription")
extern class VkSubpassDescription {
    var flags:Int;
    var pipelineBindPoint:Int;
    var inputAttachmentCount:Int;
    var pInputAttachments:cpp.Pointer<VkAttachmentReference>;
    var colorAttachmentCount:Int;
    var pColorAttachments:cpp.Pointer<VkAttachmentReference>;
    var pResolveAttachments:cpp.Pointer<VkAttachmentReference>;
    var pDepthStencilAttachment:cpp.Pointer<VkAttachmentReference>;
    var preserveAttachmentCount:Int;
    var pPreserveAttachments:cpp.Pointer<Int>;
}

@:include("vulkan/vulkan.h")
@:native("VkRenderPassCreateInfo")
extern class VkRenderPassCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var attachmentCount:Int;
    var pAttachments:cpp.Pointer<VkAttachmentDescription>;
    var subpassCount:Int;
    var pSubpasses:cpp.Pointer<VkSubpassDescription>;
    var dependencyCount:Int;
    var pDependencies:cpp.Pointer<VkSubpassDependency>;
}

@:include("vulkan/vulkan.h")
@:native("VkSubpassDependency")
extern class VkSubpassDependency {}

@:include("vulkan/vulkan.h")
@:native("VkFenceCreateInfo")
extern class VkFenceCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkSemaphoreCreateInfo")
extern class VkSemaphoreCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorPoolSize")
extern class VkDescriptorPoolSize {
    var descriptorType:Int;
    var descriptorCount:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorPoolCreateInfo")
extern class VkDescriptorPoolCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var maxSets:Int;
    var poolSizeCount:Int;
    var pPoolSizes:cpp.Pointer<VkDescriptorPoolSize>;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorSetAllocateInfo")
extern class VkDescriptorSetAllocateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var descriptorPool:VkDescriptorPool;
    var descriptorSetCount:Int;
    var pSetLayouts:cpp.Pointer<VkDescriptorSetLayout>;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorBufferInfo")
extern class VkDescriptorBufferInfo {
    var buffer:VkBuffer;
    var offset:VkDeviceSize;
    var range:VkDeviceSize;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorImageInfo")
extern class VkDescriptorImageInfo {
    var sampler:VkSampler;
    var imageView:VkImageView;
    var imageLayout:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkWriteDescriptorSet")
extern class VkWriteDescriptorSet {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var dstSet:VkDescriptorSet;
    var dstBinding:Int;
    var dstArrayElement:Int;
    var descriptorCount:Int;
    var descriptorType:Int;
    var pImageInfo:cpp.Pointer<VkDescriptorImageInfo>;
    var pBufferInfo:cpp.Pointer<VkDescriptorBufferInfo>;
    var pTexelBufferView:cpp.Pointer<VkBufferView>;
}

@:include("vulkan/vulkan.h")
@:native("VkCopyDescriptorSet")
extern class VkCopyDescriptorSet {}

@:include("vulkan/vulkan.h")
@:native("VkSamplerCreateInfo")
extern class VkSamplerCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var magFilter:Int;
    var minFilter:Int;
    var mipmapMode:Int;
    var addressModeU:Int;
    var addressModeV:Int;
    var addressModeW:Int;
    var mipLodBias:Float;
    var anisotropyEnable:Int;
    var maxAnisotropy:Float;
    var compareEnable:Int;
    var compareOp:Int;
    var minLod:Float;
    var maxLod:Float;
    var borderColor:Int;
    var unnormalizedCoordinates:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineCache")
extern class VkPipelineCache {}

@:include("vulkan/vulkan.h")
@:native("VkBufferView")
extern class VkBufferView {}
