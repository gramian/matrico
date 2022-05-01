;;;; f64vector.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-05-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: homogeneous flonum vector library

(include-relative "fpmath.scm")

(module f64vector

  (f64vector-id
   f64vector-unfold
   f64vector-concat
   f64vector-any? f64vector-all?
   f64vector-map f64vector-map-index
   f64vector-foreach f64vector-foreach-index
   f64vector-fold f64vector-fold* f64vector-dot)

  (import scheme (chicken base) (chicken module) srfi-4 utils fpmath)
  (reexport srfi-4)

;;; Vector Identifier ##########################################################

;;@assigns: **string** `"#f64"`.
(define f64vector-id "#f64")

;;; Vector Constructor #########################################################

;;@returns: **f64vector** of dimension **fixnum** `dim` with procedurally generated elements by **procedure** `fun`.
(define (f64vector-unfold dim fun)
  (must-be (fixnum? dim) (fx>0? dim) (procedure? fun))
  (let [(ret (make-f64vector dim))]
    (let rho [(idx 0)]
      (if (fx= idx dim) ret
                        (begin
                          (f64vector-set! ret idx (fun idx))
                          (rho (fx+1 idx)))))))

;;; Vector Combiner ############################################################

;;@returns: **f64vector** of concatenated **list**-of-**f64vector**s `vec`.
(define (f64vector-concat . vec)
  (must-be (not (empty? vec)))
  (let* [(dims (map f64vector-length vec))
         (ret  (make-f64vector (foldl fx+ 0 dims)))]
    (let rho [(idx 0)
              (cur vec)
              (num dims)
              (jdx 0)]
      (cond [(empty? cur) ret]
            [(fx= jdx (head num)) (rho idx (tail cur) (tail num) 0)]
            [else (begin
                    (f64vector-set! ret idx (f64vector-ref (head cur) jdx))
                    (rho (fx+1 idx) cur num (fx+1 jdx)))]))))

;;; Vector Predicates ##########################################################

;;@returns: **boolean** answering if any element of **f64vector** `vec` fulfills predicate **procedure** `pred` from left to right.
(define (f64vector-any? pred vec)
  (must-be (procedure? pred) (f64vector? vec))
  (let [(dim (f64vector-length vec))]
    (let rho [(idx 0)]
      (cond [(fx= idx dim)                  #f]
            [(pred (f64vector-ref vec idx)) #t]
            [else                           (rho (fx+1 idx))]))))

;;@returns: **boolean** answering if all elements of **f64vector** `vec` fulfill predicate **procedure** `pred` from left to right.
(define (f64vector-all? pred vec)
  (must-be (procedure? pred) (f64vector? vec))
  (let [(dim (f64vector-length vec))]
    (let rho [(idx 0)]
      (cond [(fx= idx dim)                  #t]
            [(pred (f64vector-ref vec idx)) (rho (fx+1 idx))]
            [else                           #f]))))

;;; Vector Mappers #############################################################

;;@returns: **f64vector** resulting from applying **procedure** `fun` to **f64vector**(s) `vec` elements.
(define f64vector-map
  (case-lambda [(fun vec) (must-be (procedure? fun) (f64vector? vec))
                          (let* [(dim (f64vector-length vec))
                                 (ret (make-f64vector dim))]
                            (let rho [(idx 0)]
                              (if (fx= idx dim) ret
                                (begin
                                  (f64vector-set! ret idx (fun (f64vector-ref vec idx)))
                                  (rho (fx+1 idx))))))]
               [(fun . vec) (must-be (procedure? fun) (not (empty? vec)))
                            (let* [(dim (f64vector-length (head vec)))
                                   (ret (make-f64vector dim))]
                              (let rho [(idx 0)]
                                (if (fx= idx dim) ret
                                  (begin
                                    (f64vector-set! ret idx (apply fun (map (cut f64vector-ref <> idx) vec)))
                                    (rho (fx+1 idx))))))]))

;;@returns: **f64vector** resulting from applying **procedure** `fun` to index and all corresponding **f64vector**s `vec` elements, see @1.
(define (f64vector-map-index fun . vec)
  (must-be (procedure? fun) (not (empty? vec)))
  (let* [(dim (f64vector-length (head vec)))
         (ret (make-f64vector dim))]
    (let rho [(idx 0)]
      (if (fx= idx dim) ret
                        (begin
                          (f64vector-set! ret idx (apply fun idx (map (cut f64vector-ref <> idx) vec)))
                          (rho (fx+1 idx)))))))

;;@returns: **void**, applies **procedure** `fun` to all corresponding **f64vector**s `vec` elements.
(define (f64vector-foreach fun . vec)
  (must-be (procedure? fun) (not (empty? vec)))
  (let* [(dim (f64vector-length (head vec)))
         (ret (make-f64vector dim))]
    (let rho [(idx 0)]
      (if (fx= idx dim) ret
                        (begin
                          (apply fun (map (cut f64vector-ref <> idx) vec))
                          (rho (fx+1 idx)))))))

;;@returns: **void**, applies **procedure** `fun` to index and all corresponding **f64vector**s `vec` elements.
(define (f64vector-foreach-index fun . vec)
  (must-be (procedure? fun) (not (empty? vec)))
  (let* [(dim (f64vector-length (head vec)))
         (ret (make-f64vector dim))]
    (let rho [(idx 0)]
      (if (fx= idx dim) ret
                        (begin
                          (apply fun idx (map (cut f64vector-ref <> idx) vec))
                          (rho (fx+1 idx)))))))

;;; Vector Reducers ############################################################

;;@returns: **any** resulting from applying **procedure** `fun` to `ini` initialized accumulator and sequentially to all **f64vector**s `vec` elements from left to right.
(define (f64vector-fold fun ini . vec)
  (must-be (procedure? fun) (not (empty? vec)))
  (let [(dim (f64vector-length (head vec)))]
    (let rho [(idx 0)
              (ret ini)]
      (if (fx= idx dim) ret
                        (rho (fx+1 idx) (apply fun ret (map (cut f64vector-ref <> idx) vec)))))))

;;@returns: **any** resulting from applying **procedure** `fun` to `ini` initialized accumulator and sequentially to all **f64vector**s `vec` elements from right to left.
(define (f64vector-fold* fun ini . vec)
  (must-be (procedure? fun) (not (empty? vec)))
  (let rho [(idx (fx-1 (f64vector-length (head vec))))
            (ret ini)]
    (if (fx= idx -1) ret
                     (rho (fx-1 idx) (apply fun ret (map (cut f64vector-ref <> idx) vec))))))

;;@returns: **flonum** resulting from applying fused-multiply-add to zero initialized accumulator and sequentially to all **f64vector**s `x`, `y` elements from left to right.
(define (f64vector-dot x y)
  (must-be (f64vector? x) (f64vector? y) (fx= (f64vector-length x) (f64vector-length y)))
  (let [(dim (f64vector-length x))]
    (let rho [(ret 0.0)
              (idx 0)]
      (if (fx= idx dim) ret
                        (rho (fp+* ret (f64vector-ref x idx) (f64vector-ref y idx)) (fx+1 idx))))))

);end module

;;; References #################################################################

;;@1: Vector family. Gauche Reference Manual, 6.13. https://practical-scheme.net/gauche/man/gauche-refe/Vector-family.html

