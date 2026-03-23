;;; modules/dired.el --- Dired configuration -*- lexical-binding: t -*-

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "n") #'dired-create-empty-file)
  (define-key dired-mode-map (kbd "N") #'dired-create-directory))

(global-set-key (kbd "C-x C-d") #'dired-jump)

(defun antn/dired-reopen-as-root ()
  (unless (file-writable-p default-directory)
    (when (y-or-n-p (format "Directory %s is not writable. Reopen as root? "
                            default-directory))
      (find-alternate-file (concat "/sudo::" default-directory)))))

(add-hook 'dired-mode-hook #'antn/dired-reopen-as-root)

(provide 'antn-dired)
