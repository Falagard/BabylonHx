package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.pipeline.PipelineStateMapper;
import com.babylonhx.engine.graphics.pipeline.BlendStateConfig;
import com.babylonhx.engine.graphics.pipeline.DepthStencilStateConfig;
import com.babylonhx.engine.graphics.pipeline.RasterizationStateConfig;
import com.babylonhx.materials.Material;

/**
 * Vulkan graphics pipeline manager
 * Handles creation, caching, and state management of graphics pipelines
 */
class VulkanPipelineManager {
    
    private var _backend:VulkanBackend;
    private var _pipelineCache:Map<String, VulkanGraphicsPipeline>;
    private var _currentPipeline:VulkanGraphicsPipeline;
    private var _descriptorManagers:Map<String, VulkanDescriptorSetManager>;
    private var _pipelineCount:Int = 0;
    
    public function new(backend:VulkanBackend) {
        _backend = backend;
        _pipelineCache = new Map();
        _descriptorManagers = new Map();
        _currentPipeline = null;
    }
    
    /**
     * Create a graphics pipeline from shader modules and state
     */
    public function createPipeline(vertexModule:VkShaderModule, fragmentModule:VkShaderModule,
            ?blendState:BlendStateConfig, ?depthStencilState:DepthStencilStateConfig,
            ?rasterizationState:RasterizationStateConfig):VulkanGraphicsPipeline {
        
        // Generate cache key from shader modules and state
        var cacheKey = generateCacheKey(vertexModule, fragmentModule, blendState, depthStencilState, rasterizationState);
        
        // Check if pipeline already exists in cache
        if (_pipelineCache.exists(cacheKey)) {
            return _pipelineCache.get(cacheKey);
        }
        
        // Create new pipeline
        var pipeline = new VulkanGraphicsPipeline(_backend);
        pipeline.setShaderModules(vertexModule, fragmentModule);
        
        // Create pipeline layout
        var pipelineLayout = createPipelineLayout();
        if (pipelineLayout == null) {
            trace("Failed to create pipeline layout");
            return null;
        }
        pipeline.setPipelineLayout(pipelineLayout);
        
        // Set state
        if (blendState != null) {
            pipeline.setBlendState(blendState);
        }
        if (depthStencilState != null) {
            pipeline.setDepthStencilState(depthStencilState);
        }
        if (rasterizationState != null) {
            pipeline.setRasterizationState(rasterizationState);
        }
        
        // Create the pipeline
        if (!pipeline.create()) {
            trace("Failed to create graphics pipeline");
            return null;
        }
        
        // Cache and return
        _pipelineCache.set(cacheKey, pipeline);
        _pipelineCount++;
        return pipeline;
    }
    
    /**
     * Create pipeline from BabylonHx material state
     */
    public function createPipelineFromMaterial(material:Material, vertexModule:VkShaderModule, 
            fragmentModule:VkShaderModule):VulkanGraphicsPipeline {
        
        // Extract state from material
        var blendState:BlendStateConfig = null;
        var depthStencilState:DepthStencilStateConfig = null;
        var rasterizationState:RasterizationStateConfig = null;
        
        // Map BabylonHx material state if available
        // This would use the state mapper from Phase 3
        if (material != null) {
            // TODO: Map material state using PipelineStateMapper
        }
        
        return createPipeline(vertexModule, fragmentModule, blendState, depthStencilState, rasterizationState);
    }
    
    /**
     * Create a pipeline layout
     */
    private function createPipelineLayout():VkPipelineLayout {
        var layoutCreateInfo = cpp.Lib.create(VkPipelineLayoutCreateInfo);
        layoutCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
        layoutCreateInfo.pNext = null;
        layoutCreateInfo.flags = 0;
        layoutCreateInfo.setLayoutCount = 0; // No descriptor sets for now
        layoutCreateInfo.pSetLayouts = null;
        layoutCreateInfo.pushConstantRangeCount = 0;
        layoutCreateInfo.pPushConstantRanges = null;
        
        var pipelineLayout:VkPipelineLayout = null;
        var result = Vulkan.createPipelineLayout(_backend.getDevice(), cpp.Pointer.addressOf(layoutCreateInfo), 
            null, cpp.Pointer.addressOf(pipelineLayout));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create pipeline layout");
            return null;
        }
        
        return pipelineLayout;
    }
    
    /**
     * Get or create descriptor set manager for a pipeline
     */
    public function getDescriptorSetManager(managerId:String):VulkanDescriptorSetManager {
        if (_descriptorManagers.exists(managerId)) {
            return _descriptorManagers.get(managerId);
        }
        
        var manager = new VulkanDescriptorSetManager(_backend);
        _descriptorManagers.set(managerId, manager);
        return manager;
    }
    
    /**
     * Set current pipeline for rendering
     */
    public function setCurrentPipeline(pipeline:VulkanGraphicsPipeline):Void {
        _currentPipeline = pipeline;
    }
    
    /**
     * Get current pipeline
     */
    public function getCurrentPipeline():VulkanGraphicsPipeline {
        return _currentPipeline;
    }
    
    /**
     * Clear pipeline cache
     */
    public function clearCache():Void {
        for (pipeline in _pipelineCache.iterator()) {
            pipeline.dispose();
        }
        _pipelineCache.clear();
        _pipelineCount = 0;
    }
    
    /**
     * Get pipeline cache statistics
     */
    public function getCacheStats():{count:Int, count:Int} {
        return {count: _pipelineCount, count: _pipelineCount};
    }
    
    /**
     * Generate cache key for pipeline state
     */
    private function generateCacheKey(vertexModule:VkShaderModule, fragmentModule:VkShaderModule,
            ?blendState:BlendStateConfig, ?depthStencilState:DepthStencilStateConfig,
            ?rasterizationState:RasterizationStateConfig):String {
        
        var key = "";
        key += Std.string(vertexModule).hashCode();
        key += "_";
        key += Std.string(fragmentModule).hashCode();
        
        if (blendState != null) {
            key += "_" + blendState.getHash();
        }
        if (depthStencilState != null) {
            key += "_" + depthStencilState.getHash();
        }
        if (rasterizationState != null) {
            key += "_" + rasterizationState.getHash();
        }
        
        return key;
    }
    
    /**
     * Dispose all resources
     */
    public function dispose():Void {
        clearCache();
        
        for (manager in _descriptorManagers.iterator()) {
            manager.dispose();
        }
        _descriptorManagers.clear();
    }
}
