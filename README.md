![matrico 0.1](matrico-logo.svg) matrico
========================================

* **Project**: matrico ([Esperanto for "matrix"](https://translate.google.com/?sl=eo&tl=en&text=matrico&op=translate))

* **Summary**: A flonum matrix module for CHICKEN Scheme.

* **Authors**: Christian Himpe (0000-0003-2194-6754)

* **License**: [zlib-acknowledgement](https://spdx.org/licenses/zlib-acknowledgement.html)

* **Version**: 0.1 (2022-??-??)

* **Depends**: [CHICKEN Scheme](http://call-cc.org) (>= 5.1)

* **Website**: http://numerical-schemer.xyz (Development Blog)

* **Reference**: http://

* **Repository**: https://github.com/gramian/matrico (Developer Documentation)

* **Category**: math (numerical mathematics)

* **Audience**: MATLAB, Octave, Scilab, Julia, NumPy users

## Table of Contents

* [Getting Started](#getting-started)
* [Background](#background)
* [Reference](#function-reference)
* [Performance](#performance)
* [Development](#development)

## Getting Started

`matrico` is a Scheme module for numerical matrix computations encapsulated in a CHICKEN Scheme egg.

### Install and Test `matrico` Egg
```
CHICKEN_INSTALL_REPOSITORY="/my/egg/directory/" chicken-install -test matrico
```

### Locate and Provide `matrico` Egg
```
CHICKEN_REPOSITORY_PATH="`chicken-install -repository`:/my/egg/directory/" csi
```

### Run Demo Code
```
(load "RUNME.scm")
```

### Minimal Explanation

`matrico` is a ...

* ... matrix-based numerical computing environment for, and fully written in _Scheme_.

* ... self-contained implementation with minimal dependencies.

* ... numerical linear algebra code with functional back-end design.

## Background

### Why `matrico`

* Provide numerical capabilities to _CHICKEN Scheme_ community.

* Contribute scientific computing knowledge as _Scheme_ code.

* Educational project for author and readers.

### Design Concepts

* Provide two-dimensional dense floating-point (flonum) arrays for _CHICKEN Scheme_.

* Provide typical calculator and linear algebra functions.

* Use only [included modules](http://wiki.call-cc.org/man/5/Included%20modules) of _CHICKEN Scheme_.

* A Matrix is a list of (homogeneous) vectors.

* A Matrix uses column-major ordering of entries.

* A Matrix uses one-based indexing.

* A Matrix can only have real-valued flonum entries.

* Everything is a matrix, particularly, matrices are incompatible with _Scheme_'s (homogeneous) vectors.

* Matrix transformations are based on functional map-reduce approach.

### Similar Projects

* [MatLisp](http://matlisp.sourceforge.net/)

* [Lisplab](https://common-lisp.net/project/lisplab/)

* [CLEM](https://github.com/slyrus/clem)

## Function Reference

* `matrico` Module
    * `mx` Library (User-Facing Matrix Frontend)
    * `dense` Module (Column Interface Specialization)
    * `matrix` Functor (Functional Matrix Backend)
    * `f64vector` Module (Homogeneous Flonum Vector Functions)
    * `fpmath` Module (Additional Flonum Functions)
    * `utils` Module (Additional Foundational Functions)
* Extra Tools
    * `check` Library (Testing Helper Functions)

### The `matrico` Module

<details><summary markdown="span">User-Facing Function Reference (click to expand)</summary>

#### Module Properties

* `(matrico-ver)` returns **pair** holding major and minor version number of the **matrico** module.

* `(matrico-help)` returns **void**, prints help text to terminal.

* `(matrico? proc)` returns **boolean** answering if **symbol** `proc` is an existing function starting with "`mx`" and prints its docstring.

#### Matrix Generators

* `(mx rows cols val)` returns `rows`-by-`cols` **matrix** with all entries set to **flonum** `val` for positive **fixnum**s `rows` and `cols`.

* `(mx% lst)` returns **matrix** from row-major **list**-of-**lists**-of**flonum**s `lst`.

* `(mx-identity dims)` returns `dims`-by-`dims` identity **matrix** for a positive **fixnum** `dims`.

* `(mx-exchange dims)` returns `dims`-by-`dims` exchange **matrix** for a positive **fixnum** `dims`.

* `(mx-hilbert dims)` returns `dims`-by-`dims` Hilbert **matrix** for a positive **fixnum** `dims`.

* `(mx-pascal dims)` returns `dims`-by-`dims` (lower triangular) Pascal **matrix** for a positive **fixnum** `dims`.

* `(mx-lehmer rows cols)` returns `rows`-by-`cols` Lehmer **matrix** for the positive **fixnum**s `rows` and `cols`.

* `(mx-random rows cols low upp)` returns `rows`-by-`cols` uniformly distributed random **matrix** in the interval **flonum** `low` to **flonum** `upp` for the positive **fixnum**s `rows` and `cols`.

* `(mx-tridiag dims low mid upp)` returns `dims`-by-`dims` **matrix** with lower, main, upper band entries given by the **flonum**s `low`, `mid`, `upp` for a positive **fixnum** `dims`.

* `(mx-linspace x y num)` returns **matrix** of positive **fixnum** `num` row-wise linearly spaced entries with endpoints given by **flonum**s or column-`matrix`es `x` and `y`.

* `(mx-logspace x y num)` returns **matrix** of positive **fixnum** `num` row-wise (base-10) logarithmic spaced entries with endpoints given by **flonum**s or column-**matrix**es `x` and `y`.

* `(mx-unit dims num)` returns `dims`-by-one **matrix** of zeros except the positive **fixnum** `num` entry set to one, for a positive **fixnum** `dims`, aka canonical base vector.

* `(mx-iota dims)` returns `dims`-by-one **matrix** with entries set to corresponding row index for a positive **fixnum** `dims`.

#### Matrix Dimensions

* `(mx-cols mat)` returns **fixnum** of columns of **matrix** `mat`.

* `(mx-rows mat)` returns **fixnum** of rows of **matrix** `mat`.

* `(mx-numel mat)` returns **fixnum** of entries of **matrix** `mat`.

* `(mx-dims mat)` returns **fixnum** of dimensions of **matrix** `mat`.

#### Matrix Predicates

* `(mx? any)` returns **boolean** answering if `any` is a **matrix**.

* `(mx-col? mat)` returns **boolean** answering if **matrix** `mat` has only a single column.

* `(mx-row? mat)` returns **boolean** answering if **matrix** `mat` has only a single row.

* `(mx-scalar? mat)` returns **boolean** answering if **matrix** `mat` has only a single row and single column.

* `(mx-vector? mat)` returns **boolean** answering if **matrix** `mat` has only a single row or single column.

* `(mx-square? mat)` returns **boolean** answering if **matrix** `mat` has the same number of rows as columns.

* `(mx-samecols? x y)` returns **boolean** answering if **matrix**es `x` and `y` have same number of columns.

* `(mx-samerows? x y)` returns **boolean** answering if **matrix**es `x` and `y` have same number of rows.

* `(mx-samedim? x y)` returns **boolean** answering if **matrix**es `x` and `y` have same number of columns and rows.

* `(mx-any? pred mat)` returns **boolean** answering if any entry of **matrix** `mat` fulfills predicate **procedure** `pred`.

* `(mx-all? pred mat)` returns **boolean** answering if all entries of **matrix** `mat` fulfills predicate **procedure** `pred`.

* `(mx=? x y tol)` returns **boolean** answering if all entry-wise distances between **matrix**es `x` and `y` are below tolerance **flonum** `tol`.

#### Matrix Accessors

* `(mx-ref11 mat)` returns **flonum** being the top, left entry of **matrix** `mat`.

* `(mx-ref mat row col)` **flonum** being **matrix** `mat` entry in and column specified by positive **fixnum**s `row`, `col`.

* `(mx-col mat col)` returns **matrix** being **matrix** `mat` column specified by positive **fixnum** `col`.

* `(mx-row mat row)` returns **matrix** being **matrix** `mat` row specified by positive **fixnum** `row`.

* `(mx-submatrix mat row1 row2 col1 col2)` returns **matrix** holding entries of **matrix** `mat` in rows specified by positive **fixnum**s `row1` to `row2` and columns specified by positive **fixnum**s `col1` to `col2`.

* `(mx-diag mat)` returns column-**matrix** holding **matrix** `mat` diagonal entries.

* `(mx-set! mat row col val)` returns **void**, sets entry of **matrix** `mat` in row and column specified by positive **fixnum**s `row` and `col` to **flonum** or one-by-one **matrix** `val`.

#### Matrix Expanders

* `(mx+ x)` returns **matrix** of entry-wise doubling of **matrix** `x`.

* `(mx+ x y)` returns **matrix** of entry-wise addition of **matrix**es `x` and `y`.

* `(mx* x)` returns **matrix** of entry-wise squaring of **matrix** `x`.

* `(mx* x y)` returns **matrix** of entry-wise multiplication of **matrix**es `x` and `y`.

* `(mx- x)` returns **matrix** of entry-wise negation of **matrix** `x`.

* `(mx- x y)` returns **matrix** of entry-wise subtraction of **matrix**es `x` and `y`.

* `(mx/ x)` returns **matrix** of entry-wise reciprocal of **matrix** `x`.

* `(mx/ x y)` returns **matrix** of entry-wise division of **matrix**es `x` by `y`.

* `(mx^ x y)` returns **matrix** of entry-wise exponentiation **matrix**es `x` to the `y`.

* `(mx-log b x)` returns **matrix** of entry-wise base **matrix** `b` logarithms of **matrix** `x`.

* `(mx-dist x y)` returns **matrix** of entry-wise absolute differences of **matrix**es `x` and `y`, aka distance.

* `(mx-where pred x y)` returns **matrix** of entries of **matrix**es `x` or `y` based on predicate **procedure** `pred`.

* `(mx+* x a y)` returns **matrix** of entry-wise generalized addition of **matrix** `x` with **flonum** `a` and **matrix** `y`, aka axpy.

#### Matrix Mappers

##### Entry-Wise Rounding Functions

* `(mx-round mat)` returns **matrix** with entries of **matrix** `mat` rounded to nearest integer.

* `(mx-floor mat)` returns **matrix** with entries of **matrix** `mat` rounded to nearest upper integer.

* `(mx-ceil mat)` returns **matrix** with entries of **matrix** `mat` rounded to nearest lower integer.

##### Entry-Wise Generalized Functions

* `(mx-abs mat)` returns **matrix** with entry-wise absolute value of **matrix** `mat`.

* `(mx-sign mat)` returns **matrix** with entry-wise sign of **matrix** `mat`.

* `(mx-dirac mat)` returns **matrix** with entry-wise Dirac delta of **matrix** `mat`.

##### Entry-Wise Trigonometric Functions

* `(mx-sin mat)` returns **matrix** with entry-wise sine of **matrix** `mat`.

* `(mx-cos mat)` returns **matrix** with entry-wise cosine of **matrix** `mat`.

* `(mx-tan mat)` returns **matrix** with entry-wise tangent of **matrix** `mat`.

##### Entry-Wise Inverse Trigonometric Functions

* `(mx-asin mat)` returns **matrix** with entry-wise inverse sine of **matrix** `mat`, aka arcsine.

* `(mx-acos mat)` returns **matrix** with entry-wise inverse cosine of **matrix** `mat`, aka arccosine.

* `(mx-atan mat)` returns **matrix** with entry-wise inverse tangent of **matrix** `mat`, aka arctangent.

##### Entry-Wise Hyperbolic Functions

* `(mx-sinh mat)` returns **matrix** with entry-wise hyperbolic sine of **matrix** `mat`.

* `(mx-cosh mat)` returns **matrix** with entry-wise hyperbolic cosine of **matrix** `mat`.

* `(mx-tanh mat)` returns **matrix** with entry-wise hyperbolic tangent of **matrix** `mat`.

##### Entry-Wise Inverse Hyperbolic Functions

* `(mx-asinh mat)` returns **matrix** with entry-wise inverse hyperbolic sine of **matrix** `mat`, aka area hyperbolic sine.

* `(mx-acosh mat)` returns **matrix** with entry-wise inverse hyperbolic cosine of **matrix** `mat`, aka area hyperbolic cosine.

* `(mx-atanh mat)` returns **matrix** with entry-wise inverse hyperbolic tangent of **matrix** `mat`, aka area hyperbolic tangent.

##### Entry-Wise Haversed Trigonometric Functions

* `(mx-hsin mat)` returns **matrix** with entry-wise haversed sine of **matrix** `mat`.

* `(mx-hcos mat)` returns **matrix** with entry-wise haversed cosine of **matrix** `mat`.

##### Entry-Wise Roots

* `(mx-sqrt mat)` returns **matrix** with entry-wise square root of **matrix** `mat`.

* `(mx-signsqrt mat)` returns **matrix** with entry-wise sign times square-root of absolute value of **matrix** `mat`.

##### Entry-Wise Logarithms

* `(mx-ln mat)` returns **matrix** with entry-wise natural logarithm of **matrix** `mat`.

* `(mx-lb mat)` returns **matrix** with entry-wise base-2 logarithm of **matrix** `mat`.

* `(mx-lg mat)` returns **matrix** with entry-wise base-10 logarithm of **matrix** `mat`.

##### Entry-Wise Exponential

* `(mx-exp mat)` returns **matrix** with entry-wise exponential of **matrix** `mat`.

* `(mx-gauss mat)` returns **matrix** with entry-wise Gaussian of **matrix** `mat`.

##### Entry-Wise Special Functions

* `(mx-sinc mat)` returns **matrix** with entry-wise cardinal sine of **matrix** `mat`.

* `(mx-sigm mat)` returns **matrix** with entry-wise sigmoid of **matrix** `mat`.

* `(mx-stirling mat)` returns **matrix** with entry-wise Stirling approximation of **matrix** `mat`.

#### Matrix Reducers

##### Sums

* `(mx-rowsum mat)` returns column-**matrix** of summing row entries of **matrix** `mat`.

* `(mx-colsum mat)` returns row-**matrix** of summing column entries of **matrix** `mat`.

* `(mx-sum mat)` returns **flonum** of summing all entries of **matrix** `mat`.

##### Products

* `(mx-rowprod mat)` returns column-**matrix** of multiplying row entries of **matrix** `mat`.

* `(mx-colprod mat)` returns row-**matrix** of multiplying column entries of **matrix** `mat`.

* `(mx-prod mat)` returns **flonum** of multiplying all entries of **matrix** `mat`.

##### Minima

* `(mx-rowmin mat)` returns column-**matrix** of row-wise minima of **matrix** `mat`.

* `(mx-colmin mat)` returns row-**matrix** of column-wise minima of **matrix** `mat`.

* `(mx-min mat)` returns **flonum** minimum of all **matrix** `mat` entries.

##### Maxima

* `(mx-rowmax mat)` returns column-**matrix** of row-wise maxima of **matrix** `mat`.

* `(mx-colmax mat)` returns row-**matrix** of column-wise maxima of **matrix** `mat`.

* `(mx-max mat)` returns **flonum** maximum of all **matrix** `mat` entries.

##### Midrange

* `(mx-rowmidr mat)` returns column-**matrix** of row-wise midrange of **matrix** `mat`.

* `(mx-colmidr mat)` returns row-**matrix** of column-wise midrange of **matrix** `mat`.

* `(mx-midr mat)` returns **flonum** midrange of all **matrix** `mat` entries.

##### Means

* `(mx-rowmean mat typ)` returns column-**matrix** of row-wise power means of **matrix** `mat` of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.

* `(mx-colmean mat typ)` returns row-**matrix** of column-wise power means of **matrix** `mat` of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.

* `(mx-mean mat typ)` returns **flonum** power mean of all **matrix** `mat` entries of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.

##### Norms

* `(mx-rownorm mat typ)` returns column-**matrix** of row-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `2`, or `'inf`.

* `(mx-colnorm mat typ)` returns row-**matrix** of column-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `2`, or `'inf`.

* `(mx-norm mat typ)` returns **flonum** matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `'inf`, `'fro`, or `'max`.

#### Linear Algebra

* `(mx-horcat x y)` returns **matrix** of horizontally concatenated **matrix**es `x` and `y`.

* `(mx-vercat x y)` returns **matrix** of vertically concatenated **matrix**es `x` and `y`.

* `(mx-repeat mat rows cols)` returns **matrix** of **fixnum** `rows` times row-wise, and **fixnum** `cols` times columns-wise repeated **matrix** `mat`.

* `(mx-vec mat)` returns **matrix** of vertically concatenated columns of **matrix** `mat`, aka vectorization.

* `(mx-transpose mat)` returns **matrix** of entries of **matrix** `mat` with swapped row and column indices.

* `(mx-sympart mat)` returns **matrix** being symmetric part of square **matrix** `mat`.

* `(mx-skewpart mat)` returns **matrix** being skey-symmetric part of square **matrix** `mat`, aka anti-symmetric part.

* `(mx-diagonal mat)` returns diagonal **matrix** from column **matrix** `mat`.

##### Linear Problems

* `(mx-qr mat)` returns **pair** of orthogonal **matrix** Q and upper right triangular **matrix** R factoring full column rank argument **matrix** `mat`, via QR.

* `(mx-solve mat vec)` returns column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and column-**matrix** `vec`.

* `(mx-solver mat)` returns function returning column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and for argument column-**matrix** `vec`.

* `(mx-absdet mat)` returns **flonum** being absolute value of the determinant of **matrix** `mat`.

* `(mx-logdet mat)` returns **flonum** being the logarithm of the determinant of **matrix** `mat`.

##### Traces

* `(mx-trace mat)` returns **flonum** being sum of square **matrix** `mat` diagonal entries.

* `(mx-multrace mat)` returns **flonum** being product of square **matrix** `mat` diagonal entries.

* `(mx-prodtrace* x yt)` returns **flonum** being the trace of the matrix product of **matrix** `x` and transposed **matrix** `yt`.

* `(mx-prodtrace x y)` returns **flonum** being the trace of the matrix product of **matrix**es `x` and `y`.

##### Matrix Multiplication

* `(mx-scalar x y)` returns **flonum** resulting from scalar product of column-**matrix**es `x` and `y`.

* `(mx-dot* xt y)` returns **matrix** resulting from matrix multiplication of transposed **matrix** `xt` and **matrix** `y`.

* `(mx-dot x y)` returns **matrix** resulting from matrix multiplication of **matrix**es `x` and `y`.

* `(mx-gram mat)` returns **matrix** resulting from matrix multiplication of transposed **matrix** `mat` with itself, aka Gram matrix.

* `(mx-gram* mat)` returns **matrix** resulting from matrix multiplication of **matrix** `mat` with itself transposed.

* `(mx-square mat)` returns **matrix** resulting from matrix multiplication of **matrix** `mat` with itself.

##### Multivariate Statistics

* `(mx-xcov x y)` returns **matrix** of cross-covariances of **matrix**es `x` and `y`, representing columns of observations.

* `(mx-cov mat)` returns **matrix** of covariances of **matrix** `mat`, representing columns of observations.

* `(mx-std mat)` returns column **matrix** of standard deviations of **matrix** `mat`, representing columns of observations.

* `(mx-xcor x y)` returns **matrix** of cross-correlations of **matrix**es `x` and `y`, representing columns of observations.

* `(mx-cor mat)` returns **matrix** of correlations of **matrix** `mat`, representing columns of observations.

* `(mx-coher x y)` returns **flonum** of distance coherence between **matrix**es `x` and `y`.

#### Analysis

* `(mx-diff mat)` returns **matrix** of differences of consecutives columns of **matrix** `mat`.

* `(mx-trapz mat)` returns column-**matrix** trapezoid approximate integral of **matrix** `mat` being columns data-points of rows-dimensional function.

* `(mx-ode2-hyp num fun x0 dt tf)` returns states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order hyperbolic Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`.

* `(mx-ode2-ssp num fun x0 dt tf)` returns states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order strong stability preserving Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`.

#### Matrix Utilities

* `(mx-print mat)` returns **void**, prints **matrix** `mat` to terminal.

* `(mx-export str mat)` returns **void**, writes **matrix** `mat` to new comma-separated-value (CSV) file in relative path **string** `str`.

* `(mx-save str mat)` returns **void**, writes **matrix** `mat` to new Scheme (SCM) file in relative path **string** `str`.

* `(mx-load str)` returns **matrix** loaded from SCM file in relative path **string** `str`.

</details>

### Internal Libraries and Modules

<details><summary markdown="span">Developer Function Reference (click to expand)</summary>

#### Matrix Frontend Library

##### Internal

* `(ensure-mx val)` returns one-by-one **matrix** if `val` is **flonum**, or `val` if `val` is **matrix**.

* `(ensure-fp val)` returns **flonum** if `val` is **flonum**, or element if `val` is one-by-one **matrix**.

* `(translate-cols idx)` returns **fixnum** for **matrix** `mat` translated column index **fixnum** `idx` (from 1-based to 0-based and from end).

* `(translate-rows idx)` returns **fixnum** for **matrix** `mat` translated row index **fixnum** `idx` (from 1-based to 0-based and from end).

* `(back-subst R b)` column-**matrix** solving linear problem of upper-right triangular-**matrix** `R` and column-**matrix** `b` by back substitution.

* `(time-stepper typ fun x0 dt tf)` states-times-steps **matrix** trajectory solving an ordinary differential equation, by method **procedure** `typ`, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`.

#### Matrix Backend Library
Defines the matrix type (record) as column-major list-of-columns and provides generic basic and functional methods wrapped in a functor

* `(matrix-data mat)` returns **list**-of-columns, generated by `define-record`.

* `(matrix? any)` returns **boolean** answering if `any` is a **matrix**, generated by `define-record`.

* `(make-matrix lst cols)` returns **matrix** from list `lst` of columns and **fixnum** number `cols` of columns, generated by `define-record`.

* `(make-matrix* rows cols val)` returns `rows`-by-`cols` **matrix** with all entries set to `val` for **fixnum**s `rows`, `cols`.

* `(make-matrix** lst)` returns **matrix** from row-major **list**-of-**list**s `lst`.

* `(matrix-generate fun rows cols)` returns `rows`-by-`cols` **matrix** generated procedurally from applying **procedure** `fun` (one-based), **fixnum**s `rows`, `cols`.

* `(matrix-horcat . mat)` returns **matrix** of horizontally concatenating **matrix**es from **list**-of**matrix**es `mat`.

* `(matrix-vercat . mat)` returns **matrix** of vertically concatenating **matrix**es from **list**-of-**matrix**es `mat`.

* `(matrix-vec mat)` returns column **matrix** of vertically concatenated columns of **matrix** `mat`, aka vectorization.

* `(matrix-cols mat)` returns **fixnum** number of columns of **matrix** `mat`, generated by `define-record`.

* `(matrix-rows mat)` returns **fixnum** number of rows of **matrix** `mat`.

* `(matrix-numel mat)` returns **fixnum** number of entries of **matrix** `mat`.

* `(matrix-dims mat)` returns **fixnum** number of dimensions of **matrix** `mat`.

* `(matrix-ref mat row col)` returns **any** being **matrix** `mat` entry in **fixnum** `row` and **fixnum** `col`umnS.

* `(matrix-ref00 mat)` returns: **flonum** being the top, left entry of **matrix** `mat`.

* `(matrix-col mat col)` returns **matrix** being **matrix** `mat` column specified by **fixnum** `col`.

* `(matrix-row mat row)` returns **matrix** being **matrix** `mat` row specified by **fixnum** `row`.

* `(matrix-submatrix mat row1 row2 col1 col2)` returns **matrix** holding entries of **matrix** `mat` from rows **fixnum**s `row1` to `row2` in columns **fixnum**s `col1` to `col2`.

* `(matrix-diag mat)` returns **matrix** holding **matrix** `mat` diagonal entries as column-**matrix**.

* `(matrix-set! mat row col val)` returns **void**, sets entry of **matrix** `mat` in row **fixnum** `row` and column **fixnum** `col` to `val`.

* `(matrix-col? mat)` returns **boolean** answering if **matrix** `mat` has only a single column.

* `(matrix-row? mat)` returns **boolean** answering if **matrix** `mat` has only a single row.

* `(matrix-scalar? mat)` returns **boolean** answering if **matrix** `mat` has only a single row and single column, aka scalar.

* `(matrix-vector? mat)` returns: **boolean** answering if **matrix** `mat` has only a single row or single column, aka vector.

* `(matrix-square? mat)` returns **boolean** answering if **matrix** `mat` has the same number of rows and columns.

* `(matrix-samecols? mat)` returns **boolean** answering if **matrix**es `x` and `y` have same number of columns.

* `(matrix-samerows? mat)` returns **boolean** answering if **matrix**es `x` and `y` have same number of rows.

* `(matrix-samedims? mat)` returns **boolean** answering if **matrix**es `x` and `y` have same number of columns and rows.

* `(matrix-any? pred mat)` returns **boolean** answering if any entry of **matrix** `mat` fulfills predicate **procedure** `pred`.

* `(matrix-all? pred mat)` returns **boolean** answering if all entries of **matrix** `mat` fulfill predicate **procedure** `pred`.

* `(matrix-colfold fun ini mat)` returns row **matrix** resulting from folding by two-argument **procedure** `fun each column of **matrix** `mat`.

* `(matrix-rowfold fun ini mat)` returns column **matrix** resulting from folding by two-argument **procedure** `fun each row of **matrix** `mat`.

* `(matrix-allfold fun ini mat)` returns **any** resulting from folding by two-argument **procedure** `fun all **matrix** `mat` entries.

* `(matrix-map fun mat)` returns **matrix** resulting from applying **procedure** `fun` to each entry of **matrix** `mat`.

* `(matrix-broadcast fun x y)` returns **matrix** resulting from applying **procedure** `fun` to each element of matrix `x`, `y`, expanded if necessary.

* `(matrix-transpose mat)` returns **matrix** of entries of **matrix** `mat` with swapped row and column indices.

* `(matrix-dot* xt y)` returns **matrix** resulting from matrix multiplication of transposed of **matrix** `xt` and **matrix** `y`.

* `(matrix-scalar x y)` returns **any** resulting from the scalar product of column-**matrix**es `x` and `y`.

* `(matrix-explode mat)` returns **list**-of-column-**matrix** from **matrix** `mat`.

* `(matrix-implode lst)` returns **matrix** of horizontally concatenated **list**-of-column-**matrix**es `lst`.

* `(matrix-print mat)` returns **void**, prints **matrix** `mat` to terminal.

* `(matrix-export str mat)` returns **void**, writes **matrix** `mat` to new comma-seperated-value (CSV) file in relative path (**string**) `str`.

* `(matrix-save str mat)` returns **void**, writes **matrix** `mat` to new Scheme (SCM) file in relative path (**string**) `str`.

* `(matrix-load str)` returns **matrix** loaded from file in relative path (**string**) `str`.

##### Internal

* `(matrix-map* fun x)` returns **matrix** resulting from applying **procedure** `fun` to each column of **matrix** `x`.

* `(matrix-map** fun x y)` returns **matrix** resulting from applying **procedure** `fun` to each column of **matrix**es `x` and `y`.

#### Dense Column Library
Specifies generic column functions for matrix library with f64vector (flonum vector).

#### Homogeneous Flonum Vector Module
Provides homogeneous vector transformations analogous to vectors.

* `(f64vector-id)` is **string** `"#f64"`.

* `(f64vector-unfold dim fun)` returns **f64vector** of dimension **fixnum** `dim` with procedurally generated elements by **procedure** `fun`.

* `(f64vector-concat . vec)` returns **f64vector** of concatenated **list**-of-**f64vector**s `vec`.

* `(f64vector-any? pred vec)` returns **boolean** answering if any element of **f64vector** `vec` fulfills predicate **procedure** `pred` from left to right.

* `(f64vector-all? pred vec)` returns **boolean** answering if all elements of **f64vector** `vec` fulfill predicate **procedure** `pred` from left to right.

* `(f64vector-map fun . vec)` returns **f64vector** resulting from applying **procedure** `fun` to all corresponding **f64vector**s `vec` elements.

* `(f64vector-map-index fun . vec)` returns **f64vector** resulting from applying **procedure** `fun` to index and all corresponding **f64vector**s `vec` elements.

* `(f64vector-foreach fun . vec)` returns **void**, applies **procedure** `fun` to all corresponding **f64vector**s `vec` elements.

* `(f64vector-foreach-index fun . vec)` returns **void**, applies **procedure** `fun` to index and all corresponding **f64vector** `vec` elements.

* `(f64vector-fold fun ini . vec)` returns **any** resulting from applying **procedure** `fun` to `ini` initialized accumulator and sequentially to all **f64vector**s `vec` elements from left to right.

* `(f64vector-fold* fun ini . vec)` returns **any** resulting from applying **procedure** `fun` to `ini` initialized accumulator and sequentially to all **f64vector**s `vec` elements from right to left.

* `(f64vector-dot x y)` returns **flonum** resulting from applying fused-multiply-add to zero initialized accumulator and sequentially to all **f64vector**s `x`, `y` elements from left to right.

#### Floating-Point Module
Provides additional mathematical functions, extending CHICKEN's `flonum` module.

* `(fp n)` returns **flonum** from **fixnum** `n`.

* `(fp% n d)` returns **flonum** fraction with numerator **fixnum** `n` and denominator **fixnum** `d`.

* `(fpzero?? x)` returns **boolean** answering if **flonum** `x` is exactly zero.

* `(fpdbl x)` returns **flonum** double of **flonum** `x`.

* `(fpsqr x)` returns **flonum** square of **flonum** `x`.

* `(fprec x)` returns **flonum** reciprocal of **flonum** `x`.

* `(fpdist x y)` returns **flonum** absolute difference: `|x - y|` of **flonum**s `x`, `y`.

* `(fp+* z x y)` returns **flonum** sum with product: `z + x * y` of **flonum**s `x`, `y`, `z`.

* `(fptau)` returns **flonum** circle constant Tau via fraction.

* `(fpeul)` returns **flonum** Euler number via fraction.

* `(fpphi)` returns **flonum** golden ratio via fraction of consecutive Fibonacci numbers.

* `(fpdirac x)` returns **flonum** Dirac delta of **flonum** `x`.

* `(fpheaviside x)` returns **flonum** Heaviside step function of **flonum** `x`.

* `(fpsign x)` returns **flonum** sign of **flonum** `x`.

* `(fplog2 x)` returns **flonum** base-2 logarithm of **flonum** `x`.

* `(fplog10 x)` returns **flonum** base-10 logarithm of **flonum** `x`.

* `(fplogb b x)` returns **flonum** base `b` logarithm of **flonum** `x`.

* `(fpsinh x)` returns **flonum** hyperbolic sine of **flonum** `x`.

* `(fpcosh x)` returns **flonum** hyperbolic cosine of **flonum** `x`.

* `(fptanh x)` returns **flonum** hyperbolic tangent of **flonum** `x`.

* `(fpasinh x)` returns **flonum** area hyperbolic sine of **flonum** `x`.

* `(fpacosh x)` returns **flonum** area hyperbolic cosine of **flonum** `x`.

* `(fpatanh x)` returns **flonum** area hyperbolic tangent of **flonum** `x`.

* `(fphsin x)` returns **flonum** haversed sine of **flonum** `x`.

* `(fphcos x)` returns **flonum** haversed cosine of **flonum** `x`.

* `(fpgauss x)` returns **flonum** Gauss bell curve function evaluation of **flonum** `x`.

* `(fpsignsqrt x)` returns **flonum** sign times square root of absolute value of **flonum** `x`.

* `(fpsinc x)` returns **flonum** cardinal sine function with removed singularity of **flonum** `x`.

* `(fpsigm x)` returns **flonum** standard logistic function of **flonum** `x`, aka sigmoid.

* `(fpstirling x)` returns **flonum** Stirling approximation of factorial of **flonum** `x`.

* `(fptaper x)` returns **string** representation of **flonum** `x` formatted to 8 character fixed width.

#### Utilities Module
Provides a few simple functions, macros and aliases for convenience.

* `(define-syntax-rule (name args) (body ...))` returns **macro** generating single-rule macro.

* `(alias aka name)` returns **macro** replacing `aka` with `name`.

* `(must-be args)` **macro** wrapping `assert` of `and` with variable number of arguments.

* `(comment . any)` returns **void**.

* `nil` is **alias** for `'()`.

* `head` is **alias** for `car`.

* `tail` is **alias** for `cdr`.

* `empty?` is **alias** for `null?`.

* `(fx+1 x)` returns **fixnum** incremented **fixnum** `x`.

* `(fx-1 x)` returns **fixnum** decremented **fixnum** `x`.

* `(fx=0? x)` returns **boolean** answering if **fixnum** `x` is zero.

* `(fx<0? x)` returns **boolean** answering if **fixnum** `x` is smaller than zero.

* `(fx>0? x)` returns **boolean** answering if **fixnum** `x` is greater than zero.

* `(fx<=0? x)` returns **boolean** answering if **fixnum** `x` is smaller or equal to zero.

* `(fx>=0? x)` returns **boolean** answering if **fixnum** `x` is greater or equal to zero.

* `(make-list num any)` returns **list** containing **fixnum** `num` number of elements `any`.

* `(sublist lst start end)` returns **list** containing elements of **list** `lst` from indices **fixnum**s `start` to `end`.

* `(any? pred lst)` returns **boolean** answering if any element of **list** `lst` fulfills predicate **procedure** `pred`.

* `(all? pred lst)` returns **boolean** answering if all elements of **list** `lst` fulfill predicate **procedure** `pred`.

* `(factorial n)` returns **fixnum** multiplying consecutive integers up to **fixnum** `n`.

* `(binomial n k)` returns **fixnum** binomial coefficient for **fixnums**s `n` and `k` based on Pascal's rule.

* `(define* (name args ...) (returns str) (body ...))` returns **macro** generating function binding with docstring.

* `(define* name (returns str) (body ...))` returns **macro** generating function binding with docstring.

* `(load* str)` returns **any** terminal result from loaded and evaluated file with path **string** `str`.

* `(defined? sym)` returns **boolean** answering if unquoted **symbol** `sym` is defined.

</details>

### External Tools

<details><summary markdown="span">Tools Reference (click to expand)</summary>

* `(every? lst)` returns **boolean** answering if all elements of **list** `lst` are not false.

* `(check exe arg-ret-lst)` returns **boolean** answering if **procedure** `exe` evaluated for _car_ of each element of **list**-of-**pairs** `arg-ret-lst` corresponds to its _cdr_.

* `(run-tests . tst)` returns `1` if any test argument `tst` fails, `0` otherwise.

* `(load-test str)` returns **any**, the value of the last expression of the source file (**string**) `str`.

</details>

## Performance

Please note:
The author is fully aware that the performance of `matrico` cannot compete with
current numerical environments, which predominantly utilize the highly tuned
[BLAS](https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms)
and [LAPACK](https://en.wikipedia.org/wiki/LAPACK) libraries.
The following `matrico` benchmarks in turn are meant as an indicator to track
version-by-version performance evolution of this _pure_ Scheme implementation.

### Benchmarks

#### LINPACK

* Matrix dimension: 1000x1000
* Optimization level: `-O5`

Run by:
```
make linpack
```

#### Matrix Multiplication

* Matrix dimension: 125x125, 250x250, 500x500, 1000x1000
* Optimization level: `-O0`, `-O1`, `-O2`, `-O3`, `-O4`, `-O5`

Run by:
```
make benchmark
```

### Systems

#### ARM-64 Notebook / Laptop

* `CPU:` M1 (4+4 Cores @ 3.2Ghz)
* `RAM:` 16GB (LPDDR4X @ 4266MT/s)
* `SYS:` macOS (12.3)
* `SCM:` CHICKEN Scheme (5.3)

##### LINPACK

`47.6` Megaflops/s

##### Matrix Multiplication

![benchmark plot](doc/benchmark_m1.svg)

#### ARM-64 Single-Board-Computer

* `CPU:` Cortex-A72 (4 Cores @ 1.5Ghz)
* `RAM:` 4GB (LPDDR4 @ 2400MT/s)
* `SYS:` Raspberry Pi OS Lite (22-04-04)
* `SCM:` CHICKEN Scheme (5.3)

##### LINPACK

`3.1` Megaflops/s

##### Matrix Multiplication

![benchmark plot](doc/benchmark_rpi.svg)

## Development

### Changelog

* **0.1** (2022-??-??) Initial Release

### Roadmap

* [`matrico`] Add heat equation benchmark

* [`matrico`] Add transport equation benchmark

* [`mx`]      Add rank-revealing QR and pseudo-inverse via QR

* [`mx`]      Add Eigenvalue decomposition and singular value decomposition

* [`mx`]      Add [`asciichart`](https://github.com/kroitor/asciichart) interface or functionality

* [`fpmath`]  Use native `fp+*` (CHICKEN Scheme 5.4)

* [`utils`]   Add `map*` ["parallel" map](https://lists.nongnu.org/archive/html/chicken-users/2010-12/msg00213.html)

* [`check`]   Add more `matrico` tests

* [`check`]   Add inexact approximate equality tests

### Ideas

* Alias for `.bashrc`:
```
alias matrico='CHICKEN_REPOSITORY_PATH="`chicken-install -repository`:/my/egg/directory/" csi -R matrico'
```

## [`matrico`](https://git.io/matrico) — a (:chicken: λ) :egg: for numerical schemers!

