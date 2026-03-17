package com.babylonhx.engine.graphics.vulkan;

/**
 * Vulkan opaque type handles and structures.
 * These are used for FFI bindings to Vulkan C API.
 */

// Opaque handles (pointers to implementation-specific data)
@:include("vulkan/vulkan.h")
extern class VkInstance {}

@:include("vulkan/vulkan.h")
extern class VkPhysicalDevice {}

@:include("vulkan/vulkan.h")
extern class VkDevice {}

@:include("vulkan/vulkan.h")
extern class VkQueue {}

@:include("vulkan/vulkan.h")
extern class VkSurfaceKHR {}

@:include("vulkan/vulkan.h")
extern class VkSwapchainKHR {}

@:include("vulkan/vulkan.h")
extern class VkImage {}

@:include("vulkan/vulkan.h")
extern class VkImageView {}

@:include("vulkan/vulkan.h")
extern class VkBuffer {}

@:include("vulkan/vulkan.h")
extern class VkDeviceMemory {}

@:include("vulkan/vulkan.h")
extern class VkSampler {}

@:include("vulkan/vulkan.h")
extern class VkCommandPool {}

@:include("vulkan/vulkan.h")
extern class VkCommandBuffer {}

@:include("vulkan/vulkan.h")
extern class VkShaderModule {}

@:include("vulkan/vulkan.h")
extern class VkPipelineLayout {}

@:include("vulkan/vulkan.h")
extern class VkPipeline {}

@:include("vulkan/vulkan.h")
extern class VkFramebuffer {}

@:include("vulkan/vulkan.h")
extern class VkRenderPass {}

@:include("vulkan/vulkan.h")
extern class VkDescriptorSetLayout {}

@:include("vulkan/vulkan.h")
extern class VkDescriptorPool {}

@:include("vulkan/vulkan.h")
extern class VkDescriptorSet {}

@:include("vulkan/vulkan.h")
extern class VkFence {}

@:include("vulkan/vulkan.h")
extern class VkSemaphore {}

// Core type definitions
typedef VkResult = Int;
typedef VkFlags = Int;
typedef VkDeviceSize = Int64;
typedef VkSampleCountFlags = Int;

// Vulkan version encoding
function VK_MAKE_VERSION(major:Int, minor:Int, patch:Int):Int {
    return ((major) << 22) | ((minor) << 12) | (patch);
}

// Version info
final VK_API_VERSION_1_0 = VK_MAKE_VERSION(1, 0, 0);
final VK_API_VERSION_1_1 = VK_MAKE_VERSION(1, 1, 0);
final VK_API_VERSION_1_2 = VK_MAKE_VERSION(1, 2, 0);

// VkResult codes
final VK_SUCCESS = 0;
final VK_NOT_READY = 1;
final VK_TIMEOUT = 2;
final VK_EVENT_SET = 3;
final VK_EVENT_RESET = 4;
final VK_INCOMPLETE = 5;
final VK_ERROR_OUT_OF_HOST_MEMORY = -1;
final VK_ERROR_OUT_OF_DEVICE_MEMORY = -2;
final VK_ERROR_INITIALIZATION_FAILED = -3;
final VK_ERROR_DEVICE_LOST = -4;
final VK_ERROR_MEMORY_MAP_FAILED = -5;
final VK_ERROR_LAYER_NOT_PRESENT = -6;
final VK_ERROR_EXTENSION_NOT_PRESENT = -7;
final VK_ERROR_FEATURE_NOT_PRESENT = -8;
final VK_ERROR_INCOMPATIBLE_DRIVER = -9;
final VK_ERROR_TOO_MANY_OBJECTS = -10;
final VK_ERROR_FORMAT_NOT_SUPPORTED = -11;

// Image formats
final VK_FORMAT_UNDEFINED = 0;
final VK_FORMAT_R8G8B8A8_SRGB = 43;
final VK_FORMAT_B8G8R8A8_UNORM = 44;
final VK_FORMAT_D32_SFLOAT = 126;
final VK_FORMAT_D24_UNORM_S8_UINT = 129;

// Color spaces
final VK_COLORSPACE_SRGB_NONLINEAR_KHR = 0;

// Presentation modes
final VK_PRESENT_MODE_IMMEDIATE_KHR = 0;
final VK_PRESENT_MODE_MAILBOX_KHR = 1;
final VK_PRESENT_MODE_FIFO_KHR = 2;
final VK_PRESENT_MODE_FIFO_RELAXED_KHR = 3;

