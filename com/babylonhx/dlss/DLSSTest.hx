package com.babylonhx.dlss;

/**
 * DLSS Context Test and Verification
 * Provides utilities for testing DLSS initialization and compatibility
 */
class DLSSTest {
    
    private var _driver: DLSSDriver;
    private var _testResults: Array<TestResult> = [];
    
    /**
     * Create a new DLSS test suite
     */
    public function new() {
        _driver = new DLSSDriver();
    }
    
    /**
     * Run basic hardware support tests
     * @return true if all tests passed
     */
    public function runHardwareSupportTest(): Bool {
        trace("[DLSS Test] Starting hardware support test...");
        
        clearResults();
        
        // Test 1: Check DLSS support
        addTestResult("Hardware Support", _driver.checkSupport());
        
        if (!getLastTestPassed()) {
            trace("[DLSS Test] Hardware does not support DLSS");
            return false;
        }
        
        return true;
    }
    
    /**
     * Run driver initialization test
     * Note: Requires native GPU context which may not be available in test environment
     * @return true if initialization was successful or gracefully skipped
     */
    public function runInitializationTest(): Bool {
        trace("[DLSS Test] Starting driver initialization test...");
        
        clearResults();
        
        // Test 1: Check support first
        if (!_driver.checkSupport()) {
            addTestResult("Support Check", false);
            return false;
        }
        addTestResult("Support Check", true);
        
        // Test 2: Check resolution calculation
        var testParams = new DLSSParameters();
        testParams.outputWidth = 1920;
        testParams.outputHeight = 1080;
        
        var errors = testParams.validate();
        addTestResult("Parameters Validation", errors.length == 0);
        
        if (errors.length > 0) {
            for (error in errors) {
                trace("[DLSS Test] Validation error: " + error);
            }
        }
        
        // Test 3: Test quality level changes
        try {
            _driver.setQualityLevel(DLSSQualityLevel.Performance);
            _driver.setQualityLevel(DLSSQualityLevel.Balanced);
            _driver.setQualityLevel(DLSSQualityLevel.Quality);
            _driver.setQualityLevel(DLSSQualityLevel.Ultra);
            addTestResult("Quality Level Switching", true);
        } catch (e: Dynamic) {
            addTestResult("Quality Level Switching", false);
            trace("[DLSS Test] Error during quality level switching: " + e);
        }
        
        // Test 4: Test resolution updates
        try {
            _driver.setOutputResolution(1280, 720);
            _driver.setOutputResolution(1920, 1080);
            _driver.setOutputResolution(2560, 1440);
            addTestResult("Resolution Updates", true);
        } catch (e: Dynamic) {
            addTestResult("Resolution Updates", false);
            trace("[DLSS Test] Error during resolution updates: " + e);
        }
        
        return getAllTestsPassed();
    }
    
    /**
     * Run render targets creation test
     * @param scene The scene to create targets in
     * @return true if targets were created successfully
     */
    public function runRenderTargetsTest(scene: Dynamic): Bool {
        trace("[DLSS Test] Starting render targets test...");
        
        clearResults();
        
        // Test 1: Create render targets
        try {
            var targets = new DLSSRenderTargets(scene, 960, 540, 1920, 1080);
            addTestResult("Render Targets Creation", targets != null);
            
            // Test 2: Verify target properties
            if (targets != null) {
                var inputRes = targets.getInputResolution();
                var outputRes = targets.getOutputResolution();
                var scale = targets.getScaleFactor();
                
                var testPassed = 
                    Std.int(inputRes.x) == 960 &&
                    Std.int(inputRes.y) == 540 &&
                    Std.int(outputRes.x) == 1920 &&
                    Std.int(outputRes.y) == 1080 &&
                    Math.abs(scale - 2.0) < 0.01;
                
                addTestResult("Render Targets Properties", testPassed);
                
                // Test 3: Resize operations
                targets.resize(1280, 720, 2560, 1440);
                var resizeTest = 
                    Std.int(targets.getInputResolution().x) == 1280 &&
                    Std.int(targets.getInputResolution().y) == 720;
                addTestResult("Render Targets Resize", resizeTest);
                
                // Test 4: Cleanup
                targets.dispose();
                addTestResult("Render Targets Disposal", true);
            }
        } catch (e: Dynamic) {
            addTestResult("Render Targets Test", false);
            trace("[DLSS Test] Error during render targets test: " + e);
            return false;
        }
        
        return getAllTestsPassed();
    }
    
