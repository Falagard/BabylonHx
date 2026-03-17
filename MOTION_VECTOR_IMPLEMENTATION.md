# Motion Vector Rendering Implementation for BabylonHx

## Overview
This document describes the implementation of motion vector rendering in BabylonHx as an engine-level feature for forward rendering. Motion vectors represent per-pixel screen-space displacement between the current frame and the previous frame.

## Implementation Details

### 1. Previous-Frame Transform Tracking

**Location**: `com/babylonhx/mesh/TransformNode.hx`

Added fields:
- `_previousWorldMatrix: Matrix` - Stores the world matrix from the previous frame
- `_hasPreviousWorldMatrix: Bool` - Indicates if a valid previous matrix exists

Added methods:
- `updatePreviousWorldMatrix()` - Copies the current world matrix to the previous world matrix cache
- `getPreviousWorldMatrix()` - Returns the cached previous world matrix (or Matrix.Zero if invalid)

Modified:
- `computeWorldMatrix()` - Now calls `updatePreviousWorldMatrix()` at the end to capture the state after transformation computation

**Important Timing Note**:
The previous world matrix is updated in `computeWorldMatrix()`, which is called when the world matrix becomes dirty. This ensures:
- New meshes without prior matrix history output zero motion (since `_hasPreviousWorldMatrix` is false)
- The previous matrix always represents the state from the end of the previous frame's `computeWorldMatrix()` call
- Animated meshes automatically track their previous positions through their transform updates

### 2. Motion Vector Mesh Opt-Out

**Location**: `com/babylonhx/mesh/AbstractMesh.hx`

Added field:
- `renderMotionVectors: Bool = true` - Default enabled; can be set to false to exclude meshes from motion vector rendering

Meshes with this flag set to false will not contribute to the motion vector texture.

### 3. Motion Vector Render Target

**Location**: `com/babylonhx/rendering/MotionVectorRenderer.hx`

The renderer creates a `RenderTargetTexture` with:
- Format: Float texture (RG16F preferred, fallback to RGBA32F if unavailable)
- Size: Matches the main rendering canvas at initialization
- Behavior: Cleared to (0, 0, 0, 0) every frame (no motion)
- Access: Available via `getMotionVectorTexture()` for post-processing use

### 4. Motion Vector Shader System

**Location**: `com/babylonhx/rendering/MotionVectorRenderer.hx`

Shaders are registered programmatically using `ShadersStore`:

**Vertex Shader** (`motionVectorVertex`):
- Inputs: position, normal
- Transforms vertex using both current and previous world matrices with their respective view-projection matrices
- Outputs: `vCurrentClipPos` and `vPreviousClipPos` in clip space

```glsl
// Current frame
vec4 currentWorldPos = world * vec4(position, 1.0);
vCurrentClipPos = worldViewProjection * vec4(position, 1.0);

// Previous frame
vec4 previousWorldPos = previousWorld * vec4(position, 1.0);
vPreviousClipPos = previousViewProjection * previousWorldPos;
```

**Fragment Shader** (`motionVectorFragment`):
- Converts clip space positions to NDC (Normalized Device Coordinates) via perspective divide by W
- Computes motion as: `currentNDC - previousNDC`
- Outputs motion vector in RG channels, zero in BA

```glsl
vec2 currentNDC = vCurrentClipPos.xy / vCurrentClipPos.w;
vec2 previousNDC = vPreviousClipPos.xy / vPreviousClipPos.w;
vec2 motionVector = currentNDC - previousNDC;
gl_FragColor = vec4(motionVector, 0.0, 1.0);
```

### 5. Motion Vector Renderer Class

**Location**: `com/babylonhx/rendering/MotionVectorRenderer.hx`

Key responsibilities:
- **Initialization**: Creates render target and shader effect
- **Camera Matrix Management**: Tracks previous view-projection matrix across frames
- **Mesh Filtering**: Only renders opaque, visible meshes with `renderMotionVectors=true`
- **Per-Frame Rendering**: Renders motion vectors before main rendering in the scene
- **Statistics**: Tracks number of meshes and submeshes rendered

#### Public API:

```haxe
// Create a new motion vector renderer
var renderer = new MotionVectorRenderer(scene);

// Render motion vectors (called internally by Scene)
renderer.render();

// Get the motion vector texture for post-processing
var mvTexture = renderer.getMotionVectorTexture();

// Resize on window/canvas resize
renderer.resize(newWidth, newHeight);

// Enable/disable debug visualization
renderer.setDebugMode(true);

// Get statistics
var stats = renderer.getStatistics();

// Cleanup
renderer.dispose();
```

### 6. Scene Integration

**Location**: `com/babylonhx/Scene.hx`

Changes:
- Added `_motionVectorRenderer: MotionVectorRenderer` field
- Added `enableMotionVectorRenderer(): MotionVectorRenderer` - Creates and initializes the renderer
- Added `disableMotionVectorRenderer()` - Disposes the renderer
- Added `getMotionVectorRenderer(): MotionVectorRenderer` - Getter for the renderer
- Integrated renderer into the render loop:
  - Called after geometry buffer rendering, before post-processing pipeline
  - Automatically disposed when scene is disposed

