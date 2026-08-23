package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef UInt32Array = js.html.Uint32Array;

#elseif snow
 
	typedef UInt32Array = snow.api.buffers.UInt32Array;
	
#elseif lime

	typedef UInt32Array = lime.utils.UInt32Array;
	
#elseif nme

	typedef UInt32Array = nme.utils.UInt32Array;

#elseif kha



#end