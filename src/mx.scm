;;;; mx.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-05-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: matrix type front-end

;;; Private Functions ##########################################################

;;@returns: one-by-one **matrix** if `val` is **flonum**, or `val` if `val` is **matrix**.
(define-inline (ensure-mx val)
  (cond [(flonum? val) (mx 1 1 val)]
        [(matrix? val) val]
        [else          (error "Type mismatch!" 'val)]))

;;@returns: **flonum** if `val` is **flonum**, or element if `val` is one-by-one **matrix**.
(define-inline (ensure-fp val)
  (cond [(flonum? val)        val]
        [(matrix-scalar? val) (matrix-ref00 val)]
        [else                 (error "Type mismatch!" 'val)]))

;;@returns: **fixnum** for **matrix** `mat` translated column index **fixnum** `idx` (from 1-based to 0-based and from end).
(define-inline (translate-cols mat idx)
  (cond [(fx>0? idx) (fx-1 idx)]
        [(fx<0? idx) (fx+ (matrix-cols mat) idx)]
        [else        (error "Illegal column index" 'idx)]))

;;@returns: **fixnum** for **matrix** `mat` translated row index **fixnum** `idx` (from 1-based to 0-based and from end).
(define-inline (translate-rows mat idx)
  (cond [(fx>0? idx) (fx-1 idx)]
        [(fx<0? idx) (fx+ (matrix-rows mat) idx)]
        [else        (error "Illegal row index" 'idx)]))

;;@returns: column-**matrix** solving linear problem of upper-right triangular-**matrix** `R` and column-**matrix** `b` by back substitution.
(define-inline (back-subst R b)
  (let* [(rcols (mx-cols R))
         (x     (mx rcols 1 0.0))]
    (define (trisum row)
      (let rho [(col rcols)
                (sum 0.0)]
        (cond [(fx= row col) (fp/ (fp- (mx-ref b row 1) sum) (mx-ref R row col))]
              [else          (rho (fx-1 col) (fp+* sum (mx-ref x col 1) (mx-ref R row col)))])))
    (do [(idx (mx-rows R) (fx-1 idx))]
      ((zero? idx) x)
      (mx-set! x idx 1 (trisum idx)))))

;;@returns: states-times-steps **matrix** trajectory solving an ordinary differential equation, by method **procedure** `typ`, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`. ; TODO: return list of columns?
(define-inline (time-stepper typ fun x0 dt tf)
  (must-be (procedure? typ) (procedure? fun) (mx-col? x0) (< 0.0 dt tf))
  (let rho [(steps  (fx+1 (inexact->exact (fpfloor (fp/ tf dt)))))
            (step   dt)
            (series (list x0))]
    (if (zero? steps) (matrix-implode (reverse series))
                      (rho (fx-1 steps) (fp+ step dt) (cons (typ step (head series)) series)))))

;;; Matrix Constructors ########################################################

;;@returns: `rows`-by-`cols` **matrix** with all entries set to **flonum** `val` for positive **fixnum**s `rows` and `cols`.
(define* (mx rows cols val)
  (returns "`rows`-by-`cols` **matrix** with all entries set to **flonum** `val` for positive **fixnum**s `rows` and `cols`.")
  (must-be (fixnum? rows) (fx>0? rows) (fixnum? cols) (fx>0? cols) (flonum? val))
  (make-matrix* rows cols val))

;;@returns: **matrix** from row-major **list**-of-**lists**-of-**flonum**s `lst`.
(define* (mx% lst)
  (returns "**matrix** from row-major **list**-of-**lists**-of-**flonum**s `lst`.")
  (must-be ((list-of? (list-of? flonum?)) lst))
  (make-matrix** lst))

;;@returns: `dims`-by-`dims` identity **matrix** for positive **fixnum** `dims`.
(define* (mx-identity dims)
  (returns "`dims`-by-`dims` identity **matrix** for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>0? dims))
  (matrix-generate (lambda (i j)
                     (if (fx= i j) 1.0
                                   0.0))
                   dims dims))

;;@returns: `dims`-by-`dims` exchange **matrix** for positive **fixnum** `dims`.
(define* (mx-exchange dims)
  (returns "`dims`-by-`dims` exchange **matrix** for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>0? dims))
  (matrix-generate (lambda (i j)
                     (if (fx= (fx- dims i) (fx+1 j)) 1.0
                                                     0.0))
                   dims dims))

;;@returns: `dims`-by-`dims` Hilbert **matrix** for positive **fixnum** `dims`.
(define* (mx-hilbert dims)
  (returns "`dims`-by-`dims` Hilbert **matrix** for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>0? dims))
  (matrix-generate (lambda (i j)
                     (fprec (fp (fx+1 (fx+ i j)))))
                   dims dims))

;;@returns: `dims`-by-`dims` (lower triangular) Pascal **matrix** for positive **fixnum** `dims`.
(define* (mx-pascal dims)
  (returns "`dims`-by-`dims` (lower triangular) Pascal **matrix** for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>=0? dims))
  (matrix-generate (lambda (i j)
                     (fp (binomial i j)))
                   dims dims))

;;@returns: `rows`-by-`cols` Lehmer **matrix** for positive **fixnum**s `rows` and `cols`.
(define* (mx-lehmer rows cols)
  (returns "`rows`-by-`cols` Lehmer **matrix** for positive **fixnum**s `rows` and `cols`.")
  (must-be (fixnum? rows) (fx>0? rows) (fixnum? cols) (fx>0? cols))
  (matrix-generate (lambda (i j)
                     (fp/ (fp (fx+1 (fxmin i j))) (fp (fx+1 (fxmax i j)))))
                   rows cols))

;;@returns: `rows`-by-`cols` uniformly distributed random **matrix** in the interval **flonum** `low` to **flonum** `upp` for positive **fixnum**s `rows` and `cols`.
(define* (mx-random rows cols low upp)
  (returns "`rows`-by-`cols` uniformly distributed random **matrix** in the interval **flonum** `low` to **flonum** `upp` for positive **fixnum**s `rows` and `cols`.")
  (must-be (fixnum? rows) (fx>0? rows) (fixnum? cols) (fx>0? cols) (flonum? low) (flonum? upp))
  (define ran (fp- upp low))
  (matrix-generate (lambda (i j)
                     (fp+* low ran (pseudo-random-real)))
                   rows cols))

;;@returns: `dims`-by-`dims` **matrix** with lower, main, upper band entries given by **flonum**s `low`, `mid`, `upp` for positive **fixnum** `dims`.
(define* (mx-tridiag dims low mid upp)
  (returns "`dims`-by-`dims` **matrix** with lower, main, upper band entries given by **flonum**s `low`, `mid`, `upp` for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>0? dims) (flonum? low) (flonum? mid) (flonum? upp))
  (matrix-generate (lambda (i j)
                     (cond [(fx= i j)                            mid]
                           [(and (fx<= j dims) (fx= i (fx+1 j))) low]
                           [(and (fx<= i dims) (fx= (fx+1 i) j)) upp]
                           [else                                 0.0]))
                   dims dims))

;;@returns: **matrix** of positive **fixnum** `num` row-wise linearly spaced entries with endpoints given by column-**matrix**es `x` and `y`.
(define* (mx-linspace x y num)
  (returns "**matrix** of positive **fixnum** `num` row-wise linearly spaced entries with endpoints given by column-**matrix**es `x` and `y`.")
  (must-be (or (flonum? x) (mx-col? x)) (or (flonum? y) (mx-col? y)) (fixnum? num) (fx>0? num))
  (mx+ x (mx* (mx/ (mx- y x) (fp (fx-1 num))) (mx-transpose (mx-iota num)))))

;;@returns: **matrix** of positive **fixnum** `num` row-wise (base-10) logarithmic spaced entries with endpoints given by column-**matrix**es `x` and `y`.
(define* (mx-logspace x y num)
  (returns "**matrix** of positive **fixnum** `num` row-wise (base-10) logarithmic spaced entries with endpoints given by column-**matrix**es `x` and `y`.")
  (mx^ 10.0 (mx-linspace (mx-lg (ensure-mx x)) (mx-lg (ensure-mx y)) num)))

;;@returns: `dims`-by-one column **matrix** of zeros except the positive **fixnum** `num` entry set to one, for positive **fixnum** `dims`, aka canonical base vector.
(define* (mx-unit dims num)
  (returns "`dims`-by-one column **matrix** of zeros except the positive **fixnum** `num` entry set to one, for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fixnum? num) (fx>0? num) (fx<= num dims))
  (matrix-generate (lambda (i j)
                     (if (fx= (fx+1 i) num) 1.0
                                            0.0))
                   dims 1))

;;@returns: `dims`-by-one **matrix** with entries set to corresponding row index for positive **fixnum** `dims`.
(define* (mx-iota dims)
  (returns "`dims`-by-one **matrix** with entries set to corresponding row index for positive **fixnum** `dims`.")
  (must-be (fixnum? dims) (fx>0? dims))
  (matrix-generate (lambda (i j)
                     (fp i))
                   dims 1))

;;; Matrix Dimensions ##########################################################

;;@returns: **fixnum** of columns of **matrix** `mat`.
(define* (mx-cols mat)
  (returns "**fixnum** of columns of **matrix** `mat`.")
  (matrix-cols mat))

;;@returns: **fixnum** of rows of **matrix** `mat`.
(define* (mx-rows mat)
  (returns "**fixnum** of rows of **matrix** `mat`.")
  (matrix-rows mat))

;;@returns: **fixnum** of entries of **matrix** `mat`.
(define* (mx-numel mat)
  (returns "**fixnum** of entries of **matrix** `mat`.")
  (matrix-numel mat))

;;@returns: **fixnum** of dimensions of **matrix** `mat`.
(define* (mx-dims mat)
  (returns "**fixnum** of dimensions of **matrix** `mat`.")
  (matrix-dims mat))

;;; Matrix Predicates ##########################################################

;;@returns: **boolean** answering if `any` is **matrix**.
(define* (mx? any)
  (returns "**boolean** answering if `any` is **matrix**.")
  (matrix? any))

;;@returns: **boolean** answering if **matrix** `mat` has only a single column.
(define* (mx-col? mat)
  (returns "**boolean** answering if **matrix** `mat` has only a single column.")
  (matrix-col? mat))

;;@returns: **boolean** answering if **matrix** `mat` has only a single row.
(define* (mx-row? mat)
  (returns "**boolean** answering if **matrix** `mat` has only a single row.")
  (matrix-row? mat))

;;@returns: **boolean** answering if **matrix** `mat` has only a single row and single column.
(define* (mx-scalar? mat)
  (returns "**boolean** answering if **matrix** `mat` has only a single row and single column.")
  (matrix-scalar? mat))

;;@returns: **boolean** answering if **matrix** `mat` has only a single row or single column.
(define* (mx-vector? mat)
  (returns "**boolean** answering if **matrix** `mat` has only a single row or single column.")
  (matrix-vector? mat))

;;@returns: **boolean** answering if **matrix** `mat` has the same number of rows and columns.
(define* (mx-square? mat)
  (returns "**boolean** answering if **matrix** `mat` has the same number of rows and columns.")
  (matrix-square? mat))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of columns.
(define* (mx-samecols? x y)
  (returns "**boolean** answering if **matrix**es `x` and `y` have same number of columns.")
  (matrix-samecols? x y))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of rows.
(define* (mx-samerows? x y)
  (returns "**boolean** answering if **matrix**es `x` and `y` have same number of rows.")
  (matrix-samerows? x y))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of columns and rows.
(define* (mx-samedims? x y)
  (returns "**boolean** answering if **matrix**es `x` and `y` have same number of columns and rows.")
  (matrix-samedims? x y))

;;@returns: **boolean** answering if any entry of **matrix** `mat` fulfills predicate **procedure** `pred`.
(define* (mx-any? pred mat)
  (returns "**boolean** answering if any entry of **matrix** `mat` fulfills predicate **procedure** `pred`.")
  (matrix-any? pred mat))

;;@returns: **boolean** answering if all entries of **matrix** `mat` fulfills predicate **procedure** `pred`.
(define* (mx-all? pred mat)
  (returns "**boolean** answering if all entries of **matrix** `mat` fulfills predicate **procedure** `pred`.")
  (matrix-all? pred mat))

;;@returns: **boolean** answering if all entry-wise distances between **matrix**es `x` and `y` are below tolerance **flonum** `tol`.
(define* (mx=? x y tol)
  (returns "**boolean** answering if all entry-wise distances between **matrix**es `x` and `y` are below tolerance **flonum** `tol`.")
  (mx-all? (lambda (z) (fp< z tol)) (mx-dist x y)))

;;; Matrix Accessors ###########################################################

;;@returns: **flonum** being the top, left entry of **matrix** `mat`.
(define* (mx-ref11 mat)
  (returns "**flonum** being the top, left entry of **matrix** `mat`.")
  (matrix-ref00 mat))

;;@returns: **flonum** being **matrix** `mat` entry in row and column specified by positive **fixnum**s `row`, `col`.
(define* (mx-ref mat row col)
  (returns "**flonum** being **matrix** `mat` entry in and column specified by positive **fixnum**s `row`, `col`.")
  (matrix-ref mat (translate-rows mat row) (translate-cols mat col)))

;;@returns: **matrix** being **matrix** `mat` column specified by positive **fixnum** `col`.
(define* (mx-col mat col)
  (returns "**matrix** being **matrix** `mat` column specified by positive **fixnum** `col`.")
  (matrix-col mat (translate-cols mat col)))

;;@returns: **matrix** being **matrix** `mat` row specified by positive **fixnum** `row`.
(define* (mx-row mat row)
  (returns "**matrix** being **matrix** `mat` row specified by positive **fixnum** `row`.")
  (matrix-row mat (translate-rows mat row)))

;;@returns: **matrix** holding entries of **matrix** `mat` of rows specified by positive **fixnum**s `row1` to `row2` in columns specified by positive **fixnum**s `col1` to `col2`.
(define* (mx-submatrix mat row1 row2 col1 col2)
  (returns "**matrix** holding entries of **matrix** `mat` of rows specified by positive **fixnum**s `row1` to `row2` in columns specified by positive **fixnum**s `col1` to `col2`.")
  (matrix-submatrix mat (translate-rows mat row1) (translate-rows mat row2) (translate-cols mat col1) (translate-cols mat col2)))

;;@returns: column-**matrix** holding **matrix** `mat` diagonal entries.
(define* (mx-diag mat)
  (returns "column-**matrix** holding **matrix** `mat` diagonal entries.")
  (matrix-diag mat))

;;@returns: **void**, sets entry of **matrix** `mat` in row and column specified by positive **fixnum**s `row` and `col` to **flonum** or one-by-one **matrix** `val`.
(define* (mx-set! mat row col val)
  (returns "**void**, sets entry of **matrix** `mat` in row and column specified by positive **fixnum**s `row` and `col` to **flonum** or one-by-one **matrix** `val`.")
  (matrix-set! mat (translate-rows mat row) (translate-cols mat col) (ensure-fp val)))

;;; Matrix Expanders ###########################################################

;;@returns: **matrix** of entry-wise addition of **matrix**es `x` and `y`, or entry-wise doubling for single **matrix** `x`.
(define* mx+
  (returns "**matrix** of entry-wise addition of **matrix**es `x` and `y`, or entry-wise doubling for single **matrix** `x`.")
  (case-lambda [(x)   (matrix-map fpdbl (ensure-mx x))]
               [(x y) (matrix-broadcast fp+ (ensure-mx x) (ensure-mx y))]))

;;@returns: **matrix** of entry-wise multiplication of **matrix**es `x` and `y`, or entry-wise squaring for single **matrix** `x`.
(define* mx*
  (returns "**matrix** of entry-wise multiplication of **matrix**es `x` and `y`, or entry-wise squaring for single **matrix** `x`.")
  (case-lambda [(x)   (matrix-map fpsqr (ensure-mx x))]
               [(x y) (matrix-broadcast fp* (ensure-mx x) (ensure-mx y))]))

;;@returns: **matrix** of entry-wise subtraction of **matrix**es `x` and `y`, or entry-wise negation for single **matrix** `x`.
(define* mx-
  (returns "**matrix** of entry-wise subtraction of **matrix**es `x` and `y`, or entry-wise negation for single **matrix** `x`.")
  (case-lambda [(x)   (matrix-map fpneg (ensure-mx x))]
               [(x y) (matrix-broadcast fp- (ensure-mx x) (ensure-mx y))]))

;;@returns: **matrix** of entry-wise division of **matrix**es `x` by `y`, or entry-wise reciprocal for a single **matrix** `x`.
(define* mx/
  (returns "**matrix** of entry-wise division of **matrix**es `x` by `y`, or entry-wise reciprocal for a single **matrix** `x`.")
  (case-lambda [(x)   (matrix-map fprec (ensure-mx x))]
               [(x y) (matrix-broadcast fp/ (ensure-mx x) (ensure-mx y))]))

;;@returns: **matrix** of entry-wise exponentiation of **matrix**es `x` to the `y`.
(define* (mx^ x y)
  (returns "**matrix** of entry-wise exponentiation of **matrix**es `x` to the `y`.")
  (matrix-broadcast fpexpt (ensure-mx x) (ensure-mx y)))

;;@returns: **matrix** of entry-wise base **matrix** `x` logarithms of **matrix** `y`.
(define* (mx-log x y)
  (returns "**matrix** of entry-wise base **matrix** `x` logarithms of **matrix** `y`.")
  (matrix-broadcast fplogb (ensure-mx x) (ensure-mx y)))

;;@returns: **matrix** of entry-wise absolute differences of **matrix**es `x` and `y`, aka distance.
(define* (mx-dist x y)
  (returns "**matrix** of entry-wise absolute differences of **matrix**es `x` and `y`.")
  (matrix-broadcast fpdist (ensure-mx x) (ensure-mx y)))

;;@returns: **matrix** of entries of **matrix**es `x` or `y` based on predicate **procedure** `pred`.
(define* (mx-where pred x y)
  (returns "**matrix** of entries of **matrix**es `x` or `y` based on predicate **procedure** `pred`.")
  (matrix-broadcast (lambda (x y) (if (pred x y) x y)) (ensure-mx x) (ensure-mx y)))

;;@returns: **matrix** of entry-wise generalized addition of **matrix** `x` with **flonum** `a` and **matrix** `y`, aka "axpy" (a times x plus y), see @1.
(define* (mx+* x a y)
  (returns "**matrix** of entry-wise generalized addition of **matrix** `x` with **flonum** `a` and **matrix** `y`.")
  (matrix-broadcast (cute fp+* <> (ensure-fp a) <>) (ensure-mx x) (ensure-mx y)))

;;; Matrix Mappers #############################################################

;; Rounding Functions

;;@returns: **matrix** with entries of **matrix** `mat` rounded to nearest integer.
(define* (mx-round mat)
  (returns "**matrix** with entries of **matrix** `mat` rounded to nearest integer.")
  (matrix-map fpround mat))

;;@returns: **matrix** with entries of **matrix** `mat` rounded to nearest upper integer.
(define* (mx-floor mat)
  (returns "**matrix** with entries of **matrix** `mat` rounded to nearest upper integer.")
  (matrix-map fpfloor mat))

;;@returns: **matrix** with entries of **matrix** `mat` rounded to nearest lower integer.
(define* (mx-ceil mat)
  (returns "**matrix** with entries of **matrix** `mat` rounded to nearest lower integer.")
  (matrix-map fpceiling mat))

;; Generalized Functions

;;@returns: **matrix** with entry-wise absolute value of **matrix** `mat`.
(define* (mx-abs mat)
  (returns "**matrix** with entry-wise absolute value of **matrix** `mat`.")
  (matrix-map fpabs mat))

;;@returns: **matrix** with entry-wise sign of **matrix** `mat`.
(define* (mx-sign mat)
  (returns "**matrix** with entry-wise sign of **matrix** `mat`.")
  (matrix-map fpsign mat))

;;@returns: **matrix** with entry-wise Dirac delta of **matrix** `mat`.
(define* (mx-dirac mat)
  (returns "**matrix** with entry-wise Dirac delta of **matrix** `mat`.")
  (matrix-map fpdirac mat))

;; Trigonometric Functions

;;@returns: **matrix** with entry-wise sine of **matrix** `mat`.
(define* (mx-sin mat)
  (returns "**matrix** with entry-wise sine of **matrix** `mat`.")
  (matrix-map fpsin mat))

;;@returns: **matrix** with entry-wise cosine of **matrix** `mat`.
(define* (mx-cos mat)
  (returns "**matrix** with entry-wise cosine of **matrix** `mat`.")
  (matrix-map fpcos mat))

;;@returns: **matrix** with entry-wise tangent of **matrix** `mat`.
(define* (mx-tan mat)
  (returns "**matrix** with entry-wise tangent of **matrix** `mat`.")
  (matrix-map fptan mat))

;; Inverse Trigonometric Functions

;;@returns: **matrix** with entry-wise inverse sine of **matrix** `mat`, aka arcsine.
(define* (mx-asin mat)
  (returns "**matrix** with entry-wise inverse sine of **matrix** `mat`.")
  (matrix-map fpasin mat))

;;@returns: **matrix** with entry-wise inverse cosine of **matrix** `mat`, aka arccosine.
(define* (mx-acos mat)
  (returns "**matrix** with entry-wise inverse cosine of **matrix** `mat`.")
  (matrix-map fpacos mat))

;;@returns: **matrix** with entry-wise inverse tangent of **matrix** `mat`, aka arctangent.
(define* (mx-atan mat)
  (returns "**matrix** with entry-wise inverse tangent of **matrix** `mat`.")
  (matrix-map fpatan mat))

;; Hyperbolic Functions

;;@returns: **matrix** with entry-wise hyperbolic sine of **matrix** `mat`.
(define* (mx-sinh mat)
  (returns "**matrix** with entry-wise hyperbolic sine of **matrix** `mat`.")
  (matrix-map fpsinh mat))

;;@returns: **matrix** with entry-wise hyperbolic cosine of **matrix** `mat`.
(define* (mx-cosh mat)
  (returns "**matrix** with entry-wise hyperbolic cosine of **matrix** `mat`.")
  (matrix-map fpcosh mat))

;;@returns: **matrix** with entry-wise hyperbolic tangent of **matrix** `mat`.
(define* (mx-tanh mat)
  (returns "**matrix** with entry-wise hyperbolic tangent of **matrix** `mat`.")
  (matrix-map fptanh mat))

;; Inverse Hyperbolic Functions

;;@returns: **matrix** with entry-wise inverse hyperbolic sine of **matrix** `mat`, aka area hyperbolic sine.
(define* (mx-asinh mat)
  (returns "**matrix** with entry-wise inverse hyperbolic sine of **matrix** `mat`.")
  (matrix-map fpasinh mat))

;;@returns: **matrix** with entry-wise inverse hyperbolic cosine of **matrix** `mat`, aka area hyperbolic cosine.
(define* (mx-acosh mat)
  (returns "**matrix** with entry-wise inverse hyperbolic cosine of **matrix** `mat`.")
  (matrix-map fpacosh mat))

;;@returns: **matrix** with entry-wise inverse hyperbolic tangent of **matrix** `mat`, aka area hyperbolic tangent.
(define* (mx-atanh mat)
  (returns "**matrix** with entry-wise inverse hyperbolic tangent of **matrix** `mat`.")
  (matrix-map fpatanh mat))

;; Haversed Trigonometric Functions

;;@returns: **matrix** with entry-wise haversed sine of **matrix** `mat`.
(define* (mx-hsin mat)
  (returns "**matrix** with entry-wise haversed sine of **matrix** `mat`.")
  (matrix-map fphsin mat))

;;@returns: **matrix** with entry-wise haversed cosine of **matrix** `mat`.
(define* (mx-hcos mat)
  (returns "**matrix** with entry-wise haversed cosine of **matrix** `mat`.")
  (matrix-map fphcos mat))

;; Roots

;;@returns: **matrix** with entry-wise square root of **matrix** `mat`.
(define* (mx-sqrt mat)
  (returns "**matrix** with entry-wise square root of **matrix** `mat`.")
  (matrix-map fpsqrt mat))

;;@returns: **matrix** with entry-wise sign times square-root of absolute value of **matrix** `mat`.
(define* (mx-signsqrt mat)
  (returns "**matrix** with entry-wise sign times square-root of absolute value of **matrix** `mat`.")
  (matrix-map fpsignsqrt mat))

;; Logarithms

;;@returns: **matrix** with entry-wise natural logarithm of **matrix** `mat`.
(define* (mx-ln mat)
  (returns "**matrix** with entry-wise natural logarithm of **matrix** `mat`.")
  (matrix-map fplog mat))

;;@returns: **matrix** with entry-wise base-2 logarithm of **matrix** `mat`.
(define* (mx-lb mat)
  (returns "**matrix** with entry-wise base-2 logarithm of **matrix** `mat`.")
  (matrix-map fplog2 mat))

;;@returns: **matrix** with entry-wise base-10 logarithm of **matrix** `mat`.
(define* (mx-lg mat)
  (returns "**matrix** with entry-wise base-10 logarithm of **matrix** `mat`.")
  (matrix-map fplog10 mat))

;; Exponentials

;;@returns: **matrix** with entry-wise exponential of **matrix** `mat`.
(define* (mx-exp mat)
  (returns "**matrix** with entry-wise exponential of **matrix** `mat`.")
  (matrix-map fpexp mat))

;;@returns: **matrix** with entry-wise Gaussian of **matrix** `mat`.
(define* (mx-gauss mat)
  (returns "**matrix** with entry-wise Gaussian of **matrix** `mat`.")
  (matrix-map fpgauss mat))

;; Special Functions

;;@returns: **matrix** with entry-wise cardinal sine of **matrix** `mat`.
(define* (mx-sinc mat)
  (returns "**matrix** with entry-wise cardinal sine of **matrix** `mat`.")
  (matrix-map fpsinc mat))

;;@returns: **matrix** with entry-wise sigmoid of **matrix** `mat`.
(define* (mx-sigm mat)
  (returns "**matrix** with entry-wise sigmoid of **matrix** `mat`.")
  (matrix-map fpsigm mat))

;;@returns: **matrix** with entry-wise Stirling approximation of **matrix** `mat`.
(define* (mx-stirling mat)
  (returns "**matrix** with entry-wise Stirling approximation of **matrix** `mat`.")
  (matrix-map fpstirling mat))

;;; Matrix Reductors ###########################################################

;; Sums

;;@returns: column-**matrix** of summing row entries of **matrix** `mat`.
(define* (mx-rowsum mat)
  (returns "column-**matrix** of summing row entries of **matrix** `mat`.")
  (matrix-rowfold fp+ 0.0 mat))

;;@returns: row-**matrix** of summing column entries of **matrix** `mat`.
(define* (mx-colsum mat)
  (returns "row-**matrix** of summing column entries of **matrix** `mat`.")
  (matrix-colfold fp+ 0.0 mat))

;;@returns: **flonum** of summing all entries of **matrix** `mat`.
(define* (mx-sum mat)
  (returns "**flonum** of summing all entries of **matrix** `mat`.")
  (matrix-allfold fp+ 0.0 mat))

;; Products

;;@returns: column-**matrix** of multiplying row entries of **matrix** `mat`.
(define* (mx-rowprod mat)
  (returns "column-**matrix** of multiplying row entries of **matrix** `mat`.")
  (matrix-rowfold fp* 1.0 mat))

;;@returns: row-**matrix** of multiplying column entries of **matrix** `mat`.
(define* (mx-colprod mat)
  (returns "row-**matrix** of multiplying column entries of **matrix** `mat`.")
  (matrix-colfold fp* 1.0 mat))

;;@returns: **flonum** of multiplying all entries of **matrix** `mat`.
(define* (mx-prod mat)
  (returns "**flonum** of multiplying all entries of **matrix** `mat`.")
  (matrix-allfold fp* 1.0 mat))

;; Minima

;;@returns: column-**matrix** of row-wise minima of **matrix** `mat`.
(define* (mx-rowmin mat)
  (returns "column-**matrix** of row-wise minima of **matrix** `mat`.")
  (matrix-rowfold fpmin +inf.0 mat))

;;@returns: row-**matrix** of column-wise minima of **matrix** `mat`.
(define* (mx-colmin mat)
  (returns "row-**matrix** of column-wise minima of **matrix** `mat`.")
  (matrix-colfold fpmin +inf.0 mat))

;;@returns: **flonum** minimum of all **matrix** `mat` entries.
(define* (mx-min mat)
  (returns "**flonum** minimum of all **matrix** `mat` entries.")
  (matrix-allfold fpmin +inf.0 mat))

;; Maxima

;;@returns: column-**matrix** of row-wise maxima of **matrix** `mat`.
(define* (mx-rowmax mat)
  (returns "column-**matrix** of row-wise maxima of **matrix** `mat`.")
  (matrix-rowfold fpmax -inf.0 mat))

;;@returns: row-**matrix** of column-wise maxima of **matrix** `mat`.
(define* (mx-colmax mat)
  (returns "row-**matrix** of column-wise maxima of **matrix** `mat`.")
  (matrix-colfold fpmax -inf.0 mat))

;;@returns: **flonum** maximum of all **matrix** `mat` entries.
(define* (mx-max mat)
  (returns "**flonum** maximum of all **matrix** `mat` entries.")
  (matrix-allfold fpmax -inf.0 mat))

;; Midrange

;;@returns: column-**matrix** of row-wise midrange of **matrix** `mat`.
(define* (mx-rowmidr mat)
  (returns "column-**matrix** of row-wise midrange of **matrix** `mat`.")
  (mx* 0.5 (mx+ (mx-rowmin mat) (mx-rowmax mat))))

;;@returns: row-**matrix** of column-wise midrange of **matrix** `mat`.
(define* (mx-colmidr mat)
  (returns "row-**matrix** of column-wise midrange of **matrix** `mat`.")
  (mx* 0.5 (mx+ (mx-colmin mat) (mx-colmax mat))))

;;@returns: **flonum** midrange of all **matrix** `mat` entries.
(define* (mx-midr mat)
  (returns "**flonum** midrange of all **matrix** `mat` entries.")
  (fp* 0.5 (fp+ (mx-min mat) (mx-max mat))))

;; Means

;;@returns: column-**matrix** of row-wise power means of **matrix** `mat` of type **symbol** `typ`, see @2.
(define* (mx-rowmean mat typ)
  (returns "column-**matrix** of row-wise power means of **matrix** `mat` of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.")
  (case typ [ (-1) (mx/ (fp (mx-cols mat)) (mx-rowsum (mx/ mat)))]
            [ (0)  (mx^ (mx-rowprod mat) (mx/ (fp (mx-cols mat))))]
            [ (1)  (mx/ (mx-rowsum mat) (fp (mx-cols mat)))]
            [ (2)  (mx-sqrt (mx/ (mx-rowsum (mx* mat mat)) (fp (mx-cols mat))))]
            [(inf) (mx-rowmax mat)]
            [else  (error 'mx-rowmean "Unknown row-mean!")]))

;;@returns: row-**matrix** of column-wise power means of **matrix** `mat` of type **symbol** `typ`, see @2.
(define* (mx-colmean mat typ)
  (returns "row-**matrix** of column-wise power means of **matrix** `mat` of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.")
  (case typ [ (-1) (mx/ (fp (mx-rows mat)) (mx-colsum (mx/ mat)))]
            [ (0)  (mx^ (mx-colprod mat) (mx/ (fp (mx-rows mat))))]
            [ (1)  (mx/ (mx-colsum mat) (fp (mx-rows mat)))]
            [ (2)  (mx-sqrt (mx/ (mx-colsum (mx* mat mat)) (fp (mx-rows mat))))]
            [(inf) (mx-colmax mat)]
            [else  (error 'mx-colmean "Unknown column-mean!")]))

;;@returns: **flonum** power mean of all **matrix** `mat` entries of type **symbol** `typ`, see @2.
(define* (mx-mean mat typ)
  (returns "**flonum** power mean of all **matrix** `mat` entries of type **symbol** `typ`, which can be `-1`, `0`, `1`, `2`, or `'inf`.")
  (case typ [ (-1) (fp/ (fp (mx-numel mat)) (mx-sum (mx/ mat)))]
            [ (0)  (fpexpt (mx-prod mat) (fprec (fp (mx-numel mat))))]
            [ (1)  (fp/ (mx-sum mat) (fp (mx-numel mat)))]
            [ (2)  (fpsqrt (fp/ (mx-sum (mx* mat mat)) (fp (mx-numel mat))))]
            [(inf) (mx-max mat)]
            [else  (error 'mx-mean "Unknown mean!")]))

;; Norms

;;@returns: column-**matrix** of row-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, see @3.
(define* (mx-rownorm mat typ)
  (returns "column-**matrix** of row-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `2`, or `'inf`.")
  (case typ [ (1)  (mx-rowsum (mx-abs mat))]
            [ (2)  (mx-sqrt (mx-rowsum (mx* mat mat)))]
            [(inf) (mx-rowmax (mx-abs mat))]
            [else  (error 'mx-rownorm "Unknown row-norm!")]))

;;@returns: row-**matrix** of column-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, see @3.
(define* (mx-colnorm mat typ)
  (returns "row-**matrix** of column-wise matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `2`, or `'inf`.")
  (case typ [ (1)  (mx-colsum (mx-abs mat))]
            [ (2)  (mx-sqrt (mx-colsum (mx* mat mat)))]
            [(inf) (mx-colmax (mx-abs mat))]
            [else  (error 'mx-colnorm "Unknown column-norm!")]))

;;@returns: **flonum** matrix norms of **matrix** `mat` of type **symbol** `typ`, see @3.
(define* (mx-norm mat typ)
  (returns "**flonum** matrix norms of **matrix** `mat` of type **symbol** `typ`, which can be `1`, `'inf`, `'fro`, or `'max`.")
  (case typ [ (1)  (mx-max (mx-colsum (mx-abs mat)))]
            [ (2)  (if (mx-vector? mat) (mx-norm mat 'fro) (error 'mx-norm "Spectral norm not implemented yet!"))] ; TODO: spectral norm (requires SVD)
            [(inf) (mx-max (mx-rowsum (mx-abs mat)))]
            [ (tr) (if (mx-vector? mat) (mx-norm mat 'fro) (error 'mx-norm "Trace norm not implemented yet!"))] ; TODO: trace norm (requires SVD)
            [(fro) (fpsqrt (mx-sum (mx* mat mat)))]
            [(max) (mx-max (mx-abs mat))]
            [else  (error 'mx-norm "Unknown norm!")]))

;;; Linear Algebra #############################################################

;;@returns: **matrix** of horizontally concatenated **matrix**es `x` and `y`.
(define* (mx-horcat x y)
  (returns "**matrix** of horizontally concatenated **matrix**es `x` and `y`.")
  (matrix-horcat x y))

;;@returns: **matrix** of vertically concatenated **matrix**es `x` and `y`.
(define* (mx-vercat x y)
  (returns "**matrix** of vertically concatenated **matrix**es `x` and `y`.")
  (matrix-vercat x y))

;;@returns: **matrix** of **fixnum** `rows`-times row-wise, and **fixnum** `cols`-times columns-wise repeated **matrix** `mat`.
(define* (mx-repeat mat rows cols)
  (returns "**matrix** of **fixnum** `rows`-times row-wise, and **fixnum** `cols`-times columns-wise repeated **matrix** `mat`.")
  (apply matrix-horcat (make-list cols (apply matrix-vercat (make-list rows mat)))))

;;@returns: **matrix** of vertically concatenated columns of **matrix** `mat`, aka vectorization.
(define* (mx-vec mat)
  (returns "**matrix** of vertically concatenated columns of **matrix** `mat`.")
  (matrix-vec mat))

;;@returns: **matrix** of entries of **matrix** `mat` with swapped row and column indices.
(define* (mx-transpose mat)
  (returns "**matrix** of entries of **matrix** `mat` with swapped row and column indices.")
  (matrix-transpose mat))

;;@returns: **matrix** being symmetric part of square **matrix** `mat`.
(define* (mx-sympart mat)
  (returns "**matrix** being symmetric part of square **matrix** `mat`.")
  (must-be (mx-square? mat))
  (mx* 0.5 (mx+ mat (mx-transpose mat))))

;;@returns: **matrix** being skey-symmetric part of square **matrix** `mat`, aka anti-symmetric part.
(define* (mx-skewpart mat)
  (returns "**matrix** being skey-symmetric part of square **matrix** `mat`, aka anti-symmetric part.")
  (must-be (mx-square? mat))
  (mx* 0.5 (mx- mat (mx-transpose mat))))

;;@returns: diagonal **matrix** from column **matrix** `mat`.
(define* (mx-diagonal mat)
  (returns "diagonal **matrix** from column **matrix** `mat`.")
  (must-be (mx-col? mat))
  (matrix-generate (lambda (i j)
                     (if (fx= i j) (matrix-ref mat i 0)
                                   0.0))
                   (matrix-rows mat) (matrix-rows mat)))

;; Linear Problems

;;@returns: **pair** of an orthogonal **matrix** (Q) and upper-right triangular **matrix** (R) factoring full column rank argument **matrix** `mat`, via column-wise modified Gram-Schmidt, see @4, @5.
(define* (mx-qr mat)
  (returns "**pair** of an orthogonal **matrix** (Q) and upper-right triangular **matrix** (R) factoring full column rank argument **matrix** `mat`.")
  (must-be (matrix? mat))
  (define cols (mx-cols mat))
  (define rows (mx-rows mat))
  (let rho [(Ak (matrix-explode mat))
            (Q  nil)
            (R  nil)]
    (if (empty? Ak) (cons (matrix-implode Q) (matrix-implode (reverse R)))
                    (let [(Rk (mx (fxmin cols rows) 1 0.0))]
                      (let cmgs [(i  1)
                                 (Qk (head Ak))
                                 (Qi Q)]
                        (cond [(fx> i rows) (rho (tail Ak) Q (cons Rk R))]
                              [(empty? Qi)  (let [(Rkk (mx-norm Qk 2))]
                                              (mx-set! Rk i 1 Rkk)
                                              (rho (tail Ak) (append Q (list (mx/ Qk Rkk))) (cons Rk R)))]
                              [else         (let [(Rik (matrix-scalar (head Qi) Qk))]
                                              (mx-set! Rk i 1 Rik)
                                              (cmgs (fx+1 i) (mx+* Qk (fpneg Rik) (head Qi)) (tail Qi)))]))))))

;;@returns: function returning column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and for argument column-**matrix** `vec`.
(define* (mx-solver mat)
  (returns "function returning column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and for argument column-**matrix** `vec`.")
  (must-be (matrix? mat))
  (let [(qr (mx-qr mat))]
    (lambda (vec)
      (back-subst (tail qr) (mx-dot* (head qr) vec)))))

;;@returns: column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and column-**matrix** `vec`.
(define* (mx-solve mat vec)
  (returns "column-**matrix** solving the linear (least-squares) problem of **matrix** `mat` and column-**matrix** `vec`.")
  (must-be (matrix-col? vec))
  ((mx-solver mat) vec))

;;@returns: **flonum** being the absolute value of the determinant of **matrix** `mat`.
(define* (mx-absdet mat)
  (returns "**flonum** being the absolute value of the determinant of **matrix** `mat`.")
  (must-be (mx-square? mat))
  (let [(qr (mx-qr mat))]
    (mx-prod (mx-diag (tail qr)))))

;;@returns: **flonum** being the logarithm of the determinant of **matrix** `mat`.
(define* (mx-logdet mat)
  (returns "**flonum** being the logarithm of the determinant of **matrix** `mat`.")
  (must-be (mx-square? mat))
  (let [(qr (mx-qr mat))]
    (mx-sum (mx-ln (mx-diag (tail qr))))))

;; Traces

;;@returns: **flonum** being sum of square **matrix** `mat` diagonal entries.
(define* (mx-trace mat)
  (returns "**flonum** being sum of square **matrix** `mat` diagonal entries.")
  (mx-sum (mx-diag mat)))

;;@returns: **flonum** being product of square **matrix** `mat` diagonal entries.
(define* (mx-multrace mat)
  (returns "**flonum** being product of square **matrix** `mat` diagonal entries.")
  (mx-prod (mx-diag mat)))

;;@returns: **flonum** being the trace of the matrix product of **matrix** `x` and transposed **matrix** `yt`.
(define* (mx-prodtrace* x yt)
  (returns "**flonum** being the trace of the matrix product of **matrix** `x` and transposed **matrix** `yt`.")
  (must-be (mx-samecols? x yt) (mx-samerows? x yt))
  (mx-sum (mx* x yt)))

;;@returns: **flonum** being the trace of the matrix product of **matrix**es `x` and `y`.
(define* (mx-prodtrace x y)
  (returns "**flonum** being the trace of the matrix product of **matrix**es `x` and `y`.")
  (mx-prodtrace* x (mx-transpose y)))

;; Matrix Multiplication

;;@returns: **flonum** resulting from scalar product of column-**matrix** `x` and column-**matrix** `y`.
(define* (mx-scalar x y)
  (returns "**flonum** resulting from scalar product of column-**matrix** `x` and column-**matrix** `y`.")
  (matrix-scalar x y))

;;@returns: **matrix** resulting from matrix multiplication of transposed **matrix** `xt` and **matrix** `y`.
(define* (mx-dot* xt y)
  (returns "**matrix** resulting from matrix multiplication of transposed **matrix** `xt` and **matrix** `y`.")
  (matrix-dot* xt y))

;;@returns: **matrix** resulting from matrix multiplication of **matrix**es `x` and `y`.
(define* (mx-dot x y)
  (returns "**matrix** resulting from matrix multiplication of **matrix**es `x` and `y`.")
  (matrix-dot* (mx-transpose x) y))

;;@returns: **matrix** resulting from matrix multiplication of transposed **matrix** `mat` with itself, aka Gram matrix.
(define* (mx-gram mat)
  (returns "**matrix** resulting from matrix multiplication of transposed **matrix** `mat` with itself.")
  (matrix-dot* mat mat))

;;@returns: **matrix** resulting from matrix multiplication of **matrix** `mat` with itself transposed.
(define* (mx-gram* mat)
  (returns "**matrix** resulting from matrix multiplication of **matrix** `mat` with itself transposed.")
  (let [(matt (mx-transpose mat))]
    (mx-dot* matt matt)))

;;@returns: **matrix** resulting from matrix multiplication of **matrix** `mat` with itself.
(define* (mx-square mat)
  (returns "**matrix** resulting from matrix multiplication of **matrix** `mat` with itself.")
  (mx-dot mat mat))

;; Statistics

;;@returns: **matrix** of cross-covariances of **matrix**es `x` and `y`, representing columns of observations.
(define* (mx-xcov x y)
  (returns "**matrix** of cross-covariances of **matrix**es `x` and `y`, representing columns of observations.")
  (must-be (mx-samecols? x y))
  (mx/ (mx-dot* (mx-transpose (mx- x (mx-rowmean x 1))) (mx-transpose (mx- y (mx-rowmean y 1)))) (fp (mx-cols x))))

;;@returns: **matrix** of covariances of **matrix** `mat`, representing columns of observations.
(define* (mx-cov mat)
  (returns "**matrix** of covariances of **matrix** `mat`, representing columns of observations.")
  (mx/ (mx-gram* (mx-transpose (mx- mat (mx-rowmean mat 1)))) (fp (mx-cols mat))))

;;@returns: column **matrix** of standard deviations of **matrix** `mat`, representing columns of observations.
(define* (mx-std mat)
  (returns "column **matrix** of standard deviations of **matrix** `mat`, representing columns of observations.")
  (mx-rownorm (mx- mat (mx-rowmean mat 1)) 2))

;;@returns: **matrix** of cross-correlations of **matrix**es `x` and `y`, representing columns of observations.
(define* (mx-xcor x y)
  (returns "**matrix** of cross-correlations of **matrix**es `x` and `y`, representing columns of observations.")
  (mx/ (mx-xcov x y) (mx* (mx-std x) (mx-std y))))

;;@returns: **matrix** of correlations of **matrix** `mat`, representing columns of observations.
(define* (mx-cor mat)
  (returns "**matrix** of correlations of **matrix** `mat`, representing columns of observations.")
  (mx/ (mx-cov mat) (mx* (mx-std mat))))

;;@returns: **flonum** of distance coherence between **matrix**es `x` and `y`.
(define* (mx-coher x y)
  (returns "**flonum** of distance coherence between **matrix**es `x` and `y`.")
  (mx/ (mx* (mx-prodtrace x y)) (mx* (mx-prodtrace x x) (mx-prodtrace y y))))

;;; Analysis ###################################################################

;;@returns: **matrix** of differences of consecutives columns of **matrix** `mat`.
(define* (mx-diff mat)
  (returns "**matrix** of differences of consecutives columns of **matrix** `mat`.")
  (must-be (fx>= (mx-cols mat) 2))
  (mx- (mx-submatrix mat 1 -1 2 -1) (mx-submatrix mat 1 -1 1 -2)))

;;@returns: column-**matrix** trapezoid approximate integral of **matrix** `mat` being columns data-points of rows-dimensional function.
(define* (mx-trapz mat)
  (returns "column-**matrix** trapezoid approximate integral of **matrix** `mat` being columns data-points of rows-dimensional function.")
  (mx+* (mx+* (mx-rowsum mat) -0.5 (mx-col mat 1)) -0.5 (mx-col mat -1)))

;;@returns: states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order hyperbolic Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`, see @6.
(define* (mx-ode2-hyp num fun x0 dt tf)
  (returns "states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order hyperbolic Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`, see @6.")
  (must-be (fixnum? num) (<= 2 num 12))
  (let* [(coeff (case num [ (2) (list (fp% 1 2)  1.0)]
                          [ (3) (list (fp% 1 3)  (fp% 1 2)  1.0)]
                          [ (4) (list (fp% 1 4)  (fp% 2 6)  (fp% 1 2)  1.0)]
                          [ (5) (list (fp% 1 5)  (fp% 2 10) (fp% 1 3)  (fp% 1 2)   1.0)]
                          [ (6) (list (fp% 1 6)  (fp% 2 15) (fp% 1 4)  (fp% 8 24)  (fp% 1 2) 1.0)]
                          [ (7) (list (fp% 1 7)  (fp% 2 21) (fp% 1 5)  (fp% 8 35)  (fp% 1 3) (fp% 1 2)   1.0)]
                          [ (8) (list (fp% 1 8)  (fp% 2 28) (fp% 1 6)  (fp% 8 48)  (fp% 1 4) (fp% 1 3)   (fp% 1 2) 1.0)]
                          [ (9) (list (fp% 1 9)  (fp% 2 36) (fp% 1 7)  (fp% 8 63)  (fp% 1 5) (fp% 5 21)  (fp% 1 3) (fp% 1 2)   1.0)]
                          [(10) (list (fp% 1 10) (fp% 2 45) (fp% 1 8)  (fp% 8 80)  (fp% 1 6) (fp% 9 50)  (fp% 1 4) (fp% 1 3)   (fp% 1 2) 1.0)]
                          [(11) (list (fp% 1 11) (fp% 2 55) (fp% 1 9)  (fp% 8 99)  (fp% 1 7) (fp% 14 99) (fp% 1 5) (fp% 8 33)  (fp% 1 3) (fp% 1 2) 1.0)]
                          [(12) (list (fp% 1 12) (fp% 2 66) (fp% 1 10) (fp% 8 120) (fp% 1 8) (fp% 4 35)  (fp% 1 6) (fp% 14 75) (fp% 1 4) (fp% 1 3) (fp% 1 2) 1.0)]
                          [else (error 'mx-ode2-hyp "Invalid number of stages, should be in [2,12].")]))
         (hyp   (lambda (tk xk)
                  (let rho [(cur coeff)
                            (ret xk)]
                    (if (empty? cur) ret
                                     (rho (tail cur) (mx+* xk (fp* dt (head cur)) (fun (fp+ tk (head cur)) ret)))))))]
    (time-stepper hyp fun x0 dt tf)))

;;@returns: states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order strong stability preserving Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`, see @7.
(define* (mx-ode2-ssp num fun x0 dt tf)
  (returns "states-times-steps **matrix** trajectory solving an ordinary differential equation, by a 2nd order strong stability preserving Runge-Kutta method of **fixnum** `num` stages, with vector field **procedure** `fun`, initial state column-**matrix** `x0`, time step **flonum** `dt`, and time horizon **flonum** `tf`, see @7.")
  (must-be (fixnum? num) (fx>0? num))
  (let* [(s-1    (fp (fx-1 num)))
         (dt/s-1 (fp/ dt s-1))
         (ssp    (lambda (tk xk)
                   (let rho [(cur (fx-1 num))
                             (c   tk)
                             (ret xk)]
                     (if (fx=0? cur) (mx/ (mx+* (mx+* xk s-1 ret) dt (fun c ret)) (fp num))
                                     (rho (fx-1 cur) (fp+ tk dt/s-1) (mx+* ret dt/s-1 (fun c ret)))))))]
    (time-stepper ssp fun x0 dt tf)))

;;; Matrix Utilities ###########################################################

;;@returns: **void**, prints **matrix** `mat` to terminal.
(define* (mx-print mat)
  (returns "**void**, prints **matrix**.")
  (define prec (flonum-print-precision 18))
  (matrix-print fptaper mat)
  (flonum-print-precision prec)
  (void))

;;@returns: **void**, writes **matrix** `mat` to new comma-separated-value (CSV) file in relative path **string** `str`.
(define* (mx-export str mat)
  (returns "**void**, writes **matrix** `mat` to new comma-separated-value (CSV) file in relative path **string** `str`.")
  (define prec (flonum-print-precision 18))
  (matrix-export str mat)
  (flonum-print-precision prec)
  (void))

;;@returns: **void**, writes **matrix** `mat` to new Scheme (SCM) file in relative path **string** `str`.
(define* (mx-save str mat)
  (returns "**void**, writes **matrix** `mat` to new Scheme (SCM) file in relative path **string** `str`.")
  (define prec (flonum-print-precision 18))
  (matrix-save str mat)
  (flonum-print-precision prec)
  (void))

;;@returns: **matrix** loaded from file in relative path **string** `str`.
(define* (mx-load str)
  (returns "**matrix** loaded from file in relative path **string** `str`.")
  (matrix-load str))

;;; References #################################################################

;;@1: Basic Linear Algebra Subprogram, Level 1. Wikipedia. https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms#Level_1

;;@2: Generalized mean. Wikipedia. https://en.wikipedia.org/wiki/Generalized_mean

;;@3: Matrix norm. Wikipedia. https://en.wikipedia.org/wiki/Matrix_norm

;;@4: A.V. Ratz. **Can QR Decomposition Be Actually Faster? Schwarz-Rutishauser Algorithm**. Towards Data Science. https://towardsdatascience.com/can-qr-decomposition-be-actually-faster-schwarz-rutishauser-algorithm-a32c0cde8b9b

;;@5: S.J. Leon, A. Björck, W. Gander: **Gram–Schmidt orthogonalization: 100 years and more**. Numerical Linear Algebra with Applications 20: 492--532, 2013. https://doi.org/10.1002/nla.1839

;;@6: I.P.E. Kinnmark, W.G. Gray: **One Step Integration Methods of Third-Fourth Order Accuracy with Large Hyperbolic Stability Limits**. Mathematics and Computers in Simulation 26(3): 181--188, 1984. https://doi.org/10.1016/0378-4754(84)90056-9

;;@7: D.I. Ketcheson: **Highly Efficient Strong Stability-Preserving Runge-Kutta Methods with Low-Storage Implementations**. SIAM Journal on Scientific Computing 30(4): 2113--2136, 2008. https://doi.org/10.1137/07070485X

