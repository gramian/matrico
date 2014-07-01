"use strict";

var MATRICO_VERSION = '0.1.0';

var size = 16*1024*1024; // 16MB for testing purposes
var heap = new ArrayBuffer(size);

// backend:

var matrico_core = (function(stdlib,foreign,heap)
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
//	##   # #  ##
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

//	###  ##   ###
//	# #  # #  #
//	###  ##   ###
//	# #  # #    #
//	# #  ##   ###

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

//	###  ###  #   #
//	# #  # #  #   #
//	###  # #  # # #
//	#    # #  # # #
//	#    ###   # #

	function pow(m,n) { m = m|0; n = +n;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = +math_pow(+mem[(m + i<<3)>>3],n); }

		return o|0; }

//	###  #    # #  ###
//	# #  #    # #  #
//	###  #    # #  ###
//	#    #    # #    #
//	#    ###  ###  ###

	function plus(m,n) { m = m|0; n = n|0;

		var r = 0, c = 0, s = 0, d = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		s = ~~+mem[(n - 2<<3)>>3];
		d = ~~+mem[(n - 1<<3)>>3];
		// if(r!=s || c!=d) { return -1; }  
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = mem[(m + i<<3)>>3] + mem[(n + i<<3)>>3]; }

		return o|0; }

//	#   #  ###  #   #  # #  ###
//	## ##   #   ##  #  # #  #
//	# # #   #   # # #  # #  ###
//	# # #   #   #  ##  # #    #
//	#   #  ###  #   #  ###  ###

	function minus(m,n) { m = m|0; n = n|0;

		var r = 0, c = 0, s = 0, d = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		s = ~~+mem[(n - 2<<3)>>3];
		d = ~~+mem[(n - 1<<3)>>3];
		// if(r!=s || c!=d) { return -1; }  
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = mem[(m + i<<3)>>3] - mem[(n + i<<3)>>3]; }

		return o|0; }

//	###  ###  #   #  ###  ###
//	 #    #   ## ##  #    #
//	 #    #   # # #  ##   ###
//	 #    #   # # #  #      #
//	 #   ###  #   #  ###  ###

	function times(m,n) { m = m|0; n = +n;

		var r = 0, c = 0, o = 0, t = 0, i = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3]; 
		o = zeros(r,c)|0;
		t = imul(r,c)|0;

		for(;(i|0)<(t|0);i=(i+1)|0) { mem[(o + i<<3)>>3] = mem[(m + i<<3)>>3] * n; }

		return o|0; }


	/*function mtimes(m,n) {

	}*/


	/*function dot(m,n) {

	}*/

//	###  # #  #   #
//	#    # #  ## ##
//	###  # #  # # #
//	  #  # #  # # #
//	###  ###  #   #

	function sum_1(m) { m = m|0;

		var r = 0, c = 0, o = 0, p = 0, i = 0, j = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(1,c)|0;

		for(;(i|0)<(c|0);i=(i+1)|0) { p = (m + (imul(r,i<<3)|0))|0; for(;(j|0)<(r|0);j=(j+1)|0) { mem[(i<<3)>>3] = mem[(i<<3)>>3] + mem[(p + j<<3)>>3]; } }

		return o|0; }

	function sum_2(m) { m = m|0;

		var r = 0, c = 0, o = 0, p = 0, i = 0, j = 0;

		r = ~~+mem[(m - 2<<3)>>3];
		c = ~~+mem[(m - 1<<3)>>3];
		o = zeros(r,1)|0;

		for(;(i|0)<(r|0);i=(i+1)|0) { p = i|0; for(;(j|0)<(c|0);j=(j+1)|0) { p = (p + c)|0; mem[(i<<3)>>3] = mem[(i<<3)>>3] + mem[(p<<3)>>3]; } }

		return o|0; }




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
		  size : size,
		 numel : numel,
		    at : at,
		 zeros : zeros,
		  ones : ones,
		   eye : eye,
		  rand : rand,
		 randn : randn,
		   vec : vec,
		uminus : uminus,
		   abs : abs,
		  sign : sign,
		//round : round,
		   sin : sin,
		   cos : cos,
		   tan : tan,
		  asin : asin,
		  acos : acos,
		  atan : atan,
		  sinh : sinh,
		  cosh : cosh,
		  tanh : tanh,
		  sqrt : sqrt,
		   exp : exp,
		   log : log,
		   pow : pow,
		//diag : diag
		//horzcat
		//vertcat
		//subsref
		//subsasgn
		//bsxfun
		//trace
		  plus : plus,
		 minus : minus,
		 times : times
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

