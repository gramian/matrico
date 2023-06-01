;;;; demo-flame.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.4 (2023-06-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: flame demo code

;; This demo code computes a flame state-space model, by solving semi-discrete
;; advection partial differential equation (linear transport equation) in one
;; dimension with an inflow (Neumann) boundary on the left and quantity of
;; interest on the right boundary, and together an input-output system.

(load "matrico.scm")
(import matrico)

(define N 100)
(define h (/ 0.25 N))
(define 2/h (/ 0.5 h))

(define A^T (mx-tridiag N (* 1.0 2/h) (* -4.0 2/h) (* 3.0 2/h)))
(define B (mx-set (mx N 1 0.0) 1 1 (* 1.0 2/h)))
(define C^T (mx-set (mx N 1 0.0) N 1 1.0))

(define x0 (mx N 1 0.0))

(define (u t)
  (fpexp (fp/ (fp^2 (fp- t 0.2)) -0.005)))

(define (f t x)
  (mx+ (mx-dot* A^T x) (mx* B (u t))))

(define (g t x)
  (mx-dot* C^T x))

(define X (mx-ode2-hyp 11 (cons f g) (cons h 1.0) x0))

(mx-export "flame.csv" X)