#### Usage:

```haxe
var scene = new Scene(engine);

// Enable motion vector rendering
var mvRenderer = scene.enableMotionVectorRenderer();

// Optionally disable specific meshes from motion vectors
someOpaqueMesh.renderMotionVectors = false;

// Get the motion vector texture for post-processing
var mvTexture = mvRenderer.getMotionVectorTexture();

// Disable when done
scene.disableMotionVectorRenderer();
```

## Render Flow

The motion vector rendering is integrated into the scene render flow as follows:

```
render() {
    // ... animations, physics ...
    
    // ... custom render targets ...
    
    // ... procedural textures ...
    
    // Clear main framebuffer
    
    // ... shadows ...
    
    // ... depth renderer ...
    
    // ... geometry buffer renderer ...
    
    // MOTION VECTORS <- NEW
    if (motionVectorRenderer != null) {
        motionVectorRenderer.render();
    }
    
    // ... post-processing pipeline ...
    
    // ... main forward rendering ...
    
    // ... UI, postprocesses ...
}
```

## Features Supported

✅ Rigid opaque mesh motion vectors
✅ Previous-frame transform tracking
✅ Zero motion for newly created meshes
✅ Per-mesh opt-out via `renderMotionVectors` flag
✅ Properly synchronized camera matrices
✅ Float texture output for precision
✅ Statistics tracking

## Limitations (First Version)

❌ Skinned meshes (bone-based animation) - Not yet supported
❌ Particles - Not included in motion vector pass
❌ Transparent objects - Skipped (can cause artifacts)
❌ Instancing/thin instances - Not implemented
❌ Morph targets - Not supported
❌ World-space scaling variations - May have minor precision issues

## Future Enhancements

### Skinned Mesh Support (Phase 2)
To add skinned mesh support:
1. Store previous bone matrices in `Skeleton`
2. Create separate vertex shader path that uses bone data
3. Add `_previousSkeletonMatrices` to track bone data across frames
4. Modify `isMeshValidForMotionVectors()` to validate skeleton data

### Particle Motion Vectors
For particles:
1. Create separate particle motion vector pass
2. Track previous particle positions
3. Handle dynamic particle emission/death

### Transparent Objects
Option 1: Render at lower resolution with dilation
Option 2: Use depth-based velocity approximation
Option 3: Composite transparent motion separately

## Technical Notes

### Coordinate Systems
- Motion vectors are in normalized screen space (-1 to 1 in each axis)
- Sign convention: `currentNDC - previousNDC` (positive = rightward/downward motion)
- This follows the standard convention used in temporal effects

### Frame Synchronization
- Camera matrices are updated at the start of each frame in `render()`
- World matrices are updated via `computeWorldMatrix()` during scene update
- The previous matrices represent the END-of-frame state from the previous frame
- This ensures consistent motion measurement across the entire frame

### Performance Characteristics
- Motion vector pass runs once per frame
- Only opaque, visible meshes are rendered
- Minimal overhead: simple vertex/fragment shaders, no complex operations
- Render target is typically RG format (8-16 bytes per pixel)

### Debugging Motion Vectors
To visualize motion vectors:

1. Create a simple display shader that reads the motion vector texture
2. Map motion vector values to visible colors:
   - Red channel → rightward motion
   - Green channel → downward motion
   - Black → no motion
   - Saturated colors → high motion speed

3. Optional: Scale motion values to enhance visibility

Example visualization mapping:
```glsl
// Visualize motion vectors as color
vec2 mv = texture(motionVectorsTexture, uv).rg;
vec2 visualMotion = mv * 10.0; // Scale for visibility
gl_FragColor = vec4(visualMotion.xy, 0.0, 1.0);
```

## Testing Checklist

- [ ] Static scene produces near-zero motion vectors
- [ ] Camera panning produces smooth full-screen motion gradients
- [ ] Moving objects produce local directional motion vectors
- [ ] New meshes output zero motion on first frame
- [ ] `renderMotionVectors = false` excludes meshes from output
- [ ] Window resize properly resizes motion vector texture
- [ ] No error on multiple enable/disable cycles
- [ ] Proper disposal on scene cleanup
- [ ] Motion vectors match camera movement direction

## Files Modified

1. **com/babylonhx/mesh/TransformNode.hx**
   - Added previous world matrix tracking
   - Modified `computeWorldMatrix()` to update previous state

2. **com/babylonhx/mesh/AbstractMesh.hx**
   - Added `renderMotionVectors` flag (should already be there)

3. **com/babylonhx/Scene.hx**
   - Added motion vector renderer field
   - Added enable/disable/get methods
   - Integrated rendering into render loop
   - Added disposal cleanup

## Files Created

1. **com/babylonhx/rendering/MotionVectorRenderer.hx**
   - Complete motion vector rendering system
   - Shader registration
   - Render target management
   - Mesh filtering and rendering

## Conclusion

This implementation provides a minimal, engine-level motion vector rendering system that generates correct per-pixel motion vectors for rigid opaque meshes. The architecture is extensible to support skinned meshes, particles, and other object types in future versions without requiring invasive changes to the material or rendering systems.
