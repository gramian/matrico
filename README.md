matrico
=======

matrico is a web-based linear algebra library written in Javascript.
The syntax is related to Matlab and Octave.
asm.js is utilized for efficient computations.

* Automatic Broadcasting (No bsxfun)
* Assigment Operators


## Functions ##



### Core ###

* at(matrix,row,column) ; element access (alpha)
* row(matrix,row)       ; row access (0)
* col(matrix,column)    ; column access (0)
* page(matrix,page)     ; page access (0)

* size(matrix,dimension) ; size of dimension (alpha)
* numel(matrix)          ; number of elements (alpha)

* zeros(rows,columns) ; zero matrix
* ones(rows,columns)  ; ones matrix
* eye(dimension)      ; unit matrix
* rand(rows,columns)  ; uniform random matrix
* randn(rows,columns) ; normal random matrix

* unit(rows,row) ; unit vector

* linspace

* diag
* diag

* vec(matrix)                  ; vectorize
* reshape(matrix,rows,columns) ; reshape to
* repmat(matrix,rows,columns)  ; repeat

* horzcat(matrix,matrix) ; concatenate horizontally
* vertcat(matrix,matrix) ; concatenate vertically

* abs(matrix)            ; element-wise absolute value
* sign(matrix)           ; element-wise sign
* dirac
* heaviside
* kronecker

* norm

* round(matrix)          ; element-wise round
* ceil
* floor

* min
* max

* and
* or
* not
* xor

* any
* all

* isequal
* eq
* ne
* gt
* ge
* lt
* le

* sin(matrix) ; element-wise sine
* cos(matrix) ; element-wise cosine
* tan(matrix) ; element-wise tangent

* asin(matrix) ; element-wise arcsine
* acos(matrix) ; element-wise arccosine
* atan(matrix) ; element-wise arctangent

* sinh(matrix) ; element-wise hyperbolic sine
* cosh(matrix) ; element-wise hyperbolic cosine
* tanh(matrix) ; element-wise hyperbolic tangent

* sqrt(matrix) ; element-wise squareroot
* exp(matrix)  ; element-wise exponential
* log(matrix)  ; element-wise natural logarithm

* pow(matrix,matrix) ; element-wise power
* pow(matrix,number) ; element-wise power
* pow(number,matrix) ; element-wise power

* transpose

* uminus(matrix) ; element-wise unary minus

* times(matrix,number) ; element-wise scaling

* plus(matrix,number) ; element-wise addition
* plus(matrix,matrix) ; element-wise addition

* minus(matrix,number) ; element-wise subtraction
* minus(matrix,matrix) ; element-wise subtraction

* mtimes

* dot

* sum

* prod

* diff

* mean
* median
* var
* cov
* std

* trace

* eigs

* svds

* speye
* sparse

* permute




### Util ###

* isnumeric
* exist
* dec2bin
* echo
* tic
* toc

