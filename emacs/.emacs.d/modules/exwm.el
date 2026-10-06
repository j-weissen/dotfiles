;; modules/exwm.el --- EXWM window manager -*- lexical-binding: t -*-

(defun antn/focus-exwm-window (&rest _)
  (run-at-time 0.1 nil
    (lambda ()
      (when (derived-mode-p 'exwm-mode)
        (exwm-input--set-focus (exwm--buffer->id (current-buffer)))))))

(setq focus-follows-mouse t)

(use-package exwm
  :demand t
  :hook (exwm-update-class . (lambda ()
                               (exwm-workspace-rename-buffer exwm-class-name)))
  :config
  (require 'exwm-randr)
  (exwm-randr-mode)
  (setq exwm-randr-workspace-monitor-plist '(2 "DP-1" 2 "HDMI-1"))
  (setq exwm-input-prefix-keys
        '(?\C-b
          ?\M-x
          ?\C-g
          ?\C-x))
  (setq exwm-input-global-keys
        `(([?\s-w] . exwm-workspace-switch)
          ([?\s-r] . exwm-input-grab-keyboard)
          ,@(mapcar (lambda (i)
                      `(,(vector (+ ?\s-0 i)) .
                        (lambda ()
                          (interactive)
                          (exwm-workspace-switch-create ,i))))
                    (number-sequence 0 9))))
  (unless (bound-and-true-p exwm--connection)
    (exwm-init))
  (global-set-key (kbd "s-d")
                  (lambda (command)
                    (interactive (list (read-shell-command "start program: ")))
                    (start-process-shell-command command nil command))))

(add-hook 'exwm-input-line-mode-hook #'force-mode-line-update)
(add-hook 'exwm-input-char-mode-hook #'force-mode-line-update)

(with-eval-after-load 'doom-modeline
  (doom-modeline-def-segment antn/exwm-input-mode
    (when (derived-mode-p 'exwm-mode)
      (if (eq exwm--input-mode 'char-mode)
          (propertize " [C]" 'face 'doom-modeline-urgent)
        " [L]")))

  (doom-modeline-def-modeline 'main
    '(eldoc bar window-state workspace-name window-number modals matches follow buffer-info remote-host buffer-position word-count parrot selection-info)
    '(compilation objed-state misc-info antn/exwm-input-mode project-name persp-name battery grip irc mu4e gnus github debug repl lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs check time)))

(provide 'antn-exwm)
