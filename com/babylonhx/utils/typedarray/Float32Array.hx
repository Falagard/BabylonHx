package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef Float32Array = js.html.Float32Array;

#elseif snow

	typedef Float32Array = snow.api.buffers.Float32Array;
	
#elseif lime

	typedef Float32Array = lime.utils.Float32Array;
	
#elseif nme

	typedef Float32Array = nme.utils.Float32Array;

#elseif kha



#end
