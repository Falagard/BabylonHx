package com.babylonhx.engine.graphics.directx12;

/**
 * DirectX 12 type definitions and structures
 * Provides Haxe-compatible wrappers for Direct3D 12 C++ API
 */

// COM Opaque Handles (IUnknown-based interfaces)
@:native("ID3D12Device")
extern class ID3D12Device {}

@:native("ID3D12CommandQueue")
extern class ID3D12CommandQueue {}

@:native("ID3D12CommandAllocator")
extern class ID3D12CommandAllocator {}

@:native("ID3D12GraphicsCommandList")
extern class ID3D12GraphicsCommandList {}

@:native("ID3D12RootSignature")
extern class ID3D12RootSignature {}

@:native("ID3D12PipelineState")
extern class ID3D12PipelineState {}

@:native("ID3D12Resource")
extern class ID3D12Resource {}

@:native("ID3D12DescriptorHeap")
extern class ID3D12DescriptorHeap {}

@:native("ID3D12Fence")
extern class ID3D12Fence {}

@:native("IDXGISwapChain4")
extern class IDXGISwapChain4 {}

@:native("IDXGIFactory7")
extern class IDXGIFactory7 {}

@:native("IDXGIAdapter4")
extern class IDXGIAdapter4 {}

@:native("ID3DBlob")
extern class ID3DBlob {}

// HRESULT typedef (COM standard)
typedef HRESULT = Int;

// Common Constants
class DirectXConstants {
    // HRESULT success code
    public static inline var S_OK:HRESULT = 0x00000000;
    
    // D3D12_COMMAND_LIST_TYPE
    public static inline var D3D12_COMMAND_LIST_TYPE_DIRECT:Int = 0;
    public static inline var D3D12_COMMAND_LIST_TYPE_BUNDLE:Int = 1;
    public static inline var D3D12_COMMAND_LIST_TYPE_COMPUTE:Int = 2;
    public static inline var D3D12_COMMAND_LIST_TYPE_COPY:Int = 3;
    
    // D3D12_DESCRIPTOR_HEAP_TYPE
    public static inline var D3D12_DESCRIPTOR_HEAP_TYPE_CBV_SRV_UAV:Int = 0;
    public static inline var D3D12_DESCRIPTOR_HEAP_TYPE_SAMPLER:Int = 1;
    public static inline var D3D12_DESCRIPTOR_HEAP_TYPE_RTV:Int = 2;
    public static inline var D3D12_DESCRIPTOR_HEAP_TYPE_DSV:Int = 3;
    
    // D3D12_HEAP_TYPE
    public static inline var D3D12_HEAP_TYPE_DEFAULT:Int = 1;
    public static inline var D3D12_HEAP_TYPE_UPLOAD:Int = 2;
    public static inline var D3D12_HEAP_TYPE_READBACK:Int = 3;
    
    // D3D12_RESOURCE_USAGE
    public static inline var D3D12_RESOURCE_USAGE_DEFAULT:Int = 0;
    public static inline var D3D12_RESOURCE_USAGE_IMMUTABLE:Int = 1;
    public static inline var D3D12_RESOURCE_USAGE_DYNAMIC:Int = 2;
    public static inline var D3D12_RESOURCE_USAGE_STAGING:Int = 3;
    
