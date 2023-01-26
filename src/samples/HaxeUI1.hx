package samples;

import com.babylonhx.ui.UIComponent;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.Scene;
import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;
import haxe.ui.core.Screen;
import ui.MainView;

/**
 * ...
 * @author Clay Larabie
 */
class HaxeUI1 {

	public function new(scene:Scene) {

        Toolkit.init();
        Toolkit.scaleX = 1;
        Toolkit.scaleY = 1;

        var root : UIComponent = new UIComponent();

        var app = new HaxeUIApp();
        app.ready(
            function() {

                Screen.instance.root = root;

                //app.addComponent(main);
                app.addComponent(new MainView());
                app.start();
            }
        );
		
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
