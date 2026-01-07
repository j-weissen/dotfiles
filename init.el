(tool-bar-mode 0)
(menu-bar-mode 0)
(tooltip-mode 0)
(scroll-bar-mode 0)
(set-fringe-mode 0)

(setq inhibit-startup-message t
      auto-save-default nil
      make-backup-files nil)

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-expand-minimally t)

(setq use-package-always-defer t)
(setq use-package-verbose t)

(use-package which-key
  :demand t
  :diminish
  (which-key-mode)
  :config
  (which-key-mode 1))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode))

(use-package doom-themes
    :init (load-theme 'doom-pine t))

(add-to-list 'default-frame-alist `(font . "Iosevka Nerd Font Mono"))
(set-face-attribute 'default t :font "Iosevka Nerd Font Mono" )

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package evil
    :demand t
    :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-want-C-u-scroll t)
    (setq evil-want-C-i-jump nil)
    :config
    (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "n") #'dired-create-empty-file)
    (global-set-key (kbd "C-x C-d") #'dired-jump)
    (global-set-key (kbd "C-x C-t") #'term)
    (define-key evil-normal-state-map (kbd "RET") 'dired-find-alternate-file)
    (define-key evil-normal-state-map (kbd "<return>") 'dired-find-alternate-file))

(use-package pdf-tools)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("56044c5a9cc45b6ec45c0eb28df100d3f0a576f18eef33ff8ff5d32bac2d9700"
     "fd22a3aac273624858a4184079b7134fb4e97104d1627cb2b488821be765ff17"
     "f1e8339b04aef8f145dd4782d03499d9d716fdc0361319411ac2efc603249326"
     default))
 '(package-selected-packages
   '(doom-modeline doom-themes evil-collection mood-line pdf-tools
		   projectile)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
