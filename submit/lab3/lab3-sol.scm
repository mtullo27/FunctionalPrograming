(define (quadratic-roots a b c) (list
	(/ (+ (- 0 b) (sqrt(- (expt b 2) (* 4 a c)))) (* 2 a))
	(/ (- (- 0 b) (sqrt(- (expt b 2) (* 4 a c)))) (* 2 a))
	))

(define quadratic-roots-smart
	(lambda (a b c (sqrt-fn sqrt))
		(if (= a 0)
			'error
		(let ([x (sqrt-fn (- (* b b) (* 4 a c)))])
			(list 
				(/ (+ (- 0 b) x) (* 2 a))
				(/ (- (- 0 b) x) (* 2 a))
			)
		)
		)
	)
)

(define my-sqrt
	(lambda (n (x 1.0))
		(if (< (abs (/ (- (* x x) n) n)) 0.0001)
		x
		(my-sqrt n (/ (+ x (/ n x)) 2))
		)
	)
)

(define greater-than 
	(lambda (ret1 (n 0))
		(if (null? ret1)
			'()
		(if ( > (car ret1) n) 
			(append '("#t") (greater-than(cdr ret1) n))
			(append '("#f") (greater-than(cdr ret1) n))
		)
		)
	)
)

(define get-greater-than 
	(lambda (ret1 (n 0))
		(if (null? ret1)
			'()
		(if ( > (car ret1) n) 
			(append (list (car ret1)) (get-greater-than(cdr ret1) n))
		  (get-greater-than(cdr ret1) n)
		)
		)
	)
)

(define less-than 
	(lambda (ret1 (n 0))
		(if (null? ret1)
			'()
		(if ( < (car ret1) n) 
			(append '("#t") (less-than(cdr ret1) n))
			(append '("#f") (less-than(cdr ret1) n))
		)
		)
	)
)

(define get-less-than 
	(lambda (ret1 (n 0))
		(if (null? ret1)
			'()
		(if ( < (car ret1) n) 
			(append (list (car ret1)) (get-less-than(cdr ret1) n))
		  (get-less-than(cdr ret1) n)
		)
		)
	)
)

