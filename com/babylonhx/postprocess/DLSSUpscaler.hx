package com.babylonhx.postprocess;

import com.babylonhx.dlss.DLSSDriver;
import com.babylonhx.dlss.DLSSRenderTargets;
import com.babylonhx.dlss.DLSSParameters;
import com.babylonhx.dlss.DLSSDepthConfiguration;
import com.babylonhx.dlss.DLSSStatistics;
import com.babylonhx.dlss.DLSSBindings;
import com.babylonhx.render.RenderTargetTexture;
import com.babylonhx.math.Vector2;

/**
 * DLSS Upscaler
 * Core upscaling class that orchestrates DLSS rendering
 * 
 * Typical usage:
 *   var upscaler = new DLSSUpscaler(scene, Vector2(1920, 1080));
 *   upscaler.setQualityLevel(DLSSQualityLevel.Balanced);
 *   upscaler.render(colorRT, depthRT, motionVectorRT, outputRT);
 */
class DLSSUpscaler {
    
    // Core components
    private var _scene: Dynamic;
    private var _driver: DLSSDriver;
    private var _renderTargets: DLSSRenderTargets;
    private var _parameters: DLSSParameters;
    private var _depthConfig: DLSSDepthConfiguration;
    private var _statistics: DLSSStatistics;
    
    // Output resolution
    private var _outputResolution: Vector2;
    
    // State
    private var _isInitialized: Bool = false;
    private var _isEnabled: Bool = true;
    private var _frameIndex: Int = 0;
    
    // Logging callbacks
    public var onLog: String -> Void = null;
    public var onError: String -> Void = null;
    
    /**
     * Create a new DLSS Upscaler
     * @param scene The scene to create render targets in
     * @param targetResolution Output resolution for upscaling
     */
    public function new(scene: Dynamic, targetResolution: Vector2) {
        _scene = scene;
        _outputResolution = targetResolution.clone();
        
        // Initialize components
        _driver = new DLSSDriver();
        _parameters = new DLSSParameters();
        _depthConfig = new DLSSDepthConfiguration();
        _statistics = new DLSSStatistics();
        
        // Forward logging callbacks
        _driver.onLog = log;
        _driver.onError = error;
        
        log("Initializing DLSS Upscaler with target resolution: " + 
            Std.int(_outputResolution.x) + "x" + Std.int(_outputResolution.y));
    }
    
    /**
     * Initialize DLSS context (requires GPU context)
     * @param deviceHandle Native GPU device handle
     * @param commandQueueHandle Native command queue handle
     * @return true if initialization successful
     */
    public function initialize(
        deviceHandle: cpp.Void,
        commandQueueHandle: cpp.Void
    ): Bool {
        if (_isInitialized) {
            log("DLSS Upscaler already initialized");
            return true;
        }
        
        // Initialize DLSS driver
        if (!_driver.initialize(deviceHandle, commandQueueHandle)) {
            error("Failed to initialize DLSS driver");
            return false;
        }
        
        // Set initial parameters
        _driver.setOutputResolution(Std.int(_outputResolution.x), Std.int(_outputResolution.y));
        _driver.setQualityLevel(_parameters.qualityLevel);
        
        // Update camera parameters in driver
        updateCameraParameters();
        
        // Create render targets based on driver's input resolution
        var inputRes = _driver.getInputResolution();
        
        try {
            _renderTargets = new DLSSRenderTargets(
                _scene,
                Std.int(inputRes.x),
                Std.int(inputRes.y),
                Std.int(_outputResolution.x),
                Std.int(_outputResolution.y)
            );
            
            log("Created render targets: " + _renderTargets.toString());
        } catch (e: Dynamic) {
            error("Failed to create render targets: " + e);
            return false;
        }
        
        // Update statistics with initial values
        updateStatistics();
        
        _isInitialized = true;
        log("DLSS Upscaler initialized successfully");
        
        return true;
    }
    
    /**
     * Set the quality level (Performance/Balanced/Quality/Ultra)
     * @param level Quality level preset
     * @return true if quality level was set
     */
    public function setQualityLevel(level: DLSSQualityLevel): Bool {
        if (!_isInitialized) {
            error("Cannot set quality level: DLSS not initialized");
            return false;
        }
        
        if (_driver.setQualityLevel(level)) {
            _parameters.qualityLevel = level;
            
            // Update render targets to new resolution
            if (_renderTargets != null) {
                var inputRes = _driver.getInputResolution();
                _renderTargets.resize(
                    Std.int(inputRes.x),
                    Std.int(inputRes.y),
                    Std.int(_outputResolution.x),
                    Std.int(_outputResolution.y)
                );
            }
            
            updateStatistics();
            log("Quality level set to: " + level);
            return true;
        }
        
        return false;
    }
    
