package samples;

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

	public function new(scene:Scene) {
		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
		camera.setPosition(new Vector3(0, 0, 400));
		camera.attachControl();
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);
		
		var points:Array<Vector3> = [];

        

        //todo - implement forward, right, etc. and get points to push onto stack. 
        //evaluate a string for turtle inputs
        //keyboard input for changing and evaluating the turtle string
        
        //start at 0,0,0
        var transform = new TransformNode("test", scene, true);
        //start facing up because by default we are facing right
        transform.rotate(Axis.Z, Angle.FromDegrees(90).radians(), Space.LOCAL);

        points.push(new Vector3(0, 0, 0));
               
        transform.translate(Axis.X, 100, Space.LOCAL);
        points.push(transform.position);
        
        transform.rotate(Axis.Z, Angle.FromDegrees(90).radians(), Space.LOCAL);
        transform.translate(Axis.X, 100, Space.LOCAL);
        points.push(transform.position);
                
        //transform.rotate(Axis.Z, Angle.FromDegrees(90).radians(), Space.LOCAL);
        //transform.translate(Axis.X, 100, Space.LOCAL);
        //points.push(transform.position);

        //transform.rotate(Axis.Z, Angle.FromDegrees(90).radians(), Space.LOCAL);
        //transform.translate(Axis.X, 100, Space.LOCAL);
        //points.push(transform.position);
		
		var lorenz = Mesh.CreateLines("whirlpool", points, scene, false);
		lorenz.color = Color3.Red();
		
		scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
			//lorenz.rotation.y += 0.01 * scene.getAnimationRatio();
		});
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
	
	
}