var matrico = (function()
{
	function zeros(r,c) {

		if(r===1 && c===1) { return 0; }
		else { return matrico_core.zero(r,c); }
	}

	function ones(r,c) {

		if(r===1 && c===1) { return 1; }
		else { return matrico_core.ones(r,c); }
	}

	function eye(r) {

		if(r===1) { return 1; }
		else { return ""+matrico_core.eye(r); }
	}

	function rand(r,c) {

		if(r===1 && c===1) { return matrico_core.rnd(); }
		else { return matrico_core.rand(r,c); }
	}

	function randn(r,c) {

		if(r===1 && c===1) { return (rnd()*2.0-1.0)+(rnd()*2.0-1.0)+(rnd()*2.0-1.0); }
		else { return matrico_core.randn(r,c); }
	}

	function vec(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.vec_m(parseInt(m)); }
		else if(typeof(m)==="number") { return m; }
	}

	function uminus(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.uminus_m(parseInt(m)); }
		else if(typeof(m)==="number") { return -m; }
	}

	function abs(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.abs_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.abs(m); }
	}

	function sign(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.sign_m(parseInt(m)); }
		else if(typeof(m)==="number") { return (m>0) - (m<0); }
	}

	function sin(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.sin_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.sin(m); }
	}

	function cos(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.cos_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.cos(m); }
	}

	function tan(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.tan_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.tan(m); }
	}

	function asin(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.asin_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.asin(m); }
	}

	function acos(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.acos_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.acos(m); }
	}

	function atan(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.atan_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.atan; }
	}

	function sinh(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.sinh_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.sinh(m); }
	}

	function cosh(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.cosh_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.cosh(m); }
	}

	function tanh(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.tanh_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.tanh(m); }
	}

	function sqrt(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.sqrt_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.sqrt(m); }
	}

	function exp(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.exp_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.exp(m); }
	}

	function log(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.log_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.log(m); }
	}

	function times(m,n) {

		     if(typeof(m)==="string" && typeof(n)==="number") { return ""+matrico_core.times_ms(parseInt(m),n); }
		else if(typeof(m)==="number" && typeof(n)==="string") { return ""+matrico_core.times_ms(parseInt(n),m); }
		else if(typeof(m)==="number" && typeof(n)==="number") { return m*n; }
	}

	function plus(m,n) {

		     if(typeof(m)==="string" && typeof(n)==="string") { return ""+matrico_core.plus_mm(parseInt(m),parseInt(n)); }
		else if(typeof(m)==="string" && typeof(n)==="number") { return ""+matrico_core.plus_ms(parseInt(m),n); }
		else if(typeof(m)==="number" && typeof(n)==="string") { return ""+matrico_core.plus_ms(parseInt(n),m); }
	}

	function minus(m,n) {

		     if(typeof(m)==="string" && typeof(n)==="string") { return ""+matrico_core.minus_mm(parseInt(m),parseInt(n)); }
		else if(typeof(m)==="string" && typeof(n)==="number") { return ""+matrico_core.minus_ms(parseInt(m),n); }
		else if(typeof(m)==="number" && typeof(n)==="string") { return ""+matrico_core.minus_sm(m,parseInt(n)); }
	}

	function mtimes(m,n) {

		return ""+matrico_core.mtimes(parseInt(m),parseInt(n));
	}


	function sum(m,n) {

		     if(n==1) { return ""+matrico_core.sum_1(parseInt(m)); }
		else if(n==2) { return ""+matrico_core.sum_2(parseInt(m)); }
	}


	return {
		 zeros : zeros,
		  ones : ones,
		   eye : eye,
		  rand : rand,
		 randn : randn,
		   vec : vec,
		uminus : uminus,
		   abs : abs,
		  sign : sign,
		   sin : sin,
		   cos : cos,
		   tan : tan,
		  asin : asin,
		  acos : acos,
		  atan : atan,
		  sinh : sinh,
		  cosh : cosh,
		  tanh : tanh,
		  sqrt : sqrt,
		   exp : exp,
		   log : log,

		 times : times,
		  plus : plus,
		 minus : minus,
		mtimes : mtimes,

		   sum : sum
	};


})();

function echo(m)
{
	var o = "";

	var r = matrico_core.size(m,1);
	var c = matrico_core.size(m,2);
	var v = 0;

	for(var i=0;i<r;i++)
	{
		o += " ";
		for(var j=0;j<c;j++)
		{
			v = matrico_core.at(m,i,j);
			if(v>=0) { o += " "; }
			o += v.toFixed(4) + " ";
		}
		o = o + "\n";
	}
	o = o + "\n";

	return o;
}

