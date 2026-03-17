package com.babylonhx.dlss;

import com.babylonhx.math.Vector2;

/**
 * DLSS Depth Buffer Configuration
 * Handles depth convention and camera parameters for DLSS temporal reprojection
 */
class DLSSDepthConfiguration {
    
    // Depth convention
    public var invertZ: Bool = false;  // false: 0=far, 1=near (DirectX convention)
                                        // true: 0=near, 1=far (OpenGL convention)
    
    // Camera parameters for view frustum reprojection
    public var cameraNear: Float = 0.1;
    public var cameraFar: Float = 1000.0;
    public var verticalFOV: Float = 45.0;
    public var aspectRatio: Float = 16.0 / 9.0;
    
    // Motion vector scaling
    public var motionVectorScale: Vector2 = new Vector2(1.0, 1.0);
    
    // Depth linearization flags
    public var useLinearDepth: Bool = false;  // Convert to linear view-space depth if needed
    public var depthPrecision: DepthPrecision = DepthPrecision.Float32;
    
    /**
     * Create depth configuration with default settings
     */
    public function new() {
        // Defaults initialized above
    }
    
    /**
     * Create a copy of this configuration
     */
    public function clone(): DLSSDepthConfiguration {
        var copy = new DLSSDepthConfiguration();
        copy.invertZ = invertZ;
        copy.cameraNear = cameraNear;
        copy.cameraFar = cameraFar;
        copy.verticalFOV = verticalFOV;
        copy.aspectRatio = aspectRatio;
        copy.motionVectorScale = motionVectorScale.clone();
        copy.useLinearDepth = useLinearDepth;
        copy.depthPrecision = depthPrecision;
        return copy;
    }
    
    /**
     * Set camera parameters from a traditional camera definition
     * @param nearPlane Near clipping plane distance
     * @param farPlane Far clipping plane distance
     * @param vFOV Vertical field of view in degrees
     * @param aspectRatio Width/Height aspect ratio
     */
    public function setCamera(
        nearPlane: Float,
        farPlane: Float,
        vFOV: Float,
        aspectRatio: Float
    ): Void {
        cameraNear = nearPlane;
        cameraFar = farPlane;
        verticalFOV = vFOV;
        this.aspectRatio = aspectRatio;
    }
    
    /**
     * Set depth convention based on graphics API
     * @param useDirectXConvention true for DirectX (0=far, 1=near), false for OpenGL (0=near, 1=far)
     */
    public function setDepthConvention(useDirectXConvention: Bool): Void {
        invertZ = !useDirectXConvention;  // Invert for OpenGL
    }
    
    /**
     * Validate depth configuration
     * @return Array of validation error messages
     */
    public function validate(): Array<String> {
        var errors: Array<String> = [];
        
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
     * Calculate projection matrix parameters
     * Used for reprojection calculations
     * @return Object with projection parameters
     */
    public function getProjectionParams(): ProjectionParams {
        var params: ProjectionParams = {
            near: cameraNear,
            far: cameraFar,
            fov: verticalFOV * Math.PI / 180.0,  // Convert to radians
            aspect: aspectRatio,
            invertZ: invertZ
        };
        return params;
    }
    
    /**
     * Convert NDC depth to linear view-space depth
     * @param ndc Depth in normalized device coordinates (0-1)
     * @return Linear view-space depth
     */
    public function ndcToLinearDepth(ndc: Float): Float {
        if (invertZ) {
            // Reverse-Z convention: ndc = 0 is near, ndc = 1 is far
            return (cameraNear * cameraFar) / (cameraFar + ndc * (cameraNear - cameraFar));
        } else {
            // Traditional convention: ndc = 0 is far, ndc = 1 is near
            return (cameraNear * cameraFar) / (cameraNear - ndc * (cameraNear - cameraFar));
        }
    }
    
    /**
     * Convert linear view-space depth to NDC depth
     * @param linear Linear view-space depth
     * @return Depth in normalized device coordinates
     */
    public function linearDepthToNdc(linear: Float): Float {
        if (invertZ) {
            // Reverse-Z convention
            return 1.0 - (cameraNear * cameraFar) / (linear * (cameraNear - cameraFar) + cameraFar);
        } else {
            // Traditional convention
            return (cameraFar * (cameraFar - linear)) / (linear * (cameraFar - cameraNear));
        }
    }
    
    /**
     * Get debug string representation
     */
    public function toString(): String {
        var convention = invertZ ? "OpenGL (0=near)" : "DirectX (0=far)";
        return 'DLSSDepthConfig{' +
            'convention=$convention, ' +
            'camera=[${cameraNear.toFixed(2)}, ${cameraFar.toFixed(1)}], ' +
            'fov=${verticalFOV.toFixed(1)}°, ' +
            'aspect=${aspectRatio.toFixed(2)}' +
        '}';
    }
}

/**
 * Depth buffer precision levels
 */
@:enum extern abstract DepthPrecision(Int) {
    var Float16 = 0;   // 16-bit float (D3D16F)
    var Float32 = 1;   // 32-bit float (D3D32F) - recommended
}

/**
 * Projection parameters for matrix calculations
 */
typedef ProjectionParams = {
    near: Float,
    far: Float,
    fov: Float,           // In radians
    aspect: Float,
    invertZ: Bool
}
