/**
 * Vulkan Backend Implementation Roadmap
 * 
 * This folder will contain the Vulkan graphics backend implementation.
 * It is organized for Phase 4-6 of the graphics abstraction refactoring.
 * 
 * Structure:
 * - VulkanBackend.hx - Main backend implementation
 * - VulkanBuffer.hx - IGraphicsBuffer implementation
 * - VulkanTexture.hx - IGraphicsTexture implementation
 * - VulkanProgram.hx - IGraphicsProgram implementation
 * - VulkanPipeline.hx - IRenderPipeline implementation
 * - VulkanCommandBuffer.hx - Command recording
 * - VulkanDescriptorSet.hx - Resource binding
 * - VulkanBindings.hx - FFI bindings to Vulkan SDK
 * - ShaderReflection.hx - SPIRV reflection for automatic descriptor sets
 * - SPIRVCompiler.hx - GLSL to SPIRV compilation
 * - platform/
 *   ├── VulkanWindows.hx - Windows surface creation
 *   ├── VulkanLinux.hx - Linux surface creation
 *   └── VulkanMacOS.hx - macOS/MoltenVK support
 * 
 * Implementation Timeline:
 * Phase 4 (4-6 weeks): Vulkan Core Backend
 *   - Instance & device creation
 *   - Swapchain management
 *   - Buffer & texture management
 *   - Pipeline creation
 *   - Command recording & submission
 * 
 * Phase 5 (2-3 weeks): Platform Integration
 *   - Platform-specific surface creation
 *   - Build system integration
 *   - Extension loading
 * 
 * Phase 6 (2-3 weeks): Material & Effect System
 *   - GLSL to SPIRV compilation
 *   - Shader reflection
 *   - Descriptor set auto-generation
 * 
 * Key Dependencies:
 * - Vulkan SDK
 * - glslang or shaderc (shader compilation)
 * - SPIRV-Cross (optional, for reflection)
 * - Haxe C++ FFI
 */
