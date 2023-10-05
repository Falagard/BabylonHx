package samples;

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
 * @author Clay Larabie
 */
class LSystem {

    private var _currentTransform: TransformNode = null;
    private var _points:Array<Vector3> = [];
    private var _transformsStack:Array<TransformNode> = [];
    private var _branchCounter:Int = 1;
    private var _scene:Scene = null;
    private var _colorsStack:Array<Color3> = [];
    
    //meshes used and that need to be disposed when regenerating
    var _meshes:Array<Mesh> = [];

    //l-system values
    var _turnRadius:Float = 45; 
    var _distance:Float = 10;
    var _iterations:Int = 0;
    var _axiom:String = ""; //the start value of the l-system
    var _rules:Array<String> = [];
    var _system:String = ""; //the final l-system 

    //input handling
    var _keysDown:Map<Int, Bool> = new Map();
    var _keysHandled:Map<Int, Bool> = new Map();
    var _elapsedTime:Float = 0;
    
	public function new(scene:Scene) {

        _scene = scene;

		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
        
		camera.setPosition(new Vector3(0, 0, 400));
		camera.attachControl();
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);

        //input handling 
        scene.getEngine().keyDown.push(function(keyCode:Int) {
			_keysDown[keyCode] = true;
		});
		scene.getEngine().keyUp.push(function(keyCode:Int) {
            _keysDown[keyCode] = false;
            _keysHandled[keyCode] = false;
		});

        scene.getEngine().keyDown.push(function(keyCode:Int) {
			_keysDown[keyCode] = true;
		});
		scene.getEngine().keyUp.push(function(keyCode:Int) {
            _keysDown[keyCode] = false;
            _keysHandled[keyCode] = false;
		});
		
        //our update loop, before rendering 
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            //check state of keys, update the turtle string
            var anyChanged:Bool = false;

            var dt = scene.getEngine().getDeltaTime();
            _elapsedTime += dt;

            //if enough time has elapsed, set the _keysHandled to false so they'll re-trigger
            if(_elapsedTime > 300) {
                _keysHandled = new Map();
            }

            //check which key is hit and change the L-system values appropriately
            
