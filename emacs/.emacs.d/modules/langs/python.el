;;; modules/langs/python.el --- Python: LSP + pet + flycheck -*- lexical-binding: t -*-
;; Requirements: pip install pyright mypy in each project venv

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

(use-package flycheck
  :init (global-flycheck-mode))

;; Add mypy after LSP initializes, only for Python buffers.
;; pet-flycheck-setup handles per-venv mypy configuration.
(add-hook 'lsp-after-initialize-hook
          (lambda ()
            (when (derived-mode-p 'python-mode 'python-ts-mode)
              (flycheck-add-next-checker 'lsp 'python-mypy))))

(defun antn/python-setup ()
  (when-let ((venv (pet-virtualenv-root)))
    (setq-local python-shell-interpreter          (pet-executable-find "python")
                python-shell-virtualenv-root      venv
                lsp-pyright-venv-path             (file-name-directory
                                                   (directory-file-name venv))
                lsp-pyright-venv-root             (file-name-nondirectory
                                                   (directory-file-name venv))
                lsp-pyright-python-executable-cmd (pet-executable-find "python")
                exec-path                         (cons (expand-file-name "bin" venv)
                                                        exec-path)
                ;; Keep PATH modification buffer-local via process-environment
                process-environment               (cons (concat "PATH="
                                                                (expand-file-name "bin" venv)
                                                                ":"
                                                                (getenv "PATH"))
                                                        process-environment)))
  (pet-flycheck-setup)
  (lsp-deferred))

(add-hook 'python-mode-hook    #'antn/python-setup)
(add-hook 'python-ts-mode-hook #'antn/python-setup)

(provide 'antn-python)
