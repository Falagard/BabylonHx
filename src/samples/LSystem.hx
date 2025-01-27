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
class LSystem extends TurtleBase {

    //the number of times to iterate 
    var _iterations:Int = 0;
    //the start value of the l-system
    var _axiom:String = ""; 
    //a set of rules to apply each iteration
    //this is string replacement, where you use the syntax FIND:REPLACE 
    //for example F:FF+FF 
    var _rules:Array<String> = []; 
    
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
                    _axiom = "F[+F[+F]-F]-F";
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

                //destroy meshes
                disposeMeshes();

                //begin a new mesh 
                beginMesh();

                trace("system length:  " + _system.length);

                var previousTime = haxe.Timer.stamp();
                
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

                var currentTime = haxe.Timer.stamp();
                var deltaTime: Float = Std.int((currentTime - previousTime) * 1000); //milliseconds difference

                trace("generation took:  " + deltaTime + " milliseconds");


                //actually create the mesh
                endMesh();   

                _elapsedTime = 0;

            }
        });
		
        //the render loop
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
}
