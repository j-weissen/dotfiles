;;; modules/notifications.el --- D-Bus notification daemon -*- lexical-binding: t -*-

(require 'dbus)

;; ──────────────────────────────────────────
;; State
;; ──────────────────────────────────────────

(defvar antn/notif-unread-count 0
  "Number of unread notifications.")

(defvar antn/notif-buffer-name "*Notifications*"
  "Buffer name for notification history.")

(defvar antn/notif-id-counter 1
  "Auto-incrementing notification ID (required by the D-Bus spec).")

;; ──────────────────────────────────────────
;; Buffer / logging
;; ──────────────────────────────────────────

(defun antn/notif-log (app summary body urgency)
  (with-current-buffer (get-buffer-create antn/notif-buffer-name)
    (goto-char (point-max))
    (let* ((ts  (format-time-string "%Y-%m-%d %H:%M:%S"))
           (urg (pcase urgency (0 "low") (1 "normal") (2 "CRITICAL") (_ "?")))
           (sep (make-string 60 ?─)))
      (insert (propertize ts    'face 'font-lock-comment-face) "\n")
      (insert (propertize app   'face 'font-lock-keyword-face) " ")
      (insert (propertize (concat "[" urg "]") 'face
                          (if (= urgency 2) 'error 'shadow)) "\n")
      (insert (propertize summary 'face 'bold) "\n")
      (unless (string-empty-p body)
        (insert body "\n"))
      (insert (propertize sep 'face 'shadow) "\n\n"))))

;; ──────────────────────────────────────────
;; D-Bus handler
;; ──────────────────────────────────────────

(defun antn/notif-handler (app-name
                          _replaces-id
                          _app-icon
                          summary
                          body
                          _actions
                          hints
                          _expire-timeout)
  (let* ((urgency (or (cdr (assoc "urgency" hints)) 1))
         (id      antn/notif-id-counter))
    (cl-incf antn/notif-id-counter)
    (cl-incf antn/notif-unread-count)
    (antn/notif-log app-name summary body urgency)
    (force-mode-line-update t)
    id))

;; ──────────────────────────────────────────
;; D-Bus registration
;; ──────────────────────────────────────────

(defun antn/notif-register-daemon ()
  (dbus-register-service :session "org.freedesktop.Notifications")

  (dbus-register-method
   :session "org.freedesktop.Notifications"
   "/org/freedesktop/Notifications"
   "org.freedesktop.Notifications"
   "Notify"
   #'antn/notif-handler)

  (dbus-register-method
   :session "org.freedesktop.Notifications"
   "/org/freedesktop/Notifications"
   "org.freedesktop.Notifications"
   "GetCapabilities"
   (lambda () '(("body" "persistence"))))

  (dbus-register-method
   :session "org.freedesktop.Notifications"
   "/org/freedesktop/Notifications"
   "org.freedesktop.Notifications"
   "GetServerInformation"
   (lambda () '("emacs-notif" "emacs" "1.0" "1.2")))

  (message "Notification daemon registered."))

;; ──────────────────────────────────────────
;; doom-modeline segment
;; ──────────────────────────────────────────

(with-eval-after-load 'doom-modeline
  (doom-modeline-def-segment antn/notif-segment
    "Shows unread notification count."
    (when (> antn/notif-unread-count 0)
      (let ((map (make-sparse-keymap)))
        (define-key map [mode-line mouse-1] #'antn/notif-open)
        (propertize
         (concat (doom-modeline-icon 'faicon "nf-fa-bell" "🔔" "!"
                                     :face 'doom-modeline-urgent)
                 (propertize (format "%d " antn/notif-unread-count)
                             'face 'doom-modeline-urgent))
         'mouse-face 'mode-line-highlight
         'help-echo "Notifications — click to open"
         'local-map map))))

  (doom-modeline-def-modeline 'antn/main
    '(bar matches buffer-info)
    '(antn/notif-segment misc-info battery time))

  (add-hook 'doom-modeline-mode-hook
            (lambda ()
              (doom-modeline-set-modeline 'antn/main t)
              (dolist (buf (buffer-list))
                (with-current-buffer buf
                  (when (and mode-line-format
                             (not (doom-modeline-auto-set-modeline)))
                    (doom-modeline-set-modeline 'antn/main)))))))

;; ──────────────────────────────────────────
;; User commands
;; ──────────────────────────────────────────

(defun antn/notif-open ()
  "Open the notification history buffer and clear the unread badge."
  (interactive)
  (setq antn/notif-unread-count 0)
  (force-mode-line-update t)
  (pop-to-buffer (get-buffer-create antn/notif-buffer-name)))

(defun antn/notif-clear ()
  "Clear notification history and badge."
  (interactive)
  (setq antn/notif-unread-count 0)
  (when-let ((buf (get-buffer antn/notif-buffer-name)))
    (with-current-buffer buf (erase-buffer)))
  (force-mode-line-update t)
  (message "Notifications cleared."))

(global-set-key (kbd "C-c n n") #'antn/notif-open)
(global-set-key (kbd "C-c n c") #'antn/notif-clear)

;; ──────────────────────────────────────────
;; Start
;; ──────────────────────────────────────────

(antn/notif-register-daemon)

(provide 'antn-notifications)
