package samples;

import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.engine.EngineCapabilities.WEBGL_compressed_texture_s3tc;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.cameras.FreeCamera;
import haxe.iterators.StringIterator;
import com.babylonhx.states._AlphaState;
import com.babylonhx.math.Space;
import com.babylonhx.math.Angle;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.math.Tmp;
import com.babylonhx.mesh.simplification.DecimationTriangle;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;

/**
 * ...
 * @author Clay Larabie
 */

class TurtleTransform {
    public var position:Vector3 = Vector3.Zero();
    public var rotationQuaternion:Quaternion = Quaternion.Identity();

    public function new() {
		//...
	}
}

class TurtleBase {

    private var _currentTransform: TurtleTransform = null;
    private var _points:Array<Vector3> = [];
    private var _transformsStack:Array<TurtleTransform> = [];
    private var _branchCounter:Int = 1;
    private var _scene:Scene = null;
    private var _colorsStack:Array<Color3> = [];

    var _keysDown:Map<Int, Bool> = new Map();
    var _turnRadius:Float = 90;
    var _distance:Float = 10;
    var _system:String = "";
    var _meshes:Array<Mesh> = [];
    var _keysHandled:Map<Int, Bool> = new Map();
    var _elapsedTime:Float = 0;
    var _penDown:Bool = true;

    private static var _rotationAxisCache:Quaternion = new Quaternion();
    private static var _rotationAxisTemp:Quaternion = new Quaternion();
    private static var _pivotMatrixTemp:Matrix = Matrix.Identity();
    private static var _localWorldTemp:Matrix = Matrix.Zero();
    private static var _invLocalWorldTemp:Matrix = Matrix.Zero();
    private static var _positionLocalTemp:Vector3 = Vector3.Zero();

	inline public function rollClockwise(degrees:Float) {
        rotate(Axis.X, DegreesToRadians(degrees));
    }

    inline public function rollCounterClockwise(degrees:Float) {
        rotate(Axis.X, DegreesToRadians(degrees * -1));
    }

    inline public function pitchUp(degrees:Float) {
        rotate(Axis.Y, DegreesToRadians(degrees));
    }

    inline public function pitchDown(degrees:Float) {
        rotate(Axis.Y, DegreesToRadians(degrees * -1));
    }

    inline public function right(degrees:Float) {
        rotate(Axis.Z, DegreesToRadians(degrees));
    }
	
	inline public function left(degrees:Float) {
        rotate(Axis.Z, DegreesToRadians(degrees * -1));
    }

    inline public function DegreesToRadians(degrees:Float) {
        return Math.PI / 180 * degrees;
        //Angle.FromDegrees(degrees).radians()
    }

    inline public function translate(axis:Vector3, distance:Float) {
        //this was copied out of TransformNode.translate but optimized to remove allocations and extraneous logic

        //axis scaled by distance
        axis.scaleToRef(distance, Tmp.vector3[0]);

        //scale stored in mat[1]
		Matrix.ScalingToRef(1, 1, 1, Tmp.matrix[1]);

        //quaternion to matrix stored in mat[0]
        _currentTransform.rotationQuaternion.toRotationMatrix(Tmp.matrix[0]);
        //translation to matrix stored in mat[2]
        Matrix.TranslationToRef(_currentTransform.position.x, _currentTransform.position.y, _currentTransform.position.z, Tmp.matrix[2]);
        
        //scale multiplied by pivot (identity) - stored in mat[4]
        _pivotMatrixTemp.multiplyToRef(Tmp.matrix[1], Tmp.matrix[4]);

        //pivot+scale multiplied by rotation stored in matrix 5
		Tmp.matrix[4].multiplyToRef(Tmp.matrix[0], Tmp.matrix[5]);
        //pivot+scale+rotation multiplied by position stored in _localWorldTemp
		Tmp.matrix[5].multiplyToRef(Tmp.matrix[2], _localWorldTemp);
        //invert
        _invLocalWorldTemp.copyFrom(_localWorldTemp);
		_invLocalWorldTemp.invert();
        //transform and store in positionLocalTemp
        Vector3.TransformNormalToRef(_currentTransform.position, _invLocalWorldTemp, _positionLocalTemp);
        //add axis vector 
        _positionLocalTemp.addToRef(Tmp.vector3[0], Tmp.vector3[1]);
        //set the position 
        _currentTransform.position = Vector3.TransformNormal(Tmp.vector3[1], _localWorldTemp);      
    }

    public function rotate(axis:Vector3, amount:Float) {
        //this was copied out of TransformNode.rotate 
        axis.normalize();
        
        var tempRotationQuaternion:Quaternion = Quaternion.RotationAxisToRef(axis, amount, _rotationAxisCache);
	    _currentTransform.rotationQuaternion.multiplyToRef(tempRotationQuaternion, _currentTransform.rotationQuaternion);
    }

    public function forward(amount:Float) {
        translate(Axis.X, amount);

        if(_penDown) {
            //_points.push(_currentTransform.position);
            _points.push(_currentTransform.position);
        }
    }

    inline public function penDown() {
        _penDown = true;
    }

    inline public function penUp() {
        _penDown = false;
    }
    
    inline public function beginBranch() {
        //create a copy of current transform
        //var tempTfm = new TransformNode("tfm" + _branchCounter); 
        var tempTfm = new TurtleTransform();
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        
        
        _transformsStack.push(tempTfm); //push our current transform on the stack so we can revert it in endBranch
        _branchCounter++;

        //create a new temp transform, copy position and rotation from current transform and set _tfm 
        tempTfm = new TurtleTransform();
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        
        
        _currentTransform = tempTfm;

        var color:Color3 = Color3.White();
        _colorsStack.push(color);
    }

    inline public function endBranch() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _points = [];
        _currentTransform = _transformsStack.pop(); //pop the previous position back off the stack

        if(_penDown) {
            _points.push(_currentTransform.position); //current position as our starting point
        }
        _meshes.push(mesh);
    }

    public function disposeMeshes() {
        //destroy current mesh and rebuild from scratch
        for(mesh in _meshes) {
            mesh.dispose();
        }

        _meshes = [];
        _points = [];
        _colorsStack = [];
        _transformsStack = [];

        // if(_currentTransform != null) {
        //     _currentTransform.dispose();
        // }
    }

    public function beginMesh() {
        //_currentTransform = new TransformNode("tfm", _scene, true);
        _currentTransform = new TurtleTransform();
        right(90); //starts us pointing upwards

        if(_penDown) {
            _points.push(_currentTransform.position);
        }
        _colorsStack.push(Color3.White()); //not yet supported but this is for color changing
    }

    public function endMesh() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _meshes.push(mesh);
    }
    
}
