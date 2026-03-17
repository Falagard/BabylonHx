package com.babylonhx.dlss;

import com.babylonhx.math.Vector2;

/**
 * DLSS Driver
 * Manages DLSS context initialization, configuration, and lifecycle
 */
class DLSSDriver {
    
    private var _context: DLSSContextHandle;
    private var _isInitialized: Bool = false;
    private var _isSupported: Bool = false;
    private var _currentQualityLevel: DLSSQualityLevel;
    private var _outputResolution: Vector2;
    private var _inputResolution: Vector2;
    private var _cameraDesc: DLSSCameraDesc;
    
    // Logging callback
    public var onLog: String -> Void = null;
    public var onError: String -> Void = null;
    
    /**
     * Create a new DLSS Driver
     */
    public function new() {
        _currentQualityLevel = DLSSQualityLevel.Balanced;
        _outputResolution = new Vector2(1920, 1080);
        _inputResolution = new Vector2(1920, 1080);
    }
    
    /**
     * Check if DLSS is supported on current hardware
     * @return true if DLSS is supported
     */
    public function checkSupport(): Bool {
        #if cpp
        var outSupported: cpp.Bool = false;
        var result = DLSSNative.isSupported(cpp.Pointer.addressOf(outSupported));
        
        if (result == DLSSResultCode.Success) {
            _isSupported = outSupported;
            log("DLSS support check: " + (_isSupported ? "Supported" : "Not supported"));
            return _isSupported;
        } else {
            error("Failed to check DLSS support: " + (new DLSSResult(result)).toString());
            return false;
        }
        #else
        log("DLSS is only available on C++ targets");
        return false;
        #end
    }
    
    /**
     * Initialize DLSS context
     * 
     * @param deviceHandle Native GPU device handle (IDXGIAdapter for DirectX 12)
     * @param commandQueueHandle Native command queue handle (ID3D12CommandQueue)
     * @param applicationId Application identifier
     * @param engineVersion Engine version string
     * @param features Feature flags to enable
     * @return true if initialization successful
     */
    public function initialize(
        deviceHandle: cpp.Void,
        commandQueueHandle: cpp.Void,
        applicationId: Int = 0,
        engineVersion: String = "BabylonHx/1.0",
        features: DLSSFeatureFlags = DLSSFeatureFlags.All
    ): Bool {
        if (_isInitialized) {
            log("DLSS already initialized");
            return true;
        }
        
        if (!checkSupport()) {
            error("DLSS is not supported on this hardware");
            return false;
        }
        
        #if cpp
        // Create context description
        var desc = new DLSSContextDesc();
        desc.deviceHandle = deviceHandle;
        desc.commandQueueHandle = commandQueueHandle;
        desc.applicationId = applicationId;
        desc.engineVersion = engineVersion;
        desc.features = features;
        desc.isLowLatencyMode = false;
        
        // Initialize DLSS context
        var result = DLSSNative.initialize(
            cpp.Pointer.addressOf(desc),
            cpp.Pointer.addressOf(_context)
        );
        
        if (result == DLSSResultCode.Success) {
            _isInitialized = true;
            
            // Initialize camera description
            initializeCameraDesc();
            
            log("DLSS initialized successfully");
            
            // Check frame generation support
            checkFrameGenerationSupport();
            
            return true;
        } else {
            error("DLSS initialization failed: " + (new DLSSResult(result)).toString());
            return false;
        }
        #else
        error("DLSS initialization requires C++ target");
        return false;
        #end
    }
    
    /**
     * Shutdown DLSS and release resources
     */
    public function shutdown(): Void {
        if (!_isInitialized) {
            return;
        }
        
        #if cpp
        var result = DLSSNative.destroy(_context);
        
        if (result == DLSSResultCode.Success) {
            _isInitialized = false;
            log("DLSS shutdown completed");
        } else {
            error("DLSS shutdown failed: " + (new DLSSResult(result)).toString());
        }
        #end
    }
    
    /**
     * Set the target output resolution
     * @param width Output width in pixels
     * @param height Output height in pixels
     */
    public function setOutputResolution(width: Int, height: Int): Void {
        _outputResolution.x = width;
        _outputResolution.y = height;
        updateInputResolution();
    }
    
    /**
     * Get the recommended input resolution for current settings
     * @return Input resolution (before upscaling)
     */
    public function getInputResolution(): Vector2 {
        return _inputResolution;
    }
    
    /**
     * Get the current output resolution
     * @return Output resolution (after upscaling)
     */
    public function getOutputResolution(): Vector2 {
        return _outputResolution;
    }
    
    /**
     * Get the current quality level
     */
    public function getQualityLevel(): DLSSQualityLevel {
        return _currentQualityLevel;
    }
    
    /**
     * Set the quality level and update input resolution accordingly
     * @param quality Quality level setting
     * @return true if quality level was set successfully
     */
    public function setQualityLevel(quality: DLSSQualityLevel): Bool {
        if (!_isInitialized) {
            error("Cannot set quality level: DLSS not initialized");
            return false;
        }
        
        _currentQualityLevel = quality;
        return updateInputResolution();
    }
    
