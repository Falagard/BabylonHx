package com.babylonhx.dlss;

/**
 * DLSS Post-Processing Integration
 * Manages interaction between DLSS and other post-processing effects
 * 
 * Coordinates with:
 * - TAA (Temporal Anti-Aliasing) - can conflict with DLSS temporal stability
 * - Bloom - applies after upscaling
 * - Color grading - applies after upscaling
 * - Motion blur - should apply after upscaling for better motion vectors
 */
class DLSSPostProcessIntegration {
    
    // Feature states
    private var _taaEnabled: Bool = false;
    private var _dlssEnabled: Bool = false;
    
    // Post-process pipeline configuration
    private var _postProcessOrder: Array<PostProcessStage> = [];
    
    // Integration mode
    private var _integrationMode: DLSSPostProcessMode = DLSSPostProcessMode.ReplaceTAA;
    
    // Callbacks
    public var onLog: String -> Void = null;
    
    /**
     * Create post-process integration manager
     */
    public function new() {
        initializePostProcessOrder();
        log("DLSS Post-Process Integration initialized");
    }
    
    /**
     * Initialize the default post-processing order
     * @private
     */
    private function initializePostProcessOrder(): Void {
        _postProcessOrder = [
            PostProcessStage.SceneRendering,
            PostProcessStage.MotionVectors,
            PostProcessStage.DLSSUpscaling,
            PostProcessStage.Bloom,
            PostProcessStage.ColorGrading,
            PostProcessStage.MotionBlur,
            PostProcessStage.PostProcessing,
            PostProcessStage.UIOverlay
        ];
    }
    
    /**
     * Configure TAA/DLSS interaction
     * 
     * @param dlssEnabled Whether DLSS is enabled
     * @param taaEnabled Whether TAA is enabled
     * @return true if configuration is valid
     */
    public function configureTAADLSSInteraction(dlssEnabled: Bool, taaEnabled: Bool): Bool {
        _dlssEnabled = dlssEnabled;
        _taaEnabled = taaEnabled;
        
        if (dlssEnabled && taaEnabled) {
            switch (_integrationMode) {
                case ReplaceTAA:
                    // DLSS replaces TAA
                    log("TAA disabled - DLSS provides temporal stability");
                    return true;
                    
                case CombinedMode:
                    // Both active (not recommended, but possible)
                    log("Warning: Using both DLSS and TAA is not recommended");
                    log("DLSS already provides temporal coherence similar to TAA");
                    return true;
                    
                case UserChoice:
                    // User selected one or the other
                    log("User selected mode active");
                    return true;
            }
        }
        
        return true;
    }
    
    /**
     * Set the integration mode
     * @param mode How DLSS and TAA should interact
     */
    public function setIntegrationMode(mode: DLSSPostProcessMode): Void {
        _integrationMode = mode;
        var modeName = switch (mode) {
            case ReplaceTAA: "Replace TAA";
            case CombinedMode: "Combined";
            case UserChoice: "User Choice";
        };
        log("Integration mode: " + modeName);
    }
    
    /**
     * Get the current post-processing pipeline order
     * @return Array of post-processing stages in order
     */
    public function getPostProcessOrder(): Array<PostProcessStage> {
        return _postProcessOrder.copy();
    }
    
    /**
     * Check if a post-process effect should be active in DLSS mode
     * @param effect The effect to check
     * @return true if the effect should be enabled
     */
    public function isEffectEnabledWithDLSS(effect: PostProcessEffect): Bool {
        if (!_dlssEnabled) {
            return true;  // Normal behavior when DLSS not enabled
        }
        
        return switch (effect) {
            case TAA:
                // TAA should be disabled when using DLSS
                _integrationMode == DLSSPostProcessMode.CombinedMode;
                
            case Bloom:
                true;  // Bloom always applies after upscaling
                
            case ColorGrading:
                true;  // Color grading applies after upscaling
                
            case MotionBlur:
                true;  // Motion blur applies after DLSS
                
            case SSAO:
                true;  // Ambient occlusion applies before DLSS
                
            case DepthOfField:
                false;  // DOF should apply before DLSS upscaling
                
            case Other(_):
                true;  // Unknown effects default to enabled
        };
    }
    
    /**
     * Get recommended quality settings for DLSS with post-processing
     * @return Configuration object with recommendations
     */
    public function getRecommendedSettings(): DLSSPostProcessConfig {
        var config = new DLSSPostProcessConfig();
        
        // DLSS is already providing temporal stability
        config.disableTAA = true;
        
        // These effects work well after DLSS upscaling
        config.enableBloom = true;
        config.enableColorGrading = true;
        config.enableMotionBlur = false;  // Optional, can reduce clarity
        
        // These should apply before DLSS
        config.enableSSAO = true;
        config.enableDepthOfField = false;  // Not recommended with DLSS
        
        return config;
    }
    
