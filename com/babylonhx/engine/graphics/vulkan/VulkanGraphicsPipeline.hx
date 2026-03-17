package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.pipeline.PipelineStates;
import com.babylonhx.engine.graphics.pipeline.BlendStateConfig;
import com.babylonhx.engine.graphics.pipeline.DepthStencilStateConfig;
import com.babylonhx.engine.graphics.pipeline.RasterizationStateConfig;
import cpp.Pointer;
import cpp.NativeArray;

/**
 * Vulkan graphics pipeline builder and management
 * Handles creation of VkGraphicsPipeline from pipeline state configuration
 */
class VulkanGraphicsPipeline {
    
    private var _backend:VulkanBackend;
    private var _pipeline:VkPipeline;
    private var _pipelineLayout:VkPipelineLayout;
    private var _renderPass:VkRenderPass;
    private var _vertexModule:VkShaderModule;
    private var _fragmentModule:VkShaderModule;
    private var _blendState:BlendStateConfig;
    private var _depthStencilState:DepthStencilStateConfig;
    private var _rasterizationState:RasterizationStateConfig;
    private var _viewportExtent:VkExtent2D;
    private var _created:Bool = false;
    
    public function new(backend:VulkanBackend) {
        _backend = backend;
        _pipeline = null;
        _pipelineLayout = null;
        _renderPass = backend.getRenderPass();
        _viewportExtent = cpp.Lib.create(VkExtent2D);
        _viewportExtent.width = 800;
        _viewportExtent.height = 600;
    }
    
    /**
     * Set shader modules for the pipeline
     */
    public function setShaderModules(vertexModule:VkShaderModule, fragmentModule:VkShaderModule):Void {
        _vertexModule = vertexModule;
        _fragmentModule = fragmentModule;
    }
    
    /**
     * Set pipeline layout
     */
    public function setPipelineLayout(layout:VkPipelineLayout):Void {
        _pipelineLayout = layout;
    }
    
    /**
     * Set blend state
     */
    public function setBlendState(blendState:BlendStateConfig):Void {
        _blendState = blendState;
    }
    
    /**
     * Set depth stencil state
     */
    public function setDepthStencilState(depthStencilState:DepthStencilStateConfig):Void {
        _depthStencilState = depthStencilState;
    }
    
    /**
     * Set rasterization state
     */
    public function setRasterizationState(rasterizationState:RasterizationStateConfig):Void {
        _rasterizationState = rasterizationState;
    }
    
