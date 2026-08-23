package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef UInt16Array = js.html.Uint16Array;

#elseif snow

	typedef UInt16Array = snow.api.buffers.UInt16Array;
	
#elseif lime

	typedef UInt16Array = lime.utils.UInt16Array;
	
#elseif nme

	typedef v = nme.utils.UInt16Array;

#elseif kha



#end
