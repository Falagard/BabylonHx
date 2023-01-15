package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.WebVRFreeCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;

import com.babylonhx.animations.Animation;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.collisions.PickingInfo;

import com.babylonhx.tools.EventState;
import com.babylonhx.utils.Image;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.procedurals.standard.Plasma;
import com.babylonhx.materials.textures.procedurals.standard.Spiral;
import com.babylonhx.materials.textures.procedurals.standard.Dream;
import com.babylonhx.materials.textures.procedurals.standard.Combustion;
import com.babylonhx.materials.textures.procedurals.standard.Electric;
import com.babylonhx.materials.textures.procedurals.standard.Voronoi;
import com.babylonhx.materials.textures.procedurals.standard.LiquidMetal;
import com.babylonhx.materials.textures.procedurals.standard.DoubleBokeh;

import com.babylonhx.postprocess.NotebookDrawingsPostProcess;
import com.babylonhx.postprocess.WatercolorPostProcess;
import com.babylonhx.postprocess.NoisePostProcess;

//import speccy.Z80;

/**
 * ...
 * @author Krtolica Vujadin
 */
class BasicScene {

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
		
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
	}
	
}
