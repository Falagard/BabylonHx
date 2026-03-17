package com.babylonhx.dlss;

/**
 * DLSS Phase 3 Integration Tests
 * Tests advanced features and optimization components
 */
class DLSSPhase3Test {
    
    /**
     * Test frame generator
     */
    public static function testFrameGenerator(): Bool {
        trace("[Phase 3] Testing DLSSFrameGenerator...");
        
        // Test unsupported hardware
        var gen = new DLSSFrameGenerator(false);
        if (gen.isSupported()) {
            trace("[Phase 3] ✗ Should report unsupported");
            return false;
        }
        if (gen.isEnabled()) {
            trace("[Phase 3] ✗ Should not be enabled when unsupported");
            return false;
        }
        
        // Test supported hardware
        var genSupported = new DLSSFrameGenerator(true);
        if (!genSupported.isSupported()) {
            trace("[Phase 3] ✗ Should report supported");
            return false;
        }
        
        // Test enable/disable
        genSupported.setEnabled(true);
        if (!genSupported.isEnabled()) {
            trace("[Phase 3] ✗ Should be enabled");
            return false;
        }
        
        // Test max frames setting
        genSupported.setMaxGeneratedFramesPerFrame(3);
        if (genSupported.getMaxGeneratedFramesPerFrame() != 2) {
            trace("[Phase 3] ✗ Max frames should be clamped to 2");
            return false;
        }
        
        // Test statistics
        genSupported.resetStatistics();
        if (genSupported.getTotalFramesGenerated() != 0) {
            trace("[Phase 3] ✗ Generated count should be 0 after reset");
            return false;
        }
        
        // Test effective multiplier
        var multiplier = genSupported.getEffectiveMultiplier(60.0);
        if (multiplier <= 1.0) {
            trace("[Phase 3] ✗ Multiplier should be > 1.0");
            return false;
        }
        
        trace("[Phase 3] ✓ Frame generator tests passed");
        return true;
    }
    
    /**
     * Test debug visualizer
     */
    public static function testDebugVisualizer(): Bool {
        trace("[Phase 3] Testing DLSSDebugVisualizer...");
        
        var viz = new DLSSDebugVisualizer(null);
        
        // Test mode switching
        if (viz.isDebugging()) {
            trace("[Phase 3] ✗ Should not be debugging initially");
            return false;
        }
        
        viz.setDebugMode(DLSSDebugMode.ShowInputResolution);
        if (!viz.isDebugging()) {
            trace("[Phase 3] ✗ Should be debugging with ShowInputResolution");
            return false;
        }
        
        // Test mode getters
        if (viz.getDebugMode() != DLSSDebugMode.ShowInputResolution) {
            trace("[Phase 3] ✗ Debug mode not set correctly");
            return false;
        }
        
        // Test mode names
        var name = DLSSDebugVisualizer.getDebugModeName(DLSSDebugMode.ShowMotionVectors);
        if (!name.contains("Motion")) {
            trace("[Phase 3] ✗ Mode name incorrect");
            return false;
        }
        
        // Test help text
        var help = DLSSDebugVisualizer.getDebugHelpText();
        if (help.length == 0) {
            trace("[Phase 3] ✗ Help text should not be empty");
            return false;
        }
        
        // Test motion vector scale
        viz.setMotionVectorScale(2.0);
        
        // Test checkerboard settings
        viz.setCheckerboardOverlay(true);
        viz.setCheckerboardSize(16);
        
        trace("[Phase 3] ✓ Debug visualizer tests passed");
        return true;
    }
    
