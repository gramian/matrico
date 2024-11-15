#! csi

;;;; RUNME.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.7 (2024-07-18)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: demo codes

(import matrico)

;; `matrico` about

(matrico 'about)

;; `matrico` version

(matrico 'version)

;; `matrico` cite

(matrico 'citation)

;; Using the REPL help

(matrico 'mx)

;; Assigning matrices and vectors

(matrico 'mx-tridiag)

(define A (mx-tridiag 3 1.0 -2.0 0.5)) ; Assign a 3x3 tridiagonal matrix to A

(mx-print A) ; Print matrix A

(define b (mx 3 1 1.0)) ; Assign a 3x1 column vector of ones to b

(mx-print b) ; Print vector b

;; Entry-wise matrix arithmetic

(mx-print (mx+ b b)) ; Print entry-wise sum of b and b

(mx-print (mx+ A b)) ; Print entry-wise (broadcasted) sum of A b

(mx-print (mx* b A)) ; Print entry-wise (broadcasted) product of B A

;; Multiplying matrices

(matrico 'mx-dot)

(mx-print (mx-dot A b)) ; Print matrix-vector probuct of A and b

(mx-print (mx-dot A A)) ; Print matrix-matrix product of A and A

;; Solving a linear problem

(matrico 'mx-solve)

(mx-print (mx-solve A b)) ; Print the solution to the linear problem A x = b
