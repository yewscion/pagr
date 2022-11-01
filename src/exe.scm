#!/usr/bin/env -S guile -e main -s
-e main -s
!#
(use-modules (cdr255 pagr)
             (ice-9 getopt-long)   ; For CLI Options and Flags.
             (ice-9 ftw)           ; For Filesystem Access.
             (ice-9 textual-ports) ; For Writing to Files.
             (srfi srfi-19)        ; For Dates.
             (srfi srfi-9))        ; For Records.

(define option-spec
  '((version (single-char #\v) (value #false))
    (push (single-char #\p) (value #false))
    (status (single-char #\s) (value #false))
    (help (single-char #\h) (value #false))
    (brief (single-char #\b) (value #false))))

(define my-usage-message
  (string-append
   "Usage: pagr [-vh]\n"
   "       pagr [-s | -p] [-b] [DIRECTORY] [REMOTE] [BRANCH]\n\n"

   "pagr v0.0.2\n\n"

   "Explanation of Arguments:\n\n"

   "  DIRECTORY: The directory in which all of the git\n"
   "             repositories reside.\n"
   "  REMOTE:    The name of the remote branch to which\n"
   "             all git repositories found should be\n"
   "             pushed.\n"
   "  BRANCH:    The name of the branch we're dealing with.\n"
   "             Defaults to \"trunk\" if missing.\n\n"

   "Explanation of Actions:\n\n"
   
   "  [-v || --version]: Display version and help info.\n"
   "  [-h || --help]:    Display this help info.\n"
   "  [-s || --status]:  Get the status of all of the git\n"
   "                     repositories that are found.\n"
   "  [-p || --push]:    Push all the git repositories\n"
   "                     that are found.\n\n"
   
   "Explanation of Options:\n\n"

   "  [-b || --brief]:   Only display information for repos with\n"
   "                     obvious changes (for status) or actual git\n"
   "                     output (for push).\n"
   
   "This program is entirely written in GNU Guile Scheme,\n"
   "and You are welcome to change it how You see fit.\n\n"

   "Guile Online Help: <https://www.gnu.org/software/guile/>\n"
   "Local Online Help: 'info guile'\n"))

(define (main args)
  (let* ((options (getopt-long args option-spec))
         (version (option-ref options 'version #false))
         (help (option-ref options 'help #false))
         (non-options (option-ref options '() #false))
         (push (option-ref options 'push #false))
         (status (option-ref options 'status #false))
         (brief (option-ref options 'brief #false))
         (non-option-count (length non-options))
         (directory (cond ((= non-option-count 0)
                           "Documents")
                          (else
                           (car non-options))))
         (pagr-info (cond ((not (file-exists? directory))
                           (error-dir-dne directory)
                           #false)
                          ((= non-option-count 1)
                           (make-pagr-info (canonicalize-path
                                            directory)
                                           "origin"
                                           "trunk"
                                           brief))
                          ((= non-option-count 2)
                           (make-pagr-info (canonicalize-path
                                            directory)
                                           (cadr non-options)
                                           "trunk"
                                          brief))
                          ((= non-option-count 3)
                           (make-pagr-info (canonicalize-path
                                            directory)
                                           (cadr non-options)
                                           (caddr non-options)
                                           brief))
                          (else #false))))
    (cond ((or version help)
           (display my-usage-message))
          ((not pagr-info)
           (format
            #t
            (string-append "ERROR: Unreasonable Arguments.~%"
                           "You supplied the following: ~a ~%")
            non-options))
          ((and (not push) status)
           (status-all-git-repos pagr-info))
          ((and (not status) push)
           (push-all-git-repos pagr-info))
          (else
           (display my-usage-message)))))
(define (error-dir-dne directory)
  (format #t "ERROR: Directory \"~a\" does not exist!~%"
          directory))
