# Vulkan Backend Implementation - Quick Start Guide

## Overview

This guide provides actionable steps to begin implementing Vulkan support in BabylonHx, starting with Phase 1 (Graphics Abstraction Layer).

---

## Phase 1: Graphics Abstraction Layer (Start Here)

### Step 1.1: Create Core Backend Interface

**File:** `com/babylonhx/engine/graphics/IGraphicsBackend.hx`

```haxe
package com.babylonhx.engine.graphics;

import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;

/**
 * Core abstraction for graphics rendering backends
 * Enables support for WebGL, Vulkan, DirectX, etc.
 */
interface IGraphicsBackend {
    /**
     * Initialize graphics backend
     */
    function initialize(canvas:Dynamic):Void;
    
    /**
     * Create a GPU buffer
     * @param data Initial data (can be null)
     * @param usage Buffer usage flags (e.g., GL.ARRAY_BUFFER)
     * @param isStatic Whether buffer is frequently updated
     */
    function createBuffer(data:Float32Array, usage:Int, isStatic:Bool):IGraphicsBuffer;
    
    /**
     * Create an index buffer
     */
    function createIndexBuffer(indices:Int32Array):IGraphicsBuffer;
    
    /**
     * Create a texture
     */
    function createTexture(width:Int, height:Int, format:Int, generateMipMaps:Bool):IGraphicsTexture;
    
    /**
     * Create a shader program
     */
    function createProgram(vertexSource:String, fragmentSource:String):IGraphicsProgram;
    
    /**
     * Clear the render target
     */
    function clear(color:com.babylonhx.math.Color4, clearColor:Bool, clearDepth:Bool, clearStencil:Bool):Void;
    
    /**
     * Begin frame rendering
     */
    function beginFrame():Void;
    
    /**
     * End frame and present
     */
    function endFrame():Void;
    
    /**
     * Get graphics capabilities
     */
    function getCapabilities():IGraphicsCapabilities;
    
    /**
     * Dispose backend and cleanup resources
     */
    function dispose():Void;
}

interface IGraphicsBuffer {
    function bind(target:Int):Void;
    function write(data:com.babylonhx.utils.typedarray.ArrayBufferView, offset:Int):Void;
    function getData():com.babylonhx.utils.typedarray.ArrayBufferView;
    function dispose():Void;
}

interface IGraphicsTexture {
    function bind(slot:Int):Void;
    function setData(data:com.babylonhx.utils.typedarray.ArrayBufferView, width:Int, height:Int, format:Int):Void;
    function dispose():Void;
}

interface IGraphicsProgram {
    function bind():Void;
    function unbind():Void;
    function getUniformLocation(name:String):Dynamic;
    function setAttribute(name:String, buffer:IGraphicsBuffer, size:Int, offset:Int):Void;
    function dispose():Void;
}

interface IGraphicsCapabilities {
    var maxTextureSize:Int;
    var maxVertexAttributes:Int;
    var supportsShadows:Bool;
    var supportsInstancing:Bool;
    var supportsTextureArrays:Bool;
}
```

### Step 1.2: Create WebGL Backend Implementation

**File:** `com/babylonhx/engine/graphics/webgl/WebGLBackend.hx`

