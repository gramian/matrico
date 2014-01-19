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

	function size(m,d)
	{
		m = m|0;
		d = d|0;

		return ~~+mem[(m - d<<3)>>3]|0;
	}

	function get(m,i,j)
	{
		m = m|0;
		i = i|0;
		j = j|0;

		var r = 0, c = 0, p = 0;
		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		p = ((imul(i,r)|0)+j)|0;

		return +mem[(m + p<<3)>>3];		
	}

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
		size : size,
		get : get,
		zeros : zeros
	};

})(window, document, heap);

function echo(m)
{
	var o = "";

	var r = matrico.size(m,1);
	var c = matrico.size(m,2);

	for(var i=0;i<r;i++)
	{
		for(var j=0;j<c;j++)
		{
			o = o + matrico.get(m,i,j).toFixed(4) + " ";
		}
		o = o + "\n";
	}

	return o;
}

