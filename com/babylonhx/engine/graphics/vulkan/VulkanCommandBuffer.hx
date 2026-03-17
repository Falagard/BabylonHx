package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;

/**
 * Vulkan command buffer for recording rendering commands
 */
class VulkanCommandBuffer {
    
    private var _backend:VulkanBackend;
    private var _commandBuffer:VkCommandBuffer;
    private var _recording:Bool = false;
    private var _frameIndex:Int = 0;
    private var _renderPassActive:Bool = false;
    private var _currentPipeline:VulkanGraphicsPipeline;
    
    public function new(backend:VulkanBackend, commandBuffer:VkCommandBuffer) {
        _backend = backend;
        _commandBuffer = commandBuffer;
    }
    
    /**
     * Begin recording commands
     */
    public function begin():Bool {
        if (_recording) {
            trace("Command buffer is already recording");
            return false;
        }
        
        var beginInfo = cpp.Lib.create(VkCommandBufferBeginInfo);
        beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
        beginInfo.pNext = null;
        beginInfo.flags = 0;
        beginInfo.pInheritanceInfo = null;
        
        var result = Vulkan.beginCommandBuffer(_commandBuffer, Pointer.addressOf(beginInfo));
        
        if (result != VK_SUCCESS) {
            trace("Failed to begin command buffer");
            return false;
        }
        
        _recording = true;
        return true;
    }
    
    /**
     * End recording commands
     */
    public function end():Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (_renderPassActive) {
            endRenderPass();
        }
        
        var result = Vulkan.endCommandBuffer(_commandBuffer);
        
        if (result != VK_SUCCESS) {
            trace("Failed to end command buffer");
            return false;
        }
        
