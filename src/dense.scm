;;;; dense.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.5 (2023-06-06)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: dense column function aliases

(include-relative "f64vector.scm")

(include-relative "matrix.scm")

(module dense = matrix

  (import (chicken module) f64vector)

  (reexport (rename f64vector (f64vector column)
                              (make-f64vector make-column)
                              (f64vector-length column-length)
                              (f64vector-ref column-ref)
                              (f64vector-set! column-set!)
                              (subf64vector subcolumn)
                              (f64vector-unfold column-unfold)
                              (f64vector-concat column-concat)
                              (f64vector-any? column-any?)
                              (f64vector-all? column-all?)
                              (f64vector-map column-map)
                              (f64vector-map-index column-map-index)
                              (f64vector-foreach column-foreach)
                              (f64vector-foreach-index column-foreach-index)
                              (f64vector-axpy column-axpy)
                              (f64vector-fold column-fold)
                              (f64vector-fold* column-fold*)
                              (f64vector-dot column-dot)
                              (list->f64vector list->column)))

);end module
