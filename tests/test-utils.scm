;;;; test-utils.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.4 (2023-06-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: utils module unit tests

(import (chicken load))

(load-relative "../src/utils.scm")

(import utils)

;; append*
(check 'append* '((('(0 1 2 3) 4) . (0 1 2 3 4))
                  (('(0) 1) . (0 1))
                  (('() 0) . (0))))

;; sublist
(check 'sublist '((('(0 1 2 3 4) 0 4) . (0 1 2 3 4))
                  (('(0 1 2 3 4) 2 4) . (2 3 4))
                  (('(0 1 2 3 4) 0 2) . (0 1 2))
                  (('(0 1 2 3 4) 0 0) . (0))
                  (('(0 1 2 3 4) 4 4) . (4))
                  (('(0 1 2 3 4) 4 5) . xfail)
                  (('(0 1 2 3 4) 5 6) . xfail)))

;; any?
(check 'any? '(((zero? '(0 1 2)) . #t)
               ((zero? '(1 0 2)) . #t)
               ((zero? '(1 2 0)) . #t)
               ((zero? '(1 2 3)) . #f)
               (    (zero? '(0)) . #t)
               (    (zero? '(1)) . #f)
               (     (zero? '()) . #f)))

;; all?
(check 'all? '(((zero? '(0 0 1)) . #f)
               ((zero? '(0 1 0)) . #f)
               ((zero? '(1 0 0)) . #f)
               ((zero? '(0 0 0)) . #t)
               (    (zero? '(0)) . #t)
               (    (zero? '(1)) . #f)
               (     (zero? '()) . #t)))


;; factorial
(check 'factorial '(( (0) . 1)
                    ( (1) . 1)
                    ( (2) . 2)
                    ( (3) . 6)
                    ( (4) . 24)
                    ( (5) . 120)
                    ((-1) . 0)))

;; binomial
(check 'binomial '((( 0  0) . 1)
                   (( 0  1) . 0)
                   (( 1  0) . 1)
                   (( 1  1) . 1)
                   (( 0  2) . 0)
                   (( 1  2) . 0)
                   (( 2  0) . 1)
                   (( 2  1) . 2)
                   (( 2  2) . 1)
                   (( 3  0) . 1)
                   (( 3  1) . 3)
                   (( 3  2) . 3)
                   (( 3  3) . 1)
                   (( 3  4) . 0)
                   (( 0 -1) . 0)
                   ((-1  0) . 0)
                   ((-1 -1) . 0)))

