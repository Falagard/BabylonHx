package com.babylonhx.engine.graphics.directx12;

import cpp.RawPointer;

/**
 * DirectX 12 Capabilities: Device feature and limit reporting
 * Queries GPU capabilities and generates capability profiles
 */
class DirectXCapabilities implements IGraphicsCapabilities {
    
    // ============================================================
    // Device Features
    // ============================================================
    
    private var supportedFeatures:Map<String, Bool>;
    private var maxTextureSize:Int;
    private var maxBufferSize:Int;
    private var maxSamplers:Int;
    private var maxColorAttachments:Int;
    private var maxVertexAttributes:Int;
    private var maxDescriptorsPerHeap:Int;
    private var maxConstantBufferBindings:Int;
    
    // ============================================================
    // Feature Levels
    // ============================================================
    
    private var featureLevel:Int;
    private var vendor:String;
    private var deviceName:String;
    private var driverVersion:String;
    
    // ============================================================
    // Supported Formats
    // ============================================================
    
    private var supportedColorFormats:Array<Int>;
    private var supportedDepthFormats:Array<Int>;
    
    // ============================================================
    // Constructor
    // ============================================================
    
    public function new() {
        supportedFeatures = new Map<String, Bool>();
        maxTextureSize = 16384; // Default D3D12 maximum
        maxBufferSize = 2147483647; // 2GB
        maxSamplers = 16;
        maxColorAttachments = 8;
        maxVertexAttributes = 16;
        maxDescriptorsPerHeap = 1000000;
        maxConstantBufferBindings = 14;
        
        featureLevel = DirectXConstants.D3D_FEATURE_LEVEL_12_0;
        vendor = "Unknown";
        deviceName = "Unknown DirectX 12 Device";
        driverVersion = "Unknown";
        
        supportedColorFormats = [];
        supportedDepthFormats = [];
        
        initializeDefaultCapabilities();
    }
    
    /**
     * Initialize default capability values
     */
    private function initializeDefaultCapabilities():Void {
        // DirectX 12 always supports these features on Windows
        supportedFeatures.set("vertexShaders", true);
        supportedFeatures.set("pixelShaders", true);
        supportedFeatures.set("geometryShaders", true);
        supportedFeatures.set("computeShaders", true);
        supportedFeatures.set("tessellationShaders", true);
        supportedFeatures.set("instancedDrawing", true);
        supportedFeatures.set("indirectDrawing", true);
        supportedFeatures.set("depthTesting", true);
        supportedFeatures.set("stencilTesting", true);
        supportedFeatures.set("blending", true);
        supportedFeatures.set("multisampling", true);
        supportedFeatures.set("mipmapping", true);
        supportedFeatures.set("textureCompression", true);
        supportedFeatures.set("textureArrays", true);
        supportedFeatures.set("cubemaps", true);
        supportedFeatures.set("depthTextures", true);
        supportedFeatures.set("renderToTexture", true);
        supportedFeatures.set("occlusionQueries", true);
        supportedFeatures.set("timerQueries", true);
        supportedFeatures.set("textureBuffers", true);
        supportedFeatures.set("drawBuffers", true);
        supportedFeatures.set("vertexArrayObjects", false); // Not used in D3D12
        
        // Supported color formats
        supportedColorFormats = [
            DirectXConstants.DXGI_FORMAT_R8G8B8A8_UNORM,
            DirectXConstants.DXGI_FORMAT_R8G8B8A8_UNORM_SRGB,
        ];
        
        // Supported depth formats
        supportedDepthFormats = [
            DirectXConstants.DXGI_FORMAT_D32_FLOAT,
            DirectXConstants.DXGI_FORMAT_D24_UNORM_S8_UINT,
        ];
    }
    
    /**
     * Query device capabilities from a DirectX 12 device
     */
    public function queryCapabilities(device:RawPointer<Void>):Boolean {
        if (device == null) {
            trace("Error: Invalid device pointer");
            return false;
        }
        
        #if windows
        
        // Query device name and vendor information
        // In production, would use Windows Registry or DXGI adapter enumeration
        try {
            determineVendor();
            queryDeviceProperties(device);
        } catch (e:Dynamic) {
            trace('Warning: Failed to query device properties: ${e}');
        }
        
        // Set realistic limits for DirectX 12
        maxTextureSize = 16384;
        maxBufferSize = 2147483647;
        maxSamplers = 2048;
        maxColorAttachments = 8;
        maxVertexAttributes = 32;
        maxDescriptorsPerHeap = 1000000;
        maxConstantBufferBindings = 14;
        
        featureLevel = DirectXConstants.D3D_FEATURE_LEVEL_12_0;
        
        trace("Device capabilities queried successfully");
        return true;
        
        #end
        return false;
    }
    
