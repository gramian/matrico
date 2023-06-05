;;;; matrix.scm

;;@project: matrico (numerical-schemer.xyz)
;;@version: 0.5 (2023-06-06)
;;@authors: Christian Himpe (0000-0003-2194-6754)
;;@license: zlib-acknowledgement (spdx.org/licenses/zlib-acknowledgement.html)
;;@summary: matrix type back-end via list-of-vectors, see @1, @2, @3, @4, @5, @6, @7, @8.

(include-relative "utils.scm")

(functor (matrix
           (column (column
                    make-column column-unfold column-concat
                    column-length
                    column-ref subcolumn
                    column-set!
                    column-any? column-all?
                    column-map column-map-index column-foreach column-foreach-index column-axpy
                    column-fold column-fold* column-dot
                    list->column)))

  (matrix?
   make-matrix* make-matrix** matrix-generate
   matrix-horcat matrix-vercat
   matrix-cols matrix-rows matrix-numel matrix-dims
   matrix-ref00 matrix-ref*0 matrix-ref matrix-set matrix-set!
   matrix-col matrix-row matrix-diag matrix-submatrix
   matrix-col? matrix-row? matrix-scalar? matrix-vector? matrix-square?
   matrix-samecols? matrix-samerows? matrix-samedims?
   matrix-any? matrix-all?
   matrix-colfold matrix-rowfold matrix-allfold
   matrix-map matrix-broadcast
   matrix-vec matrix-transpose matrix-axpy matrix-scalar matrix-dot* matrix-explode matrix-implode
   matrix-print matrix-export matrix-save matrix-load)

  (import scheme (chicken base) (chicken module) (only (chicken memory representation) object-copy) utils column)

;;; Matrix Type ################################################################

;;@returns: **void**, provides make-matrix constructor, matrix? predicate, matrix-cols and matrix-data accessors.
(define-record matrix cols data)

;;; Private Functions ##########################################################

;;@returns: **matrix** resulting from applying **procedure** `fun` to each column of each **matrix** `x`.
(define-inline (matrix-map* fun x)
  (make-matrix (matrix-cols x) (map fun (matrix-data x))))

;;@returns: **matrix** resulting from applying **procedure** `fun` to each column of each **matrix**es `x` and `y`.
(define-inline (matrix-map** fun x y)
  (make-matrix (matrix-cols x) (map fun (matrix-data x) (matrix-data y))))

;;; Matrix Generators ##########################################################

;;@returns: `rows`-by-`cols` **matrix** with all entries set to `val` for **fixnum**s `rows`, `cols`.
(define (make-matrix* rows cols val)
  (make-matrix cols
    (let rho [(idx cols)
              (dat nil)]
      (if (fx=0? idx) dat
                      (rho (fx-1 idx) (cons (make-column rows val) dat))))))

;;@returns: **matrix** from row-major **list**-of-**list**s `lst`.
(define (make-matrix** lst)
  (make-matrix (length (head lst)) (apply map column lst)))

;;@returns: `rows`-by-`cols` **matrix** generated procedurally from applying **procedure** `fun`, and **fixnum**s `rows`, `cols`.
(define (matrix-generate fun rows cols)
  (make-matrix cols
    (let rho [(col cols)
              (lst nil)]
      (if (fx=0? col) lst
                      (rho (fx-1 col) (cons (column-unfold rows (lambda (row)
                                                                  (fun row (fx-1 col))))
                                            lst))))))

;;; Matrix Combiners ###########################################################

;;@returns: **matrix** of horizontally concatenating **matrix**es from **list**-of-**matrix**es `mat`.
(define (matrix-horcat . mat)
  (make-matrix (foldl fx+ 0 (map matrix-cols mat)) (apply append (map (compose object-copy matrix-data) mat))))

;;@returns: **matrix** of vertically concatenating **matrix**es from **list**-of-**matrix**es `mat`.
(define (matrix-vercat . mat)
  (make-matrix (matrix-cols (head mat)) (apply map column-concat (map (compose object-copy matrix-data) mat))))

;;; Matrix Dimensions ##########################################################

;;@note: `matrix-cols` is provided by the **record** `matrix`

;;@returns: **fixnum** number of rows of **matrix** `mat`.
(define (matrix-rows mat)
  (column-length (head (matrix-data mat))))

;;@returns: **fixnum** number of entries of **matrix** `mat`.
(define (matrix-numel mat)
  (fx* (matrix-rows mat) (matrix-cols mat)))

;;@returns: **fixnum** number of dimensions of **matrix** `mat`.
(define (matrix-dims mat)
  (fx+ (if (matrix-row? mat) 0 1) (if (matrix-col? mat) 0 1)))

;;; Matrix Accessors ###########################################################

;;@returns: **any** being the entry of **matrix** `mat` in the first row and first column.
(define (matrix-ref00 mat)
  (column-ref (head (matrix-data mat)) 0))

;;@returns: **any** being the entry of **matrix** `mat` in **fixnum** `row` and the first column.
(define (matrix-ref*0 mat row)
  (column-ref (head (matrix-data mat)) row))

;;@returns: **any** being the entry of **matrix** `mat` in **fixnum** `row` and **fixnum** `col`umn.
(define (matrix-ref mat row col)
  (column-ref (list-ref (matrix-data mat) col) row))

;;@returns: **matrix** copy of **matrix** `mat` but with entry in row **fixnum** `row` and column **fixnum** `col` set to `val`.
(define (matrix-set mat row col val)
  (let [(ret (object-copy mat))]
    (column-set! (list-ref (matrix-data ret) col) row val)
    ret))

;;@returns: **any**, sets entry of **matrix** `mat` in row **fixnum** `row` and column **fixnum** `col` to `val`.
(define (matrix-set! mat row col val)
  (column-set! (list-ref (matrix-data mat) col) row val)
  val)

;;@returns: **matrix** being column of **matrix** `mat` specified by **fixnum** `col`.
(define (matrix-col mat col)
  (make-matrix 1 (list (object-copy (list-ref (matrix-data mat) col)))))

;;@returns: **matrix** being row of **matrix** `mat` specified by **fixnum** `row`.
(define (matrix-row mat row)
  (matrix-map* (lambda (col)
                 (column (column-ref col row))) mat))

;;@returns column-**matrix** holding **matrix** `mat` diagonal entries.
(define (matrix-diag mat)
  (let* [(rows (matrix-rows mat))
         (col  (make-column rows))]
    (let rho [(idx 0)
              (lst (matrix-data mat))]
      (if (fx= idx rows) (make-matrix 1 (list col))
                         (begin
                           (column-set! col idx (column-ref (head lst) idx))
                           (rho (fx+1 idx) (tail lst)))))))

;;@returns: **matrix** holding entries of **matrix** `mat` from rows **fixnum**s `row1` to `row2` in columns from **fixnum**s `col1` to `col2`.
(define (matrix-submatrix mat row1 row2 col1 col2)
  (make-matrix (fx+1 (fx- col2 col1))
    (object-copy (let [(cols (if (and (fx=0? col1) (fx= (fx+1 col2) (matrix-cols mat))) (matrix-data mat)
                                                                                        (sublist (matrix-data mat) col1 col2)))]
                   (if (and (fx=0? row1) (fx= (fx+1 row2) (matrix-rows mat))) cols
                                                                              (map (lambda (col)
                                                                                     (subcolumn col row1 (fx+1 row2)))
                                                                                   cols))))))

;;; Matrix Predicates ##########################################################

;;@returns: **boolean** answering if **matrix** `mat` has only a single column.
(define (matrix-col? mat)
  (fx= (matrix-cols mat) 1))

;;@returns: **boolean** **boolean** answering if **matrix** `mat` has only a single row.
(define (matrix-row? mat)
  (fx= (matrix-rows mat) 1))

;;@returns: **boolean** answering if **matrix** `mat` has only a single row and single column, aka scalar.
(define (matrix-scalar? mat)
  (and (matrix-col? mat) (matrix-row? mat)))

;;@returns: **boolean** answering if **matrix** `mat` has only a single row or single column, aka vector.
(define (matrix-vector? mat)
  (or (matrix-col? mat) (matrix-row? mat)))

;;@returns: **boolean** answering if **matrix** `mat` has the same number of rows and columns.
(define (matrix-square? mat)
  (fx= (matrix-rows mat) (matrix-cols mat)))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of columns.
(define (matrix-samecols? x y)
  (fx= (matrix-cols x) (matrix-cols y)))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of rows.
(define (matrix-samerows? x y)
  (fx= (matrix-rows x) (matrix-rows y)))

;;@returns: **boolean** answering if **matrix**es `x` and `y` have same number of columns and rows.
(define (matrix-samedims? x y)
  (and (matrix-samecols? x y) (matrix-samerows? x y)))

;;@returns: **boolean** answering if any entry of **matrix** `mat` fulfills predicate **procedure** `pred`.
(define (matrix-any? pred mat)
  (any? (lambda (x)
          (column-any? pred x))
        (matrix-data mat)))

;;@returns: **boolean** answering if all entries of **matrix** `mat` fulfill predicate **procedure** `pred`.
(define (matrix-all? pred mat)
  (all? (lambda (x)
          (column-all? pred x))
        (matrix-data mat)))

;;; Matrix Reducers ############################################################

;;@returns: row-**matrix** resulting from folding by two-argument **procedure** `fun` each column of **matrix** `mat`.
(define (matrix-colfold fun ini mat)
  (matrix-map* (lambda (col)
                 (column (column-fold fun ini col)))
               mat))

;;@returns: column-**matrix** resulting from folding by two-argument **procedure** `fun` each row of **matrix** `mat`.
(define (matrix-rowfold fun ini mat)
  (make-matrix 1
    (list (foldl (lambda (acc col)
                   (column-map fun acc col))
                 (make-column (matrix-rows mat) ini)
                 (matrix-data mat)))))

;;@returns: **any** resulting from folding by two-argument **procedure** `fun` all **matrix** `mat` entries.
(define (matrix-allfold fun ini mat)
  (foldl (lambda (acc col)
           (column-fold fun acc col))
         ini
         (matrix-data mat)))

;;; Matrix Mappers #############################################################

;;@returns: **matrix** resulting from applying function to each entry of **matrix** `mat`.
(define (matrix-map fun mat)
  (matrix-map* (lambda (col)
                 (column-map fun col))
               mat))

;;@returns: **matrix** resulting from applying **procedure** `fun` to each element of **matrix**es `x`, `y`, expanded if necessary.
(define (matrix-broadcast fun x y)
  (let [(x-rows (matrix-rows x))
        (y-rows (matrix-rows y))
        (x-cols (matrix-cols x))
        (y-cols (matrix-cols y))]
    (cond [(and (fx= x-rows y-rows) (fx= x-cols y-cols))  ; matrix o matrix
             (matrix-map** (lambda (x-col y-col)
                             (column-map fun x-col y-col))
                           x y)]

          [(and (fx= 1 x-rows) (fx= 1 x-cols))            ; scalar o matrix
             (let [(x0 (matrix-ref00 x))]
               (matrix-map (lambda (yk)
                             (fun x0 yk))
                           y))]

          [(and (fx= 1 y-rows) (fx= 1 y-cols))            ; matrix o scalar
             (let [(y0 (matrix-ref00 y))]
               (matrix-map (lambda (xk)
                             (fun xk y0))
                           x))]

          [(and (fx= 1 x-rows) (fx= x-cols y-cols))       ; row o matrix
             (matrix-map** (lambda (x-col y-col)
                             (let [(x0 (column-ref x-col 0))]
                               (column-map (lambda (y-row)
                                              (fun x0 y-row))
                                            y-col)))
                           x y)]

          [(and (fx= 1 y-rows) (fx= x-cols y-cols))       ; matrix o row
             (matrix-map** (lambda (x-col y-col)
                             (let [(y0 (column-ref y-col 0))]
                                (column-map (lambda (x-row)
                                               (fun x-row y0))
                                             x-col)))
                           x y)]

          [(and (fx= 1 x-cols) (fx= x-rows y-rows))       ; column o matrix
             (let [(x0 (head (matrix-data x)))]
               (matrix-map* (lambda (y-col)
                              (column-map fun x0 y-col))
                            y))]

          [(and (fx= 1 y-cols) (fx= x-rows y-rows))       ; matrix o column
             (let [(y0 (head (matrix-data y)))]
               (matrix-map* (lambda (x-col)
                              (column-map fun x-col y0))
                            x))]

          [(and (fx= 1 x-rows) (fx= 1 y-cols))            ; row o column
             (let [(y0 (head (matrix-data y)))]
               (matrix-map* (lambda (x-col)
                              (let [(x0 (column-ref x-col 0))]
                                (column-map (lambda (y-row)
                                               (fun x0 y-row))
                                             y0)))
                            x))]

          [(and (fx= 1 x-cols) (fx= 1 y-rows))            ; column o row
             (let [(x0 (head (matrix-data x)))]
               (matrix-map* (lambda (y-col)
                              (let [(y0 (column-ref y-col 0))]
                                (column-map (lambda (x-row)
                                               (fun x-row y0))
                                             x0)))
                            y))]

          [else
            (error 'matrix-broadcast "Dimension mismatch!")])))

;;; Matrix Specific ############################################################

;;@returns: column **matrix** of vertically concatenated columns of **matrix** `mat`, aka (mathematical) vectorization.
(define (matrix-vec mat)
  (make-matrix 1 (list (apply column-concat (object-copy (matrix-data mat))))))

;;@returns: **matrix** of entries of **matrix** `mat` with swapped row and column indices.
(define (matrix-transpose mat)
  (make-matrix (matrix-rows mat)
    (apply column-fold* (lambda (acc . vals)
                          (cons (list->column vals) acc))
                        nil
                        (matrix-data mat))))

;;@returns: **matrix** resulting from scaling **matrix** `x` by **any** `a` and add **matrix** `y`.
(define (matrix-axpy a x y)
  (matrix-map** (lambda (xcol ycol)
                  (column-axpy a xcol ycol))
                x y))

;;@returns: **any** resulting from the scalar product of column-**matrix**es `xt` and `y`.
(define (matrix-scalar xt y)
  (column-dot (head (matrix-data xt)) (head (matrix-data y))))

;;@returns: **matrix** resulting from matrix multiplication of transposed **matrix** `xt` and **matrix** `y`.
(define (matrix-dot* xt y)
  (define xt-data (matrix-data xt))
  (define xt-cols (matrix-cols xt))
  (matrix-map* (lambda (y-col)
                 (let [(ret (make-column xt-cols))]
                   (let rho [(idx 0)
                             (lst xt-data)]
                     (if (fx= idx xt-cols) ret
                                           (begin
                                             (column-set! ret idx (column-dot (head lst) y-col))
                                             (rho (fx+1 idx) (tail lst)))))))
               y))

;;@returns: **list**-of-column-**matrix**es from **matrix** `mat`.
(define (matrix-explode mat)
  (map (lambda (col)
         (make-matrix 1 (list col)))
       (matrix-data mat)))

;;@returns: **matrix** of horizontally concatenation of **list**-of-column-**matrix**es `lst`.
(define (matrix-implode lst)
  (apply matrix-horcat lst))

;;; Matrix Utilities ###########################################################

;;@returns: **void**, prints **matrix** to terminal.
(define (matrix-print fun mat)
  (define rows (matrix-rows mat))
  (define rows-1 (fx-1 rows))
  (apply column-foreach-index (lambda (idx . row)
                                (cond [(fx= rows 1)     (display "[")]
                                      [(fx= idx 0)      (display "⎡")]
                                      [(fx= idx rows-1) (display "⎣")]
                                      [else             (display "⎢")])
                                (let rho [(lst row)]
                                  (when (not (empty? lst)) (begin
                                                             (display (fun (head lst)))
                                                             (when (not (empty? (tail lst))) (display " "))
                                                             (rho (tail lst)))))
                                (cond [(fx= rows 1)     (display "]")]
                                      [(fx= idx 0)      (display "⎤")]
                                      [(fx= idx rows-1) (display "⎦")]
                                      [else             (display "⎥")])
                                (newline))
                              (matrix-data mat))
  (newline))

;;@returns: **void**, writes **matrix** `mat` to new comma-separated-value (CSV) file in relative path (**string**) `str`.
(define (matrix-export str mat)
  (define (export-mat)
    (apply column-foreach (lambda row
                            (let rho [(lst row)]
                              (if (empty? lst) (newline)
                                               (begin
                                                 (display (head lst))
                                                 (when (not (empty? (tail lst))) (display ","))
                                                 (rho (tail lst))))))
                          (matrix-data mat)))
  (with-output-to-file str export-mat #:text))

;;@returns: **void**, writes matrix `mat` to new Scheme (SCM) file in relative path (**string**) `str`.
(define (matrix-save str mat)
  (let [(save-mat (lambda ()
                    (display "'(;@matrico")
                    (newline)
                    (for-each print (matrix-data mat))
                    (display ")")
                    (newline)))]
    (with-output-to-file str save-mat #:text)))

;;@returns: **matrix** loaded from file in relative path (**string**) `str`.
(define (matrix-load str)
  (define data (load* str))
  (make-matrix (length data) data))

); end functor

;;; References #################################################################

;;@1: R.K. Dybvig: The Scheme Programming Language, 12.1 Matrix and Vector Multiplication. https://www.scheme.com/tspl4/examples.html#./examples:h1

;;@2: B. Harvey, M. Wright: Simply Scheme: Introducing Computer Science, 23 Vectors. https://people.eecs.berkeley.edu/~bh/ssch23/vectors.html

;;@3: G. Springer, D.P. Friedman: Scheme and the Art of Programming, 9.4 Matrices.

;;@4: H. Abelson, G.J. Sussman, J. Sussman: Structure and Interpretation of Computer Programs, 2.2.3 Sequences as Conventional Interfaces. https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-15.html#%_sec_2.2.3

;;@5: M. Eisenberg: Programming in Scheme, 8 (Ex. 23).

;;@6: M. Watson: Programming in SCHEME, 6.3.1 Two-Dimensional Array Library. https://doi.org/10.1007/978-1-4612-2394-8

;;@7: I. Ferguson, E. Martin, B. Kaufman: The Schemer's Guide (Second Edition), 4 Data Structures.

;;@8: C. Hanson, G.J. Sussman: Software Design for Flexibility, 3 Variations on an Arithmetic Theme (Ex. 3.6). https://mitpress.mit.edu/books/software-design-flexibility
