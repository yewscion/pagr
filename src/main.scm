(define-module (cdr255 pagr)
  :use-module (ice-9 ftw)
  :use-module (srfi srfi-9)
  :use-module (git)
  :export (push-all-git-repos
           status-all-git-repos
           make-pagr-info
           pagr-info-directory
           pagr-info-remote
           pagr-info-branch
           pagr-info?))

(define-record-type <pagr-info>
  (make-pagr-info directory remote branch)
  pagr-info?
  (directory pagr-info-directory)
  (remote pagr-info-remote)
  (branch pagr-info-branch))

(define (directory->list directory)
  "Build a list of files in a specified directory.

Arguments
=========
DIRECTORY <string>: The name of the directory in question.

Returns
=======
A <list> of <strings> representing the files inside of that directory.

Side Effects
============
Depends on the directory's state.
"
  (map
   (lambda (x)
     (string-append directory "/" x))
   (map
    car
    (cddr (file-system-tree directory)))))

(define (repository? directory)
  "Test whether a directory is a git repository.

Arguments
=========
DIRECTORY <string>: The directory to check.

Returns
=======
Truthy if the /.git/ directory is found. False otherwise.

Side Effects
============
Depends on Directory contents.
"

  (member (string-append directory "/.git") (directory->list directory)))

(define (find-git-repos directory)
  "Build a list of git repositories inside a specific directory.

Arguments
=========
DIRECTORY <string>: The directory to check for git repositories.

Returns
=======
A <list> of <strings>, representing the repositories found inside of the directory.

Side Effects
============
Depends on the Directory's contents.
"
  (filter repository? (directory->list directory)))

(define* (push-git-repo repository remote #:optional (branch "trunk"))
  "Call system git to push a git repository.

Arguments
=========
REPOSITORY <string>: The name of the directory the repository lives in locally.
REMOTE <string>: The name of the remote to which we are pushing.
BRANCH <string>: The name of the branch to push. Defaults to \"trunk\".

Returns
=======
A <string> representing the git command's exit status.

Side Effects
============
Relies on outside binary (git)."

  (narrate-directory-push repository)
  (display (string-append "git -C " repository " push " remote " " branch "\n"))
  (system (string-append "git -C " repository " push " remote " " branch)))

(define* (push-all-git-repos pagr-info)
  "Push all git repositories inside of a directory to a specified remote.

Arguments
=========
PAGR-INFO <srfi-9 record>: A structure containing three <string> fields: 
                           directory, remote, and branch.

Returns
=======
<undefined>

Side Effects
============
Entirely based on side effects.
"
  (let ((directory (pagr-info-directory pagr-info))
        (remote (pagr-info-remote pagr-info))
        (branch (pagr-info-branch pagr-info)))
    (greet-the-user directory)
    (map
     (lambda (repo)
       (push-git-repo repo remote branch))
     (find-git-repos directory))
    (farewell-the-user)))

(define* (list-delta-files repository)
  "Check for changed files with libgit2.

Arguments
=========
REPOSITORY <string>: The name of the directory the repository lives in locally.

Returns
=======
A <list> of <strings> representing the modified files in the repo..

Side Effects
============
Relies on outside binary (git)."

  (let* ((repo (repository-open (string-append repository "/.git")))
         (statuses (status-list->status-entries (status-list-new repo (make-status-options))))
         (diffs (map-in-order status-entry-index-to-workdir statuses)))
    (map-in-order (lambda (x) (diff-file-path (diff-delta-new-file x))) diffs)))

(define* (status-git-repo repository remote branch)
  "Call system git to check the status of a repository.

Arguments
=========
REPOSITORY <string>: The name of the directory the repository lives in locally.
REMOTE <string>: A remote expected to be tracked in the repo (IGNORED).
BRANCH <string>: A branch expected to be live in the repo (IGNORED).

Returns
=======
A <string> representing the git command's exit status.

Side Effects
============
Relies on outside binary (git)."
  
  (narrate-directory-status repository)
  (let* ((changed-files (list-delta-files repository))
         (number-of-changed-files (length changed-files)))
    (unless (= number-of-changed-files 0)
      (display "\n\nUncommitted Changes:\n\n")
      (map (lambda (x) (display (string-append " - " x "\n"))) changed-files))))

(define* (status-all-git-repos pagr-info)
  "Check all git repositories inside of a directory for their current status.

Arguments
=========
PAGR-INFO <srfi-9 record>: A structure containing three <string> fields: 
                           directory, remote, and branch.

Returns
=======
<undefined>

Side Effects
============
Entirely based on side effects.
"
  (let ((directory (pagr-info-directory pagr-info))
        (remote (pagr-info-remote pagr-info))
        (branch (pagr-info-branch pagr-info)))
    (greet-the-user directory)
    (map
     (lambda (repo)
       (status-git-repo repo remote branch))
     (find-git-repos directory))
    (farewell-the-user)))

(define (greet-the-user directory)
  "Tell the user what we're doing.

Arguments
=========
DIRECTORY <string>: The directory we are working in.

Returns
=======
<undefined>

Side Effects
============
Displays a message to the user.
"

  (display (string-append
            "Beginning work on all git repos in " directory " now!\n")))

(define (narrate-directory-push directory)
  "Tell the user what directory we are pushing, so errors can be caught.

Arguments
=========
DIRECTORY <string>: The directory being pushed.

Returns
=======
<undefined>

Side Effects
============
Displays a message to the user.
"

  (display (string-append "Pushing " directory " now!\n")))

(define (narrate-directory-status directory)
  "Tell the user what directory checking, so errors can be caught.

Arguments
=========
DIRECTORY <string>: The directory being checked.

Returns
=======
<undefined>

Side Effects
============
Displays a message to the user.
"
  (let ((reponame (basename directory)))
  (display (string-append
            "\n╭─────────"
            (make-string (string-length reponame) #\x2500)
            "─────╮\n│Checking "
            reponame
            " now!│\n╰─────────"
            (make-string (string-length reponame) #\x2500)
            "─────╯"))))

(define (farewell-the-user)
  "Say goodbye to the user.

Arguments
=========
<none>

Returns
=======
<undefined>

Side Effects
============
Displays a message to the user."

  (display "\n\nAll directories processed!\n"))
