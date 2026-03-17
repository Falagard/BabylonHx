package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.IGraphicsCapabilities;

/**
 * Vulkan capabilities reporting
 */
class VulkanCapabilities implements IGraphicsCapabilities {
    
    public var maxTextureSize:Int = 4096;
    public var maxTextureLayers:Int = 256;
    public var maxRenderTargets:Int = 8;
    public var maxSamples:Int = 64;
    public var maxUBOSize:Int = 65536;
    public var maxSSBOSize:Int = 2147483647; // 2GB
    public var maxShaderStorageBlocks:Int = 8;
    
    private var _supportedEdgeWrap:Bool = true;
    private var _supportedCompressedTextures:Bool = true;
    private var _supportedStandardDerivatives:Bool = true;
    private var _supportedUstd:Bool = true;
    private var _supportedAnisotropicFiltering:Bool = true;
    private var _supportedTextureFloat:Bool = true;
    private var _supportedTextureHalfFloat:Bool = true;
    private var _anisotropyLevel:Int = 16;
    
    public function new() {}
    
    public function getMaxTextureSize():Int {
        return maxTextureSize;
    }
    
    public function getMaxRenderTargets():Int {
        return maxRenderTargets;
    }
    
    public function supportsEdgeWrap():Bool {
        return _supportedEdgeWrap;
    }
    
    public function supportsCompressedTextures():Bool {
        return _supportedCompressedTextures;
    }
    
    public function supportsStandardDerivatives():Bool {
        return _supportedStandardDerivatives;
    }
    
    public function supportsUstd():Bool {
        return _supportedUstd;
    }
    
    public function supportsAnisotropicFiltering():Bool {
        return _supportedAnisotropicFiltering;
    }
    
    public function supportsTextureFloat():Bool {
        return _supportedTextureFloat;
    }
    
    public function supportsTextureHalfFloat():Bool {
        return _supportedTextureHalfFloat;
    }
    
    public function getAnisotropyLevel():Int {
        return _anisotropyLevel;
    }
}
