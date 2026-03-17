package com.babylonhx.engine.graphics.directx12;

import cpp.RawPointer;

/**
 * DirectX 12 FFI bindings
 * Provides Haxe-side declarations for Direct3D 12 C++ API functions
 */

@:headerCode("
#include <d3d12.h>
#include <dxgi1_4.h>
#include <dxgi1_6.h>
#include <winuser.h>
#include <wrl/client.h>

using Microsoft::WRL::ComPtr;
")
extern class DirectXBindings {
    // ============================================================
    // DXGI Factory Methods
    // ============================================================
    
    /**
     * Create a DXGI factory for enumerating adapters and creating swapchains
     * Output parameter receives pointer to IDXGIFactory7
     */
    @:native("CreateDXGIFactory")
    public static function CreateDXGIFactory(
        iid:Int, // IID_PPV_ARGS(&factory)
        ppFactory:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Get default DXGI adapter (GPU)
     * Output parameter receives pointer to IDXGIAdapter4
     */
    @:native("DXGIGetAdapter")
    public static function DXGIGetAdapter(
        factory:cpp.RawPointer<Void>, // IDXGIFactory7*
        index:Int,
        ppAdapter:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    // ============================================================
    // Device Creation
    // ============================================================
    
    /**
     * Create a Direct3D 12 device
     * Requires adapter, feature level, and output device pointer
     */
    @:native("D3D12CreateDevice")
    public static function D3D12CreateDevice(
        pAdapter:cpp.RawPointer<Void>, // IDXGIAdapter*
        minimumFeatureLevel:Int, // D3D_FEATURE_LEVEL
        riid:Int, // IID_PPV_ARGS(&device)
        ppDevice:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Get device capabilities and limits
     */
    @:native("D3D12GetDeviceCapabilities")
    public static function D3D12GetDeviceCapabilities(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pCapabilities:cpp.RawPointer<Void>
    ):Int; // HRESULT
    
    // ============================================================
    // Command Queue Management
    // ============================================================
    
    /**
     * Create a command queue for recording and executing commands
     */
    @:native("D3D12CreateCommandQueue")
    public static function D3D12CreateCommandQueue(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pDesc:cpp.RawPointer<Void>, // const D3D12_COMMAND_QUEUE_DESC*
        riid:Int, // IID_PPV_ARGS(&queue)
        ppQueue:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Execute command lists on a command queue
     */
    @:native("D3D12ExecuteCommandLists")
    public static function D3D12ExecuteCommandLists(
        pQueue:cpp.RawPointer<Void>, // ID3D12CommandQueue*
        numCommandLists:Int,
        ppCommandLists:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Void;
    
    /**
     * Signal fence from command queue (GPU-side)
     */
    @:native("D3D12SignalFence")
    public static function D3D12SignalFence(
        pQueue:cpp.RawPointer<Void>, // ID3D12CommandQueue*
        pFence:cpp.RawPointer<Void>, // ID3D12Fence*
        value:Int
    ):Int; // HRESULT
    
    /**
     * Wait for fence on CPU
     */
    @:native("D3D12WaitFence")
    public static function D3D12WaitFence(
        pFence:cpp.RawPointer<Void>, // ID3D12Fence*
        value:Int,
        maxWaitMs:Int
    ):Int; // HRESULT
    
    // ============================================================
    // Command Allocator & List
    // ============================================================
    
    /**
     * Create a command allocator for recording commands
     */
    @:native("D3D12CreateCommandAllocator")
    public static function D3D12CreateCommandAllocator(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        type:Int, // D3D12_COMMAND_LIST_TYPE
        riid:Int, // IID_PPV_ARGS(&allocator)
        ppAllocator:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Reset command allocator for reuse
     */
    @:native("D3D12ResetCommandAllocator")
    public static function D3D12ResetCommandAllocator(
        pAllocator:cpp.RawPointer<Void> // ID3D12CommandAllocator*
    ):Int; // HRESULT
    
    /**
     * Create a graphics command list for recording draw commands
     */
    @:native("D3D12CreateCommandList")
    public static function D3D12CreateCommandList(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        nodeMask:Int,
        type:Int, // D3D12_COMMAND_LIST_TYPE
        pCommandAllocator:cpp.RawPointer<Void>, // ID3D12CommandAllocator*
        pInitialState:cpp.RawPointer<Void>, // ID3D12PipelineState*
        riid:Int, // IID_PPV_ARGS(&cmdList)
        ppCommandList:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Close command list (finalize recording)
     */
    @:native("D3D12CloseCommandList")
    public static function D3D12CloseCommandList(
        pCommandList:cpp.RawPointer<Void> // ID3D12GraphicsCommandList*
    ):Int; // HRESULT
    
    /**
     * Reset command list for reuse
     */
    @:native("D3D12ResetCommandList")
    public static function D3D12ResetCommandList(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        pAllocator:cpp.RawPointer<Void> // ID3D12CommandAllocator*
    ):Int; // HRESULT
    
    // ============================================================
    // Resource Creation
    // ============================================================
    
    /**
     * Create a committed resource (buffer or texture)
     * Automatically allocates heap memory
     */
    @:native("D3D12CreateCommittedResource")
    public static function D3D12CreateCommittedResource(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pHeapProperties:cpp.RawPointer<Void>, // const D3D12_HEAP_PROPERTIES*
        heapFlags:Int,
        pDesc:cpp.RawPointer<Void>, // const D3D12_RESOURCE_DESC*
        initialState:Int, // D3D12_RESOURCE_STATES
        pOptimizedClearValue:cpp.RawPointer<Void>, // const D3D12_CLEAR_VALUE*
        riid:Int, // IID_PPV_ARGS(&resource)
        ppvResource:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Map resource memory for CPU access
     */
    @:native("D3D12MapResource")
    public static function D3D12MapResource(
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        subresource:Int,
        pReadRange:cpp.RawPointer<Void>, // const D3D12_RANGE*
        ppData:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Unmap resource memory
     */
    @:native("D3D12UnmapResource")
    public static function D3D12UnmapResource(
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        subresource:Int,
        pWrittenRange:cpp.RawPointer<Void> // const D3D12_RANGE*
    ):Void;
    
    /**
     * Get GPU virtual address for a resource
     */
    @:native("D3D12GetResourceGPUVirtualAddress")
    public static function D3D12GetResourceGPUVirtualAddress(
        pResource:cpp.RawPointer<Void> // ID3D12Resource*
    ):Int; // D3D12_GPU_VIRTUAL_ADDRESS (64-bit)
    
    // ============================================================
    // Descriptor Heap Management
    // ============================================================
    
    /**
     * Create a descriptor heap (for CBV/SRV/UAV, samplers, RTV, or DSV)
     */
    @:native("D3D12CreateDescriptorHeap")
    public static function D3D12CreateDescriptorHeap(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pDescriptorHeapDesc:cpp.RawPointer<Void>, // const D3D12_DESCRIPTOR_HEAP_DESC*
        riid:Int, // IID_PPV_ARGS(&heap)
        ppDescriptorHeap:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Get increment size for descriptors of a given type
     */
    @:native("D3D12GetDescriptorHandleIncrementSize")
    public static function D3D12GetDescriptorHandleIncrementSize(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        descriptorHeapType:Int // D3D12_DESCRIPTOR_HEAP_TYPE
    ):Int;
    
    /**
     * Get CPU descriptor handle at heap start
     */
    @:native("D3D12GetCPUDescriptorHandleForHeapStart")
    public static function D3D12GetCPUDescriptorHandleForHeapStart(
        pDescriptorHeap:cpp.RawPointer<Void>, // ID3D12DescriptorHeap*
        pHandle:cpp.RawPointer<Void> // D3D12_CPU_DESCRIPTOR_HANDLE*
    ):Void;
    
    /**
     * Get GPU descriptor handle at heap start
     */
    @:native("D3D12GetGPUDescriptorHandleForHeapStart")
    public static function D3D12GetGPUDescriptorHandleForHeapStart(
        pDescriptorHeap:cpp.RawPointer<Void>, // ID3D12DescriptorHeap*
        pHandle:cpp.RawPointer<Void> // D3D12_GPU_DESCRIPTOR_HANDLE*
    ):Void;
    
    // ============================================================
    // Descriptor Creation
    // ============================================================
    
    /**
     * Create constant buffer view (CBV) descriptor
     */
    @:native("D3D12CreateConstantBufferView")
    public static function D3D12CreateConstantBufferView(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pDesc:cpp.RawPointer<Void>, // const D3D12_CONSTANT_BUFFER_VIEW_DESC*
        destHandle:Void // D3D12_CPU_DESCRIPTOR_HANDLE (passed by value)
    ):Void;
    
    /**
     * Create shader resource view (SRV) descriptor
     */
    @:native("D3D12CreateShaderResourceView")
    public static function D3D12CreateShaderResourceView(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        pDesc:cpp.RawPointer<Void>, // const D3D12_SHADER_RESOURCE_VIEW_DESC*
        destHandle:Void // D3D12_CPU_DESCRIPTOR_HANDLE
    ):Void;
    
    /**
     * Create unordered access view (UAV) descriptor
     */
    @:native("D3D12CreateUnorderedAccessView")
    public static function D3D12CreateUnorderedAccessView(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        pCounterResource:cpp.RawPointer<Void>, // ID3D12Resource*
        pDesc:cpp.RawPointer<Void>, // const D3D12_UNORDERED_ACCESS_VIEW_DESC*
        destHandle:Void // D3D12_CPU_DESCRIPTOR_HANDLE
    ):Void;
    
    /**
     * Create render target view (RTV) descriptor
     */
    @:native("D3D12CreateRenderTargetView")
    public static function D3D12CreateRenderTargetView(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        pDesc:cpp.RawPointer<Void>, // const D3D12_RENDER_TARGET_VIEW_DESC*
        destHandle:Void // D3D12_CPU_DESCRIPTOR_HANDLE
    ):Void;
    
    /**
     * Create depth stencil view (DSV) descriptor
     */
    @:native("D3D12CreateDepthStencilView")
    public static function D3D12CreateDepthStencilView(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pResource:cpp.RawPointer<Void>, // ID3D12Resource*
        pDesc:cpp.RawPointer<Void>, // const D3D12_DEPTH_STENCIL_VIEW_DESC*
        destHandle:Void // D3D12_CPU_DESCRIPTOR_HANDLE
    ):Void;
    
    // ============================================================
    // Root Signature & Pipeline State
    // ============================================================
    
    /**
     * Create a root signature from serialized bytecode
     */
    @:native("D3D12CreateRootSignature")
    public static function D3D12CreateRootSignature(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        nodeMask:Int,
        pBlobWithRootSignature:cpp.RawPointer<Void>, // const void*
        blobLengthInBytes:Int,
        riid:Int, // IID_PPV_ARGS(&rootSig)
        ppRootSignature:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Serialize a root signature description
     */
    @:native("D3D12SerializeRootSignature")
    public static function D3D12SerializeRootSignature(
        pRootSignatureDesc:cpp.RawPointer<Void>, // const D3D12_VERSIONED_ROOT_SIGNATURE_DESC*
        version:Int, // D3D_ROOT_SIGNATURE_VERSION
        ppBlob:cpp.RawPointer<cpp.RawPointer<Void>>, // ID3DBlob**
        ppErrorBlob:cpp.RawPointer<cpp.RawPointer<Void>> // ID3DBlob**
    ):Int; // HRESULT
    
    /**
     * Create a graphics pipeline state object (PSO)
     */
    @:native("D3D12CreateGraphicsPipelineState")
    public static function D3D12CreateGraphicsPipelineState(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pDesc:cpp.RawPointer<Void>, // const D3D12_GRAPHICS_PIPELINE_STATE_DESC*
        riid:Int, // IID_PPV_ARGS(&pso)
        ppPipelineState:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Create a compute pipeline state object
     */
    @:native("D3D12CreateComputePipelineState")
    public static function D3D12CreateComputePipelineState(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        pDesc:cpp.RawPointer<Void>, // const D3D12_COMPUTE_PIPELINE_STATE_DESC*
        riid:Int, // IID_PPV_ARGS(&pso)
        ppPipelineState:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    // ============================================================
    // Fence & Synchronization
    // ============================================================
    
    /**
     * Create a fence for GPU/CPU synchronization
     */
    @:native("D3D12CreateFence")
    public static function D3D12CreateFence(
        pDevice:cpp.RawPointer<Void>, // ID3D12Device*
        initialValue:Int,
        flags:Int, // D3D12_FENCE_FLAGS
        riid:Int, // IID_PPV_ARGS(&fence)
        ppFence:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Get current fence value
     */
    @:native("D3D12GetFenceValue")
    public static function D3D12GetFenceValue(
        pFence:cpp.RawPointer<Void> // ID3D12Fence*
    ):Int; // UINT64
    
    /**
     * Set fence event for completion signaling
     */
    @:native("D3D12SetFenceEvent")
    public static function D3D12SetFenceEvent(
        pFence:cpp.RawPointer<Void>, // ID3D12Fence*
        hEvent:Void, // HANDLE
        expectedValue:Int
    ):Int; // HRESULT
    
    // ============================================================
    // Swapchain Management
    // ============================================================
    
    /**
     * Create a swapchain for window presentation
     */
    @:native("CreateSwapChainForHwnd")
    public static function CreateSwapChainForHwnd(
        pFactory:cpp.RawPointer<Void>, // IDXGIFactory4*
        pDevice:cpp.RawPointer<Void>, // IUnknown* (command queue)
        hWnd:Void, // HWND
        pDesc:cpp.RawPointer<Void>, // const DXGI_SWAP_CHAIN_DESC1*
        pFullscreenDesc:cpp.RawPointer<Void>, // const DXGI_SWAP_CHAIN_FULLSCREEN_DESC*
        pRestrictToOutput:cpp.RawPointer<Void>, // IDXGIOutput*
        ppSwapChain:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Get swapchain buffer (backbuffer)
     */
    @:native("DXGIGetSwapChainBuffer")
    public static function DXGIGetSwapChainBuffer(
        pSwapChain:cpp.RawPointer<Void>, // IDXGISwapChain4*
        buffer:Int,
        riid:Int, // IID_PPV_ARGS(&resource)
        ppBuffer:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    /**
     * Present the swapchain (display frame)
     */
    @:native("DXGIPresentSwapChain")
    public static function DXGIPresentSwapChain(
        pSwapChain:cpp.RawPointer<Void>, // IDXGISwapChain4*
        syncInterval:Int,
        flags:Int
    ):Int; // HRESULT
    
    /**
     * Wait for frame presentation (DXGI waiting)
     */
    @:native("DXGIWaitForPresent")
    public static function DXGIWaitForPresent(
        pSwapChain:cpp.RawPointer<Void>, // IDXGISwapChain4*
        maxWaitMs:Int
    ):Int; // HRESULT
    
    // ============================================================
    // Command Recording - Drawing
    // ============================================================
    
    /**
     * Set pipeline state object
     */
    @:native("D3D12SetPipelineState")
    public static function D3D12SetPipelineState(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        pPipelineState:cpp.RawPointer<Void> // ID3D12PipelineState*
    ):Void;
    
    /**
     * Set root signature
     */
    @:native("D3D12SetGraphicsRootSignature")
    public static function D3D12SetGraphicsRootSignature(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        pRootSignature:cpp.RawPointer<Void> // ID3D12RootSignature*
    ):Void;
    
    /**
     * Set viewport
     */
    @:native("D3D12RSSetViewports")
    public static function D3D12RSSetViewports(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        numViewports:Int,
        pViewports:cpp.RawPointer<Void> // const D3D12_VIEWPORT*
    ):Void;
    
    /**
     * Set scissor rectangle
     */
    @:native("D3D12RSSetScissorRects")
    public static function D3D12RSSetScissorRects(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        numRects:Int,
        pRects:cpp.RawPointer<Void> // const D3D12_RECT*
    ):Void;
    
    /**
     * Set render targets
     */
    @:native("D3D12OMSetRenderTargets")
    public static function D3D12OMSetRenderTargets(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        numRenderTargetDescriptors:Int,
        pRenderTargetDescriptors:cpp.RawPointer<Void>, // const D3D12_CPU_DESCRIPTOR_HANDLE*
        bRTsSingleHandleToDescriptorRange:Bool,
        pDepthStencilDescriptor:cpp.RawPointer<Void> // const D3D12_CPU_DESCRIPTOR_HANDLE*
    ):Void;
    
    /**
     * Set vertex buffers
     */
    @:native("D3D12IASetVertexBuffers")
    public static function D3D12IASetVertexBuffers(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        startSlot:Int,
        numViews:Int,
        pViews:cpp.RawPointer<Void> // const D3D12_VERTEX_BUFFER_VIEW*
    ):Void;
    
    /**
     * Set index buffer
     */
    @:native("D3D12IASetIndexBuffer")
    public static function D3D12IASetIndexBuffer(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        pView:cpp.RawPointer<Void> // const D3D12_INDEX_BUFFER_VIEW*
    ):Void;
    
    /**
     * Set primitive topology
     */
    @:native("D3D12IASetPrimitiveTopology")
    public static function D3D12IASetPrimitiveTopology(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        primitiveTopology:Int // D3D_PRIMITIVE_TOPOLOGY
    ):Void;
    
    /**
     * Draw indexed vertices
     */
    @:native("D3D12DrawIndexedInstanced")
    public static function D3D12DrawIndexedInstanced(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        indexCountPerInstance:Int,
        instanceCount:Int,
        startIndexLocation:Int,
        baseVertexLocation:Int,
        startInstanceLocation:Int
    ):Void;
    
    /**
     * Draw vertices (non-indexed)
     */
    @:native("D3D12DrawInstanced")
    public static function D3D12DrawInstanced(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        vertexCountPerInstance:Int,
        instanceCount:Int,
        startVertexLocation:Int,
        startInstanceLocation:Int
    ):Void;
    
    /**
     * Clear render target color
     */
    @:native("D3D12ClearRenderTargetView")
    public static function D3D12ClearRenderTargetView(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        renderTargetView:Void, // D3D12_CPU_DESCRIPTOR_HANDLE
        clearColor:cpp.RawPointer<Float>, // const FLOAT[4]
        numRects:Int,
        pRects:cpp.RawPointer<Void> // const D3D12_RECT*
    ):Void;
    
    /**
     * Clear depth stencil view
     */
    @:native("D3D12ClearDepthStencilView")
    public static function D3D12ClearDepthStencilView(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        depthStencilView:Void, // D3D12_CPU_DESCRIPTOR_HANDLE
        clearFlags:Int, // D3D12_CLEAR_FLAGS
        depth:Float,
        stencil:Int,
        numRects:Int,
        pRects:cpp.RawPointer<Void> // const D3D12_RECT*
    ):Void;
    
    // ============================================================
    // Resource Barriers (State Transitions)
    // ============================================================
    
    /**
     * Insert resource barrier (e.g., COMMON -> RENDER_TARGET)
     */
    @:native("D3D12ResourceBarrier")
    public static function D3D12ResourceBarrier(
        pCommandList:cpp.RawPointer<Void>, // ID3D12GraphicsCommandList*
        numBarriers:Int,
        pBarriers:cpp.RawPointer<Void> // const D3D12_RESOURCE_BARRIER*
    ):Void;
    
    // ============================================================
    // Shader Compilation
    // ============================================================
    
    /**
     * Compile HLSL shader code
     * Requires dxc compiler or fxc
     */
    @:native("D3DCompileFromFile")
    public static function D3DCompileFromFile(
        pFileName:cpp.RawPointer<cpp.Char>, // LPCWSTR
        pDefines:cpp.RawPointer<Void>, // const D3D_SHADER_MACRO*
        pInclude:cpp.RawPointer<Void>, // ID3DInclude*
        pEntrypoint:cpp.RawPointer<cpp.Char>, // LPCSTR
        pTarget:cpp.RawPointer<cpp.Char>, // LPCSTR (e.g., "vs_5_0", "ps_5_0")
        flags1:Int,
        flags2:Int,
        ppCode:cpp.RawPointer<cpp.RawPointer<Void>>, // ID3DBlob**
        ppErrorMsgs:cpp.RawPointer<cpp.RawPointer<Void>> // ID3DBlob**
    ):Int; // HRESULT
    
    /**
     * Compile HLSL shader from memory
     */
    @:native("D3DCompile")
    public static function D3DCompile(
        pSrcData:cpp.RawPointer<Void>, // const void*
        srcDataSize:Int,
        pSourceName:cpp.RawPointer<cpp.Char>, // const char*
        pDefines:cpp.RawPointer<Void>, // const D3D_SHADER_MACRO*
        pInclude:cpp.RawPointer<Void>, // ID3DInclude*
        pEntrypoint:cpp.RawPointer<cpp.Char>, // const char*
        pTarget:cpp.RawPointer<cpp.Char>, // const char*
        flags1:Int,
        flags2:Int,
        ppCode:cpp.RawPointer<cpp.RawPointer<Void>>, // ID3DBlob**
        ppErrorMsgs:cpp.RawPointer<cpp.RawPointer<Void>> // ID3DBlob**
    ):Int; // HRESULT
    
    // ============================================================
    // COM Object Management
    // ============================================================
    
    /**
     * Release COM object reference (decrement refcount)
     */
    @:native("COM_Release")
    public static function COM_Release(pObject:cpp.RawPointer<Void>):Int; // ULONG
    
    /**
     * Add reference to COM object (increment refcount)
     */
    @:native("COM_AddRef")
    public static function COM_AddRef(pObject:cpp.RawPointer<Void>):Int; // ULONG
    
    /**
     * Query interface from COM object
     */
    @:native("COM_QueryInterface")
    public static function COM_QueryInterface(
        pObject:cpp.RawPointer<Void>, // IUnknown*
        riid:Int, // const IID&
        ppvObject:cpp.RawPointer<cpp.RawPointer<Void>>
    ):Int; // HRESULT
    
    // ============================================================
    // Blob Operations
    // ============================================================
    
    /**
     * Get blob data pointer
     */
    @:native("ID3DBlobGetBufferPointer")
    public static function ID3DBlobGetBufferPointer(
        pBlob:cpp.RawPointer<Void> // ID3DBlob*
    ):cpp.RawPointer<Void>;
    
    /**
     * Get blob data size
     */
    @:native("ID3DBlobGetBufferSize")
    public static function ID3DBlobGetBufferSize(
        pBlob:cpp.RawPointer<Void> // ID3DBlob*
    ):Int;
}