    /**
     * Get current quality level
     */
    public function getQualityLevel(): DLSSQualityLevel {
        return _parameters.qualityLevel;
    }
    
    /**
     * Set motion vector scale factors
     * @param scaleX Horizontal scale
     * @param scaleY Vertical scale
     */
    public function setMotionVectorScale(scaleX: Float, scaleY: Float): Void {
        _parameters.motionVectorScale.x = scaleX;
        _parameters.motionVectorScale.y = scaleY;
        _driver.setMotionVectorScale(scaleX, scaleY);
    }
    
    /**
     * Set depth inversion flag
     * @param invert true for reverse-Z/OpenGL convention
     */
    public function setDepthInvertZ(invert: Bool): Void {
        _parameters.invertZ = invert;
        _depthConfig.invertZ = invert;
        _driver.setInvertZ(invert);
    }
    
    /**
     * Get input resolution (before upscaling)
     */
    public function getInputResolution(): Vector2 {
        if (_isInitialized && _renderTargets != null) {
            return _renderTargets.getInputResolution().clone();
        }
        return _outputResolution.clone();
    }
    
    /**
     * Get output resolution (after upscaling)
     */
    public function getOutputResolution(): Vector2 {
        return _outputResolution.clone();
    }
    
    /**
     * Get scale factor (output / input)
     */
    public function getScaleFactor(): Float {
        if (_isInitialized && _driver != null) {
            return _driver.getScaleFactor();
        }
        return 1.0;
    }
    
    /**
     * Resize upscaler for new output resolution
     * @param width New output width
     * @param height New output height
     */
    public function resize(width: Int, height: Int): Void {
        _outputResolution.x = width;
        _outputResolution.y = height;
        
        if (_isInitialized) {
            _driver.setOutputResolution(width, height);
            
            if (_renderTargets != null) {
                var inputRes = _driver.getInputResolution();
                _renderTargets.resize(
                    Std.int(inputRes.x),
                    Std.int(inputRes.y),
                    width,
                    height
                );
            }
            
            updateStatistics();
            log("Upscaler resized to " + width + "x" + height);
        }
    }
    
    /**
     * Enable/disable DLSS upscaling
     * When disabled, rendering proceeds normally without upscaling
     */
    public function setEnabled(enabled: Bool): Void {
        _isEnabled = enabled;
        log("DLSS upscaling " + (enabled ? "enabled" : "disabled"));
    }
    
    /**
     * Check if DLSS is enabled
     */
    public function isEnabled(): Bool {
        return _isEnabled && _isInitialized;
    }
    
    /**
     * Main rendering function
     * Call this after rendering scene to low-resolution targets
     * 
     * @param colorRT Input low-resolution color render target
     * @param depthRT Input low-resolution depth render target
     * @param motionVectorRT Input motion vectors
     * @param outputRT Output high-resolution render target
     */
    public function render(
        colorRT: RenderTargetTexture,
        depthRT: RenderTargetTexture,
        motionVectorRT: RenderTargetTexture,
        outputRT: RenderTargetTexture
    ): Void {
        if (!_isInitialized || !_isEnabled) {
            // If DLSS not available, copy input to output
            if (colorRT != null && outputRT != null) {
                copyRenderTarget(colorRT, outputRT);
            }
            return;
        }
        
        #if cpp
        try {
            // Start performance tracking
            var startTime = haxe.Timer.stamp();
            
            // Update camera parameters before rendering
            updateCameraParameters();
            
            // Create DLSS parameters for this frame
            var upscaleParams = createUpscaleParameters(colorRT, depthRT, motionVectorRT, outputRT);
            
            // Execute DLSS upscaling
            executeUpscalePass(upscaleParams);
            
            // Record performance metrics
            var upscaleTime = (haxe.Timer.stamp() - startTime) * 1000.0;  // Convert to ms
            _statistics.recordUpscalePass(upscaleTime);
            
            // Increment frame counter
            _frameIndex++;
            _parameters.frameIndex = _frameIndex;
            
        } catch (e: Dynamic) {
            error("DLSS upscaling pass failed: " + e);
            // Fallback: copy input to output
            copyRenderTarget(colorRT, outputRT);
        }
        #else
        // Non-C++ targets: copy input to output
        copyRenderTarget(colorRT, outputRT);
        #end
    }
    
    /**
     * Create DLSS upscale parameters for current frame
     * @private
     */
    private function createUpscaleParameters(
        colorRT: RenderTargetTexture,
        depthRT: RenderTargetTexture,
        motionVectorRT: RenderTargetTexture,
        outputRT: RenderTargetTexture
    ): DLSSUpscaleParams {
        var params = new DLSSUpscaleParams();
        
        // Set input resources
        params.colorInput = _renderTargets.getColorResource();
        params.depthInput = _renderTargets.getDepthResource();
        params.motionVectorInput = _renderTargets.getMotionVectorResource();
        params.colorOutput = _renderTargets.getOutputResource();
        
        // Camera configuration
        params.cameraDesc = _driver.getCameraDesc();
        
        // Quality and frame settings
        params.qualityLevel = _parameters.qualityLevel;
        params.frameIndex = _frameIndex;
        params.resetHistory = _parameters.resetHistory;
        params.enableFrameGeneration = _parameters.enableFrameGeneration;
        
        return params;
    }
    
