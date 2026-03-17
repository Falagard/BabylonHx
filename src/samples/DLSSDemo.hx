package samples;

import com.babylonhx.Scene;
import com.babylonhx.cameras.UniversalCamera;
import com.babylonhx.lights.PointLight;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Color3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.postprocess.DLSSUpscaler;
import com.babylonhx.tools.EventState;

/**
 * DLSS (Deep Learning Super Sampling) Demo
 * 
 * This scene demonstrates NVIDIA DLSS integration with:
 * - Real-time quality level switching
 * - Performance statistics display
 * - Debug visualization modes
 * - Multiple animated objects for temporal coherence testing
 * - Smooth camera movement for motion vector validation
 * 
 * Controls:
 * - 1: DLSS Performance mode
 * - 2: DLSS Balanced mode
 * - 3: DLSS Quality mode
 * - 4: DLSS Ultra mode
 * - 5: Toggle DLSS on/off
 * - D: Cycle debug visualization modes
 * - Arrow keys: Move camera
 * - Mouse: Look around
 */
class DLSSDemo extends BasicScene {
	
	private var dlssUpscaler:DLSSUpscaler;
	private var dlssEnabled:Bool = true;
	private var currentQualityLevel:Int = 2; // Balanced by default
	private var debugMode:Int = 0; // 0 = Disabled, 1-5 = Different modes
	private var animatingObjects:Array<Mesh> = [];
	private var statsText:String = "";
	private var lastFrameTime:Float = 0;
	
	override public function new(scene:Scene) {
		super(scene);
		this.create();
	}
	
	override public function create():Void {
		// Create camera with smooth movement
		var camera = new UniversalCamera("camera", new Vector3(0, 15, -40), this.scene);
		camera.attachControl();
		camera.speed = 0.3;
		camera.angularSensibility = 500;
		camera.inertia = 0.7;
		
		// Create lights for better visibility
		var hemisLight = new HemisphericLight("hemiLight", new Vector3(0, 1, 0), this.scene);
		hemisLight.intensity = 0.6;
		
		var pointLight1 = new PointLight("pointLight1", new Vector3(20, 30, 20), this.scene);
		pointLight1.intensity = 0.8;
		
		var pointLight2 = new PointLight("pointLight2", new Vector3(-20, 30, -20), this.scene);
		pointLight2.intensity = 0.6;
		
		// Create ground plane
		var ground = Mesh.CreateGround("ground", 200, 200, 50, this.scene);
		var groundMat = new StandardMaterial("groundMat", this.scene);
		groundMat.diffuse = new Color3(0.5, 0.5, 0.5);
		groundMat.specularColor = new Color3(0.2, 0.2, 0.2);
		ground.material = groundMat;
		
		// Create dynamic scene with multiple animated objects
		createAnimatedObjects();
		
		// Initialize DLSS if supported
		if (this.scene.getCaps().dlssSupported) {
			initializeDLSS();
		} else {
			trace("DLSS not supported on this hardware");
		}
		
		// Setup input controls
		setupInputControls();
		
		// Setup render loop for statistics
		this.scene.onBeforeRender = function(scene:Scene, es:EventState) {
			updateDLSSStatistics();
			updateAnimatedObjects();
		};
	}
	
	/**
	 * Creates a variety of animated objects to test temporal coherence
	 */
	private function createAnimatedObjects():Void {
		// Group 1: Rotating cubes
		for (i in 0...4) {
			var cube = Mesh.CreateBox("cube_" + i, 3, this.scene);
			cube.position.x = -15 + (i * 10);
			cube.position.y = 5;
			cube.position.z = 20;
			
			var mat = new StandardMaterial("cubeMat_" + i, this.scene);
			mat.diffuse = new Color3(
				Math.random(),
				Math.random(),
				Math.random()
			);
			cube.material = mat;
			animatingObjects.push(cube);
		}
		
		// Group 2: Orbiting spheres at different heights
		for (i in 0...3) {
			var sphere = Mesh.CreateSphere("sphere_" + i, 16, 2.5, this.scene);
			sphere.position.y = 8 + (i * 5);
			
			var mat = new StandardMaterial("sphereMat_" + i, this.scene);
			mat.diffuse = new Color3(
				0.5 + Math.random() * 0.5,
				0.5 + Math.random() * 0.5,
				0.5 + Math.random() * 0.5
			);
			mat.specularColor = new Color3(1, 1, 1);
			sphere.material = mat;
			animatingObjects.push(sphere);
		}
		
		// Group 3: Tori (donuts) with complex motion
		for (i in 0...2) {
			var torus = Mesh.CreateTorus("torus_" + i, 5, 1.5, 32, this.scene);
			torus.position.y = 10 + (i * 8);
			torus.position.z = -15;
			
			var mat = new StandardMaterial("torusMat_" + i, this.scene);
			mat.diffuse = new Color3(
				Math.random(),
				Math.random(),
				Math.random()
			);
			torus.material = mat;
			animatingObjects.push(torus);
		}
	}
	
