;;;; check.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.4 (2023-06-01)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: testing helpers

(import (chicken base) (chicken condition))

(define ok? (make-parameter #t))

;;@returns: **boolean** answering if **procedure** `exe` evaluated for _car_ of each element of list-of-pairs `arg-ret-lst` corresponds to its _cdr_.
(define (check exe arg-ret-lst)
  (print* (symbol->string exe))
  (let rho [(tst arg-ret-lst)
            (ret #t)]
    (if (null? tst) (begin
                      (newline)
                      ret)
                    (let [(pass? (equal=? (handle-exceptions exn 'xfail (eval `,(cons exe (caar tst)))) (cdar tst)))] ; `eval`, not `apply` because macros
                      (print* " " (if pass? "\x1b[32mOK" "\x1b[31mFAIL") "\x1b[0m")
                      (rho (cdr tst) (ok? (and (ok?) pass?)))))))

