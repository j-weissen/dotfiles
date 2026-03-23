;;; modules/langs/typst.el --- Typst document language -*- lexical-binding: t -*-

(setq treesit-language-source-alist
      '((typst "https://github.com/uben0/tree-sitter-typst")))

(use-package typst-ts-mode
  :ensure t
  :mode "\\.typ\\'"
  :config
  (add-to-list 'display-buffer-alist
               '("\\*typst-ts-compilation\\*"
                 (display-buffer-at-bottom)
                 (window-height . 0.2)))

  (defun antn/typst-compile ()
    "Save current buffer and compile with typst."
    (interactive)
    (save-buffer)
    (let ((default-directory (file-name-directory buffer-file-name)))
      (compile (concat "typst compile "
                       (shell-quote-argument (file-name-nondirectory buffer-file-name))))))

  (define-key typst-ts-mode-map (kbd "C-c C-c") #'antn/typst-compile))

(provide 'antn-typst)
