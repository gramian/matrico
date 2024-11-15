;;;; run.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.7 (2024-11-??)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: test runner

(import (chicken load))

(include-relative "check.scm")

(load-relative "test-utils.scm")
(load-relative "test-fpmath.scm")
(load-relative "test-f64vector.scm")
(load-relative "test-matrico.scm")

(exit (if (ok?) 0 1))