// Queue types
final VK_QUEUE_GRAPHICS_BIT = 0x00000001;
final VK_QUEUE_COMPUTE_BIT = 0x00000002;
final VK_QUEUE_TRANSFER_BIT = 0x00000004;
final VK_QUEUE_SPARSE_BINDING_BIT = 0x00000008;

// Memory types
final VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT = 0x00000001;
final VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT = 0x00000002;
final VK_MEMORY_PROPERTY_HOST_COHERENT_BIT = 0x00000004;
final VK_MEMORY_PROPERTY_HOST_CACHED_BIT = 0x00000008;
final VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT = 0x00000010;

// Buffer usage
final VK_BUFFER_USAGE_TRANSFER_DST_BIT = 0x00000001;
final VK_BUFFER_USAGE_TRANSFER_SRC_BIT = 0x00000002;
final VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT = 0x00000008;
final VK_BUFFER_USAGE_STORAGE_BUFFER_BIT = 0x00000010;
final VK_BUFFER_USAGE_INDEX_BUFFER_BIT = 0x00000020;
final VK_BUFFER_USAGE_VERTEX_BUFFER_BIT = 0x00000040;
final VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT = 0x00000080;

// Image usage
final VK_IMAGE_USAGE_TRANSFER_DST_BIT = 0x00000001;
final VK_IMAGE_USAGE_TRANSFER_SRC_BIT = 0x00000002;
final VK_IMAGE_USAGE_SAMPLED_BIT = 0x00000004;
final VK_IMAGE_USAGE_STORAGE_BIT = 0x00000008;
final VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT = 0x00000010;
final VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT = 0x00000020;

// Image aspects
final VK_IMAGE_ASPECT_COLOR_BIT = 0x00000001;
final VK_IMAGE_ASPECT_DEPTH_BIT = 0x00000002;
final VK_IMAGE_ASPECT_STENCIL_BIT = 0x00000004;

// Shader stages
final VK_SHADER_STAGE_VERTEX_BIT = 0x00000001;
final VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT = 0x00000002;
final VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT = 0x00000004;
final VK_SHADER_STAGE_GEOMETRY_BIT = 0x00000008;
final VK_SHADER_STAGE_FRAGMENT_BIT = 0x00000010;
final VK_SHADER_STAGE_COMPUTE_BIT = 0x00000020;

// Command buffer levels
final VK_COMMAND_BUFFER_LEVEL_PRIMARY = 0;
final VK_COMMAND_BUFFER_LEVEL_SECONDARY = 1;

// Pipeline bind point
final VK_PIPELINE_BIND_POINT_GRAPHICS = 0;
final VK_PIPELINE_BIND_POINT_COMPUTE = 1;

// Cull modes
final VK_CULL_MODE_NONE = 0;
final VK_CULL_MODE_FRONT_BIT = 0x00000001;
final VK_CULL_MODE_BACK_BIT = 0x00000002;
final VK_CULL_MODE_FRONT_AND_BACK = 0x00000003;

// Front face
final VK_FRONT_FACE_COUNTER_CLOCKWISE = 0;
final VK_FRONT_FACE_CLOCKWISE = 1;

// Compare ops
final VK_COMPARE_OP_NEVER = 0;
final VK_COMPARE_OP_LESS = 1;
final VK_COMPARE_OP_EQUAL = 2;
final VK_COMPARE_OP_LESS_OR_EQUAL = 3;
final VK_COMPARE_OP_GREATER = 4;
final VK_COMPARE_OP_NOT_EQUAL = 5;
final VK_COMPARE_OP_GREATER_OR_EQUAL = 6;
final VK_COMPARE_OP_ALWAYS = 7;

// Stencil ops
final VK_STENCIL_OP_KEEP = 0;
final VK_STENCIL_OP_ZERO = 1;
final VK_STENCIL_OP_REPLACE = 2;
final VK_STENCIL_OP_INCREMENT_AND_CLAMP = 3;
final VK_STENCIL_OP_DECREMENT_AND_CLAMP = 4;
final VK_STENCIL_OP_INVERT = 5;
final VK_STENCIL_OP_INCREMENT_AND_WRAP = 6;
final VK_STENCIL_OP_DECREMENT_AND_WRAP = 7;

// Blend factors
final VK_BLEND_FACTOR_ZERO = 0;
final VK_BLEND_FACTOR_ONE = 1;
final VK_BLEND_FACTOR_SRC_COLOR = 2;
final VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR = 3;
final VK_BLEND_FACTOR_DST_COLOR = 4;
final VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR = 5;
final VK_BLEND_FACTOR_SRC_ALPHA = 6;
final VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA = 7;
final VK_BLEND_FACTOR_DST_ALPHA = 8;
final VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA = 9;

