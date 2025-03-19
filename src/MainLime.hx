package;

import lime.ui.MouseWheelMode;
#if cpp
//import hxtelemetry.HxTelemetry;
#end

import haxe.Timer;
import lime.app.Application;
import lime.utils.Assets;
//import lime.graphics.GLRenderContext;
import lime.graphics.WebGL2RenderContext;
//import lime.graphics.opengl.WebGLContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.graphics.RenderContext;
//import lime.graphics.Renderer;
import lime.ui.Touch;
import lime.ui.Window;

import com.babylonhx.engine.Engine;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.Scene;
import com.babylonhx.states._AlphaState;

/**
 * ...
 * @author Krtolica Vujadin
 */
#if cpp
//@:build(haxebullet.MacroUtil.buildAll())
#end
class MainLime extends Application {

	
	
	var scene:Scene;
	var engine:Engine;
	var pointerEvent:PointerEvent;
	
	#if cpp
	//var hxt = new HxTelemetry();
	#end
	
	
	public function new() {
		super();
	}
	
	override public function onWindowCreate() {
		//switch (window.context) {
			//case OPENGL (gl):
				//var gl:WebGL2Context = window.context;
				
				//var gles3:lime.graphics.OpenGLES3RenderContext = window.context;

				trace("before creating engine");

				var renderContext = lime.graphics.opengl.GL.context;

				engine = new Engine(window, renderContext, true);	
				scene = new Scene(engine);
				
				engine.width = window.width;
				engine.height = window.height;
				
			//default:
				//
		//}
		
		pointerEvent = new PointerEvent();
	}
	
