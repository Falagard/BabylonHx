package com.babylonhx.rendering;

import com.babylonhx.tools.Observable;
import com.babylonhx.states._AlphaState;
import com.babylonhx.events.PointerInfoPre;
import com.babylonhx.events.PointerInfo;
import com.babylonhx.mesh.AbstractMesh;
import com.babylonhx.collisions.PickingInfo;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.cameras.Camera;
import com.babylonhx.materials.Effect;
import com.babylonhx.mesh.SubMesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh._InstancesBatch;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Tools as MathTools;

/**
 * ...
 * @author Clay Larabie
 * ported from babylonjs (https://github.com/BabylonJS/Babylon.js/blob/338d5ec3bef6101027caca160c5e6a439b10e150/packages/dev/core/src/Rendering/utilityLayerRenderer.ts#L20)
 */

@:expose('BABYLON.OutlineRenderer') class UtilityLayerRenderer {

    private var _pointerCaptures:Map<Int, Bool> = new Map();
    private var _lastPointerEvents:Map<Null<Int>, Bool> = new Map();
    //private var _pointerCaptures: { [pointerId: number]: boolean } = {};
    //private var _lastPointerEvents: { [pointerId: number]: boolean } = {};
    
    public static var _DefaultUtilityLayer:UtilityLayerRenderer = null;
    public static var _DefaultKeepDepthUtilityLayer:UtilityLayerRenderer = null;

    /**
     * The scene that is rendered on top of the original scene
     */
     public var utilityLayerScene: Scene;

     /**
      *  If the utility layer should automatically be rendered on top of existing scene
      */
     public var shouldRender:Bool = true;
     /**
      * If set to true, only pointer down onPointerObservable events will be blocked when picking is occluded by original scene
      */
     public var onlyCheckPointerDownEvents:Bool = true;
 
     /**
      * If set to false, only pointerUp, pointerDown and pointerMove will be sent to the utilityLayerScene (false by default)
      */
     public var processAllEvents:Bool = false;
 
     /**
      * Set to false to disable picking
      */
     public var pickingEnabled:Bool = true;

     public var pickUtilitySceneFirst:Bool = true;
 
     /**
      * Observable raised when the pointer moves from the utility layer scene to the main scene
      */
     //public onPointerOutObservable = new Observable<number>();
     public var onPointerOutObservable:Observable<Float> = new Observable<Float>();

     /** Gets or sets a predicate that will be used to indicate utility meshes present in the main scene */
     public var mainSceneTrackerPredicate: (mesh: AbstractMesh) -> Bool; 
     private var _afterRenderObserver: Dynamic; //Observer<Camera>;
     private var _sceneDisposeObserver: Dynamic; //Observer<Scene>;
     private var _originalPointerObserver: Dynamic; //Nullable<Observer<PointerInfoPre>>;

    /** @internal */
    private var _sharedGizmoLight:HemisphericLight = null;
    private var _renderCamera:Camera = null;

    public var originalScene: Scene;

    public var meshesSelectionPredicate:AbstractMesh->Bool;
    
    public function getRenderCamera(getRigParentIfPossible:Bool = false): Camera {
        
         if (this._renderCamera != null) {
             return this._renderCamera;
        } else {
            var activeCam: Camera;
            if (this.originalScene.activeCameras != null && this.originalScene.activeCameras.length > 1) {
                 activeCam = this.originalScene.activeCameras[this.originalScene.activeCameras.length - 1];
            } else {
                 var originalSceneActiveCamera = this.originalScene.activeCamera;
                 activeCam = cast(originalSceneActiveCamera, Camera);
            }

            //CL - I haven't investigated yet but isRigCamera and rigParent don't exist in current version of babylonhx so they're probably new features
            //  if (getRigParentIfPossible && activeCam != null && activeCam.isRigCamera) {
            //      return activeCam.rigParent!;
            //  }

            return activeCam;
        }

    }

    /**
     * Instantiates a UtilityLayerRenderer
     * @param originalScene the original scene that will be rendered on top of
     * @param handleEvents boolean indicating if the utility layer should handle events
     */
     public function new(originalScene: Scene, handleEvents: Bool = true) {

        this.meshesSelectionPredicate = function(m:AbstractMesh):Bool {
			return originalScene.activeCamera != null && m.material != null && m.isVisible && m.isEnabled() && m.isBlocker && ((m.layerMask & originalScene.activeCamera.layerMask) != 0);
		}

        // Create scene which will be rendered in the foreground and remove it from being referenced by engine to avoid interfering with existing app
        this.utilityLayerScene = new Scene(originalScene.getEngine(), { virtual: true });
        this.utilityLayerScene.useRightHandedSystem = originalScene.useRightHandedSystem;
        
        this.utilityLayerScene._allowPostProcessClearColor = false;

        // Deactivate post processes
        this.utilityLayerScene.postProcessesEnabled = false;

        // Detach controls on utility scene, events will be fired by logic below to handle picking priority
        this.utilityLayerScene.detachControl();
       
        if (handleEvents) {
            this._originalPointerObserver = originalScene.onPrePointerObservable.add(function(prePointerInfo, _) {
            
                if (this.utilityLayerScene.activeCamera == null) {
                    return;
                }
                if (!this.pickingEnabled) {
                    return;
                }

                if (!this.processAllEvents) {
                    if (
                        prePointerInfo.type != PointerEventTypes.POINTERMOVE &&
                        prePointerInfo.type != PointerEventTypes.POINTERUP &&
                        prePointerInfo.type != PointerEventTypes.POINTERDOWN &&
                        prePointerInfo.type != PointerEventTypes.POINTERDOUBLETAP
                    ) {
                        return;
                    }
                }
                
                this.utilityLayerScene.pointerX = originalScene.pointerX;
                this.utilityLayerScene.pointerY = originalScene.pointerY;

                var pointerEvent = cast(prePointerInfo.event, PointerEvent);
                //hard code this to pointerId 1 for now
                pointerEvent.pointerId = 1;
                
                if (originalScene != null && originalScene.isPointerCaptured(pointerEvent.pointerId)) {
                     this._pointerCaptures[pointerEvent.pointerId] = false;
                     return;
                }

                var getNearPickDataForScene = function (scene: Scene) {
                    var scenePick:PickingInfo = null;

                    if (prePointerInfo.nearInteractionPickingInfo != null) {
                        if (prePointerInfo.nearInteractionPickingInfo.pickedMesh != null && prePointerInfo.nearInteractionPickingInfo.pickedMesh.getScene() == scene) {
                            scenePick = prePointerInfo.nearInteractionPickingInfo;
                        } else {
                            scenePick = new PickingInfo();
                        }
                    } else if (scene != this.utilityLayerScene && prePointerInfo.originalPickingInfo != null) {
                        scenePick = prePointerInfo.originalPickingInfo;
                    } else {
                        var previousActiveCamera: Camera = null;
                        // If a camera is set for rendering with this layer
                        // it will also be used for the ray computation
                        // To preserve back compat and because scene.pick always use activeCamera
                        // it's substituted temporarily and a new scenePick is forced.
                        // otherwise, the ray with previously active camera is always used.
                        // It's set back to previous activeCamera after operation.
                        if (this._renderCamera != null) {
                            previousActiveCamera = scene.activeCamera;
                            scene.activeCamera = this._renderCamera;
                            prePointerInfo.ray = null;
                        }
                        scenePick = prePointerInfo.ray != null ? scene.pickWithRay(prePointerInfo.ray, null) : scene.pick(originalScene.pointerX, originalScene.pointerY);
                        if (previousActiveCamera != null) {
                            scene.activeCamera = previousActiveCamera;
                        }
                    }

                    return scenePick;
                };

                var utilityScenePick = getNearPickDataForScene(this.utilityLayerScene);

                if (prePointerInfo.ray != null && utilityScenePick != null) {
                    prePointerInfo.ray = utilityScenePick.ray;
                }

                // // always fire the prepointer observable
                this.utilityLayerScene.onPrePointerObservable.notifyObservers(prePointerInfo);

                // allow every non pointer down event to flow to the utility layer
                if (this.onlyCheckPointerDownEvents && prePointerInfo.type != PointerEventTypes.POINTERDOWN) {
                     if (!prePointerInfo.skipOnPointerObservable) {
                         this.utilityLayerScene.onPointerObservable.notifyObservers(
                             new PointerInfo(prePointerInfo.type, prePointerInfo.event, utilityScenePick),
                             prePointerInfo.type
                         );
                     }
                     if (prePointerInfo.type == PointerEventTypes.POINTERUP && this._pointerCaptures[pointerEvent.pointerId]) {
                         this._pointerCaptures[pointerEvent.pointerId] = false;
                     }
                     return;
                }

                if (this.utilityLayerScene.autoClearDepthAndStencil || this.pickUtilitySceneFirst) {
                     // If this layer is an overlay, check if this layer was hit and if so, skip pointer events for the main scene
                     if (utilityScenePick != null && utilityScenePick.hit) {
                         if (!prePointerInfo.skipOnPointerObservable) {
                             this.utilityLayerScene.onPointerObservable.notifyObservers(
                                 new PointerInfo(prePointerInfo.type, prePointerInfo.event, utilityScenePick),
                                 prePointerInfo.type
                             );
                         }
                         prePointerInfo.skipOnPointerObservable = true;
                     }
                } else {
                     var originalScenePick = getNearPickDataForScene(originalScene);
                     var pointerEvent = prePointerInfo.event;

                     // If the layer can be occluded by the original scene, only fire pointer events to the first layer that hit they ray
                     if (originalScenePick != null && utilityScenePick != null) {
                         // No pick in utility scene
                         if (utilityScenePick.distance == 0 && originalScenePick.pickedMesh != null) {
                             if (this.mainSceneTrackerPredicate != null && this.mainSceneTrackerPredicate(originalScenePick.pickedMesh)) {
                                 // We touched an utility mesh present in the main scene
                                 this._notifyObservers(prePointerInfo, originalScenePick, pointerEvent);
                                 prePointerInfo.skipOnPointerObservable = true;
                             } else if (prePointerInfo.type == PointerEventTypes.POINTERDOWN) {
                                 this._pointerCaptures[pointerEvent.pointerId] = true;
                             } else if (prePointerInfo.type == PointerEventTypes.POINTERMOVE || prePointerInfo.type == PointerEventTypes.POINTERUP) {
                                 if (this._lastPointerEvents[pointerEvent.pointerId]) {
                                     // We need to send a last pointerup to the utilityLayerScene to make sure animations can complete
                                     this.onPointerOutObservable.notifyObservers(pointerEvent.pointerId);
                                     //CL
                                     //delete this._lastPointerEvents[pointerEvent.pointerId];
                                     this._lastPointerEvents.remove(pointerEvent.pointerId);
                                 }
                                 this._notifyObservers(prePointerInfo, originalScenePick, pointerEvent);
                             }
                         } else if (!this._pointerCaptures[pointerEvent.pointerId] && (utilityScenePick.distance < originalScenePick.distance || originalScenePick.distance == 0)) {
                             // We pick something in utility scene or the pick in utility is closer than the one in main scene
                             this._notifyObservers(prePointerInfo, utilityScenePick, pointerEvent);
                             // If a previous utility layer set this, do not unset this
                             if (!prePointerInfo.skipOnPointerObservable) {
                                 prePointerInfo.skipOnPointerObservable = utilityScenePick.distance > 0;
                             }
                         } else if (!this._pointerCaptures[pointerEvent.pointerId] && utilityScenePick.distance >= originalScenePick.distance) {
                             // We have a pick in both scenes but main is closer than utility
                             // We touched an utility mesh present in the main scene
                            if (this.mainSceneTrackerPredicate != null && this.mainSceneTrackerPredicate(originalScenePick.pickedMesh)) {
                                 this._notifyObservers(prePointerInfo, originalScenePick, pointerEvent);
                                 prePointerInfo.skipOnPointerObservable = true;
                             } else {
                                 if (prePointerInfo.type == PointerEventTypes.POINTERMOVE || prePointerInfo.type == PointerEventTypes.POINTERUP) {
                                     if (this._lastPointerEvents[pointerEvent.pointerId]) {
                                         // We need to send a last pointerup to the utilityLayerScene to make sure animations can complete
                                         this.onPointerOutObservable.notifyObservers(pointerEvent.pointerId);
                                         //CL
                                         //delete this._lastPointerEvents[pointerEvent.pointerId];
                                         this._lastPointerEvents.remove(pointerEvent.pointerId);
                                     }
                                 }
                                 this._notifyObservers(prePointerInfo, utilityScenePick, pointerEvent);
                             }
                         }

                         if (prePointerInfo.type == PointerEventTypes.POINTERUP && this._pointerCaptures[pointerEvent.pointerId]) {
                             this._pointerCaptures[pointerEvent.pointerId] = false;
                         }
                     }
                 }
            });

            // As a newly added utility layer will be rendered over the screen last, it's pointer events should be processed first
            if (this._originalPointerObserver != null) {
                originalScene.onPrePointerObservable.makeObserverTopPriority(this._originalPointerObserver);
            }
        }

        // Render directly on top of existing scene without clearing
        this.utilityLayerScene.autoClear = false;

        //CL - need to investigate onAfterRenderCameraObservable instead of onAfterCameraRenderObservable (one has something to do with camera sub rigs)
        //this._afterRenderObserver = this.originalScene.onAfterRenderCameraObservable.add(function(camera) {
        this._afterRenderObserver = this.originalScene.onAfterCameraRenderObservable.add(function(camera, _) {
            // Only render when the render camera finishes rendering
            if (this.shouldRender && camera == this.getRenderCamera()) {
                this.render();
            }
        });

        this._sceneDisposeObserver = this.originalScene.onDisposeObservable.add(function(_, _) {
            this.dispose();
        });

        this._updateCamera();
    }

    private function _notifyObservers(prePointerInfo: PointerInfoPre, pickInfo: PickingInfo, pointerEvent: PointerEvent) {
        if (!prePointerInfo.skipOnPointerObservable) {
            this.utilityLayerScene.onPointerObservable.notifyObservers(new PointerInfo(prePointerInfo.type, prePointerInfo.event, pickInfo), prePointerInfo.type);
            this._lastPointerEvents[pointerEvent.pointerId] = true;
        }
    }

    /**
     * Renders the utility layers scene on top of the original scene
     */
     public function render() {
        this._updateCamera();
        if (this.utilityLayerScene.activeCamera != null) {
            // Set the camera's scene to utility layers scene
            var oldScene = this.utilityLayerScene.activeCamera.getScene();
            var camera = this.utilityLayerScene.activeCamera;
            camera._scene = this.utilityLayerScene;
            if (camera.leftCamera != null) {
                camera.leftCamera._scene = this.utilityLayerScene;
            }
            if (camera.rightCamera != null) {
                camera.rightCamera._scene = this.utilityLayerScene;
            }

            this.utilityLayerScene.render();

            // Reset camera's scene back to original
            camera._scene = oldScene;
            if (camera.leftCamera != null) {
                camera.leftCamera._scene = oldScene;
            }
            if (camera.rightCamera != null) {
                camera.rightCamera._scene = oldScene;
            }
        }
    }

    /**
     * Disposes of the renderer
     */
     public function dispose() {
        this.onPointerOutObservable.clear();

        if (this._afterRenderObserver) {
            this.originalScene.onAfterCameraRenderObservable.remove(this._afterRenderObserver);
        }
        if (this._sceneDisposeObserver) {
            this.originalScene.onDisposeObservable.remove(this._sceneDisposeObserver);
        }
        if (this._originalPointerObserver) {
            this.originalScene.onPrePointerObservable.remove(this._originalPointerObserver);
        }
        this.utilityLayerScene.dispose();
    }

    private function _updateCamera() {
        this.utilityLayerScene.cameraToUseForPointers = this.getRenderCamera();
        this.utilityLayerScene.activeCamera = this.getRenderCamera();
    }
}