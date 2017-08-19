package com.babylonhx.math.coherentnoise.generation;

import com.babylonhx.math.coherentnoise.interpolation.SCurve;

/// <summary>
/// This is the same noise as <see cref="GradientNoise"/>, but it does not change in Z direction. This is more efficient if you're only interested in 2D noise anyway.
/// </summary>
class GradientNoise2D extends Generator {

	// 256 random vectors
	private static var Vectors:Array<Float> = [
		-0.731431341826129, 0.68191509163123,
		0.850826255327452, -0.525447126974223,
		0.951901184669578, -0.306405180479466,
		0.847375274477774, -0.530994486038901,
		0.848652296864435, 0.528951112132982,
		0.367039509662365, 0.930205352783358,
		0.993031254071925, -0.117851297983264,
		-0.671151386173851, -0.741320319994615,
		-0.520675077759241, -0.853754919986063,
		0.797453600237253, -0.603380274344997,
		0.261253746745916, 0.965270158976864,
		-0.4665434272427, 0.884498293099899,
		0.988416259834662, -0.151767247107068,
		0.243393593738193, 0.96992760478667,
		0.366768847231788, -0.93031210499502,
		0.411298702005218, -0.911500618611322,
		0.207341022783915, -0.978268726000643,
		-0.738546389576949, 0.674202662737885,
		-0.394654589200276, -0.918829557221121,
		-0.571211615051746, 0.820802833103039,
		-0.322822891839912, -0.946459391893871,
		0.297290895653234, -0.95478695181789,
		0.955458211448602, -0.295126424054909,
		0.144935573935015, 0.989441094460973,
		-0.472190238715513, 0.881496669569311,
		-0.999147653977811, -0.0412791176097179,
		-0.0566039180894319, -0.998396712963802,
		0.838467522782852, 0.544951569626502,
		0.748568021004782, -0.663058004950535,
		-0.527875842628975, 0.849321549690545,
		0.357699899706583, 0.933836592638081,
		0.349221591518296, -0.93704016990598,
		0.989238396385076, 0.146312662191223,
		0.333538104376736, -0.942736619066414,
		0.234353839405063, 0.972151365763638,
		0.62765151947276, 0.778494425223158,
		-0.179494348130198, 0.983759004527692,
		-0.659780814342818, 0.751458100645091,
		-0.718415278792677, -0.69561446735763,
		-0.998033869930316, -0.0626769054111391,
		0.673068523904019, -0.739580125564272,
		-0.739350670868863, 0.673320566658826,
		-0.933271553810173, 0.359171556291344,
		-0.662381939929279, 0.749166313748507,
		-0.0801366250317778, -0.996783888979209,
		0.29025385297949, -0.956949685631675,
		-0.54032917870841, -0.841453729349568,
		-0.692344483921232, -0.721567124794252,
		-0.887159876903364, 0.461462190014316,
		-0.991828148906124, 0.12758104497711,
		0.0810979161066969, -0.99670613924223,
		-0.539198809344358, 0.842178510769318,
		0.969429412401646, 0.245370361638484,
		0.955780929362972, 0.294079606681682,
		0.806781534755456, 0.590849858405357,
		-0.868531510457536, -0.495633952975733,
		0.968002263782507, -0.250941461922778,
		-0.165205532592608, -0.986259160667617,
		-0.868192204140243, -0.496228069208208,
		-0.86976358662251, -0.493468644784598,
		-0.949489840940752, 0.313797772379451,
		0.768401205829135, -0.63996842647144,
		-0.010864092537854, -0.999940984005221,
		-0.450260656290424, 0.892897161714,
		-0.278209506633843, -0.960520416450662,
		-0.813261464544128, 0.581898436402385,
		-0.332109371842527, 0.943240883939178,
		0.472751027063131, 0.881196043120233,
		0.999956668864357, -0.00930915644399175,
		-0.494039763195941, -0.869439309199497,
		-0.970522733594673, -0.241009592290273,
		-0.87192758761998, 0.489634845519804,
		0.0615978842377382, -0.998101047318073,
		0.451468040192217, 0.892287290442377,
		-0.991514020949566, 0.129999793309158,
		-0.398591252415884, 0.91712867881096,
		-0.620385451531012, 0.784297068417741,
		-0.853977038819679, -0.520310692921809,
		-0.997873589794849, 0.0651789750605269,
		-0.980602996956203, -0.196004495766075,
		0.574603098739222, -0.818432207894633,
		0.75959965603487, 0.650390930557697,
		-0.492380199527919, -0.870380226747395,
		-0.82704446775552, 0.562136503311241,
		-0.889333633567567, -0.457258885321551,
		0.593585750865447, -0.80477074770987,
		0.108623796903932, -0.994082929511504,
		0.988522764008209, -0.151071986276644,
		-0.287923414140447, -0.957653438144357,
		-0.685374918424191, -0.728190374280678,
		0.41221156255193, 0.911088155832626,
		-0.94058787072448, -0.339550375417241,
		0.199921957079754, -0.979811824320058,
		0.968115378066659, 0.250504720017107,
		0.927955147115966, 0.372691890092857,
		0.990494594580402, -0.137551656140541,
		-0.665248455869535, -0.746622054297353,
		0.740918725496693, 0.671594700848924,
		-0.535308586961631, -0.844656567324935,
		-0.514854957391123, 0.857277302189778,
		-0.999030092148431, 0.0440326581289129,
		-0.996926870958181, 0.078337819484146,
		-0.685597302598936, -0.727981001585249,
		0.0370788877945427, -0.999312341602924,
		0.931843510698615, -0.362860402315931,
		-0.558733566868429, 0.829347213930621,
		-0.873792759466752, -0.486298481905381,
		0.656607252062933, -0.754232667376828,
		-0.909439904334537, -0.415835376566243,
		0.220309287650761, -0.975430068110889,
		0.150100056956946, 0.988670811191228,
		-0.696084180859879, 0.717960175188451,
		0.100570876625785, 0.994929896412165,
		0.948614809804062, 0.316433156638814,
		-0.095898219566003, -0.99539114496969,
		-0.517140931402395, 0.855900261168475,
		0.178670325099743, 0.98390899728011,
		-0.55311824063568, 0.833102761894408,
		-0.00785321536084002, -0.999969163028789,
		0.60785753484444, -0.79404610529417,
		-0.666794850491482, -0.745241321558354,
		-0.470794948080833, 0.882242663251764,
		-0.979996510123714, 0.199014673191053,
		-0.678566382235446, 0.734539083303195,
		-0.995784759576747, 0.0917208405689818,
		0.994696809022833, -0.102850659306556,
		-0.654067480988245, -0.756436203730158,
		-0.19039516442027, -0.981707533517686,
		0.751490328435529, 0.659744106656407,
		-0.999970965068827, -0.00762030309888781,
		-0.419586283036086, -0.90771545711636,
		0.0670745569756537, 0.99774796607486,
		0.896625085774033, -0.442790532374742,
		0.569636620454938, 0.821896660558173,
		0.971021303456385, 0.238992945991848,
		-0.636951463831028, 0.770903906283728,
		-0.994251716281941, 0.107067850778906,
		0.851524792305273, -0.524314340915315,
		-0.974653098085159, 0.223721564434458,
		0.117674170632817, 0.99305225923205,
		-0.127312138335695, 0.991862701906062,
		0.821092992312965, -0.570794444589767,
		-0.836180971630179, 0.548453628562716,
		0.87069175612852, -0.491829102239623,
		-0.822815382334055, 0.568308759913537,
		0.367191064113784, -0.93014553830838,
		-0.432424566542929, 0.901670113872119,
		-0.120396019190764, -0.992725943331299,
		-0.3421907211692, 0.939630517994016,
		-0.160896503013349, -0.986971283937925,
		0.0416336791557611, -0.999132942485611,
		-0.254051840030241, 0.967190603023648,
		-0.677392585218673, 0.73562169998632,
		0.34530489954395, -0.93849055741171,
		-0.295575835287478, -0.955319279400405,
		0.509185809941917, 0.860656616168024,
		0.992575229930708, 0.121632285713957,
		-0.0695072162716299, 0.997581448748005,
		-0.12858035933064, 0.991699093069265,
		0.964222198214983, -0.26509536485851,
		-0.261898801454652, -0.965095341298784,
		0.643768799332641, -0.765220055282015,
		-0.00416655784368122, -0.999991319860195,
		0.912582290418183, 0.408893095093452,
		0.792974195036607, 0.609255222387174,
		0.996512185806037, -0.0834473698811023,
		-0.942032506564994, 0.335521618640103,
		0.87501841362795, 0.484089636133666,
		0.996750481408581, 0.0805510882096704,
		-0.706268410606012, 0.707944158941973,
		0.605807660050887, -0.795611135557861,
		-0.363735385957895, 0.931502318302033,
		0.725481460068661, -0.688241709791439,
		-0.993945757112509, -0.109871888661487,
		-0.86497235799957, -0.501819509282633,
		-0.122120972824683, -0.99251522305522,
		0.877538967058075, -0.479505329787529,
		-0.951156090447505, -0.308710368476048,
		0.975779852778161, -0.218754837460183,
		-0.450956996122408, -0.892545678185859,
		-0.522868702172098, -0.85241323329056,
		0.829680964911082, -0.558237849365497,
		-0.85729089961775, 0.514832315839429,
		-0.772060653910783, 0.635548854678265,
		-0.0340187744669282, -0.999421193983682,
		-0.771337193085491, 0.636426692214426,
		0.688529247409745, -0.725208573764382,
		0.725163768716788, 0.688576436236722,
		-0.953544545407338, 0.301252053808622,
		0.700121129056667, -0.714024092484573,
		-0.538455441479676, 0.842653984468671,
		0.175916570766405, 0.984405079288902,
		-0.629451420142488, -0.777039837898036,
		-0.999089702483185, -0.0426587200002751,
		-0.989208833301989, -0.146512402605778,
		-0.840952814021566, 0.541108459173583,
		0.567368358566675, 0.823464113181235,
		-0.538825044596127, 0.842417694090041,
		0.390786645379538, -0.920481285954803,
		-0.867369426459715, 0.497664825000668,
		-0.657989855099474, 0.75302679274125,
		0.0581096991068076, 0.99831020372914,
		-0.199969945117378, -0.979802031560331,
		0.90688443354178, -0.42137943020466,
		0.687773009975965, -0.725925813529593,
		-0.945838294573846, 0.324638137805216,
		-0.849970814157478, 0.526829778088211,
		0.592467340459703, -0.805594470244556,
		0.172273677799394, 0.985049125646772,
		0.98426493623182, -0.176698996331532,
		0.034140955127593, 0.999417027663115,
		-0.981643122917266, 0.190726975620226,
		-0.286049508934714, 0.958214839395743,
		-0.827152526975724, -0.561977488087979,
		-0.278190812296812, 0.960525830966372,
		0.321460297459343, -0.946923057675412,
		-0.945857146313334, 0.324583207772671,
		-0.632326502652004, 0.774702003381871,
		-0.439701356430231, 0.898144040315035,
		-0.22390420389053, -0.974611157067344,
		0.746644533423535, 0.665223226224665,
		-0.452095562270814, 0.891969507648684,
		-0.688536038333179, -0.725202126249263,
		0.640330654773997, 0.768099376745421,
		0.976846035149785, 0.213943505655453,
		-0.676632036881798, -0.736321320257121,
		-0.494860655167783, -0.868972342463736,
		-0.695461545706562, 0.718563315542507,
		0.999317517145356, -0.036939138138857,
		0.455862157059439, 0.89005038832704,
		-0.886588243870148, -0.46255949436937,
		-0.876783747283401, -0.480884872396375,
		-0.0875369808558837, -0.996161270569498,
		-0.95522819915781, -0.295870051768894,
		-0.375385680884685, 0.92686870191346,
		-0.881356571543301, 0.472451684087843,
		0.381051321883982, 0.924553887066876,
		-0.994403519779731, 0.105648662318475,
		-0.992363799194351, -0.123345409515526,
		-0.292273975672636, 0.956334629271842,
		0.990902635025559, -0.134580711468633,
		0.9921551088401, 0.12501295933818,
		0.803208245899664, -0.59569834120869,
		-0.99177139673035, 0.128021469400765,
		-0.689705032139782, -0.724090442307494,
		0.689287927077946, -0.724487510992831,
		0.892950706269959, -0.45015445812741,
		0.957331229025545, 0.288992937513079,
		0.236962773414951, 0.971518730656025,
		-0.179255393539833, -0.983802573632982,
		0.971055948286095, -0.238852141079356,
		0.279177248306704, -0.960239586784411,
		0.993534534390401, 0.113530299804277,
		0.809612558438491, 0.586964654147659,
		-0.316558440259375, 0.948573009262098,
		0.969151231077369, 0.246466815821563,
	];

