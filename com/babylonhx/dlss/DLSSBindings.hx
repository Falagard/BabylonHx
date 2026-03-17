package com.babylonhx.dlss;

/**
 * Native FFI bindings for NVIDIA DLSS SDK
 * These are low-level bindings to the native DLSS library
 * Version: DLSS 3.7+
 */

#if cpp
@:buildXml('<include name="${haxelib:dlss}/include/Build.xml" />')
#end

// DLSS Opaque types
@:native("opaque_dlss_context_t")
extern class DLSSContextHandle {}

@:native("opaque_dlss_command_list_t")
extern class DLSSCommandListHandle {}

// DLSS Enumerations
@:enum extern abstract DLSSQualityLevel(Int) {
    var Performance = 0;  // 50% resolution
    var Balanced = 1;     // 71% resolution
    var Quality = 2;      // 89% resolution
    var Ultra = 3;        // 100% or higher with DLSS
}

@:enum extern abstract DLSSFeatureFlags(Int) {
    var None = 0x0;
    var MotionVectors = 0x1;
    var Depth = 0x2;
    var FrameGeneration = 0x4;
    var AutoExposure = 0x8;
    var All = 0xF;
}

@:enum extern abstract DLSSResultCode(Int) {
    var Success = 0;
    var InvalidParameter = 1;
    var NotInitialized = 2;
    var OutOfMemory = 3;
    var UnsupportedFeature = 4;
    var GPUError = 5;
    var Unknown = 6;
}

@:enum extern abstract DLSSTextureFormat(Int) {
    var RGBA8 = 0;
    var RGBA16F = 1;
    var RGBA32F = 2;
    var R16F = 3;
    var R32F = 4;
    var RG16F = 5;
    var RG32F = 6;
}

/**
 * Camera description for DLSS
 * Provides camera parameters needed for temporal reprojection
 */
@:native("dlss_camera_desc_t")
extern class DLSSCameraDesc {
    public var cameraNear: cpp.Float32;
    public var cameraFar: cpp.Float32;
    public var verticalFOV: cpp.Float32;
    public var aspectRatio: cpp.Float32;
    public var motionVectorScale: cpp.Struct<"float[2]">;
    public var invertZ: cpp.Bool;
}

/**
 * Texture resource description
 * Describes input/output textures for DLSS
 */
@:native("dlss_texture_resource_t")
extern class DLSSTextureResource {
    public var handle: cpp.Void;  // Native GPU resource handle
    public var format: DLSSTextureFormat;
    public var width: cpp.UInt32;
    public var height: cpp.UInt32;
    public var mipLevels: cpp.UInt32;
}

/**
 * DLSS context creation descriptor
 * Configuration for initializing DLSS
 */
@:native("dlss_context_desc_t")
extern class DLSSContextDesc {
    public var deviceHandle: cpp.Void;              // IDXGIAdapter or equivalent
    public var commandQueueHandle: cpp.Void;        // ID3D12CommandQueue
    public var isLowLatencyMode: cpp.Bool;
    public var features: DLSSFeatureFlags;
    public var applicationId: cpp.UInt32;
    public var engineVersion: cpp.CString;
}

/**
 * DLSS upscale parameters
 * Configuration for a single upscaling pass
 */
@:native("dlss_upscale_params_t")
extern class DLSSUpscaleParams {
    public var qualityLevel: DLSSQualityLevel;
    
    // Input resources
    public var colorInput: DLSSTextureResource;
    public var depthInput: DLSSTextureResource;
    public var motionVectorInput: DLSSTextureResource;
    public var exposureInput: DLSSTextureResource;
    
    // Output resource
    public var colorOutput: DLSSTextureResource;
    
    // Parameters
    public var cameraDesc: DLSSCameraDesc;
    public var frameIndex: cpp.UInt32;
    public var resetHistory: cpp.Bool;
    
    // Optional features
    public var enableFrameGeneration: cpp.Bool;
    public var previousFrameHandle: cpp.Void;
}

