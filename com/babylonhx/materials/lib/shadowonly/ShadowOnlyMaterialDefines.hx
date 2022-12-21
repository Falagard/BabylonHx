package com.babylonhx.materials.lib.shadowonly;

/**
 * ...
 * @author Krtolica Vujadin
 */
class ShadowOnlyMaterialDefines extends MaterialDefines {
	
	//public var CLIPPLANE:Bool = false;
	public var POINTSIZE:Bool = false;
	public var FOG:Bool = false;
	public var NORMAL:Bool = false;
	public var NUM_BONE_INFLUENCERS:Int = 0;
	public var BonesPerMesh:Int = 0;
	//public var INSTANCES:Bool = false;
	
	// BHX: not used but needed by MaterialHelper
	public var ALPHATEST:Bool = false;
	//public var DEPTHPREPASS:Bool = false;
	public var LOGARITHMICDEPTH:Bool = false;
	public var NONUNIFORMSCALING:Bool = false;
	public var SHADOWS:Bool = false;
	public var SHADOWFLOAT:Bool = false;
	public var UV1:Bool = false;
	public var UV2:Bool = false;
	

	public function new() {
		super(); 
		this.CLIPPLANE = 0;
		this.INSTANCES = 0;
		this.DEPTHPREPASS = 0;
	}
	
	override public function isEqual(other:MaterialDefines):Bool {
		if (super.isEqual(other)) {
			if (untyped this.CLIPPLANE != other.CLIPPLANE) return false; 
			if (untyped this.POINTSIZE != other.POINTSIZE) return false; 
			if (untyped this.FOG != other.FOG) return false;
			if (untyped this.NORMAL != other.NORMAL) return false; 
			if (untyped this.NUM_BONE_INFLUENCERS != other.NUM_BONE_INFLUENCERS) return false; 
			if (untyped this.BonesPerMesh != other.BonesPerMesh) return false;
			if (untyped this.INSTANCES != other.INSTANCES) return false;
			
			return true;
		}
		
		return false;
	}
	
	override public function cloneTo(other:MaterialDefines) {
		super.cloneTo(other);
		
		untyped other.CLIPPLANE = this.CLIPPLANE;
		untyped other.POINTSIZE = this.POINTSIZE;
		untyped other.FOG = this.FOG;
		untyped other.NORMAL = this.NORMAL;
		untyped other.NUM_BONE_INFLUENCERS = this.NUM_BONE_INFLUENCERS;
		untyped other.BonesPerMesh = this.BonesPerMesh;
		untyped other.INSTANCES = this.INSTANCES;
	}
	
	override public function reset() {
		super.reset();
		
		this.CLIPPLANE = 0;
		this.POINTSIZE = false;
		this.FOG = false;
		this.NORMAL = false;
		this.NUM_BONE_INFLUENCERS = 0;
		this.BonesPerMesh = 0;
		this.INSTANCES = 0;
	}
	
	override public function toString():String {
		var result = super.toString();
		
		if (this.CLIPPLANE != 0) {
			result += "#define CLIPPLANE \n";
		}
		if (this.POINTSIZE) {
			result += "#define POINTSIZE \n";
		}
		if (this.FOG) {
			result += "#define FOG \n";
		}
		if (this.NORMAL) {
			result += "#define NORMAL \n";
		}
		if (this.INSTANCES != 0) {
			result += "#define INSTANCES \n";
		}
		
		result += "#define BonesPerMesh " + this.BonesPerMesh + "\n";
		result += "#define NUM_BONE_INFLUENCERS " + this.NUM_BONE_INFLUENCERS + "\n";
		
		return result;
	}
	
}