    // D3D12_RESOURCE_STATES
    public static inline var D3D12_RESOURCE_STATE_COMMON:Int = 0;
    public static inline var D3D12_RESOURCE_STATE_VERTEX_AND_CONSTANT_BUFFER:Int = 0x1;
    public static inline var D3D12_RESOURCE_STATE_INDEX_BUFFER:Int = 0x2;
    public static inline var D3D12_RESOURCE_STATE_RENDER_TARGET:Int = 0x4;
    public static inline var D3D12_RESOURCE_STATE_UNORDERED_ACCESS:Int = 0x8;
    public static inline var D3D12_RESOURCE_STATE_DEPTH_WRITE:Int = 0x10;
    public static inline var D3D12_RESOURCE_STATE_DEPTH_READ:Int = 0x20;
    public static inline var D3D12_RESOURCE_STATE_NON_PIXEL_SHADER_RESOURCE:Int = 0x40;
    public static inline var D3D12_RESOURCE_STATE_PIXEL_SHADER_RESOURCE:Int = 0x80;
    public static inline var D3D12_RESOURCE_STATE_STREAM_OUT:Int = 0x100;
    public static inline var D3D12_RESOURCE_STATE_INDIRECT_ARGUMENT:Int = 0x200;
    public static inline var D3D12_RESOURCE_STATE_COPY_DEST:Int = 0x400;
    public static inline var D3D12_RESOURCE_STATE_COPY_SOURCE:Int = 0x800;
    public static inline var D3D12_RESOURCE_STATE_RESOLVE_DEST:Int = 0x1000;
    public static inline var D3D12_RESOURCE_STATE_RESOLVE_SOURCE:Int = 0x2000;
    public static inline var D3D12_RESOURCE_STATE_GENERIC_READ:Int = 0x3F;
    public static inline var D3D12_RESOURCE_STATE_PRESENT:Int = 0;
    
    // D3D12_CLEAR_FLAGS
    public static inline var D3D12_CLEAR_FLAG_DEPTH:Int = 0x1;
    public static inline var D3D12_CLEAR_FLAG_STENCIL:Int = 0x2;
    
    // D3D12_CULL_MODE
    public static inline var D3D12_CULL_MODE_NONE:Int = 1;
    public static inline var D3D12_CULL_MODE_FRONT:Int = 2;
    public static inline var D3D12_CULL_MODE_BACK:Int = 3;
    
    // D3D12_COMPARISON_FUNC
    public static inline var D3D12_COMPARISON_FUNC_NEVER:Int = 1;
    public static inline var D3D12_COMPARISON_FUNC_LESS:Int = 2;
    public static inline var D3D12_COMPARISON_FUNC_EQUAL:Int = 3;
    public static inline var D3D12_COMPARISON_FUNC_LESS_EQUAL:Int = 4;
    public static inline var D3D12_COMPARISON_FUNC_GREATER:Int = 5;
    public static inline var D3D12_COMPARISON_FUNC_NOT_EQUAL:Int = 6;
    public static inline var D3D12_COMPARISON_FUNC_GREATER_EQUAL:Int = 7;
    public static inline var D3D12_COMPARISON_FUNC_ALWAYS:Int = 8;
    
    // DXGI_FORMAT (subset)
    public static inline var DXGI_FORMAT_UNKNOWN:Int = 0;
    public static inline var DXGI_FORMAT_R8G8B8A8_UNORM:Int = 28;
    public static inline var DXGI_FORMAT_R8G8B8A8_UNORM_SRGB:Int = 29;
    public static inline var DXGI_FORMAT_D32_FLOAT:Int = 40;
    public static inline var DXGI_FORMAT_D24_UNORM_S8_UINT:Int = 45;
    
    // D3D12_BLEND
    public static inline var D3D12_BLEND_ZERO:Int = 1;
    public static inline var D3D12_BLEND_ONE:Int = 2;
    public static inline var D3D12_BLEND_SRC_COLOR:Int = 3;
    public static inline var D3D12_BLEND_INV_SRC_COLOR:Int = 4;
    public static inline var D3D12_BLEND_SRC_ALPHA:Int = 5;
    public static inline var D3D12_BLEND_INV_SRC_ALPHA:Int = 6;
    public static inline var D3D12_BLEND_DEST_COLOR:Int = 9;
    public static inline var D3D12_BLEND_INV_DEST_COLOR:Int = 10;
    public static inline var D3D12_BLEND_DEST_ALPHA:Int = 11;
    public static inline var D3D12_BLEND_INV_DEST_ALPHA:Int = 12;
    
