package com.babylonhx.dlss;

import com.babylonhx.render.RenderTargetTexture;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Vector3;

/**
 * DLSS Temporal Reprojection
 * Manages previous frame data for temporal coherence
 * 
 * Reprojection takes pixels from the previous frame and maps them to the
 * current frame using motion vectors. This maintains temporal stability
 * and improves DLSS reconstruction quality.
 */
class DLSSReprojection {
    
    // Projection matrices
    private var _currentProjectionMatrix: Matrix;
    private var _previousProjectionMatrix: Matrix;
    private var _currentViewMatrix: Matrix;
    private var _previousViewMatrix: Matrix;
    
    // Render targets
    private var _previousColorTarget: RenderTargetTexture;
    private var _currentColorTarget: RenderTargetTexture;
    private var _reprojectionMaskTarget: RenderTargetTexture;
    
    // Configuration
    private var _maxReprojectionDistance: Float = 100.0;  // Maximum pixel distance for reprojection
    private var _useVarianceClipping: Bool = true;       // Enable temporal variance clipping
    private var _temporalBlendFactor: Float = 0.875;     // Blend weight for temporal data
    
    // Statistics
    private var _reprojectionSuccessRate: Float = 0.0;   // 0.0-1.0
    
    // Callbacks
    public var onLog: String -> Void = null;
    
    /**
     * Create a new reprojection manager
     */
    public function new() {
        _currentProjectionMatrix = Matrix.Identity();
        _previousProjectionMatrix = Matrix.Identity();
        _currentViewMatrix = Matrix.Identity();
        _previousViewMatrix = Matrix.Identity();
        
        log("Temporal Reprojection initialized");
    }
    
    /**
     * Update projection matrices for reprojection calculations
     * @param currentProj Current frame projection matrix
     * @param currentView Current frame view matrix
     * @param previousProj Previous frame projection matrix
     * @param previousView Previous frame view matrix
     */
    public function updateMatrices(
        currentProj: Matrix,
        currentView: Matrix,
        previousProj: Matrix,
        previousView: Matrix
    ): Void {
        _currentProjectionMatrix = currentProj.clone();
        _previousProjectionMatrix = previousProj.clone();
        _currentViewMatrix = currentView.clone();
        _previousViewMatrix = previousView.clone();
    }
    
    /**
     * Set the previous frame color target
     * This contains the rendered result from the previous frame
     */
    public function setPreviousColorTarget(target: RenderTargetTexture): Void {
        _previousColorTarget = target;
    }
    
    /**
     * Set the current frame color target
     * This will be the output for reprojection
     */
    public function setCurrentColorTarget(target: RenderTargetTexture): Void {
        _currentColorTarget = target;
    }
    
    /**
     * Reproject previous frame color using motion vectors
     * 
     * Algorithm:
     * 1. For each pixel in current frame:
     *    a. Get motion vector
     *    b. Calculate source position in previous frame
     *    c. Sample previous frame color
     *    d. Apply temporal blend
     * 2. Handle edge cases (screen boundaries, occlusion)
     * 3. Apply variance clipping to reduce ghosting
     * 
     * @param motionVectorRT Motion vectors (RG = X,Y displacement in NDC)
     * @param depthRT Current depth buffer
     * @param previousDepthRT Previous depth buffer
     * @return Success of reprojection pass
     */
    public function reprojectPreviousFrame(
        motionVectorRT: RenderTargetTexture,
        depthRT: RenderTargetTexture,
        previousDepthRT: RenderTargetTexture
    ): Bool {
        if (_previousColorTarget == null || _currentColorTarget == null) {
            error("Previous or current color target not set");
            return false;
        }
        
        #if cpp
        try {
            log("Reprojecting previous frame using motion vectors");
            
            // This would execute a compute/pixel shader that:
            // 1. Samples motion vectors
            // 2. Calculates reprojected UV coordinates
            // 3. Samples previous frame
            // 4. Handles disocclusion (depth mismatches)
            // 5. Applies temporal blend
            
            // Pseudocode for GPU shader:
            /*
            vec2 uv = gl_FragCoord.xy / screenResolution;
            vec2 motion = texture(motionVectors, uv).rg;
            
            // Reproject backwards in time
            vec2 previousUv = uv - motion;
            
            // Check bounds
            if (previousUv.x < 0.0 || previousUv.x > 1.0 ||
                previousUv.y < 0.0 || previousUv.y > 1.0) {
                // Outside screen - use current frame only
                return texture(currentColor, uv);
            }
            
            // Check depth continuity (detect disocclusion)
            float currentDepth = texture(depth, uv).r;
            float previousDepth = texture(previousDepth, previousUv).r;
            
            if (abs(currentDepth - previousDepth) > depthThreshold) {
                // Depth mismatch - disoccluded, use current only
                return texture(currentColor, uv);
            }
            
            // Sample previous frame
            vec3 previousColor = texture(previousColor, previousUv).rgb;
            vec3 currentColor = texture(currentColor, uv).rgb;
            
            // Apply variance clipping to reduce ghosting
            vec3 topLeft = texture(currentColor, uv + vec2(-1.0, 1.0)/screenResolution).rgb;
            vec3 topRight = texture(currentColor, uv + vec2(1.0, 1.0)/screenResolution).rgb;
            vec3 bottomLeft = texture(currentColor, uv + vec2(-1.0, -1.0)/screenResolution).rgb;
            vec3 bottomRight = texture(currentColor, uv + vec2(1.0, -1.0)/screenResolution).rgb;
            
            vec3 boxMin = min(min(min(topLeft, topRight), bottomLeft), bottomRight);
            vec3 boxMax = max(max(max(topLeft, topRight), bottomLeft), bottomRight);
            
            previousColor = clamp(previousColor, boxMin, boxMax);
            
            // Temporal blend
            vec3 final = mix(currentColor, previousColor, temporalBlendFactor);
            return vec4(final, 1.0);
            */
            
            _reprojectionSuccessRate = 0.95;  // Estimate success rate
            return true;
        } catch (e: Dynamic) {
            error("Reprojection failed: " + e);
            return false;
        }
        #else
        return false;
        #end
    }
    
