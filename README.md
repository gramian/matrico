matrico
=======

matrico is a web-based linear algebra library written in Javascript.
The syntax is related to Matlab and Octave.
asm.js is utilized for efficient computations.

## Functions ##

Thew following functions are implemented:

* at

* size(m,d)	, size of dimension d of array m 
* numel(m)	, number of elements of array m

* zeros(r,c)	, array filled with zeros with r rows and c columns
* ones(r,c)	, array filled with ones with r rows and c columns
* eye(r)	, unit matrix with r rows and columns
* rand(r,c)	, array filled with uniformly distributed values with r rows and c columns
* randn(r,c)	, array filled with normally distributed values with r rows and c columns

* vec(m)	, vectorize array
* trace(m)      , matrix trace

* uminus(m)	, unary minus of array

* round(m)      , round all array elements
* abs(m)	, absolute value of all array elements
* sign(m)	, sign of all array elements

* sin(m)	, sine of all array elements 
* cos(m)	, cosine of all array elements
* tan(m)	, tangent of all array elements
* asin(m)	, arcsine of all array elements
* acos(m)	, arccosine of all array elements
* atan(m)	, arctangent of all array elements
* sinh(m)	, hyperbolic sine of all array elements
* cosh(m)	, hyperbolic cosine of all array elements
* tanh(m)	, hyperbolic tangent of all array elements
* asinh(m)      , area hyperbolic sine of all array elements
* acosh(m)      , area hyperbolic cosine of all array elements
* atanh(m)      , area hyperbolic tangent of all array elements
* sqrt(m)	, squareroot of all array elements
* exp(m)	, exponential of all array elements
* log(m)	, natural logarithm of all array elements

* horzcat(m,n)
* vertcat(m,n)

* plus(m,n)
* minus(m,n)
* times(m,n)
* mtimes(m,n)
* dot(m,n)

### TODO ###

* col
* row
* page

* pow

* diag
* bsxfun
* sum
* prod
* diff
* permute
* repmat
* reshape
* transpose
* dot
* norm
* svd

* rdivide
* ldivide

* and
* or
* not
* xor
* any
* all

* max
* min
* mean
* median
* var
* cov
* std

* isequal
* eq
* ne
* gt
* ge
* lt
* le

* isnumeric
* exist
* dec2bin
* tic
* toc