    /**
     * Create the graphics pipeline
     */
    public function create():Bool {
        if (_created) return true;
        
        if (_vertexModule == null || _fragmentModule == null) {
            trace("Cannot create pipeline: shader modules not set");
            return false;
        }
        
        if (_pipelineLayout == null) {
            trace("Cannot create pipeline: pipeline layout not set");
            return false;
        }
        
        // Create shader stage create infos
        var shaderStages = createShaderStages();
        
        // Create vertex input state (empty for now)
        var vertexInputState = cpp.Lib.create(VkPipelineVertexInputStateCreateInfo);
        vertexInputState.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
        vertexInputState.pNext = null;
        vertexInputState.flags = 0;
        vertexInputState.vertexBindingDescriptionCount = 0;
        vertexInputState.pVertexBindingDescriptions = null;
        vertexInputState.vertexAttributeDescriptionCount = 0;
        vertexInputState.pVertexAttributeDescriptions = null;
        
        // Create input assembly state
        var inputAssemblyState = cpp.Lib.create(VkPipelineInputAssemblyStateCreateInfo);
        inputAssemblyState.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
        inputAssemblyState.pNext = null;
        inputAssemblyState.flags = 0;
        inputAssemblyState.topology = 0; // VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
        inputAssemblyState.primitiveRestartEnable = 0;
        
        // Create viewport state
        var viewportState = createViewportState();
        
        // Create rasterization state
        var rastState = cpp.Lib.create(VkPipelineRasterizationStateCreateInfo);
        rastState.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
        rastState.pNext = null;
        rastState.flags = 0;
        rastState.depthClampEnable = 0;
        rastState.rasterizerDiscardEnable = 0;
        rastState.polygonMode = 0; // VK_POLYGON_MODE_FILL
        rastState.cullMode = (_rasterizationState != null) ? _rasterizationState.cullMode : 0;
        rastState.frontFace = (_rasterizationState != null) ? _rasterizationState.frontFace : 0;
        rastState.depthBiasEnable = (_rasterizationState != null && _rasterizationState.depthBiasEnable) ? 1 : 0;
        rastState.depthBiasConstantFactor = (_rasterizationState != null) ? _rasterizationState.depthBiasConstantFactor : 0.0;
        rastState.depthBiasClamp = (_rasterizationState != null) ? _rasterizationState.depthBiasClamp : 0.0;
        rastState.depthBiasSlopeFactor = (_rasterizationState != null) ? _rasterizationState.depthBiasSlopeFactor : 0.0;
        rastState.lineWidth = (_rasterizationState != null) ? _rasterizationState.lineWidth : 1.0;
        
        // Create multisample state
        var multisampleState = cpp.Lib.create(VkPipelineMultisampleStateCreateInfo);
        multisampleState.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
        multisampleState.pNext = null;
        multisampleState.flags = 0;
        multisampleState.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
        multisampleState.sampleShadingEnable = 0;
        multisampleState.minSampleShading = 1.0;
        multisampleState.pSampleMask = null;
        multisampleState.alphaToCoverageEnable = 0;
        multisampleState.alphaToOneEnable = 0;
        
        // Create depth stencil state
        var depthStencilState = createDepthStencilState();
        
        // Create color blend state
        var colorBlendState = createColorBlendState();
        
        // Create dynamic state
        var dynamicStates = new NativeArray<Int>(2);
        dynamicStates[0] = 0; // VK_DYNAMIC_STATE_VIEWPORT
        dynamicStates[1] = 1; // VK_DYNAMIC_STATE_SCISSOR
        
        var dynamicState = cpp.Lib.create(VkPipelineDynamicStateCreateInfo);
        dynamicState.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
        dynamicState.pNext = null;
        dynamicState.flags = 0;
        dynamicState.dynamicStateCount = 2;
        dynamicState.pDynamicStates = Pointer.arrayElem(dynamicStates, 0);
        
        // Create graphics pipeline create info
        var pipelineCreateInfo = cpp.Lib.create(VkGraphicsPipelineCreateInfo);
        pipelineCreateInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
        pipelineCreateInfo.pNext = null;
        pipelineCreateInfo.flags = 0;
        pipelineCreateInfo.stageCount = shaderStages.length;
        pipelineCreateInfo.pStages = Pointer.arrayElem(shaderStages, 0);
        pipelineCreateInfo.pVertexInputState = Pointer.addressOf(vertexInputState);
        pipelineCreateInfo.pInputAssemblyState = Pointer.addressOf(inputAssemblyState);
        pipelineCreateInfo.pTessellationState = null;
        pipelineCreateInfo.pViewportState = Pointer.addressOf(viewportState);
        pipelineCreateInfo.pRasterizationState = Pointer.addressOf(rastState);
        pipelineCreateInfo.pMultisampleState = Pointer.addressOf(multisampleState);
        pipelineCreateInfo.pDepthStencilState = Pointer.addressOf(depthStencilState);
        pipelineCreateInfo.pColorBlendState = Pointer.addressOf(colorBlendState);
        pipelineCreateInfo.pDynamicState = Pointer.addressOf(dynamicState);
        pipelineCreateInfo.layout = _pipelineLayout;
        pipelineCreateInfo.renderPass = _renderPass;
        pipelineCreateInfo.subpass = 0;
        pipelineCreateInfo.basePipelineHandle = null;
        pipelineCreateInfo.basePipelineIndex = -1;
        
        // Create the pipeline
        var pipeline:VkPipeline = null;
        var result = Vulkan.createGraphicsPipelines(_backend.getDevice(), null, 1, 
            Pointer.addressOf(pipelineCreateInfo), null, Pointer.addressOf(pipeline));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create graphics pipeline");
            return false;
        }
        
