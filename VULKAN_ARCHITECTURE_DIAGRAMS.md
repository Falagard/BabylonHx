# Vulkan Backend Architecture Diagrams

## Current Architecture (Before Refactoring)

```
┌─────────────────────────────────────────┐
│     Scene/Materials/Rendering Layer     │
└──────────────────┬──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│  Engine.hx (Monolithic Graphics API)    │
│  - Direct WebGL2Context usage           │
│  - Shader management (GLSL)             │
│  - State tracking (GL enums)            │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
   GL.hx Wrapper        WebGL2Context
   (WebGL binding)      (Platform API)
        │
        ▼
   Haxe/Lime Framework
```

**Issues:**
- ❌ No abstraction for different graphics APIs
- ❌ WebGL tightly coupled to Engine
- ❌ Shader system GLSL-only
- ❌ Cannot add Vulkan without major rewrites

---

## Proposed Architecture (After Phase 1-3)

```
┌──────────────────────────────────────────────────┐
│   Scene/Materials/Rendering Layer                │
│   (unchanged API - full backward compat)         │
└─────────────────────┬────────────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────┐
        │  Engine.hx (Refactored)     │
        │  - Backend selection        │
        │  - Unified interface        │
        └──────────┬────────────┬─────┘
                   │            │
        ┌──────────▼─┐    ┌─────▼──────────┐
        │IGraphics   │    │IShaderCompiler │
        │Backend     │    │(abstraction)   │
        │(interface) │    └─────┬──────────┘
        └──────────┬─┘          │
                   │            │
     ┌─────────────┼────────────┼──────────────┐
     │             │            │              │
     ▼             ▼            ▼              ▼
WebGLBackend  VulkanBackend  GLSLCompiler  SPIRVCompiler
(existing)    (new)         (existing)    (new)
     │             │            │              │
     ▼             ▼            ▼              ▼
  WebGL 2      Vulkan API     GLSL        Shader Reflection
  Context      Binding        Binary      + SPIRV Binary
```

---

## Phase-by-Phase Evolution

### Phase 1: Graphics Abstraction Layer

```
┌─────────────────────────────┐
│  Graphics Backend Interface │
└────────────────┬────────────┘
                 │
    ┌────────────┴────────────┐
    │                         │
    ▼                         ▼
WebGLBackend           [VulkanBackend Placeholder]
├─ createBuffer()       (implemented in Phase 4)
├─ createTexture()
├─ createProgram()
└─ submit()
```

### Phase 4: Vulkan Implementation

```
┌──────────────────────────────────────────┐
│      VulkanBackend                       │
├──────────────────────────────────────────┤
│                                          │
│  Instance Creation                       │
│  ├─ vkCreateInstance                     │
│  ├─ Physical Device Selection            │
│  └─ Logical Device Creation              │
│                                          │
│  Resource Management                     │
│  ├─ VulkanBuffer                         │
│  ├─ VulkanTexture                        │
│  └─ VulkanImage                          │
│                                          │
│  Pipeline Management                     │
│  ├─ VulkanGraphicsPipeline               │
│  ├─ DescriptorSet Pool/Layout            │
│  └─ ShaderReflection                     │
│                                          │
│  Command Recording                       │
│  ├─ CommandPool                          │
│  ├─ Primary/Secondary Buffers            │
│  └─ Synchronization (Semaphores/Fences) │
│                                          │
│  Platform Integration                    │
│  ├─ Windows (VK_KHR_win32_surface)      │
│  ├─ Linux (VK_KHR_xcb_surface)          │
│  └─ macOS (MoltenVK)                    │
│                                          │
└──────────────────────────────────────────┘
```

---

## Shader Compilation Pipeline Evolution

### Current (WebGL-only)

```
GLSL Source
    │
    ▼
Preprocess
    │
    ▼
GL Compiler
    │
    ▼
WebGL Program Object
```

### After Phase 2-4 (Dual-path)

```
GLSL Source
    │
    ├─────────────────┬─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
Preprocess      [Same for both paths]
    │
    ├─────────────────┬─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
GLSLCompiler    SPIRVCompiler
    │                 │
    ▼                 ▼
WebGL Program   SPIRV Binary
    │                 │
    ▼                 ▼
WebGL Backend   ShaderReflection
    │                 │
    ▼                 ▼
Render          DescriptorLayout
                 │
                 ▼
            VulkanPipeline
                 │
                 ▼
            Vulkan Render
```

---

## Abstraction Layer Key Interfaces

### IGraphicsBackend Interface

```
IGraphicsBackend
├─ createBuffer(data, usage) → IGraphicsBuffer
├─ createTexture(options) → IGraphicsTexture
├─ createProgram(vs, fs) → IGraphicsProgram
├─ beginFrame() → void
├─ endFrame() → void
├─ submit(commands) → void
└─ getCapabilities() → IGraphicsCapabilities
```

### IShaderCompiler Interface

```
IShaderCompiler
├─ compileVertexShader(source) → ShaderBinary
├─ compileFragmentShader(source) → ShaderBinary
├─ linkProgram(vertex, fragment) → IShaderProgram
└─ getShaderReflection() → ShaderReflection
```

---

## Implementation Dependency Graph

