package com.babylonhx.engine.graphics.vulkan;

import cpp.Pointer;
import cpp.NativeArray;

/**
 * Vulkan descriptor set layout and pool management
 * Handles creation of descriptor set layouts and allocation of descriptor sets
 */
class VulkanDescriptorSetManager {
    
    private var _backend:VulkanBackend;
    private var _descriptorPool:VkDescriptorPool;
    private var _descriptorSetLayouts:Array<VkDescriptorSetLayout>;
    private var _descriptorSets:Array<VkDescriptorSet>;
    private var _maxSets:Int;
    private var _bufferBindings:Array<DescriptorBinding>;
    private var _imageBindings:Array<DescriptorBinding>;
    
    private typedef DescriptorBinding = {
        binding:Int,
        descriptorType:Int,
        descriptorCount:Int,
        stageFlags:Int
    };
    
    public function new(backend:VulkanBackend, maxSets:Int = 16) {
        _backend = backend;
        _maxSets = maxSets;
        _descriptorSetLayouts = [];
        _descriptorSets = [];
        _bufferBindings = [];
        _imageBindings = [];
    }
    
    /**
     * Add a uniform buffer binding
     */
    public function addUniformBufferBinding(binding:Int, descriptorCount:Int = 1, 
            stageFlags:Int = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT):Void {
        _bufferBindings.push({
            binding: binding,
            descriptorType: VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            descriptorCount: descriptorCount,
            stageFlags: stageFlags
        });
    }
    
    /**
     * Add a storage buffer binding
     */
    public function addStorageBufferBinding(binding:Int, descriptorCount:Int = 1,
            stageFlags:Int = VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT):Void {
        _bufferBindings.push({
            binding: binding,
            descriptorType: VK_DESCRIPTOR_TYPE_STORAGE_BUFFER,
            descriptorCount: descriptorCount,
            stageFlags: stageFlags
        });
    }
    
    /**
     * Add a sampler binding
     */
    public function addSamplerBinding(binding:Int, descriptorCount:Int = 1,
            stageFlags:Int = VK_SHADER_STAGE_FRAGMENT_BIT):Void {
        _imageBindings.push({
            binding: binding,
            descriptorType: VK_DESCRIPTOR_TYPE_SAMPLER,
            descriptorCount: descriptorCount,
            stageFlags: stageFlags
        });
    }
    
    /**
     * Add a sampled image binding
     */
    public function addSampledImageBinding(binding:Int, descriptorCount:Int = 1,
            stageFlags:Int = VK_SHADER_STAGE_FRAGMENT_BIT):Void {
        _imageBindings.push({
            binding: binding,
            descriptorType: VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE,
            descriptorCount: descriptorCount,
            stageFlags: stageFlags
        });
    }
    
    /**
     * Add a combined image sampler binding
     */
    public function addCombinedImageSamplerBinding(binding:Int, descriptorCount:Int = 1,
            stageFlags:Int = VK_SHADER_STAGE_FRAGMENT_BIT):Void {
        _imageBindings.push({
            binding: binding,
            descriptorType: VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            descriptorCount: descriptorCount,
            stageFlags: stageFlags
        });
    }
    
    /**
     * Create descriptor set layout and pool
     */
    public function create():Bool {
        if (!createDescriptorSetLayout()) {
            return false;
        }
        
        if (!createDescriptorPool()) {
            return false;
        }
        
        if (!allocateDescriptorSets()) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Create descriptor set layout
     */
    private function createDescriptorSetLayout():Bool {
        var bindingCount = _bufferBindings.length + _imageBindings.length;
        
        if (bindingCount == 0) {
            trace("No descriptor bindings defined");
            return false;
        }
        
        var bindings = new NativeArray<VkDescriptorSetLayoutBinding>(bindingCount);
        var index = 0;
        
        // Add buffer bindings
        for (binding in _bufferBindings) {
            var vkBinding = cpp.Lib.create(VkDescriptorSetLayoutBinding);
            vkBinding.binding = binding.binding;
            vkBinding.descriptorType = binding.descriptorType;
            vkBinding.descriptorCount = binding.descriptorCount;
            vkBinding.stageFlags = binding.stageFlags;
            vkBinding.pImmutableSamplers = null;
            bindings[index++] = vkBinding;
        }
        
        // Add image bindings
        for (binding in _imageBindings) {
            var vkBinding = cpp.Lib.create(VkDescriptorSetLayoutBinding);
            vkBinding.binding = binding.binding;
            vkBinding.descriptorType = binding.descriptorType;
            vkBinding.descriptorCount = binding.descriptorCount;
            vkBinding.stageFlags = binding.stageFlags;
            vkBinding.pImmutableSamplers = null;
            bindings[index++] = vkBinding;
        }
        
        var layoutCreateInfo = cpp.Lib.create(VkDescriptorSetLayoutCreateInfo);
        layoutCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
        layoutCreateInfo.pNext = null;
        layoutCreateInfo.flags = 0;
        layoutCreateInfo.bindingCount = bindingCount;
        layoutCreateInfo.pBindings = Pointer.arrayElem(bindings, 0);
        
        var descriptorSetLayout:VkDescriptorSetLayout = null;
        var result = Vulkan.createDescriptorSetLayout(_backend.getDevice(), Pointer.addressOf(layoutCreateInfo),
            null, Pointer.addressOf(descriptorSetLayout));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create descriptor set layout");
            return false;
        }
        
        _descriptorSetLayouts.push(descriptorSetLayout);
        return true;
    }
    
