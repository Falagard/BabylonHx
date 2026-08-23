package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef UInt8Array = js.html.Uint8Array;

#elseif snow

	typedef UInt8Array = snow.api.buffers.Uint8Array;
	
#elseif lime

	typedef UInt8Array = lime.utils.UInt8Array;

#elseif nme

	typedef UInt8Array = nme.utils.UInt8Array;

#elseif kha



#end