        _pipeline = pipeline;
        _created = true;
        return true;
    }
    
    /**
     * Create shader stage info structures
     */
    private function createShaderStages():NativeArray<VkPipelineShaderStageCreateInfo> {
        var stages = new NativeArray<VkPipelineShaderStageCreateInfo>(2);
        
        // Vertex shader stage
        var vertexStage = cpp.Lib.create(VkPipelineShaderStageCreateInfo);
        vertexStage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        vertexStage.pNext = null;
        vertexStage.flags = 0;
        vertexStage.stage = VK_SHADER_STAGE_VERTEX_BIT;
        vertexStage.module = _vertexModule;
        vertexStage.pName = cast cpp.Lib.nativeString("main");
        vertexStage.pSpecializationInfo = null;
        stages[0] = vertexStage;
        
        // Fragment shader stage
        var fragmentStage = cpp.Lib.create(VkPipelineShaderStageCreateInfo);
        fragmentStage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        fragmentStage.pNext = null;
        fragmentStage.flags = 0;
        fragmentStage.stage = VK_SHADER_STAGE_FRAGMENT_BIT;
        fragmentStage.module = _fragmentModule;
        fragmentStage.pName = cast cpp.Lib.nativeString("main");
        fragmentStage.pSpecializationInfo = null;
        stages[1] = fragmentStage;
        
        return stages;
    }
    
    /**
     * Create viewport state
     */
    private function createViewportState():VkPipelineViewportStateCreateInfo {
        var viewport = cpp.Lib.create(VkViewport);
        viewport.x = 0.0;
        viewport.y = 0.0;
        viewport.width = cast _viewportExtent.width;
        viewport.height = cast _viewportExtent.height;
        viewport.minDepth = 0.0;
        viewport.maxDepth = 1.0;
        
        var scissor = cpp.Lib.create(VkRect2D);
        var scissorOffset = cpp.Lib.create(VkOffset2D);
        scissorOffset.x = 0;
        scissorOffset.y = 0;
        scissor.offset = scissorOffset;
        scissor.extent = _viewportExtent;
        
        var viewportState = cpp.Lib.create(VkPipelineViewportStateCreateInfo);
        viewportState.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
        viewportState.pNext = null;
        viewportState.flags = 0;
        viewportState.viewportCount = 1;
        viewportState.pViewports = Pointer.addressOf(viewport);
        viewportState.scissorCount = 1;
        viewportState.pScissors = Pointer.addressOf(scissor);
        
        return viewportState;
    }
    
    /**
     * Create depth stencil state
     */
    private function createDepthStencilState():VkPipelineDepthStencilStateCreateInfo {
        var depthStencilState = cpp.Lib.create(VkPipelineDepthStencilStateCreateInfo);
        depthStencilState.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
        depthStencilState.pNext = null;
        depthStencilState.flags = 0;
        
        if (_depthStencilState != null) {
            depthStencilState.depthTestEnable = _depthStencilState.depthTestEnabled ? 1 : 0;
            depthStencilState.depthWriteEnable = _depthStencilState.depthWriteEnabled ? 1 : 0;
            depthStencilState.depthCompareOp = _depthStencilState.depthCompareOp;
            depthStencilState.depthBoundsTestEnable = 0;
            depthStencilState.stencilTestEnable = 0;
        } else {
            depthStencilState.depthTestEnable = 0;
            depthStencilState.depthWriteEnable = 0;
            depthStencilState.depthCompareOp = VK_COMPARE_OP_ALWAYS;
            depthStencilState.depthBoundsTestEnable = 0;
            depthStencilState.stencilTestEnable = 0;
        }
        
        depthStencilState.minDepthBounds = 0.0;
        depthStencilState.maxDepthBounds = 1.0;
        
        return depthStencilState;
    }
    
    /**
     * Create color blend state
     */
    private function createColorBlendState():VkPipelineColorBlendStateCreateInfo {
        var attachmentState = cpp.Lib.create(VkPipelineColorBlendAttachmentState);
        
        if (_blendState != null) {
            attachmentState.blendEnable = _blendState.enabled ? 1 : 0;
            attachmentState.srcColorBlendFactor = _blendState.srcColorBlend;
            attachmentState.dstColorBlendFactor = _blendState.dstColorBlend;
            attachmentState.colorBlendOp = _blendState.colorBlendOp;
            attachmentState.srcAlphaBlendFactor = _blendState.srcAlphaBlend;
            attachmentState.dstAlphaBlendFactor = _blendState.dstAlphaBlend;
            attachmentState.alphaBlendOp = _blendState.alphaBlendOp;
            attachmentState.colorWriteMask = _blendState.colorWriteMask;
        } else {
            attachmentState.blendEnable = 0;
            attachmentState.srcColorBlendFactor = VK_BLEND_FACTOR_ONE;
            attachmentState.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO;
            attachmentState.colorBlendOp = VK_BLEND_OP_ADD;
            attachmentState.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
            attachmentState.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
            attachmentState.alphaBlendOp = VK_BLEND_OP_ADD;
            attachmentState.colorWriteMask = 0xF; // RGBA
        }
        
        var colorBlendState = cpp.Lib.create(VkPipelineColorBlendStateCreateInfo);
        colorBlendState.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
        colorBlendState.pNext = null;
        colorBlendState.flags = 0;
        colorBlendState.logicOpEnable = 0;
        colorBlendState.logicOp = 0;
        colorBlendState.attachmentCount = 1;
        colorBlendState.pAttachments = Pointer.addressOf(attachmentState);
        colorBlendState.blendConstants = 0.0;
        
        return colorBlendState;
    }
    
    /**
     * Get the Vulkan pipeline handle
     */
    public function getPipeline():VkPipeline {
        return _pipeline;
    }
    
    /**
     * Check if pipeline has been created
     */
    public function isCreated():Bool {
        return _created;
    }
    
    /**
     * Dispose GPU resources
     */
    public function dispose():Void {
        if (_pipeline != null && _created) {
            Vulkan.destroyPipeline(_backend.getDevice(), _pipeline, null);
        }
    }
}
