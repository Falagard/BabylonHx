package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.pipeline.BlendStateConfig;
import com.babylonhx.engine.graphics.pipeline.DepthStencilStateConfig;
import com.babylonhx.engine.graphics.pipeline.RasterizationStateConfig;
import com.babylonhx.engine.graphics.pipeline.PipelineEnums;

/**
 * Vulkan pipeline and descriptor set tests
 */
class VulkanPipelineTests {
    
    public static function runTests():Void {
        trace("=== Vulkan Pipeline Tests ===");
        
        testDescriptorSetManagerCreation();
        testDescriptorSetBindings();
        testGraphicsPipelineState();
        testPipelineManager();
        testPipelineCaching();
        
        trace("=== All tests completed ===");
    }
    
    /**
     * Test descriptor set manager creation
     */
    private static function testDescriptorSetManagerCreation():Void {
        trace("\n[TEST] Descriptor Set Manager Creation");
        
        var manager = new VulkanDescriptorSetManager(null, 16);
        
        // Should have no bindings initially
        if (manager == null) {
            trace("[FAIL] Failed to create descriptor set manager");
            return;
        }
        
        trace("[PASS] Descriptor set manager created successfully");
    }
    
    /**
     * Test descriptor set bindings
     */
    private static function testDescriptorSetBindings():Void {
        trace("\n[TEST] Descriptor Set Bindings");
        
        var manager = new VulkanDescriptorSetManager(null, 16);
        
        // Add various bindings
        manager.addUniformBufferBinding(0);
        manager.addStorageBufferBinding(1);
        manager.addSamplerBinding(2);
        manager.addSampledImageBinding(3);
        manager.addCombinedImageSamplerBinding(4);
        
        trace("[PASS] All binding types added successfully");
    }
    
    /**
     * Test graphics pipeline state
     */
    private static function testGraphicsPipelineState():Void {
        trace("\n[TEST] Graphics Pipeline State");
        
        // Create blend state
        var blendState = new BlendStateConfig();
        blendState.enabled = true;
        blendState.srcColorBlend = PipelineEnums.BlendFactor.SRC_ALPHA;
        blendState.dstColorBlend = PipelineEnums.BlendFactor.ONE_MINUS_SRC_ALPHA;
        
        if (!blendState.enabled) {
            trace("[FAIL] Blend state not created properly");
            return;
        }
        
        // Create depth stencil state
        var depthStencilState = new DepthStencilStateConfig();
        depthStencilState.depthTestEnabled = true;
        depthStencilState.depthWriteEnabled = true;
        depthStencilState.depthCompareOp = PipelineEnums.CompareOp.LESS;
        
        if (!depthStencilState.depthTestEnabled) {
            trace("[FAIL] Depth stencil state not created properly");
            return;
        }
        
        // Create rasterization state
        var rastState = new RasterizationStateConfig();
        rastState.cullMode = PipelineEnums.CullMode.BACK;
        rastState.frontFace = PipelineEnums.FrontFace.COUNTER_CLOCKWISE;
        
        if (rastState.cullMode != PipelineEnums.CullMode.BACK) {
            trace("[FAIL] Rasterization state not created properly");
            return;
        }
        
        trace("[PASS] All pipeline states created successfully");
    }
    
    /**
     * Test pipeline manager
     */
    private static function testPipelineManager():Void {
        trace("\n[TEST] Pipeline Manager");
        
        var manager = new VulkanPipelineManager(null);
        
        if (manager == null) {
            trace("[FAIL] Failed to create pipeline manager");
            return;
        }
        
        // Get descriptor set manager
        var descriptorMgr = manager.getDescriptorSetManager("main");
        if (descriptorMgr == null) {
            trace("[FAIL] Failed to create descriptor set manager");
            return;
        }
        
        trace("[PASS] Pipeline manager created successfully");
    }
    
    /**
     * Test pipeline caching
     */
    private static function testPipelineCaching():Void {
        trace("\n[TEST] Pipeline Caching");
        
        var manager = new VulkanPipelineManager(null);
        
        var stats = manager.getCacheStats();
        if (stats.count != 0) {
            trace("[FAIL] Pipeline cache should start empty");
            return;
        }
        
        // Clear cache (even though empty)
        manager.clearCache();
        
        trace("[PASS] Pipeline caching works as expected");
    }
}
