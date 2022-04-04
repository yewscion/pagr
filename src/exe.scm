#!/usr/bin/env -S guile -e main -s
-e main -s
!#
(use-modules (cdr255 pagr))

(define my-usage-message (string-append
                          "Usage: pagr.scm DIRECTORY REMOTE\n\n"
                          
                          "Explanation of Arguments:\n\n"
                          
                          "  DIRECTORY: The directory in which all of the git\n"
                          "             repositories reside.\n"
                          "  REMOTE:    The name of the remote branch to which\n"
                          "             all git repositories found should be\n"
                          "             pushed.\n\n"

                          "This program is entirely written in GNU Guile Scheme,\n"
                          "and You are welcome to change it how You see fit.\n\n"

                          "Guile Online Help: <https://www.gnu.org/software/guile/>\n"
                          "Local Online Help: 'info guile'\n"))

(define (main args)
  (let ((arguments (cdr args)))
    (cond ((not (equal? (length arguments) 2))
           (display my-usage-message))
          ((not (file-exists? (car arguments)))
           (format #t "ERROR: ~a does not exist!~%" (car arguments)))
          (else
           (push-all-git-repos (car arguments) (cadr arguments))))))
