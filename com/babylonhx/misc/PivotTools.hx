package com.babylonhx.misc;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.TransformNode;

/**
 * Class containing a set of static utilities functions for managing Pivots
 * @internal
 */
 @:expose('BABYLON.PivotTools') class PivotTools {
    // Stores the state of the pivot cache (_oldPivotPoint, _pivotTranslation)
    // store/remove pivot point should only be applied during their outermost calls
    private static var _PivotCached = 0;
    private static var _OldPivotPoint = new Vector3();
    private static var _PivotTranslation = new Vector3();
    private static var _PivotTmpVector = new Vector3();
    private static var _PivotPostMultiplyPivotMatrix = false;
    
    /**
     * @internal
     */
    public static function _RemoveAndStorePivotPoint(mesh: TransformNode) {
        if (mesh != null && PivotTools._PivotCached == 0) {
            // Save old pivot and set pivot to 0,0,0
            mesh.getPivotPointToRef(PivotTools._OldPivotPoint);
            PivotTools._PivotPostMultiplyPivotMatrix = mesh._postMultiplyPivotMatrix;
            if (!PivotTools._OldPivotPoint.equalsToFloats(0, 0, 0)) {
                mesh.setPivotMatrix(Matrix.IdentityReadOnly);
                PivotTools._OldPivotPoint.subtractToRef(mesh.getPivotPoint(), PivotTools._PivotTranslation);
                PivotTools._PivotTmpVector.copyFromFloats(1, 1, 1);
                PivotTools._PivotTmpVector.subtractInPlace(mesh.scaling);
                PivotTools._PivotTmpVector.multiplyInPlace(PivotTools._PivotTranslation);
                mesh.position.addInPlace(PivotTools._PivotTmpVector);
            }
        }
        PivotTools._PivotCached++;
    }
    /**
     * @internal
     */
    public static function _RestorePivotPoint(mesh: TransformNode) {
        if (mesh != null && !PivotTools._OldPivotPoint.equalsToFloats(0, 0, 0) && PivotTools._PivotCached == 1) {
            mesh.setPivotPoint(PivotTools._OldPivotPoint);
            mesh._postMultiplyPivotMatrix = PivotTools._PivotPostMultiplyPivotMatrix;
            PivotTools._PivotTmpVector.copyFromFloats(1, 1, 1);
            PivotTools._PivotTmpVector.subtractInPlace(mesh.scaling);
            PivotTools._PivotTmpVector.multiplyInPlace(PivotTools._PivotTranslation);
            mesh.position.subtractInPlace(PivotTools._PivotTmpVector);
        }
        _PivotCached--;
    }
}