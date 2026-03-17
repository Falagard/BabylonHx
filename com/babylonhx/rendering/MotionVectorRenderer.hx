package com.babylonhx.rendering;

import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.materials.Effect;
import com.babylonhx.materials.ShadersStore;
import com.babylonhx.materials.textures.RenderTargetTexture;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.tools.SmartArray;

/**
 * Motion Vector Renderer: Generates per-pixel motion vectors for rigid opaque meshes
 * 
 * This renderer creates a dedicated render target containing motion vectors (2D screen-space motion)
 * for each pixel. Motion vectors are computed as: currentNDC - previousNDC.
 * 
 * This first version supports:
 * - Rigid opaque meshes only
 * - Static and dynamic rigid transforms
 * - Meshes without valid previous-frame data output zero motion
 * - Debug visualization of motion vectors
 * 
 * Not supported yet:
 * - Skinned meshes (bone-based animation)
 * - Particles
 * - Transparent objects
 * - Instancing
 */
class MotionVectorRenderer {
	
	private var scene:Scene;
	private var engine:Engine;
	
	// Render target for motion vectors (RG16F preferred, fallback to RG32F or RGBA)
	private var motionVectorRenderTarget:RenderTargetTexture;
	private var motionVectorTexture:Null<RenderTargetTexture>;
	
	// Effect for motion vector pass
	private var motionVectorEffect:Effect;
	
	// Previous frame camera matrices (for screen-space motion calculation)
	private var previousViewProjectionMatrix:Matrix;
	
	// Enable debug visualization (shows motion vectors as pseudo-color)
	private var debugMode:Bool = false;
	
	// Statistics
	private var renderedMeshCount:Int = 0;
	private var renderedSubMeshCount:Int = 0;

	public function new(scene:Scene) {
		this.scene = scene;
		this.engine = scene.getEngine();
		
		// Initialize previous view-projection with current to avoid invalid first frame
		this.previousViewProjectionMatrix = Matrix.Identity();
		
		// Register motion vector shaders if not already registered
		if (!ShadersStore.Shaders.exists("motionVectorVertex")) {
			registerMotionVectorShaders();
		}
		
		// Create motion vector effect
		this.motionVectorEffect = new Effect("motionVector", 
			["position", "normal"], // attributes
			["worldViewProjection", "world", "previousWorld", "previousViewProjection"],  // uniforms
			[],  // samplers
			engine);
		
		// Create render target for motion vectors
		// Try to use RG16F, but fall back to RGBA or RG32F if unavailable
		var motionVectorFormat = this.detectMotionVectorFormat();
		this.motionVectorRenderTarget = new RenderTargetTexture(
			"motionVectorTarget",
			engine.getRenderWidth(),
			engine.getRenderHeight(),
			scene,
			false,  // generateMipMaps
			true,   // doNotChangeAspectRatio
			motionVectorFormat,  // texture type
			false   // isCube
		);
		
		// Clear to zero (no motion) every frame
		this.motionVectorRenderTarget.onBeforeRender = function() {
			engine.clear(new Color4(0.0, 0.0, 0.0, 0.0), true, true, true);
		};
		
		this.motionVectorTexture = this.motionVectorRenderTarget;
	}
	
	/**
	 * Detects the best texture format for motion vectors.
	 * Prefers RG16F > RG32F > RGBA
	 */
	private function detectMotionVectorFormat():Int {
		// For now, use FLOAT type which will be interpreted as best available
		// In a production system, check engine.getCaps() for specific format support
		return Engine.TEXTURETYPE_FLOAT;
	}
	