        _recording = false;
        return true;
    }
    
    /**
     * Begin render pass
     */
    public function beginRenderPass(renderPass:VkRenderPass, framebuffer:VkFramebuffer, 
            width:Int, height:Int, ?clearColor:{r:Float, g:Float, b:Float, a:Float}):Bool {
        
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (_renderPassActive) {
            trace("Render pass is already active");
            return false;
        }
        
        // Create clear value
        var clearValue = cpp.Lib.create(VkClearValue);
        if (clearColor != null) {
            // Note: Color should be set in a union, this is simplified
            trace("Clear color: " + clearColor.r + ", " + clearColor.g + ", " + clearColor.b + ", " + clearColor.a);
        }
        
        var renderPassBegin = cpp.Lib.create(VkRenderPassBeginInfo);
        renderPassBegin.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
        renderPassBegin.pNext = null;
        renderPassBegin.renderPass = renderPass;
        renderPassBegin.framebuffer = framebuffer;
        
        var renderArea = cpp.Lib.create(VkRect2D);
        var offset = cpp.Lib.create(VkOffset2D);
        offset.x = 0;
        offset.y = 0;
        renderArea.offset = offset;
        
        var extent = cpp.Lib.create(VkExtent2D);
        extent.width = width;
        extent.height = height;
        renderArea.extent = extent;
        
        renderPassBegin.renderArea = renderArea;
        renderPassBegin.clearValueCount = 1;
        renderPassBegin.pClearValues = Pointer.addressOf(clearValue);
        
        Vulkan.cmdBeginRenderPass(_commandBuffer, Pointer.addressOf(renderPassBegin), 0); // VK_SUBPASS_CONTENTS_INLINE
        
        _renderPassActive = true;
        return true;
    }
    
    /**
     * End render pass
     */
    public function endRenderPass():Bool {
        if (!_renderPassActive) {
            trace("No render pass is active");
            return false;
        }
        
        Vulkan.cmdEndRenderPass(_commandBuffer);
        _renderPassActive = false;
        return true;
    }
    
    /**
     * Bind graphics pipeline
     */
    public function bindPipeline(pipeline:VulkanGraphicsPipeline):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (!_renderPassActive) {
            trace("No render pass is active");
            return false;
        }
        
        var vkPipeline = pipeline.getPipeline();
        if (vkPipeline == null) {
            trace("Pipeline is not created");
            return false;
        }
        
        Vulkan.cmdBindPipeline(_commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, vkPipeline);
        _currentPipeline = pipeline;
        return true;
    }
    
    /**
     * Bind descriptor sets
     */
    public function bindDescriptorSets(pipelineLayout:VkPipelineLayout, descriptorSets:Array<VkDescriptorSet>):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (descriptorSets.length == 0) {
            trace("No descriptor sets to bind");
            return false;
        }
        
        // Create native array for descriptor sets
        var nativeDescriptorSets = new cpp.NativeArray<VkDescriptorSet>(descriptorSets.length);
        for (i in 0...descriptorSets.length) {
            nativeDescriptorSets[i] = descriptorSets[i];
        }
        
        Vulkan.cmdBindDescriptorSets(_commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayout,
            0, descriptorSets.length, Pointer.arrayElem(nativeDescriptorSets, 0), 0, null);
        
        return true;
    }
    
    /**
     * Set viewport
     */
    public function setViewport(x:Float, y:Float, width:Float, height:Float, ?minDepth:Float, ?maxDepth:Float):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (minDepth == null) minDepth = 0.0;
        if (maxDepth == null) maxDepth = 1.0;
        
        var viewport = cpp.Lib.create(VkViewport);
        viewport.x = x;
        viewport.y = y;
        viewport.width = width;
        viewport.height = height;
        viewport.minDepth = minDepth;
        viewport.maxDepth = maxDepth;
        
        Vulkan.cmdSetViewport(_commandBuffer, 0, 1, Pointer.addressOf(viewport));
        return true;
    }
    
    /**
     * Set scissor rectangle
     */
    public function setScissor(x:Int, y:Int, width:Int, height:Int):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        var scissor = cpp.Lib.create(VkRect2D);
        var offset = cpp.Lib.create(VkOffset2D);
        offset.x = x;
        offset.y = y;
        scissor.offset = offset;
        
        var extent = cpp.Lib.create(VkExtent2D);
        extent.width = width;
        extent.height = height;
        scissor.extent = extent;
        
        Vulkan.cmdSetScissor(_commandBuffer, 0, 1, Pointer.addressOf(scissor));
        return true;
    }
    
    /**
     * Draw vertices
     */
    public function draw(vertexCount:Int, ?instanceCount:Int, ?firstVertex:Int, ?firstInstance:Int):Bool {
        if (!_recording || !_renderPassActive) {
            trace("Cannot draw: command buffer not in render pass");
            return false;
        }
        
        if (instanceCount == null) instanceCount = 1;
        if (firstVertex == null) firstVertex = 0;
        if (firstInstance == null) firstInstance = 0;
        
        Vulkan.cmdDraw(_commandBuffer, vertexCount, instanceCount, firstVertex, firstInstance);
        return true;
    }
    
    /**
     * Draw indexed vertices
     */
    public function drawIndexed(indexCount:Int, ?instanceCount:Int, ?firstIndex:Int, 
            ?vertexOffset:Int, ?firstInstance:Int):Bool {
        
        if (!_recording || !_renderPassActive) {
            trace("Cannot draw: command buffer not in render pass");
            return false;
        }
        
        if (instanceCount == null) instanceCount = 1;
        if (firstIndex == null) firstIndex = 0;
        if (vertexOffset == null) vertexOffset = 0;
        if (firstInstance == null) firstInstance = 0;
        
        Vulkan.cmdDrawIndexed(_commandBuffer, indexCount, instanceCount, firstIndex, vertexOffset, firstInstance);
        return true;
    }
    
    /**
     * Bind vertex buffers
     */
    public function bindVertexBuffers(buffers:Array<VkBuffer>, ?offsets:Array<Int>):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (buffers.length == 0) {
            trace("No vertex buffers to bind");
            return false;
        }
        
        // Create native arrays
        var nativeBuffers = new cpp.NativeArray<VkBuffer>(buffers.length);
        var nativeOffsets = new cpp.NativeArray<Int>(buffers.length);
        
        for (i in 0...buffers.length) {
            nativeBuffers[i] = buffers[i];
            nativeOffsets[i] = (offsets != null && i < offsets.length) ? offsets[i] : 0;
        }
        
        Vulkan.cmdBindVertexBuffers(_commandBuffer, 0, buffers.length,
            Pointer.arrayElem(nativeBuffers, 0), 
            Pointer.arrayElem(cast nativeOffsets, 0));
        
        return true;
    }
    
    /**
     * Bind index buffer
     */
    public function bindIndexBuffer(buffer:VkBuffer, ?offset:Int, ?indexType:Int):Bool {
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (offset == null) offset = 0;
        if (indexType == null) indexType = 0; // VK_INDEX_TYPE_UINT32
        
        Vulkan.cmdBindIndexBuffer(_commandBuffer, buffer, cast offset, indexType);
        return true;
    }
    
    /**
     * Push constants
     */
    public function pushConstants(pipelineLayout:VkPipelineLayout, stageFlags:Int, 
            data:cpp.Pointer<Void>, size:Int, ?offset:Int):Bool {
        
        if (!_recording) {
            trace("Command buffer is not recording");
            return false;
        }
        
        if (offset == null) offset = 0;
        
        Vulkan.cmdPushConstants(_commandBuffer, pipelineLayout, stageFlags, offset, size, data);
        return true;
    }
    
    /**
     * Get underlying Vulkan command buffer
     */
    public function getVkCommandBuffer():VkCommandBuffer {
        return _commandBuffer;
    }
    
    /**
     * Check if recording
     */
    public function isRecording():Bool {
        return _recording;
    }
    
    /**
     * Check if render pass is active
     */
    public function isRenderPassActive():Bool {
        return _renderPassActive;
    }
    
    /**
     * Get current bound pipeline
     */
    public function getCurrentPipeline():VulkanGraphicsPipeline {
        return _currentPipeline;
    }
}
