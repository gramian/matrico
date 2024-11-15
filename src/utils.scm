;;;; utils.scm (CHICKEN Scheme)

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.7 (2024-11-??)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: helper utilities module

(module utils

  (define-syntax-rule must-be comment
   nil head tail empty?
   fx+1 fx-1 fx=0? fx<0? fx>0? fx<=0? fx>=0?
   append* sublist
   any? all?
   factorial binomial
   define* load*)

  (import scheme (chicken base) (chicken module) (chicken plist) (chicken fixnum) (chicken load))

  (reexport (chicken fixnum))

;;; Meta Helpers ###############################################################

;;@returns: **macro** generating single-rule macro, see @1.
(define-syntax define-syntax-rule
  (syntax-rules ()
    [(_ (name args ...) (body ...))
     (define-syntax name
       (syntax-rules ()
         ((_ args ...) (body ...))))]))

;;@returns: **macro** wrapping `assert` of `and` with variable number of arguments.
(define-syntax-rule (must-be (pred name ...) ...)
  (begin (assert (pred name ...) "Guard failed for" 'name ...) ...))

;;@returns: **void**, see @2, @3.
(define-syntax-rule (comment any ...)
  (void))

;;; List Aliases ###############################################################

;;@assigns: **alias** for `'()`.
(define nil '())

;;@assigns: **alias** for `car`.
(define head car)

;;@assigns: **alias** for `cdr`.
(define tail cdr)

;;@assigns: **alias** for `null?`.
(define empty? null?)

;;; Fixnum Helpers #############################################################

;;@returns: **fixnum** incremented **fixnum** `x`.
(define-syntax-rule (fx+1 x)
  (fx+ x 1))

;;@returns: **fixnum** decremented **fixnum** `x`.
(define-syntax-rule (fx-1 x)
  (fx- x 1))

;;@returns: **boolean** answering if **fixnum** `x` is zero.
(define-syntax-rule (fx=0? x)
  (fx= x 0))

;;@returns: **boolean** answering if **fixnum** `x` is smaller than zero.
(define-syntax-rule (fx<0? x)
  (fx< x 0))

;;@returns: **boolean** answering if **fixnum** `x` is greater than zero.
(define-syntax-rule (fx>0? x)
  (fx> x 0))

;;@returns: **boolean** answering if **fixnum** `x` is smaller or equal to zero.
(define-syntax-rule (fx<=0? x)
  (fx<= x 0))

;;@returns: **boolean** answering if **fixnum** `x` is greater or equal to zero.
(define-syntax-rule (fx>=0? x)
  (fx>= x 0))

;;; List Functions #############################################################

;;@returns: **list** of **list** argument `lst` with appended argument `any`.
(define (append* lst any)
  (foldr cons (list any) lst))

;;@returns: **list** containing elements of **list** `lst` from indices **fixnum**s `start` to `end`.
(define (sublist lst start end)
  (cond [(fx>0? start) (sublist (tail lst) (fx-1 start) (fx-1 end))]
        [(fx>0? end)   (cons (head lst) (sublist (tail lst) 0 (fx-1 end)))]
        [else          (cons (head lst) nil)]))

;;; List Predicates ############################################################

;;@returns: **boolean** answering if any element of **list** `lst` fulfills predicate **procedure** `pred`.
(define (any? pred lst)
  (cond [(empty? lst)      #f]
        [(pred (head lst)) #t]
        [else              (any? pred (tail lst))]))

;;@returns: **boolean** answering if all elements of **list** `lst` fulfill predicate **procedure** `pred`.
(define (all? pred lst)
  (cond [(empty? lst)      #t]
        [(pred (head lst)) (all? pred (tail lst))]
        [else              #f]))

;;; Factorials #################################################################

;;@returns: **fixnum** multiplying consecutive integers up to **fixnum** `n`: `n! = 1 * 2 * ...`.
(define (factorial n)
  (if (fx<0? n) 0
                (let rho [(idx n)
                          (acc 1)]
                  (if (fx=0? idx) acc
                                  (rho (fx-1 idx) (fx* idx acc))))))

;;@returns: **fixnum** binomial coefficient for **integer**s `n` and `k` based on Pascal's rule: `(n k) = (n-1 k) + (n-1 k-1)`.
(define (binomial n k)
  (let rho [(a n)
            (b k)]
    (cond [(fx<0? a)  0]
          [(fx<0? b)  0]
          [(fx=0? b)  1]
          [(fx=0? a)  0]
          [else       (fx+ (rho (fx-1 a) (fx-1 b)) (rho (fx-1 a) b))])))

;;; Standard Variants ##########################################################

;;@returns: **macro** generating function binding with docstring in `'returns` property list, see @4.
(define-syntax define*
  (syntax-rules (returns)
    [(_ (name args ...) (returns str) body ...)
      (begin
        (put! 'returns 'name str)
        (define (name args ...) body ...))]
    [(_ (name . args) (returns str) body ...)
      (begin
        (put! 'returns 'name str)
        (define (name . args) body ...))]
    [(_ name (returns str) (body ...))
      (begin
        (put! 'returns 'name str)
        (define name (body ...)))]))

;;@returns: **any** result of the last expressions in loaded and evaluated file with path **string** `str`, see @5, @6.
(define (load* str)
  (let [(ret nil)
        (vrb (load-verbose #f))]
    (load str (lambda (x)
                (set! ret (eval x))))
    (load-verbose vrb)
    ret))

);end module

;;; References #################################################################

;;@1: Syntax-rules Macros. Guile Reference Manual, 6.8.2.3. https://www.gnu.org/software/guile/manual/html_node/Syntax-Rules.html#Shorthands

;;@2: Miscellaneous Features. The T Manual, 13. http://mumble.net/~jar/tproject/

;;@3: comment. ClojureDocs, https://clojuredocs.org/clojure.core/comment

;;@4: Docstrings in my Chicken. https://demonastery.org/2011/11/docstrings-in-my-chicken/

;;@5: [Scheme-reports] return value(s) of load. http://scheme-reports.org/mail/scheme-reports/msg02021.html

;;@6: What load returns. https://docs.scheme.org/surveys/what-load-returns/
