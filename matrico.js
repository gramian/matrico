"use strict";

var MATRICO_VERSION = '0.1.0';

var size = 65536;
var heap = new ArrayBuffer(size);

var matrico = (function(stdlib,foreign,heap)
{
	"use asm";

	var mem = new stdlib.Float64Array(heap);
	var ptr = 0;

	var imul   = stdlib.Math.imul;

	function zeros(r,c)
	{
		r = r|0;
		c = c|0;

		var m = 0, t = 0;
		m = (ptr + 2)|0;
		t = imul(r,c)|0;

		mem[(ptr + 0<<3)>>3] = +~~r;
		mem[(ptr + 1<<3)>>3] = +~~c;
		ptr = (ptr + t + 2)|0;

		return m|0;
	}

	return {
		zeros : zeros
	};

})(window, null, heap);
