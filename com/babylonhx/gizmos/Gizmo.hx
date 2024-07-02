package com.babylonhx.gizmos;

import com.babylonhx.lights.Light;
import com.babylonhx.lights.ShadowLight;
import com.babylonhx.bones.Bone;
import com.babylonhx.cameras.TargetCamera;
import com.babylonhx.math.Tmp;
import com.babylonhx.math.Vector3;
import com.babylonhx.materials.StandardMaterial;
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
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.rendering.UtilityLayerRenderer;
import com.babylonhx.behaviors.meshes.PointerDragBehavior;

/**
 * Cache built by each axis. Used for managing state between all elements of gizmo for enhanced UI
 */
 interface GizmoAxisCache {
    /** Mesh used to render the Gizmo */
    var gizmoMeshes: Array<Mesh>;
    /** Mesh used to detect user interaction with Gizmo */
    var colliderMeshes: Array<Mesh>;
    /** Material used to indicate color of gizmo mesh */
    var material: StandardMaterial;
    /** Material used to indicate hover state of the Gizmo */
    var hoverMaterial: StandardMaterial;
    /** Material used to indicate disabled state of the Gizmo */
    var disableMaterial: StandardMaterial;
    /** Used to indicate Active state of the Gizmo */
    var active: Bool;
    /** DragBehavior */
    var dragBehavior: PointerDragBehavior;
}

/**
 * Anchor options where the Gizmo can be positioned in relation to its anchored node
 */
enum GizmoAnchorPoint {
    /** The origin of the attached node */
    Origin;
    /** The pivot point of the attached node*/
    Pivot;
}

/**
 * Coordinates mode: Local or World. Defines how axis is aligned: either on world axis or transform local axis
 */
 enum GizmoCoordinatesMode {
    World;
    Local;
}

/**
 * Interface for basic gizmo
 */
//interface IGizmo extends IDisposable {
interface IGizmo extends IDisposable {
    /** True when the mouse pointer is hovered a gizmo mesh */
    var isHovered: Bool;
    /** The root mesh of the gizmo */
    var _rootMesh: Mesh;
    /** Ratio for the scale of the gizmo */
    var scaleRatio: Float;
    /**
     * Mesh that the gizmo will be attached to. (eg. on a drag gizmo the mesh that will be dragged)
     * * When set, interactions will be enabled
     */
    var attachedMesh: AbstractMesh;
    /**
     * Node that the gizmo will be attached to. (eg. on a drag gizmo the mesh, bone or NodeTransform that will be dragged)
     * * When set, interactions will be enabled
     */
    var attachedNode: Node;
    /**
     * If set the gizmo's rotation will be updated to match the attached mesh each frame (Default: true)
     */
    var updateGizmoRotationToMatchAttachedMesh: Bool;
    /** The utility layer the gizmo will be added to */
    var gizmoLayer: UtilityLayerRenderer;
    /**
     * If set the gizmo's position will be updated to match the attached mesh each frame (Default: true)
     */
    var updateGizmoPositionToMatchAttachedMesh: Bool;
    /**
     * Defines where the gizmo will be positioned if `updateGizmoPositionToMatchAttachedMesh` is enabled.
     * (Default: GizmoAnchorPoint.Origin)
     */
    var anchorPoint: GizmoAnchorPoint;

    /**
     * Set the coordinate mode to use. By default it's local.
     */
    var coordinatesMode: GizmoCoordinatesMode;

    /**
     * When set, the gizmo will always appear the same size no matter where the camera is (default: true)
     */
    var updateScale: Bool;
    /**
     * posture that the gizmo will be display
     * When set null, default value will be used (Quaternion(0, 0, 0, 1))
     */
    var customRotationQuaternion: Quaternion;
    /**
     * Disposes and replaces the current meshes in the gizmo with the specified mesh
     * @param mesh The mesh to replace the default mesh of the gizmo
     */
    function setCustomMesh(mesh: Mesh): Void;
    
