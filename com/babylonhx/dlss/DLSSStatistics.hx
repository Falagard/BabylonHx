package com.babylonhx.dlss;

import com.babylonhx.math.Vector2;

/**
 * DLSS Performance Statistics
 * Tracks and reports DLSS upscaling performance metrics
 */
class DLSSStatistics {
    
    // Time tracking (in milliseconds)
    public var upscaleTimeMs: Float = 0.0;
    public var totalFrameTimeMs: Float = 0.0;
    
    // Resolution tracking
    public var inputResolution: Vector2 = new Vector2();
    public var outputResolution: Vector2 = new Vector2();
    
    // Performance metrics
    public var scaleFactor: Float = 1.0;
    public var estimatedFrameGain: Float = 1.0;  // Multiplier for FPS improvement
    
    // Frame generation (DLSS 3.0+)
    public var framesGeneratedCount: Int = 0;
    public var frameGenerationEnabled: Bool = false;
    
    // Quality tracking
    public var qualityLevel: DLSSQualityLevel = DLSSQualityLevel.Balanced;
    public var motionVectorsActive: Bool = true;
    
    // Statistics aggregation
    private var _frameCount: Int = 0;
    private var _totalUpscaleTime: Float = 0.0;
    private var _maxUpscaleTime: Float = 0.0;
    private var _minUpscaleTime: Float = 999999.0;
    
    /**
     * Create new statistics tracker
     */
    public function new() {
        reset();
    }
    
    /**
     * Reset all statistics
     */
    public function reset(): Void {
        upscaleTimeMs = 0.0;
        totalFrameTimeMs = 0.0;
        framesGeneratedCount = 0;
        _frameCount = 0;
        _totalUpscaleTime = 0.0;
        _maxUpscaleTime = 0.0;
        _minUpscaleTime = 999999.0;
    }
    
    /**
     * Record an upscaling pass
     * @param timeMs Upscaling pass duration in milliseconds
     */
    public function recordUpscalePass(timeMs: Float): Void {
        upscaleTimeMs = timeMs;
        _totalUpscaleTime += timeMs;
        _frameCount++;
        
        if (timeMs > _maxUpscaleTime) {
            _maxUpscaleTime = timeMs;
        }
        
        if (timeMs < _minUpscaleTime) {
            _minUpscaleTime = timeMs;
        }
    }
    
    /**
     * Record a generated frame (DLSS 3.0+)
     */
    public function recordGeneratedFrame(): Void {
        framesGeneratedCount++;
    }
    
    /**
     * Calculate average upscale time
     * @return Average time in milliseconds
     */
    public function getAverageUpscaleTime(): Float {
        if (_frameCount == 0) {
            return 0.0;
        }
        return _totalUpscaleTime / _frameCount;
    }
    
    /**
     * Get maximum upscale time recorded
     * @return Maximum time in milliseconds
     */
    public function getMaxUpscaleTime(): Float {
        return _maxUpscaleTime;
    }
    
    /**
     * Get minimum upscale time recorded
     * @return Minimum time in milliseconds
     */
    public function getMinUpscaleTime(): Float {
        if (_frameCount == 0) {
            return 0.0;
        }
        return _minUpscaleTime;
    }
    
    /**
     * Calculate estimated FPS improvement
     * Assumes typical game renders at 60 FPS base
     * @param baseFrameTimeMs Base frame rendering time
     * @return Expected FPS multiplier
     */
    public function estimatePerformanceGain(baseFrameTimeMs: Float = 16.67): Float {
        if (baseFrameTimeMs <= 0) {
            return 1.0;
        }
        
        var upscaleOverhead = getAverageUpscaleTime();
        var renderedFrameTime = baseFrameTimeMs * (1.0 / (scaleFactor * scaleFactor));
        var totalTime = renderedFrameTime + upscaleOverhead;
        
        return baseFrameTimeMs / totalTime;
    }
    
    /**
     * Calculate memory bandwidth overhead
     * DLSS upscaling requires reading input and writing output
     * @return Estimated bandwidth multiplier (1.0 = no overhead)
     */
    public function getBandwidthOverhead(): Float {
        // Reading low-res color, depth, motion + writing high-res output
        var inputPixels = inputResolution.x * inputResolution.y;
        var outputPixels = outputResolution.x * outputResolution.y;
        
        if (inputPixels <= 0) {
            return 1.0;
        }
        
        // Simplified model: bandwidth proportional to pixel count
        return (inputPixels * 3.0 + outputPixels) / (outputPixels * 4.0);
    }
    
    /**
     * Check if upscaling is efficient
     * @return true if upscaling overhead is justified by resolution increase
     */
    public function isEfficient(): Bool {
        // Efficient if scale factor > 1.2 (20% improvement)
        return scaleFactor > 1.2;
    }
    
    /**
     * Get quality assessment
     * @return Quality rating (1-5 stars)
     */
    public function getQualityRating(): Int {
        return switch (qualityLevel) {
            case Performance: 3;    // Good performance, lower visual quality
            case Balanced: 4;       // Well-balanced (recommended)
            case Quality: 4;        // Very good visual quality
            case Ultra: 5;          // Maximum visual quality
        };
    }
    
    /**
     * Format statistics for display
     */
    public function toString(): String {
        var gain = estimatePerformanceGain();
        var avgTime = getAverageUpscaleTime();
        
        return 'DLSS Stats{' +
            'resolution=${Std.int(inputResolution.x)}→${Std.int(outputResolution.x)}, ' +
            'scale=${scaleFactor.toFixed(2)}x, ' +
            'upscaleTime=${avgTime.toFixed(2)}ms, ' +
            'perfGain=${gain.toFixed(2)}x, ' +
            'quality=$qualityLevel' +
        '}';
    }
    
    /**
     * Get detailed statistics report
     */
    public function getDetailedReport(): String {
        var report = "=== DLSS Statistics Report ===\n";
        report += "Resolution: " + Std.int(inputResolution.x) + "x" + Std.int(inputResolution.y) + 
                  " → " + Std.int(outputResolution.x) + "x" + Std.int(outputResolution.y) + "\n";
        report += "Scale Factor: " + scaleFactor.toFixed(2) + "x\n";
        report += "Quality Level: " + qualityLevel + "\n";
        report += "\nPerformance:\n";
        report += "  Average Upscale Time: " + getAverageUpscaleTime().toFixed(2) + " ms\n";
        report += "  Min/Max: " + getMinUpscaleTime().toFixed(2) + " / " + getMaxUpscaleTime().toFixed(2) + " ms\n";
        report += "  Estimated FPS Gain: " + estimatePerformanceGain().toFixed(2) + "x\n";
        report += "  Bandwidth Overhead: " + (getBandwidthOverhead() * 100.0).toFixed(1) + "%\n";
        
        if (frameGenerationEnabled) {
            report += "\nFrame Generation (DLSS 3.0+):\n";
            report += "  Frames Generated: " + framesGeneratedCount + "\n";
            report += "  Effective FPS Multiplier: " + (scaleFactor + (framesGeneratedCount * 0.5)).toFixed(2) + "x\n";
        }
        
        report += "\nMotion Vectors: " + (motionVectorsActive ? "Active" : "Inactive") + "\n";
        report += "Quality Rating: " + getQualityRating() + "/5 stars\n";
        
        return report;
    }
}
