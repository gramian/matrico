;;;; fpmath.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-05-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: floating-point add-on module

(include-relative "utils.scm")

(module fpmath

  (fp fp%
   fpzero??
   fpdbl fpsqr fprec fpdist fp+*
   fptau fpeul fpphi
   fpdirac fpheaviside fpsign
   fplog2 fplog10 fplogb
   fpsinh fpcosh fptanh
   fpasinh fpacosh fpatanh
   fphsin fphcos
   fpgauss fpsignsqrt fpsinc fpsigm fpstirling
   fptaper)

  (import scheme (chicken base) (chicken module) (chicken flonum) utils)
  (reexport (chicken flonum))

;;; Converter ##################################################################

;;@returns: **flonum** from **fixnum** `n`.
(alias fp exact->inexact)

;;@returns: **flonum** fraction with numerator **fixnum** `n` and denominator **fixnum** `d`.
(define (fp% n d)
  (fp/ (fp n) (fp d)))

;;; Predicates #################################################################

;;@returns: **boolean** answering if **flonum** `x` is exactly zero.
(define (fpzero?? x)
  (fp= 0.0 x))

;;; Operators ##################################################################

;;@returns: **flonum** double of **flonum** `x`.
(define (fpdbl x)
  (fp+ x x))

;;@returns: **flonum** square of **flonum** `x`.
(define (fpsqr x)
  (fp* x x))

;;@returns: **flonum** reciprocal of **flonum** `x`.
(define (fprec x)
  (fp/ 1.0 x))

;;@returns: **flonum** absolute difference: `|x - y|` of **flonum**s `x`, `y`.
(define (fpdist x y)
  (fpabs (fp- x y)))

;;@returns: **flonum** sum with product: `z + x * y` of **flonum**s `x`, `y`, `z`, see @1, @2, @3.
(define (fp+* z x y)
  (fp+ z (fp* x y)))

;;; Constants Thunks ###########################################################

;;@returns: **flonum** circle constant Tau via fraction, see @4, @5, @6.
(define fptau (constantly (fp% 491701844 78256779)))

;;@returns: **flonum** Euler number via fraction, see @7, @8, @9.
(define fpeul (constantly (fp% 410105312 150869313)))

;;@returns: **flonum golden ratio via fraction of consecutive Fibonacci numbers, see @10.
(define fpphi (constantly (fp% 165580141 102334155)))

;;; Generalized Functions ######################################################

;;@returns: **flonum** Dirac delta of **flonum** `x`.
(define (fpdirac x)
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

;;@returns: **flonum** base-2 logarithm of **flonum** `x`.
(define fplog2
  (let [(ln2 (fplog 2.0))]
    (lambda (x)
      (fp/ (fplog x) ln2))))

;;@returns: **flonum** base-10 logarithm of **flonum** `x`.
(define fplog10
  (let [(ln10 (fplog 10.0))]
    (lambda (x)
      (fp/ (fplog x) ln10))))

;;@returns: **flonum** base `b` logarithm of **flonum** `x`.
(define (fplogb b x)
  (fp/ (fplog x) (fplog b)))

;;; Hyperbolic Functions #######################################################

;;@returns: **flonum** hyperbolic sine of **flonum** `x`: `sinh(x) = 0.5 * (exp(x) - exp(-x))`.
(define (fpsinh x)
  (fp* 0.5 (fp- (fpexp x) (fpexp (fpneg x)))))

;;@returns: **flonum** hyperbolic cosine of **flonum** `x`: `cosh(x) = 0.5 * (exp(x) + exp(-x))`.
(define (fpcosh x)
  (fp* 0.5 (fp+ (fpexp x) (fpexp (fpneg x)))))

;;@returns: **flonum** hyperbolic tangent of **flonum** `x`: `tanh(x) = 1 - 2 / (exp(2 * x) + 1)`.
(define (fptanh x)
  (fp- 1.0 (fp/ 2.0 (fp+ (fpexp (fpdbl x)) 1.0))))

;;; Inverse Hyperbolic Functions ###############################################

;;@returns: **flonum** area hyperbolic sine of **flonum** `x`: `asinh(x) = log(x + sqrt(x^2 + 1))`.
(define (fpasinh x)
  (fp* (fpsign x) (fplog (fp+ (fpabs x) (fpsqrt (fp+ (fpsqr x) 1.0))))))

;;@returns: **flonum** area hyperbolic cosine of **flonum** `x`: `acosh(x) = log(x + sqrt(x^2 - 1))`.
(define (fpacosh x)
  (fplog (fp+ x (fpsqrt (fp- (fpsqr x) 1.0)))))

;;@returns: **flonum** area hyperbolic tangent of **flonum** `x`: `atanh(x) = 0.5 * log((1 + x) / (1 - x))`.
(define (fpatanh x)
  (fp* 0.5 (fplog (fp/ (fp+ 1.0 x) (fp- 1.0 x)))))

;;; Haversed Trigonometric Functions ###########################################

;;@returns: **flonum** haversed sine of **flonum** `x`: `hsin(x) = 0.5 * (1 - cos(x))`.
(define (fphsin x)
  (fp* 0.5 (fp- 1.0 (fpcos x))))

;;@returns: **flonum** haversed cosine of **flonum** `x`: `cosh(x) = 0.5 * (1 + cos(x))`.
(define (fphcos x)
  (fp* 0.5 (fp+ 1.0 (fpcos x))))

;;; Special Functions ##########################################################

;;@returns: **flonum** Gauss bell curve function evaluation of **flonum** `x`: `gauss(x) = exp(-0.5 * x^2)`.
(define (fpgauss x)
  (fpexp (fp* -0.5 (fpsqr x))))

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

;;@returns: **flonum** Stirling approximation of factorial of **flonum** `x`: `x! ≈ sqrt(tau * x) * (x / e)^x`.
(define (fpstirling x)
  (fpround (fp* (fpsqrt (fp* (fptau) x)) (fpexpt (fp/ x (fpeul)) x))))

;;; Utilities ##################################################################

;;@returns **string** representation of **flonum** `x` formatted to 8 character fixed width.
(define (fptaper x)
  (must-be (flonum? x))
  (let* [(prc  (flonum-print-precision 17))
         (sgnx (cond [(fp> x 0.0) "+"]
                     [(fp< x 0.0) "-"]
                     [else        " "]))
         (absx (fpabs x))
         (lgx  (fplog10 absx))
         (strx (number->string absx))
         (lenx (string-length strx))]
    (flonum-print-precision prc)
    (apply string-append sgnx (cond [(fpzero?? x)    '("   0   ")]
                                    [(fp<= lgx -5.0) '("0.0000\u2026")]
                                    [(fp<= lgx -4.0) `("0.0000" ,(substring strx 0 1))]
                                    [(fp>= lgx  6.0) `(,(substring strx 0 5) "\u2026.")]
                                    [else            `(,(substring strx 0 (min 7 lenx)) ,(make-string (max 0 (- 7 lenx)) #\0))]))))

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

