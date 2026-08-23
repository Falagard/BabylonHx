package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef ArrayBuffer = js.html.ArrayBuffer;

#elseif snow

	typedef ArrayBuffer = snow.api.buffers.ArrayBuffer;
	
#elseif lime

	typedef ArrayBuffer = lime.utils.ArrayBuffer;
	
#elseif nme

	typedef ArrayBuffer = nme.utils.ArrayBuffer;

#elseif kha



#end