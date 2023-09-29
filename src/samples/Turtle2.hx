package samples;

import com.babylonhx.engine.EngineCapabilities.WEBGL_compressed_texture_s3tc;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.cameras.FreeCamera;
import haxe.iterators.StringIterator;
import com.babylonhx.states._AlphaState;
import com.babylonhx.math.Space;
import com.babylonhx.math.Angle;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.TransformNode;
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
 * @author Krtolica Vujadin
 */
class Turtle2 {

    private var _currentTransform: TransformNode = null;
    private var _points:Array<Vector3> = [];
    private var _transformsStack:Array<TransformNode> = [];
    private var _branchCounter:Int = 1;
    private var _scene:Scene = null;
    private var _colorsStack:Array<Color3> = [];
    var _keysDown:Map<Int, Bool> = new Map();
    var _turnRadius:Float = 90;
    var _distance:Float = 10;
    var _system:String = "";
    var _meshes:Array<Mesh> = [];
    var _keysHandled:Map<Int, Bool> = new Map();

	public function new(scene:Scene) {

        _scene = scene;

		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
        //var camera = new FreeCamera("Camera", new Vector3(20, 30, -100), scene);
		camera.setPosition(new Vector3(0, 0, 400));
		camera.attachControl();
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
	
        scene.getEngine().keyDown.push(function(keyCode:Int) {
			_keysDown[keyCode] = true;
		});
		scene.getEngine().keyUp.push(function(keyCode:Int) {
            _keysDown[keyCode] = false;
            _keysHandled[keyCode] = false;
		});
		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            //check state of keys, update the turtle string
            var anyChanged:Bool = false;
            
            if(_keysDown[Keycodes.key_w] && !_keysHandled[Keycodes.key_w]) {
                //move forward
                _system += "F";
                anyChanged = true;
                _keysHandled[Keycodes.key_w] = true;
            }

            if(_keysDown[Keycodes.key_s] && !_keysHandled[Keycodes.key_s]) {
                //erase last move;
                _system = _system.substr(0, _system.length - 2);
                anyChanged = true;
                _keysHandled[Keycodes.key_s] = true;
            }

            if(_keysDown[Keycodes.key_d] && !_keysHandled[Keycodes.key_d]) {
                _system += "+";
                anyChanged = true;
                _keysHandled[Keycodes.key_d] = true;
            }

            if(_keysDown[Keycodes.key_a] && !_keysHandled[Keycodes.key_a]) {
                _system += "-";
                anyChanged = true;
                _keysHandled[Keycodes.key_a] = true;
            }

            if(anyChanged) {

                beginSystem();

                //loop through the characters, does not validate begin and end branches yet
                for(i in 0..._system.length) {
                    var item = _system.charAt(i);

                    if(item == "F") {
                        forward(_distance);
                    } else if(item == "+") {
                        right(_turnRadius);
                    } else if(item == "-") {
                        left(_turnRadius);
                    } else if(item == "/") {
                        rollCounterClockwise(_turnRadius);
                    } else if(item == "\\") {
                        rollClockwise(_turnRadius);
                    } else if(item == "&") {
                        pitchUp(_turnRadius);
                    } else if(item == "^") {
                        pitchDown(_turnRadius);
                    }
                    else if(item == "[") {
                        beginBranch();
                    }
                    else if(item == "]") {
                        endBranch();
                    }
                    else if(item == "X" || item == "A") {
                        //no op
                    } else {
                        //everything else is interpetted as forward
                        forward(_distance);
                    }
                }

                endSystem();   

            }
        });
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}

    public function rollClockwise(degrees:Float) {
        _currentTransform.rotate(Axis.X, Angle.FromDegrees(degrees).radians(), Space.LOCAL);
    }

    public function rollCounterClockwise(degrees:Float) {
        _currentTransform.rotate(Axis.X, Angle.FromDegrees(degrees * -1).radians(), Space.LOCAL);
    }

    public function pitchUp(degrees:Float) {
        _currentTransform.rotate(Axis.Y, Angle.FromDegrees(degrees).radians(), Space.LOCAL);
    }

    public function pitchDown(degrees:Float) {
        _currentTransform.rotate(Axis.Y, Angle.FromDegrees(degrees * -1).radians(), Space.LOCAL);
    }

    public function right(degrees:Float) {
        _currentTransform.rotate(Axis.Z, Angle.FromDegrees(degrees).radians(), Space.LOCAL);
    }
	
	public function left(degrees:Float) {
        _currentTransform.rotate(Axis.Z, Angle.FromDegrees(degrees * -1).radians(), Space.LOCAL);
    }

    public function forward(amount:Float) {
        _currentTransform.translate(Axis.X, amount, Space.LOCAL);
        _points.push(_currentTransform.position);
    }
    
    public function beginBranch() {
        
        //create a copy of current transform
        var tempTfm = new TransformNode("tfm" + _branchCounter); 
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        

        _transformsStack.push(tempTfm); //push our current transform on the stack so we can revert it in endBranch

        //trace("beginBranch position " + tempTfm.position + " rotation " + tempTfm.rotationQuaternion);

        _branchCounter++;

        //create a new temp transform, copy position and rotation from current transform and set _tfm 
        tempTfm = new TransformNode("tfm" + _branchCounter); 
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        
        
        _currentTransform = tempTfm;

        var color:Color3 = Color3.White();
        _colorsStack.push(color);
    }

    public function endBranch() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _points = [];
        _currentTransform = _transformsStack.pop(); //pop the previous position back off the stack

        //trace("endBranch position " + _currentTransform.position + " rotation " + _currentTransform.rotationQuaternion);

        _points.push(_currentTransform.position); //current position as our starting point
        _meshes.push(mesh);
    }

    public function beginSystem() {

        //destroy current mesh and rebuild from scratch
        for(mesh in _meshes) {
            mesh.dispose();
        }

        _meshes = [];
        _points = [];
        _colorsStack = [];
        _transformsStack = [];

        if(_currentTransform != null) {
            _currentTransform.dispose();
        }

        _currentTransform = new TransformNode("tfm", _scene, true);
        right(90); //starts us pointing upwards
        _points.push(_currentTransform.position);
        _colorsStack.push(Color3.White()); //not yet supported but this is for color changing
    }

    public function endSystem() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _meshes.push(mesh);
    }

    
}
