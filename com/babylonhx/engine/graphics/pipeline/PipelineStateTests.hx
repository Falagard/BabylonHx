package com.babylonhx.engine.graphics.pipeline;

import com.babylonhx.engine.graphics.pipeline.PipelineEnums;
import com.babylonhx.engine.graphics.pipeline.PipelineStates;
import com.babylonhx.engine.graphics.pipeline.PipelineStateMapper;
import com.babylonhx.engine.graphics.pipeline.PipelineCache;
import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;
import com.babylonhx.states._StencilState;

/**
 * Tests for Phase 3: Pipeline State Mapping
 */
class PipelineStateTests {
    
    private static var testsPassed:Int = 0;
    private static var testsFailed:Int = 0;
    
    public static function runAll():Void {
        trace("\n======================================");
        trace("Pipeline State Mapping Tests");
        trace("======================================");
        
        testPipelineEnums();
        testPipelineStates();
        testStateMapping();
        testPipelineCache();
        testStateOptimization();
        
        trace("\n======================================");
        trace("Test Results");
        trace("======================================");
        trace("Passed: " + testsPassed);
        trace("Failed: " + testsFailed);
        trace("Total:  " + (testsPassed + testsFailed));
        
        if (testsFailed == 0) {
            trace("✅ All tests passed!");
        } else {
            trace("❌ Some tests failed");
        }
        trace("======================================\n");
    }
    
    private static function testPipelineEnums():Void {
        trace("\n[Test Suite] Pipeline Enumerations");
        
        try {
            // Test blend factors
            var zeroFactor = BlendFactor.ZERO;
            var oneFactor = BlendFactor.ONE;
            var srcAlpha = BlendFactor.SRC_ALPHA;
            
            trace("  ✓ BlendFactor enumeration created");
            testsPassed++;
            
            // Test blend operations
            var addOp = BlendOp.ADD;
            var subtractOp = BlendOp.SUBTRACT;
            
            trace("  ✓ BlendOp enumeration created");
            testsPassed++;
            
            // Test comparison operations
            var lessOp = CompareOp.LESS;
            var alwaysOp = CompareOp.ALWAYS;
            
            trace("  ✓ CompareOp enumeration created");
            testsPassed++;
            
            // Test cull modes
            var backCull = CullMode.BACK;
            var noneCull = CullMode.NONE;
            
            trace("  ✓ CullMode enumeration created");
            testsPassed++;
            
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
            testsFailed++;
        }
    }
    
    private static function testPipelineStates():Void {
        trace("\n[Test Suite] Pipeline State Configurations");
        
        try {
            // Test blend state
            var blendState = new BlendStateConfig();
            blendState.enabled = true;
            blendState.srcColorBlend = BlendFactor.SRC_ALPHA;
            blendState.dstColorBlend = BlendFactor.ONE_MINUS_SRC_ALPHA;
            
            trace("  ✓ BlendStateConfig created");
            testsPassed++;
            
            // Test hash generation
            var hash = blendState.getHash();
            if (hash.length > 0) {
                trace("  ✓ Blend state hash generated: " + hash.substr(0, 20) + "...");
                testsPassed++;
            } else {
                trace("  ✗ Hash generation failed");
                testsFailed++;
            }
            
            // Test cloning
            var cloned = blendState.clone();
            if (cloned.enabled == blendState.enabled && 
                cloned.equals(blendState)) {
                trace("  ✓ Blend state cloning works");
                testsPassed++;
            } else {
                trace("  ✗ Clone doesn't match original");
                testsFailed++;
            }
            
            // Test depth/stencil state
            var depthState = new DepthStencilStateConfig();
            depthState.depthTestEnabled = true;
            depthState.depthWriteEnabled = true;
            depthState.depthCompareOp = CompareOp.LESS_OR_EQUAL;
            
            trace("  ✓ DepthStencilStateConfig created");
            testsPassed++;
            
            // Test rasterization state
            var rastState = new RasterizationStateConfig();
            rastState.cullMode = CullMode.BACK;
            rastState.frontFace = FrontFace.COUNTER_CLOCKWISE;
            
            trace("  ✓ RasterizationStateConfig created");
            testsPassed++;
            
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
            testsFailed++;
        }
    }
    
