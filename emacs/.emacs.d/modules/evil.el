;;; modules/evil.el --- Evil mode and extensions -*- lexical-binding: t -*-

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-numbers
  :after evil
  :config
  (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt))
  ;; (define-key evil-normal-state-map (kbd "C-x") 'evil-numbers/dec-at-pt)

(provide 'antn-evil)