	override public function onPreloadComplete() {
		//new samples.Turtle(scene);
		//new samples.LSystem(scene);

		//new samples.TestWireframe(scene); //works
	    //new samples.BScene(scene); //html: y, hl: y
		//new samples.DRPDemo(scene); //default rendering pipeline crashes, needs investigation
		new samples.BasicScene(scene); //     html: Y, hl: y
		//new samples.BasicElements(scene); //hl: y
		//new samples.DashedLinesMesh(scene); //hl: y
		//new samples.RotationAndScaling(scene); //hl: y
		//Fnew samples.Materials(scene); //html: y, hl: y
		//new samples.Lights(scene); //hl: y
		//new samples.BumpMap(scene); //html:y , hl: y
		//new samples.Bump2(scene); //html: runs but not showing bump
		//new samples.Animations(scene); //hl: y
		//new samples.Collisions(scene); //html: runs, black screen
		//new samples.Intersections(scene); //html: y
		//new samples.EasingFunctions(scene); //html: y
		//new samples.ProceduralTextures(scene); //html: y
		//new samples.MeshImport(scene); //html: y
		//new samples.LoadScene(scene); //needs assets
		//new samples.CSGDemo(scene); //html: y
		//new samples.Fog(scene); html: y
		//new samples.DisplacementMap(scene); //compile error
		//new samples.Environment(scene); //hl: y
		//new samples.LensFlares(scene); //hl: y
		//new samples.PhysicsCannon(scene);
		//new samples.Physics(scene);
		//new samples.Physics2(scene);
		//new samples.Physics_Pyramid(scene);
		//new samples.PhysicsSimple(scene);
		//new samples.PhysicsCar(scene);
		//new samples.PhysicsNew(scene);
		//new samples.PolygonMesh1(scene); //OpenSimplexNoiseTileable3D crash
		//new samples.PolygonMesh2(scene);
		//new samples.PolygonMesh3(scene);
		//new samples.ProceduralShapesTest(scene);
		//new samples.CustomRenderTarget(scene); //hl: y
		//new samples.Lines(scene); //hl:y
		//new samples.Lines2(scene); //hl:y
		//new samples.Lines3(scene); //hl:y
		//new samples.Bones(scene); //html: y, hl: y
		//new samples.Shadows(scene); //hl: y
		//new samples.Shadows2(scene); //hl: runs but shadows and maybe materials are missing. Crashes if you enable useBlurExponentialShadowMap
		//new samples.HeightMap(scene); //missing assets
		//new samples.LoadObjFile(scene);
		//new samples.LoadStlFile(scene);
		//new samples.LoadPlyFile(scene);
		//new samples.LoadCtmFile(scene);
		//new samples.LOD(scene);
		//new samples.Instances(scene); //hl: y, but minor crash when freecamera collisions enabled
		//new samples.Instances2(scene);
		//new samples.Fresnel(scene);		
		//new samples.Fresnel2(scene);
		//new samples.VolumetricLights(scene);
		//new samples.CellShading(scene);
		//new samples.Particles(scene); //hl: y
		//new samples.Particles2(scene); //crashes, effect is null
		//new samples.Particles3(scene); //hl:y
		//new samples.Particles4(scene); //hl: y
		//new samples.Particles5(scene); //hl: y
		//new samples.Particles6(scene); //hl: y
		//new samples.Particles7(scene); //hl:y
		//new samples.Particles8(scene); //hl:y
		//new samples.Particles9(scene); //hl:y
		//new samples.Particles10(scene); //hl:y
		//new samples.AnimatedParticles(scene); //hl:y
		//new samples.Snow(scene);
		//new samples.Extrusion(scene);
		//new samples.Sprites(scene); //missing assets
		//new samples.PostprocessBloom(scene); //hl: y
		//new samples.PostprocessBloom2(scene); //compile error CTM file loader and need example file. 
		//new samples.PostprocessRefraction(scene); //hl: y
		//new samples.PostprocessConvolution(scene);
		//new samples.GodRays(scene);
		//new samples.GodRays2(scene);
		//new samples.DepthOfField(scene);
		//new samples.Actions(scene);
		//new samples.Picking(scene);		
		//new samples.Octree(scene);
		//new samples.SSAO(scene);	
		//new samples.SSAO2(scene);
		//new samples.Decals(scene);
		//new samples.InstancedBones(scene);				
		//new samples.AdvancedShadows(scene);
		//new samples.Ribbons(scene);
		//new samples.RibbonTest2(scene);
		//new samples.SoftShadows(scene);		
		//new samples.BabylonHxWebsiteScene(scene);
		//new samples.Water(scene);
		//new samples.SolidParticles1(scene);
		//new samples.SolidParticles2(scene);
		//new samples.SolidParticles3(scene);
		//new samples.SolidParticles4(scene);
		//new samples.SolidParticles5(scene);
		//new samples.SolidParticles6(scene);
		//new samples.SolidParticles7(scene);
		//new samples.PointLightShadows(scene);
		//new samples.PointLightShadow(scene);
		//new samples.Labyrinth(scene);
		//new samples.ForestOfPythagoras(scene);		
		//new samples.MaterialsLibTest(scene);	
		//new samples.ReflectionProbeTest(scene);
		//new samples.IcoSphereTest(scene);
		//new samples.PBRMaterialTest1(scene);
		//new samples.PBRMaterialTest2(scene);	
		//new samples.PBRMaterialTest3(scene);
		//new samples.PBRMaterialTest4(scene);
		//new samples.PBRMaterialTest5(scene);
		//new samples.PBRMaterialTest6(scene);
		//new samples.PBRMaterialTest7(scene);
		//new samples.PBRMaterialTest8(scene);
		//new samples.PBRMaterialTest9(scene);
		//new samples.PBRMetalicWorkflow(scene);
		//new samples.TorusThing(scene);
		//new samples.StarfieldMaterialTest(scene);
		//new samples.FeaturedDemo1(scene);
		//new samples.GlosinessAndRoughness(scene);
		//new samples.HaxedNES(scene);
		//new samples.RefractionMaterial(scene);
		//new samples.SponzaDynamicShadows(scene);
		//new samples.RefractReflect(scene);
		//new samples.AnimationBlending(scene);
		//new samples.AnimationBlending2(scene);
		//new samples.GridMaterialTest(scene);
		//new samples.SkeletonViewerTest(scene);
		//new samples.Mario(scene);
		//new samples.LogarithmicDepth(scene);
		//new samples.SkullPBR(scene);
		//new samples.BulletPhysics(scene);
		//new samples.Bullet2(scene);
		//new samples.Waterfall(scene);
		//new samples.ShaderBuilder1(scene);
		//new samples.ShaderBuilder2(scene);
		//new samples.ShaderBuilder3(scene);
		//new samples.ShaderBuilder4(scene);
		//new samples.ShaderBuilder5(scene);
		//new samples.ShaderBuilder6(scene);
		//new samples.CalikoDemo3D(scene);
		//new samples.TriPlanarMaterialTest(scene);
		//new samples.SkyMaterialTest(scene);
		//new samples.SimpleMaterialTest(scene);
		//new samples.FireMat(scene);
		//new samples.WaterMat(scene);
		//new samples.WaterMat2(scene);
		//new samples.LavaMat(scene);
		//new samples.NormalMat(scene);
		//new samples.FurMat(scene);
		//new samples.GradientMaterialTest(scene);
		//new samples.CellMat(scene);
		//new samples.ShadowTest(scene);
		//new samples.MultiLights(scene);
		//new samples.MultiLights2(scene);
		//new samples.HighlightLayerTest(scene);
		//new samples.PBRWithHighlight(scene);
		//new samples.BoneScaling(scene);
		//new samples.MouseFollow(scene);
		//new samples.BoneLookControllerDemo(scene);
		//new samples.BoneIKControllerDemo(scene);
		//new samples.proceduralcity.City(scene);
		//new samples.Minimap(scene);
		//new samples.RayRender(scene);
		//new samples.ShaderMaterialTest(scene);
		//new samples.TestInstancesCount(scene);
		//new samples.HighlightLayerInstances(scene);
		//new samples.ShadowOnlyMaterialTest(scene); //compile error
		//new samples.Facets(scene);
		//new samples.SelfShadowing(scene);
		//new samples.DynamicTerrainTest(scene);
		//new samples.SimpleOakTreeTest(scene);
		//new samples.PineTree(scene);
		//new samples.MultipleViewports(scene);
		//new samples.BackgroundMaterialTest(scene);
		//new samples.NonUniformScalingTest(scene);
		//new samples.PremultiplyAlphaTest(scene);
		//new samples.StandardRenderingPipelineTest(scene);
		//new samples.MeshFacetDepthSortTest(scene);
		//new samples.SuperEllipsoid(scene);
		//new samples.MoleculeViewer(scene);
		//new samples.PPFilm(scene);
		//new samples.PPDreamVision(scene);
		//new samples.PPInk(scene);
		//new samples.PPKnitted(scene);
		//new samples.PPLimbDarkening(scene);
		//new samples.PPMosaic(scene);
		//new samples.PPNaturalColor(scene);
		//new samples.PPNotebookDrawings(scene);
		//new samples.PPScanline(scene);
		//new samples.PPThermalVision(scene);
		//new samples.PPVignette(scene);
		//new samples.PPBleachBypass(scene);
		//new samples.PPCrossHatching(scene);
		//new samples.PPCrossStitching(scene);
		//new samples.PPNightVision(scene);
		//new samples.PPVibrance(scene);
		//new samples.PPWatercolor(scene);
		//new samples.PPOldVideo(scene);
		
		//new samples.CrossHatchingMaterial(scene);
		
		//new samples.TestRot(scene);
		
		//new samples.TestCustomFileStruct(scene);
		
		//new samples.MemoryGame(scene);
		
		//new samples.sokoban.Main(scene);
		
		//new samples.MultiAnim(scene);
		
		
		//scene.init2D();
		//new samples.demos2D.Graphics(scene);
		//new samples.demos2D.Bitmaps(scene);
		//new samples.demos2D.Bunnymark(scene);
		//new samples.demos2D.EnterFrameEvent(scene);
		//new samples.demos2D.MouseEvents(scene);
		//new samples.demos2D.ColorTransform(scene);
		//new samples.demos2D.Bezier(scene);
		//new samples.demos2D.WaterSurface(scene);
		//new samples.demos2D.Plasma(scene);
		//new samples.demos2D.Spritesheet(scene);
		//new samples.demos2D.Mandelbrot(scene);
		//new samples.demos2D.Pseudo3D(scene);
		//new samples.demos2D.Real3D(scene);
		//new samples.demos2D.KeyboardEvents(scene);
		//new samples.demos2D.Physics(scene);
		//new samples.demos2D.box2Dtests.Box2DMain(scene);
		//new samples.demos2D.Pendulum(scene);
		//new samples.demos2D.Text(scene);
		//new samples.demos2D.Resizable(scene);
		//new samples.demos2D.TestEarcut(scene);
		//new samples.demos2D.JellyPhysics(scene);		
		//new samples.demos2D.JellyPhysics2(scene);
		
		//scene.stage2D.addChild(new com.babylonhx.d2.text.FPS());
	}
	