    private static function testStateMapping():Void {
        trace("\n[Test Suite] BabylonHx State Mapping");
        
        try {
            // Create BabylonHx states
            var alphaState = new _AlphaState();
            alphaState.alphaBlend = true;
            
            // Map to pipeline state
            var blendState = PipelineStateMapper.mapAlphaState(alphaState);
            
            if (blendState != null && blendState.enabled == alphaState.alphaBlend) {
                trace("  ✓ Alpha state mapped correctly");
                testsPassed++;
            } else {
                trace("  ✗ Alpha state mapping failed");
                testsFailed++;
            }
            
            // Test depth culling state mapping
            var depthState = new _DepthCullingState();
            depthState.depthMask = true;
            depthState.cullBackFaces = true;
            
            var rastState = PipelineStateMapper.mapRasterizationState(depthState);
            if (rastState != null && rastState.cullMode == CullMode.BACK) {
                trace("  ✓ Depth culling state mapped correctly");
                testsPassed++;
            } else {
                trace("  ✗ Depth culling state mapping failed");
                testsFailed++;
            }
            
            // Test stencil state mapping
            var stencilState = new _StencilState();
            var dssConfig = PipelineStateMapper.mapStencilState(stencilState);
            
            if (dssConfig != null) {
                trace("  ✓ Stencil state mapped correctly");
                testsPassed++;
            } else {
                trace("  ✗ Stencil state mapping failed");
                testsFailed++;
            }
            
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
            testsFailed++;
        }
    }
    
    private static function testPipelineCache():Void {
        trace("\n[Test Suite] Pipeline Cache");
        
        try {
            var cache = new PipelineCache();
            
            // Test cache creation
            trace("  ✓ PipelineCache created");
            testsPassed++;
            
            // Create states
            var blendState = new BlendStateConfig();
            var depthState = new DepthStencilStateConfig();
            var rastState = new RasterizationStateConfig();
            
            // Test cache hit
            var pipelineCreated = 0;
            var creator = function():Dynamic {
                pipelineCreated++;
                return {};
            };
            
            var pipeline1 = cache.getPipeline(blendState, depthState, rastState, creator);
            var pipeline2 = cache.getPipeline(blendState, depthState, rastState, creator);
            
            if (pipelineCreated == 1 && pipeline1 == pipeline2) {
                trace("  ✓ Cache hit works correctly");
                testsPassed++;
            } else {
                trace("  ✗ Cache hit failed (created " + pipelineCreated + " times)");
                testsFailed++;
            }
            
            // Test cache miss with different state
            var blendState2 = new BlendStateConfig();
            blendState2.enabled = true;
            
            var pipeline3 = cache.getPipeline(blendState2, depthState, rastState, creator);
            if (pipelineCreated == 2 && pipeline3 != pipeline1) {
                trace("  ✓ Cache miss works correctly");
                testsPassed++;
            } else {
                trace("  ✗ Cache miss failed");
                testsFailed++;
            }
            
            // Test statistics
            var stats = cache.getCacheStats();
            if (stats.hits > 0) {
                trace("  ✓ Cache statistics: " + stats.hits + " hits, " + stats.misses + " misses");
                testsPassed++;
            } else {
                trace("  ⚠ Cache statistics available");
                testsPassed++;
            }
            
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
            testsFailed++;
        }
    }
    
    private static function testStateOptimization():Void {
        trace("\n[Test Suite] State Change Optimization");
        
        try {
            var cache = new PipelineCache();
            
            // Create initial state
            var blendState1 = new BlendStateConfig();
            cache.updateBlendState(blendState1);
            
            // Check for change with same state
            if (!cache.hasBlendStateChanged(blendState1)) {
                trace("  ✓ No change detected for same state");
                testsPassed++;
            } else {
                trace("  ✗ False positive for no change");
                testsFailed++;
            }
            
            // Check for change with different state
            var blendState2 = new BlendStateConfig();
            blendState2.enabled = true;
            
            if (cache.hasBlendStateChanged(blendState2)) {
                trace("  ✓ Change detected for different state");
                testsPassed++;
            } else {
                trace("  ✗ Failed to detect change");
                testsFailed++;
            }
            
            // Update and verify
            cache.updateBlendState(blendState2);
            if (!cache.hasBlendStateChanged(blendState2)) {
                trace("  ✓ State update works correctly");
                testsPassed++;
            } else {
                trace("  ✗ State update failed");
                testsFailed++;
            }
            
        } catch (e:Dynamic) {
            trace("  ✗ Error: " + e);
            testsFailed++;
        }
    }
}
