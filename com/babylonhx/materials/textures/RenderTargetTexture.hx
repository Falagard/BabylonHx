package com.babylonhx.materials.textures;

import com.babylonhx.engine.Engine;
import com.babylonhx.cameras.Camera;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.tools.SmartArray;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Color4;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.tools.EventState;
import com.babylonhx.rendering.RenderingManager;
import com.babylonhx.postprocess.PostProcess;
import com.babylonhx.postprocess.PostProcessManager;

/**
 * ...
 * @author Krtolica Vujadin
 */

@:expose('BABYLON.RenderTargetTexture') class RenderTargetTexture extends Texture {
	
	public static inline var REFRESHRATE_RENDER_ONCE:Int = 0;
    public static inline var REFRESHRATE_RENDER_ONEVERYFRAME:Int = 1;
    public static inline var REFRESHRATE_RENDER_ONEVERYTWOFRAMES:Int = 2;
	
	/**
	* Use this predicate to dynamically define the list of mesh you want to render.
	* If set, the renderList property will be overwritten.
	*/
	public var renderListPredicate:AbstractMesh->Bool;

	/**
	* Use this list to define the list of mesh you want to render.
	*/	
	public var renderList:Array<AbstractMesh> = [];
	public var renderParticles:Bool = true;
	public var renderSprites:Bool = false;
	public var activeCamera:Camera;
	public var customRenderFunction:Dynamic;//SmartArray<SubMesh>->SmartArray<SubMesh>->SmartArray<SubMesh>->Void->Void->Void;
	public var useCameraPostProcesses:Bool = false;	
	public var ignoreCameraViewport:Bool = false;
	
	private var _postProcessManager:PostProcessManager;
    private var _postProcesses:Array<PostProcess>;
	
	private var _resizeObserver:Observer<Engine>;
	
	// Events
	
	/**
	* An event triggered when the texture is unbind.
	* @type {BABYLON.Observable}
	*/
	public var onBeforeBindObservable:Observable<RenderTargetTexture> = new Observable<RenderTargetTexture>();

	/**
	* An event triggered when the texture is unbind.
	* @type {BABYLON.Observable}
	*/
	public var onAfterUnbindObservable:Observable<RenderTargetTexture> = new Observable<RenderTargetTexture>();
	private var _onAfterUnbindObserver:Observer<RenderTargetTexture>;
	public var onAfterUnbind(never, set):RenderTargetTexture->Null<EventState>->Void;
	private  function set_onAfterUnbind(callback:RenderTargetTexture->Null<EventState>->Void) {
		if (this._onAfterUnbindObserver != null) {
			this.onAfterUnbindObservable.remove(this._onAfterUnbindObserver);
		}
		this._onAfterUnbindObserver = this.onAfterUnbindObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered before rendering the texture
	* @type {BABYLON.Observable}
	*/
	public var onBeforeRenderObservable:Observable<Int> = new Observable<Int>();
	private var _onBeforeRenderObserver:Observer<Int>;
	public var onBeforeRender(never, set):Int->Null<EventState>->Void;
	private function set_onBeforeRender(callback:Int->Null<EventState>->Void) {
		if (this._onBeforeRenderObserver != null) {
			this.onBeforeRenderObservable.remove(this._onBeforeRenderObserver);
		}
		this._onBeforeRenderObserver = this.onBeforeRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered after rendering the texture
	* @type {BABYLON.Observable}
	*/
	public var onAfterRenderObservable:Observable<Int> = new Observable<Int>();
	private var _onAfterRenderObserver:Observer<Int>;
	public var onAfterRender(never, set):Int->Null<EventState>->Void;
	private function set_onAfterRender(callback:Int->Null<EventState>->Void) {
		if (this._onAfterRenderObserver != null) {
			this.onAfterRenderObservable.remove(this._onAfterRenderObserver);
		}
		this._onAfterRenderObserver = this.onAfterRenderObservable.add(callback);
		
		return callback;
	}

	/**
	* An event triggered after the texture clear
	* @type {BABYLON.Observable}
	*/
	public var onClearObservable:Observable<Engine> = new Observable<Engine>();
	private var _onClearObserver:Observer<Engine>;
	public var onClear(never, set):Engine->Null<EventState>->Void;
	private function set_onClear(callback:Engine->Null<EventState>->Void) {
		if (this._onClearObserver != null) {
			this.onClearObservable.remove(this._onClearObserver);
		}
		this._onClearObserver = this.onClearObservable.add(callback);
		
		return callback;
	}
	
	public var refreshRate(get, set):Int;
	public var canRescale(get, never):Bool;

	public var clearColor:Color4 = null;
	private var _size:Dynamic = { width: 0, height: 0 };
	private var _initialSizeParameter:Dynamic;
	private var _sizeRatio:Float = 0;
	public var _generateMipMaps:Bool;
	private var _renderingManager:RenderingManager;
	public var _waitingRenderList:Array<String>;
	private var _doNotChangeAspectRatio:Bool;
	private var _currentRefreshId:Int = -1;
	private var _refreshRate:Int = 1;
	private var _textureMatrix:Matrix;
	private var _samples:Int = 1;
	private var _renderTargetOptions:RenderTargetCreationOptions;
	public var renderTargetOptions(get, never):RenderTargetCreationOptions;
	inline private function get_renderTargetOptions():RenderTargetCreationOptions {
		return this._renderTargetOptions;
	}

	private var _engine:Engine;
	
	private function _onRatioRescale() {
		if (this._sizeRatio != 0) {
			this.resize(this._initialSizeParameter);
		}
	}
	
	/**
     * Gets or sets the center of the bounding box associated with the texture (when in cube mode)
     * It must define where the camera used to render the texture is set
     */
    public var boundingBoxPosition:Vector3 = Vector3.Zero();

    private var _boundingBoxSize:Vector3;

    /**
     * Gets or sets the size of the bounding box associated with the texture (when in cube mode)
     * When defined, the cubemap will switch to local mode
     * @see https://community.arm.com/graphics/b/blog/posts/reflections-based-on-local-cubemaps-in-unity
     * @example https://www.babylonjs-playground.com/#RNASML
     */        
	public var boundingBoxSize(get, set):Vector3;
    function set_boundingBoxSize(value:Vector3):Vector3 {
        if (this._boundingBoxSize != null && this._boundingBoxSize.equals(value)) {
            return value;
        }
        this._boundingBoxSize = value;
        var scene = this.getScene();
        if (scene != null) {
            scene.markAllMaterialsAsDirty(Material.TextureDirtyFlag);
        }
		return value;
    }
    inline function get_boundingBoxSize():Vector3 {
        return this._boundingBoxSize;
    }	
	
	/**
	 * In case the RTT has been created with a depth texture, get the associated 
	 * depth texture.
	 * Otherwise, return null.
	 */
	public var depthStencilTexture:InternalTexture;
	

	/**
	 * Instantiate a render target texture. This is mainly to render of screen the scene to for instance apply post processse
	 * or used a shadow, depth texture...
	 * @param name The friendly name of the texture
	 * @param size The size of the RTT (number if square, or {with: number, height:number} or {ratio:} to define a ratio from the main scene)
	 * @param scene The scene the RTT belongs to. The latest created scene will be used if not precised.
	 * @param generateMipMaps True if mip maps need to be generated after render.
	 * @param doNotChangeAspectRatio True to not change the aspect ratio of the scene in the RTT
	 * @param type The type of the buffer in the RTT (int, half float, float...)
	 * @param isCube True if a cube texture needs to be created
	 * @param samplingMode The sampling mode to be usedwith the render target (Linear, Nearest...)
	 * @param generateDepthBuffer True to generate a depth buffer
	 * @param generateStencilBuffer True to generate a stencil buffer
	 * @param isMulti True if multiple textures need to be created (Draw Buffers)
	 */
	public function new(name:String, size:Dynamic, scene:Scene, ?generateMipMaps:Bool, doNotChangeAspectRatio:Bool = true, type:Int = Engine.TEXTURETYPE_UNSIGNED_INT, isCube:Bool = false, samplingMode:Int = Texture.TRILINEAR_SAMPLINGMODE, generateDepthBuffer:Bool = true, generateStencilBuffer:Bool = false, isMulti:Bool = false) {
		super(null, scene, !generateMipMaps);
		scene = this.getScene();
		
		if (scene == null) {
			return;
		}
		
		// BHX
		this.coordinatesMode = Texture.PROJECTION_MODE;
		
		this._engine = scene.getEngine();
		this.name = name;
		this.isRenderTarget = true;
		this._initialSizeParameter = size;
		
		this._processSizeParameter(size);
		
		this._resizeObserver = this.getScene().getEngine().onResizeObservable.add(function(_, _) {
			
		}); 
		
		this._generateMipMaps = generateMipMaps;
		this._doNotChangeAspectRatio = doNotChangeAspectRatio;
		
		// Rendering groups
		this._renderingManager = new RenderingManager(scene);
		this.isCube = isCube;
		
		if (isMulti) {
			return;
		}
		
		this._renderTargetOptions = new RenderTargetCreationOptions();
		this._renderTargetOptions.generateMipMaps = generateMipMaps;
		this._renderTargetOptions.type = type;
		this._renderTargetOptions.samplingMode = samplingMode;
		this._renderTargetOptions.generateDepthBuffer = generateDepthBuffer;
		this._renderTargetOptions.generateStencilBuffer = generateStencilBuffer;
		
		if (samplingMode == Texture.NEAREST_SAMPLINGMODE) {
            this.wrapU = Texture.CLAMP_ADDRESSMODE;
            this.wrapV = Texture.CLAMP_ADDRESSMODE;
        }
		
		if (isCube) {
			this._texture = this._engine.createRenderTargetCubeTexture(this._size, this._renderTargetOptions);
			this.coordinatesMode = Texture.INVCUBIC_MODE;
            this._textureMatrix = Matrix.Identity();
		}
		else {
			this._texture = this._engine.createRenderTargetTexture(this._size, this._renderTargetOptions);
		}
	}
	
	private function _processSizeParameter(size:Dynamic) {
		if (Std.isOfType(size, Int)) {
			this._size.width = size;
			this._size.height = size;
		}
		else if (size.width != null) {
			this._size.width = size.width;
			this._size.height = size.height;
		}
		else if (size.ratio != null) {
			this._sizeRatio = size.ratio;
			this._size.width = this._bestReflectionRenderTargetDimension(this._engine.getRenderWidth(), this._sizeRatio);
			this._size.height = this._bestReflectionRenderTargetDimension(this._engine.getRenderHeight(), this._sizeRatio);
		}
	}
	
	public var samples(get, set):Int;
	inline private function get_samples():Int {
		return this._samples;
	}
	private function set_samples(value:Int):Int {
		if (this._samples == value) {
			return value;
		}
		
		var scene = this.getScene();
		
		if (scene == null) {
			return value;
		}
		
		this._samples = this._engine.updateRenderTargetTextureSampleCount(this._texture, value);
		return value;
	}

	public function resetRefreshCounter() {
		this._currentRefreshId = -1;
	}

	private function get_refreshRate():Int {
		return this._refreshRate;
	}
	// Use 0 to render just once, 1 to render on every frame, 2 to render every two frames and so on...
	private function set_refreshRate(value:Int):Int {
		this._refreshRate = value;
		this.resetRefreshCounter();
		
		return value;
	}
	
	public function addPostProcess(postProcess:PostProcess) {
		if (this._postProcessManager == null) {
			var scene = this.getScene();
			
			if (scene == null) {
				return;
			}
			
			this._postProcessManager = new PostProcessManager(scene);
			this._postProcesses = new Array<PostProcess>();
		}
		
		this._postProcesses.push(postProcess);
		this._postProcesses[0].autoClear = false;
	}

	public function clearPostProcesses(dispose:Bool = false) {
		if (this._postProcesses == null) {
			return;
		}
		
		if (dispose) {
			for (postProcess in this._postProcesses) {
				postProcess.dispose();
				postProcess = null;
			}
		}
		
		this._postProcesses = [];
	}

	public function removePostProcess(postProcess:PostProcess) {
		if (this._postProcesses == null) {
			return;
		}
		
		var index = this._postProcesses.indexOf(postProcess);
		
		if (index == -1) {
			return;
		}
		
		this._postProcesses.splice(index, 1);
		
		if (this._postProcesses.length > 0) {
			this._postProcesses[0].autoClear = false;
		}
	}

	public function _shouldRender():Bool {
		if (this._currentRefreshId == -1) { // At least render once
			this._currentRefreshId = 1;
			return true;
		}
		
		if (this.refreshRate == this._currentRefreshId) {
			this._currentRefreshId = 1;
			return true;
		}
		
		this._currentRefreshId++;
		return false;
	}
	
	public function getRenderSize():Int {
		return getRenderWidth();
	}
	
	public function getRenderWidth():Int {
		if (Std.isOfType(this._size, Int)) {
			return this._size;
		}
		else {
			return this._size.width;
		}
	}

	public function getRenderHeight():Int {
		if (Std.isOfType(this._size, Int)) {
			return this._size;
		}
		else {
			return this._size.height;
		}
	}

	private function get_canRescale():Bool {
		return true;
	}

	override public function scale(ratio:Float) {
		var newSize = this.getRenderSize() * ratio;
		this.resize(newSize);
	}
	
	override public function getReflectionTextureMatrix():Matrix {
        if (this.isCube) {
            return this._textureMatrix;
        }
		
        return super.getReflectionTextureMatrix();
    }

	public function resize(size:Dynamic) {
		this.releaseInternalTexture();
		var scene = this.getScene();
		
		if (scene == null) {
			return;
		}
		
		this._processSizeParameter(size);
		
		if (this.isCube) {
			this._texture = this.getScene().getEngine().createRenderTargetCubeTexture(this.getRenderSize(), this._renderTargetOptions);
		} 
		else {
			this._texture = this.getScene().getEngine().createRenderTargetTexture(this._size, this._renderTargetOptions);
		}
	}

	public function render(useCameraPostProcess:Bool = false) {
		var scene = this.getScene();
		
		if (scene == null) {
			return;
		}
		
		var engine = scene.getEngine();
		
		if (this.useCameraPostProcesses) {
			useCameraPostProcess = this.useCameraPostProcesses;
		}
		
		if (this._waitingRenderList != null) {
			this.renderList = [];
			for (index in 0...this._waitingRenderList.length) {
				var id = this._waitingRenderList[index];
				var mesh = scene.getMeshByID(id);
				if (mesh != null) {
					this.renderList.push(mesh);
				}
			}
			
			this._waitingRenderList = null;
		}
		
		// Is predicate defined?
		if (this.renderListPredicate != null) {
			if (this.renderList != null) {
				this.renderList.splice(0, 1); // Clear previous renderList
			}
			else {
				this.renderList = [];
			}
			
			var scene = this.getScene();
            
			if (scene == null) {
				return;
			}
			
			var sceneMeshes = scene.meshes;
			
			for (index in 0...sceneMeshes.length) {
				var mesh = sceneMeshes[index];
				if (this.renderListPredicate(mesh)) {
					this.renderList.push(mesh);
				}
			}
		}
		
		this.onBeforeBindObservable.notifyObservers(this);
		
		// Set custom projection.
		// Needs to be before binding to prevent changing the aspect ratio.
		var camera:Camera = null;
		if (this.activeCamera != null) {
			camera = this.activeCamera;
			engine.setViewport(this.activeCamera.viewport, this.getRenderWidth(), this.getRenderHeight());
			
			if (this.activeCamera != scene.activeCamera) {
				scene.setTransformMatrix(this.activeCamera.getViewMatrix(), this.activeCamera.getProjectionMatrix(true));
			}
		}
		else {
			camera = scene.activeCamera;
			if (camera != null) {
				engine.setViewport(scene.activeCamera.viewport, this.getRenderWidth(), this.getRenderHeight());
			}
		}
		
		// Prepare renderingManager
		this._renderingManager.reset();
		
		var currentRenderList = this.renderList != null ? this.renderList : scene.getActiveMeshes().data;
		var currentRenderListLength = this.renderList != null ? this.renderList.length : scene.getActiveMeshes().length;
		var sceneRenderId = scene.getRenderId();
		for (meshIndex in 0...currentRenderListLength) {
			var mesh = currentRenderList[meshIndex];
			
			if (mesh != null) {
				if (!mesh.isReady()) {
					// Reset _currentRefreshId
					this.resetRefreshCounter();
					continue;
				}
				
				mesh._preActivateForIntermediateRendering(sceneRenderId);
				
				var isMasked:Bool = false;
				if (this.renderList == null && camera != null) {
					isMasked = ((mesh.layerMask & camera.layerMask) == 0);
				}
				else {
					isMasked = false;
				}
				
				if (mesh.isEnabled() && mesh.isVisible && mesh.subMeshes != null && !isMasked) {
					mesh._activate(sceneRenderId);
					
					for (subIndex in 0...mesh.subMeshes.length) {
						var subMesh = mesh.subMeshes[subIndex];
						scene._activeIndices.addCount(subMesh.indexCount, false);
						this._renderingManager.dispatch(subMesh, mesh);
					}
				}
			}
		}
		
		for (particleIndex in 0...scene.particleSystems.length) {
			var particleSystem = scene.particleSystems[particleIndex];
			
			var emitter:Dynamic = particleSystem.emitter;
			if (!particleSystem.isStarted() || emitter == null || emitter.position == null || !emitter.isEnabled(true)) {
				continue;
			}
			
			if (currentRenderList.indexOf(emitter) >= 0) {
				this._renderingManager.dispatchParticles(particleSystem);
			}
		}
		
		if (this.isCube) {
			for (face in 0...6) {
				this.renderToTarget(face, currentRenderList, currentRenderListLength, useCameraPostProcess);
				scene.incrementRenderId();
				scene.resetCachedMaterial();
			}
		} 
		else {
			this.renderToTarget(0, currentRenderList, currentRenderListLength, useCameraPostProcess);
		}
		
		this.onAfterUnbindObservable.notifyObservers(this);
		
		if (scene.activeCamera != null) {
			if (this.activeCamera != null && this.activeCamera != scene.activeCamera) {
				scene.setTransformMatrix(scene.activeCamera.getViewMatrix(), scene.activeCamera.getProjectionMatrix(true));
			}
			engine.setViewport(scene.activeCamera.viewport);
		}
		
		scene.resetCachedMaterial();
	}
	
	private function _bestReflectionRenderTargetDimension(renderDimension:Int, scale:Float):Int {
		var minimum = 128;
		var x = renderDimension * scale;
		var curved = MathTools.NearestPOT(Std.int(x + (minimum * minimum / (minimum + x))));
		
		// Ensure we don't exceed the render dimension (while staying POT)
		return Std.int(Math.min(MathTools.NearestPOT(renderDimension), curved));
	}
	
	public function unbindFrameBuffer(engine:Engine, faceIndex:Int) {
        if (this._texture == null) {
            return;
        }
        engine.unBindFramebuffer(this._texture, this.isCube, function() {
            this.onAfterRenderObservable.notifyObservers(faceIndex);
        });
    }

	private function renderToTarget(faceIndex:Int, currentRenderList:Array<AbstractMesh>, currentRenderListLength:Int, useCameraPostProcess:Bool, dumpForDebug:Bool = false) {
		var scene = this.getScene();
		
		if (scene == null) {
			return;
		}
		
		var engine = scene.getEngine();
		
		if (this._texture == null) {
			return;
		}
		
		// Bind
		if (this._postProcessManager != null) {
			this._postProcessManager._prepareFrame(this._texture, this._postProcesses);
		}
		else if (!useCameraPostProcess || !scene.postProcessManager._prepareFrame(this._texture)) {
			if (this._texture != null) {
				engine.bindFramebuffer(this._texture, this.isCube ? faceIndex : 0, null, null, this.ignoreCameraViewport, this.depthStencilTexture != null ? this.depthStencilTexture : null);
			}
		}
		
		this.onBeforeRenderObservable.notifyObservers(faceIndex);
		
		// Clear
		if (this.onClearObservable.hasObservers()) {
			this.onClearObservable.notifyObservers(engine);
		} 
		else {
			engine.clear(this.clearColor != null ? this.clearColor : scene.clearColor, true, true, true);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		// Render
		this._renderingManager.render(this.customRenderFunction, currentRenderList, this.renderParticles, this.renderSprites);
		
		if (this._postProcessManager != null) {
			this._postProcessManager._finalizeFrame(false, this._texture, faceIndex, this._postProcesses);
		}
		else if (useCameraPostProcess) {
			scene.postProcessManager._finalizeFrame(false, this._texture, faceIndex);
		}
		
		if (!this._doNotChangeAspectRatio) {
			scene.updateTransformMatrix(true);
		}
		
		// Dump ?
		/*if (dumpForDebug) {
			Tools.DumpFramebuffer(this._size, this._size, engine);
		}*/

		// Unbind
		if (!this.isCube || faceIndex == 5) {
			if (this.isCube) {
				if (faceIndex == 5) {
					engine.generateMipMapsForCubemap(this._texture);
				}
			}
			
			this.unbindFrameBuffer(engine, faceIndex);
		} 
		else {
			this.onAfterRenderObservable.notifyObservers(faceIndex);
		}
	}
	
	/**
	 * Overrides the default sort function applied in the renderging group to prepare the meshes.
	 * This allowed control for front to back rendering or reversly depending of the special needs.
	 * 
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param opaqueSortCompareFn The opaque queue comparison function use to sort.
	 * @param alphaTestSortCompareFn The alpha test queue comparison function use to sort.
	 * @param transparentSortCompareFn The transparent queue comparison function use to sort.
	 */
	public function setRenderingOrder(renderingGroupId:Int,
		opaqueSortCompareFn:SubMesh->SubMesh->Int = null,
		alphaTestSortCompareFn:SubMesh->SubMesh->Int = null,
		transparentSortCompareFn:SubMesh->SubMesh->Int = null) {
		
		this._renderingManager.setRenderingOrder(renderingGroupId,
			opaqueSortCompareFn,
			alphaTestSortCompareFn,
			transparentSortCompareFn);
	}

	/**
	 * Specifies whether or not the stencil and depth buffer are cleared between two rendering groups.
	 * 
	 * @param renderingGroupId The rendering group id corresponding to its index
	 * @param autoClearDepthStencil Automatically clears depth and stencil between groups if true.
	 */
	inline public function setRenderingAutoClearDepthStencil(renderingGroupId:Int, autoClearDepthStencil:Bool) {            
		this._renderingManager.setRenderingAutoClearDepthStencil(renderingGroupId, autoClearDepthStencil);
	}

	override public function clone():RenderTargetTexture {
		var textureSize = this.getSize();
		var newTexture = new RenderTargetTexture(
			this.name,
			textureSize.width,
			this.getScene(),
			this._renderTargetOptions.generateMipMaps,
			this._doNotChangeAspectRatio,
			this._renderTargetOptions.type,
			this.isCube,
			this._renderTargetOptions.samplingMode,
			this._renderTargetOptions.generateDepthBuffer,
			this._renderTargetOptions.generateStencilBuffer
		);
		
		// Base texture
		newTexture.hasAlpha = this.hasAlpha;
		newTexture.level = this.level;
		
		// RenderTarget Texture
		newTexture.coordinatesMode = this.coordinatesMode;
		newTexture.renderList = this.renderList.slice(0);
		
		return newTexture;
	}
	
	override public function serialize():Dynamic {
		if (this.name == null) {
			return null;
		}
		
		var serializationObject = super.serialize();
		
		serializationObject.renderTargetSize = this.getRenderSize();
		serializationObject.renderList = [];
		
		for (index in 0...this.renderList.length) {
			serializationObject.renderList.push(this.renderList[index].id);
		}
		
		return serializationObject;
	}
	
	// This will remove the attached framebuffer objects. The texture will not be able to be used as render target anymore
	public function disposeFramebufferObjects() {
		this.getScene().getEngine()._releaseFramebufferObjects(this.getInternalTexture());
	}
	
	override public function dispose() {
		if (this._postProcessManager != null) {
			this._postProcessManager.dispose();
			this._postProcessManager = null;
		}
		
		this.clearPostProcesses(true);
		
		this.renderList = null;
		
		// Remove from custom render targets
		var scene = this.getScene();
		var index = scene.customRenderTargets.indexOf(this);
		
		if (index >= 0) {
			scene.customRenderTargets.splice(index, 1);
		}
		
		for (camera in scene.cameras) {
			index = camera.customRenderTargets.indexOf(this);
			
			if (index >= 0) {
				camera.customRenderTargets.splice(index, 1);
			}
		}
		
		super.dispose();
	}
	
	override public function _rebuild() {
        if (this.refreshRate == RenderTargetTexture.REFRESHRATE_RENDER_ONCE) {
            this.refreshRate = RenderTargetTexture.REFRESHRATE_RENDER_ONCE;
        }
		
		if (this._postProcessManager != null) {
            this._postProcessManager._rebuild();
        }
    }
	
}
