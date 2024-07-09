package com.babylonhx.behaviors.meshes;

import com.babylonhx.math.Tools;
import com.babylonhx.cameras.ArcRotateCamera;
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
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.mesh._InstancesBatch;
import com.babylonhx.mesh.LinesMesh;
import com.babylonhx.materials.Material;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Tools as MathTools;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Quaternion;
import com.babylonhx.rendering.UtilityLayerRenderer;
import com.babylonhx.culling.Ray;
import com.babylonhx.misc.PivotTools;

typedef DragEventInfo = {
    delta: Vector3,
    dragPlanePoint: Vector3,
    dragPlaneNormal: Vector3,
    dragDistance: Float,
    pointerId: Int,
    pointerInfo: PointerInfo
}

typedef DragOptions = {
    dragAxis: Vector3,
    dragPlaneNormal: Vector3
}

/**
 * A behavior that when attached to a mesh will allow the mesh to be dragged around the screen based on pointer events
 */
 @:expose('BABYLON.PointerDragBehavior') class PointerDragBehavior implements Behavior<AbstractMesh> {
 
    private static var _AnyMouseId = -2;
    /**
     * Abstract mesh the behavior is set on
     */
    public var attachedNode: AbstractMesh;
    private var _dragPlane: Mesh;
    private var _scene: Scene;
    private var _pointerObserver: Observer<PointerInfo>;
    private var _beforeRenderObserver: Observer<Scene>;
    private static var _PlaneScene: Scene;
    private var _useAlternatePickedPointAboveMaxDragAngleDragSpeed = -1.1;
    private var _activeDragButton: Int = -1;
    private var _activePointerInfo: PointerInfo;
    /**
     * The maximum tolerated angle between the drag plane and dragging pointer rays to trigger pointer events. Set to 0 to allow any angle (default: 0)
     */
    public var maxDragAngle = 0;
    /**
     * Butttons that can be used to initiate a drag
     */
    public var dragButtons = [0, 1, 2];
    /**
     * @internal
     */
    public var _useAlternatePickedPointAboveMaxDragAngle = false;
    
    /**
     * The id of the pointer that is currently interacting with the behavior (-1 when no pointer is active)
     */
    public var currentDraggingPointerId:Float = -1;
    /**
     * The last position where the pointer hit the drag plane in world space
     */
    public var lastDragPosition: Vector3;
    /**
     * If the behavior is currently in a dragging state
     */
    public var dragging = false;
    /**
     * The distance towards the target drag position to move each frame. This can be useful to avoid jitter. Set this to 1 for no delay. (Default: 0.2)
     */
    public var dragDeltaRatio = 0.2;
    /**
     * If the drag plane orientation should be updated during the dragging (Default: true)
     */
    public var updateDragPlane = true;
    // Debug mode will display drag planes to help visualize behavior
    private var _debugMode = false;
    private var _moving = false;
    /**
     *  Fires each time the attached mesh is dragged with the pointer
     *  * delta between last drag position and current drag position in world space
     *  * dragDistance along the drag axis
     *  * dragPlaneNormal normal of the current drag plane used during the drag
     *  * dragPlanePoint in world space where the drag intersects the drag plane
     *
     *  (if validatedDrag is used, the position of the attached mesh might not equal dragPlanePoint)
     */
    public var onDragObservable:Observable<DragEventInfo> = new Observable<DragEventInfo>();
    
    /**
     *  Fires each time a drag begins (eg. mouse down on mesh)
     *  * dragPlanePoint in world space where the drag intersects the drag plane
     *
     *  (if validatedDrag is used, the position of the attached mesh might not equal dragPlanePoint)
     */
    public var onDragStartObservable:Observable<DragEventInfo> = new Observable<DragEventInfo>();

    /**
     *  Fires each time a drag ends (eg. mouse release after drag)
     *  * dragPlanePoint in world space where the drag intersects the drag plane
     *
     *  (if validatedDrag is used, the position of the attached mesh might not equal dragPlanePoint)
     */
    
    public var onDragEndObservable = new Observable<DragEventInfo>();
    /**
     *  Fires each time behavior enabled state changes
     */
    public var onEnabledObservable = new Observable<Bool>();

    /**
     *  If the attached mesh should be moved when dragged
     */
    public var moveAttached = true;

    /**
     *  If the drag behavior will react to drag events (Default: true)
     */
    public var enabled(get,set): Bool;
	public var name(get, never):String;

    
    public function set_enabled(value: Bool) {
        if (value != this._enabled) {
            this.onEnabledObservable.notifyObservers(value);
        }
        this._enabled = value;
        return value;
    }

    public function get_enabled() : Bool {
        return this._enabled;
    }
    private var _enabled = true;

    /**
     * If pointer events should start and release the drag (Default: true)
     */
    public var startAndReleaseDragOnPointerEvents = true;
    /**
     * If camera controls should be detached during the drag
     */
    public var detachCameraControls = true;

    /**
     * If set, the drag plane/axis will be rotated based on the attached mesh's world rotation (Default: true)
     */
    public var useObjectOrientationForDragging = true;

    private var _options: DragOptions;

    /**
     * Gets the options used by the behavior
     */
    public var options(get,set): DragOptions;

    public function get_options(): DragOptions {
        return this._options;
    }

    /**
     * Sets the options used by the behavior
     */
    public function set_options(options:DragOptions) {
        this._options = options;
        return options;
    }

    /**
     * Creates a pointer drag behavior that can be attached to a mesh
     * @param options The drag axis or normal of the plane that will be dragged across. If no options are specified the drag plane will always face the ray's origin (eg. camera)
     * @param options.dragAxis
     * @param options.dragPlaneNormal
     */
    function new(options: DragOptions) {
        this._options = options != null ? options : { dragAxis: null, dragPlaneNormal: null };

        var optionCount = 0;
        if (this._options.dragAxis != null) {
            optionCount++;
        }
        if (this._options.dragPlaneNormal != null) {
            optionCount++;
        }
        if (optionCount > 1) {
            // eslint-disable-next-line no-throw-literal
            throw "Multiple drag modes specified in dragBehavior options. Only one expected";
        }
    }

    /**
     * Predicate to determine if it is valid to move the object to a new position when it is moved.
     * In the case of rotation gizmo, target contains the angle.
     * @param target destination position or desired angle delta
     * @returns boolean for whether or not it is valid to move
     */
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    public function validateDrag(target: Vector3) : Bool
    {
        return true;
    }

    // public validateDrag = (target: Vector3) -> {
    //     return true;
    // };
       

    /**
     *  The name of the behavior
     */
    inline private function get_name(): String {
        return "PointerDrag";
    }

    /**
     *  Initializes the behavior
     */
    public function init() {}

    private var _tmpVector = new Vector3(0, 0, 0);
    private var _alternatePickedPoint = new Vector3(0, 0, 0);
    private var _worldDragAxis = new Vector3(0, 0, 0);
    private var _targetPosition = new Vector3(0, 0, 0);
    private var _attachedToElement: Bool = false;
    /**
     * Attaches the drag behavior to the passed in mesh
     * @param ownerNode The mesh that will be dragged around once attached
     * @param predicate Predicate to use for pick filtering
     */
    //public function attach(ownerNode: AbstractMesh, ?predicate:AbstractMesh -> Bool): Void {
    public function attach(ownerNode: AbstractMesh): Void {
        this._scene = ownerNode.getScene();
        //CL - removed
        //ownerNode.isNearGrabbable = true;
        this.attachedNode = ownerNode;

        // Initialize drag plane to not interfere with existing scene
        if (PointerDragBehavior._PlaneScene != null) {
            if (this._debugMode) {
                PointerDragBehavior._PlaneScene = this._scene;
            } else {
                PointerDragBehavior._PlaneScene = new Scene(this._scene.getEngine(), { virtual: true });
                PointerDragBehavior._PlaneScene.detachControl();
                //CL 
                //this._scene.onDisposeObservable.addOnce(() => {
                this._scene.onDisposeObservable.add(function(_,_) {
                    PointerDragBehavior._PlaneScene.dispose();
                    PointerDragBehavior._PlaneScene = null;
                });
            }
        }

        var sideOrientation = 2; //= Mesh.DOUBLESIDE;

        this._dragPlane = Mesh.CreatePlane(
            "pointerDragPlane",
            this._debugMode ? 1 : 10000, 
            PointerDragBehavior._PlaneScene, 
            false, 
            sideOrientation
        );

        // State of the drag
        this.lastDragPosition = new Vector3(0, 0, 0);

        // final pickPredicate = predicate != null ? predicate 
        //     : function(m: AbstractMesh) {
        //         return this.attachedNode == m || m.isDescendantOf(this.attachedNode);
        //     };

        final pickPredicate = function(m: AbstractMesh) {
                return this.attachedNode == m || m.isDescendantOf(this.attachedNode);
        };

        this._pointerObserver = this._scene.onPointerObservable.add(function(pointerInfo, _) {
            if (!this.enabled) {
                // If behavior is disabled before releaseDrag is ever called, call it now.
                if (this._attachedToElement) {
                    this.releaseDrag();
                }

                return;
            }

            if (pointerInfo.type == PointerEventTypes.POINTERDOWN) {
                if (
                    this.startAndReleaseDragOnPointerEvents &&
                    !this.dragging &&
                    pointerInfo.pickInfo != null &&
                    pointerInfo.pickInfo.hit != null &&
                    pointerInfo.pickInfo.pickedMesh != null &&
                    pointerInfo.pickInfo.pickedPoint != null &&
                    pointerInfo.pickInfo.ray != null &&
                    pickPredicate(pointerInfo.pickInfo.pickedMesh)
                ) {
                    if (this._activeDragButton == -1 && this.dragButtons.indexOf(pointerInfo.event.button) != -1) {
                        this._activeDragButton = pointerInfo.event.button;
                        this._activePointerInfo = pointerInfo;
                        //CL
                        this._startDrag(cast(pointerInfo.event, PointerEvent).pointerId, pointerInfo.pickInfo.ray, pointerInfo.pickInfo.pickedPoint);
                    }
                }
            } else if (pointerInfo.type == PointerEventTypes.POINTERUP) {
                if (
                    this.startAndReleaseDragOnPointerEvents &&
                    this.currentDraggingPointerId == cast(pointerInfo.event, PointerEvent).pointerId &&
                    (this._activeDragButton == pointerInfo.event.button || this._activeDragButton == -1)
                ) {
                    this.releaseDrag();
                }
            } else if (pointerInfo.type == PointerEventTypes.POINTERMOVE) {
                final pointerId = cast(pointerInfo.event, PointerEvent).pointerId;

                // If drag was started with anyMouseID specified, set pointerID to the next mouse that moved
                if (this.currentDraggingPointerId == PointerDragBehavior._AnyMouseId && pointerId != PointerDragBehavior._AnyMouseId) {
                    final evt = cast(pointerInfo.event, PointerEvent);
                    //CL - needs investigation
                    //final isMouseEvent = evt.pointerType == "mouse" || (!this._scene.getEngine().hostInformation.isMobile && Std.isOfType(evt, MouseEvent));
                    final isMouseEvent = evt.pointerType == "mouse"; // || Std.isOfType(evt, MouseEvent));
                    if (isMouseEvent) {
                        if (this._lastPointerRay[this.currentDraggingPointerId] != null) {
                            this._lastPointerRay[pointerId] = this._lastPointerRay[this.currentDraggingPointerId];
                            //CL 
                            this._lastPointerRay.remove(this.currentDraggingPointerId);
                            //delete this._lastPointerRay[this.currentDraggingPointerId];
                        }
                        this.currentDraggingPointerId = pointerId;
                    }
                }

                // Keep track of last pointer ray, this is used simulating the start of a drag in startDrag()
                if (this._lastPointerRay[pointerId] == null) {
                    this._lastPointerRay[pointerId] = new Ray(new Vector3(), new Vector3());
                }
                if (pointerInfo.pickInfo != null && pointerInfo.pickInfo.ray != null) {
                    this._lastPointerRay[pointerId].origin.copyFrom(pointerInfo.pickInfo.ray.origin);
                    this._lastPointerRay[pointerId].direction.copyFrom(pointerInfo.pickInfo.ray.direction);

                    if (this.currentDraggingPointerId == pointerId && this.dragging) {
                        this._moveDrag(pointerInfo.pickInfo.ray);
                    }
                }
            }
        });

        this._beforeRenderObserver = this._scene.onBeforeRenderObservable.add(function(_, _) {
            if (this._moving && this.moveAttached) {
                var needMatrixUpdate = false;
                PivotTools._RemoveAndStorePivotPoint(this.attachedNode);
                // Slowly move mesh to avoid jitter
                this._targetPosition.subtractToRef(this.attachedNode.absolutePosition, this._tmpVector);
                this._tmpVector.scaleInPlace(this.dragDeltaRatio);
                this.attachedNode.getAbsolutePosition().addToRef(this._tmpVector, this._tmpVector);
                if (this.validateDrag(this._tmpVector)) {
                    this.attachedNode.setAbsolutePosition(this._tmpVector);
                    needMatrixUpdate = true;
                }
                PivotTools._RestorePivotPoint(this.attachedNode);
                if (needMatrixUpdate) {
                    this.attachedNode.computeWorldMatrix();
                }
            }
        });
    }

    /**
     * Force release the drag action by code.
     */
    public function releaseDrag() {
        if (this.dragging) {
            this.dragging = false;
            this.onDragEndObservable.notifyObservers(
                { dragPlanePoint: this.lastDragPosition, pointerId: Std.int(this.currentDraggingPointerId), pointerInfo: this._activePointerInfo, dragPlaneNormal: null, dragDistance: 0, delta: Vector3.Zero() }
            );
        }

        this.currentDraggingPointerId = -1;
        this._activeDragButton = -1;
        this._activePointerInfo = null;
        this._moving = false;

        // Reattach camera controls
        if (this.detachCameraControls && this._attachedToElement && this._scene.activeCamera != null && this._scene.activeCamera.leftCamera == null) {
            if (this._scene.activeCamera.getClassName() == "ArcRotateCamera") {
                var arcRotateCamera = cast(this._scene.activeCamera, ArcRotateCamera);
                // arcRotateCamera.attachControl(
                //     arcRotateCamera.inputs != null ? arcRotateCamera.inputs.noPreventDefault : true,
                //     arcRotateCamera._useCtrlForPanning,
                //     arcRotateCamera._panningMouseButton
                // );
                arcRotateCamera.attachControl();
            } else {
                //this._scene.activeCamera.attachControl(this._scene.activeCamera.inputs ? this._scene.activeCamera.inputs.noPreventDefault : true);
                this._scene.activeCamera.attachControl();
            }
            this._attachedToElement = false;
        }
    }

    private var _startDragRay = new Ray(new Vector3(), new Vector3());
    //private var _lastPointerRay: { [key: Float]: Ray } = {};
    private var _lastPointerRay: Map<Float, Ray> = new Map<Float, Ray>();

    /**
     * Simulates the start of a pointer drag event on the behavior
     * @param pointerId pointerID of the pointer that should be simulated (Default: Any mouse pointer ID)
     * @param fromRay initial ray of the pointer to be simulated (Default: Ray from camera to attached mesh)
     * @param startPickedPoint picked point of the pointer to be simulated (Default: attached mesh position)
     */
    public function startDrag(pointerId: Int, ?fromRay: Ray, ?startPickedPoint: Vector3) {
        this._startDrag(pointerId, fromRay, startPickedPoint);

        var lastRay = this._lastPointerRay[pointerId];
        if (pointerId == PointerDragBehavior._AnyMouseId) {
            //lastRay = this._lastPointerRay[<any>Object.keys(this._lastPointerRay)[0]];
            //lastRay = this._lastPointerRay.get(this._lastPointerRay.keys()[0]);
            lastRay = this._lastPointerRay.iterator().next();
        }

        if (lastRay != null) {
            // if there was a last pointer ray drag the object there
            this._moveDrag(lastRay);
        }
    }

    private function _startDrag(pointerId: Float, ?fromRay: Ray, ?startPickedPoint: Vector3) {
        if (this._scene.activeCamera == null || this.dragging || this.attachedNode == null) {
            return;
        }

        PivotTools._RemoveAndStorePivotPoint(this.attachedNode);
        // Create start ray from the camera to the object
        if (fromRay != null) {
            this._startDragRay.direction.copyFrom(fromRay.direction);
            this._startDragRay.origin.copyFrom(fromRay.origin);
        } else {
            this._startDragRay.origin.copyFrom(this._scene.activeCamera.position);
            this.attachedNode.getWorldMatrix().getTranslationToRef(this._tmpVector);
            this._tmpVector.subtractToRef(this._scene.activeCamera.position, this._startDragRay.direction);
        }

        this._updateDragPlanePosition(this._startDragRay, startPickedPoint != null ? startPickedPoint : this._tmpVector);

        final pickedPoint = this._pickWithRayOnDragPlane(this._startDragRay);
        if (pickedPoint != null) {
            this.dragging = true;
            this.currentDraggingPointerId = pointerId;
            this.lastDragPosition.copyFrom(pickedPoint);
            this.onDragStartObservable.notifyObservers({ dragPlanePoint: pickedPoint, pointerId: Std.int(this.currentDraggingPointerId), pointerInfo: this._activePointerInfo, dragPlaneNormal: null, dragDistance: 0, delta: Vector3.Zero() });
            this._targetPosition.copyFrom(this.attachedNode.getAbsolutePosition());

            // Detatch camera controls
            if (this.detachCameraControls && this._scene.activeCamera != null && this._scene.activeCamera.inputs != null && this._scene.activeCamera.leftCamera == null) {
                //CL This functionality didn't exist on CameraInputsManager so I commented it out here. 
                //if (this._scene.activeCamera.inputs.attachedToElement != null) {
                //    this._scene.activeCamera.detachControl();
                //    this._attachedToElement = true;
                //} else {
                    this._attachedToElement = false;
                //}
            }
        } else {
            this.releaseDrag();
        }
        PivotTools._RestorePivotPoint(this.attachedNode);
    }

    private var _dragDelta = new Vector3();
    private function _moveDrag(ray: Ray) {
        this._moving = true;
        var pickedPoint = this._pickWithRayOnDragPlane(ray);

        if (pickedPoint != null) {
            PivotTools._RemoveAndStorePivotPoint(this.attachedNode);

            if (this.updateDragPlane) {
                this._updateDragPlanePosition(ray, pickedPoint);
            }
            var dragLength:Float = 0;
            // depending on the drag mode option drag accordingly
            if (this._options.dragAxis != null) {
                // Convert local drag axis to world if useObjectOrientationForDragging
                this.useObjectOrientationForDragging
                    ? Vector3.TransformCoordinatesToRef(this._options.dragAxis, this.attachedNode.getWorldMatrix().getRotationMatrix(), this._worldDragAxis)
                    : this._worldDragAxis.copyFrom(this._options.dragAxis);

                // Project delta drag from the drag plane onto the drag axis
                pickedPoint.subtractToRef(this.lastDragPosition, this._tmpVector);
                dragLength = Vector3.Dot(this._tmpVector, this._worldDragAxis);
                this._worldDragAxis.scaleToRef(dragLength, this._dragDelta);
            } else {
                dragLength = this._dragDelta.length();
                pickedPoint.subtractToRef(this.lastDragPosition, this._dragDelta);
            }
            this._targetPosition.addInPlace(this._dragDelta);
            this.onDragObservable.notifyObservers({
                dragDistance: dragLength,
                delta: this._dragDelta,
                dragPlanePoint: pickedPoint,
                dragPlaneNormal: this._dragPlane.forward,
                pointerId: Std.int(this.currentDraggingPointerId),
                pointerInfo: this._activePointerInfo,
            });
            this.lastDragPosition.copyFrom(pickedPoint);

            PivotTools._RestorePivotPoint(this.attachedNode);
        }
    }

    private function _pickWithRayOnDragPlane(ray: Ray) {
        if (ray == null) {
            return null;
        }

        // Calculate angle between plane normal and ray
        var angle = Math.acos(Vector3.Dot(this._dragPlane.forward, ray.direction));
        // Correct if ray is casted from oposite side
        if (angle > Math.PI / 2) {
            angle = Math.PI - angle;
        }

        // If the angle is too perpendicular to the plane pick another point on the plane where it is looking
        if (this.maxDragAngle > 0 && angle > this.maxDragAngle) {
            if (this._useAlternatePickedPointAboveMaxDragAngle) {
                // Invert ray direction along the towards object axis
                this._tmpVector.copyFrom(ray.direction);
                this.attachedNode.absolutePosition.subtractToRef(ray.origin, this._alternatePickedPoint);
                this._alternatePickedPoint.normalize();
                this._alternatePickedPoint.scaleInPlace(this._useAlternatePickedPointAboveMaxDragAngleDragSpeed * Vector3.Dot(this._alternatePickedPoint, this._tmpVector));
                this._tmpVector.addInPlace(this._alternatePickedPoint);

                // Project resulting vector onto the drag plane and add it to the attached nodes absolute position to get a picked point
                final dot = Vector3.Dot(this._dragPlane.forward, this._tmpVector);
                this._dragPlane.forward.scaleToRef(-dot, this._alternatePickedPoint);
                this._alternatePickedPoint.addInPlace(this._tmpVector);
                this._alternatePickedPoint.addInPlace(this.attachedNode.absolutePosition);
                return this._alternatePickedPoint;
            } else {
                return null;
            }
        }

        // use an infinite plane instead of ray picking a mesh that must be updated every frame
        final planeNormal = this._dragPlane.forward;
        final planePosition = this._dragPlane.position;
        //Vector3.Dot()
        final dotProduct = ray.direction.dot(planeNormal);
        if (Math.abs(dotProduct) < Tools.Epsilon) {
            // Ray and plane are parallel, no intersection
            return null;
        }
        planePosition.subtractToRef(ray.origin, Tmp.vector3[0]);
        final t = Tmp.vector3[0].dot(planeNormal) / dotProduct;
        // Ensure the intersection point is in front of the ray (t must be positive)
        if (t < 0) {
            // Intersection point is behind the ray
            return null;
        }

        // Calculate the intersection point using the parameter t
        ray.direction.scaleToRef(t, Tmp.vector3[0]);
        final intersectionPoint = ray.origin.add(Tmp.vector3[0]);
        return intersectionPoint;
    }

    // Variables to avoid instantiation in the below method
    private var _pointA = new Vector3(0, 0, 0);
    private var _pointC = new Vector3(0, 0, 0);
    private var _localAxis = new Vector3(0, 0, 0);
    private var _lookAt = new Vector3(0, 0, 0);
    // Position the drag plane based on the attached mesh position, for single axis rotate the plane along the axis to face the camera
    private function _updateDragPlanePosition(ray: Ray, dragPlanePosition: Vector3) {
        this._pointA.copyFrom(dragPlanePosition);
        if (this._options.dragAxis != null) {
            this.useObjectOrientationForDragging
                ? Vector3.TransformCoordinatesToRef(this._options.dragAxis, this.attachedNode.getWorldMatrix().getRotationMatrix(), this._localAxis)
                : this._localAxis.copyFrom(this._options.dragAxis);

            // Calculate plane normal that is the cross product of local axis and (eye-dragPlanePosition)
            ray.origin.subtractToRef(this._pointA, this._pointC);
            this._pointC.normalize();
            if (Math.abs(Vector3.Dot(this._localAxis, this._pointC)) > 0.999) {
                // the drag axis is colinear with the (eye to position) ray. The cross product will give jittered values.
                // A new axis vector need to be computed
                //CL - UpReadOnly? if (Math.abs(Vector3.Dot(Vector3.UpReadOnly, this._pointC)) > 0.999) {
                if (Math.abs(Vector3.Dot(Vector3.Up(), this._pointC)) > 0.999) {
                    this._lookAt.copyFrom(Vector3.Right());
                } else {
                    this._lookAt.copyFrom(Vector3.Up());
                }
            } else {
                Vector3.CrossToRef(this._localAxis, this._pointC, this._lookAt);
                // Get perpendicular line from previous result and drag axis to adjust lineB to be perpendicular to camera
                Vector3.CrossToRef(this._localAxis, this._lookAt, this._lookAt);
                this._lookAt.normalize();
            }

            this._dragPlane.position.copyFrom(this._pointA);
            this._pointA.addToRef(this._lookAt, this._lookAt);
            this._dragPlane.lookAt(this._lookAt);
        } else if (this._options.dragPlaneNormal != null) {
            this.useObjectOrientationForDragging
                ? Vector3.TransformCoordinatesToRef(this._options.dragPlaneNormal, this.attachedNode.getWorldMatrix().getRotationMatrix(), this._localAxis)
                : this._localAxis.copyFrom(this._options.dragPlaneNormal);
            this._dragPlane.position.copyFrom(this._pointA);
            this._pointA.addToRef(this._localAxis, this._lookAt);
            this._dragPlane.lookAt(this._lookAt);
        } else {
            this._dragPlane.position.copyFrom(this._pointA);
            this._dragPlane.lookAt(ray.origin);
        }
        // Update the position of the drag plane so it doesn't get out of sync with the node (eg. when moving back and forth quickly)
        this._dragPlane.position.copyFrom(this.attachedNode.getAbsolutePosition());

        this._dragPlane.computeWorldMatrix(true);
    }

    /**
        
     *  Detaches the behavior from the mesh
     */
    public function detach() : Void {
        this._lastPointerRay = new Map();

        //CL - isNearGrabbable? 
        //if (this.attachedNode != null) {
        //    this.attachedNode.isNearGrabbable = false;
        //}
        if (this._pointerObserver != null) {
            this._scene.onPointerObservable.remove(this._pointerObserver);
        }
        if (this._beforeRenderObserver != null) {
            this._scene.onBeforeRenderObservable.remove(this._beforeRenderObserver);
        }
        if (this._dragPlane != null) {
            this._dragPlane.dispose();
        }
        this.releaseDrag();
    }
}