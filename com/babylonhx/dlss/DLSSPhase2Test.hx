package com.babylonhx.dlss;

import com.babylonhx.postprocess.DLSSUpscaler;
import com.babylonhx.math.Vector2;

/**
 * DLSS Phase 2 Integration Test
 * Tests the core upscaler and scene integration
 */
class DLSSPhase2Test {
    
    /**
     * Test DLSSUpscaler initialization
     */
    public static function testUpscalerInitialization(): Bool {
        trace("[Phase 2] Testing DLSSUpscaler initialization...");
        
        var upscaler: DLSSUpscaler = null;
        
        try {
            // Note: This creates an upscaler but doesn't call initialize()
            // since we don't have GPU context in pure Haxe test
            upscaler = new DLSSUpscaler(null, new Vector2(1920, 1080));
            
            if (upscaler.getOutputResolution().x != 1920 || 
                upscaler.getOutputResolution().y != 1080) {
                trace("[Phase 2] ✗ Output resolution mismatch");
                return false;
            }
            
            if (!upscaler.isEnabled()) {
                trace("[Phase 2] ✗ Upscaler should be enabled by default");
                return false;
            }
            
            trace("[Phase 2] ✓ Upscaler initialization passed");
            return true;
        } catch (e: Dynamic) {
            trace("[Phase 2] ✗ Initialization failed: " + e);
            return false;
        }
    }
    
    /**
     * Test DLSSDepthConfiguration
     */
    public static function testDepthConfiguration(): Bool {
        trace("[Phase 2] Testing DLSSDepthConfiguration...");
        
        var depthConfig = new DLSSDepthConfiguration();
        
        // Test default values
        if (depthConfig.cameraNear != 0.1 || depthConfig.cameraFar != 1000.0) {
            trace("[Phase 2] ✗ Default camera parameters incorrect");
            return false;
        }
        
        // Test camera setup
        depthConfig.setCamera(0.01, 5000.0, 60.0, 16.0/9.0);
        if (depthConfig.cameraNear != 0.01 || depthConfig.cameraFar != 5000.0) {
            trace("[Phase 2] ✗ Camera setup failed");
            return false;
        }
        
        // Test validation
        var errors = depthConfig.validate();
        if (errors.length > 0) {
            trace("[Phase 2] ✗ Validation failed: " + errors);
            return false;
        }
        
        // Test invalid depth config
        var badConfig = new DLSSDepthConfiguration();
        badConfig.cameraNear = -1.0;  // Invalid
        var badErrors = badConfig.validate();
        if (badErrors.length == 0) {
            trace("[Phase 2] ✗ Should detect invalid camera near plane");
            return false;
        }
        
        // Test cloning
        var cloned = depthConfig.clone();
        if (cloned.cameraNear != depthConfig.cameraNear ||
            cloned.cameraFar != depthConfig.cameraFar) {
            trace("[Phase 2] ✗ Cloning failed");
            return false;
        }
        
        // Test depth conversion
        var ndc = depthConfig.linearDepthToNdc(100.0);
        var linear = depthConfig.ndcToLinearDepth(ndc);
        if (Math.abs(linear - 100.0) > 0.1) {
            trace("[Phase 2] ✗ Depth conversion failed: " + linear + " != 100.0");
            return false;
        }
        
        trace("[Phase 2] ✓ Depth configuration tests passed");
        return true;
    }
    
    /**
     * Test DLSSStatistics
     */
    public static function testStatistics(): Bool {
        trace("[Phase 2] Testing DLSSStatistics...");
        
        var stats = new DLSSStatistics();
        
        // Test initial state
        if (stats.getAverageUpscaleTime() != 0.0) {
            trace("[Phase 2] ✗ Initial upscale time should be 0");
            return false;
        }
        
        // Record some samples
        stats.recordUpscalePass(2.5);
        stats.recordUpscalePass(2.8);
        stats.recordUpscalePass(2.3);
        
        var avg = stats.getAverageUpscaleTime();
        var expected = (2.5 + 2.8 + 2.3) / 3.0;
        if (Math.abs(avg - expected) > 0.001) {
            trace("[Phase 2] ✗ Average time calculation failed: " + avg + " != " + expected);
            return false;
        }
        
        // Test performance estimation
        stats.inputResolution.setTo(960, 540);
        stats.outputResolution.setTo(1920, 1080);
        stats.scaleFactor = 2.0;
        
        var gain = stats.estimatePerformanceGain(16.67);  // 60 FPS base
        if (gain <= 1.0) {
            trace("[Phase 2] ✗ Performance gain should be > 1.0 with upscaling");
            return false;
        }
        
        // Test quality rating
        stats.qualityLevel = DLSSQualityLevel.Balanced;
        var rating = stats.getQualityRating();
        if (rating < 1 || rating > 5) {
            trace("[Phase 2] ✗ Quality rating out of range: " + rating);
            return false;
        }
        
        // Test report generation
        var report = stats.getDetailedReport();
        if (report.length == 0 || !report.contains("DLSS Statistics")) {
            trace("[Phase 2] ✗ Report generation failed");
            return false;
        }
        
        trace("[Phase 2] ✓ Statistics tests passed");
        return true;
    }
    
    /**
     * Test DLSSParameters
     */
    public static function testParameters(): Bool {
        trace("[Phase 2] Testing DLSSParameters...");
        
        var params = new DLSSParameters();
        
        // Test default values
        if (!params.enableDLSS || !params.enableMotionVectors || !params.enableDepth) {
            trace("[Phase 2] ✗ Default feature flags incorrect");
            return false;
        }
        
        // Test validation
        var errors = params.validate();
        if (errors.length > 0) {
            trace("[Phase 2] ✗ Default params should be valid: " + errors);
            return false;
        }
        
        // Test quality descriptions
        params.qualityLevel = DLSSQualityLevel.Performance;
        var desc = params.getQualityDescription();
        if (!desc.contains("Performance")) {
            trace("[Phase 2] ✗ Quality description incorrect");
            return false;
        }
        
        // Test preset generation
        var profile = DLSSParameters.getRecommendedProfile(DLSSProfile.Balanced);
        if (profile.qualityLevel != DLSSQualityLevel.Balanced) {
            trace("[Phase 2] ✗ Preset generation failed");
            return false;
        }
        
        // Test cloning
        params.enableFrameGeneration = true;
        var cloned = params.clone();
        if (!cloned.enableFrameGeneration) {
            trace("[Phase 2] ✗ Parameter cloning failed");
            return false;
        }
        
        trace("[Phase 2] ✓ Parameters tests passed");
        return true;
    }
    
    /**
     * Run all Phase 2 tests
     */
    public static function runAllPhase2Tests(): Bool {
        trace("\n[Phase 2] ========================================");
        trace("[Phase 2] Running Phase 2 Core Integration Tests");
        trace("[Phase 2] ========================================\n");
        
        var allPassed = true;
        
        allPassed = testUpscalerInitialization() && allPassed;
        allPassed = testDepthConfiguration() && allPassed;
        allPassed = testStatistics() && allPassed;
        allPassed = testParameters() && allPassed;
        
        trace("\n[Phase 2] ========================================");
        if (allPassed) {
            trace("[Phase 2] ✓ All Phase 2 tests PASSED");
        } else {
            trace("[Phase 2] ✗ Some Phase 2 tests FAILED");
        }
        trace("[Phase 2] ========================================\n");
        
        return allPassed;
    }
}