    // D3D12_BLEND_OP
    public static inline var D3D12_BLEND_OP_ADD:Int = 1;
    public static inline var D3D12_BLEND_OP_SUBTRACT:Int = 2;
    public static inline var D3D12_BLEND_OP_REV_SUBTRACT:Int = 3;
    public static inline var D3D12_BLEND_OP_MIN:Int = 4;
    public static inline var D3D12_BLEND_OP_MAX:Int = 5;
    
    // D3D12_COLOR_WRITE_ENABLE
    public static inline var D3D12_COLOR_WRITE_ENABLE_RED:Int = 1;
    public static inline var D3D12_COLOR_WRITE_ENABLE_GREEN:Int = 2;
    public static inline var D3D12_COLOR_WRITE_ENABLE_BLUE:Int = 4;
    public static inline var D3D12_COLOR_WRITE_ENABLE_ALPHA:Int = 8;
    public static inline var D3D12_COLOR_WRITE_ENABLE_ALL:Int = 0xF;
    
    // D3D12_DESCRIPTOR_HEAP_FLAGS
    public static inline var D3D12_DESCRIPTOR_HEAP_FLAG_NONE:Int = 0;
    public static inline var D3D12_DESCRIPTOR_HEAP_FLAG_SHADER_VISIBLE:Int = 1;
    
    // D3D_FEATURE_LEVEL
    public static inline var D3D_FEATURE_LEVEL_12_1:Int = 0xc100;
    public static inline var D3D_FEATURE_LEVEL_12_0:Int = 0xc000;
    
    // D3D12_SHADER_VISIBILITY
    public static inline var D3D12_SHADER_VISIBILITY_ALL:Int = 0;
    public static inline var D3D12_SHADER_VISIBILITY_VERTEX:Int = 1;
    public static inline var D3D12_SHADER_VISIBILITY_HULL:Int = 2;
    public static inline var D3D12_SHADER_VISIBILITY_DOMAIN:Int = 3;
    public static inline var D3D12_SHADER_VISIBILITY_GEOMETRY:Int = 4;
    public static inline var D3D12_SHADER_VISIBILITY_PIXEL:Int = 5;
    public static inline var D3D12_SHADER_VISIBILITY_AMPLIFICATION:Int = 6;
    public static inline var D3D12_SHADER_VISIBILITY_MESH:Int = 7;
}

// Structures

@:include("d3d12.h")
@:native("D3D12_COMMAND_QUEUE_DESC")
extern class D3D12_COMMAND_QUEUE_DESC {
    var Type:Int; // D3D12_COMMAND_LIST_TYPE
    var Priority:Int; // D3D12_COMMAND_QUEUE_PRIORITY
    var Flags:Int; // D3D12_COMMAND_QUEUE_FLAGS
    var NodeMask:Int;
}

@:include("d3d12.h")
@:native("D3D12_DESCRIPTOR_HEAP_DESC")
extern class D3D12_DESCRIPTOR_HEAP_DESC {
    var Type:Int; // D3D12_DESCRIPTOR_HEAP_TYPE
    var NumDescriptors:Int;
    var Flags:Int; // D3D12_DESCRIPTOR_HEAP_FLAGS
    var NodeMask:Int;
}

@:include("d3d12.h")
@:native("D3D12_RESOURCE_DESC")
extern class D3D12_RESOURCE_DESC {
    var Dimension:Int;
    var Alignment:Int;
    var Width:Int;
    var Height:Int;
    var DepthOrArraySize:Int;
    var MipLevels:Int;
    var Format:Int; // DXGI_FORMAT
    var SampleDesc:DXGI_SAMPLE_DESC;
    var Layout:Int; // D3D12_TEXTURE_LAYOUT
    var Flags:Int; // D3D12_RESOURCE_FLAGS
}

