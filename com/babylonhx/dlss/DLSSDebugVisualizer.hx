package com.babylonhx.dlss;

import com.babylonhx.render.RenderTargetTexture;
import com.babylonhx.materials.Effect;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;

/**
 * DLSS Debug Visualizer
 * Provides debugging and visualization modes for DLSS optimization
 * 
 * Includes modes for visualizing:
 * - Render resolution vs output resolution
 * - Motion vector magnitude and direction
 * - Reconstruction masks (areas DLSS had to reconstruct)
 * - Temporal confidence/accumulation
 */
class DLSSDebugVisualizer {
    
    // Current debug mode
    private var _debugMode: DLSSDebugMode = DLSSDebugMode.Disabled;
    
    // Visualization parameters
    private var _motionVectorScale: Float = 1.0;
    private var _showCheckerboard: Bool = true;
    private var _checkboardSize: Int = 32;
    
    // Effects for visualization
    private var _debugEffect: Effect;
    private var _scene: Dynamic;
    
    // Callbacks
    public var onLog: String -> Void = null;
    
    /**
     * Create a new debug visualizer
     * @param scene The scene to create effects in
     */
    public function new(scene: Dynamic) {
        _scene = scene;
        log("DLSS Debug Visualizer initialized");
    }
    
    /**
     * Set the debug visualization mode
     * @param mode Debug mode to display
     */
    public function setDebugMode(mode: DLSSDebugMode): Void {
        _debugMode = mode;
        
        var modeName = switch (mode) {
            case Disabled: "Disabled";
            case ShowInputResolution: "Input Resolution";
            case ShowMotionVectors: "Motion Vectors";
            case ShowReconstructionMask: "Reconstruction Mask";
            case ShowTemporalAccumulation: "Temporal Accumulation";
        };
        
        log("Debug mode: " + modeName);
    }
    
    /**
     * Get current debug mode
     */
    public function getDebugMode(): DLSSDebugMode {
        return _debugMode;
    }
    
    /**
     * Visualize input resolution with checkerboard pattern
     * Shows which areas are rendered at lower resolution
     * 
     * @param outputRT Output render target (full resolution)
     * @param inputWidth Width of input (render) resolution
     * @param inputHeight Height of input (render) resolution
     * @param outputWidth Width of output (display) resolution
     * @param outputHeight Height of output (display) resolution
     */
    public function visualizeInputResolution(
        outputRT: RenderTargetTexture,
        inputWidth: Int,
        inputHeight: Int,
        outputWidth: Int,
        outputHeight: Int
    ): Void {
        if (_debugMode != DLSSDebugMode.ShowInputResolution) {
            return;
        }
        
        // Render checkerboard pattern showing upscaling regions
        var scaleX = outputWidth / inputWidth;
        var scaleY = outputHeight / inputHeight;
        
        log('Visualizing input resolution: ${inputWidth}x${inputHeight} upscaled to ${outputWidth}x${outputHeight} (${scaleX.toFixed(2)}x)');
        
        #if cpp
        // This would use a shader to render the visualization
        // Fragment shader would be something like:
        /*
        vec2 uv = gl_FragCoord.xy / outputResolution;
        vec2 scaledUv = uv * vec2(inputWidth/outputWidth, inputHeight/outputHeight);
        
        // Create checkerboard pattern
        vec2 checkPos = fract(scaledUv / checkboardSize) * 2.0;
        float checker = mod(floor(checkPos.x) + floor(checkPos.y), 2.0);
        
        // Blend with original color
        vec3 original = texture(colorTexture, uv).rgb;
        vec3 checkerColor = mix(vec3(0.2), vec3(0.8), checker);
        gl_FragColor = vec4(mix(original, checkerColor, 0.3), 1.0);
        */
        #end
    }
    
    /**
     * Visualize motion vectors as pseudo-color
     * Red/green channels show X/Y motion
     * Brightness shows motion magnitude
     * 
     * @param motionVectorRT Texture containing motion vectors
     */
    public function visualizeMotionVectors(motionVectorRT: RenderTargetTexture): Void {
        if (_debugMode != DLSSDebugMode.ShowMotionVectors) {
            return;
        }
        
        log("Visualizing motion vectors (pseudo-color)");
        
        #if cpp
        // Motion vector visualization shader:
        /*
        vec2 motion = texture(motionVectors, uv).rg;
        
        // Normalize motion to color space
        vec2 normalizedMotion = motion * motionScale;
        
        // Create pseudo-color representation
        // Red = positive X, Cyan = negative X
        // Green = positive Y, Magenta = negative Y
        float r = clamp(normalizedMotion.x, 0.0, 1.0);
        float g = clamp(normalizedMotion.y, 0.0, 1.0);
        float b = 0.5 + 0.5 * clamp(-normalizedMotion.x, 0.0, 1.0);
        
        // Brightness = magnitude
        float magnitude = length(motion);
        float brightness = clamp(magnitude * motionScale, 0.0, 1.0);
        
        vec3 motionColor = vec3(r, g, b) * brightness;
        gl_FragColor = vec4(motionColor, 1.0);
        */
        #end
    }
    
