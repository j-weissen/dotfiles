;;; modules/exwm.el --- EXWM window manager -*- lexical-binding: t -*-

(defun antn/focus-exwm-window (&rest _)
  (run-at-time 0.1 nil
    (lambda ()
      (when (derived-mode-p 'exwm-mode)
        (exwm-input--set-focus (exwm--buffer->id (current-buffer)))))))

(use-package exwm
  :demand t
  :hook (exwm-update-class . (lambda ()
                               (exwm-workspace-rename-buffer exwm-class-name)))
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

(provide 'antn-exwm)
