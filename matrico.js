"use strict";

var MATRICO_VERSION = '0.1.0';

var size = 65536;
var heap = new ArrayBuffer(size);

var matrico = (function(stdlib,foreign,heap)
{
	"use asm";

	var mem = new stdlib.Float64Array(heap);
	var ptr = 0;

	var seed = 1.0;

	var imul = stdlib.Math.imul;
	var sin  = stdlib.Math.sin;

	var floor = stdlib.Math.floor;

	// private:

	function rnd()
	{
		var x = 0.0;

		seed = +(seed + 1.0);

		x = +sin(seed)*10000.0;

		return +(x - +floor(x));
	}

	// public:

	function size(m,d)
	{
		m = m|0;
		d = d|0;

		return ~~+mem[(m - d<<3)>>3]|0;
	}

	function numel(m)
	{
		m = m|0;

		var r = 0, c = 0;
		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];

		return imul(r,c)|0;
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

	function ones(r,c)
	{
		r = r|0;
		c = c|0;

		var m = 0, t = 0, i = 0;
		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0)
		{
			mem[(m + i<<3)>>3] = 1.0;
		}

		return m|0;
	}

	function eye(r)
	{
		r = r|0;

		var m = 0, t = 0, i = 0;
		m = zeros(r,r)|0;
		t = imul(r,r)|0;

		for(;(i|0)<(t|0);i=(i+r+1)|0)
		{
			mem[(m + i<<3)>>3] = 1.0;
		}

		return m|0;
	}

	function rand(r,c)
	{
		r = r|0;
		c = c|0;

		var m = 0, t = 0, i = 0;
		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0)
		{
			mem[(m + i<<3)>>3] = +rnd();
		}

		return m|0;
	}

	function randn(r,c)
	{
		r = r|0;
		c = c|0;

		var m = 0, t = 0, i = 0;
		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0)
		{
			mem[(m + i<<3)>>3] = (+rnd()*2.0-1.0)+(+rnd()*2.0-1.0)+(+rnd()*2.0-1.0);
		}

		return m|0;
	}

	return {
		size  : size,
		numel : numel,
		get   : get,
		zeros : zeros,
		ones  : ones,
		eye   : eye,
		rand  : rand,
		randn : randn
	};

})(window, document, heap);

function echo(m)
{
	var o = "";

	var r = matrico.size(m,1);
	var c = matrico.size(m,2);
	var v = 0;

	for(var i=0;i<r;i++)
	{
		o += " ";
		for(var j=0;j<c;j++)
		{
			v = matrico.get(m,i,j);
			if(v>=0) { o += " "; }
			o += v.toFixed(4) + " ";
		}
		o = o + "\n";
	}
	o = o + "\n";

	return o;
}