    /**
     * Create descriptor pool
     */
    private function createDescriptorPool():Bool {
        var poolSizes = new NativeArray<VkDescriptorPoolSize>(10);
        var poolSizeIndex = 0;
        var totalDescriptors = 0;
        
        // Count buffer descriptors
        if (_bufferBindings.length > 0) {
            var bufferSize = cpp.Lib.create(VkDescriptorPoolSize);
            bufferSize.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
            bufferSize.descriptorCount = _maxSets * 4; // Assume 4 uniform buffers per set
            poolSizes[poolSizeIndex++] = bufferSize;
            totalDescriptors += bufferSize.descriptorCount;
            
            var storageSize = cpp.Lib.create(VkDescriptorPoolSize);
            storageSize.descriptorType = VK_DESCRIPTOR_TYPE_STORAGE_BUFFER;
            storageSize.descriptorCount = _maxSets * 2; // Assume 2 storage buffers per set
            poolSizes[poolSizeIndex++] = storageSize;
            totalDescriptors += storageSize.descriptorCount;
        }
        
        // Count image descriptors
        if (_imageBindings.length > 0) {
            var samplerSize = cpp.Lib.create(VkDescriptorPoolSize);
            samplerSize.descriptorType = VK_DESCRIPTOR_TYPE_SAMPLER;
            samplerSize.descriptorCount = _maxSets * 4; // Assume 4 samplers per set
            poolSizes[poolSizeIndex++] = samplerSize;
            totalDescriptors += samplerSize.descriptorCount;
            
            var imageSize = cpp.Lib.create(VkDescriptorPoolSize);
            imageSize.descriptorType = VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE;
            imageSize.descriptorCount = _maxSets * 4;
            poolSizes[poolSizeIndex++] = imageSize;
            totalDescriptors += imageSize.descriptorCount;
            
            var combinedSize = cpp.Lib.create(VkDescriptorPoolSize);
            combinedSize.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
            combinedSize.descriptorCount = _maxSets * 4;
            poolSizes[poolSizeIndex++] = combinedSize;
            totalDescriptors += combinedSize.descriptorCount;
        }
        
        var poolCreateInfo = cpp.Lib.create(VkDescriptorPoolCreateInfo);
        poolCreateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
        poolCreateInfo.pNext = null;
        poolCreateInfo.flags = 0;
        poolCreateInfo.maxSets = _maxSets;
        poolCreateInfo.poolSizeCount = poolSizeIndex;
        poolCreateInfo.pPoolSizes = Pointer.arrayElem(poolSizes, 0);
        
        var descriptorPool:VkDescriptorPool = null;
        var result = Vulkan.createDescriptorPool(_backend.getDevice(), Pointer.addressOf(poolCreateInfo),
            null, Pointer.addressOf(descriptorPool));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create descriptor pool");
            return false;
        }
        
