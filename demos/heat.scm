;;;; demo-heat.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.6 (2024-07-18)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: cooling demo code

;; This demo code computes a cooling process, by solving a semi-discrete
;; diffusion partial differential equation (linear heat equation) in one
;; dimension with a central box as initial state and zero Dirichlet boundaries.

(load "matrico.scm")
(import matrico)

(define N 100)
(define h (/ 10.0 (add1 N)))
(define h^2 (* h h))

(define A^T (mx-tridiag N (/ 1.0 h^2) (/ -2.0 h^2) (/ 1.0 h^2)))

(define x0 (mx-vercat (mx 43 1 0.0) (mx-vercat (mx 14 1 1.0) (mx 43 1 0.0))))

(define (f t x)
  (mx-dot* A^T x))

(define X (mx-ode2-ssp 5 f (cons 0.01 1.0) x0))

(mx-export "heat.csv" X)
