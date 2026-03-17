package com.babylonhx.engine.graphics;

/**
 * Interface for querying graphics backend capabilities
 */
interface IGraphicsCapabilities {
    /**
     * Maximum texture size
     */
    function getMaxTextureSize():Int;
    
    /**
     * Maximum render target size
     */
    function getMaxRenderTargetSize():Int;
    
    /**
     * Maximum number of texture units
     */
    function getMaxTextureUnits():Int;
    
    /**
     * Maximum number of vertex attributes
     */
    function getMaxVertexAttributes():Int;
    
    /**
     * Check if a texture format is supported
     * @param format The format string (e.g., "RGBA8", "DEPTH24", etc.)
     */
    function supportsTextureFormat(format:String):Bool;
    
    /**
     * Check if compression format is supported
     * @param compression The compression format (e.g., "S3TC", "ETC2", etc.)
     */
    function supportsCompression(compression:String):Bool;
    
    /**
     * Check if anisotropic filtering is supported
     */
    function supportsAnisotropicFiltering():Bool;
    
    /**
     * Get maximum anisotropy level
     */
    function getMaxAnisotropy():Float;
    
    /**
     * Backend name (e.g., "WebGL", "Vulkan", "DirectX12")
     */
    function getBackendName():String;
    
    /**
     * Get backend version/info
     */
    function getBackendVersion():String;
}
