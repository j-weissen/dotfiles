;; Python development: Pyright LSP + Mypy
;; Requirements: pip install pyright mypy in each project venv

(use-package python
  :ensure nil)

(use-package pet
  :ensure t)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l"))

(use-package lsp-pyright
  :ensure t)

(use-package lsp-ui
  :ensure t
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-sideline-show-diagnostics t))

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package flycheck-mypy
  :ensure t)

(add-hook 'lsp-after-initialize-hook
          (lambda ()
            (flycheck-add-next-checker 'lsp 'python-mypy)))

(add-hook 'python-mode-hook
          (lambda ()
            (when-let ((venv (pet-virtualenv-root)))
              (setq-local python-shell-interpreter          (pet-executable-find "python")
                          python-shell-virtualenv-root      venv
                          lsp-pyright-venv-path             (file-name-directory (directory-file-name venv))
                          lsp-pyright-venv-root             (file-name-nondirectory (directory-file-name venv))
                          lsp-pyright-python-executable-cmd (pet-executable-find "python")
                          exec-path                         (cons (expand-file-name "bin" venv) exec-path))
              (setenv "PATH" (concat (expand-file-name "bin" venv) ":" (getenv "PATH"))))
            (pet-flycheck-setup)
            (lsp-deferred)))

