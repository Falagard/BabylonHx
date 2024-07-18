package com.babylonhx.gizmos;

import com.babylonhx.gizmos.Gizmo;
import com.babylonhx.gizmos.AxisDragGizmo;
import com.babylonhx.gizmos.PlaneDragGizmo;

/**
* ...
* @author Clay Larabie
*/

/**
 * Interface for position gizmo
 */
interface IPositionGizmo extends IGizmo {
    /** Internal gizmo used for interactions on the x axis */
    var xGizmo: IAxisDragGizmo;
    /** Internal gizmo used for interactions on the y axis */
    var yGizmo: IAxisDragGizmo;
    /** Internal gizmo used for interactions on the z axis */
    var zGizmo: IAxisDragGizmo;
    /** Internal gizmo used for interactions on the yz plane */
    var xPlaneGizmo: IPlaneDragGizmo;
    /** Internal gizmo used for interactions on the xz plane */
    var yPlaneGizmo: IPlaneDragGizmo;
    /** Internal gizmo used for interactions on the xy plane */
    var zPlaneGizmo: IPlaneDragGizmo;
    /** True when the mouse pointer is dragging a gizmo mesh */
    var isDragging: Bool;
    /** Fires an event when any of its sub gizmos are dragged */
    var  onDragStartObservable: Observable<Dynamic>;
    /** Fires an event when any of its sub gizmos are being dragged */
    var onDragObservable: Observable<Dynamic>;
    /** Fires an event when any of its sub gizmos are released from dragging */
    var onDragEndObservable: Observable<Dynamic>;
    /**
     * If the planar drag gizmo is enabled
     * setting this will enable/disable XY, XZ and YZ planes regardless of individual gizmo settings.
     */
    var planarGizmoEnabled: Bool;
    /** Drag distance in babylon units that the gizmo will snap to when dragged */
    var snapDistance: Float;
    /**
     * Builds Gizmo Axis Cache to enable features such as hover state preservation and graying out other axis during manipulation
     * @param mesh Axis gizmo mesh
     * @param cache Gizmo axis definition used for reactive gizmo UI
     */
    function addToAxisCache(mesh: Mesh, cache: GizmoAxisCache): Void;
    /**
     * Force release the drag action by code
     */
    function releaseDrag(): Void;
}

/**
 * Additional options for the position gizmo
 */
interface PositionGizmoOptions {
    /**
     * Additional transform applied to the gizmo.
     * @See Gizmo.additionalTransformNode for more detail
     */
    var additionalTransformNode: TransformNode;
}