    /**
     * Optimize pipeline for current settings
     * @param dlssEnabled Whether DLSS is active
     * @param qualityLevel DLSS quality level
     * @return Optimized post-process configuration
     */
    public function optimizePipeline(dlssEnabled: Bool, qualityLevel: DLSSQualityLevel): DLSSPostProcessConfig {
        var config = getRecommendedSettings();
        
        if (!dlssEnabled) {
            // Non-DLSS pipeline
            config.disableTAA = false;
            return config;
        }
        
        // Adjust based on quality level
        switch (qualityLevel) {
            case Performance:
                // Aggressive optimization
                config.enableBloom = false;
                config.enableMotionBlur = false;
                config.enableSSAO = false;
                
            case Balanced:
                // Keep important effects
                config.enableBloom = true;
                config.enableMotionBlur = false;
                config.enableSSAO = true;
                
            case Quality:
                // All effects enabled
                config.enableBloom = true;
                config.enableMotionBlur = true;
                config.enableSSAO = true;
                
            case Ultra:
                // Maximum quality
                config.enableBloom = true;
                config.enableMotionBlur = true;
                config.enableSSAO = true;
                config.enableColorGrading = true;
        }
        
        return config;
    }
    
    /**
     * Get detailed explanation of DLSS/TAA interaction
     * @return Documentation string
     */
    public static function getIntegrationGuide(): String {
        return "DLSS and TAA Integration Guide\n\n" +
            "DLSS provides temporal stability similar to TAA:\n" +
            "- Uses motion vectors for temporal coherence\n" +
            "- Reduces temporal artifacts and flickering\n" +
            "- Already accounts for frame-to-frame consistency\n\n" +
            "Recommendation: Disable TAA when DLSS is enabled\n" +
            "- Reduces post-processing overhead\n" +
            "- DLSS temporal quality is superior\n" +
            "- Avoids potential temporal artifacts from double-processing\n\n" +
            "Post-Processing Order with DLSS:\n" +
            "1. Scene rendering (low-res if DLSS)\n" +
            "2. Motion vectors\n" +
            "3. DLSS upscaling\n" +
            "4. Post-effects (Bloom, Color Grading, etc.)\n" +
            "5. UI overlay\n\n" +
            "Effects behavior with DLSS:\n" +
            "- Bloom: Apply after upscaling (recommended)\n" +
            "- Color Grading: Apply after upscaling\n" +
            "- Motion Blur: Apply after upscaling\n" +
            "- TAA: Disable (DLSS replaces)\n" +
            "- SSAO: Apply before upscaling\n" +
            "- DoF: Apply before upscaling (not recommended with DLSS)\n";
    }
    
    /**
     * Get debug string
     */
    public function toString(): String {
        var taaStatus = _taaEnabled && !_dlssEnabled ? "Enabled" : "Disabled";
        var dlssStatus = _dlssEnabled ? "Enabled" : "Disabled";
        
        return 'PostProcessIntegration{dlss=$dlssStatus, taa=$taaStatus, mode=$_integrationMode}';
    }
    
    /**
     * Internal logging
     * @private
     */
    private function log(message: String): Void {
        if (onLog != null) {
            onLog("[PostProcess] " + message);
        }
        #if debug
        trace("[PostProcess] " + message);
        #end
    }
}

/**
 * Post-processing pipeline stages
 */
@:enum extern abstract PostProcessStage(Int) {
    var SceneRendering = 0;
    var MotionVectors = 1;
    var DLSSUpscaling = 2;
    var Bloom = 3;
    var ColorGrading = 4;
    var MotionBlur = 5;
    var PostProcessing = 6;
    var UIOverlay = 7;
}

/**
 * Post-processing effects
 */
@:enum extern abstract PostProcessEffect(Int) {
    var TAA = 0;
    var Bloom = 1;
    var ColorGrading = 2;
    var MotionBlur = 3;
    var SSAO = 4;
    var DepthOfField = 5;
    var Other(effect:String) = 6;
}

/**
 * DLSS/TAA integration modes
 */
@:enum extern abstract DLSSPostProcessMode(Int) {
    var ReplaceTAA = 0;    // DLSS replaces TAA (recommended)
    var CombinedMode = 1;  // Both active (not recommended)
    var UserChoice = 2;    // User selects one or the other
}

/**
 * Post-processing configuration
 */
class DLSSPostProcessConfig {
    public var disableTAA: Bool = true;
    public var enableBloom: Bool = true;
    public var enableColorGrading: Bool = true;
    public var enableMotionBlur: Bool = true;
    public var enableSSAO: Bool = true;
    public var enableDepthOfField: Bool = false;
    
    public function new() {}
    
    public function toString(): String {
        return 'PostProcessConfig{' +
            'disableTAA: $disableTAA, ' +
            'bloom: $enableBloom, ' +
            'motionBlur: $enableMotionBlur' +
        '}';
    }
}