/**
 * Native DLSS API functions
 */
@:hlNativeStaticLinking
@:native("extern \"C\"")
extern class DLSSNative {
    
    /**
     * Initialize DLSS context
     * @param desc Configuration descriptor
     * @param outContext Output context handle
     * @return Result code
     */
    @:native("dlss_initialize")
    static function initialize(
        desc: cpp.Pointer<DLSSContextDesc>,
        outContext: cpp.Pointer<DLSSContextHandle>
    ): DLSSResultCode;
    
    /**
     * Destroy DLSS context and release resources
     * @param context Context to destroy
     * @return Result code
     */
    @:native("dlss_destroy")
    static function destroy(context: DLSSContextHandle): DLSSResultCode;
    
    /**
     * Get recommended input resolution for quality level
     * @param context DLSS context
     * @param outputWidth Target output width
     * @param outputHeight Target output height
     * @param qualityLevel Desired quality level
     * @param outWidth Output input width
     * @param outHeight Output input height
     * @return Result code
     */
    @:native("dlss_get_input_resolution")
    static function getInputResolution(
        context: DLSSContextHandle,
        outputWidth: cpp.UInt32,
        outputHeight: cpp.UInt32,
        qualityLevel: DLSSQualityLevel,
        outWidth: cpp.Pointer<cpp.UInt32>,
        outHeight: cpp.Pointer<cpp.UInt32>
    ): DLSSResultCode;
    
    /**
     * Execute DLSS upscaling pass
     * @param commandList Command list for recording GPU commands
     * @param context DLSS context
     * @param params Upscale parameters
     * @return Result code
     */
    @:native("dlss_upscale")
    static function upscale(
        commandList: DLSSCommandListHandle,
        context: DLSSContextHandle,
        params: cpp.Pointer<DLSSUpscaleParams>
    ): DLSSResultCode;
    
    /**
     * Check if DLSS is supported on current hardware
     * @param outSupported Whether DLSS is supported
     * @return Result code
     */
    @:native("dlss_is_supported")
    static function isSupported(
        outSupported: cpp.Pointer<cpp.Bool>
    ): DLSSResultCode;
    
    /**
     * Check if frame generation is supported
     * @param context DLSS context
     * @param outSupported Whether frame generation is supported
     * @return Result code
     */
    @:native("dlss_is_frame_generation_supported")
    static function isFrameGenerationSupported(
        context: DLSSContextHandle,
        outSupported: cpp.Pointer<cpp.Bool>
    ): DLSSResultCode;
    
    /**
     * Allocate command list for DLSS operations
     * @param context DLSS context
     * @param outCommandList Output command list
     * @return Result code
     */
    @:native("dlss_allocate_command_list")
    static function allocateCommandList(
        context: DLSSContextHandle,
        outCommandList: cpp.Pointer<DLSSCommandListHandle>
    ): DLSSResultCode;
    
    /**
     * Free command list
     * @param context DLSS context
     * @param commandList Command list to free
     * @return Result code
     */
    @:native("dlss_free_command_list")
    static function freeCommandList(
        context: DLSSContextHandle,
        commandList: DLSSCommandListHandle
    ): DLSSResultCode;
}

/**
 * Haxe-friendly wrapper for DLSS result codes
 */
class DLSSResult {
    public var code: DLSSResultCode;
    
    public function new(code: DLSSResultCode) {
        this.code = code;
    }
    
    public function isSuccess(): Bool {
        return code == DLSSResultCode.Success;
    }
    
    public function toString(): String {
        return switch (code) {
            case Success: "Success";
            case InvalidParameter: "Invalid parameter";
            case NotInitialized: "DLSS not initialized";
            case OutOfMemory: "Out of memory";
            case UnsupportedFeature: "Unsupported feature";
            case GPUError: "GPU error";
            case Unknown: "Unknown error";
            default: "Error code " + code;
        };
    }
}
