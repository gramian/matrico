;;;; matrico.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.3 (2022-09-16)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: A CHICKEN Scheme flonum matrix module.

(include-relative "src/dense.scm")

(module matrico

  (matrico
   mx mx%
   mx-identity mx-exchange mx-hilbert mx-pascal mx-lehmer mx-random mx-tridiag
   mx-unit mx-iota
   mx-linspace mx-logspace
   mx-cols mx-rows mx-numel mx-dims
   mx?
   mx-col? mx-row? mx-scalar? mx-vector? mx-square?
   mx-samecols? mx-samerows? mx-samedims?
   mx-any? mx-all? mx=?
   mx-ref11 mx-ref mx-set mx-set! mx-col mx-row mx-diag mx-submatrix
   mx+ mx* mx- mx/ mx*2 mx^2
   mx^ mx-log mx-where mx*+
   mx-round mx-floor mx-ceil
   mx-abs mx-sign mx-delta mx-heaviside
   mx-sin mx-cos mx-tan
   mx-asin mx-acos mx-atan
   mx-sinh mx-cosh mx-tanh
   mx-asinh mx-acosh mx-atanh
   mx-hsin mx-hcos
   mx-lnsinh mx-lncosh
   mx-sqrt mx-signsqrt
   mx-ln mx-lb mx-lg
   mx-exp mx-gauss
   mx-sinc mx-sigm mx-stirling
   mx-rowsum mx-colsum mx-sum
   mx-rowprod mx-colprod mx-prod
   mx-rowmin mx-colmin mx-min
   mx-rowmax mx-colmax mx-max
   mx-rowmidr mx-colmidr mx-midr
   mx-rowmean mx-colmean mx-mean
   mx-rownorm mx-colnorm mx-norm
   mx-horcat mx-vercat
   mx-vec mx-transpose
   mx-sympart mx-skewpart
   mx-diagonal
   mx-qr mx-solver mx-solve
   mx-absdet mx-logdet
   mx-trace mx-multrace mx-prodtrace* mx-prodtrace
   mx-scalar mx-dyadic mx-dot* mx-dot mx-gram mx-gram* mx-square
   mx-xcov mx-cov mx-std
   mx-xcor mx-cor mx-coher
   mx-diff mx-trapz mx-ode2-hyp mx-ode2-ssp
   mx-print mx-export mx-save mx-load)

  (import scheme (chicken module) (chicken base) (chicken plist) (chicken random) (chicken time) utils fpmath dense)

  (reexport (except fpmath fptaper))

(include-relative "src/mx.scm")

;;; Matrico Meta Information ###################################################

(cond-expand [(or chicken-5.0 chicken-5.1 chicken-5.2)
                (define current-process-milliseconds current-milliseconds)]
             [else])

;;@assigns: matrico version number as pair.
(define-constant version '(0 . 3))

;;@returns
(define (matrico . s)
  (define sym (optional s 'exe))
  (must-be (symbol? sym))
  (case sym ['exe (begin
                    (newline)
                    (print "(matrico) - Returns void, prints this message.")
                    (print "(matrico 'list) - Returns void, prints list of \"mx\" functions.")
                    (print "(matrico 'about) - Returns void, prints summary about \"matrico\".")
                    (print "(matrico 'banner) - Returns void, prints \"matrico\" banner.")
                    (print "(matrico 'version) - Returns pair of major and minor version number.")
                    (print "(matrico 'citation) - Returns void, prints \"matrico\" citation information.")
                    (print "(matrico 'benchmark) - Returns million-additions-per-second for current machine.")
                    (print "(matrico s) - Returns #t if argument symbol is \"mx\" function, prints docstring.")
                    (newline))]

            ['list (let rho [(lst (symbol-plist 'returns))]
                     (if (or (empty? lst) (empty? (tail lst))) (void)
                                                                 (begin
                                                                   (print (symbol->string (head lst)))
                                                                   (rho (tail (tail lst))))))]

            ['about (begin
                      (newline)
                      (print "\
`matrico` is a flonum matrix module for CHICKEN Scheme, providing real-valued,
two-dimensional, double-precision floating-point arrays in column-major ordering
and one-based indexing together with calculator and linear algebra functions.")
                      (newline)
                      (print "For documentation see: http://wiki.call-cc.org/eggref/5/matrico")
                      (newline))]

            ['banner (begin
                       (newline)
                       (print " ⎡ ('>⎤  ╔═══════════════╗")
                       (print " ⎢({ )⎥  ║ matrico (" (number->string (head version)) "." (number->string (tail version)) ") ║")
                       (print " ⎣ ][ ⎦  ╚═══════════════╝")
                       (newline))]

            ['version version]

            ['citation (begin
                         (newline)
                         (print "C. Himpe: \"matrico - A matrix module for CHICKEN Scheme\", Version "
                           (number->string (head version)) "." (number->string (tail version)))
                         (newline))]

            ['benchmark (let [(start (current-process-milliseconds))
                              (count (cond-expand [compiling 1000000000]
                                                  [else         1000000]))]
                          (let rho [(sum 0)]
                            (if (fx= sum count) (inexact->exact (floor (/ sum 1000.0 (fx- (current-process-milliseconds) start))))
                                                (rho (fx+1 sum)))))]

            [else (let [(procname (symbol->string sym))
                        (docstring (get 'returns sym))]
                    (if docstring (begin
                                    (newline)
                                    (print "`" procname "`" " returns: " docstring)
                                    (newline)
                                    #t)
                                  #f))]))

;; Print matrico banner
(matrico 'banner)

);end module

