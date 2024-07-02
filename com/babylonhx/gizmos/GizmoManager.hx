package com.babylonhx.gizmos;

import com.babylonhx.gizmos.Gizmo.GizmoAxisCache;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.rendering.UtilityLayerRenderer;
import com.babylonhx.tools.Observer;
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
import com.babylonhx.math.Color3;
import com.babylonhx.rendering.UtilityLayerRenderer;

/**
 * Helps setup gizmo's in the scene to rotate/scale/position nodes
 */
 @:expose('BABYLON.GizmoManager') class GizmoManager implements IDisposable {
	
    /**
     * Gizmos created by the gizmo manager, gizmo will be null until gizmo has been enabled for the first time
     */
     public var gizmos: {
         positionGizmo: IPositionGizmo,
         rotationGizmo: IRotationGizmo,
         scaleGizmo: IScaleGizmo,
         boundingBoxGizmo: IBoundingBoxGizmo
    };

    /** When true, the gizmo will be detached from the current object when a pointer down occurs with an empty picked mesh */
    public var clearGizmoOnEmptyPointerEvent = false;

    /** When true (default), picking to attach a new mesh is enabled. This works in sync with inspector autopicking. */
    public var enableAutoPicking = true;

    /** Fires an event when the manager is attached to a mesh */
    public var onAttachedToMeshObservable = new Observable<AbstractMesh>();

    /** Fires an event when the manager is attached to a node */
    public var onAttachedToNodeObservable = new Observable<Node>();

    private var _gizmosEnabled = { positionGizmo: false, rotationGizmo: false, scaleGizmo: false, boundingBoxGizmo: false };
    private var _pointerObservers: Array<Observer<PointerInfo>> = [];
    private var _attachedMesh: AbstractMesh = null;
    private var _attachedNode: Node = null;
    private var _boundingBoxColor = Color3.FromHexString("#0984e3");
    private var _defaultUtilityLayer: UtilityLayerRenderer;
    private var _defaultKeepDepthUtilityLayer: UtilityLayerRenderer;
    private var _thickness:Int = 1;
    private var _scaleRatio:Float = 1;
    //private var _coordinatesMode = GizmoCoordinatesMode.Local;
    private var _additionalTransformNode: TransformNode;
    private var _scene:Scene;

    /** Node Caching for quick lookup */
    private var _gizmoAxisCache: Map<Mesh, GizmoAxisCache> = new Map();
    /**
     * When bounding box gizmo is enabled, this can be used to track drag/end events
     */
    //public var boundingBoxDragBehavior = new SixDofDragBehavior();
    /**
     * Array of meshes which will have the gizmo attached when a pointer selected them. If null, all meshes are attachable. (Default: null)
     */
    public var attachableMeshes: Array<AbstractMesh> = null;
    /**
     * Array of nodes which will have the gizmo attached when a pointer selected them. If null, all nodes are attachable. (Default: null)
     */
    public var attachableNodes: Array<Node> = null;
    /**
     * If pointer events should perform attaching/detaching a gizmo, if false this can be done manually via attachToMesh/attachToNode. (Default: true)
     */
    public var usePointerToAttachGizmos = true;

    /**
     * Utility layer that the bounding box gizmo belongs to
     */
    public var keepDepthUtilityLayer(get, never):UtilityLayerRenderer;

    private function get_keepDepthUtilityLayer():UtilityLayerRenderer {
		return this._defaultKeepDepthUtilityLayer;
	}


    public var utilityLayer(get, never):UtilityLayerRenderer;

    /**
     * Utility layer that all gizmos besides bounding box belong to
     */
    public function get_utilityLayer() {
        return this._defaultUtilityLayer;
    }

    /**
     * True when the mouse pointer is hovering a gizmo mesh
     */
    public var isHovered(get, never):Bool;

    public function get_isHovered() : Bool {
        var hovered = false;
        // for (key in this.gizmos) {
        //     //CL todo
        //     var gizmo = cast(gizmos[key], IGizmo);
        //     if (gizmo && gizmo.isHovered) {
        //         hovered = true;
        //          break;
        //     }
        // }
        return hovered;
    }

    /**
     * True when the mouse pointer is dragging a gizmo mesh
     */
    public var isDragging(get, never):Bool;

    public function get_isDragging() {
        var dragging = false;

        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if (gizmo != null && gizmo.isDragging) {
                dragging = true;
            }
        }

        return dragging;
    }

    /**
     * Ratio for the scale of the gizmo (Default: 1)
     */
    public var scaleRatio(get, set):Float;

    public function set_scaleRatio(value: Float) {
        return this._scaleRatio = value;
        // for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
        //     if (gizmo != null) {
        //         gizmo.scaleRatio = value;
        //     }
        // }
    }
    public function get_scaleRatio():Float {
        return this._scaleRatio;
    }

    /**
     * Set the coordinate system to use. By default it's local.
     * But it's possible for a user to tweak so its local for translation and world for rotation.
     * In that case, setting the coordinate system will change `updateGizmoRotationToMatchAttachedMesh` and `updateGizmoPositionToMatchAttachedMesh`
     */
    // public var coordinatesMode(get, set):GizmoCoordinatesMode;

    // public function set_coordinatesMode(coordinatesMode: GizmoCoordinatesMode) {
    //     return this._coordinatesMode = coordinatesMode;
    //     // for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
    //     //     if (gizmo != null) {
    //     //         gizmo.coordinatesMode = coordinatesMode;
    //     //     }
    //     // }
    // }

    // public function get_coordinatesMode(): GizmoCoordinatesMode {
    //     return this._coordinatesMode;
    // }

    /**
     * The mesh the gizmo's is attached to
     */
    public var attachedMesh(get, never):AbstractMesh;

    public function get_attachedMesh() : AbstractMesh {
        return this._attachedMesh;
    }

    /**
     * The node the gizmo's is attached to
     */
    public var attachedNode(get, never):Node;
    
    public function get_attachedNode() {
        return this._attachedNode;
    }

    /**
     * Additional transform node that will be used to transform all the gizmos
     */
    public var additionalTransformNode(get, never):TransformNode;

    public function get_additionalTransformNode() {
        return this._additionalTransformNode;
    }

    /**
     * Instantiates a gizmo manager
     * @param _scene the scene to overlay the gizmos on top of
     * @param thickness display gizmo axis thickness
     * @param utilityLayer the layer where gizmos are rendered
     * @param keepDepthUtilityLayer the layer where occluded gizmos are rendered
     */
    public function new(scene: Scene, thickness: Int = 1, utilityLayer: UtilityLayerRenderer = null,
        keepDepthUtilityLayer: UtilityLayerRenderer = null
    ) {
        if(utilityLayer == null) {
            utilityLayer = UtilityLayerRenderer.DefaultUtilityLayer;
        }

        if(keepDepthUtilityLayer == null) {
            keepDepthUtilityLayer = UtilityLayerRenderer.DefaultKeepDepthUtilityLayer;
        }

        this._defaultUtilityLayer = utilityLayer;
        this._defaultKeepDepthUtilityLayer = keepDepthUtilityLayer;
        this._defaultKeepDepthUtilityLayer.utilityLayerScene.autoClearDepthAndStencil = false;
        this._thickness = thickness;
        this.gizmos = { positionGizmo: null, rotationGizmo: null, scaleGizmo: null, boundingBoxGizmo: null };

        var attachToMeshPointerObserver = this._attachToMeshPointerObserver(_scene);
        //CL todo
        //var gizmoAxisPointerObserver = Gizmo.GizmoAxisPointerObserver(this._defaultUtilityLayer, this._gizmoAxisCache);
        //this._pointerObservers = [attachToMeshPointerObserver, gizmoAxisPointerObserver];
        this._pointerObservers = [attachToMeshPointerObserver];
    }

    /**
     * @internal
     * Subscribes to pointer down events, for attaching and detaching mesh
     * @param scene The scene layer the observer will be added to
     * @returns the pointer observer
     */
    private function _attachToMeshPointerObserver(scene: Scene): Observer<PointerInfo> {
        // Instantiate/dispose gizmos based on pointer actions
        var pointerObserver = scene.onPointerObservable.add(function(pointerInfo, _) {
            if (!this.usePointerToAttachGizmos) {
                return;
            }
            if (pointerInfo.type == PointerEventTypes.POINTERDOWN) {
                if (pointerInfo.pickInfo != null && pointerInfo.pickInfo.pickedMesh != null) {
                    if (this.enableAutoPicking) {
                        var node: Node = pointerInfo.pickInfo.pickedMesh;
                        if (this.attachableMeshes == null) {
                            // Attach to the most parent node
                            while (node != null && node.parent != null) {
                                node = node.parent;
                            }
                        } else {
                            // Attach to the parent node that is an attachableMesh
                            var found = false;
                            for(mesh in this.attachableMeshes) {
                                if (node != null && (node == mesh || node.isDescendantOf(mesh))) {
                                    node = mesh;
                                    found = true;
                                }
                            }
                            if (!found) {
                                node = null;
                            }
                        }
                        if (Std.isOfType(node, AbstractMesh)) {
                            var abstractMesh = cast(node, AbstractMesh);
                            if (this._attachedMesh != node) {
                                this.attachToMesh(abstractMesh);
                            }
                        } else {
                            if (this.clearGizmoOnEmptyPointerEvent) {
                                this.attachToMesh(null);
                            }
                        }
                    }
                } else {
                    if (this.clearGizmoOnEmptyPointerEvent) {
                        this.attachToMesh(null);
                    }
                }
            }
        });

        return pointerObserver;
    }

    /**
     * Attaches a set of gizmos to the specified mesh
     * @param mesh The mesh the gizmo's should be attached to
     */
    public function attachToMesh(mesh: AbstractMesh) {
        // if (this._attachedMesh != null) {
        //     this._attachedMesh.removeBehavior(this.boundingBoxDragBehavior);
        // }
        // if (this._attachedNode != null) {
        //     this._attachedNode.removeBehavior(this.boundingBoxDragBehavior);
        // }

        this._attachedMesh = mesh;
        this._attachedNode = null;

        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if(gizmo == null)
                continue;

            var gizmoEnabled = false;
            if(gizmo == this.gizmos.positionGizmo) {
                gizmoEnabled = _gizmosEnabled.positionGizmo;
            } else if(gizmo == this.gizmos.rotationGizmo) {
                gizmoEnabled = _gizmosEnabled.rotationGizmo;
            } else if(gizmo == this.gizmos.scaleGizmo) {
                gizmoEnabled = _gizmosEnabled.scaleGizmo;
            }

            if(gizmoEnabled) 
                gizmo.attachedMesh = mesh;
        }
        
        //CL todo 
        // if (this.boundingBoxGizmoEnabled && this._attachedMesh) {
        //     this._attachedMesh.addBehavior(this.boundingBoxDragBehavior);
        // }

        this.onAttachedToMeshObservable.notifyObservers(mesh);
    }

    /**
     * Attaches a set of gizmos to the specified node
     * @param node The node the gizmo's should be attached to
     */
    public function attachToNode(node: Node) {
        // if (this._attachedMesh) {
        //     this._attachedMesh.removeBehavior(this.boundingBoxDragBehavior);
        // }
        // if (this._attachedNode) {
        //     this._attachedNode.removeBehavior(this.boundingBoxDragBehavior);
        // }
        this._attachedMesh = null;
        this._attachedNode = node;
        
        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if(gizmo == null)
                continue;

            var gizmoEnabled = false;
            if(gizmo == this.gizmos.positionGizmo) {
                gizmoEnabled = _gizmosEnabled.positionGizmo;
            } else if(gizmo == this.gizmos.rotationGizmo) {
                gizmoEnabled = _gizmosEnabled.rotationGizmo;
            } else if(gizmo == this.gizmos.scaleGizmo) {
                gizmoEnabled = _gizmosEnabled.scaleGizmo;
            }

            if(gizmoEnabled) 
                gizmo.attachedNode = node;
        }

        // if (this.boundingBoxGizmoEnabled && this._attachedNode) {
        //     this._attachedNode.addBehavior(this.boundingBoxDragBehavior);
        // }
        this.onAttachedToNodeObservable.notifyObservers(node);
    }


    /**
     * If the position gizmo is enabled
     */
    public var positionGizmoEnabled(get, set):Bool;

    public function set_positionGizmoEnabled(value: Bool) {
        if (value) {
            if (!this.gizmos.positionGizmo) {
                this.gizmos.positionGizmo = new PositionGizmo(this._defaultUtilityLayer, this._thickness, this);
            }
            if (this._attachedNode != null) {
                this.gizmos.positionGizmo.attachedNode = this._attachedNode;
            } else {
                this.gizmos.positionGizmo.attachedMesh = this._attachedMesh;
            }
        } else if (this.gizmos.positionGizmo) {
            this.gizmos.positionGizmo.attachedNode = null;
        }
        this._gizmosEnabled.positionGizmo = value;
        this._setAdditionalTransformNode();
        return value;
    }
    public function get_positionGizmoEnabled(): Bool {
        return this._gizmosEnabled.positionGizmo;
    }

    /**
     * If the rotation gizmo is enabled
     */
    public var rotationGizmoEnabled(get, set):Bool;

    public function set_rotationGizmoEnabled(value: Bool) {
        if (value) {
            if (!this.gizmos.rotationGizmo) {
                this.gizmos.rotationGizmo = new RotationGizmo(this._defaultUtilityLayer, 32, false, this._thickness, this);
            }
            if (this._attachedNode != null) {
                this.gizmos.rotationGizmo.attachedNode = this._attachedNode;
            } else {
                this.gizmos.rotationGizmo.attachedMesh = this._attachedMesh;
            }
        } else if (this.gizmos.rotationGizmo) {
            this.gizmos.rotationGizmo.attachedNode = null;
        }
        this._gizmosEnabled.rotationGizmo = value;
        this._setAdditionalTransformNode();
        return value;
    }
    public function get_rotationGizmoEnabled(): Bool {
        return this._gizmosEnabled.rotationGizmo;
    }
    /**
     * If the scale gizmo is enabled
     */
    public var scaleGizmoEnabled(get, set):Bool;

    public function set_scaleGizmoEnabled(value: Bool) {
        if (value) {
            this.gizmos.scaleGizmo = this.gizmos.scaleGizmo || new ScaleGizmo(this._defaultUtilityLayer, this._thickness, this);
            if (this._attachedNode != null) {
                this.gizmos.scaleGizmo.attachedNode = this._attachedNode;
            } else {
                this.gizmos.scaleGizmo.attachedMesh = this._attachedMesh;
            }
        } else if (this.gizmos.scaleGizmo) {
            this.gizmos.scaleGizmo.attachedNode = null;
        }
        this._gizmosEnabled.scaleGizmo = value;
        this._setAdditionalTransformNode();
        return value;
    }
    public function get_scaleGizmoEnabled(): Bool {
        return this._gizmosEnabled.scaleGizmo;
    }
    /**
     * If the boundingBox gizmo is enabled
     */
    public var boundingBoxGizmoEnabled(get, set):Bool;

    public function set_boundingBoxGizmoEnabled(value: Bool) {
        if (value) {
            this.gizmos.boundingBoxGizmo = this.gizmos.boundingBoxGizmo || new BoundingBoxGizmo(this._boundingBoxColor, this._defaultKeepDepthUtilityLayer);
            if (this._attachedMesh != null) {
                this.gizmos.boundingBoxGizmo.attachedMesh = this._attachedMesh;
            } else {
                this.gizmos.boundingBoxGizmo.attachedNode = this._attachedNode;
            }

            // if (this._attachedMesh != null) {
            //     this._attachedMesh.removeBehavior(this.boundingBoxDragBehavior);
            //     this._attachedMesh.addBehavior(this.boundingBoxDragBehavior);
            // } else if (this._attachedNode != null) {
            //     this._attachedNode.removeBehavior(this.boundingBoxDragBehavior);
            //     this._attachedNode.addBehavior(this.boundingBoxDragBehavior);
            // }
        } else if (this.gizmos.boundingBoxGizmo != null) {
            // if (this._attachedMesh != null) {
            //     this._attachedMesh.removeBehavior(this.boundingBoxDragBehavior);
            // } else if (this._attachedNode != null) {
            //     this._attachedNode.removeBehavior(this.boundingBoxDragBehavior);
            // }
            this.gizmos.boundingBoxGizmo.attachedNode = null;
        }
        this._gizmosEnabled.boundingBoxGizmo = value;
        this._setAdditionalTransformNode();
        return value;
    }
    public function get_boundingBoxGizmoEnabled(): Bool {
        return this._gizmosEnabled.boundingBoxGizmo;
    }

    private function _setAdditionalTransformNode() {
        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if(gizmo == null)
                continue;

            var gizmoEnabled = false;
            if(gizmo == this.gizmos.positionGizmo) {
                gizmoEnabled = _gizmosEnabled.positionGizmo;
            } else if(gizmo == this.gizmos.rotationGizmo) {
                gizmoEnabled = _gizmosEnabled.rotationGizmo;
            } else if(gizmo == this.gizmos.scaleGizmo) {
                gizmoEnabled = _gizmosEnabled.scaleGizmo;
            }

            if(gizmoEnabled) 
                gizmo.additionalTransformNode = this._additionalTransformNode;
        }
    }

    /**
     * Builds Gizmo Axis Cache to enable features such as hover state preservation and graying out other axis during manipulation
     * @param gizmoAxisCache Gizmo axis definition used for reactive gizmo UI
     */
    public function addToAxisCache(gizmoAxisCache: Map<Mesh, GizmoAxisCache>) {
        for(key in gizmoAxisCache.keys()) {
            this._gizmoAxisCache.set(key, gizmoAxisCache.get(key));
        };
    }

    /**
     * Force release the drag action by code
     */
    public function releaseDrag() {
        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if(gizmo != null)   
                gizmo.releaseDrag();
        };
    }

    /**
     * Disposes of the gizmo manager
     */
    public function dispose(doNotRecurse:Bool = false) {
    //public function dispose() {
        for(observer in this._pointerObservers) {
            this._scene.onPointerObservable.remove(observer);
        };
        for(gizmo in [this.gizmos.positionGizmo, this.gizmos.rotationGizmo, this.gizmos.scaleGizmo, this.gizmos.boundingBoxGizmo]) {
            if(gizmo != null)   
                gizmo.dispose(doNotRecurse);
        };
        if (this._defaultKeepDepthUtilityLayer != UtilityLayerRenderer._DefaultKeepDepthUtilityLayer) {
            this._defaultKeepDepthUtilityLayer?.dispose();
        }
        if (this._defaultUtilityLayer != UtilityLayerRenderer._DefaultUtilityLayer) {
            this._defaultUtilityLayer?.dispose();
        }
        //CL todo
        //this.boundingBoxDragBehavior.detach();
        this.onAttachedToMeshObservable.clear();
    }
}