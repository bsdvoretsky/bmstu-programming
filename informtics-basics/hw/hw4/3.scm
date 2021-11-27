(define (read-words src)
  (let ((port (open-input-file src)) (res '()) (temp '()))
    (define (loop)
      (let ((char (read-char port)))
        (if (eof-object? char)
            (if (not (null? temp))
                (begin (set! res (cons (list->string temp) res))
                       (set! temp '()))
                (begin (close-input-port port)
                       (reverse res)))
            (if (char-whitespace? char)
                (if (not (null? temp))
                    (begin (set! res (cons (list->string temp) res))
                           (set! temp '())
                           (loop))
                    (loop))
                (begin (set! temp (append temp (list char))) (loop))))))
    (loop)))