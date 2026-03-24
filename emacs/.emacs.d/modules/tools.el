;;; modules/tools.el --- Miscellaneous tools -*- lexical-binding: t -*-

(use-package server
  :config
  (unless (server-running-p)
    (server-start)))

(use-package which-key
  :demand t
  :diminish which-key-mode
  :config
  (which-key-mode 1))

(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :custom
  (auto-revert-use-notify t)
  (auto-revert-verbose nil)
  :config
  (pdf-tools-install)
  (add-to-list 'revert-without-query "\\.pdf\\'")
  (add-hook 'pdf-view-mode-hook #'auto-revert-mode)
  (with-eval-after-load 'pdf-view
    (define-key pdf-view-mode-map (kbd "C-b") 'antn/tmux-keymap)))

(use-package magit
  :bind ("C-c g" . magit-status))

(provide 'antn-tools)
