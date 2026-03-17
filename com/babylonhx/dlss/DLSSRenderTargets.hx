package com.babylonhx.dlss;

import com.babylonhx.render.RenderTargetTexture;
import com.babylonhx.math.Vector2;

/**
 * DLSS Render Targets Manager
 * Manages creation and lifecycle of render targets needed for DLSS
 */
class DLSSRenderTargets {
    
    // Render targets at input resolution (low-res)
    public var colorTarget: RenderTargetTexture;
    public var depthTarget: RenderTargetTexture;
    public var motionVectorTarget: RenderTargetTexture;
    
    // Render target at output resolution (full-res)
    public var outputTarget: RenderTargetTexture;
    
    // Optional targets
    public var normalTarget: RenderTargetTexture;  // Optional, for additional effects
    public var previousColorTarget: RenderTargetTexture;  // For temporal effects
    
    // Resolution tracking
    private var _inputResolution: Vector2;
    private var _outputResolution: Vector2;
    
    // Parent scene for creating render targets
    private var _scene: Dynamic;
    
    /**
     * Create a new DLSS render targets manager
     * @param scene The scene to create targets in
     * @param inputWidth Input resolution width
     * @param inputHeight Input resolution height
     * @param outputWidth Output resolution width
     * @param outputHeight Output resolution height
     */
    public function new(
        scene: Dynamic,
        inputWidth: Int,
        inputHeight: Int,
        outputWidth: Int,
        outputHeight: Int
    ) {
        _scene = scene;
        _inputResolution = new Vector2(inputWidth, inputHeight);
        _outputResolution = new Vector2(outputWidth, outputHeight);
        
        createRenderTargets();
    }
    
    /**
     * Create all required render targets
     */
    private function createRenderTargets(): Void {
        // Input resolution color target (RGB, high precision)
        colorTarget = new RenderTargetTexture(
            "DLSSColorInput",
            Std.int(_inputResolution.x),
            Std.int(_inputResolution.y),
            _scene
        );
        colorTarget.format = 5; // RGBA32F for high quality
        colorTarget.generateMipMaps = false;
        colorTarget.samplingMode = 2; // TRILINEAR_SAMPLINGMODE
        
        // Input resolution depth target (single-channel 32-bit float)
        depthTarget = new RenderTargetTexture(
            "DLSSDepthInput",
            Std.int(_inputResolution.x),
            Std.int(_inputResolution.y),
            _scene
        );
        depthTarget.format = 6; // Single channel, 32-bit float
        depthTarget.generateMipMaps = false;
        depthTarget.samplingMode = 1; // LINEAR_SAMPLINGMODE
        
        // Input resolution motion vector target (RG16F)
        // Motion vectors are typically stored as red and green channels
        motionVectorTarget = new RenderTargetTexture(
            "DLSSMotionVectors",
            Std.int(_inputResolution.x),
            Std.int(_inputResolution.y),
            _scene
        );
        motionVectorTarget.format = 4; // RG16F
        motionVectorTarget.generateMipMaps = false;
        motionVectorTarget.samplingMode = 1; // LINEAR_SAMPLINGMODE
        
        // Output resolution target (full resolution after upscaling)
        outputTarget = new RenderTargetTexture(
            "DLSSColorOutput",
            Std.int(_outputResolution.x),
            Std.int(_outputResolution.y),
            _scene
        );
        outputTarget.format = 5; // RGBA32F
        outputTarget.generateMipMaps = false;
        outputTarget.samplingMode = 2; // TRILINEAR_SAMPLINGMODE
        
        // Optional: Normal target at input resolution
        normalTarget = new RenderTargetTexture(
            "DLSSNormals",
            Std.int(_inputResolution.x),
            Std.int(_inputResolution.y),
            _scene
        );
        normalTarget.format = 4; // RG16F (for normal maps)
        normalTarget.generateMipMaps = false;
        normalTarget.samplingMode = 1; // LINEAR_SAMPLINGMODE
        
        // Optional: Previous frame color for temporal effects
        previousColorTarget = new RenderTargetTexture(
            "DLSSPreviousColor",
            Std.int(_outputResolution.x),
            Std.int(_outputResolution.y),
            _scene
        );
        previousColorTarget.format = 5; // RGBA32F
        previousColorTarget.generateMipMaps = false;
        previousColorTarget.samplingMode = 2; // TRILINEAR_SAMPLINGMODE
    }
    
    /**
     * Resize all render targets to new resolutions
     * @param inputWidth New input width
     * @param inputHeight New input height
     * @param outputWidth New output width
     * @param outputHeight New output height
     */
    public function resize(
        inputWidth: Int,
        inputHeight: Int,
        outputWidth: Int,
        outputHeight: Int
    ): Void {
        // Release old targets
        dispose();
        
        // Update resolutions
        _inputResolution.x = inputWidth;
        _inputResolution.y = inputHeight;
        _outputResolution.x = outputWidth;
        _outputResolution.y = outputHeight;
        
        // Recreate targets with new sizes
        createRenderTargets();
    }
    