/**
 * Gizmo that enables dragging a mesh along 3 axis
 */
 @:expose('BABYLON.PositionGizmo') class PositionGizmo extends Gizmo implements IPositionGizmo {
    /**
     * Internal gizmo used for interactions on the x axis
     */
    public var xGizmo: IAxisDragGizmo;
    /**
     * Internal gizmo used for interactions on the y axis
     */
    public var yGizmo: IAxisDragGizmo;
    /**
     * Internal gizmo used for interactions on the z axis
     */
    public var zGizmo: IAxisDragGizmo;
    /**
     * Internal gizmo used for interactions on the yz plane
     */
    public var xPlaneGizmo: IPlaneDragGizmo;
    /**
     * Internal gizmo used for interactions on the xz plane
     */
    public var yPlaneGizmo: IPlaneDragGizmo;
    /**
     * Internal gizmo used for interactions on the xy plane
     */
    public var zPlaneGizmo: IPlaneDragGizmo;

    /**
     * protected variables
     */
    private var _meshAttached: Nullable<AbstractMesh> = null;
    private var _nodeAttached: Nullable<Node> = null;
    private var _snapDistance: Float;
    //private var _observables: Observer<PointerInfo>[] = [];
    private var _observeables: Array<Observer<PointerInfo>> = [];

    /** Node Caching for quick lookup */
    private var _gizmoAxisCache: Map<Mesh, GizmoAxisCache> = new Map();

    /** Fires an event when any of it's sub gizmos are dragged */
    public var onDragStartObservable = new Observable();
    /** Fires an event when any of it's sub gizmos are being dragged */
    public var onDragObservable = new Observable();
    /** Fires an event when any of it's sub gizmos are released from dragging */
    public var onDragEndObservable = new Observable();

    /**
     * If set_to true, planar drag is enabled
     */
    private var _planarGizmoEnabled = false;
    //public override var attachedMesh(get, set): AbstractMesh;
    public function get_attachedMesh() {
        return this._meshAttached;
    }
    public function set_attachedMesh(mesh: AbstractMesh) {
        this._meshAttached = mesh;
        this._nodeAttached = mesh;
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            if (gizmo.isEnabled) {
                gizmo.attachedMesh = mesh;
            } else {
                gizmo.attachedMesh = null;
            }
        };
    }

    //public override var attachedNode(get, set): Node;
    public function get_attachedNode(): Node {
        return this._nodeAttached;
    }
    public function set_attachedNode(node: Node) {
        this._meshAttached = null;
        this._nodeAttached = node;
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            if (gizmo.isEnabled) {
                gizmo.attachedNode = node;
            } else {
                gizmo.attachedNode = null;
            }
        };
    }

    /**
     * True when the mouse pointer is hovering a gizmo mesh
     */
    //public override var isHovered(get, never): Bool;
    public function get_isHovered(): Bool {
        return this.xGizmo.isHovered || this.yGizmo.isHovered || this.zGizmo.isHovered || this.xPlaneGizmo.isHovered || this.yPlaneGizmo.isHovered || this.zPlaneGizmo.isHovered;
    }

    //public override var isDragging(get, never): Bool;
    public function get_isDragging() {
        return (
            this.xGizmo.dragBehavior.dragging ||
            this.yGizmo.dragBehavior.dragging ||
            this.zGizmo.dragBehavior.dragging ||
            this.xPlaneGizmo.dragBehavior.dragging ||
            this.yPlaneGizmo.dragBehavior.dragging ||
            this.zPlaneGizmo.dragBehavior.dragging
        );
    }

    //public override var additionalTransformNode(get,set): TransformNode;
    public function get_additionalTransformNode() {
        return this._additionalTransformNode;
    }

    public function set_additionalTransformNode(transformNode: TransformNode) {
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            gizmo.additionalTransformNode = transformNode;
        };
    }

    /**
     * Creates a PositionGizmo
     * @param gizmoLayer The utility layer the gizmo will be added to
     * @param thickness display gizmo axis thickness
     * @param gizmoManager
     * @param options More options
     */
    public function new(gizmoLayer: UtilityLayerRenderer = UtilityLayerRenderer.DefaultUtilityLayer, thickness: Float = 1, ?gizmoManager: GizmoManager, ?options: PositionGizmoOptions) {
        super(gizmoLayer);
        this.xGizmo = new AxisDragGizmo(new Vector3(1, 0, 0), Color3.Red().scale(0.5), gizmoLayer, this, thickness);
        this.yGizmo = new AxisDragGizmo(new Vector3(0, 1, 0), Color3.Green().scale(0.5), gizmoLayer, this, thickness);
        this.zGizmo = new AxisDragGizmo(new Vector3(0, 0, 1), Color3.Blue().scale(0.5), gizmoLayer, this, thickness);

        this.xPlaneGizmo = new PlaneDragGizmo(new Vector3(1, 0, 0), Color3.Red().scale(0.5), this.gizmoLayer, this);
        this.yPlaneGizmo = new PlaneDragGizmo(new Vector3(0, 1, 0), Color3.Green().scale(0.5), this.gizmoLayer, this);
        this.zPlaneGizmo = new PlaneDragGizmo(new Vector3(0, 0, 1), Color3.Blue().scale(0.5), this.gizmoLayer, this);

        this.additionalTransformNode = options?.additionalTransformNode;

        // Relay drag events
        [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo].forEach((gizmo) => {
            gizmo.dragBehavior.onDragStartObservable.add(function() {
                this.onDragStartObservable.notifyObservers({});
            });
            gizmo.dragBehavior.onDragObservable.add(function() {
                this.onDragObservable.notifyObservers({});
            });
            gizmo.dragBehavior.onDragEndObservable.add(function() {
                this.onDragEndObservable.notifyObservers({});
            });
        });

        this.attachedMesh = null;

        if (gizmoManager) {
            gizmoManager.addToAxisCache(this._gizmoAxisCache);
        } else {
            // Only subscribe to pointer event if gizmoManager isnt
            Gizmo.GizmoAxisPointerObserver(gizmoLayer, this._gizmoAxisCache);
        }
    }

    /**
     * If the planar drag gizmo is enabled
     * setting this will enable/disable XY, XZ and YZ planes regardless of individual gizmo settings.
     */
    public var planarGizmoEnabled(get,set): Bool;
    public function set_planarGizmoEnabled(value: Bool) {
        this._planarGizmoEnabled = value;
        for(gizmo in [this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            if (gizmo != null) {
                gizmo.isEnabled = value;
                if (value) {
                    if (gizmo.attachedMesh) {
                        gizmo.attachedMesh = this.attachedMesh;
                    } else {
                        gizmo.attachedNode = this.attachedNode;
                    }
                }
            }
        };
    }
    public function get_planarGizmoEnabled(): Bool {
        return this._planarGizmoEnabled;
    }

    /**
     * posture that the gizmo will be display
     * When set_null, default value will be used (Quaternion(0, 0, 0, 1))
     */
    //public override var customRotationQuaternion(get,set) : Quaternion;
    public function get_customRotationQuaternion(): Quaternion {
        return this._customRotationQuaternion;
    }

    public function set_customRotationQuaternion(customRotationQuaternion: Quaternion) {
        this._customRotationQuaternion = customRotationQuaternion;
        [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo].forEach((gizmo) => {
            if (gizmo) {
                gizmo.customRotationQuaternion = customRotationQuaternion;
            }
        });
    }

    /**
     * If set_the gizmo's rotation will be updated to match the attached mesh each frame (Default: true)
     * NOTE: This is only possible for meshes with uniform scaling, as otherwise it's not possible to decompose the rotation
     */
    //public override var updateGizmoRotationToMatchAttachedMesh(get,set): Bool;
    public function set_updateGizmoRotationToMatchAttachedMesh(value: Bool) {
        this._updateGizmoRotationToMatchAttachedMesh = value;
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            if (gizmo) {
                gizmo.updateGizmoRotationToMatchAttachedMesh = value;
            }
        };
    }
    public function get_updateGizmoRotationToMatchAttachedMesh(): Bool {
        return this._updateGizmoRotationToMatchAttachedMesh;
    }

    public function set_updateGizmoPositionToMatchAttachedMesh(value: Bool) {
        this._updateGizmoPositionToMatchAttachedMesh = value;
        [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo].forEach((gizmo) => {
            if (gizmo) {
                gizmo.updateGizmoPositionToMatchAttachedMesh = value;
            }
        });
    }
    public function get_updateGizmoPositionToMatchAttachedMesh() {
        return this._updateGizmoPositionToMatchAttachedMesh;
    }

    //public override var anchorPoint(get,set): GizmoAnchorPoint;
    public function set_anchorPoint(value: GizmoAnchorPoint) {
        this._anchorPoint = value;
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            gizmo.anchorPoint = value;
        };
    }
    public function get_anchorPoint() {
        return this._anchorPoint;
    }

    /**
     * set_the coordinate system to use. By default it's local.
     * But it's possible for a user to tweak so its local for translation and world for rotation.
     * In that case, setting the coordinate system will change `updateGizmoRotationToMatchAttachedMesh` and `updateGizmoPositionToMatchAttachedMesh`
     */
    //public override var coordinatesMode(default, set): GizmoCoordinatesMode;
    public function set_coordinatesMode(coordinatesMode: GizmoCoordinatesMode) {
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            gizmo.coordinatesMode = coordinatesMode;
        };
    }

    //public override var updateScale(get,set): Bool;
    public function set_updateScale(value: Bool) {
        if (this.xGizmo) {
            this.xGizmo.updateScale = value;
            this.yGizmo.updateScale = value;
            this.zGizmo.updateScale = value;
        }
    }
    public function get_updateScale() {
        return this.xGizmo.updateScale;
    }
    /**
     * Drag distance in babylon units that the gizmo will snap to when dragged (Default: 0)
     */
    public var snapDistance(get,set): Float;

    public function set_snapDistance(value: Float) {
        this._snapDistance = value;
        for(gizmo in [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo]) {
            if (gizmo) {
                gizmo.snapDistance = value;
            }
        };
    }
    public function get_snapDistance() {
        return this._snapDistance;
    }

    /**
     * Ratio for the scale of the gizmo (Default: 1)
     */
    //public override var scaleRatio(get,set): Float;
    public function set_scaleRatio(value: Float) {
        this._scaleRatio = value;
        [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo].forEach((gizmo) => {
            if (gizmo) {
                gizmo.scaleRatio = value;
            }
        });
    }
    public function get_scaleRatio() {
        return this._scaleRatio;
    }

    /**
     * Builds Gizmo Axis Cache to enable features such as hover state preservation and graying out other axis during manipulation
     * @param mesh Axis gizmo mesh
     * @param cache Gizmo axis definition used for reactive gizmo UI
     */
    public function addToAxisCache(mesh: Mesh, cache: GizmoAxisCache) {
        this._gizmoAxisCache.set(mesh, cache);
    }
    /**
     * Force release the drag action by code
     */
    public function releaseDrag() {
        this.xGizmo.dragBehavior.releaseDrag();
        this.yGizmo.dragBehavior.releaseDrag();
        this.zGizmo.dragBehavior.releaseDrag();
        this.xPlaneGizmo.dragBehavior.releaseDrag();
        this.yPlaneGizmo.dragBehavior.releaseDrag();
        this.zPlaneGizmo.dragBehavior.releaseDrag();
    }

    /**
     * Disposes of the gizmo
     */
    public override function dispose() {
        [this.xGizmo, this.yGizmo, this.zGizmo, this.xPlaneGizmo, this.yPlaneGizmo, this.zPlaneGizmo].forEach((gizmo) => {
            if (gizmo) {
                gizmo.dispose();
            }
        });
        this._observables.forEach((obs) => {
            this.gizmoLayer.utilityLayerScene.onPointerObservable.remove(obs);
        });
        this.onDragStartObservable.clear();
        this.onDragObservable.clear();
        this.onDragEndObservable.clear();
    }

    /**
     * CustomMeshes are not supported by this gizmo
     */
    public override function setCustomMesh() {
        Logger.Error(
            "Custom meshes are not supported on this gizmo, please set_the custom meshes on the gizmos contained within this one (gizmo.xGizmo, gizmo.yGizmo, gizmo.zGizmo,gizmo.xPlaneGizmo, gizmo.yPlaneGizmo, gizmo.zPlaneGizmo)"
        );
    }
}