```
Phase 1: Graphics Abstraction
    ↓
┌───────────────────────────────────────┐
│ Enables:                              │
│ - WebGL backend wrapping              │
│ - Backend selection at runtime        │
└───────────────────────────────────────┘
    ↓
Phase 2: Shader Compilation Abstraction
    ↓
┌───────────────────────────────────────┐
│ Enables:                              │
│ - GLSL→SPIRV compilation              │
│ - Shader reflection                   │
└───────────────────────────────────────┘
    ↓
Phase 3: State Pipeline Mapping
    ↓
┌───────────────────────────────────────┐
│ Enables:                              │
│ - Vulkan pipeline state mapping       │
│ - Render state abstraction            │
└───────────────────────────────────────┘
    ↓
Phase 4-6: Vulkan Backend Implementation
    ↓
┌───────────────────────────────────────┐
│ Result:                               │
│ - Full Vulkan rendering               │
│ - Platform support (Win/Linux/macOS)  │
│ - Multi-backend support               │
└───────────────────────────────────────┘
```

---

## Code Organization - Before vs After

### Before (Current)

```
com/babylonhx/
└── engine/
    ├── Engine.hx         [1000+ lines, WebGL-specific]
    └── ...
    
com/babylonhx/mesh/
├── WebGLBuffer.hx        [WebGL-specific class]
└── ...

com/babylonhx/materials/
├── Effect.hx             [GLSL shader compilation]
└── ...
```

### After (Proposed)

```
com/babylonhx/
└── engine/
    ├── Engine.hx         [Refactored, backend-agnostic]
    ├── graphics/         [NEW - Graphics abstraction]
    │   ├── IGraphicsBackend.hx
    │   ├── IGraphicsBuffer.hx
    │   ├── IGraphicsTexture.hx
    │   ├── IRenderPipeline.hx
    │   ├── webgl/        [WebGL backend - NEW folder]
    │   │   ├── WebGLBackend.hx
    │   │   ├── WebGLBuffer.hx
    │   │   ├── WebGLTexture.hx
    │   │   └── WebGLProgram.hx
    │   └── vulkan/       [Vulkan backend - NEW folder]
    │       ├── VulkanBackend.hx
    │       ├── VulkanBuffer.hx
    │       ├── VulkanTexture.hx
    │       ├── VulkanPipeline.hx
    │       ├── VulkanCommandBuffer.hx
    │       ├── ShaderReflection.hx
    │       ├── VulkanBindings.hx
    │       └── platform/
    │           ├── VulkanWindows.hx
    │           ├── VulkanLinux.hx
    │           └── VulkanMacOS.hx
    └── ...

com/babylonhx/materials/
├── Effect.hx             [Refactored - uses IShaderCompiler]
├── IShaderCompiler.hx    [NEW - abstraction]
├── shaders/              [NEW - compiler implementations]
│   ├── GLSLCompiler.hx
│   └── SPIRVCompiler.hx
└── ...
```

---

## Build System Configuration

### Current project.xml

```xml
<haxelib name="lime" />
<!-- WebGL/OpenGL only -->
```

### Proposed project.xml extensions

```xml
<!-- Existing -->
<haxelib name="lime" />

<!-- New optional Vulkan support -->
<define name="vulkan_support" if="(windows || linux || macos)" />

<!-- Platform-specific Vulkan libraries -->
<compilerflag name="-I/path/to/vulkan/include" if="vulkan_support" />
<compilerflag name="-lvulkan" if="(linux && vulkan_support)" />
<compilerflag name="-lvulkan-1" if="(windows && vulkan_support)" />

<!-- Build variants -->
<target name="html5" />         <!-- WebGL only -->
<target name="windows" />       <!-- WebGL or Vulkan -->
<target name="linux" />         <!-- WebGL or Vulkan -->
<target name="android" />       <!-- WebGL only -->
```

---

## Timeline Visual

```
Phase 1: Graphics Abstraction     ████████████████░░░░░░░░░░░░  2-4 weeks
Phase 2: Shader Abstraction       ░░░░░░░░░░░░░░░░████████░░░░░  1-2 weeks
Phase 3: State Pipeline Mapping   ░░░░░░░░░░░░░░░░░░░░░░████████  1.5-2 weeks
Phase 4: Vulkan Core Backend      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██████████████ 4-6 weeks
Phase 5: Platform Integration     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████ 2-3 weeks
Phase 6: Materials & Effects      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████ 2-3 weeks
Phase 7: Testing & Optimization   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████ 2-3 weeks

                                    Total: 15-23 weeks (~4-6 months)
```

---

## System Requirements per Phase

| Phase | Components | Skills Needed | Tools Required |
|-------|-----------|---------------|----------------|
| 1-3 | Architecture, Interfaces | Haxe, OOP Design | Build system |
| 4-6 | Vulkan Implementation | Graphics API, C++, FFI | Vulkan SDK, glslang |
| 7 | Testing, Profiling | Testing, Performance | RenderDoc, GPU debuggers |

---

## Example: Rendering a Triangle - Evolution

### Current Code (WebGL-only)

```haxe
var engine = new Engine(canvas);
var scene = new Scene(engine);

var triangle = MeshBuilder.CreateTriangle("tri", scene);
var mat = new StandardMaterial("mat", scene);
triangle.material = mat;

engine.runRenderLoop(function() {
    scene.render();
});
```

### After Phase 1 (Same code, multi-backend support)

```haxe
// Initialization automatically chooses backend
var options:EngineOptions = {
    preferVulkan: true  // Try Vulkan, fallback to WebGL
};
var engine = new Engine(canvas, options);
// Rest of code identical - works on any backend!
```

### Vulkan-specific optimizations (Phase 6+)

```haxe
// Advanced users can access backend-specific features
#if vulkan_support
if (engine.getBackend().supportsMultiThreadedRecording()) {
    engine.recordCommandBuffersParallel(renderTasks);
}
#end
```

