;;; modules/keybindings.el --- Keybindings, prefix maps, launch/workspace fns -*- lexical-binding: t -*-

(setq initial-buffer-choice 'vterm)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;;; Prefix maps

(define-key evil-normal-state-map (kbd "C-b") nil)
(define-key evil-insert-state-map (kbd "C-b") nil)

(define-prefix-command 'antn/tmux-keymap)
(define-key evil-normal-state-map (kbd "C-b") 'antn/tmux-keymap)
(define-key evil-insert-state-map (kbd "C-b") 'antn/tmux-keymap)

(define-prefix-command 'antn/launch-keymap)
(define-key antn/tmux-keymap (kbd "d") 'antn/launch-keymap)

(define-prefix-command 'antn/workspace-keymap)
(define-key antn/tmux-keymap (kbd "w") 'antn/workspace-keymap)

(define-prefix-command 'antn/monitor-keymap)
(define-key antn/tmux-keymap (kbd "m") 'antn/monitor-keymap)

;;; System commands

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

(defun antn/reload-config ()
  (interactive)
  (load-file user-init-file)
  (message "config reloaded"))

(defun antn/open-config ()
  (interactive)
  (find-file user-init-file))

(define-key antn/tmux-keymap (kbd "r") #'antn/reload-config)
(define-key antn/tmux-keymap (kbd "q") #'antn/open-config)

;;; Screenshots

(defvar antn/ss-png-bytes nil)

(push (cons 'image/png (lambda (_sel _type _val)
                         (when antn/ss-png-bytes
                           (cons 'image/png antn/ss-png-bytes))))
      selection-converter-alist)

(defun antn/ss-selection ()
  (interactive)
  (let ((tmpfile (expand-file-name (format-time-string "screenshot_%Y%m%d_%H%M%S.png")
                                   temporary-file-directory)))
    (set-process-sentinel
     (start-process "maim-screenshot" nil "maim" "-s" tmpfile)
     (lambda (proc event)
       (let ((ok (= 0 (process-exit-status proc))))
         (when ok
           (with-temp-buffer
             (set-buffer-multibyte nil)
             (insert-file-contents-literally tmpfile)
             (setq antn/ss-png-bytes (buffer-string)))
           (x-own-selection-internal 'CLIPBOARD 'antn/png-selection))
         (antn/notif-log "screenshot"
                         (if ok "Screenshot captured" "Screenshot failed")
                         (if ok (concat "Copied to clipboard.\n" tmpfile)
                           (string-trim event))
                         (if ok 1 2))
         (cl-incf antn/notif-unread-count)
         (force-mode-line-update t))))))

(exwm-input-set-key (kbd "s-S") #'antn/ss-selection)
   
;;; Launch programs

(defun antn/keepass () (interactive) (start-process "keepassxc" nil "keepassxc"))
(defun antn/browser  () (interactive) (start-process "brave" nil "brave-browser"))
(defun antn/office   () (interactive) (start-process "onlyoffice" nil "onlyoffice-desktopeditors"))

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

(define-key antn/launch-keymap (kbd "t") #'vterm)
(define-key antn/launch-keymap (kbd "k") #'antn/keepass)
(define-key antn/launch-keymap (kbd "b") #'antn/browser)
(define-key antn/launch-keymap (kbd "o") #'antn/office)
(define-key antn/launch-keymap (kbd "j") #'antn/toggle-jupyter)

;;; Buffer / window management

(define-key antn/tmux-keymap (kbd "n") 'tab-bar-switch-to-next-tab)
(define-key antn/tmux-keymap (kbd "p") 'tab-bar-switch-to-prev-tab)
(define-key antn/tmux-keymap (kbd "o") 'other-window)
(define-key antn/tmux-keymap (kbd "<left>")  'windmove-left)
(define-key antn/tmux-keymap (kbd "<right>") 'windmove-right)
(define-key antn/tmux-keymap (kbd "<up>")    'windmove-up)
(define-key antn/tmux-keymap (kbd "<down>")  'windmove-down)
(define-key antn/tmux-keymap (kbd "c") 'tab-new)
(define-key antn/tmux-keymap (kbd "%") 'split-window-right)
(define-key antn/tmux-keymap (kbd "\"") 'split-window-down)
(define-key antn/tmux-keymap (kbd "x") 'delete-window)
(define-key antn/tmux-keymap (kbd "z") 'exwm-layout-toggle-fullscreen)
(define-key antn/tmux-keymap (kbd "C-b") 'exwm-input-send-next-key)

;;; Flutter helpers

(defun antn/flutter-send (key)
  (let ((buf (get-buffer "flutter run")))
    (when buf
      (with-current-buffer buf
        (vterm-send-string key)))))

(defun antn/flutter-hot-reload  () (interactive) (antn/flutter-send "r"))
(defun antn/flutter-hot-restart () (interactive) (antn/flutter-send "R"))
(defun antn/flutter-quit        () (interactive) (antn/flutter-send "q"))

(define-key antn/workspace-keymap (kbd "r") 'antn/flutter-hot-reload)
(define-key antn/workspace-keymap (kbd "R") 'antn/flutter-hot-restart)
(define-key antn/workspace-keymap (kbd "q") 'antn/flutter-quit)

;;; Workspace layouts

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
    (when (string-match-p "emulator" device)
      (vterm-send-string "nix develop --command bash -c 'emulator -avd vpixel9 &'\n")
      (run-at-time 2 nil
        (lambda ()
          (with-current-buffer "flutter run"
            (vterm-send-string "nix develop --command flutter run -d emulator-5554\n")))))
    (when (string-empty-p device)
      (vterm-send-string "nix develop --command flutter run\n"))
    (other-window 1)
    (let ((default-directory dir))
      (vterm "nix shell")
      (vterm-send-string "nix develop\n"))

    ;; Tab 3: Claude
    (tab-bar-new-tab)
    (tab-bar-rename-tab "claude")
    (delete-other-windows)
    (let ((default-directory dir))
      (vterm "claude")
      (vterm-send-string "claude\n"))

    (tab-bar-switch-to-tab "code")))

(define-key antn/workspace-keymap (kbd "l") 'antn/workspace-logpos)

(defun antn/workspace-typst ()
  "Open a typst editing workspace: left=editor, right=pdf preview."
  (interactive)
  (let* ((typ-file (if (and buffer-file-name
                            (string-match-p "\\.typ\\'" buffer-file-name))
                       buffer-file-name
                     (read-file-name "Typst file: " nil nil t nil
                                     (lambda (f) (string-match-p "\\.typ\\'" f)))))
         (pdf-file (concat (file-name-sans-extension typ-file) ".pdf")))
    (unless (file-exists-p pdf-file)
      (let ((default-directory (file-name-directory typ-file)))
        (shell-command (concat "typst compile "
                               (shell-quote-argument (file-name-nondirectory typ-file))))))
    (tab-bar-rename-tab "typst")
    (delete-other-windows)
    (find-file typ-file)
    (split-window-right)
    (other-window 1)
    (find-file pdf-file)
    (other-window 1)))

(define-key antn/workspace-keymap (kbd "t") 'antn/workspace-typst)

;;; Monitors

(defun antn/display-hgb ()
  (interactive)
  (shell-command "xrandr --output eDP-1 --off --output DP-1 --mode 3840x2160 --pos 0x0 --primary")
  (set-frame-width (selected-frame) 3840 nil t)
  (set-frame-height (selected-frame) 2160 nil t))

(defun antn/display-sol ()
  (interactive)
  (shell-command "xrandr --output eDP-1 --off --output DP-1 --mode 2560x1440 --pos 0x0 --primary")
  (set-frame-width (selected-frame) 2560 nil t)
  (set-frame-height (selected-frame) 1440 nil t))

(defun antn/display-steyr ()
  (interactive)
  (shell-command "xrandr --output eDP-1 --off --output HDMI-1 --mode 1920x1080 --pos 0x0 --primary")
  (set-frame-width (selected-frame) 1920 nil t)
  (set-frame-height (selected-frame) 1080 nil t))

(defun antn/display-internal ()
  (interactive)
  (shell-command "xrandr --output DP-1 --off --output eDP-1 --auto --primary")
  (let ((width (x-display-pixel-width))
        (height (x-display-pixel-height)))
    (set-frame-width (selected-frame) width nil t)
    (set-frame-height (selected-frame) height nil t)))

(define-key antn/monitor-keymap (kbd "i") 'antn/display-internal)
(define-key antn/monitor-keymap (kbd "h") 'antn/display-hgb)
(define-key antn/monitor-keymap (kbd "s") 'antn/display-steyr)
(define-key antn/monitor-keymap (kbd "f") 'antn/display-sol)

(provide 'antn-keybindings)
