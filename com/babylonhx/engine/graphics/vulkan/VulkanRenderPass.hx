package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;

/**
 * Manages Vulkan render pass creation and configuration
 */
class VulkanRenderPass {
    
    private var _backend:VulkanBackend;
    private var _renderPass:VkRenderPass;
    private var _created:Bool = false;
    
    // Attachment configuration
    private var _colorAttachmentFormat:Int = 0; // VK_FORMAT_B8G8R8A8_SRGB
    private var _depthAttachmentFormat:Int = 0; // VK_FORMAT_D32_SFLOAT
    private var _hasDepthAttachment:Bool = false;
    
    public function new(backend:VulkanBackend) {
        _backend = backend;
    }
    
    /**
     * Set color attachment format
     */
    public function setColorFormat(format:Int):VulkanRenderPass {
        _colorAttachmentFormat = format;
        return this;
    }
    
    /**
     * Enable depth attachment with format
     */
    public function setDepthFormat(format:Int):VulkanRenderPass {
        _hasDepthAttachment = true;
        _depthAttachmentFormat = format;
        return this;
    }
    
    /**
     * Create render pass with current configuration
     */
    public function create():Bool {
        if (_created) {
            trace("Render pass is already created");
            return false;
        }
        
        var attachmentCount = 1; // Color
        if (_hasDepthAttachment) attachmentCount++;
        
        var attachments = new cpp.NativeArray<VkAttachmentDescription>(attachmentCount);
        var colorRefIndex = 0;
        var depthRefIndex = 1;
        
        // Color attachment
        var colorAttachment = cpp.Lib.create(VkAttachmentDescription);
        colorAttachment.format = _colorAttachmentFormat;
        colorAttachment.samples = 1; // VK_SAMPLE_COUNT_1_BIT
        colorAttachment.loadOp = 0; // VK_ATTACHMENT_LOAD_OP_CLEAR
        colorAttachment.storeOp = 0; // VK_ATTACHMENT_STORE_OP_STORE
        colorAttachment.stencilLoadOp = 1; // VK_ATTACHMENT_LOAD_OP_DONT_CARE
        colorAttachment.stencilStoreOp = 1; // VK_ATTACHMENT_STORE_OP_DONT_CARE
        colorAttachment.initialLayout = 0; // VK_IMAGE_LAYOUT_UNDEFINED
        colorAttachment.finalLayout = 7; // VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
        attachments[0] = colorAttachment;
        
        // Create color reference
        var colorReference = cpp.Lib.create(VkAttachmentReference);
        colorReference.attachment = colorRefIndex;
        colorReference.layout = 4; // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
        
        // Depth attachment (optional)
        if (_hasDepthAttachment) {
            var depthAttachment = cpp.Lib.create(VkAttachmentDescription);
            depthAttachment.format = _depthAttachmentFormat;
            depthAttachment.samples = 1; // VK_SAMPLE_COUNT_1_BIT
            depthAttachment.loadOp = 0; // VK_ATTACHMENT_LOAD_OP_CLEAR
            depthAttachment.storeOp = 0; // VK_ATTACHMENT_STORE_OP_STORE
            depthAttachment.stencilLoadOp = 1; // VK_ATTACHMENT_LOAD_OP_DONT_CARE
            depthAttachment.stencilStoreOp = 1; // VK_ATTACHMENT_STORE_OP_DONT_CARE
            depthAttachment.initialLayout = 0; // VK_IMAGE_LAYOUT_UNDEFINED
            depthAttachment.finalLayout = 2; // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
            attachments[1] = depthAttachment;
        }
        
        // Subpass description
        var subpass = cpp.Lib.create(VkAttachmentReference);
        var subpasses = new cpp.NativeArray<VkAttachmentReference>(1);
        subpasses[0] = subpass;
        
        var colorAttachmentRef = cpp.Lib.create(VkAttachmentReference);
        colorAttachmentRef.attachment = colorRefIndex;
        colorAttachmentRef.layout = 4; // VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
        
        var subpassDesc = cpp.Lib.create(VkSubpassDescription);
        subpassDesc.flags = 0;
        subpassDesc.pipelineBindPoint = 1; // VK_PIPELINE_BIND_POINT_GRAPHICS
        subpassDesc.inputAttachmentCount = 0;
        subpassDesc.pInputAttachments = null;
        subpassDesc.colorAttachmentCount = 1;
        subpassDesc.pColorAttachments = Pointer.addressOf(colorAttachmentRef);
        subpassDesc.pResolveAttachments = null;
        
        // Depth reference
        var depthAttachmentRef:cpp.Pointer<VkAttachmentReference> = null;
        if (_hasDepthAttachment) {
            depthAttachmentRef = new cpp.Pointer<VkAttachmentReference>();
            var depthRef = cpp.Lib.create(VkAttachmentReference);
            depthRef.attachment = depthRefIndex;
            depthRef.layout = 2; // VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
            depthAttachmentRef = Pointer.addressOf(depthRef);
            subpassDesc.pDepthStencilAttachment = depthAttachmentRef;
        }
        
        subpassDesc.preserveAttachmentCount = 0;
        subpassDesc.pPreserveAttachments = null;
        
        // Subpass dependency
        var dependency = cpp.Lib.create(VkSubpassDependency);
        dependency.srcSubpass = 0xFFFFFFFF; // VK_SUBPASS_EXTERNAL
        dependency.dstSubpass = 0;
        dependency.srcStageMask = 256; // VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
        dependency.dstStageMask = 256;
        dependency.srcAccessMask = 0;
        dependency.dstAccessMask = 1 | 2; // VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT
        dependency.dependencyFlags = 0;
        
        // Create render pass
        var createInfo = cpp.Lib.create(VkRenderPassCreateInfo);
        createInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        createInfo.pNext = null;
        createInfo.flags = 0;
        createInfo.attachmentCount = attachmentCount;
        createInfo.pAttachments = Pointer.arrayElem(attachments, 0);
        createInfo.subpassCount = 1;
        createInfo.pSubpasses = Pointer.addressOf(subpassDesc);
        createInfo.dependencyCount = 1;
        createInfo.pDependencies = Pointer.addressOf(dependency);
        
        var result = Vulkan.createRenderPass(_backend.getDevice(), Pointer.addressOf(createInfo), null, Pointer.addressOf(_renderPass));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create render pass");
            return false;
        }
        
        _created = true;
        return true;
    }
    
    /**
     * Get Vulkan render pass handle
     */
    public function getRenderPass():VkRenderPass {
        return _renderPass;
    }
    
    /**
     * Check if created
     */
    public function isCreated():Bool {
        return _created;
    }
    
    /**
     * Check if has depth attachment
     */
    public function hasDepthAttachment():Bool {
        return _hasDepthAttachment;
    }
    
    /**
     * Cleanup render pass
     */
    public function dispose():Void {
        if (_created) {
            Vulkan.destroyRenderPass(_backend.getDevice(), _renderPass, null);
            _created = false;
        }
    }
}