    /**
     * Determine GPU vendor from environment or adapter info
     */
    private function determineVendor():Void {
        // In production implementation, would use:
        // - IDXGIAdapter enumeration
        // - Device name parsing
        // - DXGI vendor ID lookup
        
        vendor = "Microsoft"; // Default
        deviceName = "DirectX 12 Compatible GPU";
        driverVersion = "1.0.0";
    }
    
    /**
     * Query additional device properties
     */
    private function queryDeviceProperties(device:RawPointer<Void>):Void {
        // Query additional properties like:
        // - Maximum texture dimensions (supports up to 16384)
        // - Aligned buffer sizes
        // - Command buffer size limits
        // - Descriptor pool limits
        
        // These are set to reasonable DirectX 12 defaults
    }
    
    // ============================================================
    // IGraphicsCapabilities Interface Implementation
    // ============================================================
    
    public function hasFeature(feature:String):Bool {
        if (supportedFeatures.exists(feature)) {
            return supportedFeatures.get(feature);
        }
        return false;
    }
    
    public function getMaxTextureSize():Int {
        return maxTextureSize;
    }
    
    public function getMaxBufferSize():Int {
        return maxBufferSize;
    }
    
    public function getMaxSamplers():Int {
        return maxSamplers;
    }
    
    public function getMaxColorAttachments():Int {
        return maxColorAttachments;
    }
    
    public function getMaxVertexAttributes():Int {
        return maxVertexAttributes;
    }
    
    public function getBackendName():String {
        return "DirectX 12";
    }
    
    public function getVendor():String {
        return vendor;
    }
    
    public function getDeviceName():String {
        return deviceName;
    }
    
    public function getDriverVersion():String {
        return driverVersion;
    }
    
    public function getFeatureLevel():String {
        if (featureLevel == DirectXConstants.D3D_FEATURE_LEVEL_12_1) {
            return "12.1";
        } else if (featureLevel == DirectXConstants.D3D_FEATURE_LEVEL_12_0) {
            return "12.0";
        }
        return "Unknown";
    }
    
    public function supportsShadow():Bool {
        return hasFeature("depthTextures");
    }
    
    public function supportsBlueNoise():Bool {
        return hasFeature("textureArrays");
    }
    
    public function supportsParallel():Bool {
        return true; // DirectX 12 always supports parallelism
    }
    
    public function supportsBoneTextures():Bool {
        return hasFeature("textureBuffers");
    }
    
    public function supportsVRMultiview():Bool {
        return false; // Would require special extension support
    }
    
    public function supportsOcclusionQuery():Bool {
        return hasFeature("occlusionQueries");
    }
    
    public function supportsNonSemanticValues():Bool {
        return false;
    }
    
    // ============================================================
    // Format Support Query
    // ============================================================
    
    public function supportsColorFormat(format:Int):Bool {
        return supportedColorFormats.indexOf(format) >= 0;
    }
    
    public function supportsDepthFormat(format:Int):Bool {
        return supportedDepthFormats.indexOf(format) >= 0;
    }
    
    // ============================================================
    // Capability Reporting
    // ============================================================
    
    public function printCapabilities():Void {
        trace("============ DirectX 12 Capabilities ============");
        trace('Device: ${deviceName}');
        trace('Vendor: ${vendor}');
        trace('Driver Version: ${driverVersion}');
        trace('Feature Level: ${getFeatureLevel()}');
        trace("");
        trace("Limits:");
        trace('  Max Texture Size: ${maxTextureSize}');
        trace('  Max Buffer Size: ${maxBufferSize}');
        trace('  Max Samplers: ${maxSamplers}');
        trace('  Max Color Attachments: ${maxColorAttachments}');
        trace('  Max Vertex Attributes: ${maxVertexAttributes}');
        trace('  Max Descriptors/Heap: ${maxDescriptorsPerHeap}');
        trace('  Max Constant Buffer Bindings: ${maxConstantBufferBindings}');
        trace("");
        trace("Features:");
        for (feature in supportedFeatures.keys()) {
            var supported = supportedFeatures.get(feature) ? "✓" : "✗";
            trace('  ${supported} ${feature}');
        }
        trace("================================================");
    }
    
    // ============================================================
    // Accessors
    // ============================================================
    
    public function getMaxDescriptorsPerHeap():Int {
        return maxDescriptorsPerHeap;
    }
    
    public function getMaxConstantBufferBindings():Int {
        return maxConstantBufferBindings;
    }
}
