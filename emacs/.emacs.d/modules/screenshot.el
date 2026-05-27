;;; modules/screenshot.el --- Screenshot to file via maim -*- lexical-binding: t -*-

(defvar antn/ss-dir (expand-file-name "screenshots" (or (getenv "XDG_PICTURES_DIR")
                                                         "~/.local/share")))

(defun antn/ss-selection ()
  (interactive)
  (make-directory antn/ss-dir t)
  (let ((outfile (expand-file-name (format-time-string "screenshot_%Y%m%d_%H%M%S.png")
                                   antn/ss-dir)))
    (set-process-sentinel
     (start-process "maim-screenshot" nil "maim" "-s" outfile)
     (lambda (proc event)
       (let ((ok (= 0 (process-exit-status proc))))
         (when ok
           (kill-new outfile))
         (antn/notif-log "screenshot"
                         (if ok "Screenshot captured" "Screenshot failed")
                         (if ok (concat "Path copied to kill ring.\n" outfile)
                           (string-trim event))
                         (if ok 1 2))
         (cl-incf antn/notif-unread-count)
         (force-mode-line-update t))))))

(exwm-input-set-key (kbd "s-S") #'antn/ss-selection)

(provide 'antn-screenshot)