    /**
     * Execute the DLSS upscaling pass
     * @private
     */
    private function executeUpscalePass(params: DLSSUpscaleParams): Void {
        #if cpp
        // This would be called through the native DLSS API
        // For now, this is a placeholder for the actual GPU upscaling
        var result = DLSSNative.upscale(
            cast(0),  // Command list (would be from engine)
            cast(0),  // Context handle (would be from driver)
            cpp.Pointer.addressOf(params)
        );
        
        if (result != DLSSResultCode.Success) {
            error("DLSS GPU upscale failed: " + (new DLSSResult(result)).toString());
        }
        #end
    }
    
    /**
     * Fallback: copy render target when DLSS not available
     * @private
     */
    private function copyRenderTarget(
        source: RenderTargetTexture,
        target: RenderTargetTexture
    ): Void {
        if (source == null || target == null) {
            return;
        }
        
        // This would use GPU copy command in actual implementation
        // For now, mark target as needing content
        target.refreshRate = 1;
    }
    
    /**
     * Update camera parameters in driver and depth config
     * @private
     */
    private function updateCameraParameters(): Void {
        if (_scene == null || _scene.activeCamera == null) {
            return;
        }
        
        var camera = _scene.activeCamera;
        
        // Update driver's camera description
        _driver.updateCameraDesc(
            camera.minZ,
            camera.maxZ,
            camera.fov,
            camera.getEngine().getRenderWidth() / camera.getEngine().getRenderHeight()
        );
        
        // Update depth configuration
        _depthConfig.setCamera(
            camera.minZ,
            camera.maxZ,
            camera.fov,
            camera.getEngine().getRenderWidth() / camera.getEngine().getRenderHeight()
        );
    }
    
    /**
     * Update statistics with current state
     * @private
     */
    private function updateStatistics(): Void {
        if (_statistics == null || _driver == null) {
            return;
        }
        
        _statistics.inputResolution = _driver.getInputResolution();
        _statistics.outputResolution = _outputResolution;
        _statistics.scaleFactor = _driver.getScaleFactor();
        _statistics.qualityLevel = _parameters.qualityLevel;
        _statistics.motionVectorsActive = _parameters.enableMotionVectors;
        _statistics.frameGenerationEnabled = _parameters.enableFrameGeneration;
        _statistics.estimatedFrameGain = _statistics.estimatePerformanceGain();
    }
    
    /**
     * Get statistics tracker
     */
    public function getStatistics(): DLSSStatistics {
        return _statistics;
    }
    
    /**
     * Get depth configuration
     */
    public function getDepthConfiguration(): DLSSDepthConfiguration {
        return _depthConfig;
    }
    
    /**
     * Get current parameters
     */
    public function getParameters(): DLSSParameters {
        return _parameters;
    }
    
    /**
     * Get the driver instance
     */
    public function getDriver(): DLSSDriver {
        return _driver;
    }
    
    /**
     * Check if DLSS is initialized and ready
     */
    public function isInitialized(): Bool {
        return _isInitialized;
    }
    
    /**
     * Get render targets manager
     */
    public function getRenderTargets(): DLSSRenderTargets {
        return _renderTargets;
    }
    
    /**
     * Reset temporal history (use when camera jumps, scene changes, etc.)
     */
    public function resetHistory(): Void {
        if (_renderTargets != null) {
            _renderTargets.resetHistory();
        }
        if (_parameters != null) {
            _parameters.resetHistory = true;
        }
        log("Temporal history reset");
    }
    
    /**
     * Dispose and clean up resources
     */
    public function dispose(): Void {
        if (_renderTargets != null) {
            _renderTargets.dispose();
            _renderTargets = null;
        }
        
        if (_driver != null) {
            _driver.shutdown();
            _driver = null;
        }
        
        _isInitialized = false;
        log("DLSS Upscaler disposed");
    }
    
    /**
     * Internal logging
     * @private
     */
    private function log(message: String): Void {
        if (onLog != null) {
            onLog("[DLSSUpscaler] " + message);
        }
        #if debug
        trace("[DLSSUpscaler] " + message);
        #end
    }
    
    /**
     * Internal error logging
     * @private
     */
    private function error(message: String): Void {
        if (onError != null) {
            onError("[DLSSUpscaler Error] " + message);
        }
        #if debug
        trace("[DLSSUpscaler Error] " + message);
        #end
    }
}
