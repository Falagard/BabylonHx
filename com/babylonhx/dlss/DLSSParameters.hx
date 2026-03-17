package com.babylonhx.dlss;

import com.babylonhx.math.Vector2;

/**
 * DLSS Parameters Configuration
 * Holds all configuration parameters for DLSS upscaling
 */
class DLSSParameters {
    
    // Quality and performance settings
    public var qualityLevel: DLSSQualityLevel = DLSSQualityLevel.Balanced;
    public var enableDLSS: Bool = true;
    public var enableMotionVectors: Bool = true;
    public var enableDepth: Bool = true;
    
    // Depth configuration
    public var invertZ: Bool = false;  // false = DirectX convention (0=far, 1=near)
                                        // true = OpenGL convention (0=near, 1=far)
    
    // Motion vector configuration  
    public var motionVectorScale: Vector2 = new Vector2(1.0, 1.0);
    
    // Frame configuration
    public var frameIndex: Int = 0;
    public var resetHistory: Bool = false;
    
    // Advanced options
    public var enableFrameGeneration: Bool = false;
    public var enableAutoExposure: Bool = false;
    public var lowLatencyMode: Bool = false;
    
    // Camera parameters for temporal coherence
    public var cameraNear: Float = 0.1;
    public var cameraFar: Float = 1000.0;
    public var verticalFOV: Float = 45.0;
    public var aspectRatio: Float = 16.0 / 9.0;
    
    // Resolution settings
    public var outputWidth: Int = 1920;
    public var outputHeight: Int = 1080;
    
    // Optional: Debug visualization
    public var debugMode: DLSSDebugMode = DLSSDebugMode.Disabled;
    
    /**
     * Create parameters with default values
     */
    public function new() {
        // All fields initialized with defaults above
    }
    
    /**
     * Create a copy of these parameters
     */
    public function clone(): DLSSParameters {
        var copy = new DLSSParameters();
        
        copy.qualityLevel = qualityLevel;
        copy.enableDLSS = enableDLSS;
        copy.enableMotionVectors = enableMotionVectors;
        copy.enableDepth = enableDepth;
        copy.invertZ = invertZ;
        copy.motionVectorScale = motionVectorScale.clone();
        copy.frameIndex = frameIndex;
        copy.resetHistory = resetHistory;
        copy.enableFrameGeneration = enableFrameGeneration;
        copy.enableAutoExposure = enableAutoExposure;
        copy.lowLatencyMode = lowLatencyMode;
        copy.cameraNear = cameraNear;
        copy.cameraFar = cameraFar;
        copy.verticalFOV = verticalFOV;
        copy.aspectRatio = aspectRatio;
        copy.outputWidth = outputWidth;
        copy.outputHeight = outputHeight;
        copy.debugMode = debugMode;
        
        return copy;
    }
    
    /**
     * Validate parameters for correctness
     * @return Array of validation error messages (empty if valid)
     */
    public function validate(): Array<String> {
        var errors: Array<String> = [];
        
        if (outputWidth <= 0) {
            errors.push("Output width must be positive");
        }
        
        if (outputHeight <= 0) {
            errors.push("Output height must be positive");
        }
        
        if (cameraNear <= 0) {
            errors.push("Camera near plane must be positive");
        }
        
        if (cameraFar <= 0) {
            errors.push("Camera far plane must be positive");
        }
        
        if (cameraNear >= cameraFar) {
            errors.push("Camera near plane must be less than far plane");
        }
        
        if (verticalFOV <= 0 || verticalFOV >= 180) {
            errors.push("Vertical FOV must be between 0 and 180 degrees");
        }
        
        if (aspectRatio <= 0) {
            errors.push("Aspect ratio must be positive");
        }
        
        if (motionVectorScale.x <= 0 || motionVectorScale.y <= 0) {
            errors.push("Motion vector scale must be positive");
        }
        
        return errors;
    }
    
