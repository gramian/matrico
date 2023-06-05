;;;; fpmath.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.5 (2023-06-06)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: floating-point add-on module

(include-relative "utils.scm")

(module fpmath

  (fp fp%
   fpzero?? fpzero?
   fp*2 fp^2 fprec fp*+
   fptau fpeul fpphi
   fpdelta fpheaviside fpsign
   fpln fplb fplg
   fpsinh fpcosh fptanh
   fpasinh fpacosh fpatanh
   fphsin fphcos
   fplnsinh fplncosh
   fpsignsqrt fpsinc fpsigm fpgauss fpstirling
   fptaper)

  (import scheme (chicken base) (chicken module) (chicken flonum) utils)

  (reexport (chicken flonum))

;;; Converter ##################################################################

;;@assigns: **alias** for `exact->inexact`.
(define fp exact->inexact)

;;@returns: **flonum** fraction with numerator **fixnum** `n` and denominator **fixnum** `d`.
(define (fp% n d)
  (fp/ (fp n) (fp d)))

;;; Predicates #################################################################

;;@returns: **boolean** answering if **flonum** `x` is exactly zero.
(define (fpzero?? x)
  (fp= 0.0 x))

;;returns: **boolean** answering if absolute value of **flonum** `x` is less or equal than positive **flonum** `tol`.
(define (fpzero? x tol)
  (fp<= (fpabs x) tol))

;;; Operators ##################################################################

;;@returns: **flonum** double of **flonum** `x`.
(define (fp*2 x)
  (fp+ x x))

;;@returns: **flonum** square of **flonum** `x`.
(define (fp^2 x)
  (fp* x x))

;;@returns: **flonum** reciprocal of **flonum** `x`.
(define (fprec x)
  (fp/ 1.0 x))

;;@returns: **flonum** sum with product: `x * y + z` of **flonum**s `x`, `y`, `z`, see @1, @2, @3.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fp*+ x y z)
       (fp+ (fp* x y) z))]
  [else])

;;; Constants Thunks ###########################################################

;;@returns: **flonum** circle constant Tau via fraction, see @4, @5, @6.
(define fptau (constantly (fp% 491701844 78256779)))

;;@returns: **flonum** Euler number via fraction, see @7, @8, @9.
(define fpeul (constantly (fp% 410105312 150869313)))

;;@returns: **flonum golden ratio via fraction of consecutive Fibonacci numbers, see @10.
(define fpphi (constantly (fp% 165580141 102334155)))

;;; Generalized Functions ######################################################

;;@returns: **flonum** Kronecker delta of **flonum** `x`.
(define (fpdelta x)
  (if (fpzero?? x) 1.0
                   0.0))

;;@returns: **flonum** Heaviside step function of **flonum** `x`.
(define (fpheaviside x)
  (if (fp> x 0.0) 1.0
                  0.0))

;;@returns: **flonum** sign of **flonum** `x`.
(define (fpsign x)
  (cond [(fp> x 0.0)  1.0]
        [(fp< x 0.0) -1.0]
        [else         0.0]))

;;; Logarithms #################################################################

;;@assigns: **alias** for `fplog`.
(define fpln fplog)

;;@returns: **flonum** base-2 logarithm of **flonum** `x`.
(define fplb
  (let [(log2 (fplog 2.0))]
    (lambda (x)
      (fp/ (fplog x) log2))))

;;@returns: **flonum** base-10 logarithm of **flonum** `x`.
(define fplg
  (let [(log10 (fplog 10.0))]
    (lambda (x)
      (fp/ (fplog x) log10))))

;;; Hyperbolic Functions #######################################################

;;@returns: **flonum** hyperbolic sine of **flonum** `x`: `sinh(x) = 0.5 * (exp(x) - exp(-x))`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fpsinh x)
       (fp* 0.5 (fp- (fpexp x) (fpexp (fpneg x)))))]
  [else])

;;@returns: **flonum** hyperbolic cosine of **flonum** `x`: `cosh(x) = 0.5 * (exp(x) + exp(-x))`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fpcosh x)
       (fp* 0.5 (fp+ (fpexp x) (fpexp (fpneg x)))))]
  [else])

;;@returns: **flonum** hyperbolic tangent of **flonum** `x`: `tanh(x) = 1 - 2 / (exp(2 * x) + 1)`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fptanh x)
       (fp- 1.0 (fp/ 2.0 (fp+ (fpexp (fp*2 x)) 1.0))))]
  [else])

;;; Inverse Hyperbolic Functions ###############################################

;;@returns: **flonum** area hyperbolic sine of **flonum** `x`: `asinh(x) = log(x + sqrt(x^2 + 1))`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fpasinh x)
       (fp* (fpsign x) (fplog (fp+ (fpabs x) (fpsqrt (fp+ (fp^2 x) 1.0))))))]
  [else])

;;@returns: **flonum** area hyperbolic cosine of **flonum** `x`: `acosh(x) = log(x + sqrt(x^2 - 1))`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fpacosh x)
       (fplog (fp+ x (fpsqrt (fp- (fp^2 x) 1.0)))))]
  [else])

;;@returns: **flonum** area hyperbolic tangent of **flonum** `x`: `atanh(x) = 0.5 * log((1 + x) / (1 - x))`.
(cond-expand
  [(or chicken-5.0 chicken-5.1 chicken-5.2 chicken-5.3)
     (define (fpatanh x)
       (fp* 0.5 (fplog (fp/ (fp+ 1.0 x) (fp- 1.0 x)))))]
  [else])

