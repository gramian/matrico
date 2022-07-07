;;;; test-f64vector.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.2 (2022-07-07)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: f64vector module unit tests

(import (chicken load))

(load-relative "check.scm")

(load-relative "../src/f64vector.scm")

(import f64vector)

(run-tests

;; f64vector-unfold 
(check 'f64vector-unfold '(( (1 exact->inexact) . #f64(0.0))
                           ( (3 exact->inexact) . #f64(0.0 1.0 2.0))))

;; f64vector-concat
(check 'f64vector-concat '(( (#f64(1.0 2.0) #f64(3.0 4.0)) . #f64(1.0 2.0 3.0 4.0))
                           (        (#f64() #f64(1.0 2.0)) . #f64(1.0 2.0))
                           (        (#f64(1.0 2.0) #f64()) . #f64(1.0 2.0))
                           (               (#f64() #f64()) . #f64())
                           (               (#f64(1.0 2.0)) . #f64(1.0 2.0))
                           (                      (#f64()) . #f64())))

;; f64vector-or?
(check 'f64vector-any? '(( (zero? #f64(0.0 1.0 2.0)) . #t)
                         ( (zero? #f64(1.0 2.0 0.0)) . #t)
                         ( (zero? #f64(0.0 0.0 0.0)) . #t)
                         (         (zero? #f64(0.0)) . #t)
                         ( (zero? #f64(1.0 2.0 3.0)) . #f)
                         (            (zero? #f64()) . #f)))

;; f64vector-and?
(check 'f64vector-all? '(( (zero? #f64(0.0 1.0 2.0)) . #f)
                         ( (zero? #f64(1.0 2.0 0.0)) . #f)
                         ( (zero? #f64(0.0 0.0 0.0)) . #t)
                         (         (zero? #f64(0.0)) . #t)
                         ( (zero? #f64(1.0 2.0 3.0)) . #f)
                         (            (zero? #f64()) . #t)))

;; f64vector-map
(check 'f64vector-map '((                                          (add1 #f64(1.0 2.0 3.0 4.0)) . #f64(2.0 3.0 4.0 5.0))
                        (                       (+ #f64(1.0 2.0 3.0 4.0) #f64(2.0 3.0 4.0 5.0)) . #f64(3.0 5.0 7.0 9.0))
                        ( (+ #f64(1.0 2.0 3.0 4.0) #f64(2.0 3.0 4.0 5.0) #f64(3.0 4.0 5.0 6.0)) . #f64(6.0 9.0 12.0 15.0))
                        (                                                         (add1 #f64()) . #f64())))

;; f64vector-map-index
(check 'f64vector-map-index '((                       (+ #f64(1.0 2.0 3.0 4.0)) . #f64(1.0 3.0 5.0 7.0))
                              ( (+ #f64(1.0 2.0 3.0 4.0) #f64(2.0 3.0 4.0 5.0)) . #f64(3.0 6.0 9.0 12.0))
                              (                                      (+ #f64()) . #f64())))

; TODO f64vector-foreach

; TODO f64vector-foreach-index

;; f64vector-fold
(check 'f64vector-fold '(((+ 0.0 #f64(1.0 2.0 3.0)) . 6.0)
                         (        (+ 0.0 #f64(1.0)) . 1.0)
                         (           (+ 0.0 #f64()) . 0.0)))

;; f64vector-fold*
(check 'f64vector-fold* '(((+ 0.0 #f64(1.0 2.0 3.0)) . 6.0)
                          (        (+ 0.0 #f64(1.0)) . 1.0)
                          (           (+ 0.0 #f64()) . 0.0)))

(check 'f64vector-dot '(((#f64(2.0) #f64(3.0)) . 6.0)
                        ((#f64(1.0 2.0 3.0) #f64(2.0 3.0 4.0)) . 20.0)
                        ((#f64() #f64()) . 0.0)))

)

