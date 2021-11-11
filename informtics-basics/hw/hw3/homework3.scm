(define (simplify exp)
  (let ((op (car exp))
        (e1 (cadr exp))
        (e2 (cddr exp)))
    (cond ((equal? op '+)
           (cond ((equal? e1 0)
                  (car e2))
                 ((equal? (car e2) 0)
                  e1)
                 (else exp)))
          ((equal? op '*)
           (cond ((or (equal? e1 0) (equal? (car e2) 0))
                  0)
                 ((equal? e1 1) (car e2))
                 ((equal? (car e2) 1) e1)
                 (else exp)))
          ((equal? op '-)
           (cond ((equal? e1 0)
                  `(* -1 ,(car e2)))
                 ((equal? (car e2) 0) e1)
                 (else exp)))
          ((equal? op '/)
           (if (equal? e1 0)
               0
               exp)))))

(define (derivative exp)
  (cond ((or (number? exp) (equal? exp 'e)) 0)
        ((symbol? exp)
         (if (equal? exp '-x)
             -1
             1))
        (else (let ((op (car exp))
                    (e1 (cadr exp))
                    (e2 (cddr exp)))
                (cond ((equal? op '*)
                       (if (= (length e2) 1)
                           (simplify `(+ ,(simplify `(* ,e1 ,(derivative (car e2)))) ,(simplify `(* ,(derivative e1) ,(car e2)))))
                           (simplify `(+ ,(simplify `(* ,e1 ,(derivative `(* ,(car e2) ,@(cdr e2)))))
                                         ,(simplify `(* ,(derivative e1) (* ,@e2)))))))
                      ((equal? op '+)
                       (if (= (length e2) 1)
                           (simplify `(+ ,(derivative e1) ,(derivative (car e2))))
                           (simplify `(+ ,(derivative e1) ,(derivative `(+ ,(car e2) ,@(cdr e2)))))))
                      ((equal? op '-)
                       (if (= (length e2) 1)
                           (simplify `(- ,(derivative e1) ,(derivative (car e2))))
                           (simplify `(- ,(derivative e1) ,(derivative `(- ,(car e2) ,@(cdr e2)))))))
                      ((equal? op 'sin)
                       (simplify `(* ,(derivative e1) (cos ,e1))))
                      ((equal? op 'cos)
                       (simplify `(* ,(derivative e1) (* (sin ,e1) -1))))
                      ((equal? op 'log)
                       (simplify `(/ ,(derivative e1) ,e1)))
                      ((equal? op 'expt)
                       (simplify `(* ,(derivative `(* ,(car e2) (log ,e1))) (expt ,e1 ,(car e2)))))
                      ((equal? op '/)
                       `(/ ,(simplify `(- ,(simplify `(* ,(derivative `,e1) ,(car e2))) ,(simplify `(* ,e1 ,(derivative `,(car e2)))))) (expt ,(car e2) 2)))
                      )))))