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

(provide 'antn-exwm)
