;;;; matrico.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-05-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: A CHICKEN Scheme flonum matrix module.

(include-relative "src/dense.scm")

(module matrico
  (
   ;; Matrico Properties
   matrico-ver matrico-help matrico?
   ;; Matrix Constructors
   mx mx%
   mx-identity mx-exchange mx-hilbert mx-pascal mx-lehmer mx-random mx-tridiag
   mx-linspace mx-logspace
   mx-unit mx-iota
   ;; Matrix Dimensions
   mx-cols mx-rows mx-numel mx-dims
   ;; Matrix Predicates
   mx?
   mx-col? mx-row? mx-scalar? mx-vector? mx-square?
   mx-samecols? mx-samerows? mx-samedims?
   mx-any? mx-all? mx=?
   ;; Matrix Accessors
   mx-ref11 mx-ref mx-col mx-row mx-diag mx-submatrix
   mx-set!
   ;; Matrix Expanders
   mx+ mx* mx- mx/
   mx^ mx-log mx-dist mx-where mx+*
   ;; Matrix Mappers
   mx-round mx-floor mx-ceil
   mx-abs mx-sign mx-dirac
   mx-sin mx-cos mx-tan
   mx-asin mx-acos mx-atan
   mx-sinh mx-cosh mx-tanh
   mx-asinh mx-acosh mx-atanh
   mx-hcos mx-hsin
   mx-sqrt mx-signsqrt
   mx-ln mx-lb mx-lg
   mx-exp mx-gauss
   mx-sinc mx-sigm mx-stirling
   ;; Matrix Reducers
   mx-rowsum mx-colsum mx-sum
   mx-rowprod mx-colprod mx-prod
   mx-rowmin mx-colmin mx-min
   mx-rowmax mx-colmax mx-max
   mx-rowmidr mx-colmidr mx-midr
   mx-rowmean mx-colmean mx-mean
   mx-rownorm mx-colnorm mx-norm
   ;; Matrix Algebra
   mx-horcat mx-vercat mx-repeat
   mx-vec mx-transpose
   mx-sympart mx-skewpart
   mx-diagonal
   mx-qr mx-solver mx-solve
   mx-absdet mx-logdet
   mx-trace mx-multrace mx-prodtrace* mx-prodtrace
   mx-scalar mx-dot* mx-dot mx-gram mx-gram* mx-square
   mx-xcov mx-cov mx-std
   mx-xcor mx-cor mx-coher
   ;; Matrix Analysis
   mx-diff mx-trapz mx-ode2-hyp mx-ode2-ssp
   ;; Matrix Utilities
   mx-print mx-export mx-save mx-load
  )
  (import scheme (chicken base) (chicken plist) (chicken random) utils fpmath dense)

(include-relative "src/mx.scm")

;;; Matrico About ##############################################################

;;@assigns: matrico version number as pair.
(define-constant version '(0 . 1))

;; Print matrico banner
(newline)
(print                " ⎡ ('>⎤  ╔═══════════════╗")
(print (string-append " ⎢({ )⎥  ║ matrico (" (number->string (head version)) "." (number->string (tail version)) ") ║"))
(print                " ⎣ ][ ⎦  ╚═══════════════╝")
(newline)

;;@returns: **pair** holding version and prints library name and version number of **matrico**.
(define (matrico-ver)
  version)

;;@returns: **void**, prints help text to terminal.
(define (matrico-help)
  (print "\
`matrico` is a flonum matrix module for CHICKEN Scheme, providing real-valued,
two-dimensional, double-precision floating-point arrays in column-major ordering
and one-based indexing together with calculator and linear algebra functions.")
  (print #\newline "For documentation see: http://wiki.call-cc.org/eggref/5/matrico" #\newline))

;;@returns: **boolean** answering if **symbol** `proc` is an existing function, starting with "mx" and prints its docstring.
(define (matrico? proc)
  (must-be (symbol? proc))
  (let [(docstring (get proc 'returns))]
    (if (and (string=? "mx" (substring (symbol->string proc) 0 2)) docstring)
        (begin
          (print "returns: " docstring #\newline)
          #t)
        #f)))

);end module

