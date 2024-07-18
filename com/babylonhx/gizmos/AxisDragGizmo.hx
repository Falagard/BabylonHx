package com.babylonhx.gizmos;

import com.babylonhx.mesh.TransformNode;
import com.babylonhx.gizmos.Gizmo;
import com.babylonhx.behaviors.meshes.PointerDragBehavior;
import com.babylonhx.tools.Observable;
import com.babylonhx.tools.Observer;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.events.PointerInfo;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.rendering.UtilityLayerRenderer;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.AbstractMesh;

/**
 * Interface for axis drag gizmo
 */
interface IAxisDragGizmo extends IGizmo {
    /** Drag behavior responsible for the gizmos dragging interactions */
    var dragBehavior: PointerDragBehavior;
    /** Drag distance in babylon units that the gizmo will snap to when dragged */
    var snapDistance: Float;
    /**
     * Event that fires each time the gizmo snaps to a new location.
     * * snapDistance is the change in distance
     */
    //var onSnapObservable: Observable<{ snapDistance: Float }>;
    var onSnapObservable: Observable<Float>;
    /** If the gizmo is enabled */
    var isEnabled: Bool;

    /** Default material used to render when gizmo is not disabled or hovered */
    var coloredMaterial: StandardMaterial;
    /** Material used to render when gizmo is hovered with mouse*/
    var hoverMaterial: StandardMaterial;
    /** Material used to render when gizmo is disabled. typically grey.*/
    var disableMaterial: StandardMaterial;
}

/**
 * Single axis drag gizmo
 */
class AxisDragGizmo extends Gizmo implements IAxisDragGizmo {
    /**
     * Drag behavior responsible for the gizmos dragging interactions
     */
    public var dragBehavior: PointerDragBehavior;
    private var _pointerObserver: Observer<PointerInfo> = null;
    /**
     * Drag distance in babylon units that the gizmo will snap to when dragged (Default: 0)
     */
    public var snapDistance:Float = 0;
    /**
     * Event that fires each time the gizmo snaps to a new location.
     * * snapDistance is the change in distance
     */
    //public var onSnapObservable = new Observable<{ snapDistance: Float }>();
    public var onSnapObservable = new Observable<Float>();

    private var _isEnabled: Bool = true;
    private var _parent: PositionGizmo = null;

    private var _gizmoMesh: Mesh;
    private var _coloredMaterial: StandardMaterial;
    private var _hoverMaterial: StandardMaterial;
    private var _disableMaterial: StandardMaterial;
    private var _dragging: Bool = false;

    /** Default material used to render when gizmo is not disabled or hovered */
    public var coloredMaterial(get, never) : StandardMaterial;
    public function get_coloredMaterial() {
        return this._coloredMaterial;
    }

    /** Material used to render when gizmo is hovered with mouse*/
    public var hoverMaterial(get, never): StandardMaterial;
    public function get_hoverMaterial() {
        return this._hoverMaterial;
    }

    /** Material used to render when gizmo is disabled. typically grey.*/
    public var disableMaterial(get, never): Bool;
    public function get_disableMaterial() {
        return this._disableMaterial;
    }

    /**
     * @internal
     */
    public static function _CreateArrow(scene: Scene, material: StandardMaterial, thickness: Float = 1, isCollider = false): TransformNode {
        final arrow = new TransformNode("arrow", scene);
        final cylinder = CreateCylinder(
            "cylinder",
            {
                diameterTop: 0,
                height: 0.075,
                diameterBottom: 0.0375 * (1 + (thickness - 1) / 4),
                tessellation: 96,
            },
            scene
        );
        final line = CreateCylinder(
            "cylinder",
            {
                diameterTop: 0.005 * thickness,
                height: 0.275,
                diameterBottom: 0.005 * thickness,
                tessellation: 96,
            },
            scene
        );

        // Position arrow pointing in its drag axis
        cylinder.parent = arrow;
        cylinder.material = material;
        cylinder.rotation.x = Math.PI / 2;
        cylinder.position.z += 0.3;

        line.parent = arrow;
        line.material = material;
        line.position.z += 0.275 / 2;
        line.rotation.x = Math.PI / 2;

        if (isCollider) {
            line.visibility = 0;
            cylinder.visibility = 0;
        }
        return arrow;
    }

    /**
     * @internal
     */
    public static function _CreateArrowInstance(scene: Scene, arrow: TransformNode): TransformNode {
        final instance = new TransformNode("arrow", scene);
        for (mesh in arrow.getChildMeshes()) {
            final childInstance = cast(mesh, Mesh).createInstance(mesh.name);
            childInstance.parent = instance;
        }
        return instance;
    }