        _descriptorPool = descriptorPool;
        return true;
    }
    
    /**
     * Allocate descriptor sets from pool
     */
    private function allocateDescriptorSets():Bool {
        if (_descriptorSetLayouts.length == 0) {
            trace("No descriptor set layouts created");
            return false;
        }
        
        var layoutArray = new NativeArray<VkDescriptorSetLayout>(_maxSets);
        for (i in 0..._maxSets) {
            layoutArray[i] = _descriptorSetLayouts[0];
        }
        
        var allocateInfo = cpp.Lib.create(VkDescriptorSetAllocateInfo);
        allocateInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
        allocateInfo.pNext = null;
        allocateInfo.descriptorPool = _descriptorPool;
        allocateInfo.descriptorSetCount = _maxSets;
        allocateInfo.pSetLayouts = Pointer.arrayElem(layoutArray, 0);
        
        var descriptorSets = new NativeArray<VkDescriptorSet>(_maxSets);
        var result = Vulkan.allocateDescriptorSets(_backend.getDevice(), Pointer.addressOf(allocateInfo),
            Pointer.arrayElem(descriptorSets, 0));
        
        if (result != VK_SUCCESS) {
            trace("Failed to allocate descriptor sets");
            return false;
        }
        
        for (i in 0..._maxSets) {
            _descriptorSets.push(descriptorSets[i]);
        }
        
        return true;
    }
    
    /**
     * Update a descriptor set with buffer bindings
     */
    public function updateBufferDescriptor(setIndex:Int, binding:Int, buffer:VkBuffer, offset:Int, range:Int):Void {
        if (setIndex >= _descriptorSets.length) {
            trace("Invalid descriptor set index: " + setIndex);
            return;
        }
        
        var bufferInfo = cpp.Lib.create(VkDescriptorBufferInfo);
        bufferInfo.buffer = buffer;
        bufferInfo.offset = cast offset;
        bufferInfo.range = cast range;
        
        var writeDescriptorSet = cpp.Lib.create(VkWriteDescriptorSet);
        writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        writeDescriptorSet.pNext = null;
        writeDescriptorSet.dstSet = _descriptorSets[setIndex];
        writeDescriptorSet.dstBinding = binding;
        writeDescriptorSet.dstArrayElement = 0;
        writeDescriptorSet.descriptorCount = 1;
        writeDescriptorSet.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
        writeDescriptorSet.pImageInfo = null;
        writeDescriptorSet.pBufferInfo = Pointer.addressOf(bufferInfo);
        writeDescriptorSet.pTexelBufferView = null;
        
        Vulkan.updateDescriptorSets(_backend.getDevice(), 1, Pointer.addressOf(writeDescriptorSet), 0, null);
    }
    
    /**
     * Update a descriptor set with image bindings
     */
    public function updateImageDescriptor(setIndex:Int, binding:Int, imageView:VkImageView, sampler:VkSampler):Void {
        if (setIndex >= _descriptorSets.length) {
            trace("Invalid descriptor set index: " + setIndex);
            return;
        }
        
        var imageInfo = cpp.Lib.create(VkDescriptorImageInfo);
        imageInfo.sampler = sampler;
        imageInfo.imageView = imageView;
        imageInfo.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        
        var writeDescriptorSet = cpp.Lib.create(VkWriteDescriptorSet);
        writeDescriptorSet.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        writeDescriptorSet.pNext = null;
        writeDescriptorSet.dstSet = _descriptorSets[setIndex];
        writeDescriptorSet.dstBinding = binding;
        writeDescriptorSet.dstArrayElement = 0;
        writeDescriptorSet.descriptorCount = 1;
        writeDescriptorSet.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
        writeDescriptorSet.pImageInfo = Pointer.addressOf(imageInfo);
        writeDescriptorSet.pBufferInfo = null;
        writeDescriptorSet.pTexelBufferView = null;
        
        Vulkan.updateDescriptorSets(_backend.getDevice(), 1, Pointer.addressOf(writeDescriptorSet), 0, null);
    }
    
    /**
     * Get descriptor set layout
     */
    public function getDescriptorSetLayout(index:Int = 0):VkDescriptorSetLayout {
        if (index >= _descriptorSetLayouts.length) {
            return null;
        }
        return _descriptorSetLayouts[index];
    }
    
    /**
     * Get descriptor set
     */
    public function getDescriptorSet(index:Int = 0):VkDescriptorSet {
        if (index >= _descriptorSets.length) {
            return null;
        }
        return _descriptorSets[index];
    }
    
    /**
     * Get all descriptor set layouts
     */
    public function getDescriptorSetLayouts():Array<VkDescriptorSetLayout> {
        return _descriptorSetLayouts;
    }
    
    /**
     * Dispose GPU resources
     */
    public function dispose():Void {
        var device = _backend.getDevice();
        
        if (_descriptorPool != null) {
            Vulkan.destroyDescriptorPool(device, _descriptorPool, null);
        }
        
        for (layout in _descriptorSetLayouts) {
            if (layout != null) {
                Vulkan.destroyDescriptorSetLayout(device, layout, null);
            }
        }
    }
}
