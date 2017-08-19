package textures.procedural.coherentnoise.generation.displacement;

import math.Quat;
import math.Vec3;

/// <summary>
/// This generator rotates its source around origin.
/// </summary>
class Rotate extends Generator {

	private var m_Source:Generator;
	private var m_Rotation:Quat;

	///<summary>
	/// Create new rotation using a quaternion
	///</summary>
	///<param name="source">Source generator</param>
	///<param name="rotation">Rotation</param>
	public function new(source:Generator, rotation:Quat) {
		super();

		m_Source = source;
		m_Rotation = rotation;
	}

	// #region Overrides of Noise

	/// <summary>
	///  Returns noise value at given point. 
	///  </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param><returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var v = m_Rotation.multVector(new Vec3(x, y, z));

		return m_Source.GetValue(v.x, v.y, v.z);
	}

	//	#endregion
	
}