    /**
     * Test reprojection
     */
    public static function testReprojection(): Bool {
        trace("[Phase 3] Testing DLSSReprojection...");
        
        var reproj = new DLSSReprojection();
        
        // Test temporal blend factor
        reproj.setTemporalBlendFactor(0.9);
        if (Math.abs(reproj.getTemporalBlendFactor() - 0.9) > 0.01) {
            trace("[Phase 3] ✗ Temporal blend factor not set");
            return false;
        }
        
        // Test clamping
        reproj.setTemporalBlendFactor(1.5);
        if (reproj.getTemporalBlendFactor() > 1.0) {
            trace("[Phase 3] ✗ Temporal blend factor should be clamped");
            return false;
        }
        
        // Test max reprojection distance
        reproj.setMaxReprojectionDistance(50.0);
        
        // Test variance clipping
        reproj.setVarianceClipping(true);
        reproj.setVarianceClipping(false);
        
        // Test pixel reprojection
        var screenPos = new com.babylonhx.math.Vector2(100, 100);
        var motion = new com.babylonhx.math.Vector2(5, 5);
        var reprojected = reproj.reprojectPixel(screenPos, motion, 1.0, 0.95);
        
        if (reprojected.x == -1.0) {
            trace("[Phase 3] ✗ Pixel should be reprojected");
            return false;
        }
        
        // Test reset
        reproj.reset();
        if (reproj.getReprojectionSuccessRate() > 0.0) {
            trace("[Phase 3] ✗ Success rate should be 0 after reset");
            return false;
        }
        
        trace("[Phase 3] ✓ Reprojection tests passed");
        return true;
    }
    
    /**
     * Test post-process integration
     */
    public static function testPostProcessIntegration(): Bool {
        trace("[Phase 3] Testing DLSSPostProcessIntegration...");
        
        var pp = new DLSSPostProcessIntegration();
        
        // Test integration mode setting
        pp.setIntegrationMode(DLSSPostProcessMode.ReplaceTAA);
        
        // Test TAA/DLSS interaction
        if (!pp.configureTAADLSSInteraction(true, true)) {
            trace("[Phase 3] ✗ DLSS + TAA should be valid");
            return false;
        }
        
        // Test post-process order
        var order = pp.getPostProcessOrder();
        if (order.length == 0) {
            trace("[Phase 3] ✗ Post-process order should not be empty");
            return false;
        }
        
        // Test effect enabling
        if (!pp.isEffectEnabledWithDLSS(PostProcessEffect.Bloom)) {
            trace("[Phase 3] ✗ Bloom should be enabled with DLSS");
            return false;
        }
        
        if (pp.isEffectEnabledWithDLSS(PostProcessEffect.TAA)) {
            trace("[Phase 3] ✗ TAA should be disabled with DLSS in ReplaceTAA mode");
            return false;
        }
        
        // Test recommended settings
        var config = pp.getRecommendedSettings();
        if (!config.disableTAA) {
            trace("[Phase 3] ✗ Recommended settings should disable TAA");
            return false;
        }
        
        // Test pipeline optimization
        var optimized = pp.optimizePipeline(true, DLSSQualityLevel.Balanced);
        if (optimized == null) {
            trace("[Phase 3] ✗ Should return optimized config");
            return false;
        }
        
        // Test integration guide
        var guide = DLSSPostProcessIntegration.getIntegrationGuide();
        if (guide.length == 0) {
            trace("[Phase 3] ✗ Integration guide should not be empty");
            return false;
        }
        
        trace("[Phase 3] ✓ Post-process integration tests passed");
        return true;
    }
    
    /**
     * Test all Phase 3 components
     */
    public static function runAllPhase3Tests(): Bool {
        trace("\n[Phase 3] ========================================");
        trace("[Phase 3] Running Phase 3 Optimization Tests");
        trace("[Phase 3] ========================================\n");
        
        var allPassed = true;
        
        allPassed = testFrameGenerator() && allPassed;
        allPassed = testDebugVisualizer() && allPassed;
        allPassed = testReprojection() && allPassed;
        allPassed = testPostProcessIntegration() && allPassed;
        
        trace("\n[Phase 3] ========================================");
        if (allPassed) {
            trace("[Phase 3] ✓ All Phase 3 tests PASSED");
        } else {
            trace("[Phase 3] ✗ Some Phase 3 tests FAILED");
        }
        trace("[Phase 3] ========================================\n");
        
        return allPassed;
    }
}