```haxe
package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.IGraphicsBackend;
import com.babylonhx.engine.graphics.IGraphicsBuffer;
import com.babylonhx.engine.graphics.IGraphicsTexture;
import com.babylonhx.engine.graphics.IGraphicsProgram;
import com.babylonhx.engine.graphics.IGraphicsCapabilities;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.GLBuffer;
import com.babylonhx.utils.GL.GLTexture;
import com.babylonhx.utils.GL.GLProgram;
import com.babylonhx.utils.typedarray.Float32Array;
import com.babylonhx.utils.typedarray.Int32Array;
import com.babylonhx.math.Color4;

class WebGLBackend implements IGraphicsBackend {
    private var gl:Dynamic; // WebGL context
    private var canvas:Dynamic;
    
    public function new() {}
    
    public function initialize(canvas:Dynamic):Void {
        this.canvas = canvas;
        
        #if (js || purejs)
        this.gl = canvas.getContext('webgl2') != null ? 
            canvas.getContext('webgl2') : 
            canvas.getContext('webgl');
        #elseif lime
        this.gl = lime.graphics.opengl.GL; // Lime-based GL context
        #end
    }
    
    public function createBuffer(data:Float32Array, usage:Int, isStatic:Bool):IGraphicsBuffer {
        var buffer = gl.createBuffer();
        gl.bindBuffer(usage, buffer);
        gl.bufferData(usage, data, isStatic ? GL.STATIC_DRAW : GL.DYNAMIC_DRAW);
        return new WebGLBufferImpl(gl, buffer, usage);
    }
    
    public function createIndexBuffer(indices:Int32Array):IGraphicsBuffer {
        var buffer = gl.createBuffer();
        gl.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, buffer);
        gl.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
        return new WebGLBufferImpl(gl, buffer, GL.ELEMENT_ARRAY_BUFFER);
    }
    
    public function createTexture(width:Int, height:Int, format:Int, generateMipMaps:Bool):IGraphicsTexture {
        var texture = gl.createTexture();
        return new WebGLTextureImpl(gl, texture, width, height, format, generateMipMaps);
    }
    
    public function createProgram(vertexSource:String, fragmentSource:String):IGraphicsProgram {
        var vs = gl.createShader(GL.VERTEX_SHADER);
        gl.shaderSource(vs, vertexSource);
        gl.compileShader(vs);
        
        var fs = gl.createShader(GL.FRAGMENT_SHADER);
        gl.shaderSource(fs, fragmentSource);
        gl.compileShader(fs);
        
        var program = gl.createProgram();
        gl.attachShader(program, vs);
        gl.attachShader(program, fs);
        gl.linkProgram(program);
        
        return new WebGLProgramImpl(gl, program);
    }
    
    public function clear(color:Color4, clearColor:Bool, clearDepth:Bool, clearStencil:Bool):Void {
        if (clearColor) {
            gl.clearColor(color.r, color.g, color.b, color.a);
            gl.clear(GL.COLOR_BUFFER_BIT);
        }
        if (clearDepth) {
            gl.clear(GL.DEPTH_BUFFER_BIT);
        }
        if (clearStencil) {
            gl.clear(GL.STENCIL_BUFFER_BIT);
        }
    }
    
    public function beginFrame():Void {
        // WebGL typically doesn't need this
    }
    
    public function endFrame():Void {
        // WebGL automatically presents
    }
    
    public function getCapabilities():IGraphicsCapabilities {
        return new WebGLCapabilities(gl);
    }
    
    public function dispose():Void {
        // Cleanup
    }
}

private class WebGLBufferImpl implements IGraphicsBuffer {
    private var gl:Dynamic;
    private var buffer:GLBuffer;
    private var target:Int;
    
    public function new(gl:Dynamic, buffer:GLBuffer, target:Int) {
        this.gl = gl;
        this.buffer = buffer;
        this.target = target;
    }
    
    public function bind(target:Int):Void {
        gl.bindBuffer(target, this.buffer);
    }
    
    public function write(data:com.babylonhx.utils.typedarray.ArrayBufferView, offset:Int):Void {
        gl.bufferSubData(this.target, offset, data);
    }
    
    public function getData():com.babylonhx.utils.typedarray.ArrayBufferView {
        // WebGL limitation: cannot read back buffer data easily
        return null;
    }
    
    public function dispose():Void {
        gl.deleteBuffer(this.buffer);
    }
}

private class WebGLTextureImpl implements IGraphicsTexture {
    private var gl:Dynamic;
    private var texture:GLTexture;
    private var width:Int;
    private var height:Int;
    
    public function new(gl:Dynamic, texture:GLTexture, width:Int, height:Int, format:Int, generateMipMaps:Bool) {
        this.gl = gl;
        this.texture = texture;
        this.width = width;
        this.height = height;
    }
    
    public function bind(slot:Int):Void {
        gl.activeTexture(GL.TEXTURE0 + slot);
        gl.bindTexture(GL.TEXTURE_2D, this.texture);
    }
    
    public function setData(data:com.babylonhx.utils.typedarray.ArrayBufferView, width:Int, height:Int, format:Int):Void {
        gl.bindTexture(GL.TEXTURE_2D, this.texture);
        gl.texImage2D(GL.TEXTURE_2D, 0, GL.RGBA, width, height, 0, GL.RGBA, GL.UNSIGNED_BYTE, data);
    }
    
    public function dispose():Void {
        gl.deleteTexture(this.texture);
    }
}

private class WebGLProgramImpl implements IGraphicsProgram {
    private var gl:Dynamic;
    private var program:GLProgram;
    
    public function new(gl:Dynamic, program:GLProgram) {
        this.gl = gl;
        this.program = program;
    }
    
    public function bind():Void {
        gl.useProgram(this.program);
    }
    
    public function unbind():Void {
        gl.useProgram(null);
    }
    
    public function getUniformLocation(name:String):Dynamic {
        return gl.getUniformLocation(this.program, name);
    }
    
    public function setAttribute(name:String, buffer:IGraphicsBuffer, size:Int, offset:Int):Void {
        // Implementation would bind buffer and set vertex attributes
    }
    
    public function dispose():Void {
        gl.deleteProgram(this.program);
    }
}

private class WebGLCapabilities implements IGraphicsCapabilities {
    private var gl:Dynamic;
    
    public var maxTextureSize(get, never):Int;
    public var maxVertexAttributes(get, never):Int;
    public var supportsShadows(get, never):Bool;
    public var supportsInstancing(get, never):Bool;
    public var supportsTextureArrays(get, never):Bool;
    
    public function new(gl:Dynamic) {
        this.gl = gl;
    }
    
    function get_maxTextureSize():Int {
        return gl.getParameter(GL.MAX_TEXTURE_SIZE);
    }
    
    function get_maxVertexAttributes():Int {
        return gl.getParameter(GL.MAX_VERTEX_ATTRIBS);
    }
    
    function get_supportsShadows():Bool {
        return true;
    }
    
    function get_supportsInstancing():Bool {
        return true;
    }
    
    function get_supportsTextureArrays():Bool {
        return #if (js || purejs) true #else false #end;
    }
}
```