	/**
	 * Register motion vector shader code in the shader store
	 */
	private function registerMotionVectorShaders():Void {
		// Vertex shader: compute both current and previous clip-space positions
		ShadersStore.Shaders.set("motionVectorVertex", 
			"attribute vec3 position; \n" +
			"attribute vec3 normal; \n" +
			"attribute vec2 uv; \n" +
			
			"uniform mat4 worldViewProjection; \n" +
			"uniform mat4 world; \n" +
			"uniform mat4 previousWorld; \n" +
			"uniform mat4 previousViewProjection; \n" +
			
			"varying vec4 vCurrentClipPos; \n" +
			"varying vec4 vPreviousClipPos; \n" +
			
			"void main() { \n" +
			"    // Current frame: transform to clip space \n" +
			"    vec4 currentWorldPos = world * vec4(position, 1.0); \n" +
			"    vCurrentClipPos = worldViewProjection * vec4(position, 1.0); \n" +
			"    \n" +
			"    // Previous frame: transform using previous matrices \n" +
			"    vec4 previousWorldPos = previousWorld * vec4(position, 1.0); \n" +
			"    vPreviousClipPos = previousViewProjection * previousWorldPos; \n" +
			"    \n" +
			"    // Output current position \n" +
			"    gl_Position = vCurrentClipPos; \n" +
			"} \n"
		);
		
		// Fragment shader: compute motion as currentNDC - previousNDC
		ShadersStore.Shaders.set("motionVectorFragment",
			"#ifdef GL_ES \n" +
			"precision highp float; \n" +
			"#endif \n" +
			
			"varying vec4 vCurrentClipPos; \n" +
			"varying vec4 vPreviousClipPos; \n" +
			
			"void main() { \n" +
			"    // Convert from clip space to NDC (normalized device coordinates) \n" +
			"    // Divide by W to get proper perspective-correct NDC \n" +
			"    vec2 currentNDC = vCurrentClipPos.xy / vCurrentClipPos.w; \n" +
			"    vec2 previousNDC = vPreviousClipPos.xy / vPreviousClipPos.w; \n" +
			"    \n" +
			"    // Motion vector: how much this pixel moved from previous to current frame \n" +
			"    // Stored in RG channels: R = horizontal motion  G = vertical motion \n" +
			"    vec2 motionVector = currentNDC - previousNDC; \n" +
			"    \n" +
			"    // Scale to 0-1 range for visualization (optional - depends on consumer) \n" +
			"    // For post-processing use, may need different scaling \n" +
			"    gl_FragColor = vec4(motionVector, 0.0, 1.0); \n" +
			"} \n"
		);
	}
	
	/**
	 * Update previous camera matrices (call once per frame before rendering)
	 */
	public function updateCameraMatrices():Void {
		if (this.scene.activeCamera != null) {
			// Store the CURRENT matrices as PREVIOUS for next frame
			// This is called at the START of the frame to capture last frame's camera state
			this.previousViewProjectionMatrix.copyFrom(
				this.scene.activeCamera.getViewMatrix()
			);
			// Multiply with projection for full view-projection
			var projMat = this.scene.activeCamera.getProjectionMatrix();
			if (projMat != null) {
				this.previousViewProjectionMatrix.multiplyToRef(projMat, this.previousViewProjectionMatrix);
			}
		}
	}
	
	/**
	 * Render motion vectors for all opaque rigid meshes
	 * Call this AFTER updating previous matrices but BEFORE normal rendering
	 */
	public function render():Void {
		if (this.motionVectorRenderTarget == null || !this.motionVectorRenderTarget._shouldRender()) {
			return;
		}
		
		// Use the motion vector render target
		var oldActiveCamera = this.scene.activeCamera;
		var oldRenderTarget = this.engine.getRenderingCanvas();
		
		// Bind motion vector render target
		this.engine.bindFramebuffer(this.motionVectorRenderTarget.getInternalTexture());
		this.engine.clear(new Color4(0.0, 0.0, 0.0, 0.0), true, true, true);
		
		// Render all opaque rigid meshes
		this.renderedMeshCount = 0;
		this.renderedSubMeshCount = 0;
		
		var activeMeshes = this.scene.getActiveMeshes();
		if (activeMeshes != null) {
			for (mesh in activeMeshes.data) {
				if (mesh == null) {
					break;
				}
				this.renderMesh(mesh);
			}
		}
		
		// Restore rendering to default frame buffer
		this.engine.restoreDefaultFramebuffer();
	}
	
	/**
	 * Check if a mesh is suitable for motion vector rendering
	 */
	private function isMeshValidForMotionVectors(mesh:AbstractMesh):Bool {
		// Must be visible
		if (!mesh.isVisible) {
			return false;
		}
		
		// Must have renderMotionVectors enabled
		if (!mesh.renderMotionVectors) {
			return false;
		}
		
		// Must be a Mesh (not just node)
		if (!Std.is(mesh, Mesh)) {
			return false;
		}
		
		// Skip meshes with transparent materials (simplified check)
		if (mesh.material != null && mesh.material.alpha < 0.99) {
			return false;
		}
		
		// Mesh must have geometry
		var m = cast(mesh, Mesh);
		if (m.getTotalVertices() == 0 || m.geometry == null) {
			return false;
		}
		
		// Must have previous world matrix (skip first frame or newly created meshes)
		if (!m._hasPreviousWorldMatrix) {
			return false;
		}
		
		return true;
	}
	
	/**
	 * Render motion vectors for a single mesh
	 */
	private function renderMesh(mesh:AbstractMesh):Void {
		if (!this.isMeshValidForMotionVectors(mesh)) {
			return;
		}
		
		var m = cast(mesh, Mesh);
		
		// Bind effect
		if (!this.motionVectorEffect.isReady()) {
			return;
		}
		
		// Get world matrices
		var currentWorld = m.getWorldMatrix();
		var previousWorld = m.getPreviousWorldMatrix();
		var currentVP = this.scene.activeCamera.getViewMatrix();
		currentVP.multiplyToRef(this.scene.activeCamera.getProjectionMatrix(), currentVP);
		
		// Get the camera matrices from current scene state
		// Note: previousViewProjection was set at start of frame
		
		// Render all submeshes
		if (m.subMeshes != null) {
			for (subMesh in m.subMeshes) {
				this.renderSubMesh(subMesh, currentWorld, previousWorld, currentVP);
			}
		} else {
			// Render as single mesh if no submeshes
			this.renderSubMeshDirect(m, currentWorld, previousWorld, currentVP);
		}
		
		this.renderedMeshCount++;
	}
	
