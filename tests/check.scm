;;;; check.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.0 (2022-??-??)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: testing helpers

(import (chicken condition) (chicken load))

;;@returns: **boolean** answering if all elements of **list** `lst` are not false.
(define-inline (every? lst)
  (not (member #f lst)))

;;@returns: **boolean** answering if **procedure** `exe` evaluated for _car_ of each element of list-of-pairs `arg-ret-lst` corresponds to its _cdr_.
(define (check exe arg-ret-lst)
  (let rho [(tst arg-ret-lst)
            (ret '())]
    (if (null? tst) (begin
                      (print (cons (symbol->string exe)
                                   (map (lambda (l)
                                          (if l "\x1b[32mOK\x1b[0m"
                                                "\x1b[31mFAIL\x1b[0m")) (reverse ret))))
                      (every? ret))
                    (rho (cdr tst)
                         (cons (equal=? (handle-exceptions exn 'xfail (eval `,(cons exe (caar tst)))) ; `eval`, not `apply` because macros 
                                        (cdar tst))
                               ret)))))

;;@returns: `1` if any test argument `tst` fails, `0` otherwise.
(define (run-tests . tst)
  (if (every? tst) 0 1))

;;@returns: **void**, mutates the number argument `tst` to the maximum of `tst` and the value of the last expression of the source file (**string**) `str`.
(define (load-test str)
  (define ret '())
  (load-relative str (lambda (x)
              (set! ret (eval x))))
  ret)