### Step 1.3: Refactor Engine.hx

Replace direct GL usage with backend interface:

```haxe
class Engine {
    private var _graphics:IGraphicsBackend;
    private var gl:Dynamic; // Keep for backward compatibility during transition
    
    public function new(canvas:Dynamic, ?options:EngineOptions) {
        super(canvas, options);
        
        // Initialize graphics backend
        #if vulkan_support
        if (options != null && options.preferVulkan && VulkanBackend.isSupported()) {
            this._graphics = new VulkanBackend();
        } else
        #end
        {
            this._graphics = new WebGLBackend();
        }
        
        this._graphics.initialize(canvas);
        
        // Keep WebGL context for backward compatibility
        #if (js || purejs)
        this.gl = canvas.getContext('webgl2') ?? canvas.getContext('webgl');
        #end
    }
    
    public function getGraphicsBackend():IGraphicsBackend {
        return this._graphics;
    }
    
    // Existing methods now delegate to backend
    override public function createVertexBuffer(vertices:Float32Array):WebGLBuffer {
        var backendBuffer = this._graphics.createBuffer(vertices, GL.ARRAY_BUFFER, false);
        return new WebGLBuffer(backendBuffer);
    }
}
```

### Step 1.4: Build System Configuration

**File:** `project.xml` (additions)

```xml
<!-- Enable multi-backend compilation -->
<define name="multi_backend_graphics" />

<!-- Optional Vulkan support (disabled by default) -->
<define name="vulkan_support" if="desktop" />

<!-- Build variants -->
<set name="backend" value="webgl" unless="defined(backend)" />
```

### Step 1.5: Unit Tests

**File:** `tests/GraphicsBackendTests.hx`

