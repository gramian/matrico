;;;; utils.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.1 (2022-??-??)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: helper utilities module

(module utils

  (define-syntax-rule alias must-be comment
   nil head tail empty?
   make-list sublist any? all?
   fx+1 fx-1 fx=0? fx<0? fx>0? fx<=0? fx>=0?
   factorial binomial
   define* load*
   defined?)

  (import scheme (chicken base) (chicken module) (chicken plist) (chicken fixnum) (chicken condition))
  (reexport (chicken fixnum))

;;; Meta Helpers ###############################################################

;;@returns: **macro** generating single-rule macro, see @1.
(define-syntax define-syntax-rule
  (syntax-rules ()
    [(_ (name args ...) (body ...))
     (define-syntax name
       (syntax-rules ()
         ((_ args ...) (body ...))))]))

;;@returns: **macro** replacing `aka` with `name`, see @2.
(define-syntax alias
  (syntax-rules ()
    [(_ aka name)
     (define-syntax aka
       (syntax-rules ()
         ((_ . args) (name . args))))]))

;;@returns: **macro** wrapping `assert` of `and` with variable number of arguments.
(define-syntax must-be
  (syntax-rules ()
    [(_ args ...) (assert (and args ...))]))

;;@returns: **void**, see @3.
(define-syntax comment
  (syntax-rules ()
    [(_ . any) (void)]))

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

;;@returns: **list** containing **fixnum** `num` number of elements `any`.
(define (make-list num any)
  (must-be (fixnum? num) (fx>=0? num))
  (if (fx=0? num) nil
                  (cons any (make-list (fx-1 num) any))))

;;@returns: **list** containing elements of **list** `lst` from indices **fixnum**s `start` to `end`.
(define (sublist lst start end)
  (must-be (list? lst) (fixnum? start) (fixnum? end) (fx>=0? start) (fx>= end start))
  (cond [(fx>0? start) (sublist (tail lst) (fx-1 start) (fx-1 end))]
        [(fx>0? end)   (cons (head lst) (sublist (tail lst) 0 (fx-1 end)))]
        [else          (cons (head lst) nil)]))

;;@returns: **boolean** answering if any element of **list** `lst` fulfills predicate **procedure** `pred`.
(define (any? pred lst)
  (must-be (procedure? pred) (list? lst))
  (cond [(empty? lst)      #f]
        [(pred (head lst)) #t]
        [else              (any? pred (tail lst))]))

;;@returns: **boolean** answering if all elements of **list** `lst` fulfill predicate **procedure** `pred`.
(define (all? pred lst)
  (must-be (procedure? pred) (list? lst))
  (cond [(empty? lst)      #t]
        [(pred (head lst)) (all? pred (tail lst))]
        [else              #f]))

;;; Factorials #################################################################

;;@returns: **fixnum** multiplying consecutive integers up to **fixnum** `n`: `n! = 1 * 2 * ...`.
(define (factorial n)
  (must-be (fixnum? n))
  (if (negative? n) 0
                    (let rho [(idx n)
                              (acc 1)]
                      (if (fx=0? idx) acc
                                      (rho (fx-1 idx) (fx* idx acc))))))

;;@returns: **fixnum** binomial coefficient for **integer**s `n` and `k` based on Pascal's rule: `(n k) = (n-1 k) + (n-1 k-1)`.
(define (binomial n k)
  (must-be (fixnum? n) (fixnum? k))
  (let rho [(a n)
            (b k)]
    (cond [(fx<0? a)  0]
          [(fx<0? b)  0]
          [(fx=0? b)  1]
          [(fx=0? a)  0]
          [else       (fx+ (rho (fx-1 a) (fx-1 b)) (rho (fx-1 a) b))])))

;;; Standard Variants ##########################################################

;;@returns: **macro** generating function binding with docstring in `'returns` property list.
(define-syntax define*
  (syntax-rules (returns)
    [(_ (name args ...) (returns str) body ...)
      (begin
        (put! 'name 'returns str)
        (define (name args ...) body ...))]
    [(_ (name . args) (returns str) body ...)
      (begin
        (put! 'name 'returns str)
        (define (name . args) body ...))]
    [(_ name (returns str) (body ...))
      (begin
        (put! 'name 'returns str)
        (define name (body ...)))]))

;;@returns: **any** terminal result from loaded and evaluated file with path **string** `str`, see @4.
(define (load* str)
  (define ret nil)
  (load str (lambda (x)
              (set! ret (eval x))))
  ret)

;;; Environment ################################################################

;;@returns: **boolean** answering if unquoted **symbol** `sym` is defined, see @5.
(define (defined? sym)
  (let [(warn (enable-warnings))]
    (enable-warnings #f)
    (handle-exceptions exn #f (eval `(procedure? ,sym)))
    (enable-warnings warn)))

);end module

;;; References #################################################################

;;@1: Syntax-rules Macros. Guile Reference Manual, 6.8.2.3. https://www.gnu.org/software/guile/manual/html_node/Syntax-Rules.html#Shorthands

;;@2: PC Scheme User's Guide & Software, 7-9.

;;@3: Miscellaneous Features. The T Manual, 13.

;;@4: [Scheme-reports] return value(s) of load. http://scheme-reports.org/mail/scheme-reports/msg02021.html

;;@5: Querying variable bindings. Guile Reference Manual, 6.10.4. https://www.gnu.org/software/guile/manual/html_node/Binding-Reflection.html