	override function onMouseDown(x:Float, y:Float, button:Int) {
		for (f in engine.mouseDown) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.button = button;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
		
	}
	
	#if !neko
	override function onMouseUp(x:Float, y:Float, button:Int) {
		for(f in engine.mouseUp) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.button = button;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	#end
	
	override function onMouseMove(x:Float, y:Float) {
		for(f in engine.mouseMove) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	
	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) {
		for (f in engine.mouseWheel) {
			pointerEvent.type = PointerEventTypes.POINTERWHEEL;
			pointerEvent.pointerType = "mouse";
			f(deltaY);
		}
	}
	
	override function onTouchStart(touch:Touch) {
		for (f in engine.touchDown) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	override function onTouchEnd(touch:Touch) {
		for (f in engine.touchUp) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	override function onTouchMove(touch:Touch) {
		for (f in engine.touchMove) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}

	override function onKeyUp(keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyUp) {
			f(keycode);
		}
		//scene.stage2D._onKU(modifier.altKey, modifier.ctrlKey, modifier.shiftKey, keycode, 0);
	}
	
	override function onKeyDown(keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyDown) {
			f(keycode);
		}
		//scene.stage2D._onKD(modifier.altKey, modifier.ctrlKey, modifier.shiftKey, keycode, 0);
	}
	
	override public function onWindowResize(width:Int, height:Int) {
		if (engine != null) {
			engine.width = width;
			engine.height = height;
			for (f in engine.onResize) {
				f();
			}
			engine.resize();
		}
	}
	
	override function update(deltaTime:Int) {
		#if cpp
		//hxt.advance_frame();
		#end
		engine._renderLoop();
	}
	
}