// Blend ops
final VK_BLEND_OP_ADD = 0;
final VK_BLEND_OP_SUBTRACT = 1;
final VK_BLEND_OP_REVERSE_SUBTRACT = 2;
final VK_BLEND_OP_MIN = 3;
final VK_BLEND_OP_MAX = 4;

// Attachment load ops
final VK_ATTACHMENT_LOAD_OP_LOAD = 0;
final VK_ATTACHMENT_LOAD_OP_CLEAR = 1;
final VK_ATTACHMENT_LOAD_OP_DONT_CARE = 2;

// Attachment store ops
final VK_ATTACHMENT_STORE_OP_STORE = 0;
final VK_ATTACHMENT_STORE_OP_DONT_CARE = 1;

// Image layouts
final VK_IMAGE_LAYOUT_UNDEFINED = 0;
final VK_IMAGE_LAYOUT_GENERAL = 1;
final VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL = 2;
final VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL = 3;
final VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL = 4;
final VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL = 5;
final VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL = 6;
final VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL = 7;
final VK_IMAGE_LAYOUT_PREINITIALIZED = 8;
final VK_IMAGE_LAYOUT_PRESENT_SRC_KHR = 1000001002;

// Descriptor types
final VK_DESCRIPTOR_TYPE_SAMPLER = 0;
final VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER = 1;
final VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE = 2;
final VK_DESCRIPTOR_TYPE_STORAGE_IMAGE = 3;
final VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER = 4;
final VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER = 5;
final VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER = 6;
final VK_DESCRIPTOR_TYPE_STORAGE_BUFFER = 7;
final VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC = 8;
final VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC = 9;
final VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT = 10;

// Vertex input rate
final VK_VERTEX_INPUT_RATE_VERTEX = 0;
final VK_VERTEX_INPUT_RATE_INSTANCE = 1;

// Structures
@:include("vulkan/vulkan.h")
@:native("VkApplicationInfo")
extern class VkApplicationInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var pApplicationName:cpp.Pointer<cpp.Char>;
    var applicationVersion:Int;
    var pEngineName:cpp.Pointer<cpp.Char>;
    var engineVersion:Int;
    var apiVersion:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkInstanceCreateInfo")
extern class VkInstanceCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var pApplicationInfo:cpp.Pointer<VkApplicationInfo>;
    var enabledLayerCount:Int;
    var ppEnabledLayerNames:cpp.Pointer<cpp.Pointer<cpp.Char>>;
    var enabledExtensionCount:Int;
    var ppEnabledExtensionNames:cpp.Pointer<cpp.Pointer<cpp.Char>>;
}

@:include("vulkan/vulkan.h")
@:native("VkPhysicalDeviceProperties")
extern class VkPhysicalDeviceProperties {
    var apiVersion:Int;
    var driverVersion:Int;
    var vendorID:Int;
    var deviceID:Int;
    var deviceType:Int;
    var deviceName:cpp.Char;
    var pipelineCacheUUID:cpp.Char;
    var limits:VkPhysicalDeviceLimits;
    var sparseProperties:VkPhysicalDeviceSparseProperties;
}

@:include("vulkan/vulkan.h")
@:native("VkPhysicalDeviceLimits")
extern class VkPhysicalDeviceLimits {}

@:include("vulkan/vulkan.h")
@:native("VkPhysicalDeviceSparseProperties")
extern class VkPhysicalDeviceSparseProperties {}

@:include("vulkan/vulkan.h")
@:native("VkPhysicalDeviceMemoryProperties")
extern class VkPhysicalDeviceMemoryProperties {
    var memoryTypeCount:Int;
    var memoryTypes:cpp.ConstPointer<VkMemoryType>;
    var memoryHeapCount:Int;
    var memoryHeaps:cpp.ConstPointer<VkMemoryHeap>;
}