    /**
     * Get recommended settings based on platform/performance target
     */
    public static function getRecommendedProfile(profile: DLSSProfile): DLSSParameters {
        var params = new DLSSParameters();
        
        switch (profile) {
            case Performance:
                params.qualityLevel = DLSSQualityLevel.Performance;
                params.enableFrameGeneration = true;
                params.lowLatencyMode = true;
                
            case Balanced:
                params.qualityLevel = DLSSQualityLevel.Balanced;
                params.enableFrameGeneration = false;
                params.lowLatencyMode = false;
                
            case Quality:
                params.qualityLevel = DLSSQualityLevel.Quality;
                params.enableFrameGeneration = false;
                params.lowLatencyMode = false;
                
            case Ultra:
                params.qualityLevel = DLSSQualityLevel.Ultra;
                params.enableFrameGeneration = false;
                params.lowLatencyMode = false;
                
            case MaxQuality:
                params.qualityLevel = DLSSQualityLevel.Ultra;
                params.enableDLSS = true;  // Still use DLSS for stability
                params.enableMotionVectors = true;
                params.enableDepth = true;
                params.lowLatencyMode = false;
        }
        
        return params;
    }
    
    /**
     * Get quality level description
     */
    public function getQualityDescription(): String {
        return switch (qualityLevel) {
            case Performance: "Performance (50% resolution)";
            case Balanced: "Balanced (71% resolution)";
            case Quality: "Quality (89% resolution)";
            case Ultra: "Ultra (100%+ resolution)";
        };
    }
    
    /**
     * Get expected performance improvement estimate
     */
    public function getExpectedPerformanceGain(): Float {
        return switch (qualityLevel) {
            case Performance: 4.0;   // Up to 4x faster
            case Balanced: 2.0;       // Up to 2x faster
            case Quality: 1.3;        // Up to 1.3x faster
            case Ultra: 1.0;          // No acceleration
        };
    }
    
    /**
     * Convert parameters to a display string for debugging
     */
    public function toString(): String {
        return 'DLSSParameters{' +
            'enabled=$enableDLSS, ' +
            'quality=${getQualityDescription()}, ' +
            'resolution=$outputWidth x $outputHeight, ' +
            'motionVectors=$enableMotionVectors, ' +
            'depth=$enableDepth, ' +
            'frameGen=$enableFrameGeneration' +
        '}';
    }
}

/**
 * DLSS Debug Visualization Modes
 */
@:enum extern abstract DLSSDebugMode(Int) {
    var Disabled = 0;
    var ShowInputResolution = 1;       // Show render resolution color-coded
    var ShowMotionVectors = 2;         // Display motion magnitude
    var ShowReconstructionMask = 3;    // Show DLSS reconstruction areas
    var ShowTemporalAccumulation = 4;  // Show temporal confidence
}

/**
 * Preset performance profiles for quick configuration
 */
@:enum extern abstract DLSSProfile(Int) {
    var Performance = 0;   // Max FPS, sacrifices some quality
    var Balanced = 1;      // Balanced quality and FPS (recommended)
    var Quality = 2;       // Higher visual quality, lower FPS
    var Ultra = 3;         // Maximum quality
    var MaxQuality = 4;    // Highest possible quality without DLSS upscaling
}

/**
 * DLSS Quality Preset
 * Predefined configurations for common use cases
 */
class DLSSPreset {
    
    public var name: String;
    public var description: String;
    public var parameters: DLSSParameters;
    
    public function new(
        name: String,
        description: String,
        parameters: DLSSParameters
    ) {
        this.name = name;
        this.description = description;
        this.parameters = parameters;
    }
    
    /**
     * Get all built-in presets
     */
    public static function getBuiltinPresets(): Array<DLSSPreset> {
        return [
            new DLSSPreset(
                "Maximum FPS",
                "Performance mode with aggressive upscaling (50% render resolution)",
                DLSSParameters.getRecommendedProfile(DLSSProfile.Performance)
            ),
            new DLSSPreset(
                "Balanced",
                "Balanced quality and performance (71% render resolution)",
                DLSSParameters.getRecommendedProfile(DLSSProfile.Balanced)
            ),
            new DLSSPreset(
                "High Quality",
                "High visual quality with 89% render resolution",
                DLSSParameters.getRecommendedProfile(DLSSProfile.Quality)
            ),
            new DLSSPreset(
                "Ultra Quality",
                "Maximum visual quality with 100%+ render resolution",
                DLSSParameters.getRecommendedProfile(DLSSProfile.Ultra)
            ),
            new DLSSPreset(
                "Native Quality",
                "Full render resolution without upscaling",
                DLSSParameters.getRecommendedProfile(DLSSProfile.MaxQuality)
            ),
            new DLSSPreset(
                "Disabled",
                "DLSS disabled, using traditional rendering",
                {
                    var params = new DLSSParameters();
                    params.enableDLSS = false;
                    params;
                }()
            )
        ];
    }
}
