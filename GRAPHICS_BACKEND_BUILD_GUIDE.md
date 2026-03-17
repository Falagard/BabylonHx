# Graphics Backend Configuration Guide

## Overview

BabylonHx now supports multiple graphics backends through the abstraction layer introduced in Phase 1. The default backend is WebGL, which works on all platforms. Vulkan support is optional and can be enabled with compiler flags.

## Build Configuration

### Default Configuration (WebGL)

The default build uses WebGL and requires no special configuration:

```bash
# Compile with WebGL backend (default)
haxe -x project.xml
```

### Vulkan Optional Support

To enable Vulkan backend support, add the `-D vulkan_support` compiler flag:

```bash
# Compile with Vulkan support enabled
haxe -D vulkan_support -x project.xml
```

When Vulkan support is enabled:
- Both WebGL and Vulkan backends are available at runtime
- The Engine can select between them based on platform and options
- Code for Vulkan backend is only included if the flag is set

### Project Configuration Example

To enable Vulkan in `project.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<project>
    <meta title="BabylonHx" package="com.babylonhx" version="1.0.0" />
    <app main="MainLime" file="BabylonHx" path="bin" />
    
    <source path="src" />
    <source path="com" />
    
    <haxelib name="lime" />
    
    <!-- Enable Vulkan support (optional) -->
    <!-- <define name="vulkan_support" /> -->
    
    <!-- Vulkan SDK paths (if using Vulkan) -->
    <!-- <compilerflag name="-I/path/to/vulkan/include" /> -->
    <!-- <compilerflag name="-L/path/to/vulkan/lib" /> -->
    
    <window require-shaders="true" hardware="true" depth-buffer="true" />
</project>
```

## Runtime Backend Selection

### Automatic Selection

By default, the Engine automatically selects the best available backend:

```haxe
var engine = new Engine(canvas);
// Automatically uses WebGL or Vulkan based on availability
```

In the future, when Vulkan is fully implemented, it will be selected on supported platforms (Windows, Linux, macOS with MoltenVK).

### Explicit Backend Selection

You can hint toward a specific backend:

```haxe
var options = { preferVulkan: true };
var engine = new Engine(canvas, null, false, options);
// Will try Vulkan first, fall back to WebGL if unavailable
```

### Checking Available Backends

```haxe
var backends = GraphicsBackendFactory.getAvailableBackends();
trace(backends); // ["WebGL", "Vulkan"] or ["WebGL"]
```

## Dependencies

### WebGL Backend

- Lime/OpenGL context (automatic via lime library)
- No additional dependencies

### Vulkan Backend (Future)

When implementing Vulkan support, add:

```xml
<!-- In project.xml -->
<define name="vulkan_support" if="(windows || linux || macos)" />

<compilerflag name="-I${VULKAN_SDK}/include" if="vulkan_support" />
<compilerflag name="-L${VULKAN_SDK}/lib" if="vulkan_support" />

<!-- Link Vulkan library -->
<compilerflag name="-lvulkan" if="linux" />
<compilerflag name="-lvulkan-1" if="windows" />
<compilerflag name="-framework Vulkan" if="macos" />
```

## Troubleshooting

### Graphics Backend Not Initializing

If you see the message: `[Engine] Graphics backend initialized successfully` in the console, the abstraction layer is working correctly.

If initialization fails (optional), the engine falls back to direct WebGL calls and continues to work normally.

### Checking Backend at Runtime

```haxe
var engine = new Engine(canvas);
if (engine.graphicsBackend != null) {
    var caps = engine.graphicsBackend.getCapabilities();
    trace("Backend: " + caps.getBackendName());
    trace("Version: " + caps.getBackendVersion());
}
```

## Platform Support

| Platform | WebGL | Vulkan (Planned) |
|----------|-------|------------------|
| Web (JS)  | ✅ Yes | ❌ No            |
| Windows  | ✅ Yes | 🟡 Phase 4       |
| Linux    | ✅ Yes | 🟡 Phase 4       |
| macOS    | ✅ Yes | 🟡 Phase 5 (MoltenVK) |
| iOS      | ✅ Yes | ❌ No            |
| Android  | ✅ Yes | 🟡 Future        |

## Conditional Compilation Usage

In Haxe code, you can conditionally include backend-specific code:

```haxe
// Include everywhere
var backend = new WebGLBackend();

// Include only when Vulkan support is enabled
#if vulkan_support
var vulkanBackend = new VulkanBackend();
#end

// Check multiple conditions
#if (vulkan_support && (windows || linux || macos))
var backendName = "Vulkan";
#else
var backendName = "WebGL";
#end
```

## Testing

To test the graphics abstraction layer:

1. Compile with WebGL (default): `haxe -x project.xml`
   - All existing functionality should work unchanged
   
2. Verify backend initialization:
   - Check console for `[Engine] Graphics backend initialized successfully`
   
3. When Vulkan is available, compile with: `haxe -D vulkan_support -x project.xml`
   - Both backends should be available for selection

## Performance Considerations

- **WebGL Backend**: Fully optimized, no performance impact
- **Vulkan Backend** (future): Expected to provide better performance on capable hardware
- **Compatibility**: WebGL backend maintains backward compatibility with all existing code

## Future Development

As the Vulkan backend is implemented in subsequent phases, this configuration will expand with:
- Shader compilation options (GLSL → SPIRV)
- Vulkan-specific optimization flags
- Platform-specific surface creation options
- Debugging and validation layer controls
