;;; modules/session.el --- Session persistence -*- lexical-binding: t -*-

(use-package desktop
  :config
  (setq desktop-save t
        desktop-load-locked-desktop t
        desktop-restore-eager 5)
  (desktop-save-mode 1))

(use-package savehist
  :config
  (savehist-mode 1))

(use-package saveplace
  :config
  (save-place-mode 1))

(provide 'antn-session)
