"use strict";

var MATRICO_VERSION = '0.1.0';

var size = 16*1024*1024;
var heap = new ArrayBuffer(size);

var matrico = (function(stdlib,foreign,heap)
{
	"use asm";

	var mem = new stdlib.Float64Array(heap);
	var ptr = 0;

	var seed = 1.0;

	var imul       = stdlib.Math.imul;
	var math_abs   = stdlib.Math.abs;
	var math_sin   = stdlib.Math.sin;
	var math_cos   = stdlib.Math.cos;
	var math_tan   = stdlib.Math.tan;
	var math_asin  = stdlib.Math.asin;
	var math_acos  = stdlib.Math.acos;
	var math_atan  = stdlib.Math.atan;
	var math_sqrt  = stdlib.Math.sqrt;
	var math_exp   = stdlib.Math.exp;
	var math_log   = stdlib.Math.log;
	var math_pow   = stdlib.Math.pow;
	var math_ceil  = stdlib.Math.ceil;
	var math_floor = stdlib.Math.floor;

	var floor = stdlib.Math.floor;

	// private:

	function rnd()
	{
		var x = 0.0;

		seed = +(seed + 1.0);

		x = +math_sin(seed)*10000.0;

		return +(x - +floor(x));
	}

	// public:

	function size(m,d) { m = m|0; d = d|0;

		return ~~+mem[(m - d<<3)>>3]|0;	}


	function numel(m) { m = m|0;

		var r = 0, c = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];

		return imul(r,c)|0; }


	function at(m,i,j) { m = m|0; i = i|0; j = j|0;

		var r = 0, c = 0, p = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		p = ((imul(i,r)|0)+j)|0;

		return +mem[(m + p<<3)>>3]; }


	/*function row(m,i) {

	}*/


	/*function col(m,i) {

	}*/


	/*function page(m,i) {

	}*/

	// global:

//	###  ###  ###  ###  ###
//	  #  #    # #  # #  #
//	 #   ##   ###  # #  ###
//	#    #    ##   # #    #
//	###  ###  # #  ###  ###

	function zeros(r,c) { r = r|0; c = c|0;

		var m = 0, t = 0;

		m = (ptr + 2)|0;
		t = imul(r,c)|0;
		mem[(ptr + 0<<3)>>3] = +~~r;
		mem[(ptr + 1<<3)>>3] = +~~c;
		ptr = (ptr + t + 2)|0;

		return m|0; }

//	###  #   #  ###  ###
//	# #  ##  #  #    #
//	# #  # # #  ##   ###
//	# #  #  ##  #      #
//	###  #   #  ###  ###

	function ones(r,c) { r = r|0; c = c|0;

		var m = 0, t = 0, i = 0;

		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(m + i<<3)>>3] = 1.0; }

		return m|0; }

//	###  # #  ###
//	#    # #  #
//	##   ###  ##
//	#     #   #
//	###   #   ###

	function eye(r) { r = r|0;

		var m = 0, t = 0, i = 0;

		m = zeros(r,r)|0;
		t = imul(r,r)|0;

		for(;(i|0)<(t|0);i=(i+r+1)|0) { mem[(m + i<<3)>>3] = 1.0; }

		return m|0; }

//	###  ###  #   #  ##
//	# #  # #  ##  #  # #
//	###  ###  # # #  # #
//	##   # #  #  ##  # #
//	# #  # #  #   #  ##

	function rand(r,c) { r = r|0; c = c|0;

		var m = 0, t = 0, i = 0;

		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(m + i<<3)>>3] = +rnd(); }

		return m|0; }

//	###  ###  #   #  ##   #   #
//	# #  # #  ##  #  # #  ##  #
//	###  ###  # # #  # #  # # #
//	##   # #  #  ##  # #  #  ##
//	# #  # #  #   #  ##   #   #

	function randn(r,c) { r = r|0; c = c|0;

		var m = 0, t = 0, i = 0;

		m = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(m + i<<3)>>3] = (+rnd()*2.0-1.0)+(+rnd()*2.0-1.0)+(+rnd()*2.0-1.0); }

		return m|0; }

//	# #  ###  ###
//	# #  #    #
//	# #  ##   #
//	# #  #    #
//	 #   ###  ###

	function vec(m) { m = m|0;

		var r = 0, c = 0, t = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		t = imul(r,c)|0;

		mem[(m - 2<<3)>>3] = +~~t;
		mem[(m - 1<<3)>>3] = 1.0; }

//	# #  #   #  ###  #  #  # #  ###
//	# #  ## ##   #   ## #  # #  #
//	# #  # # #   #   ## #  # #  ###
//	# #  # # #   #   # ##  # #    #
//	###  #   #  ###  #  #  ###  ###

	function uminus(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = -mem[(m + i<<3)>>3]; }

		return o|0; }

