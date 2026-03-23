;;; modules/vterm.el --- VTerm terminal emulator -*- lexical-binding: t -*-

(use-package vterm
  :commands vterm
  :config
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] *"
        vterm-shell "bash"
        vterm-max-scrollback 10000)
  (evil-set-initial-state 'vterm-mode 'insert)
  (define-key vterm-mode-map [remap evil-paste-after]
    (lambda () (interactive)
      (vterm-send-string (current-kill 0))))
  (add-hook 'vterm-set-title-functions
            (lambda (&rest _)
              (when (derived-mode-p 'vterm-mode)
                (setq default-directory (vterm--get-pwd))))))

(provide 'antn-vterm)
