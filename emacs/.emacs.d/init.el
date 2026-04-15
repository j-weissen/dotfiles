;;; init.el --- Bootstrap -*- lexical-binding: t -*-

;;; PACKAGE
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("melpa"  . "https://melpa.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t
      use-package-expand-minimally t
      use-package-verbose t)

;;; CUSTOM FILE
;; Keep Emacs Custom output out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;;; MODULES
(defun antn/load-module (name)
  (load (expand-file-name name user-emacs-directory)))

(antn/load-module "modules/ui")
(antn/load-module "modules/completion")
(antn/load-module "modules/evil")
(antn/load-module "modules/dired")
(antn/load-module "modules/vterm")
(antn/load-module "modules/tools")
(antn/load-module "modules/exwm")
(antn/load-module "modules/notifications")
(antn/load-module "modules/session")
(antn/load-module "modules/keybindings")
(antn/load-module "modules/langs/python")
(antn/load-module "modules/langs/dart")
(antn/load-module "modules/langs/nasm")
(antn/load-module "modules/langs/typst")
(antn/load-module "modules/langs/c")

;;; MISC
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-at-bottom)
               (window-height . 0.2)))

(setq make-backup-files nil)
(setq auto-save-default nil)
(setq create-lockfiles nil)

(put 'dired-find-alternate-file 'disabled nil)
