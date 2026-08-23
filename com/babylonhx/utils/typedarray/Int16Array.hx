package com.babylonhx.utils.typedarray;

/**
 * @author Krtolica Vujadin
 */

// NOTE: OpenFL is built on Lime and defines both, and the lime branch below is
// matched first, so an OpenFL build already resolves to the Lime types. That is
// also the right answer - the openfl.utils._internal typed arrays are themselves
// typedefs of the lime.utils ones.

#if purejs

	typedef Int16Array = js.html.Int16Array;

#elseif snow

	typedef Int16Array = snow.api.buffers.Int16Array;
	
#elseif lime

	typedef Int16Array = lime.utils.Int16Array;
	
#elseif nme

	typedef Int16Array = nme.utils.Int16Array;

#elseif kha



#end
