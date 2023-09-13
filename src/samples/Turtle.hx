package samples;

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

    private var _tfm: TransformNode = null;
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
		
		//var points:Array<Vector3> = [];

        

        //todo - implement forward, right, etc. and get points to push onto stack. 
        //evaluate a string for turtle inputs
        //figure out how to do branching, probably by pushing and popping the transform into a stack, and also creating lines from the current set of points and clearing the current set of points
        //keyboard input for changing and evaluating the turtle string
        //work out the amounts for forward45 vs forward
                                
        _tfm = new TransformNode("tfm", scene, true);

        //FFF(RFF(RFF)LFF)LLFF

        var r:Float = 45;
        var f:Float = 20;
        
        right(90);
        
        forward(f);
        forward(f);
        forward(f);

        beginBranch();
        right(r);
        forward(f);
        forward(f);
        beginBranch();
        right(r);
        forward(f);
        forward(f);
        endBranch();
        left(r);
        forward(f);
        forward(f);
        endBranch();
        left(r);
        left(r);
        forward(f);
        forward(f);

        var mesh = Mesh.CreateLines("branch" + _branchCounter, _points, _scene, false);
        mesh.color = Color3.Yellow();

		// var lorenz = Mesh.CreateLines("whirlpool", points, scene, false);
		// lorenz.color = Color3.Red();
		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			//lorenz.rotation.y += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}

    public function right(degrees:Float) {
        _tfm.rotate(Axis.Z, Angle.FromDegrees(degrees).radians(), Space.LOCAL);
    }
	
	public function left(degrees:Float) {
        _tfm.rotate(Axis.Z, Angle.FromDegrees(degrees * -1).radians(), Space.LOCAL);
    }

    public function forward(amount:Float) {
        _tfm.translate(Axis.X, amount, Space.LOCAL);
        _points.push(_tfm.position);
    }
    
    public function beginBranch() {
        _branchCounter++;
        _transformsStack.push(_tfm);
        var tempTfm = new TransformNode("tfm" + _branchCounter);
        tempTfm.position = _tfm.position;
        tempTfm.rotationQuaternion = _tfm.rotationQuaternion;        
        _tfm = tempTfm;

        var color:Color3 = Color3.Red();

        if(_branchCounter % 2 == 0) {
            color = Color3.Red();
        }
        else {
            color = Color3.Blue();
        }

        _colorsStack.push(color);
    }

    public function endBranch() {
        var mesh = Mesh.CreateLines("branch", _points, _scene, false);
        mesh.color = _colorsStack.pop();
        _points = [];
        _tfm = _transformsStack.pop();
        _points.push(_tfm.position);
    }
}