    /**
     * Run parameters validation test
     * @return true if all parameter tests passed
     */
    public function runParametersTest(): Bool {
        trace("[DLSS Test] Starting parameters validation test...");
        
        clearResults();
        
        // Test 1: Default parameters validation
        var defaultParams = new DLSSParameters();
        var errors = defaultParams.validate();
        addTestResult("Default Parameters Valid", errors.length == 0);
        
        // Test 2: Invalid parameters
        var invalidParams = new DLSSParameters();
        invalidParams.outputWidth = -100;
        errors = invalidParams.validate();
        addTestResult("Invalid Params Detection", errors.length > 0);
        
        // Test 3: Parameter cloning
        var original = new DLSSParameters();
        original.qualityLevel = DLSSQualityLevel.Performance;
        original.enableFrameGeneration = true;
        var cloned = original.clone();
        
        var cloneTest = 
            cloned.qualityLevel == original.qualityLevel &&
            cloned.enableFrameGeneration == original.enableFrameGeneration;
        addTestResult("Parameter Cloning", cloneTest);
        
        // Test 4: Preset profiles
        try {
            var perfProfile = DLSSParameters.getRecommendedProfile(DLSSProfile.Performance);
            var balancedProfile = DLSSParameters.getRecommendedProfile(DLSSProfile.Balanced);
            var qualityProfile = DLSSParameters.getRecommendedProfile(DLSSProfile.Quality);
            
            addTestResult("Preset Generation", 
                perfProfile != null && 
                balancedProfile != null && 
                qualityProfile != null
            );
        } catch (e: Dynamic) {
            addTestResult("Preset Generation", false);
            trace("[DLSS Test] Error generating presets: " + e);
        }
        
        // Test 5: Preset access
        try {
            var presets = DLSSPreset.getBuiltinPresets();
            addTestResult("Builtin Presets", presets.length == 6);
        } catch (e: Dynamic) {
            addTestResult("Builtin Presets", false);
            trace("[DLSS Test] Error accessing presets: " + e);
        }
        
        return getAllTestsPassed();
    }
    
    /**
     * Run all Phase 1 tests in sequence
     * @param scene Optional scene for render target tests
     * @return true if all tests passed
     */
    public function runAllPhase1Tests(scene: Dynamic = null): Bool {
        trace("[DLSS Test] ========================================");
        trace("[DLSS Test] Running Phase 1 Foundation Tests");
        trace("[DLSS Test] ========================================");
        
        var allPassed = true;
        
        // 1. Hardware support tests
        trace("\n[DLSS Test] Test 1: Hardware Support");
        var hardwarePassed = runHardwareSupportTest();
        allPassed = allPassed && hardwarePassed;
        printTestResults();
        
        if (!hardwarePassed) {
            trace("[DLSS Test] Hardware tests failed, skipping remaining tests");
            return false;
        }
        
        // 2. Driver initialization tests
        trace("\n[DLSS Test] Test 2: Driver Initialization");
        var initPassed = runInitializationTest();
        allPassed = allPassed && initPassed;
        printTestResults();
        
        // 3. Parameters validation tests
        trace("\n[DLSS Test] Test 3: Parameters Validation");
        var paramsPassed = runParametersTest();
        allPassed = allPassed && paramsPassed;
        printTestResults();
        
        // 4. Render targets tests (if scene provided)
        if (scene != null) {
            trace("\n[DLSS Test] Test 4: Render Targets Creation");
            var targetsPassed = runRenderTargetsTest(scene);
            allPassed = allPassed && targetsPassed;
            printTestResults();
        } else {
            trace("\n[DLSS Test] Test 4: Render Targets (SKIPPED - no scene provided)");
        }
        
        // Final summary
        trace("\n[DLSS Test] ========================================");
        if (allPassed) {
            trace("[DLSS Test] ✓ All Phase 1 tests PASSED");
        } else {
            trace("[DLSS Test] ✗ Some Phase 1 tests FAILED");
        }
        trace("[DLSS Test] ========================================\n");
        
        return allPassed;
    }
    
    /**
     * Print current test results
     */
    private function printTestResults(): Void {
        for (result in _testResults) {
            var status = result.passed ? "✓" : "✗";
            trace('  $status ${result.name}: ${result.message}');
        }
    }
    
    /**
     * Get all test results
     */
    public function getResults(): Array<TestResult> {
        return _testResults.copy();
    }
    
    /**
     * Check if all tests passed
     */
    private function getAllTestsPassed(): Bool {
        for (result in _testResults) {
            if (!result.passed) {
                return false;
            }
        }
        return _testResults.length > 0;
    }
    
    /**
     * Check if last test passed
     */
    private function getLastTestPassed(): Bool {
        if (_testResults.length == 0) {
            return false;
        }
        return _testResults[_testResults.length - 1].passed;
    }
    
    /**
     * Clear test results
     */
    private function clearResults(): Void {
        _testResults = [];
    }
    
    /**
     * Add a test result
     */
    private function addTestResult(name: String, passed: Bool, message: String = ""): Void {
        _testResults.push({
            name: name,
            passed: passed,
            message: message.length > 0 ? message : (passed ? "Passed" : "Failed")
        });
    }
}

/**
 * Individual test result data
 */
typedef TestResult = {
    name: String,
    passed: Bool,
    message: String
}
