;;Given a list of tokens containing Scheme numbers, '+, '*, '< and '>
;;representing an arithmetic expression given by the following EBNF:
;;
;; expr
;;  : term ( '+ term )*
;;  ;
;; term
;;  : factor ( '* factor )*
;;  ;
;; factor
;;  : NUMBER
;;  | '< expr '>
;;  ;
;;
;;return a Scheme expression giving an AST for the token list with
;;symbols 'add and 'mul used to indicate applications of '+ and '*
;;respectively.
;;
;;If the token list does not meet the requirements of the above
;;grammar, return #f.
(define (arith-parse tokens)
  (let* ([expr-result (expr (init-parse-state tokens))]
	 [ast (result-ast expr-result)]
	 [state (result-state expr-result)])
    (and (eof? state) ast)))

(define (expr state)
) 

;;return a parse-result for a factor in state.
(define (factor state)
  (cond ((error? state) (parse-result #f state))
	( (check? 'NUMBER state)
	  (parse-result (lookahead state) (my-match 'NUMBER state)))
	(else 
	 (let* ([state1 (my-match '< state)]
		[expr-result (expr state1)]
		[state2 (my-match '> (result-state expr-result))])
	   (parse-result (result-ast expr-result) state2)))))


;;return #t iff tok matches parse-state lookahead
(define (check? tok parse-state)
  (if (eq? tok 'NUMBER)
      (number? (lookahead parse-state))
      (eq? tok (lookahead parse-state))))

;;return next parse-state if tok matches lookahead in parse-state;
;;#f on error.
(define (my-match tok parse-state)
  (and (check? tok parse-state) (next-token parse-state)))

;;return triple '(tag left right); #f if if left or right is in error
(define (ast tag left right)
  (and left right (list tag left right)))

;;a parse-result is simply a (ast state) pair.
(define (parse-result ast parse-state)
  (list ast parse-state))
(define (result-ast parse-result) (car parse-result))
(define (result-state parse-result) (cadr parse-result))

;;a parse-state simply consists of list of tokens still
;;to be consumed by parser, #f on error or '() on EOF.
;;Abstracted out below:
(define (init-parse-state tokens) tokens)
(define (lookahead parse-state)
  (and (pair? parse-state) (car parse-state)))
(define (error? parse-state) (eq? #f parse-state))
(define (eof? parse-state) (eq? '() parse-state))

;;return parse-state after discarding current lookahead; #f if no
;;next token.
(define (next-token parse-state)
  (and (pair? parse-state) (cdr parse-state)))
		      