```haxe
package tests;

import com.babylonhx.engine.graphics.webgl.WebGLBackend;
import com.babylonhx.engine.graphics.IGraphicsBackend;
import com.babylonhx.utils.typedarray.Float32Array;

class GraphicsBackendTests {
    
    public function testWebGLBackendInitialization():Void {
        var backend = new WebGLBackend();
        // Mock canvas or use test canvas
        // backend.initialize(mockCanvas);
        // Assert backend is ready
    }
    
    public function testBufferCreation():Void {
        var data = new Float32Array([0.0, 1.0, 2.0, 3.0]);
        var buffer = backend.createBuffer(data, GL.ARRAY_BUFFER, true);
        Assert.isNotNull(buffer);
    }
    
    public function testTextureCreation():Void {
        var texture = backend.createTexture(512, 512, GL.RGBA, true);
        Assert.isNotNull(texture);
    }
}
```

---

## Phase 2: Shader Compilation Abstraction

### Step 2.1: Create Shader Compiler Interface

**File:** `com/babylonhx/materials/IShaderCompiler.hx`

```haxe
package com.babylonhx.materials;

interface IShaderCompiler {
    function compileVertexShader(source:String):ShaderBinary;
    function compileFragmentShader(source:String):ShaderBinary;
    function linkProgram(vertex:ShaderBinary, fragment:ShaderBinary):ShaderProgram;
}

class ShaderBinary {
    public var data:Dynamic; // Can be WebGL shader object or SPIRV bytecode
    public var type:String;  // "glsl", "spirv", etc.
    public var format:String; // "native", "spirv_binary", etc.
    
    public var source:String; // Original source for debugging
    public var compileLog:String;
    public var compiled:Bool;
}

class ShaderProgram {
    public var native:Dynamic;  // Native API-specific object
    public var vertex:ShaderBinary;
    public var fragment:ShaderBinary;
    public var uniforms:Map<String, UniformDesc>;
    public var attributes:Map<String, AttributeDesc>;
}

class UniformDesc {
    public var name:String;
    public var type:String; // "float", "vec3", "mat4", etc.
    public var size:Int;
    public var location:Dynamic;
}

class AttributeDesc {
    public var name:String;
    public var type:String;
    public var location:Int;
}
```

### Step 2.2: GLSLCompiler Implementation

**File:** `com/babylonhx/materials/shaders/GLSLCompiler.hx`

```haxe
package com.babylonhx.materials.shaders;

import com.babylonhx.materials.IShaderCompiler;

class GLSLCompiler implements IShaderCompiler {
    private var gl:Dynamic;
    
    public function new(gl:Dynamic) {
        this.gl = gl;
    }
    
    public function compileVertexShader(source:String):ShaderBinary {
        return compileShader(source, GL.VERTEX_SHADER);
    }
    
    public function compileFragmentShader(source:String):ShaderBinary {
        return compileShader(source, GL.FRAGMENT_SHADER);
    }
    
    private function compileShader(source:String, type:Int):ShaderBinary {
        var shader = gl.createShader(type);
        gl.shaderSource(shader, source);
        gl.compileShader(shader);
        
        var compiled = gl.getShaderParameter(shader, GL.COMPILE_STATUS);
        
        var binary = new ShaderBinary();
        binary.data = shader;
        binary.type = "glsl";
        binary.format = "native";
        binary.source = source;
        binary.compiled = compiled;
        
        if (!compiled) {
            binary.compileLog = gl.getShaderInfoLog(shader);
        }
        
        return binary;
    }
    
    public function linkProgram(vertex:ShaderBinary, fragment:ShaderBinary):ShaderProgram {
        var program = gl.createProgram();
        gl.attachShader(program, vertex.data);
        gl.attachShader(program, fragment.data);
        gl.linkProgram(program);
        
        var linked = gl.getProgramParameter(program, GL.LINK_STATUS);
        
        var prog = new ShaderProgram();
        prog.native = program;
        prog.vertex = vertex;
        prog.fragment = fragment;
        
        // Extract uniform and attribute information
        prog.uniforms = extractUniforms(program);
        prog.attributes = extractAttributes(program);
        
        return prog;
    }
    
    private function extractUniforms(program:Dynamic):Map<String, UniformDesc> {
        var uniforms = new Map<String, UniformDesc>();
        var count:Int = gl.getProgramParameter(program, GL.ACTIVE_UNIFORMS);
        
        for (i in 0...count) {
            var info = gl.getActiveUniform(program, i);
            var desc = new UniformDesc();
            desc.name = info.name;
            desc.type = getTypeName(info.type);
            desc.size = info.size;
            desc.location = gl.getUniformLocation(program, info.name);
            uniforms.set(info.name, desc);
        }
        
        return uniforms;
    }
    
    private function extractAttributes(program:Dynamic):Map<String, AttributeDesc> {
        var attrs = new Map<String, AttributeDesc>();
        var count:Int = gl.getProgramParameter(program, GL.ACTIVE_ATTRIBUTES);
        
        for (i in 0...count) {
            var info = gl.getActiveAttrib(program, i);
            var desc = new AttributeDesc();
            desc.name = info.name;
            desc.type = getTypeName(info.type);
            desc.location = gl.getAttribLocation(program, info.name);
            attrs.set(info.name, desc);
        }
        
        return attrs;
    }
    
    private function getTypeName(glType:Int):String {
        return switch(glType) {
            case GL.FLOAT: "float";
            case GL.FLOAT_VEC2: "vec2";
            case GL.FLOAT_VEC3: "vec3";
            case GL.FLOAT_VEC4: "vec4";
            case GL.FLOAT_MAT2: "mat2";
            case GL.FLOAT_MAT3: "mat3";
            case GL.FLOAT_MAT4: "mat4";
            case GL.SAMPLER_2D: "sampler2D";
            case _: "unknown";
        }
    }
}
```