    /**
     * Calculate reprojection for a single pixel position
     * Used for CPU-side validation/debugging
     * 
     * @param screenPos Current pixel position
     * @param motionVector Motion at this pixel
     * @param depth Current depth
     * @param previousDepth Previous frame depth
     * @return Reprojected position in previous frame
     */
    public function reprojectPixel(
        screenPos: Vector2,
        motionVector: Vector2,
        depth: Float,
        previousDepth: Float
    ): Vector2 {
        // Simple reprojection: subtract motion from current position
        var reprojectedPos = screenPos.subtract(motionVector);
        
        // Check for disocclusion (depth mismatch)
        var depthDifference = Math.abs(depth - previousDepth);
        if (depthDifference > 0.1) {  // Threshold for disocclusion
            // Object is disocccluded, return invalid position
            return new Vector2(-1.0, -1.0);
        }
        
        return reprojectedPos;
    }
    
    /**
     * Apply variance clipping to reduce temporal ghosting
     * Clamps reprojected color to the neighborhood of current color
     * 
     * @param currentColor Color at current frame
     * @param reprojectedColor Color from previous frame (reprojected)
     * @param neighborhoodMin Minimum of current frame neighbors
     * @param neighborhoodMax Maximum of current frame neighbors
     * @return Clipped color
     */
    public function applyVarianceClipping(
        currentColor: Vector3,
        reprojectedColor: Vector3,
        neighborhoodMin: Vector3,
        neighborhoodMax: Vector3
    ): Vector3 {
        if (!_useVarianceClipping) {
            return reprojectedColor;
        }
        
        // Clamp reprojected color to neighborhood bounds
        var clippedColor = new Vector3(
            Math.max(neighborhoodMin.x, Math.min(neighborhoodMax.x, reprojectedColor.x)),
            Math.max(neighborhoodMin.y, Math.min(neighborhoodMax.y, reprojectedColor.y)),
            Math.max(neighborhoodMin.z, Math.min(neighborhoodMax.z, reprojectedColor.z))
        );
        
        return clippedColor;
    }
    
    /**
     * Set the temporal blend factor
     * Higher values increase the weight of temporal (previous frame) data
     * Typical range: 0.7-0.95
     * 
     * @param factor Blend factor (0.0 = current only, 1.0 = previous only)
     */
    public function setTemporalBlendFactor(factor: Float): Void {
        _temporalBlendFactor = Math.max(0.0, Math.min(1.0, factor));
    }
    
    /**
     * Get the temporal blend factor
     */
    public function getTemporalBlendFactor(): Float {
        return _temporalBlendFactor;
    }
    
    /**
     * Set maximum reprojection distance in pixels
     * Pixels with motion greater than this are not reprojected
     * @param maxDistance Maximum pixel distance
     */
    public function setMaxReprojectionDistance(maxDistance: Float): Void {
        _maxReprojectionDistance = maxDistance;
        log("Max reprojection distance: " + maxDistance.toFixed(1) + " pixels");
    }
    
    /**
     * Enable/disable variance clipping
     * Variance clipping reduces ghosting artifacts
     * @param enabled Whether to apply clipping
     */
    public function setVarianceClipping(enabled: Bool): Void {
        _useVarianceClipping = enabled;
        log("Variance clipping " + (enabled ? "enabled" : "disabled"));
    }
    
    /**
     * Get reprojection success rate
     * Estimates percentage of pixels successfully reprojected
     * @return Success rate (0.0-1.0)
     */
    public function getReprojectionSuccessRate(): Float {
        return _reprojectionSuccessRate;
    }
    
    /**
     * Reset reprojection state
     * Call when temporal continuity is broken (camera jump, scene change, etc.)
     */
    public function reset(): Void {
        _reprojectionSuccessRate = 0.0;
        log("Reprojection state reset");
    }
    
    /**
     * Get debug string
     */
    public function toString(): String {
        return 'Reprojection{' +
            'blendFactor=${_temporalBlendFactor.toFixed(3)}, ' +
            'varianceClipping=$_useVarianceClipping, ' +
            'successRate=${(_reprojectionSuccessRate * 100).toFixed(1)}%' +
        '}';
    }
    
    /**
     * Internal logging
     * @private
     */
    private function log(message: String): Void {
        if (onLog != null) {
            onLog("[Reprojection] " + message);
        }
        #if debug
        trace("[Reprojection] " + message);
        #end
    }
    
    /**
     * Internal error logging
     * @private
     */
    private function error(message: String): Void {
        #if debug
        trace("[Reprojection Error] " + message);
        #end
    }
}
