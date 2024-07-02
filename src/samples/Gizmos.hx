package samples;

import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import com.babylonhx.rendering.UtilityLayerRenderer;
import com.babylonhx.gizmos.GizmoManager;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Gizmos {

	public function new(scene:Scene) {
		        
		var camera = new FreeCamera("camera1", new Vector3(0, 5, -10), scene);
		camera.setTarget(Vector3.Zero());
		camera.attachControl();
		
		var light = new HemisphericLight("light1", new Vector3(1, 0.5, 0), scene);
		light.intensity = 1;
		
		var sphere = Mesh.CreateSphere("sphere1", 16, 2, scene);
		sphere.material = new StandardMaterial("mat", scene);
		untyped sphere.material.diffuseColor = new Color3(0.3, 0.34, 0.87);
		sphere.position.y = 1;

        var utilityLayerRenderer = new UtilityLayerRenderer(scene, true);
	
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