    /**
     * Get the input resolution
     */
    public function getInputResolution(): Vector2 {
        return _inputResolution;
    }
    
    /**
     * Get the output resolution
     */
    public function getOutputResolution(): Vector2 {
        return _outputResolution;
    }
    
    /**
     * Get the scale factor from input to output resolution
     */
    public function getScaleFactor(): Float {
        if (_inputResolution.x <= 0) {
            return 1.0;
        }
        return _outputResolution.x / _inputResolution.x;
    }
    
    /**
     * Reset all render target history/accumulation
     * Call this when temporal coherence needs to be reset
     */
    public function resetHistory(): Void {
        // Signal targets to clear accumulated data
        if (colorTarget != null) {
            colorTarget.clear(0, 0, 0, 0);
        }
        if (depthTarget != null) {
            depthTarget.clear(1, 1, 1, 1);
        }
        if (motionVectorTarget != null) {
            motionVectorTarget.clear(0, 0, 0, 0);
        }
        if (outputTarget != null) {
            outputTarget.clear(0, 0, 0, 0);
        }
    }
    
    /**
     * Get texture resource for DLSS binding
     * Converts BabylonHx texture to DLSS-compatible resource
     */
    public function getColorResource(): DLSSTextureResource {
        return createTextureResource(colorTarget, DLSSTextureFormat.RGBA32F);
    }
    
    /**
     * Get depth texture resource for DLSS binding
     */
    public function getDepthResource(): DLSSTextureResource {
        return createTextureResource(depthTarget, DLSSTextureFormat.R32F);
    }
    
    /**
     * Get motion vector texture resource for DLSS binding
     */
    public function getMotionVectorResource(): DLSSTextureResource {
        return createTextureResource(motionVectorTarget, DLSSTextureFormat.RG16F);
    }
    
    /**
     * Get output texture resource for DLSS binding
     */
    public function getOutputResource(): DLSSTextureResource {
        return createTextureResource(outputTarget, DLSSTextureFormat.RGBA32F);
    }
    
    /**
     * Create a texture resource from a render target
     * @param target The render target
     * @param format Expected texture format
     */
    private function createTextureResource(
        target: RenderTargetTexture,
        format: DLSSTextureFormat
    ): DLSSTextureResource {
        var resource = new DLSSTextureResource();
        
        // Extract native GPU handle from render target
        // This depends on the engine backend implementation
        #if cpp
        // DirectX 12 backend: Get ID3D12Resource from texture
        resource.handle = target.getInternalTexture();  // Returns native texture handle
        #end
        
        resource.format = format;
        resource.width = target.getRenderWidth();
        resource.height = target.getRenderHeight();
        resource.mipLevels = target.requestedWidth; // Use width as mip count indicator
        
        return resource;
    }
    
    /**
     * Enable/disable all render targets
     */
    public function setEnabled(enabled: Bool): Void {
        if (colorTarget != null) colorTarget.activeCamera = enabled ? null : _scene.activeCamera;
        if (depthTarget != null) depthTarget.activeCamera = enabled ? null : _scene.activeCamera;
        if (motionVectorTarget != null) motionVectorTarget.activeCamera = enabled ? null : _scene.activeCamera;
        if (outputTarget != null) outputTarget.activeCamera = enabled ? null : _scene.activeCamera;
    }
    
    /**
     * Dispose all render targets and release GPU resources
     */
    public function dispose(): Void {
        if (colorTarget != null) {
            colorTarget.dispose();
            colorTarget = null;
        }
        
        if (depthTarget != null) {
            depthTarget.dispose();
            depthTarget = null;
        }
        
        if (motionVectorTarget != null) {
            motionVectorTarget.dispose();
            motionVectorTarget = null;
        }
        
        if (outputTarget != null) {
            outputTarget.dispose();
            outputTarget = null;
        }
        
        if (normalTarget != null) {
            normalTarget.dispose();
            normalTarget = null;
        }
        
        if (previousColorTarget != null) {
            previousColorTarget.dispose();
            previousColorTarget = null;
        }
    }
    
    /**
     * Get a debug string representation
     */
    public function toString(): String {
        return 'DLSSRenderTargets(input: ${Std.int(_inputResolution.x)}x${Std.int(_inputResolution.y)}, output: ${Std.int(_outputResolution.x)}x${Std.int(_outputResolution.y)}, scale: ${getScaleFactor().toFixed(2)}x)';
    }
}
