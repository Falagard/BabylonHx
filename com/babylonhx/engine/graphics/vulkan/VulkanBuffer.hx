package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.IGraphicsBuffer;
import cpp.Pointer;

/**
 * Vulkan GPU buffer implementation
 */
class VulkanBuffer implements IGraphicsBuffer {
    
    private var _backend:VulkanBackend;
    private var _buffer:VkBuffer;
    private var _memory:VkDeviceMemory;
    private var _size:VkDeviceSize;
    private var _usage:Int;
    private var _mappedPointer:cpp.Pointer<Void>;
    private var _mapped:Bool = false;
    
    public function new(backend:VulkanBackend, data:Float32Array, usage:Int) {
        _backend = backend;
        _usage = usage;
        _size = cast (data.length * 4); // 4 bytes per float32
        _mappedPointer = null;
        
        if (!createBuffer(data)) {
            throw "Failed to create Vulkan buffer";
        }
    }
    
    /**
     * Create and allocate GPU buffer
     */
    private function createBuffer(data:Float32Array):Bool {
        var device = _backend.getDevice();
        var physicalDevice = _backend.getPhysicalDevice();
        
        // Create buffer
        var bufferCreateInfo = cpp.Lib.create(VkBufferCreateInfo);
        bufferCreateInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
        bufferCreateInfo.pNext = null;
        bufferCreateInfo.flags = 0;
        bufferCreateInfo.size = _size;
        bufferCreateInfo.usage = _usage;
        bufferCreateInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
        bufferCreateInfo.queueFamilyIndexCount = 0;
        bufferCreateInfo.pQueueFamilyIndices = null;
        
        var buffer:VkBuffer = null;
        var result = Vulkan.createBuffer(device, Pointer.addressOf(bufferCreateInfo), null, Pointer.addressOf(buffer));
        
        if (result != VK_SUCCESS) {
            trace("Failed to create buffer");
            return false;
        }
        
        _buffer = buffer;
        
        // Get memory requirements
        var memRequirements = cpp.Lib.create(VkMemoryRequirements);
        Vulkan.getBufferMemoryRequirements(device, _buffer, Pointer.addressOf(memRequirements));
        
        // Find suitable memory type
        var memoryTypeIndex = findMemoryType(physicalDevice, memRequirements.memoryTypeBits, 
            VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
        
        if (memoryTypeIndex == -1) {
            trace("Failed to find suitable memory type");
            return false;
        }
        
        // Allocate memory
        var allocateInfo = cpp.Lib.create(VkMemoryAllocateInfo);
        allocateInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
        allocateInfo.pNext = null;
        allocateInfo.allocationSize = memRequirements.size;
        allocateInfo.memoryTypeIndex = memoryTypeIndex;
        
        var memory:VkDeviceMemory = null;
        result = Vulkan.allocateMemory(device, Pointer.addressOf(allocateInfo), null, Pointer.addressOf(memory));
        
        if (result != VK_SUCCESS) {
            trace("Failed to allocate buffer memory");
            Vulkan.destroyBuffer(device, _buffer, null);
            return false;
        }
        
        _memory = memory;
        
        // Bind memory to buffer
        result = Vulkan.bindBufferMemory(device, _buffer, _memory, 0);
        
        if (result != VK_SUCCESS) {
            trace("Failed to bind buffer memory");
            Vulkan.freeMemory(device, _memory, null);
            Vulkan.destroyBuffer(device, _buffer, null);
            return false;
        }
        
        // Copy data to GPU
        if (data != null) {
            return copyDataToBuffer(data);
        }
        
        return true;
    }
    
    /**
     * Copy data from CPU to GPU buffer
     */
    private function copyDataToBuffer(data:Float32Array):Bool {
        var device = _backend.getDevice();
        
        // Map memory
        var mappedData:cpp.Pointer<cpp.Void> = null;
        var result = Vulkan.mapMemory(device, _memory, 0, _size, 0, Pointer.addressOf(mappedData));
        
        if (result != VK_SUCCESS) {
            trace("Failed to map buffer memory");
            return false;
        }
        
        // Copy data using memcpy
        cpp.NativeArray.setData(cast mappedData, 0, cast data, 0, data.length * 4);
        
        // Unmap memory
        Vulkan.unmapMemory(device, _memory);
        
        return true;
    }
    
    /**
     * Find suitable memory type index
     */
    private function findMemoryType(physicalDevice:VkPhysicalDevice, typeFilter:Int, properties:Int):Int {
        var memProperties = cpp.Lib.create(VkPhysicalDeviceMemoryProperties);
        Vulkan.getPhysicalDeviceMemoryProperties(physicalDevice, Pointer.addressOf(memProperties));
        
        for (i in 0...memProperties.memoryTypeCount) {
            if ((typeFilter & (1 << i)) != 0 && (memProperties.memoryTypes[i].propertyFlags & properties) == properties) {
                return i;
            }
        }
        
        return -1;
    }
    
    /**
     * Bind buffer for use in rendering
     */
    public function bind(target:Int):Void {
        // Binding is done at command buffer recording time in Vulkan
        // This is a placeholder for API compatibility
    }
    
    /**
     * Write data to buffer
     */
    public function write(data:cpp.Pointer<cpp.Void>, offset:Int):Void {
        var device = _backend.getDevice();
        
        // Only works if buffer was created with HOST_VISIBLE memory
        var mappedData:cpp.Pointer<cpp.Void> = null;
        var result = Vulkan.mapMemory(device, _memory, offset, _size - offset, 0, Pointer.addressOf(mappedData));
        
        if (result != VK_SUCCESS) {
            trace("Failed to map buffer for writing");
            return;
        }
        
        // Copy data
        cpp.NativeArray.setData(cast mappedData, 0, cast data, 0, cast(_size - offset));
        
        // Unmap
        Vulkan.unmapMemory(device, _memory);
    }
    
    /**
     * Update buffer data
     */
    public function update(data:cpp.Pointer<cpp.Void>, offset:Int, size:Int):Void {
        var device = _backend.getDevice();
        
        var mappedData:cpp.Pointer<cpp.Void> = null;
        var result = Vulkan.mapMemory(device, _memory, offset, size, 0, Pointer.addressOf(mappedData));
        
        if (result != VK_SUCCESS) {
            return;
        }
        
        cpp.NativeArray.setData(cast mappedData, 0, cast data, 0, size);
        Vulkan.unmapMemory(device, _memory);
    }
    
    /**
     * Get buffer size
     */
    public function getSize():Int {
        return cast _size;
    }
    
    /**
     * Get Vulkan buffer handle
     */
    public function getVkBuffer():VkBuffer {
        return _buffer;
    }
    
    /**
     * Dispose GPU resources
     */
    public function dispose():Void {
        var device = _backend.getDevice();
        
        if (_buffer != null) {
            Vulkan.destroyBuffer(device, _buffer, null);
        }
        
        if (_memory != null) {
            Vulkan.freeMemory(device, _memory, null);
        }
    }
}
