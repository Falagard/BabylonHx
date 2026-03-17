package samples;

import com.babylonhx.Scene;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.cameras.UniversalCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.rendering.MotionVectorRenderer;

/**
 * Test scene for motion vector rendering
 * 
 * This scene demonstrates motion vector rendering with:
 * - A static camera
 * - A static ground plane (should produce zero motion)
 * - A rotating box (should produce rotational motion vectors)
 * - An animated sphere moving in a circle (should produce translational motion vectors)
 */
class MotionVectorTest extends BasicScene {
	
	override public function new(scene:Scene) {
		super(scene);
        this.create();
    }
    
    override public function create():Void {
		// Create camera
		var camera = new UniversalCamera("camera", new Vector3(0, 10, -20), this.scene);
		camera.attachControl();
		camera.speed = 0.15;
		camera.angularSensibility = 1000;
		camera.inertia = 0.7;
		camera.lowerRadiusLimit = 9;
		camera.upperRadiusLimit = 500;
		
		// Create lights
		var light1 = new PointLight("light1", new Vector3(10, 20, 10), this.scene);
		light1.intensity = 1.0;
		
		var light2 = new PointLight("light2", new Vector3(-10, 20, -10), this.scene);
		light2.intensity = 0.7;
		
		// Create ground (static - should have zero motion)
		var ground = Mesh.CreateGround("ground", 100, 100, 20, this.scene);
		var groundMat = new StandardMaterial("groundMat", this.scene);
		groundMat.diffuse = new Color3(0.5, 0.5, 0.5);
		ground.material = groundMat;
		
		// Create a rotating box (should have rotational motion)
		var box = Mesh.CreateBox("rotatingBox", 2, this.scene);
		box.position.y = 2;
		var boxMat = new StandardMaterial("boxMat", this.scene);
		boxMat.diffuse = new Color3(1.0, 0.0, 0.0);
		box.material = boxMat;
		
		// Create animation for box rotation
		var boxRotationAnim = new com.babylonhx.animations.Animation(
			"boxRotation",
			"rotation.z",
			60,
			com.babylonhx.animations.Animation.ANIMATIONTYPE_FLOAT,
			com.babylonhx.animations.Animation.ANIMATIONLOOPMODE_CYCLE
		);
		var keys = [];
		keys.push({frame: 0, value: 0});
		keys.push({frame: 120, value: Math.PI * 2});
		boxRotationAnim.setKeys(keys);
		box.animations.push(boxRotationAnim);
		this.scene.beginAnimation(box, 0, 120, true);
		
		// Create an orbiting sphere (translational motion)
		var sphere = Mesh.CreateSphere("orbitingSphere", 16, 1.5, this.scene);
		sphere.position.y = 2;
		var sphereMat = new StandardMaterial("sphereMat", this.scene);
		sphereMat.diffuse = new Color3(0.0, 1.0, 0.0);
		sphere.material = sphereMat;
		
		// Create animation for sphere orbiting
		var sphereXAnim = new com.babylonhx.animations.Animation(
			"sphereX",
			"position.x",
			60,
			com.babylonhx.animations.Animation.ANIMATIONTYPE_FLOAT,
			com.babylonhx.animations.Animation.ANIMATIONLOOPMODE_CYCLE
		);
		var keysX = [];
		keysX.push({frame: 0, value: 10});
		keysX.push({frame: 60, value: 0});
		keysX.push({frame: 120, value: -10});
		keysX.push({frame: 180, value: 0});
		keysX.push({frame: 240, value: 10});
		sphereXAnim.setKeys(keysX);
		
		var sphereZAnim = new com.babylonhx.animations.Animation(
			"sphereZ",
			"position.z",
			60,
			com.babylonhx.animations.Animation.ANIMATIONTYPE_FLOAT,
			com.babylonhx.animations.Animation.ANIMATIONLOOPMODE_CYCLE
		);
		var keysZ = [];
		keysZ.push({frame: 0, value: 10});
		keysZ.push({frame: 60, value: 0});
		keysZ.push({frame: 120, value: -10});
		keysZ.push({frame: 180, value: 0});
		keysZ.push({frame: 240, value: 10});
		sphereZAnim.setKeys(keysZ);
		
		sphere.animations.push(sphereXAnim);
		sphere.animations.push(sphereZAnim);
		this.scene.beginAnimation(sphere, 0, 240, true);
		
		// Create a cube that opts out of motion vector rendering
		var nmoMesh = Mesh.CreateBox("noMotionBox", 1.5, this.scene);
		nmoMesh.position = new Vector3(-8, 2, 0);
		nmoMesh.renderMotionVectors = false; // Opt out of motion vectors
		var nmoMat = new StandardMaterial("nmoMat", this.scene);
		nmoMat.diffuse = new Color3(0.0, 0.0, 1.0);
		nmoMesh.material = nmoMat;
		
		// Enable motion vector rendering
		var mvRenderer = this.scene.enableMotionVectorRenderer();
		
		// Optional: Log motion vector statistics
		var logStats = function() {
			trace(mvRenderer.getStatistics());
		};
		
		// Could add console logging here for debugging
		// Every frame, you could check: mvRenderer.getMotionVectorTexture()
    }
}
