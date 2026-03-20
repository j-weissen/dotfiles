;;; PACKAGE
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
	("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
(setq use-package-expand-minimally t)

(setq use-package-always-defer t)
(setq use-package-verbose t)

;;; GENERAL
(setq inhibit-startup-message t
      auto-save-default nil
      make-backup-files nil)

(setq initial-buffer-choice 'vterm)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(tool-bar-mode 0)
(menu-bar-mode 0)
(tooltip-mode 0)
(scroll-bar-mode 0)
(set-fringe-mode 0)

(use-package server
  :config
  (unless (server-running-p)
    (server-start)))

(use-package doom-themes
    :init (load-theme 'doom-pine t))

(setq display-line-numbers-type 'relative)
(display-line-numbers-mode 1)

(set-frame-font "IosevkaNerdFontMono-20")
(set-face-attribute 'default nil :font "IosevkaNerdFontMono-20")
(add-to-list 'default-frame-alist '(font . "IosevkaNerdFontMono-20"))

;;; MODELINE
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :config
  (display-battery-mode 1)
  (display-time-mode 1))

;;; IDO
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
  :ensure t
  :after ido
  :config
  (ido-ubiquitous-mode 1)
  (setq ido-confirm-unique-completion t))

;;; WHICH-KEY
(use-package which-key
  :demand t
  :diminish
  (which-key-mode)
  :config
  (which-key-mode 1))

;;; EVIL
(use-package evil
  :ensure t
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

(use-package evil-numbers
  :ensure t
  :config
  (define-key evil-normal-state-map (kbd "C-a") 'evil-numbers/inc-at-pt))
  ;(define-key evil-normal-state-map (kbd "C-x") 'evil-numbers/dec-at-pt)

;;; DIRED
(with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "n") #'dired-create-empty-file)
    (define-key dired-mode-map (kbd "N") #'dired-create-directory)
    (global-set-key (kbd "C-x C-d") #'dired-jump))
    ;(define-key evil-normal-state-map (kbd "RET") 'dired-find-alternate-file)
    ;(define-key evil-normal-state-map (kbd "<return>") 'dired-find-alternate-file))

(defun antn/dired-reopen-as-root ()
  (unless (file-writable-p default-directory)
    (find-alternate-file (concat "/sudo::" default-directory))))
(add-hook 'dired-mode-hook #'antn/dired-reopen-as-root)

;;; VTERM
(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *")
  (setq vterm-shell "bash")
  (setq vterm-max-scrollback 10000)
  (evil-set-initial-state 'vterm-mode 'insert)
  (define-key vterm-mode-map [remap evil-paste-after]
	      (lambda () (interactive)
		(vterm-send-string (current-kill 0))))
  (add-hook 'vterm-set-title-functions
	    (lambda (&rest _)
	      (when (derived-mode-p 'vterm-mode)
		(setq default-directory (vterm--get-pwd))))))

 ;;; PDFS
(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :custom
  (auto-revert-use-notify t)
  (auto-revert-verbose nil)
  :config
  (pdf-tools-install)
  (add-to-list 'revert-without-query "\\.pdf\\'")
  (add-hook 'pdf-view-mode-hook #'auto-revert-mode))

;;; MAGIT
(use-package magit
  :ensure t
  :bind ("C-c g" . magit-status))

(use-package exwm
  :ensure t
  :demand t
  :hook (exwm-update-class . (lambda () (exwm-workspace-rename-buffer exwm-class-name)))
  :config
  (unless (bound-and-true-p exwm--connection)
    (exwm-init))
  (setq exwm-input-prefix-keys
      '(?\C-b
        ?\M-x
        ?\C-g
        ?\C-x))
  (global-set-key (kbd "s-d")
		  (lambda (command)
		    (interactive (list (read-shell-command "start program: ")))
		    (start-process-shell-command command nil command)))
  (advice-add 'tab-bar-switch-to-next-tab :after #'antn/focus-exwm-window)
  (advice-add 'tab-bar-switch-to-prev-tab :after #'antn/focus-exwm-window)
  (advice-add 'tab-bar-switch-to-tab :after #'antn/focus-exwm-window)
  (advice-add 'tab-bar-select-tab :after #'antn/focus-exwm-window))

(defun antn/focus-exwm-window (&rest _)
  (run-at-time 0.1 nil
    (lambda ()
      (when (derived-mode-p 'exwm-mode)
        (exwm-input--set-focus (exwm--buffer->id (current-buffer)))))))

; xrandr
  (defun antn/display-hgb ()
    (interactive)
    (shell-command "xrandr --output eDP-1 --off --output DP-1 --mode 3840x2160 --pos 0x0 --primary")
    (set-frame-width (selected-frame) 3840 nil t)
    (set-frame-height (selected-frame) 2160 nil t))

  (defun antn/display-internal ()
    (interactive)
    (shell-command "xrandr --output DP-1 --off --output eDP-1 --auto --primary")
    (let ((width (x-display-pixel-width))
          (height (x-display-pixel-height)))
      (set-frame-width (selected-frame) width nil t)
      (set-frame-height (selected-frame) height nil t)))

;;; SESSION PRESERVATION
(use-package desktop
  :config
  (setq desktop-save t
        desktop-load-locked-desktop t
        desktop-restore-eager 5)
  (desktop-save-mode 1))

;; Persist minibuffer history (commands, file paths, etc.)
(use-package savehist
  :config
  (savehist-mode 1))

;; Remember cursor position in files
(use-package saveplace
  :config
  (save-place-mode 1))

;;; KEYBINDS
(define-key evil-normal-state-map (kbd "C-b") nil)
(define-key evil-insert-state-map (kbd "C-b") nil)

(define-prefix-command 'antn/tmux-keymap)
(define-key evil-normal-state-map (kbd "C-b") 'antn/tmux-keymap)
(define-key evil-insert-state-map (kbd "C-b") 'antn/tmux-keymap)

(define-prefix-command 'antn/launch-keymap)
(define-key antn/tmux-keymap (kbd "d") 'antn/launch-keymap)

(defun antn/shutdown ()
  (interactive)
  (when (yes-or-no-p "really shutdown?")
    (start-process "shutdown" nil "systemctl" "poweroff")))

(defun antn/reboot ()
  (interactive)
  (when (yes-or-no-p "really reboot?")
    (start-process "reboot" nil "systemctl" "reboot")))

(defun antn/exit-emacs ()
  (interactive)
  (when (yes-or-no-p "really exit emacs?")
    (let ((confirm-kill-processes nil)
          (confirm-kill-emacs nil))
      (kill-emacs))))

(define-key antn/tmux-keymap (kbd "ä") 'antn/shutdown)
(define-key antn/tmux-keymap (kbd "ö") 'antn/reboot)
(define-key antn/tmux-keymap (kbd "ü") 'antn/exit-emacs)

(define-key antn/tmux-keymap (kbd "r") (lambda () (interactive)
					 (load-file user-init-file)
					 (message "config reloaded")))
(define-key antn/tmux-keymap (kbd "q") (lambda () (interactive)
					 (find-file user-init-file)))

; Programs
(define-key antn/launch-keymap (kbd "t") #'vterm)

(defun antn/keepass () (interactive) (start-process "keepassxc" nil "keepassxc"))
(define-key antn/launch-keymap (kbd "k") #'antn/keepass)

(defun antn/browser () (interactive) (start-process "brave" nil "brave-browser"))
(define-key antn/launch-keymap (kbd "b") #'antn/browser)

(defun antn/office () (interactive) (start-process "onlyoffice" nil "onlyoffice-desktopeditors"))
(define-key antn/launch-keymap (kbd "o") #'antn/office)

(defun antn/toggle-jupyter ()
  (interactive)
  (let ((proc (get-process "jupyter")))
    (if proc
        (progn
          (delete-process proc)
          (message "Jupyter stopped"))
      (start-process "jupyter" "*jupyter*" 
                     (expand-file-name "~/Software/jupyter-venv/bin/jupyter-lab"))
      (message "Jupyter started"))))

(define-key antn/launch-map (kbd "j") 'antn/toggle-jupyter)

; Buffer Management
(define-key antn/tmux-keymap (kbd "n") 'tab-bar-switch-to-next-tab)
(define-key antn/tmux-keymap (kbd "p") 'tab-bar-switch-to-prev-tab)
(define-key antn/tmux-keymap (kbd "o") 'other-window)
(define-key antn/tmux-keymap (kbd "c") 'tab-new)
(define-key antn/tmux-keymap (kbd "%") 'split-window-right)
(define-key antn/tmux-keymap (kbd "\"") 'split-window-down)
(define-key antn/tmux-keymap (kbd "x") 'delete-window)
(define-key antn/tmux-keymap (kbd "z") 'exwm-layout-toggle-fullscreen)

; EXWM
(define-key antn/tmux-keymap (kbd "C-b") 'exwm-input-send-next-key)

; Workspace
(define-prefix-command 'antn/workspace-map)
(define-key antn/tmux-keymap (kbd "m") 'antn/workspace-map)

;; Hot reload/restart: send keys to the flutter run vterm from anywhere
(defun antn/flutter-send (key)
  (let ((buf (get-buffer "flutter run")))
    (when buf
      (with-current-buffer buf
        (vterm-send-string key)))))

(defun antn/flutter-hot-reload () (interactive) (antn/flutter-send "r"))
(defun antn/flutter-hot-restart () (interactive) (antn/flutter-send "R"))
(defun antn/flutter-quit () (interactive) (antn/flutter-send "q"))

(define-key antn/workspace-map (kbd "r") 'antn/flutter-hot-reload)
(define-key antn/workspace-map (kbd "R") 'antn/flutter-hot-restart)
(define-key antn/workspace-map (kbd "q") 'antn/flutter-quit)

(defun antn/workspace-logpos ()
  (interactive)
  (let* ((dir "~/LogPos/logpos/")
         (device (if (y-or-n-p "Use physical device?")
                     ""
                   "-d emulator-5554")))

    ;; Tab 1: Code
    (tab-bar-rename-tab "code")
    (delete-other-windows)
    (let ((default-directory dir))
      (find-file dir))

    ;; Tab 2: Run
    (tab-bar-new-tab)
    (tab-bar-rename-tab "run")
    (delete-other-windows)
    (let ((default-directory dir))
      (vterm "flutter run"))
    (split-window-right)
    (window-resize (selected-window)
                   (- (round (* 0.7 (frame-width))) (window-width))
                   t)
    ;; Start emulator if needed
    (when (string-match-p "emulator" device)
      (vterm-send-string "nix develop --command bash -c 'emulator -avd vpixel9 &'\n")
      (run-at-time 2 nil
        (lambda ()
          (with-current-buffer "flutter run"
            (vterm-send-string "nix develop --command flutter run -d emulator-5554\n")))))
    (when (string-empty-p device)
      (vterm-send-string "nix develop --command flutter run\n"))
    ;; Right: nix shell
    (other-window 1)
    (let ((default-directory dir))
      (vterm "nix develop")
      (vterm-send-string "nix develop\n"))

    ;; Tab 3: Claude
    (tab-bar-new-tab)
    (tab-bar-rename-tab "claude")
    (delete-other-windows)
    (let ((default-directory dir))
      (vterm "claude")
      (vterm-send-string "claude\n"))

    ;; Start on code tab
    (tab-bar-switch-to-tab "code")))

(define-key antn/workspace-map (kbd "l") 'antn/workspace-logpos)
				       

;;; EXTENSIONS
(load (expand-file-name "python.el" user-emacs-directory))
(use-package dart-mode
  :ensure t)

(use-package nasm-mode
  :ensure t)

(setq treesit-language-source-alist
      '((typst "https://github.com/uben0/tree-sitter-typst")))
(use-package typst-ts-mode
  :ensure t
  :mode "\\.typ\\'"
  :config
  (add-to-list 'display-buffer-alist
	       '("\\*typst-ts-compilation\\*"
               (display-buffer-at-bottom)
               (window-height . 0.2))))

; compilation
(add-to-list 'display-buffer-alist
	    '("\\*compilation\\*"
	    (display-buffer-at-bottom)
	    (window-height . 0.2)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dart-mode doom-modeline doom-themes evil-collection evil-numbers
	       exwm flycheck flycheck-mypy ido-completing-read+
	       lsp-mode lsp-pyright lsp-ui magit nasm-mode pdf-tools
	       pet python-mode typst-ts-mode vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'dired-find-alternate-file 'disabled nil)