---

## Phase 4: Vulkan Backend Skeleton

### Step 4.1: Create Vulkan Bindings

**File:** `com/babylonhx/engine/graphics/vulkan/VulkanBindings.hx`

```haxe
package com.babylonhx.engine.graphics.vulkan;

#if cpp
@:include("vulkan/vulkan.h")
@:buildXml('
    <target id="haxe">
        <lib name="vulkan" if="linux" />
        <lib name="vulkan-1" if="windows" />
    </target>
')
extern class VulkanBindings {
    @:native("vkCreateInstance")
    static function createInstance(
        createInfo:cpp.Pointer<VkInstanceCreateInfo>,
        allocator:cpp.Pointer<Void>,
        instance:cpp.Pointer<VkInstance>
    ):Int;
    
    // Additional bindings...
}

@:unreflective
extern class VkInstance {}

@:unreflective
extern class VkPhysicalDevice {}

@:unreflective
extern class VkDevice {}

// ... Additional type definitions
#end
```

### Step 4.2: Vulkan Backend Skeleton

**File:** `com/babylonhx/engine/graphics/vulkan/VulkanBackend.hx`

```haxe
#if (vulkan_support && cpp)
package com.babylonhx.engine.graphics.vulkan;

import com.babylonhx.engine.graphics.IGraphicsBackend;

class VulkanBackend implements IGraphicsBackend {
    private var instance:VkInstance;
    private var physicalDevice:VkPhysicalDevice;
    private var device:VkDevice;
    private var graphicsQueue:VkQueue;
    
    public function new() {
        trace("VulkanBackend: Initializing...");
    }
    
    public static function isSupported():Bool {
        #if (cpp)
        // Check if Vulkan SDK is available
        return true;  // Simplified check
        #end
        return false;
    }
    
    public function initialize(canvas:Dynamic):Void {
        trace("VulkanBackend: initialize()");
        // Implementation in Phase 4
    }
    
    public function createBuffer(data:Float32Array, usage:Int, isStatic:Bool):IGraphicsBuffer {
        trace("VulkanBackend: createBuffer()");
        // Implementation in Phase 4
        return null;
    }
    
    public function createIndexBuffer(indices:Int32Array):IGraphicsBuffer {
        return null;
    }
    
    public function createTexture(width:Int, height:Int, format:Int, generateMipMaps:Bool):IGraphicsTexture {
        return null;
    }
    
    public function createProgram(vertexSource:String, fragmentSource:String):IGraphicsProgram {
        return null;
    }
    
    public function clear(color:com.babylonhx.math.Color4, clearColor:Bool, clearDepth:Bool, clearStencil:Bool):Void {
    }
    
    public function beginFrame():Void {
    }
    
    public function endFrame():Void {
    }
    
    public function getCapabilities():IGraphicsCapabilities {
        return null;
    }
    
    public function dispose():Void {
    }
}

#if cpp
extern class VkInstance {}
extern class VkPhysicalDevice {}
extern class VkDevice {}
extern class VkQueue {}

@:unreflective
class VkInstanceCreateInfo {
    public var sType:Int;
    public var pNext:cpp.Pointer<Void>;
    public var flags:Int;
    public var pApplicationInfo:cpp.Pointer<Void>;
    public var enabledLayerCount:Int;
    public var ppEnabledLayerNames:cpp.Pointer<cpp.ConstCharStar>;
    public var enabledExtensionCount:Int;
    public var ppEnabledExtensionNames:cpp.Pointer<cpp.ConstCharStar>;
}
#end

#else
// Stub for non-cpp platforms
class VulkanBackend {
    public static function isSupported():Bool { return false; }
}
#end
```