    /**
     * Creates an AxisDragGizmo
     * @param dragAxis The axis which the gizmo will be able to drag on
     * @param color The color of the gizmo
     * @param gizmoLayer The utility layer the gizmo will be added to
     * @param parent
     * @param thickness display gizmo axis thickness
     * @param hoverColor The color of the gizmo when hovering over and dragging
     * @param disableColor The Color of the gizmo when its disabled
     */
    public function new(
        dragAxis: Vector3,
        color: Color3 = Color3.Gray(),
        gizmoLayer: UtilityLayerRenderer = UtilityLayerRenderer.DefaultUtilityLayer,
        parent: PositionGizmo = null,
        thickness: Float = 1,
        hoverColor: Color3 = Color3.Yellow(),
        disableColor: Color3 = Color3.Gray()
    ) {
        super(gizmoLayer);
        this._parent = parent;

        // Create Material
        this._coloredMaterial = new StandardMaterial("", gizmoLayer.utilityLayerScene);
        this._coloredMaterial.diffuseColor = color;
        this._coloredMaterial.specularColor = color.subtract(new Color3(0.1, 0.1, 0.1));

        this._hoverMaterial = new StandardMaterial("", gizmoLayer.utilityLayerScene);
        this._hoverMaterial.diffuseColor = hoverColor;

        this._disableMaterial = new StandardMaterial("", gizmoLayer.utilityLayerScene);
        this._disableMaterial.diffuseColor = disableColor;
        this._disableMaterial.alpha = 0.4;

        // Build Mesh + Collider
        var arrow = AxisDragGizmo._CreateArrow(gizmoLayer.utilityLayerScene, this._coloredMaterial, thickness);
        var collider = AxisDragGizmo._CreateArrow(gizmoLayer.utilityLayerScene, this._coloredMaterial, thickness + 4, true);

        // Add to Root Node
        this._gizmoMesh = new Mesh("", gizmoLayer.utilityLayerScene);
        this._gizmoMesh.addChild(cast(arrow, Mesh));
        this._gizmoMesh.addChild(cast(collider,Mesh));

        this._gizmoMesh.lookAt(this._rootMesh.position.add(dragAxis));
        this._gizmoMesh.scaling.scaleInPlace(1 / 3);
        this._gizmoMesh.parent = this._rootMesh;

        var currentSnapDragDistance = 0;
        final tmpSnapEvent = { snapDistance: 0 };
        // Add drag behavior to handle events when the gizmo is dragged
        this.dragBehavior = new PointerDragBehavior({ dragAxis: dragAxis });
        this.dragBehavior.moveAttached = false;
        this.dragBehavior.updateDragPlane = false;
        this._rootMesh.addBehavior(this.dragBehavior);

        this.dragBehavior.onDragObservable.add((event) => {
            if (this.attachedNode) {
                // Keep world translation and use it to update world transform
                // if the node has parent, the local transform properties (position, rotation, scale)
                // will be recomputed in _matrixChanged function

                var matrixChanged: Bool = false;
                // Snapping logic
                if (this.snapDistance == 0) {
                    this.attachedNode.getWorldMatrix().getTranslationToRef(TmpVectors.Vector3[2]);
                    TmpVectors.Vector3[2].addInPlace(event.delta);
                    if (this.dragBehavior.validateDrag(TmpVectors.Vector3[2])) {
                        
                        //CL
                        if(Std.isOfType(this.attachedNode, IShadowLight)) {
                            var shadowLight = cast(this.attachedNode, IShadowLight);
                            shadowLight.position.addInPlaceFromFloats(event.delta.x, event.delta.y, event.delta.z);
                        }
                        
                        // if ((this.attachedNode as any).position) {
                        //     // Required for nodes like lights
                        //     (this.attachedNode as any).position.addInPlaceFromFloats(event.delta.x, event.delta.y, event.delta.z);
                        // }

                        // use _worldMatrix to not force a matrix update when calling GetWorldMatrix especially with Cameras
                        this.attachedNode.getWorldMatrix().addTranslationFromFloats(event.delta.x, event.delta.y, event.delta.z);
                        this.attachedNode.updateCache();
                        matrixChanged = true;
                    }
                } else {
                    currentSnapDragDistance += event.dragDistance;
                    if (Math.abs(currentSnapDragDistance) > this.snapDistance) {
                        final dragSteps = Math.floor(Math.abs(currentSnapDragDistance) / this.snapDistance);
                        currentSnapDragDistance = currentSnapDragDistance % this.snapDistance;
                        event.delta.normalizeToRef(TmpVectors.Vector3[1]);
                        TmpVectors.Vector3[1].scaleInPlace(this.snapDistance * dragSteps);

                        this.attachedNode.getWorldMatrix().getTranslationToRef(TmpVectors.Vector3[2]);
                        TmpVectors.Vector3[2].addInPlace(TmpVectors.Vector3[1]);
                        if (this.dragBehavior.validateDrag(TmpVectors.Vector3[2])) {
                            this.attachedNode.getWorldMatrix().addTranslationFromFloats(TmpVectors.Vector3[1].x, TmpVectors.Vector3[1].y, TmpVectors.Vector3[1].z);
                            this.attachedNode.updateCache();
                            tmpSnapEvent.snapDistance = this.snapDistance * dragSteps * Math.sign(currentSnapDragDistance);
                            this.onSnapObservable.notifyObservers(tmpSnapEvent);
                            matrixChanged = true;
                        }
                    }
                }
                if (matrixChanged) {
                    this._matrixChanged();
                }
            }
        });
        this.dragBehavior.onDragStartObservable.add(function() {
            this._dragging = true;
        });
        this.dragBehavior.onDragEndObservable.add(function() {
            this._dragging = false;
        });

        final light = gizmoLayer._getSharedGizmoLight();
        light.includedOnlyMeshes = light.includedOnlyMeshes.concat(this._rootMesh.getChildMeshes(false));

        var gizmoMeshes = arrow.getChildMeshes();
        var colliderMeshes = collider.getChildMeshes();
        
        var cache: GizmoAxisCache = {
            // gizmoMeshes: cast(arrow.getChildMeshes(), Mesh[]),
            // colliderMeshes: cast(collider.getChildMeshes(), Mesh[]),
            gizmoMeshes: gizmoMeshes,
            colliderMeshes: colliderMeshes,
            material: this._coloredMaterial,
            hoverMaterial: this._hoverMaterial,
            disableMaterial: this._disableMaterial,
            active: false,
            dragBehavior: this.dragBehavior,
        };

        this._parent?.addToAxisCache(cast(collider,Mesh), cache);

        this._pointerObserver = gizmoLayer.utilityLayerScene.onPointerObservable.add((pointerInfo) => {
            if (this._customMeshSet) {
                return;
            }
            //CL 
            this._isHovered = cache.colliderMeshes.indexOf(pointerInfo?.pickInfo?.pickedMesh) != -1;
            //this._isHovered = !!(cache.colliderMeshes.indexOf(<Mesh>pointerInfo?.pickInfo?.pickedMesh) != -1);
            if (!this._parent) {
                final material = this.dragBehavior.enabled ? (this._isHovered || this._dragging ? this._hoverMaterial : this._coloredMaterial) : this._disableMaterial;
                this._setGizmoMeshMaterial(cache.gizmoMeshes, material);
            }
        });

        this.dragBehavior.onEnabledObservable.add((newState) => {
            this._setGizmoMeshMaterial(cache.gizmoMeshes, newState ? cache.material : cache.disableMaterial);
        });
    }

    private function _attachedNodeChanged(value: Node) {
        if (this.dragBehavior) {
            this.dragBehavior.enabled = value ? true : false;
        }
    }

    /**
     * If the gizmo is enabled
     */
    public var isEnabled(get,set): Bool;
    public function set_isEnabled(value: Bool) {
        this._isEnabled = value;
        if (!value) {
            this.attachedMesh = null;
            this.attachedNode = null;
        } else {
            if (this._parent) {
                this.attachedMesh = this._parent.attachedMesh;
                this.attachedNode = this._parent.attachedNode;
            }
        }
    }

    public function get_isEnabled(): Bool {
        return this._isEnabled;
    }

    /**
     * Disposes of the gizmo
     */
    public override function dispose() {
        this.onSnapObservable.clear();
        this.gizmoLayer.utilityLayerScene.onPointerObservable.remove(this._pointerObserver);
        this.dragBehavior.detach();
        if (this._gizmoMesh) {
            this._gizmoMesh.dispose();
        }
        [this._coloredMaterial, this._hoverMaterial, this._disableMaterial].forEach((matl) => {
            if (matl) {
                matl.dispose();
            }
        });
        super.dispose();
    }
}