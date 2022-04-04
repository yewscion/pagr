(define-module (<<project-name>>)
  :use-module (ice-9 ftw)
  :export (<<program-name>>))

(define (say-hello)
  (display "Hello World!\n"))

(define (<<program-name>>)
  (say-hello))