	private var m_Seed:Int;
	private var m_SCurve:SCurve;

	/// <summary>
	/// Create new generator with specified seed and interpolation algorithm. Different interpolation algorithms can make noise smoother at the expense of speed.
	/// </summary>
	/// <param name="seed">noise seed</param>
	/// <param name="sCurve">Interpolator to use. Can be null, in which case default will be used</param>
	public function new(seed:Int, ?sCurve:SCurve) {
		m_Seed = seed;
		m_SCurve = sCurve;
	}

	/// <summary>
	/// Noise period. Used for repeating (seamless) noise.
	/// When Period &gt;0 resulting noise pattern repeats exactly every Period, for all coordinates.
	/// </summary>
	public var Period:Int;

	public var SCurve(get, never):SCurve;
	inline private function get_SCurve():SCurve { 
		return m_SCurve != null ? m_SCurve : SCurve.Default; 
	}

	// #region Implementation of Noise

	/// <summary>
	/// Returns noise value at given point. 
	/// </summary>
	/// <param name="x">X coordinate</param>
	/// <param name="y">Y coordinate</param>
	/// <param name="z">Z coordinate</param>
	/// <returns>Noise value</returns>
	override public function GetValue(x:Float, y:Float, z:Float):Float {
		var ix = Math.floor(x);
		var iy = Math.floor(y);

		// interpolate the coordinates instead of values - this way we need only 4 calls instead of 7
		var xs = SCurve.Interpolate(x - ix);
		var ys = SCurve.Interpolate(y - iy);

		// THEN we can use linear interp to find our value - triliear actually

		var n0 = GetNoise(x, y, ix, iy);
		var n1 = GetNoise(x, y, ix + 1, iy);
		var ix0 = math.Tools.Lerp(n0, n1, xs);

		n0 = GetNoise(x, y, ix, iy + 1);
		n1 = GetNoise(x, y, ix + 1, iy + 1);
		var ix1 = math.Tools.Lerp(n0, n1, xs);

		return math.Tools.Lerp(ix0, ix1, ys);
	}

	function GetRandomVector(x:Int, y:Int):Vec2 {
		if (Period > 0) {
			// make periodic lattice. Repeat every Period cells
			x = x % Period; 
			if (x < 0) {
				x += Period;
			}
			
			y = y % Period; 
			if (y < 0) {
				y += Period;
			}
		}
		
		var vectorIndex = (
			Constants.MultiplierX * x
			+ Constants.MultiplierY * y
			+ Constants.MultiplierSeed * m_Seed)
			& 0x7fffffff;
		vectorIndex = (((vectorIndex >> Constants.ValueShift) ^ vectorIndex) & 0xff) * 2;
		
		return new Vec2(Vectors[vectorIndex], Vectors[vectorIndex + 1]);
	}

	private function GetNoise(x:Float, y:Float, ix:Int, iy:Int):Float {
		var gradient = GetRandomVector(ix, iy);
		return Vec2.Dot(gradient, new Vec2(x - ix, y - iy)) * 2.12; // scale to [-1,1]
	}

	// #endregion
}