	/**
	 * Update position and rotation of animated objects
	 * This generates motion vectors for DLSS temporal coherence
	 */
	private function updateAnimatedObjects():Void {
		var time = this.scene.getAnimationRatio();
		
		// Rotate cubes
		for (i in 0...4) {
			var cube = animatingObjects[i];
			cube.rotation.x += 0.01;
			cube.rotation.y += 0.015;
			cube.position.y = 5 + Math.sin(time * 0.002 + i) * 2;
		}
		
		// Orbit spheres
		for (i in 0...3) {
			var sphere = animatingObjects[4 + i];
			var angle = (time * 0.001 + i * 2.0) % (Math.PI * 2);
			var radius = 15 + (i * 5);
			sphere.position.x = Math.cos(angle) * radius;
			sphere.position.z = Math.sin(angle) * radius;
		}
		
		// Complex motion for tori
		for (i in 0...2) {
			var torus = animatingObjects[7 + i];
			torus.rotation.x += 0.008;
			torus.rotation.z += 0.012;
			torus.position.x = Math.sin(time * 0.0015 + i * 50) * 10;
		}
	}
	
	/**
	 * Initialize DLSS upscaler with default balanced quality
	 */
	private function initializeDLSS():Void {
		dlssUpscaler = new DLSSUpscaler(this.scene.getEngine(), this.scene.getCamera());
		
		try {
			var qualityNames = ["Performance", "Balanced", "Quality", "Ultra"];
			var success = dlssUpscaler.initialize(null, null);
			
			if (success) {
				// Set to Balanced quality by default (index 2)
				dlssUpscaler.setQualityLevel(currentQualityLevel);
				dlssEnabled = true;
				trace("DLSS initialized successfully (Balanced mode)");
			} else {
				trace("Failed to initialize DLSS");
				dlssEnabled = false;
			}
		} catch (e:Dynamic) {
			trace("Error initializing DLSS: " + e);
			dlssEnabled = false;
		}
	}
	
	/**
	 * Setup keyboard controls for DLSS features
	 */
	private function setupInputControls():Void {
		this.scene.onKeyboardObservable.add(function(kbInfo:Dynamic, es:EventState) {
			var key = kbInfo.event.keyCode;
			
			switch (key) {
				case 49: // Key '1' - Performance mode
					if (dlssUpscaler != null) {
						dlssUpscaler.setQualityLevel (0);
						currentQualityLevel = 0;
						trace("DLSS Quality: Performance (4x speedup)");
					}
					
				case 50: // Key '2' - Balanced mode
					if (dlssUpscaler != null) {
						dlssUpscaler.setQualityLevel(1);
						currentQualityLevel = 1;
						trace("DLSS Quality: Balanced (2.4x speedup)");
					}
					
				case 51: // Key '3' - Quality mode
					if (dlssUpscaler != null) {
						dlssUpscaler.setQualityLevel(2);
						currentQualityLevel = 2;
						trace("DLSS Quality: Quality (1.7x speedup)");
					}
					
				case 52: // Key '4' - Ultra mode
					if (dlssUpscaler != null) {
						dlssUpscaler.setQualityLevel(3);
						currentQualityLevel = 3;
						trace("DLSS Quality: Ultra (1.3x speedup)");
					}
					
				case 53: // Key '5' - Toggle DLSS on/off
					if (dlssUpscaler != null) {
						dlssEnabled = !dlssEnabled;
						if (dlssEnabled) {
							dlssUpscaler.initialize(null, null);
							trace("DLSS: Enabled");
						} else {
							dlssUpscaler.dispose();
							trace("DLSS: Disabled (native resolution rendering)");
						}
					}
					
				case 68: // Key 'D' - Cycle debug visualization
					if (dlssUpscaler != null) {
						debugMode = (debugMode + 1) % 6;
						var debugNames = [
							"Disabled",
							"Input Resolution",
							"Motion Vectors",
							"Reconstruction Mask",
							"Temporal Accumulation",
							"Performance Graph"
						];
						if (dlssUpscaler.debugVisualizer != null) {
							dlssUpscaler.debugVisualizer.setMode(debugMode);
						}
						trace("Debug Mode: " + debugNames[debugMode]);
					}
			}
		});
	}
	
	/**
	 * Update and display DLSS statistics
	 */
	private function updateDLSSStatistics():Void {
		if (dlssUpscaler == null || !dlssEnabled) {
			return;
		}
		
		try {
			var stats = dlssUpscaler.getStatistics();
			if (stats != null) {
				var qualityNames = ["Performance", "Balanced", "Quality", "Ultra"];
				var qualityName = qualityNames[currentQualityLevel];
				
				statsText = 'DLSS Status\n' +
					'Quality: $qualityName\n' +
					'GPU Time: ${Math.round(stats.gpuTimeMs * 100) / 100}ms\n' +
					'Estimated FPS Gain: ${Math.round(stats.estimatedPerformanceGain * 100)}%\n' +
					'Output Resolution: ${stats.outputWidth}x${stats.outputHeight}\n' +
					'Input Resolution: ${stats.inputWidth}x${stats.inputHeight}\n' +
					'Scale Factor: ${Math.round(stats.scaleFactor * 100) / 100}x\n' +
					'\nControls:\n' +
					'1-4: Quality modes\n' +
					'5: Toggle DLSS\n' +
					'D: Debug visualization';
				
				// You would typically render this to an overlay or console
				// trace(statsText);
			}
		} catch (e:Dynamic) {
			// Handle statistics retrieval error
		}
	}
	
	/**
	 * Cleanup DLSS resources
	 */
	override public function dispose():Void {
		if (dlssUpscaler != null) {
			dlssUpscaler.dispose();
		}
		super.dispose();
	}
}
