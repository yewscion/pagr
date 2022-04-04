(define-module (pagr)
  :use-module (ice-9 ftw)
  :export (pagr))

(define (say-hello)
  (display "Hello World!\n"))

(define (pagr)
  (say-hello))