@:include("vulkan/vulkan.h")
@:native("VkMemoryType")
extern class VkMemoryType {
    var propertyFlags:Int;
    var heapIndex:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkMemoryHeap")
extern class VkMemoryHeap {
    var size:VkDeviceSize;
    var flags:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkQueueFamilyProperties")
extern class VkQueueFamilyProperties {
    var queueFlags:Int;
    var queueCount:Int;
    var timestampValidBits:Int;
    var minImageTransferGranularity:VkExtent3D;
}

@:include("vulkan/vulkan.h")
@:native("VkExtent3D")
extern class VkExtent3D {
    var width:Int;
    var height:Int;
    var depth:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkExtent2D")
extern class VkExtent2D {
    var width:Int;
    var height:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkDeviceQueueCreateInfo")
extern class VkDeviceQueueCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var queueFamilyIndex:Int;
    var queueCount:Int;
    var pQueuePriorities:cpp.Pointer<cpp.Float32>;
}

@:include("vulkan/vulkan.h")
@:native("VkPhysicalDeviceFeatures")
extern class VkPhysicalDeviceFeatures {}

@:include("vulkan/vulkan.h")
@:native("VkDeviceCreateInfo")
extern class VkDeviceCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var queueCreateInfoCount:Int;
    var pQueueCreateInfos:cpp.Pointer<VkDeviceQueueCreateInfo>;
    var enabledLayerCount:Int;
    var ppEnabledLayerNames:cpp.Pointer<cpp.Pointer<cpp.Char>>;
    var enabledExtensionCount:Int;
    var ppEnabledExtensionNames:cpp.Pointer<cpp.Pointer<cpp.Char>>;
    var pEnabledFeatures:cpp.Pointer<VkPhysicalDeviceFeatures>;
}

@:include("vulkan/vulkan.h")
@:native("VkMemoryRequirements")
extern class VkMemoryRequirements {
    var size:VkDeviceSize;
    var alignment:VkDeviceSize;
    var memoryTypeBits:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkBufferCreateInfo")
extern class VkBufferCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var size:VkDeviceSize;
    var usage:Int;
    var sharingMode:Int;
    var queueFamilyIndexCount:Int;
    var pQueueFamilyIndices:cpp.Pointer<Int>;
}

@:include("vulkan/vulkan.h")
@:native("VkMemoryAllocateInfo")
extern class VkMemoryAllocateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var allocationSize:VkDeviceSize;
    var memoryTypeIndex:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkImageCreateInfo")
extern class VkImageCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var imageType:Int;
    var format:Int;
    var extent:VkExtent3D;
    var mipLevels:Int;
    var arrayLayers:Int;
    var samples:Int;
    var tiling:Int;
    var usage:Int;
    var sharingMode:Int;
    var queueFamilyIndexCount:Int;
    var pQueueFamilyIndices:cpp.Pointer<Int>;
    var initialLayout:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkImageViewCreateInfo")
extern class VkImageViewCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var image:VkImage;
    var viewType:Int;
    var format:Int;
    var components:VkComponentMapping;
    var subresourceRange:VkImageSubresourceRange;
}

@:include("vulkan/vulkan.h")
@:native("VkComponentMapping")
extern class VkComponentMapping {
    var r:Int;
    var g:Int;
    var b:Int;
    var a:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkImageSubresourceRange")
extern class VkImageSubresourceRange {
    var aspectMask:Int;
    var baseMipLevel:Int;
    var levelCount:Int;
    var baseArrayLayer:Int;
    var layerCount:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkCommandPoolCreateInfo")
extern class VkCommandPoolCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var queueFamilyIndex:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkCommandBufferAllocateInfo")
extern class VkCommandBufferAllocateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var commandPool:VkCommandPool;
    var level:Int;
    var commandBufferCount:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkShaderModuleCreateInfo")
extern class VkShaderModuleCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var codeSize:Int;
    var pCode:cpp.Pointer<Int>;
}

@:include("vulkan/vulkan.h")
@:native("VkVertexInputBindingDescription")
extern class VkVertexInputBindingDescription {
    var binding:Int;
    var stride:Int;
    var inputRate:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkVertexInputAttributeDescription")
extern class VkVertexInputAttributeDescription {
    var location:Int;
    var binding:Int;
    var format:Int;
    var offset:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorSetLayoutBinding")
extern class VkDescriptorSetLayoutBinding {
    var binding:Int;
    var descriptorType:Int;
    var descriptorCount:Int;
    var stageFlags:Int;
    var pImmutableSamplers:cpp.Pointer<VkSampler>;
}

@:include("vulkan/vulkan.h")
@:native("VkDescriptorSetLayoutCreateInfo")
extern class VkDescriptorSetLayoutCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var bindingCount:Int;
    var pBindings:cpp.Pointer<VkDescriptorSetLayoutBinding>;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineLayoutCreateInfo")
extern class VkPipelineLayoutCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var setLayoutCount:Int;
    var pSetLayouts:cpp.Pointer<VkDescriptorSetLayout>;
    var pushConstantRangeCount:Int;
    var pPushConstantRanges:cpp.Pointer<VkPushConstantRange>;
}

@:include("vulkan/vulkan.h")
@:native("VkPushConstantRange")
extern class VkPushConstantRange {
    var stageFlags:Int;
    var offset:Int;
    var size:Int;
}

@:include("vulkan/vulkan.h")
@:native("VkPipelineShaderStageCreateInfo")
extern class VkPipelineShaderStageCreateInfo {
    var sType:Int;
    var pNext:cpp.Pointer<Void>;
    var flags:Int;
    var stage:Int;
    var module:VkShaderModule;
    var pName:cpp.Pointer<cpp.Char>;
    var pSpecializationInfo:cpp.Pointer<VkSpecializationInfo>;
}

@:include("vulkan/vulkan.h")
@:native("VkSpecializationInfo")
extern class VkSpecializationInfo {
    var mapEntryCount:Int;
    var pMapEntries:cpp.Pointer<VkSpecializationMapEntry>;
    var dataSize:Int;
    var pData:cpp.Pointer<Void>;
}

@:include("vulkan/vulkan.h")
@:native("VkSpecializationMapEntry")
extern class VkSpecializationMapEntry {
    var constantID:Int;
    var offset:Int;
    var size:Int;
}

// Data structure types
final VK_STRUCTURE_TYPE_APPLICATION_INFO = 0;
final VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO = 1;
final VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO = 2;
final VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO = 3;
final VK_STRUCTURE_TYPE_SUBMIT_INFO = 4;
final VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO = 5;
final VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE = 6;
final VK_STRUCTURE_TYPE_BIND_SPARSE_INFO = 7;
final VK_STRUCTURE_TYPE_FENCE_CREATE_INFO = 8;
final VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO = 9;
final VK_STRUCTURE_TYPE_EVENT_CREATE_INFO = 10;
final VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO = 11;
final VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO = 12;
final VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO = 13;
final VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO = 14;
final VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO = 15;
final VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO = 16;
final VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO = 17;
final VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO = 18;
final VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO = 19;
final VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO = 20;
final VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO = 21;
final VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO = 22;
final VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO = 23;
final VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO = 24;
final VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO = 25;
final VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO = 26;
final VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO = 27;
final VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO = 28;
final VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO = 29;
final VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO = 30;
final VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO = 31;
final VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO = 32;
final VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO = 33;
final VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO = 34;
final VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET = 35;
final VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET = 36;
final VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO = 37;
final VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO = 38;
final VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO = 39;
final VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO = 40;
final VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO = 41;
final VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO = 42;
final VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO = 43;
final VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER = 44;
final VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER = 45;
final VK_STRUCTURE_TYPE_MEMORY_BARRIER = 46;

// Sharing mode
final VK_SHARING_MODE_EXCLUSIVE = 0;
final VK_SHARING_MODE_CONCURRENT = 1;

// Image tiling
final VK_IMAGE_TILING_OPTIMAL = 0;
final VK_IMAGE_TILING_LINEAR = 1;

// Image type
final VK_IMAGE_TYPE_1D = 0;
final VK_IMAGE_TYPE_2D = 1;
final VK_IMAGE_TYPE_3D = 2;

// Image view type
final VK_IMAGE_VIEW_TYPE_1D = 0;
final VK_IMAGE_VIEW_TYPE_2D = 1;
final VK_IMAGE_VIEW_TYPE_3D = 2;
final VK_IMAGE_VIEW_TYPE_CUBE = 3;
final VK_IMAGE_VIEW_TYPE_1D_ARRAY = 4;
final VK_IMAGE_VIEW_TYPE_2D_ARRAY = 5;
final VK_IMAGE_VIEW_TYPE_CUBE_ARRAY = 6;

// Component swizzle
final VK_COMPONENT_SWIZZLE_IDENTITY = 0;
final VK_COMPONENT_SWIZZLE_ZERO = 1;
final VK_COMPONENT_SWIZZLE_ONE = 2;
final VK_COMPONENT_SWIZZLE_R = 3;
final VK_COMPONENT_SWIZZLE_G = 4;
final VK_COMPONENT_SWIZZLE_B = 5;
final VK_COMPONENT_SWIZZLE_A = 6;

// Sample count
final VK_SAMPLE_COUNT_1_BIT = 0x00000001;
final VK_SAMPLE_COUNT_2_BIT = 0x00000002;
final VK_SAMPLE_COUNT_4_BIT = 0x00000004;
final VK_SAMPLE_COUNT_8_BIT = 0x00000008;
final VK_SAMPLE_COUNT_16_BIT = 0x00000010;
final VK_SAMPLE_COUNT_32_BIT = 0x00000020;
final VK_SAMPLE_COUNT_64_BIT = 0x00000040;