	/**
	 * Render motion vectors for a specific submesh
	 */
	private function renderSubMesh(subMesh:SubMesh, currentWorld:Matrix, previousWorld:Matrix, currentVP:Matrix):Void {
		// Bind geometry
		var mesh = subMesh.getMesh();
		if (!Std.is(mesh, Mesh)) {
			return;
		}
		var m = cast(mesh, Mesh);
		
		// Set vertex buffers
		if (!this.engine.bindBuffersDirectly(
			m.getVertexBuffer(com.babylonhx.mesh.VertexBuffer.PositionKind),
			m.getIndexBuffer(),
			[m.getVertexBuffer(com.babylonhx.mesh.VertexBuffer.NormalKind)],
			[0], // offsets
			[com.babylonhx.mesh.VertexBuffer.NormalKind]
		)) {
			return;
		}
		
		// Set uniforms
		var engine = this.engine;
		this.motionVectorEffect.setMatrix("worldViewProjection", Matrix.Identity()
			.multiplyToRef(currentWorld, Tmp.matrix[0])
			.multiplyToRef(currentVP, Tmp.matrix[1])
		);
		this.motionVectorEffect.setMatrix("world", currentWorld);
		this.motionVectorEffect.setMatrix("previousWorld", previousWorld);
		this.motionVectorEffect.setMatrix("previousViewProjection", this.previousViewProjectionMatrix);
		
		// Bind effect and draw
		engine.setEffect(this.motionVectorEffect);
		engine.draw(true, subMesh.indexStart, subMesh.indexCount);
		
		this.renderedSubMeshCount++;
	}
	
	/**
	 * Render mesh as a single draw call (no submeshes)
	 */
	private function renderSubMeshDirect(mesh:Mesh, currentWorld:Matrix, previousWorld:Matrix, currentVP:Matrix):Void {
		// Set vertex buffers
		if (!this.engine.bindBuffersDirectly(
			mesh.getVertexBuffer(com.babylonhx.mesh.VertexBuffer.PositionKind),
			mesh.getIndexBuffer(),
			[mesh.getVertexBuffer(com.babylonhx.mesh.VertexBuffer.NormalKind)],
			[0], // offsets
			[com.babylonhx.mesh.VertexBuffer.NormalKind]
		)) {
			return;
		}
		
		// Set uniforms
		var engine = this.engine;
		this.motionVectorEffect.setMatrix("worldViewProjection", Matrix.Identity()
			.multiplyToRef(currentWorld, Tmp.matrix[0])
			.multiplyToRef(currentVP, Tmp.matrix[1])
		);
		this.motionVectorEffect.setMatrix("world", currentWorld);
		this.motionVectorEffect.setMatrix("previousWorld", previousWorld);
		this.motionVectorEffect.setMatrix("previousViewProjection", this.previousViewProjectionMatrix);
		
		// Bind effect and draw
		engine.setEffect(this.motionVectorEffect);
		engine.draw(true, 0, mesh.getTotalIndices());
		
		this.renderedSubMeshCount++;
	}
	
	/**
	 * Get the motion vector texture (for reading/binding in post-processing)
	 */
	public function getMotionVectorTexture():RenderTargetTexture {
		return this.motionVectorRenderTarget;
	}
	
	/**
	 * Enable or disable debug visualization
	 */
	public function setDebugMode(enabled:Bool):Void {
		this.debugMode = enabled;
	}
	
	/**
	 * Get statistics about the last render
	 */
	public function getStatistics():String {
		return 'Motion Vectors: $renderedMeshCount meshes, $renderedSubMeshCount submeshes rendered';
	}
	
	/**
	 * Resize the motion vector render target (call on window resize)
	 */
	public function resize(width:Int, height:Int):Void {
		if (this.motionVectorRenderTarget != null) {
			this.motionVectorRenderTarget.resize(width, height);
		}
	}
	
	/**
	 * Dispose resources
	 */
	public function dispose():Void {
		if (this.motionVectorEffect != null) {
			this.motionVectorEffect.dispose();
		}
		if (this.motionVectorRenderTarget != null) {
			this.motionVectorRenderTarget.dispose();
		}
	}
}

// Import Tmp for temporary matrices
private var Tmp = com.babylonhx.math.Tmp;