    /**
     * Visualize DLSS reconstruction mask
     * Shows where DLSS had to synthesize pixels vs where it used actual rendered data
     * Green = reconstructed, Blue = original, Gray = blended
     * 
     * @param reconstructionMaskRT Texture containing reconstruction confidence
     */
    public function visualizeReconstructionMask(reconstructionMaskRT: RenderTargetTexture): Void {
        if (_debugMode != DLSSDebugMode.ShowReconstructionMask) {
            return;
        }
        
        log("Visualizing DLSS reconstruction mask");
        
        #if cpp
        // Reconstruction mask visualization shader:
        /*
        float confidence = texture(reconstructionMask, uv).r;
        
        // Color based on confidence
        vec3 color;
        if (confidence < 0.5) {
            // Low confidence = lots of reconstruction
            color = mix(vec3(0.0, 1.0, 0.0), vec3(0.5), confidence * 2.0);  // Green
        } else {
            // High confidence = mostly original
            color = mix(vec3(0.5), vec3(0.0, 0.0, 1.0), (confidence - 0.5) * 2.0);  // Blue
        }
        
        gl_FragColor = vec4(color, 1.0);
        */
        #end
    }
    
    /**
     * Visualize temporal accumulation/confidence
     * Shows temporal stability of the final image
     * Bright = stable, Dark = less stable (more temporal differences)
     * 
     * @param temporalConfidenceRT Texture containing temporal confidence data
     */
    public function visualizeTemporalAccumulation(temporalConfidenceRT: RenderTargetTexture): Void {
        if (_debugMode != DLSSDebugMode.ShowTemporalAccumulation) {
            return;
        }
        
        log("Visualizing temporal accumulation confidence");
        
        #if cpp
        // Temporal confidence visualization shader:
        /*
        float confidence = texture(temporalConfidence, uv).r;
        
        // Remap confidence to visual range [0, 1]
        float visualConfidence = clamp(confidence, 0.0, 1.0);
        
        // Create heatmap: dark = unstable, bright = stable
        vec3 heatColor;
        if (visualConfidence < 0.33) {
            // Red region - unstable
            heatColor = vec3(1.0, visualConfidence * 3.0, 0.0);
        } else if (visualConfidence < 0.66) {
            // Yellow region - somewhat stable
            heatColor = vec3(1.0, 1.0, (visualConfidence - 0.33) * 3.0);
        } else {
            // Green region - stable
            heatColor = vec3(1.0 - (visualConfidence - 0.66) * 3.0, 1.0, 0.0);
        }
        
        gl_FragColor = vec4(heatColor, 1.0);
        */
        #end
    }
    
    /**
     * Configure motion vector visualization scale
     * @param scale Scale factor for motion visualization (higher = larger visible motion)
     */
    public function setMotionVectorScale(scale: Float): Void {
        _motionVectorScale = scale;
        log("Motion vector visualization scale set to: " + scale.toFixed(2));
    }
    
    /**
     * Enable/disable checkerboard overlay for resolution visualization
     * @param enabled Whether to show checkerboard
     */
    public function setCheckerboardOverlay(enabled: Bool): Void {
        _showCheckerboard = enabled;
    }
    
    /**
     * Set checkerboard size in pixels
     * @param size Checkerboard cell size
     */
    public function setCheckerboardSize(size: Int): Void {
        _checkboardSize = Std.int(Math.max(8, size));
    }
    
    /**
     * Check if debugging is enabled
     * @return true if any debug mode is active
     */
    public function isDebugging(): Bool {
        return _debugMode != DLSSDebugMode.Disabled;
    }
    
    /**
     * Create a help overlay string describing debug modes
     * @return Text description of available debug modes
     */
    public static function getDebugHelpText(): String {
        return "DLSS Debug Modes:\n" +
            "0 = Disabled (normal rendering)\n" +
            "1 = Input Resolution (shows upscaling regions with checkerboard)\n" +
            "2 = Motion Vectors (pseudo-color visualization)\n" +
            "3 = Reconstruction Mask (shows AI reconstruction areas)\n" +
            "4 = Temporal Accumulation (shows temporal confidence/stability)";
    }
    
    /**
     * Get debug mode name
     * @param mode Debug mode enum
     * @return Human-readable name
     */
    public static function getDebugModeName(mode: DLSSDebugMode): String {
        return switch (mode) {
            case Disabled: "Disabled";
            case ShowInputResolution: "Input Resolution";
            case ShowMotionVectors: "Motion Vectors";
            case ShowReconstructionMask: "Reconstruction Mask";
            case ShowTemporalAccumulation: "Temporal Accumulation";
        };
    }
    
    /**
     * Get status string
     */
    public function toString(): String {
        var modeName = getDebugModeName(_debugMode);
        return 'DLSSDebugVisualizer{mode=$modeName, enabled=${isDebugging()}}';
    }
    
    /**
     * Internal logging
     * @private
     */
    private function log(message: String): Void {
        if (onLog != null) {
            onLog("[DLSSDebug] " + message);
        }
        #if debug
        trace("[DLSSDebug] " + message);
        #end
    }
}

/**
 * DLSS Debug visualization modes
 */
@:enum extern abstract DLSSDebugMode(Int) {
    var Disabled = 0;
    var ShowInputResolution = 1;       // Display render resolution used with checkerboard
    var ShowMotionVectors = 2;         // Visualize motion vector magnitude/direction
    var ShowReconstructionMask = 3;    // Show areas that DLSS reconstructed
    var ShowTemporalAccumulation = 4;  // Show temporal confidence/stability
}
