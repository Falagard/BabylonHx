package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef UInt8ClampedArray = js.html.Uint8ClampedArray;

#elseif snow

	typedef UInt8ClampedArray = snow.api.buffers.UInt8ClampedArray;
	
#elseif lime

	typedef UInt8ClampedArray = lime.utils.UInt8ClampedArray;

#elseif nme

	typedef UInt8ClampedArray = nme.utils.UInt8ClampedArray;

#elseif kha



#end
