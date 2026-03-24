;;; modules/ui.el --- Theme, modeline, font, line numbers -*- lexical-binding: t -*-

(use-package doom-themes
  :init (load-theme 'doom-flatwhite t))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :config
  (display-battery-mode 1)
  (display-time-mode 1))

(set-face-attribute 'default nil :font "IosevkaNerdFontMono-20")
(add-to-list 'default-frame-alist '(font . "IosevkaNerdFontMono-20"))

(setq display-line-numbers-type 'relative)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'vterm-mode-hook    (lambda () (display-line-numbers-mode -1)))
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

(provide 'antn-ui)
