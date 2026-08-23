package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef Int32Array = js.html.Int32Array;

#elseif snow
 
	typedef Int32Array = snow.api.buffers.Int32Array;
	
#elseif lime

	typedef Int32Array = lime.utils.Int32Array;
	
#elseif nme

	typedef Int32Array = nme.utils.Int32Array;

#elseif kha



#end
