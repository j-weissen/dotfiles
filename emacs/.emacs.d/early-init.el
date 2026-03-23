;;; early-init.el --- UI suppression before frame creation -*- lexical-binding: t -*-
;; Runs before init.el and before the first frame is created.
;; Disabling UI elements here prevents the brief flicker of toolbars/scrollbars.

(setq inhibit-startup-message t)

(tool-bar-mode 0)
(menu-bar-mode 0)
(tooltip-mode 0)
(scroll-bar-mode 0)
(set-fringe-mode 0)