    /**
     * Update input resolution based on output resolution and quality level
     * @return true if successful
     */
    private function updateInputResolution(): Bool {
        if (!_isInitialized) {
            return false;
        }
        
        #if cpp
        var outWidth: cpp.UInt32 = 0;
        var outHeight: cpp.UInt32 = 0;
        
        var result = DLSSNative.getInputResolution(
            _context,
            cast(_outputResolution.x, cpp.UInt32),
            cast(_outputResolution.y, cpp.UInt32),
            _currentQualityLevel,
            cpp.Pointer.addressOf(outWidth),
            cpp.Pointer.addressOf(outHeight)
        );
        
        if (result == DLSSResultCode.Success) {
            _inputResolution.x = outWidth;
            _inputResolution.y = outHeight;
            
            var scale = _outputResolution.x / _inputResolution.x;
            log('Updated input resolution: ${Std.int(_inputResolution.x)} x ${Std.int(_inputResolution.y)} (scale: ${scale.toFixed(2)}x)');
            return true;
        } else {
            error("Failed to get input resolution: " + (new DLSSResult(result)).toString());
            return false;
        }
        #else
        return false;
        #end
    }
    
    /**
     * Initialize default camera description
     */
    private function initializeCameraDesc(): Void {
        _cameraDesc = new DLSSCameraDesc();
        _cameraDesc.cameraNear = 0.1;
        _cameraDesc.cameraFar = 1000.0;
        _cameraDesc.verticalFOV = 45.0;
        _cameraDesc.aspectRatio = 16.0 / 9.0;
        _cameraDesc.invertZ = false; // DirectX convention
        _cameraDesc.motionVectorScale[0] = 1.0;
        _cameraDesc.motionVectorScale[1] = 1.0;
    }
    
    /**
     * Update camera description parameters
     * @param cameraNear Near plane distance
     * @param cameraFar Far plane distance
     * @param fov Vertical field of view in degrees
     * @param aspectRatio Aspect ratio (width/height)
     */
    public function updateCameraDesc(
        cameraNear: Float,
        cameraFar: Float,
        fov: Float,
        aspectRatio: Float
    ): Void {
        if (_cameraDesc == null) {
            return;
        }
        
        _cameraDesc.cameraNear = cameraNear;
        _cameraDesc.cameraFar = cameraFar;
        _cameraDesc.verticalFOV = fov;
        _cameraDesc.aspectRatio = aspectRatio;
    }
    
    /**
     * Set motion vector scaling factors
     * @param scaleX Horizontal motion scaling
     * @param scaleY Vertical motion scaling
     */
    public function setMotionVectorScale(scaleX: Float, scaleY: Float): Void {
        if (_cameraDesc != null) {
            _cameraDesc.motionVectorScale[0] = scaleX;
            _cameraDesc.motionVectorScale[1] = scaleY;
        }
    }
    
    /**
     * Set depth inversion flag (Z convention)
     * @param invert true for reverse-Z convention (OpenGL-style)
     */
    public function setInvertZ(invert: Bool): Void {
        if (_cameraDesc != null) {
            _cameraDesc.invertZ = invert;
        }
    }
    
    /**
     * Get the internal camera description
     * @return Camera description for DLSS operations
     */
    public function getCameraDesc(): DLSSCameraDesc {
        return _cameraDesc;
    }
    
    /**
     * Check if frame generation is supported
     * @return true if frame generation is available
     */
    public function checkFrameGenerationSupport(): Bool {
        if (!_isInitialized) {
            return false;
        }
        
        #if cpp
        var outSupported: cpp.Bool = false;
        var result = DLSSNative.isFrameGenerationSupported(
            _context,
            cpp.Pointer.addressOf(outSupported)
        );
        
        if (result == DLSSResultCode.Success) {
            if (outSupported) {
                log("Frame generation is supported");
            }
            return outSupported;
        } else {
            return false;
        }
        #end
        
        return false;
    }
    
    /**
     * Check if DLSS is initialized
     */
    public function isInitialized(): Bool {
        return _isInitialized;
    }
    
    /**
     * Check if DLSS is supported on this hardware
     */
    public function isSupported(): Bool {
        return _isSupported;
    }
    
    /**
     * Get scale factor from input to output resolution
     */
    public function getScaleFactor(): Float {
        if (_inputResolution.x <= 0) {
            return 1.0;
        }
        return _outputResolution.x / _inputResolution.x;
    }
    
    /**
     * Internal logging method
     */
    private function log(message: String): Void {
        if (onLog != null) {
            onLog("[DLSS] " + message);
        }
        #if debug
        trace("[DLSS] " + message);
        #end
    }
    
    /**
     * Internal error logging method
     */
    private function error(message: String): Void {
        if (onError != null) {
            onError("[DLSS Error] " + message);
        }
        #if debug
        trace("[DLSS Error] " + message);
        #end
    }
}