---

## Implementation Checklist

### Phase 1: Graphics Abstraction

- [ ] Create `IGraphicsBackend` interface
- [ ] Create `IGraphicsBuffer`, `IGraphicsTexture`, `IGraphicsProgram` interfaces
- [ ] Implement `WebGLBackend` wrapper
- [ ] Implement `WebGLBufferImpl`, `WebGLTextureImpl`, `WebGLProgramImpl`
- [ ] Refactor `Engine.hx` to use backend interface
- [ ] Update `project.xml` build configuration
- [ ] Add unit tests
- [ ] Test backward compatibility
- [ ] Update documentation

### Phase 2: Shader Abstraction

- [ ] Create `IShaderCompiler` interface
- [ ] Implement `GLSLCompiler`
- [ ] Update `Effect.hx` to use compiler abstraction
- [ ] Add shader reflection utilities
- [ ] Create SPIRVCompiler skeleton
- [ ] Add shader caching system

### Phase 3-7

(See full implementation plan for details)

---

## Quick Testing

Test Phase 1 completion:

```haxe
function testGraphicsBackend():Void {
    var engine = new Engine(canvas);
    var backend = engine.getGraphicsBackend();
    
    Assert.isNotNull(backend);
    Assert.isTrue(backend.getCapabilities().maxTextureSize > 0);
    
    // Create and use resources
    var buffer = backend.createBuffer(vertexData, GL.ARRAY_BUFFER, false);
    var texture = backend.createTexture(512, 512, GL.RGBA, true);
    var program = backend.createProgram(vertexShader, fragmentShader);
    
    Assert.isNotNull(buffer);
    Assert.isNotNull(texture);
    Assert.isNotNull(program);
    
    backend.dispose();
}
```

---

## Resources for Implementation

### Tutorials & Documentation
- [Khronos Vulkan Tutorial](https://vulkan-tutorial.com)
- [Haxe Language Reference](https://haxe.org/ref)
- [Haxe C++ FFI Guide](https://haxe.org/use-cases/game-dev)

### Tools
- Vulkan SDK: https://vulkan.lunarg.com
- glslang: https://github.com/KhronosGroup/glslang
- RenderDoc: Vulkan debugging

### Helper Libraries
- [spirv-cross](https://github.com/KhronosGroup/SPIRV-Cross) - SPIRV reflection
- [Vulkan Memory Allocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator)

---

## Next Steps

1. **Start with Phase 1**: Implement graphics abstraction layer
2. **Validate WebGL backend**: Ensure all existing samples still work
3. **Proceed to Phase 2**: Shader compilation abstraction
4. **Plan Phase 4**: Begin Vulkan FFI bindings and basic initialization
5. **Iterate**: Test frequently, gather performance data

---

## Getting Help

For questions or issues:
1. Check the full implementation plan: `VULKAN_BACKEND_IMPLEMENTATION_PLAN.md`
2. Review architecture diagrams: `VULKAN_ARCHITECTURE_DIAGRAMS.md`
3. Consult Vulkan specs: https://www.khronos.org/vulkan/
4. Reference BabylonJS original implementation for feature parity
