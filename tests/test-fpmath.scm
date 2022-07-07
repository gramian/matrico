;;;; test-fpmath.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.2 (2022-07-07)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: fpmath module unit tests

(import (chicken load))

(load-relative "check.scm")

(load-relative "../src/fpmath.scm")

(import fpmath)

(run-tests

;; fp
(check 'fp '((         (0) . 0.0)
             (         (1) . 1.0)
             (        (-1) . -1.0)
             ((4294967296) . 4294967296.0)))

;; fp%
(check 'fp% '(((0 1) . 0.0)
              ((1 1) . 1.0)
              ((1 2) . 0.5)
              ((2 1) . 2.0)
              ((1 -1) . -1.0)
              ((-1 1) . -1.0)
              ((1 0) . +inf.0)
              ((-1 0) . -inf.0)))

;; fpzero??
(check 'fpzero?? '((   (0.0) . #t)
                   (  (-0.0) . #t)
                   (   (1.0) . #f)
                   (  (-1.0) . #f)
                   ((+inf.0) . #f)
                   ((-inf.0) . #f)
                   ((+nan.0) . #f)))

;; fpzero?
(check 'fpzero? '((   (0.0 1.0) . #t)
                  (  (-0.0 1.0) . #t)
                  (   (1.0 1.0) . #t)
                  (  (-1.0 1.0) . #t)
                  (   (1.0 2.0) . #t)
                  (  (-1.0 2.0) . #t)
                  ((+inf.0 1.0) . #f)
                  ((-inf.0 1.0) . #f)
                  ((+nan.0 1.0) . #f)))

;;fp*2
(check 'fp*2 '((    (1.0) . 2.0)
               (   (-1.0) . -2.0)
               (    (0.5) . 1.0)
               (   (-0.5) . -1.0)
               (    (0.0) . 0.0)
               ( (+inf.0) . +inf.0)
               ( (-inf.0) . -inf.0)))

;;fp^2
(check 'fp^2 '((    (1.0) . 1.0)
               (   (-1.0) . 1.0)
               (    (2.0) . 4.0)
               (   (-2.0) . 4.0)
               (    (0.5) . 0.25)
               (   (-0.5) . 0.25)
               (    (0.0) . 0.0)
               ( (+inf.0) . +inf.0)
               ( (-inf.0) . +inf.0)))

;;fprec
(check 'fprec '((    (1.0) . 1.0)
                (   (-1.0) . -1.0)
                (   ( 2.0) . 0.5)
                (   (-2.0) . -0.5)
                (   ( 0.5) . 2.0)
                (   (-0.5) . -2.0)
                (    (0.0) . +inf.0)
                ( (+inf.0) . 0.0)
                ( (-inf.0) . 0.0)))

;; fp+*
(check 'fp*+ '((   (2.0 2.0 2.0) . 6.0)
               (   (0.0 2.0 2.0) . 2.0)
               (   (2.0 0.0 2.0) . 2.0)
               (   (2.0 2.0 0.0) . 4.0)
               (  (-2.0 2.0 2.0) . -2.0)
               ( (-2.0 -2.0 2.0) . 6.0)
               ( (-2.0 2.0 -2.0) . -6.0)
               ((-2.0 -2.0 -2.0) . 2.0)
               (   (0.0 0.0 0.0) . 0.0)
               ((+inf.0 1.0 1.0) . +inf.0)
               ((1.0 +inf.0 1.0) . +inf.0)
               ((1.0 1.0 +inf.0) . +inf.0)))

;; fptau
(check 'fptau `(( () . ,(* 8.0 (atan 1.0)))))

;; fpeul
(check 'fpeul `(( () . ,(exp 1.0))))

;; fpphi
(check 'fpphi `(( () . ,(* (+ 1.0 (sqrt 5.0)) 0.5))))

;; fpdelta
(check 'fpdelta '((   (0.0) . 1.0)
                  (  (-0.0) . 1.0)
                  (   (1.0) . 0.0)
                  (  (-1.0) . 0.0)
                  ((+inf.0) . 0.0)
                  ((-inf.0) . 0.0)))

;; fpheaviside
(check 'fpheaviside '((   (0.0) . 0.0)
                      (  (-0.0) . 0.0)
                      (   (1.0) . 1.0)
                      (  (-1.0) . 0.0)
                      ((+inf.0) . 1.0)
                      ((-inf.0) . 0.0)))

;; fpsign
(check 'fpsign '((   (0.0) .  0.0)
                 (  (-0.0) .  0.0)
                 (   (1.0) .  1.0)
                 (  (-1.0) . -1.0)
                 ((+inf.0) .  1.0)
                 ((-inf.0) . -1.0)))

;;fplog2
(check 'fplb '((    (0.0) . -inf.0)
               (    (1.0) . 0.0)
               (   (16.0) . 4.0)
               (  (256.0) . 8.0)
               ((65536.0) . 16.0)))

;;fplog10
(check 'fplg '((        (0.0) . -inf.0)
               (        (1.0) . 0.0)
               (      (100.0) . 2.0)
               (    (10000.0) . 4.0)
               ((100000000.0) . 8.0)))

;;fplogb
(check 'fplogb '((  (2.0 0.0) . -inf.0)
                 (  (2.0 1.0) . 0.0)
                 (  (0.5 0.0) . +inf.0)
                 (  (0.5 0.5) . 1.0)
                 (  (2.0 2.0) . 1.0)
                 (  (3.0 3.0) . 1.0)
                 ((10.0 10.0) . 1.0)))

;; fpsinh
(check 'fpsinh `((   (0.0) . 0.0)
                 (  (-1.0) . ,(- (fpsinh 1.0)))
                 ((+inf.0) . +inf.0)
                 ((-inf.0) . -inf.0)))

;; fpcosh
(check 'fpcosh `((   (0.0) . 1.0)
                 (  (-1.0) . ,(fpcosh 1.0))
                 ((+inf.0) . +inf.0)
                 ((-inf.0) . +inf.0)))

;; fptanh 
(check 'fptanh `((   (0.0) . 0.0)
                 ( (-20.0) . ,(- (fptanh 20.0)))
                 ((+inf.0) . 1.0)
                 ((-inf.0) . -1.0)))

;; fpasinh
(check 'fpasinh `((   (0.0) . 0.0)
                  (  (-0.1) . ,(- (fpasinh 0.1)))
                  ((+inf.0) . +inf.0)
                  ((-inf.0) . -inf.0)
                  (((fpsinh 0.5)) . 0.5)))

;; fpacosh
(check 'fpacosh '((   (1.0) . 0.0)
                  ((+inf.0) . +inf.0)
                  (((fpcosh 2.0)) . 2.0)))

;; fpatanh
(check 'fpatanh `((         (0.0) . 0.0)
                  (        (-0.5) . ,(- (fpatanh 0.5)))
                  (         (1.0) . +inf.0)
                  (        (-1.0) . -inf.0)
                  (((fptanh 0.5)) . 0.5)))

;; fphsin
(check 'fphsin '((        (0.0) . 0.0)
                 (((- (fptau))) . 0.0)
                 (    ((fptau)) . 0.0)))

;; fphcos
(check 'fphcos '((        (0.0) . 1.0)
                 (((- (fptau))) . 1.0)
                 (    ((fptau)) . 1.0)))

;; fpsignsqrt
(check 'fpsignsqrt '((   (0.0) . 0.0)
                     (   (1.0) . 1.0)
                     (  (-1.0) . -1.0)
                     ((+inf.0) . +inf.0)
                     ((-inf.0) . -inf.0)
                     (   (4.0) . 2.0)
                     (  (-4.0) . -2.0)))

;; fpsinc
(check 'fpsinc '((        (0.0) . 1.0)
                 (    ((fptau)) . 0.0)
                 (((- (fptau))) . 0.0)))

;; fpsigm
(check 'fpsigm '((   (0.0) . 0.5)
                 ((+inf.0) . 1.0)
                 ((-inf.0) . 0.0)))

;; fpgauss
(check 'fpgauss '((   (0.0) . 1.0)
                  ((-inf.0) . 0.0)
                  ((+inf.0) . 0.0)))

;; fpstirling
(check 'fpstirling '(((0.0) . 0.0)
                     ((1.0) . 1.0)
                     ((2.0) . 2.0)
                     ((3.0) . 6.0)
                     ((4.0) . 24.0)
                     ((5.0) . 118.0)))

;; fptaper
(check 'fptaper '(((0.0) .        "    0   ")
                  ((1.0) .        "+1.00000")
                  ((0.00002) .    "+0.00002")
                  ((0.000001) .   "+0.0000…")
                  ((999999.0) .   "+999999.")
                  ((1000001.0) .  "+10000….")
                  ((-0.0) .       "    0   ")
                  ((-1.0) .       "-1.00000")
                  ((-0.00002) .   "-0.00002")
                  ((-0.000001) .  "-0.0000…")
                  ((-999999.0) .  "-999999.")
                  ((-1000001.0) . "-10000….")
                  ((+nan.0) .     "   NaN  ")
                  ((+inf.0) .     "   +∞   ")
                  ((-inf.0) .     "   -∞   ")))

)

