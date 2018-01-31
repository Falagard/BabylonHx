package samples;

import com.babylonhx.particles.solid.SolidParticleSystem;
import com.babylonhx.particles.solid.SolidParticle;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Color4;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.lights.PointLight;
import com.babylonhx.materials.StandardMaterial;

/**
 * ...
 * @author Krtolica Vujadin
 */
class Facets {

	public function new(scene:Scene) {
		scene.clearColor = new Color4(0.15, 0.15, 0.3, 1.0);
		// camera
		var camera = new ArcRotateCamera("Camera", 0, 0, 0, Vector3.Zero(), scene);
		camera.attachControl();
		camera.setPosition(new Vector3(0, 10.0, -150.0));
		// lights
		var light = new HemisphericLight('light1', new Vector3(0, 1, 0), scene);
		light.intensity = 0.2;
		var pl = new PointLight('pl', camera.position, scene);
		pl.intensity = 0.9;
		// material
		var meshMat = new StandardMaterial("sm", scene);

		// scene and physics params
		var gravity = new Vector3(0, -0.01, 0);
		// init ball velocity and position
		var ballOrigin = new Vector3(-20.0, 60.0, 0.0);
		var restitution = 0.60;
		var speed = 0.05;
		var sceneLimit = ballOrigin.y + 2.0;

		// mesh
		//var model1 = MeshBuilder.CreateBox("m1",{size: 4.0}, scene);
		var model1 = MeshBuilder.CreateTorusKnot("m1", { radius: 8.0, tube: 1.2, radialSegments: 48 }, scene);
		var posfunc = function(p, _, _) {
			var x = (0.5 - Math.random()) * sceneLimit / 1.5;
			var y = (0.5 - Math.random()) * sceneLimit;
			var z = (0.5 - Math.random()) * sceneLimit / 1.5;
			p.position.x = x;
			p.position.y = y;
			p.position.z = z;
			p.rotation.x = 3.2 * Math.random();
			p.rotation.y = 3.2 * Math.random();
			p.rotation.z = 3.2 * Math.random();
			p.scaling.x = 0.5 + Math.random() * 0.5;
			p.scaling.y = p.scaling.x;
			p.scaling.z = p.scaling.x;
		};
		var meshSPS = new SolidParticleSystem("m", scene, {updatable: false});
		meshSPS.addShape(model1, 30, { positionFunction: posfunc });
		meshSPS.buildMesh();
		model1.dispose();

		meshSPS.refreshVisibleSize();
		var mesh = meshSPS.mesh;
		mesh.partitioningSubdivisions = 40;
		mesh.updateFacetData();

		// Balls
		var ballRadius = 1.0;
		var ballNb = 2000;
		var radiusSquared = ballRadius * ballRadius;
		var ball = MeshBuilder.CreateSphere('b', { diameter: ballRadius * 2.0, segments: 3 }, scene);
		//var ball = MeshBuilder.CreatePolyhedron('p', {size: ballRadius / 2.0}, scene);
		var sps = new SolidParticleSystem('sps', scene);
		sps.addShape(ball, ballNb);
		ball.dispose();
		sps.buildMesh();
		//sps.mesh.showBoundingBox = true;
		//sps.computeBoundingBox = true;
		sps.isAlwaysVisible = true;
		sps.computeParticleRotation = false;
		sps.computeParticleTexture = false;
		sps.recycleParticle = function(p:SolidParticle) {
			p.position.copyFrom(sps.vars.origin);
			p.velocity.x = (Math.random() - 0.5) * sps.vars.speed * 3.0 + sps.vars.speed * 3.0 ;
			p.velocity.z = (Math.random() - 0.5) * sps.vars.speed * 6.0;
			p.velocity.y = Math.random() * sps.vars.speed * 10.0;
			p.scaling.x = 1.0;
			p.scaling.y = p.scaling.x;
			p.scaling.z = p.scaling.x;
			return p;
		};
		sps.initParticles = function(origin:Vector3, speed:Float) {
			sps.vars.origin = origin.clone();
			sps.vars.speed = speed;
			for (p in 0...sps.nbParticles) {
				sps.recycleParticle(sps.particles[p]);
				sps.particles[p].color.r = 0.4 + Math.random() * 0.6;
				sps.particles[p].color.g = 0.4 + Math.random() * 0.6;
				sps.particles[p].color.b = 0.4 + Math.random() * 0.6;
				sps.particles[p].rotation.x = Math.random() * 3.2;
				sps.particles[p].rotation.y = Math.random() * 3.2;
				sps.particles[p].rotation.z = Math.random() * 3.2;
			}
		};
		
		// tmp vars
		var tmpDotVel = 0.0;                                // tmp dot facet normal * velocity
		var tmpDotPos = 0.0;                                // tmp dit facet normal * ball-facet vector
		var projected = Vector3.Zero();             // tmp projected vector
		var facetPosition = Vector3.Zero();         // tmp facet position
		var facetNorm = Vector3.Zero();             // tmp facet normal
		var normPos = Vector3.Zero();               // tmp vector to locate the ball on the normal from the projection
		var tmpVect = Vector3.Zero();               // tmp Vector3 : ball - projection
		
		// ball animation with custom simple physics
		// =========================================
		sps.updateParticle = function(p:SolidParticle) {			
			// check scene limits
			if (Math.abs(p.position.x) > sceneLimit || Math.abs(p.position.y) > sceneLimit || Math.abs(p.position.z) > sceneLimit) {
				sps.recycleParticle(p);
				return p;
			}
			
			// apply force and move the ball 
			p.velocity.addInPlace(gravity);                             // apply force : update velocity
			p.position.addInPlace(p.velocity);                          // apply velocity : update world position			
			var closest = mesh.getClosestFacetAtCoordinates(p.position.x, p.position.y, p.position.z, projected, true, true);
			// if we've found one facet in the mesh partitioning
			if (closest != null) {
				// get the impact facet normal and position
				mesh.getFacetNormalToRef(cast closest, facetNorm);
				mesh.getFacetPositionToRef(cast closest, facetPosition);
				
				p.position.subtractToRef(projected, tmpVect);           // tmpVect is the vector ball-projection
				
				// if the distance between the ball and the facet is lower than the ball radius, then collision
				if (tmpVect.lengthSquared() < radiusSquared) {   
					// bounce result computation
					tmpDotVel = Vector3.Dot(p.velocity, facetNorm);                   // dot product (velocity, normal)
					p.velocity.x = (p.velocity.x - 2.0 * tmpDotVel * facetNorm.x) * restitution;
					p.velocity.y = (p.velocity.y - 2.0 * tmpDotVel * facetNorm.y) * restitution;
					p.velocity.z = (p.velocity.z - 2.0 * tmpDotVel * facetNorm.z) * restitution;
					
					facetNorm.scaleToRef(ballRadius * 1.01, normPos);                       // reset the ball at distance ballRadius on the facet 
					projected.addToRef(normPos, p.position);
				}
			}
			p.scaling.x = 0.4 + Math.abs(p.velocity.x);                                     // scale the ball according to its velocity
			p.scaling.y = 0.4 + Math.abs(p.velocity.y);
			p.scaling.z = 0.4 + Math.abs(p.velocity.z);
			
			return p;
		};
		
		//scene.debugLayer.show();
		sps.initParticles(ballOrigin, speed);
		sps.setParticles();
		var k = 0.0;
		scene.registerBeforeRender(function(_, _) {
			mesh.rotation.y += 0.01;
			mesh.rotation.x = 0.6 * Math.sin(k);
			sps.setParticles();
			k += 0.02;
		});
		
		scene.onDisposeObservable.add(function(_, _) {
			mesh.disableFacetData();
		});
		
		scene.getEngine().runRenderLoop(function() {
            scene.render();
        });
	}
	
}
