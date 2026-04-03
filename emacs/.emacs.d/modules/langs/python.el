;;; modules/langs/python.el --- Python: LSP + pet + flycheck -*- lexical-binding: t -*-
;; Requirements: pip install pyright mypy debugpy flake8 pylint in each project venv
;; Optional: pip install black for formatting (C-c C-f)

(use-package python
  :ensure nil)

(use-package pet
  :ensure t)

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l"))

(use-package lsp-pyright
  :ensure t)

(use-package lsp-ui
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-sideline-show-diagnostics t))

(use-package dap-mode
  :after lsp-mode
  :config
  (require 'dap-python)
  (setq dap-python-debugger 'debugpy)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  :bind ((:map python-mode-map
          ("C-c d d" . dap-debug)
          ("C-c d b" . dap-breakpoint-toggle)
          ("C-c d n" . dap-next)
          ("C-c d i" . dap-step-in)
          ("C-c d o" . dap-step-out)
          ("C-c d c" . dap-continue)
          ("C-c d q" . dap-disconnect)
          ("C-c d r" . dap-ui-repl))
         (:map python-ts-mode-map
          ("C-c d d" . dap-debug)
          ("C-c d b" . dap-breakpoint-toggle)
          ("C-c d n" . dap-next)
          ("C-c d i" . dap-step-in)
          ("C-c d o" . dap-step-out)
          ("C-c d c" . dap-continue)
          ("C-c d q" . dap-disconnect)
          ("C-c d r" . dap-ui-repl))))

(use-package flycheck
  :hook ((python-mode    . flycheck-mode)
         (python-ts-mode . flycheck-mode)))

;; Chain checkers after LSP initializes, only for Python buffers.
;; pet-flycheck-setup handles per-venv executable paths.
;; (t . CHECKER) means always run regardless of upstream errors.
;; Chain: lsp -> python-mypy -> python-flake8 -> python-pylint
(add-hook 'lsp-after-initialize-hook
          (lambda ()
            (when (derived-mode-p 'python-mode 'python-ts-mode)
              (flycheck-add-next-checker 'lsp             '(t . python-mypy))
              (flycheck-add-next-checker 'python-mypy     '(t . python-flake8))
              (flycheck-add-next-checker 'python-flake8   '(t . python-pylint)))))

;; --- Compilation-style run/test commands ---
;; C-c C-c  run project  (prompts first time, reruns after)
;; C-c C-t  run tests    (prompts first time, reruns after)
;; C-c C-k  reset both commands

(defvar-local antn/python-run-cmd nil
  "Cached run command for this Python buffer.")
(defvar-local antn/python-test-cmd nil
  "Cached test command for this Python buffer.")

(defun antn/python-run ()
  "Run the Python project.  Prompts for command on first use; reruns after."
  (interactive)
  (unless antn/python-run-cmd
    (setq antn/python-run-cmd
          (read-shell-command "Run command: " "python -m ")))
  (compile antn/python-run-cmd))

(defun antn/python-test ()
  "Run project tests.  Prompts for command on first use; reruns after."
  (interactive)
  (unless antn/python-test-cmd
    (setq antn/python-test-cmd
          (read-shell-command "Test command: " "pytest ")))
  (compile antn/python-test-cmd))

(defun antn/python-reset-commands ()
  "Reset cached run/test commands so the next invocation prompts again."
  (interactive)
  (setq antn/python-run-cmd nil
        antn/python-test-cmd nil)
  (message "Python run/test commands reset"))

;; --- Formatting with black (C-c C-f) ---

(use-package reformatter :ensure t)

(reformatter-define antn-python-black
  :program "black"
  :args '("--quiet" "--line-length" "100" "-"))

;; --- Setup ---

(defun antn/python-setup ()
  (when-let ((venv (pet-virtualenv-root)))
    (setq-local python-shell-interpreter          (pet-executable-find "python")
                python-shell-virtualenv-root      venv
                lsp-pyright-venv-path             (file-name-directory
                                                   (directory-file-name venv))
                lsp-pyright-venv-root             (file-name-nondirectory
                                                   (directory-file-name venv))
                lsp-pyright-python-executable-cmd (pet-executable-find "python")
                dap-python-executable             (pet-executable-find "python")
                exec-path                         (cons (expand-file-name "bin" venv)
                                                        exec-path)
                ;; Keep PATH modification buffer-local via process-environment
                process-environment               (cons (concat "PATH="
                                                                (expand-file-name "bin" venv)
                                                                ":"
                                                                (getenv "PATH"))
                                                        process-environment))
    ;; Use venv's black if installed
    (when-let ((black-bin (pet-executable-find "black")))
      (setq-local antn-python-black-program black-bin)))
  (setq-local flycheck-flake8-maximum-line-length 100
              flycheck-pylint-use-symbolic-id nil)
  (pet-flycheck-setup)
  (lsp-deferred))

(add-hook 'python-mode-hook    #'antn/python-setup)
(add-hook 'python-ts-mode-hook #'antn/python-setup)

(dolist (map (list python-mode-map python-ts-mode-map))
  (define-key map (kbd "C-c C-c") #'antn/python-run)
  (define-key map (kbd "C-c C-t") #'antn/python-test)
  (define-key map (kbd "C-c C-k") #'antn/python-reset-commands)
  (define-key map (kbd "C-c C-f") #'antn-python-black-buffer))

(provide 'antn-python)