@:include("d3d12.h")
@:native("D3D12_HEAP_PROPERTIES")
extern class D3D12_HEAP_PROPERTIES {
    var Type:Int; // D3D12_HEAP_TYPE
    var CPUPageProperty:Int;
    var MemoryPoolPreference:Int;
    var CreationNodeMask:Int;
    var VisibleNodeMask:Int;
}

@:include("d3d12.h")
@:native("D3D12_CLEAR_VALUE")
extern class D3D12_CLEAR_VALUE {
    var Format:Int; // DXGI_FORMAT
    var Color:Array<Float>; // Float[4]
    var Depth:Float;
    var Stencil:Int;
}

@:include("d3d12.h")
@:native("D3D12_VIEWPORT")
extern class D3D12_VIEWPORT {
    var TopLeftX:Float;
    var TopLeftY:Float;
    var Width:Float;
    var Height:Float;
    var MinDepth:Float;
    var MaxDepth:Float;
}

@:include("d3d12.h")
@:native("D3D12_RECT")
extern class D3D12_RECT {
    var left:Int;
    var top:Int;
    var right:Int;
    var bottom:Int;
}

@:include("dxgi1_4.h")
@:native("DXGI_SAMPLE_DESC")
extern class DXGI_SAMPLE_DESC {
    var Count:Int;
    var Quality:Int;
}

@:include("dxgi1_4.h")
@:native("DXGI_RATIONAL")
extern class DXGI_RATIONAL {
    var Numerator:Int;
    var Denominator:Int;
}

@:include("dxgi1_4.h")
@:native("DXGI_MODE_DESC")
extern class DXGI_MODE_DESC {
    var Width:Int;
    var Height:Int;
    var RefreshRate:DXGI_RATIONAL;
    var Format:Int; // DXGI_FORMAT
    var ScanlineOrdering:Int;
    var Scaling:Int;
}

@:include("dxgi1_4.h")
@:native("DXGI_SWAP_CHAIN_DESC1")
extern class DXGI_SWAP_CHAIN_DESC1 {
    var Width:Int;
    var Height:Int;
    var Format:Int; // DXGI_FORMAT
    var Stereo:Bool;
    var SampleDesc:DXGI_SAMPLE_DESC;
    var BufferUsage:Int;
    var BufferCount:Int;
    var Scaling:Int;
    var SwapEffect:Int;
    var AlphaMode:Int;
    var Flags:Int;
}

@:include("d3d12.h")
@:native("D3D12_COMMAND_BUFFER_ALLOCATE_INFO")
extern class D3D12_COMMAND_BUFFER_ALLOCATE_INFO {
    var Level:Int;
    var CommandBufferCount:Int;
}

@:include("d3d12.h")
@:native("D3D12_BUFFER_BARRIER")
extern class D3D12_BUFFER_BARRIER {
    var pResource:ID3D12Resource;
    var Offset:Int;
    var Size:Int;
    var StateBefore:Int; // D3D12_RESOURCE_STATES
    var StateAfter:Int; // D3D12_RESOURCE_STATES
}

@:include("d3d12.h")
@:native("D3D12_RASTERIZER_DESC")
extern class D3D12_RASTERIZER_DESC {
    var FillMode:Int;
    var CullMode:Int; // D3D12_CULL_MODE
    var FrontCounterClockwise:Bool;
    var DepthBias:Int;
    var DepthBiasClamp:Float;
    var SlopeScaledDepthBias:Float;
    var DepthClipEnable:Bool;
    var MultisampleEnable:Bool;
    var AntialiasedLineEnable:Bool;
    var ForcedSampleCount:Int;
    var ConservativeRaster:Int;
}

@:include("d3d12.h")
@:native("D3D12_DEPTH_STENCIL_DESC")
extern class D3D12_DEPTH_STENCIL_DESC {
    var DepthEnable:Bool;
    var DepthWriteMask:Int;
    var DepthFunc:Int; // D3D12_COMPARISON_FUNC
    var StencilEnable:Bool;
    var StencilReadMask:Int;
    var StencilWriteMask:Int;
    // FrontFace and BackFace would be D3D12_DEPTH_STENCILOP_DESC
}