            //basic 
            if(!_keysDown[Keycodes.lshift])
            {
                if(_keysDown[Keycodes.key_1] && !_keysHandled[Keycodes.key_1]) {
                    anyChanged = true;
                    _turnRadius = 45;
                    _distance = 10;
                    _iterations = 0;
                    _axiom = "F+F+F+F+F+F+F+F";
                    _rules = [];
                    _keysHandled[Keycodes.key_1] = true;
                }
                //basic with branching
                else if(_keysDown[Keycodes.key_2] && !_keysHandled[Keycodes.key_2]) {
                    anyChanged = true;
                    _turnRadius = 45;
                    _distance = 10;
                    _iterations = 0;
                    _axiom = "F+[F+F]-F-F[F+F]-F-F";
                    _rules = [];
                    _keysHandled[Keycodes.key_1] = true;
                }
                //diamond
                else if(_keysDown[Keycodes.key_3] && !_keysHandled[Keycodes.key_3]) {
                    anyChanged = true;
                    _turnRadius = 60;
                    _distance = 2;
                    _iterations = 3;
                    _axiom = "F";
                    _rules = [];
                    _rules.push("F=FF++F++F+F++F-F");
                    _keysHandled[Keycodes.key_3] = true;
                }
                //koch
                else if(_keysDown[Keycodes.key_4] && !_keysHandled[Keycodes.key_4]) {
                    anyChanged = true;
                    _turnRadius = 90;
                    _distance = 2;
                    _iterations = 2;
                    _axiom = "F-F-F-F";
                    _rules = [];
                    _rules.push("F=F+FF-FF-F-F+F+FF-F-F+F+FF+FF-F");
                    _keysHandled[Keycodes.key_4] = true;
                }
                //quadratic snowflake
                // else if(_keysDown[Keycodes.key_5] && !_keysHandled[Keycodes.key_5]) {
                //     anyChanged = true;
                //     _turnRadius = 90;
                //     _distance = 5;
                //     _iterations = 4;
                //     _axiom = "-F";
                //     _rules = [];
                //     _rules.push("F=F+F-F-F+F");
                //     _keysHandled[Keycodes.key_5] = true;
                // }
                //koch snowflake
                else if(_keysDown[Keycodes.key_5] && !_keysHandled[Keycodes.key_5]) {
                    anyChanged = true;
                    _turnRadius = 60;
                    _distance = 5;
                    _iterations = 3;
                    _axiom = "F--F--F";
                    _rules = [];
                    _rules.push("F=F+F--F+F");
                    _keysHandled[Keycodes.key_5] = true;
                }
                //koch curve a
                else if(_keysDown[Keycodes.key_6] && !_keysHandled[Keycodes.key_6]) {
                    anyChanged = true;
                    _turnRadius = 90;
                    _distance = 5;
                    _iterations = 3;
                    _axiom = "F-F-F-F";
                    _rules = [];
                    _rules.push("F=FF-F-F-F-F-F+F");
                    _keysHandled[Keycodes.key_6] = true;
                }
                //koch curve b
                else if(_keysDown[Keycodes.key_7] && !_keysHandled[Keycodes.key_7]) {
                    anyChanged = true;
                    _turnRadius = 90;
                    _distance = 5;
                    _iterations = 3;
                    _axiom = "F-F-F-F";
                    _rules = [];
                    _rules.push("F=FF-F-F-F-FF");
                    _keysHandled[Keycodes.key_7] = true;
                }
                //tree 
                else if(_keysDown[Keycodes.key_8] && !_keysHandled[Keycodes.key_8]) {
                    anyChanged = true;
                    _turnRadius = 25;
                    _distance = 10;
                    _iterations = 2;
                    _axiom = "F";
                    _rules = [];
                    _rules.push("F=F[-F][+F]");
                    _keysHandled[Keycodes.key_8] = true;
                }
                //tree with no-op X value 
                else if(_keysDown[Keycodes.key_9] && !_keysHandled[Keycodes.key_9]) {
                    anyChanged = true;
                    _turnRadius = 25;
                    _distance = 10;
                    _iterations = 3;
                    _axiom = "X";
                    _rules = [];
                    _rules.push("F=FF");
                    _rules.push("X=F[+F][---X]+F-F[++++X]-X");
                    _keysHandled[Keycodes.key_9] = true;
                }
                //branching structures a
                else if(_keysDown[Keycodes.key_0] && !_keysHandled[Keycodes.key_0]) {
                    anyChanged = true;
                    _turnRadius = 20;
                    _distance = 10;
                    _iterations = 3;
                    _axiom = "F";
                    _rules = [];
                    _rules.push("F=F[+F]F[-F]F");
                    _keysHandled[Keycodes.key_0] = true;
                }
                else if(_keysDown[Keycodes.equals] && !_keysHandled[Keycodes.equals] && _system != "") {
                    anyChanged = true;
                    _iterations++;
                    _keysHandled[Keycodes.equals] = true;
                }
                else if(_keysDown[Keycodes.minus] && !_keysHandled[Keycodes.minus] && _system != "") {
                    anyChanged = true;
                    _iterations--;
                    _keysHandled[Keycodes.minus] = true;
                }
            } else {
                //shift is held down

                //first 3d tree with pitch and roll
                if(_keysDown[Keycodes.key_1] && !_keysHandled[Keycodes.key_1]) {
                    anyChanged = true;
                    _turnRadius = 28;
                    _distance = 5;
                    _iterations = 4;
                    _axiom = "FFFA";
                    _rules = [];
                    _rules.push("A=[B]////[B]////[B]");
                    _rules.push("B=&FFFA");
                    _keysHandled[Keycodes.key_1] = true;
                }
            }

            if(anyChanged) {

                //generate the system using the starting axiom and rules
                _system = _axiom;

                for(i in 0..._iterations) {
                    for(rule in _rules) {
                        var equalsIdx = rule.indexOf("=");
                        //parse the rule into before colon and after colon
                        var source = rule.substring(0, equalsIdx);
                        var dest = rule.substring(equalsIdx + 1, rule.length);

                        _system = StringTools.replace(_system, source, dest);
                    }
                }

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

                _elapsedTime = 0;

            }
        });
		
        //the render loop
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

        _branchCounter = 0;

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
