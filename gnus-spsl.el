;;; gnus-spsl.el --- Handle email spam splitting -*- lexical-binding: t -*-

;; Copyright (C) 2026 Lars Ingebrigtsen.

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>

;; gnus-spsl is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; gnus-spsl is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'multisession)

(defun gnus-spam-split-activate ()
  "Activate `gnus-spam-split-mode' if the current group is a mail group."
  (unless (gnus-news-group-p gnus-newsgroup-name)
    (gnus-spam-split-mode 1)))

(defvar-keymap gnus-spam-split-map
  "z" #'gnus-spam-split-add
  "Z" #'gnus-spam-split-edit)

(define-minor-mode gnus-spam-split-mode
  "Minor mode for adding spam splitting rules."
  :keymap gnus-spam-split-map
  :lighter " Spam"
  :interactive (gnus-summary-mode))

(define-multisession-variable gnus-spam-split-rules nil)

(defvar gnus-spam-split-group "spam"
  "The name of the group to split spam to.")

(defun gnus-spam-split-add ()
  "Add new spam splitting rules based on the current message."
  (interactive nil gnus-summary-mode)
  (let* ((header (gnus-summary-article-header))
	 (subject (mail-header-subject header))
	 (address (mail-header-parse-address (mail-header-from header)))
	 (adds
	  (with-temp-buffer
	    (insert
	     (read-string-from-buffer
	      "Mark the following as spam"
	      (format "Subject: %s\nFrom: %s\nFrom: %s\n"
		      (regexp-quote subject)
		      (regexp-quote
		       (replace-regexp-in-string "\\`.+@" "" (car address)))
		      (regexp-quote
		       (cdr address)))))
	    (goto-char (point-min))
	    (mail-header-extract-no-properties))))
    (if (not adds)
	(message "Nothing to add")
      (setf (multisession-value gnus-spam-split-rules)
	    (seq-uniq
	     (append (multisession-value gnus-spam-split-rules)
		     (mapcar (lambda (elem)
			       (list (symbol-name (car elem)) (cdr elem)))
			     adds))))
      (message "Added to spam rules"))))

(defun gnus-spam-split-edit ()
  "Edit the spam split rules."
  (interactive)
  (setf (multisession-value gnus-spam-split-rules)
	(mapcar
	 (lambda (elem)
	   (list (symbol-name (car elem)) (cdr elem)))
	 (with-temp-buffer
	   (insert
	    (read-string-from-buffer
	     "Edit the spam rules"
	     (mapconcat
	      (lambda (elem)
		(format "%s: %s\n" (capitalize (car elem)) (cadr elem)))
	      (multisession-value gnus-spam-split-rules)
	      "")))
	   (goto-char (point-min))
	   (mail-header-extract-no-properties))))
  (message "Updated spam rules"))

(defun gnus-spam-split ()
  "Returns the current spam split."
  (cons '| (mapcar (lambda (rule)
		     (append rule (list "spam")))
		   (multisession-value gnus-spam-split-rules))))

(provide 'gnus-spsl)

;;; gnus-spsl.el ends here
