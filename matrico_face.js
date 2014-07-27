
var matrico = (function()
{
	function numel(m) {
		     if(typeof(m)==="string") { return matrico_core.numel(parseInt(m)); }
		else if(typeof(m)==="number") { return 1; }
	}

	function size(m,d) {
		     if(typeof(m)==="string") { return matrico_core.size(parseInt(m),d); }
		else if(typeof(m)==="number") { return 1; }
	}

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

	function abs(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.abs_m(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.abs(m); }
	}

	function sign(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.sign_m(parseInt(m)); }
		else if(typeof(m)==="number") { return (m>0) - (m<0); }
	}

	function round(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.round(parseInt(m)); }
		else if(typeof(m)==="number") { return Math.floor(m+0.5); }
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

	function pow(m,n) {

		     if(typeof(m)==="string" && typeof(n)==="string") { return ""+matrico_core.pow_mm(parseInt(m),parseInt(n)); }
		else if(typeof(m)==="string" && typeof(n)==="number") { return ""+matrico_core.pow_ms(parseInt(m),n); }
		else if(typeof(m)==="number" && typeof(n)==="string") { return ""+matrico_core.pow_sm(m,parseInt(n)); }
	}

	function uminus(m) {

		     if(typeof(m)==="string") { return ""+matrico_core.uminus_m(parseInt(m)); }
		else if(typeof(m)==="number") { return -m; }
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

		     if(typeof(m)==="number") { return m; }
		else if(typeof(m)==="string" && n==1 && size(m,2)==1) { return ""+matrico_core.sum_1s(parseInt(m)); }
		else if(typeof(m)==="string" && n==2 && size(m,1)>1) { return ""+matrico_core.sum_2s(parseInt(m)); }
		else if(typeof(m)==="string" && n==1 && size(m,2)==1) { return ""+matrico_core.sum_1m(parseInt(m)); }
		else if(typeof(m)==="string" && n==2 && size(m,1)>1) { return ""+matrico_core.sum_2m(parseInt(m)); }
	}

	function prod(m,n) {

		     if(typeof(m)==="number") { return m; }
		else if(typeof(m)==="string" && n==1) { return ""+matrico_core.prod_1(parseInt(m)); }
		else if(typeof(m)==="string" && n==2) { return ""+matrico_core.prod_2(parseInt(m)); }
	}

	function mean(m,n) {

		     if(typeof(m)==="number") { return m; }
		else if(typeof(m)==="string" && n==1) { return ""+matrico_core.mean_1(parseInt(m)); }
		else if(typeof(m)==="string" && n==2) { return ""+matrico_core.mean_2(parseInt(m)); }
	}


	return {
		 numel : numel,
		  size : size,

		 zeros : zeros,
		  ones : ones,
		   eye : eye,
		  rand : rand,
		 randn : randn,

		   vec : vec,

		   abs : abs,
		  sign : sign,
		 round : round,

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

		uminus : uminus,
		 times : times,
		  plus : plus,
		 minus : minus,
		mtimes : mtimes,

		   sum : sum,
		  prod : prod
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

