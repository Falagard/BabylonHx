package;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import openfl.display.OpenGLRenderer;
import openfl.display.Sprite;
import openfl.display3D.Context3D;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.RenderEvent;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

import com.babylonhx.engine.Engine;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 */

// __flushGL is private, but it is the only way to tell OpenFL that the GL state
// it has cached no longer matches the driver after BabylonHx has drawn.
@:access(openfl.display3D.Context3D)
class MainOpenFL extends Sprite {
	
	var scene:Scene;
	var engine:Engine;
	
	var context3D:Context3D;
	var pointerEvent:PointerEvent;
	
	
	public function new() {
		super();
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	function onAddedToStage(_) {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		pointerEvent = new PointerEvent();
		
		// openfl.display.OpenGLView was removed in OpenFL 6. Listening for
		// RENDER_OPENGL is the supported way to issue raw GL calls in the middle
		// of OpenFL's frame, and it keeps BabylonHx ordered in the display list.
		addEventListener(RenderEvent.RENDER_OPENGL, onRenderOpenGL);
		
		stage.addEventListener(Event.RESIZE, onResize);
		
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		
		// Key events come from the Lime window instead of KeyboardEvent because
		// BabylonHx compares against com.babylonhx.utils.Keycodes, which uses SDL
		// values. KeyboardEvent.keyCode has already been mapped to Flash codes.
		stage.window.onKeyDown.add(onKeyDown);
		stage.window.onKeyUp.add(onKeyUp);
		
		#if mobile
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchStart);
		stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		#end
	}
	
	function onRenderOpenGL(e:RenderEvent) {
		if (engine == null) {
			var renderer:OpenGLRenderer = cast e.renderer;
			
			context3D = stage.context3D;
			
			engine = new Engine(stage, renderer.gl, true);
			engine.width = stage.stageWidth;
			engine.height = stage.stageHeight;
			
			scene = new Scene(engine);
			
			createDemo();
		}
		
		engine._renderLoop();
		
		// OpenFL flushes its GL state before dispatching this event but only
		// restores the viewport afterwards, so hand it back a state it can trust.
		// Build with -D openfl_disable_context_cache or these calls are skipped as
		// redundant and the 2D display list renders with BabylonHx's state.
		context3D.__flushGL();
	}
	
	function createDemo() {
		//new samples.TestWireframe(scene);
		//new samples.BScene(scene);
		//new samples.DRPDemo(scene);
		//new samples.BasicScene(scene);
		//new samples.BasicElements(scene);
		//new samples.DashedLinesMesh(scene);
		//new samples.RotationAndScaling(scene);
		//new samples.Materials(scene);
		new samples.Lights(scene);
		//new samples.BumpMap(scene);
		//new samples.Bump2(scene);
		//new samples.Animations(scene);
		//new samples.Collisions(scene);
		//new samples.Intersections(scene);
		//new samples.EasingFunctions(scene);
		//new samples.ProceduralTextures(scene);
		//new samples.MeshImport(scene);
		//new samples.LoadScene(scene);
		//new samples.CSGDemo(scene);
		//new samples.Fog(scene);
		//new samples.DisplacementMap(scene);
		//new samples.Environment(scene);
		//new samples.LensFlares(scene);
		//new samples.PhysicsCannon(scene);
		//new samples.Physics(scene);
		//new samples.Physics2(scene);
		//new samples.Physics_Pyramid(scene);
		//new samples.PhysicsSimple(scene);
		//new samples.PhysicsCar(scene);
		//new samples.PhysicsNew(scene);
		//new samples.PolygonMesh1(scene);
		//new samples.PolygonMesh2(scene);
		//new samples.PolygonMesh3(scene);
		//new samples.ProceduralShapesTest(scene);
		//new samples.CustomRenderTarget(scene);
		//new samples.Lines(scene);
		//new samples.Lines2(scene);
		//new samples.Lines3(scene);
		//new samples.Bones(scene);		
		//new samples.Shadows(scene);
		//new samples.Shadows2(scene);
		//new samples.HeightMap(scene);
		//new samples.LoadObjFile(scene);
		//new samples.LoadStlFile(scene);
		//new samples.LoadPlyFile(scene);
		//new samples.LoadCtmFile(scene);
		//new samples.LOD(scene);
		//new samples.Instances(scene);
		//new samples.Instances2(scene);
		//new samples.Fresnel(scene);		
		//new samples.Fresnel2(scene);
		//new samples.VolumetricLights(scene);
		//new samples.CellShading(scene);
		//new samples.Particles(scene);
		//new samples.Particles2(scene);					// OK
		//new samples.Particles3(scene);					// OK
		//new samples.Particles4(scene);
		//new samples.Particles5(scene);					// OK
		//new samples.Particles6(scene);
		//new samples.Particles7(scene);
		//new samples.Particles8(scene);
		//new samples.Particles9(scene);
		//new samples.Particles10(scene);
		//new samples.AnimatedParticles(scene);
		//new samples.Snow(scene);
		//new samples.Extrusion(scene);
		//new samples.Sprites(scene);
		//new samples.PostprocessBloom(scene);
		//new samples.PostprocessBloom2(scene);
		//new samples.PostprocessRefraction(scene);
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
		//new samples.Minimap(scene);
		//new samples.RayRender(scene);
		//new samples.ShaderMaterialTest(scene);
		//new samples.TestInstancesCount(scene);
		//new samples.HighlightLayerInstances(scene);
		//new samples.ShadowOnlyMaterialTest(scene);
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
	}
	
	function onResize(_) {
		if (engine == null) {
			return;
		}
		
		engine.width = stage.stageWidth;
		engine.height = stage.stageHeight;
		
		for (f in engine.onResize) {
			f();
		}
		
		engine.resize();
	}
	
	function onKeyDown(keyCode:KeyCode, modifier:KeyModifier) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.keyDown) {
			f(keyCode);
		}
	}
	
	function onKeyUp(keyCode:KeyCode, modifier:KeyModifier) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.keyUp) {
			f(keyCode);
		}
	}
	
	function onMouseDown(e:MouseEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.mouseDown) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.button = 0;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	
	function onMouseUp(e:MouseEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.mouseUp) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.button = 0;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	
	function onMouseMove(e:MouseEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.mouseMove) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	
	function onMouseWheel(e:MouseEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.mouseWheel) {
			f(e.delta);
		}
	}
	
	function onTouchStart(e:TouchEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.touchDown) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.button = e.touchPointID;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	function onTouchEnd(e:TouchEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.touchUp) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.button = e.touchPointID;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	function onTouchMove(e:TouchEvent) {
		if (engine == null) {
			return;
		}
		
		for (f in engine.touchMove) {
			pointerEvent.x = e.stageX;
			pointerEvent.y = e.stageY;
			pointerEvent.button = e.touchPointID;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
}
