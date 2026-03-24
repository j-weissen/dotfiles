;;; modules/langs/c.el --- C: LSP + compile keybindings -*- lexical-binding: t -*-
;; Requirements: clangd on PATH

(defun antn/c-setup ()
  (local-unset-key (kbd "C-c"))
  (local-set-key (kbd "C-c C-c") #'recompile)
  (local-set-key (kbd "C-c /")   #'comment-or-uncomment-region)
  (lsp-deferred))

(use-package cc-mode
  :ensure nil
  :hook ((c-mode    . antn/c-setup)
         (c-ts-mode . antn/c-setup)))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l"))

(use-package lsp-ui
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-sideline-show-diagnostics t))

(provide 'antn-c)