//	###  ###  ###
//	# #  # #  #
//	###  ###  ###
//	# #  # #    #
//	# #  ###  ###

	function abs(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_abs(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  ###  #   #
//	#     #   #    ##  #
//	###   #   # #  # # #
//	  #   #   # #  #  ##
//	###  ###  ###  #   #

	function sign(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +~~(+mem[(m + i<<3)>>3]>0.0) - +~~(+mem[(m + i<<3)>>3]<0.0); }

		return o|0; }

//	###  ###  #   #
//	#     #   ##  #
//	###   #   # # #
//	  #   #   #  ##
//	###  ###  #   #

	function sin(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_sin(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  ###
//	#    # #  #
//	#    # #  ###
//	#    # #    #
//	###  ###  ###

	function cos(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_cos(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  #   #
//	 #   # #  ##  #
//	 #   ###  # # #
//	 #   # #  #  ##
//	 #   # #  #   #

	function tan(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_tan(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  ###  #   #
//	# #  #     #   ##  #
//	###  ###   #   # # #
//	# #    #   #   #  ##
//	# #  ###  ###  #   #

	function asin(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_asin(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  ###  ###
//	# #  #    # #  #
//	###  #    # #  ###
//	# #  #    # #    #
//	# #  ###  ###  ###

	function acos(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_acos(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  ###  #   #
//	# #   #   # #  ##  #
//	###   #   ###  # # #
//	# #   #   # #  #  ##
//	# #   #   # #  #   #

	function atan(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_atan(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  ###  #   #  # #
//	#     #   ##  #  # #
//	###   #   # # #  ###
//	  #   #   #  ##  # #
//	###  ###  #   #  # #

	function sinh(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = 0.5*(+math_exp(+mem[(m + i<<3)>>3])- +math_exp(-mem[(m + i<<3)>>3])); }

		return o|0; }

//	###  ###  ###  # #
//	#    # #  #    # #
//	#    # #  ###  ###
//	#    # #    #  # #
//	###  ###  ###  # #

	function cosh(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = 0.5*(+math_exp(+mem[(m + i<<3)>>3])+ +math_exp(-mem[(m + i<<3)>>3])); }

		return o|0; }

//	###  ###  #   #  # #
//	 #   # #  ##  #  # #
//	 #   ###  # # #  ###
//	 #   # #  #  ##  # #
//	 #   # #  #   #  # #

	function tanh(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = (+math_exp(2.0* +mem[(m + i<<3)>>3])-1.0)/(+math_exp(2.0* +mem[(m + i<<3)>>3])+1.0); }

		return o|0; }

//	###  ###  ###  ###
//	#    # #  # #   #
//	###  # #  ###   #
//	  #  ###  ##    #
//	###    #  # #   #

	function sqrt(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_sqrt(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	###  # #  ###
//	#    # #  # #
//	##    #   ###
//	#    # #  #
//	###  # #  #

	function exp(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_exp(+mem[(m + i<<3)>>3]); }

		return o|0; }

//	#    ###  ###
//	#    # #  #
//	#    # #  # #
//	#    # #  # #
//	###  ###  ###

	function log(m) { m = m|0;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_log(+mem[(m + i<<3)>>3]); }

		return o|0; }

	// ######## ######## ######## ######## ########

	/*function plus(m,n) {

	}*/


	/*function minus(m,n) {

	}*/


	/*function times(m,n) {

	}*/


	/*function mtimes(m,n) {

	}*/


	/*function dot(m,n) {

	}*/


	/*function sum(m) {

	}*/


	/*function prod(m) {

	}*/


	/*function repmat(m,a,b)
	{
		m = m|0; a = a|0; b = b|0;
		var r = 0; c = 0; o = 0; p = 0 ; t = 0; i = 0; j = 0; k = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(imul(a,r),imul(b,c));
		t = imul(r,c)|0;

		for(;(i|0)<(a|0);i=(i+1)|0)
		{
			for(;(j|0)<(b|0);j=(j+1)|0)
			{
				p = 
				for(;(k|0)<(k|0);k=(k+1)|0)
				{
					mem[(p + k<<3)>>3] = +mem[(m + k<<3)>>3];
				}
			}
		}


		return o|0;
	}*/

	/*function mean(m) {

	}*/


	/*function median(m) {

	}*/


	/*function svd(m,n) {

	}*/


	/*function eig(m,n) {

	}*/


	/*function speye(m) {

	}*/


	return {
		size   : size,
		numel  : numel,
		at     : at,
		zeros  : zeros,
		ones   : ones,
		eye    : eye,
		rand   : rand,
		randn  : randn,
		vec    : vec,
		uminus : uminus,
		abs    : abs,
		sign   : sign,
		//round  : round,
		sin    : sin,
		cos    : cos,
		tan    : tan,
		asin   : asin,
		acos   : acos,
		atan   : atan,
		sinh   : sinh,
		cosh   : cosh,
		tanh   : tanh,
		sqrt   : sqrt,
		exp    : exp,
		log    : log
		//diag   : diag
		//horzcat
		//vertcat
		//bsxfun
		//trace
		//plus
		//minus
		//times
		//mtimes
		//dot
		//sum
		//prod
		//repmat
		//mean
		//median
		//eig
		//svd
		//speye

	};

})(window, document, heap);

// frontend:

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
			v = matrico.at(m,i,j);
			if(v>=0) { o += " "; }
			o += v.toFixed(4) + " ";
		}
		o = o + "\n";
	}
	o = o + "\n";

	return o;
}

