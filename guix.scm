;;; guix.scm -- Guix package definition

;;; pagr -- Push All Git Repos
;;; Copyright © 2021-2022 Christopher (yewscion) Rodriguez <yewscion@gmail.com>
;;;
;;; This file is part of pagr.
;;;
;;; Pagr is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU Affero General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; Pagr is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU Affero General Public License
;;; along with pagr.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; GNU Guix development package.  To build and install, run:
;;
;;   guix package -f guix.scm
;;
;; To build it, but not install it, run:
;;
;;   guix build -f guix.scm
;;
;; To use as the basis for a development environment, run:
;;
;;   guix environment -l guix.scm
;;
;;; Code:

(define %source-dir (dirname (current-filename)))
(add-to-load-path (string-append %source-dir "/guix"))

(use-modules (git pagr))

;; Return it here so `guix build/environment/package' can consume it directly.
pagr