@:include("d3d12.h")
@:native("D3D12_BLEND_DESC")
extern class D3D12_BLEND_DESC {
    var AlphaToCoverageEnable:Bool;
    var IndependentBlendEnable:Bool;
    // RenderTarget array would go here
}

@:include("d3d12.h")
@:native("D3D12_GRAPHICS_PIPELINE_STATE_DESC")
extern class D3D12_GRAPHICS_PIPELINE_STATE_DESC {
    var pRootSignature:ID3D12RootSignature;
    var VS:D3D12_SHADER_BYTECODE;
    var PS:D3D12_SHADER_BYTECODE;
    var GS:D3D12_SHADER_BYTECODE;
    var HS:D3D12_SHADER_BYTECODE;
    var DS:D3D12_SHADER_BYTECODE;
    var StreamOutput:D3D12_STREAM_OUTPUT_DESC;
    var BlendState:D3D12_BLEND_DESC;
    var SampleMask:Int;
    var RasterizerState:D3D12_RASTERIZER_DESC;
    var DepthStencilState:D3D12_DEPTH_STENCIL_DESC;
    var InputLayout:D3D12_INPUT_LAYOUT_DESC;
    var IBStripCutValue:Int;
    var PrimitiveTopologyType:Int;
    var NumRenderTargets:Int;
    var RTVFormats:Array<Int>; // DXGI_FORMAT[8]
    var DSVFormat:Int; // DXGI_FORMAT
    var SampleDesc:DXGI_SAMPLE_DESC;
    var NodeMask:Int;
    var CachedPSO:D3D12_CACHED_PIPELINE_STATE;
    var Flags:Int;
}

@:include("d3d12.h")
@:native("D3D12_SHADER_BYTECODE")
extern class D3D12_SHADER_BYTECODE {
    var pShaderBytecode:cpp.Pointer<Void>;
    var BytecodeLength:Int;
}

@:include("d3d12.h")
@:native("D3D12_STREAM_OUTPUT_DESC")
extern class D3D12_STREAM_OUTPUT_DESC {
    var pSODeclaration:cpp.Pointer<Void>;
    var NumEntries:Int;
    var pBufferStrides:cpp.Pointer<Int>;
    var NumStrides:Int;
    var RasterizedStream:Int;
}

@:include("d3d12.h")
@:native("D3D12_INPUT_LAYOUT_DESC")
extern class D3D12_INPUT_LAYOUT_DESC {
    var pInputElementDescs:cpp.Pointer<Void>;
    var NumElements:Int;
}

@:include("d3d12.h")
@:native("D3D12_CACHED_PIPELINE_STATE")
extern class D3D12_CACHED_PIPELINE_STATE {
    var pCachedBlob:cpp.Pointer<Void>;
    var CachedBlobSizeInBytes:Int;
}

@:include("d3d12.h")
@:native("D3D12_FENCE_DESC")
extern class D3D12_FENCE_DESC {
    var InitialValue:Int;
    var Flags:Int; // D3D12_FENCE_FLAGS
}

@:include("d3d12.h")
@:native("D3D12_RENDER_TARGET_VIEW_DESC")
extern class D3D12_RENDER_TARGET_VIEW_DESC {
    var Format:Int; // DXGI_FORMAT
    var ViewDimension:Int; // D3D12_RTV_DIMENSION
    // Union for different texture types would go here
}

@:include("d3d12.h")
@:native("D3D12_DEPTH_STENCIL_VIEW_DESC")
extern class D3D12_DEPTH_STENCIL_VIEW_DESC {
    var Format:Int; // DXGI_FORMAT
    var ViewDimension:Int; // D3D12_DSV_DIMENSION
    var Flags:Int;
    // Union for different texture types would go here
}
