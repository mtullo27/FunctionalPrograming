;;-*- mode: scheme; -*-
;; :set filetype=scheme


;;Return the list resulting by multiplying each element of `list` by `x`.
(define (mul-list list x)
  (if (null? list)
  	'()
  	(cons(* (car list) x) (mul-list (cdr list) x))
  )
) 

;;Given a proper-list list of proper-lists, return the sum of the
;;lengths of all the top-level contained lists.
(define (sum-lengths list)
  (cond((null? list)
  	0)
  (else
  	(+ (length (car list)) (sum-lengths (cdr list)))
  )
  )
)  

;;Evaluate polynomial with list of coefficients coeffs (highest-order
;;first) at x.  The computation should reflect the traditional
;;representation of the polynomial.
(define (poly-eval coeffs x)
	(cond ((null? coeffs)
		0)
	(else
		(+ (* (expt x (- (length coeffs) 1)) (car coeffs)) (poly-eval (cdr coeffs) x)))
	)
)

;;Evaluate polynomial with list of coefficients coeffs (highest-order
;;first) at x using Horner's method.
(define (poly-eval-horner coeffs x)
	(cond 
		((null? coeffs)
			0)
		((not (pair? (cdr coeffs)))
			(+ (car coeffs)))
		(( > (car coeffs) (car (cdr coeffs)))
			(define ret (reverse coeffs))
			(+ (car ret) (* x (poly-eval-horner (cdr ret) x))))
		(else 
			(+ (car coeffs) (* x (poly-eval-horner (cdr coeffs) x))))
	)
) 

;;Return count of occurrences equal? to x in exp
(define (count-occurrences exp x)
	(cond
		((null? exp) 0)
		((and (list? (car exp)) (list? x))
			(cond 
				((equal? x exp) (+ 1 (count-occurrences (cdr exp) x)))
				(else (count-occurrences (cdr exp) x))))
		((list? (car exp)) (count-occurrences (car exp) x))
		((equal? x (car exp)) (+ 1 (count-occurrences (cdr exp) x)))
		(else (count-occurrences (cdr exp) x)))
)
;;Return result of evaluating arith expression over Scheme numbers
;;with fully parenthesized prefix binary operators 'add, 'sub, 'mul
;;and 'div.
(define (arith-eval exp)
  (cond
  	((number? exp) exp)
  	(else
  		(let ((name (car exp))
  			(x1 (arith-eval (cadr exp)))
  			(x2 (arith-eval (caddr exp))))
  		(cond 
  		((equal? name 'add)
  			(+ x1 x2))
  		((equal? name 'sub)
  			(- x1 x2))
  		((equal? name 'mul)
  			(* x1 x2))
  		((equal? name 'div)
  			(/ x1 x2))
  		)
  		)
  	)
	)  	
)  
;;Given a proper-list list of proper-lists, return sum of lengths of
;;all the contained lists.  Must be tail-recursive.
(define (sum-lengths-tr list)
	(define (sum-tr list acc)
		(cond 
			((null? list) 0)
			(else
				(+ acc (+ (length (car list)) (sum-tr (cdr list) acc)))
			)
		)
	)
	(sum-tr list 0)
)  

;;Evaluate polynomial with list of coefficients coeffs (highest-order
;;first) at x.  Must be tail-recursive.
(define (poly-eval-horner-tr coeffs x)
	(define (poly-tr coeffs x acc)
		(cond
			((null? coeffs) 0)
			((not (pair? (cdr coeffs))) (+ acc (car coeffs)))
			(( > (car coeffs) (cadr coeffs))
				(define ret (reverse coeffs))
				(poly-tr ret x acc))
			(else 
				(+ acc (+ (car coeffs) (* x (poly-tr (cdr coeffs) x acc))))
			)
		)
	)
	(poly-tr coeffs x 0)
) 

;;Return the list resulting by multiplying each element of `list` by `x`.
;;Cannot use recursion, can use one or more of `map`, `foldl`, or `foldr`.
(define (mul-list-2 list x)
  (cond((null? list) '())
  	(else (map (lambda (n) (* x n)) list))
  )
)

;;Given a proper-list list of proper-lists, return the sum of the
;;lengths of all the contained lists.  Cannot use recursion, can use
;;one or more of `map`, `foldl`, or `foldr`.
(define (sum-lengths-2 list)
  (cond ((null? list) 0)
  (else (apply + (map length list)))
  )
)

		     
