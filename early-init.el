;;; early-init.el --- Early startup tweaks -*- lexical-binding: t; -*-

(setq frame-resize-pixelwise t
      frame-inhibit-implied-resize t
      ;; Match the `misterioso' theme early to avoid a white startup flash.
      default-frame-alist '((background-color . "#2d3743")
                            (foreground-color . "#e1e1e0"))
      initial-frame-alist default-frame-alist
      inhibit-splash-screen t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      use-dialog-box nil
      use-file-dialog nil
      use-short-answers t
      ring-bell-function 'ignore)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Elpaca manages packages; do not let package.el activate packages at startup.
(setq package-enable-at-startup nil)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

(defvar my-emacs--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1000 1000)
                  gc-cons-percentage 0.1
                  file-name-handler-alist my-emacs--file-name-handler-alist)))

;;; early-init.el ends here