;;; Haversed Trigonometric Functions ###########################################

;;@returns: **flonum** haversed sine of **flonum** `x`: `hsin(x) = 0.5 * (1 - cos(x))`, see @11.
(define (fphsin x)
  (fp* 0.5 (fp- 1.0 (fpcos x))))

;;@returns: **flonum** haversed cosine of **flonum** `x`: `hcos(x) = 0.5 * (1 + cos(x))`, see @11.
(define (fphcos x)
  (fp* 0.5 (fp+ 1.0 (fpcos x))))

;;; Logarithmic Hyperbolic Functions ###########################################

;;@returns: **flonum** log-sinh **flonum** `x`: `lnsinh(x) = ln(sinh(x))`, see @12.
(define (fplnsinh x)
  (fplog (fpsinh x)))

;;@returns: **flonum** log-cosh **flonum** `x`: `lncosh(x) = ln(cosh(x))`, see @12.
(define (fplncosh x)
  (fplog (fpcosh x)))

;;; Special Functions ##########################################################

;;@returns: **flonum** sign times square root of absolute value of **flonum** `x`: `signsqrt(x) = sign(x) * sqrt(abs(x))`.
(define (fpsignsqrt x)
  (fp* (fpsign x) (fpsqrt (fpabs x))))

;;@returns: **flonum** cardinal sine function with removed singularity of **flonum** `x`: `sinc(x) = sin(x) / x`.
(define (fpsinc x)
  (if (fpzero?? x) 1.0
                   (fp- (fp+ (fp/ (fpsin x) x) 1.0) 1.0)))

;;@returns: **flonum** standard logistic function of **flonum** `x`, aka sigmoid: `sigm(x) = 1 / (1 + exp(-x))`.
(define (fpsigm x)
  (fprec (fp+ 1.0 (fpexp (fpneg x)))))

;;@returns: **flonum** Gauss bell curve function evaluation of **flonum** `x`: `gauss(x) = exp(-0.5 * x^2)`.
(define (fpgauss x)
  (fpexp (fp* -0.5 (fp^2 x))))

;;@returns: **flonum** Stirling's approximation of factorial of **flonum** `x`: `x! ≈ sqrt(tau * x) * (x / e)^x`.
(define (fpstirling x)
  (fpround (fp* (fpsqrt (fp* (fptau) x)) (fpexpt (fp/ x (fpeul)) x))))

;;; Utilities ##################################################################

;;@returns **string** representation of **flonum** `x` formatted to 8 character fixed width.
(define (fptaper x)
  (let* [(prc  (flonum-print-precision 17))
         (sgnx (cond [(fp> x 0.0) "+"]
                     [(fp< x 0.0) "-"]
                     [else        ""]))
         (absx (fpabs x))
         (lgx  (fplg absx))
         (strx (number->string absx))
         (lenx (string-length strx))]
    (flonum-print-precision prc)
    (apply string-append (if (finite? x) "" "   ")
                         sgnx
                         (cond [(nan? x)          '("NaN  ")]
                               [(fpzero?? x)      '("    0   ")]
                               [(not (finite? x)) '("\u221E   ")]  ; `infinite?` does not work with chicken-5.1
                               [(fp<= lgx -5.0)   '("0.0000\u2026")]
                               [(fp<= lgx -4.0)   `("0.0000" ,(substring strx 0 1))]
                               [(fp>= lgx  6.0)   `(,(substring strx 0 5) "\u2026.")]
                               [else              `(,(substring strx 0 (min 7 lenx)) ,(make-string (max 0 (- 7 lenx)) #\0))]))))

);end module

;;; References #################################################################

;;@1: Multiply-Accumulate Operation. Wikipedia. https://en.wikipedia.org/wiki/Multiply%E2%80%93accumulate_operation

;;@2: scheme.flonum. Gauche Reference Manual, 10.3.24. https://practical-scheme.net/gauche/man/gauche-refe/R7RS-large.html#index-fl_002b_002a

;;@3: Flonum Operations. MIT Scheme Reference. https://www.gnu.org/software/mit-scheme/documentation/stable/mit-scheme-ref.html#Flonum-Operations

;;@4: Numerators of convergents to Pi. The On-Line Encyclopedia of Integer Sequences, A002485. https://oeis.org/A002485

;;@5: Denominators of convergents to Pi. The On-Line Encyclopedia of Integer Sequences, A002486. https://oeis.org/A002486

;;@6: Number of correct decimal digits given by the n-th convergent to Pi. The On-Line Encyclopedia of Integer Sequences, A114526. https://oeis.org/A114526

;;@7: Numerators of convergents to e. The On-Line Encyclopedia of Integer Sequences, A007676. https://oeis.org/A007676

;;@8: Denominators of convergents to e. The On-Line Encyclopedia of Integer Sequences, A007677. https://oeis.org/A007677

;;@9: Number of correct decimal digits given by the n-th convergent to e. The On-Line Encyclopedia of Integer Sequences, A114539. https://oeis.org/A114539

;;@10: Fibonacci numbers. The On-Line Encyclopedia of Integer Sequences, A000045. https://oeis.org/A000045

;;@11: Versine. Wikipedia. https://en.wikipedia.org/wiki/Versine

;;@12: Hyperbolic Trigonometric Functions. GNU Scientific Library. https://www.gnu.org/software/gsl/doc/html/specfunc.html#hyperbolic-trigonometric-functions
