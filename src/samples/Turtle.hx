package samples;

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
class Turtle {

    private var _currentTransform: TransformNode = null;
    private var _points:Array<Vector3> = [];
    private var _transformsStack:Array<TransformNode> = [];
    private var _branchCounter:Int = 1;
    private var _scene:Scene = null;
    private var _colorsStack:Array<Color3> = [];

	public function new(scene:Scene) {

        _scene = scene;

		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(0, 0, 400));
		camera.attachControl();
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
		
        //change logic so it's possible to change the color at any location - in which case we'll create the mesh, set the color, etc. 
        //use a state system maybe for setting color like C=1 which can be injected into the l system and do specific things like set the color. 
        //C=1FFF(C=2RFF(C=3RFF)LFF)LLFF
        //evaluate a string for turtle inputs including branching
        //attempt a simple l system using an axiom, iteration, etc. 
        //keyboard input for changing and evaluating the turtle string
        //work out the amounts for forward45 vs forward

        //Layers - if we are defining boundaries, we may want to overlap certain things such as walls, etc. so use different colors. Each of these could be considered a different layer. 
        //Layers could be visualized in 3D by changing the Z value slightly, and shown/hidden by color
        //For example, when defining a house, blue could be exterior walls, red interior walls, etc.,
        
        var r:Float = 25;
        var f:Float = 30;
        var iterations:Int = 5;

        var axiom:String = "F";

        var rules:Array<String> = [];

        rules.push("F:F[-F][+F]");

        var system:String = axiom; //"FFF[RFF[RFF]LFF]LLFF";

        for(i in 0...iterations) {
            for(rule in rules) {
                //parse the rule into before colon and after colon
                var source = rule.substring(0, rule.indexOf(":"));
                var dest = rule.substring(rule.indexOf(":") + 1, rule.length);

                system = StringTools.replace(system, source, dest);
            }
        }

        beginSystem();

        //loop through the characters, does not validate begin and end branches yet
        for(i in 0...system.length) {
            var item = system.charAt(i);

            if(item == "F") {
                forward(f);
            } else if(item == "+") {
                right(r);
            } else if(item == "-") {
                left(r);
            }
            else if(item == "[") {
                beginBranch();
            }
            else if(item == "]") {
                endBranch();
            }
        }
        
        endSystem();
		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
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
        _branchCounter++;
        _transformsStack.push(_currentTransform); //push our current transform on the stack so we can revert it in endBranch
        //create a new temp transform, copy position and rotation from current transform and set _tfm 
        var tempTfm = new TransformNode("tfm" + _branchCounter); 
        tempTfm.position = _currentTransform.position;
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion;        
        _currentTransform = tempTfm;

        var color:Color3 = Color3.White();
        _colorsStack.push(color);
    }

    public function endBranch() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _points = [];
        _currentTransform = _transformsStack.pop(); //pop the previous position back off the stack
        _points.push(_currentTransform.position); //current position as our starting point
    }

    public function beginSystem() {
        _currentTransform = new TransformNode("tfm", _scene, true);
        right(90); //starts us pointing upwards

        _colorsStack.push(Color3.White()); //not yet supported but this is for color changing
    }

    public function endSystem() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
    }
}
