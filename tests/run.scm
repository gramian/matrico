;;;; run.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-05-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: test runner

(import (chicken load))

(load-relative "check.scm")

(exit (max (load-test "test-utils.scm")

           (load-test "test-fpmath.scm")

           (load-test "test-f64vector.scm")

           (load-test "test-matrico.scm")))

