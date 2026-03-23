;;; modules/completion.el --- IDO completion -*- lexical-binding: t -*-

(use-package ido
  :demand t
  :config
  (ido-mode 1)
  (ido-everywhere 1)
  (setq ido-enable-flex-matching t
        ido-create-new-buffer 'always
        ido-use-filename-at-point 'guess
        ido-default-file-method 'selected-window
        ido-default-buffer-method 'selected-window))

(use-package ido-completing-read+
  :after ido
  :config
  (ido-ubiquitous-mode 1)
  (setq ido-confirm-unique-completion t))

(provide 'antn-completion)
