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
 * @author Clay Larabie
 */
class Turtle extends TurtleBase {

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

        //draw a pointer mesh for the turtle direction
        penUp();
        beginMesh();
        left(180);
        forward(5);
        right(180);
        penDown();
        forward(10);
        left(120);
        forward(10);
        left(120);
        forward(10);
        left(120);
        forward(10);
        endMesh();

        //grab the current mesh so it doesn't get disposed
        var turtleMesh:Mesh = _meshes[0];
        _meshes = [];
        		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            //check state of keys, update the turtle string
            var anyChanged:Bool = false;

            var dt = scene.getEngine().getDeltaTime();
            _elapsedTime += dt;

            //if enough time has elapsed, set the _keysHandled to false so they'll re-trigger
            if(_elapsedTime > 300) {
                _keysHandled = new Map();
            }

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

                //destroy current meshes
                disposeMeshes();

                _elapsedTime = 0;

                beginMesh();

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

                endMesh();   

                turtleMesh.position = _currentTransform.position;
                turtleMesh.rotationQuaternion = _currentTransform.rotationQuaternion;
                

            }
        });
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
    }
}
