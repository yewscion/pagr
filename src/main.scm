(define-module (cdr255 pagr)
  :use-module (ice-9 ftw)
  :export (push-all-git-repos))

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
TRUNK <string>: The name of the branch to push. Defaults to \"trunk\".

Returns
=======
A <string> representing the git command's exit status.

Side Effects
============
Relies on outside binary (git)."

  (narrate-directory-push repository)
  (display (string-append "git -C " repository " push " remote " " branch "\n"))
  (system (string-append "git -C " repository " push " remote " " branch)))

(define* (push-all-git-repos directory remote #:optional (branch "trunk"))
  "Push all git repositories inside of a directory to a specified remote.

Arguments
=========
DIRECTORY <string>: The directory to look for repos inside.
REMOTE <string>: A remote to push the repos to.
BRANCH <string>: Which branch to push.

Returns
=======
<undefined>

Side Effects
============
Entirely based on side effects.
"

  (greet-the-user directory)
  (map
   (lambda (repo)
     (push-git-repo repo remote branch))
   (find-git-repos directory))
  (farewell-the-user))

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

  (display (string-append "Beginning push of all git repos in " directory " now!\n")))

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

  (display "All directories pushed!\n"))