    /**
     * Additional transform applied to the gizmo.
     * It's useful when the gizmo is attached to a bone: if the bone is part of a skeleton attached to a mesh, you should define the mesh as additionalTransformNode if you want the gizmo to be displayed at the bone's correct location.
     * Otherwise, as the gizmo is relative to the skeleton root, the mesh transformation will not be taken into account.
     */
    var additionalTransformNode: TransformNode;
}
/**
 * Renders gizmos on top of an existing scene which provide controls for position, rotation, etc.
 */
 @:expose('BABYLON.Gizmo') class Gizmo implements IGizmo {
    /**
     * The root mesh of the gizmo
     */
    public var _rootMesh: Mesh;
    private var _attachedMesh: AbstractMesh = null;
    private var _attachedNode: Node = null;
    private var _customRotationQuaternion: Quaternion = null;
    private var _additionalTransformNode: TransformNode;
    /**
     * Ratio for the scale of the gizmo (Default: 1)
     */
    private var _scaleRatio = 1.0;

    /**
     * boolean updated by pointermove when a gizmo mesh is hovered
     */
    private var _isHovered = false;

    /**
     * When enabled, any gizmo operation will perserve scaling sign. Default is off.
     * Only valid for TransformNode derived classes (Mesh, AbstractMesh, ...)
     */
    public static var PreserveScaling = false;

    /**
     * There are 2 ways to preserve scaling: using mesh scaling or absolute scaling. Depending of hierarchy, non uniform scaling and LH or RH coordinates. One is preferable than the other.
     * If the scaling to be preserved is the local scaling, then set this value to false.
     * Default is true which means scaling to be preserved is absolute one (with hierarchy applied)
     */
    public static var UseAbsoluteScaling = true;

    /**
     * Ratio for the scale of the gizmo (Default: 1)
     */
    public var scaleRatio:Float;

    public function set_scaleRatio(value: Float) {
        this._scaleRatio = value;
    }

    public function get_scaleRatio() : Float {
        return this._scaleRatio;
    }

    /**
     * True when the mouse pointer is hovered a gizmo mesh
     */
    public var isHovered:Bool;
    public function get_isHovered() {
        return this._isHovered;
    }

    /**
     * If a custom mesh has been set (Default: false)
     */
    var _customMeshSet = false;
    /**
     * Mesh that the gizmo will be attached to. (eg. on a drag gizmo the mesh that will be dragged)
     * * When set, interactions will be enabled
     */
    public var attachedMesh:AbstractMesh;
    public function get_attachedMesh() {
        return this._attachedMesh;
    }
    public function set_attachedMesh(value:AbstractMesh) {
        this._attachedMesh = value;
        if (value != null) {
            this._attachedNode = value;
        }
        this._rootMesh.setEnabled(value != null ? true : false);
        this._attachedNodeChanged(value);
        return this;
    }
    /**
     * Node that the gizmo will be attached to. (eg. on a drag gizmo the mesh, bone or NodeTransform that will be dragged)
     * * When set, interactions will be enabled
     */
    public var attachedNode:Node;
    public function get_attachedNode() : Node {
        return this._attachedNode;
    }
    public function set_attachedNode(value:Node) {
        this._attachedNode = value;
        this._attachedMesh = null;
        this._rootMesh.setEnabled(value != null ? true : false);
        this._attachedNodeChanged(value);
    }

    /**
     * Disposes and replaces the current meshes in the gizmo with the specified mesh
     * @param mesh The mesh to replace the default mesh of the gizmo
     */
    public function setCustomMesh(mesh: Mesh) {
        if (mesh.getScene() != this.gizmoLayer.utilityLayerScene) {
            // eslint-disable-next-line no-throw-literal
            throw "When setting a custom mesh on a gizmo, the custom meshes scene must be the same as the gizmos (eg. gizmo.gizmoLayer.utilityLayerScene)";
        }
        //CL todo 
        // this._rootMesh.getChildMeshes().forEach((c) => {
        //     c.dispose();
        // });
        mesh.parent = this._rootMesh;
        this._customMeshSet = true;
    }

    /**
     * Additional transform applied to the gizmo.
     * It's useful when the gizmo is attached to a bone: if the bone is part of a skeleton attached to a mesh, you should define the mesh as additionalTransformNode if you want the gizmo to be displayed at the bone's correct location.
     * Otherwise, as the gizmo is relative to the skeleton root, the mesh transformation will not be taken into account.
     */
    public var additionalTransformNode:TransformNode;
    public function get_additionalTransformNode(): TransformNode {
        return this._additionalTransformNode;
    }

    public function set_additionalTransformNode(value: TransformNode) {
        this._additionalTransformNode = value;
    }

    private var _updateGizmoRotationToMatchAttachedMesh = true;
    private var _updateGizmoPositionToMatchAttachedMesh = true;
    private var _anchorPoint = GizmoAnchorPoint.Origin;
    private var _updateScale = true;
    private var _coordinatesMode = GizmoCoordinatesMode.Local;

    /**
     * If set the gizmo's rotation will be updated to match the attached mesh each frame (Default: true)
     * NOTE: This is only possible for meshes with uniform scaling, as otherwise it's not possible to decompose the rotation
     */
    public var updateGizmoRotationToMatchAttachedMesh:Bool;
    public function set_updateGizmoRotationToMatchAttachedMesh(value: Bool) {
        this._updateGizmoRotationToMatchAttachedMesh = value;
    }
    public function get_updateGizmoRotationToMatchAttachedMesh() {
        return this._updateGizmoRotationToMatchAttachedMesh;
    }
    /**
     * If set the gizmo's position will be updated to match the attached mesh each frame (Default: true)
     */
    public var updateGizmoPositionToMatchAttachedMesh:Bool;
    public function set_updateGizmoPositionToMatchAttachedMesh(value: Bool) {
        this._updateGizmoPositionToMatchAttachedMesh = value;
    }
    public function get_updateGizmoPositionToMatchAttachedMesh() : Bool {
        return this._updateGizmoPositionToMatchAttachedMesh;
    }

    /**
     * Defines where the gizmo will be positioned if `updateGizmoPositionToMatchAttachedMesh` is enabled.
     * (Default: GizmoAnchorPoint.Origin)
     */
    public var anchorPoint:GizmoAnchorPoint;
    public function set_anchorPoint(value: GizmoAnchorPoint) {
        this._anchorPoint = value;
    }
    public function get_anchorPoint() : GizmoAnchorPoint {
        return this._anchorPoint;
    }

    /**
     * Set the coordinate system to use. By default it's local.
     * But it's possible for a user to tweak so its local for translation and world for rotation.
     * In that case, setting the coordinate system will change `updateGizmoRotationToMatchAttachedMesh` and `updateGizmoPositionToMatchAttachedMesh`
     */
    public var coordinatesMode:GizmoCoordinatesMode;
    public function set_coordinatesMode(coordinatesMode: GizmoCoordinatesMode) {
        this._coordinatesMode = coordinatesMode;
        var local = coordinatesMode == GizmoCoordinatesMode.Local;
        this.updateGizmoRotationToMatchAttachedMesh = local;
        this.updateGizmoPositionToMatchAttachedMesh = true;
    }

    public function get_coordinatesMode(): GizmoCoordinatesMode {
        return this._coordinatesMode;
    }

    /**
     * When set, the gizmo will always appear the same size no matter where the camera is (default: true)
     */
    public var updateScale:Bool;
    public function set_updateScale(value: Bool) {
        this._updateScale = value;
    }
    public function get_updateScale() : Bool {
        return this._updateScale;
    }
    private var _interactionsEnabled = true;
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    private function _attachedNodeChanged(value: Node) {}

    private var _beforeRenderObserver: Observer<Scene>;
    private var _rightHandtoLeftHandMatrix = Matrix.RotationY(Math.PI);

    public var gizmoLayer: UtilityLayerRenderer;

    /**
     * Creates a gizmo
     * @param gizmoLayer The utility layer the gizmo will be added to
     */
    function new(
        /** The utility layer the gizmo will be added to */
        gizmoLayer: UtilityLayerRenderer
    ) {
        this.gizmoLayer = gizmoLayer;
        this._rootMesh = new Mesh("gizmoRootNode", gizmoLayer.utilityLayerScene);
        this._rootMesh.rotationQuaternion = Quaternion.Identity();

        this._beforeRenderObserver = this.gizmoLayer.utilityLayerScene.onBeforeRenderObservable.add(function(_,_) {
            this._update();
        });
    }

    /**
     * posture that the gizmo will be display
     * When set null, default value will be used (Quaternion(0, 0, 0, 1))
     */
    public var customRotationQuaternion:Quaternion;
    public function get_customRotationQuaternion(): Quaternion {
        return this._customRotationQuaternion;
    }

    public function set_customRotationQuaternion(customRotationQuaternion: Quaternion) {
        this._customRotationQuaternion = customRotationQuaternion;
    }

    /**
     * Updates the gizmo to match the attached mesh's position/rotation
     */
    private function _update() {
        if (this.attachedNode != null) {
            var effectiveNode = this.attachedNode;
            if (this.attachedMesh != null) {
                effectiveNode = this.attachedMesh != null ? this.attachedMesh : this.attachedNode;
            }

            // Position
            if (this.updateGizmoPositionToMatchAttachedMesh) {
                if (this.anchorPoint == GizmoAnchorPoint.Pivot && (cast(effectiveNode, TransformNode)).getAbsolutePivotPoint() != null) {
                    var position = (cast(effectiveNode, TransformNode)).getAbsolutePivotPoint();
                    this._rootMesh.position.copyFrom(position);
                } else {
                    var row = effectiveNode.getWorldMatrix().getRow(3);
                    var position = row != null ? row.toVector3() : new Vector3(0, 0, 0);
                    this._rootMesh.position.copyFrom(position);
                }
            }

            // Rotation
            if (this.updateGizmoRotationToMatchAttachedMesh) {
                var supportedNode =
                    cast(effectiveNode, Mesh).isMesh ||
                    effectiveNode.getClassName() == "AbstractMesh" ||
                    effectiveNode.getClassName() == "TransformNode" ||
                    effectiveNode.getClassName() == "InstancedMesh";
                var transformNode = supportedNode != null ? cast(effectiveNode, TransformNode) : null;
                effectiveNode.getWorldMatrix().decompose(Vector3.Zero(), this._rootMesh.rotationQuaternion, Gizmo.PreserveScaling ? transformNode.position : Vector3.Zero(), null);
                //CL
                //this._rootMesh.rotationQuaternion!.normalize();
                this._rootMesh.rotationQuaternion.normalize();
            } else {
                if(this._customRotationQuaternion != null) {
                    //this._rootMesh.rotationQuaternion!.copyFrom(this._customRotationQuaternion);
                    this._rootMesh.rotationQuaternion.copyFrom(this._customRotationQuaternion);
                } else {
                    this._rootMesh.rotationQuaternion.set(0, 0, 0, 1);
                }
            }

            // Scale
            if (this.updateScale) {
                var activeCamera = this.gizmoLayer.utilityLayerScene.activeCamera;
                var cameraPosition = activeCamera.globalPosition;
                this._rootMesh.position.subtractToRef(cameraPosition, Tmp.vector3[0]);
                var scale = this.scaleRatio;
                if (activeCamera.mode == Camera.ORTHOGRAPHIC_CAMERA) {
                    if (activeCamera.orthoTop != null && activeCamera.orthoBottom != null) {
                        final orthoHeight = activeCamera.orthoTop - activeCamera.orthoBottom;
                        scale *= orthoHeight;
                    }
                } else {
                    //final camForward = activeCamera.getScene().useRightHandedSystem ? Vector3.RightHandedForwardReadOnly : Vector3.LeftHandedForwardReadOnly;
                    final camForward = Vector3.Forward(); 
                    final direction = activeCamera.getDirection(camForward);
                    scale *= Vector3.Dot(Tmp.vector3[0], direction);
                }
                this._rootMesh.scaling.set(scale, scale, scale);

                // Account for handedness, similar to Matrix.decompose
                if(cast(effectiveNode, TransformNode)._getWorldMatrixDeterminant() < 0 && !Gizmo.PreserveScaling) {
                    this._rootMesh.scaling.y *= -1;
                }
            } else {
                this._rootMesh.scaling.set(this.scaleRatio, this.scaleRatio, this.scaleRatio);
            }
        }

        if (this.additionalTransformNode != null) {
            this._rootMesh.computeWorldMatrix(true);
            this._rootMesh.getWorldMatrix().multiplyToRef(this.additionalTransformNode.getWorldMatrix(), Tmp.matrix[0]);
            Tmp.matrix[0].decompose(this._rootMesh.scaling, this._rootMesh.rotationQuaternion, this._rootMesh.position, null);
        }
    }

    /**
     * if transform has a pivot and is not using PostMultiplyPivotMatrix, then the worldMatrix contains the pivot matrix (it's not cancelled at the end)
     * so, when extracting the world matrix component, the translation (and other components) is containing the pivot translation.
     * And the pivot is applied each frame. Removing it anyway here makes it applied only in computeWorldMatrix.
     * @param transform local transform that needs to be transform by the pivot inverse matrix
     * @param localMatrix local matrix that needs to be transform by the pivot inverse matrix
     * @param result resulting matrix transformed by pivot inverse if the transform node is using pivot without using post Multiply Pivot Matrix
     */
    private function _handlePivotMatrixInverse(transform: TransformNode, localMatrix: Matrix, result: Matrix): Void {
        if (transform.isUsingPivotMatrix() && !transform.isUsingPostMultiplyPivotMatrix()) {
            transform.getPivotMatrix().invertToRef(Tmp.matrix[5]);
            Tmp.matrix[5].multiplyToRef(localMatrix, result);
            return;
        }
        result.copyFrom(localMatrix);
    }
    /**
     * computes the rotation/scaling/position of the transform once the Node world matrix has changed.
     */
    private function _matrixChanged() {
        if (this._attachedNode == null) {
            return;
        }

        if (Std.isOfType(this._attachedNode, Camera) && cast(this.attachedNode, Camera).isCamera) {
            final camera = cast(this._attachedNode, Camera);
            var worldMatrix:Matrix;
            var worldMatrixUC:Matrix;
            if (camera.parent != null) {
                final parentInv = Tmp.matrix[1];
                //CL - investigate! One of the big changes in newer babylonjs is that Node has its own _worldMatrix
                //camera.parent._worldMatrix.invertToRef(parentInv);
                camera.parent.getWorldMatrix().invertToRef(parentInv);
                //this._attachedNode._worldMatrix.multiplyToRef(parentInv, Tmp.matrix[0]);
                this._attachedNode.getWorldMatrix().multiplyToRef(parentInv, Tmp.matrix[0]);
                worldMatrix = Tmp.matrix[0];
            } else {
                //worldMatrix = this._attachedNode._worldMatrix;
                worldMatrix = this._attachedNode.getWorldMatrix();
            }

            if (camera.getScene().useRightHandedSystem) {
                // avoid desync with RH matrix computation. Otherwise, rotation of PI around Y axis happens each frame resulting in axis flipped because worldMatrix is computed as inverse of viewMatrix.
                this._rightHandtoLeftHandMatrix.multiplyToRef(worldMatrix, Tmp.matrix[1]);
                worldMatrixUC = Tmp.matrix[1];
            } else {
                worldMatrixUC = worldMatrix;
            }

            worldMatrixUC.decompose(Tmp.vector3[1], Tmp.quaternion[0], Tmp.vector3[0]);

            final inheritsTargetCamera =
                this._attachedNode.getClassName() == "FreeCamera" ||
                this._attachedNode.getClassName() == "FlyCamera" ||
                this._attachedNode.getClassName() == "ArcFollowCamera" ||
                this._attachedNode.getClassName() == "TargetCamera" ||
                this._attachedNode.getClassName() == "TouchCamera" ||
                this._attachedNode.getClassName() == "UniversalCamera";

            if (inheritsTargetCamera) {
                final targetCamera = cast(this._attachedNode, TargetCamera);
                targetCamera.rotation = Tmp.quaternion[0].toEulerAngles();

                if (targetCamera.rotationQuaternion != null) {
                    targetCamera.rotationQuaternion.copyFrom(Tmp.quaternion[0]);
                    targetCamera.rotationQuaternion.normalize();
                }
            }

            camera.position.copyFrom(Tmp.vector3[0]);
        } else if (
            (cast(this._attachedNode, Mesh)).isMesh ||
            this._attachedNode.getClassName() == "AbstractMesh" ||
            this._attachedNode.getClassName() == "TransformNode" ||
            this._attachedNode.getClassName() == "InstancedMesh"
        ) {
            var transform = cast(this._attachedNode, TransformNode);
            if (transform.parent != null) {
                final parentInv = Tmp.matrix[0];
                final localMat = Tmp.matrix[1];
                transform.parent.getWorldMatrix().invertToRef(parentInv);
                this._attachedNode.getWorldMatrix().multiplyToRef(parentInv, localMat);
                final matrixToDecompose = Tmp.matrix[4];
                this._handlePivotMatrixInverse(transform, localMat, matrixToDecompose);
                matrixToDecompose.decompose(
                    Tmp.vector3[0],
                    Tmp.quaternion[0],
                    transform.position,
                    Gizmo.PreserveScaling ? transform : null,
                    Gizmo.UseAbsoluteScaling
                );
                Tmp.quaternion[0].normalize();
                if (transform.isUsingPivotMatrix()) {
                    // Calculate the local matrix without the translation.
                    // Copied from TranslateNode.computeWorldMatrix
                    final r = Tmp.quaternion[1];
                    Quaternion.RotationYawPitchRollToRef(transform.rotation.y, transform.rotation.x, transform.rotation.z, r);

                    final scaleMatrix = Tmp.matrix[2];
                    Matrix.ScalingToRef(transform.scaling.x, transform.scaling.y, transform.scaling.z, scaleMatrix);

                    final rotationMatrix = Tmp.matrix[2];
                    r.toRotationMatrix(rotationMatrix);

                    final pivotMatrix = transform.getPivotMatrix();
                    final invPivotMatrix = Tmp.matrix[3];
                    pivotMatrix.invertToRef(invPivotMatrix);

                    pivotMatrix.multiplyToRef(scaleMatrix, Tmp.matrix[4]);
                    Tmp.matrix[4].multiplyToRef(rotationMatrix, Tmp.matrix[5]);
                    Tmp.matrix[5].multiplyToRef(invPivotMatrix, Tmp.matrix[6]);

                    Tmp.matrix[6].getTranslationToRef(Tmp.vector3[1]);

                    transform.position.subtractInPlace(Tmp.vector3[1]);
                }
            } else {
                final matrixToDecompose = Tmp.matrix[4];
                this._handlePivotMatrixInverse(transform, this._attachedNode.getWorldMatrix(), matrixToDecompose);
                matrixToDecompose.decompose(
                    Tmp.vector3[0],
                    Tmp.quaternion[0],
                    transform.position,
                    Gizmo.PreserveScaling ? transform : null,
                    Gizmo.UseAbsoluteScaling
                );
            }
            Tmp.vector3[0].scaleInPlace(1.0 / transform.scalingDeterminant);
            transform.scaling.copyFrom(Tmp.vector3[0]);
            if (transform.billboardMode == null) {
                if (transform.rotationQuaternion != null) {
                    transform.rotationQuaternion.copyFrom(Tmp.quaternion[0]);
                    transform.rotationQuaternion.normalize();
                } else {
                    transform.rotation = Tmp.quaternion[0].toEulerAngles();
                }
            }
        } else if (this._attachedNode.getClassName() == "Bone") {
            final bone = cast(this._attachedNode, Bone);
            final parent = bone.getParent();

            if (parent != null) {
                final invParent = Tmp.matrix[0];
                final boneLocalMatrix = Tmp.matrix[1];
                //CL
                parent.getWorldMatrix().invertToRef(invParent);
                //parent.getFinalMatrix().invertToRef(invParent);
                //CL
                bone.getWorldMatrix().multiplyToRef(invParent, boneLocalMatrix);
                //bone.getFinalMatrix().multiplyToRef(invParent, boneLocalMatrix);
                final lmat = bone.getLocalMatrix();
                lmat.copyFrom(boneLocalMatrix);
            } else {
                final lmat = bone.getLocalMatrix();
                //CL
                //lmat.copyFrom(bone.getFinalMatrix());
                lmat.copyFrom(bone.getWorldMatrix());
            }
            bone.markAsDirty();
        } else {
            final light = cast(this._attachedNode, ShadowLight);
            //if (light.getTypeID) {
                var type = light.getTypeID();
                if (type == Light.LIGHTTYPEID_DIRECTIONALLIGHT || type == Light.LIGHTTYPEID_SPOTLIGHT || type == Light.LIGHTTYPEID_POINTLIGHT) {
                    final parent = light.parent;

                    if (parent != null) {
                        final invParent = Tmp.matrix[0];
                        final nodeLocalMatrix = Tmp.matrix[1];
                        parent.getWorldMatrix().invertToRef(invParent);
                        light.getWorldMatrix().multiplyToRef(invParent, nodeLocalMatrix);
                        //CL
                        //nodeLocalMatrix.decompose(undefined, Tmp.quaternion[0], Tmp.vector3[0]);
                        nodeLocalMatrix.decompose(Tmp.vector3[7], Tmp.quaternion[0], Tmp.vector3[0]);
                    } else {
                        this._attachedNode.getWorldMatrix().decompose(Tmp.vector3[7], Tmp.quaternion[0], Tmp.vector3[0]);
                    }
                    // setter doesn't copy values. Need a new Vector3
                    light.position = new Vector3(Tmp.vector3[0].x, Tmp.vector3[0].y, Tmp.vector3[0].z);
                    if (light.direction != null) {
                        light.direction = new Vector3(light.direction.x, light.direction.y, light.direction.z);
                    }
                }
            //}
        }
    }

    /**
     * refresh gizmo mesh material
     * @param gizmoMeshes
     * @param material material to apply
     */
    private function _setGizmoMeshMaterial(gizmoMeshes: List<Mesh>, material: StandardMaterial) {
        if (gizmoMeshes != null) {
            for(m in gizmoMeshes) {
                m.material = material;
                //CL
                if(Std.isOfType(m, LinesMesh)) {
                   cast(m, LinesMesh).color = material.diffuseColor;
                }
                // if ((<LinesMesh>m).color) {
                //     (<LinesMesh>m).color = material.diffuseColor;
                // }
            };
        }
    }

    /**
     * Subscribes to pointer up, down, and hover events. Used for responsive gizmos.
     * @param gizmoLayer The utility layer the gizmo will be added to
     * @param gizmoAxisCache Gizmo axis definition used for reactive gizmo UI
     * @returns {Observer<PointerInfo>} pointerObserver
     */
    public static function GizmoAxisPointerObserver(gizmoLayer: UtilityLayerRenderer, gizmoAxisCache: Map<Mesh, GizmoAxisCache>): Observer<PointerInfo> {
        var dragging = false;

        final pointerObserver = gizmoLayer.utilityLayerScene.onPointerObservable.add(function(pointerInfo, _) {
            if (pointerInfo.pickInfo != null) {
                // On Hover Logic
                if (pointerInfo.type == PointerEventTypes.POINTERMOVE) {
                    if (dragging) {
                        return;
                    }
                    
                    for(cache in gizmoAxisCache) {
                        if (cache.colliderMeshes != null && cache.gizmoMeshes != null) {
                            final pickedMesh = cast(pointerInfo.pickInfo.pickedMesh, Mesh);
                            final isHovered = cache.colliderMeshes.indexOf(pickedMesh) != -1;
                            final material = cache.dragBehavior.enabled ? (isHovered || cache.active ? cache.hoverMaterial : cache.material) : cache.disableMaterial;
                            for(m in cache.gizmoMeshes) {
                                m.material = material;
                                if(Std.isOfType(m, LinesMesh)) {
                                    cast(m, LinesMesh).color = material.diffuseColor;
                                 }
                            }
                            //CL
                            // cache.gizmoMeshes.forEach((m: Mesh) => {
                            //     m.material = material;
                            //     if ((m as LinesMesh).color) {
                            //         (m as LinesMesh).color = material.diffuseColor;
                            //     }
                            // });
                        }
                    };
                }

                // On Mouse Down
                if (pointerInfo.type == PointerEventTypes.POINTERDOWN) {
                    // If user Clicked Gizmo
                    final pickedMesh = cast(pointerInfo.pickInfo.pickedMesh, Mesh);
                    //CL
                    
                    if (gizmoAxisCache.exists(pickedMesh)) {
                    //if (gizmoAxisCache.has(pointerInfo.pickInfo.pickedMesh?.parent as Mesh)) {
                        dragging = true;
                        final parentPickedMesh = cast(pickedMesh.parent, Mesh);
                        final statusMap = gizmoAxisCache.get(parentPickedMesh);
                        statusMap.active = true;
                        for(cache in gizmoAxisCache) {
   
                            final isHovered = cache.colliderMeshes != null && cache.colliderMeshes.indexOf(pickedMesh) != -1;
                            final material = (isHovered || cache.active) && cache.dragBehavior.enabled ? cache.hoverMaterial : cache.disableMaterial;

                            for(m in cache.gizmoMeshes) {
                                m.material = material;
                                if(Std.isOfType(m, LinesMesh)) {
                                    cast(m, LinesMesh).color = material.diffuseColor;
                                 }
                            }
                        }
                    }
                }

                // On Mouse Up
                if (pointerInfo.type == PointerEventTypes.POINTERUP) {
                    for(cache in gizmoAxisCache) {
                        cache.active = false;
                        dragging = false;
                        for(m in cache.gizmoMeshes) {
                            m.material = cache.dragBehavior.enabled ? cache.material : cache.disableMaterial;
                            if(Std.isOfType(m, LinesMesh)) {
                                cast(m, LinesMesh).color = cache.material.diffuseColor;
                             }
                        }
                    };
                }
            }
        });

        return pointerObserver;
    }

    /**
     * Disposes of the gizmo
     */
    public function dispose(doNotRecurse:Bool = false) {
        this._rootMesh.dispose();
        if (this._beforeRenderObserver != null) {
            this.gizmoLayer.utilityLayerScene.onBeforeRenderObservable.remove(this._beforeRenderObserver);
        }
    }
}
