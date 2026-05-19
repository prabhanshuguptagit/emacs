;;; init.el --- Minimal Emacs configuration -*- lexical-binding: t; -*-

;;; Foundations

;; Elpaca package manager.
;; This is the standard bootstrap.  It clones Elpaca on first startup,
;; then uses it for package installation/update/builds.
(defvar elpaca-installer-version 0.12)
(defvar my-emacs-cache-directory
  (expand-file-name ".cache/" user-emacs-directory)
  "Directory for disposable Emacs cache/build files.")

(defvar my-emacs-state-directory
  (expand-file-name ".state/" user-emacs-directory)
  "Directory for persistent Emacs state files.")

(dolist (directory (list my-emacs-cache-directory my-emacs-state-directory))
  (make-directory directory t))

(defvar elpaca-directory (expand-file-name "elpaca/" my-emacs-cache-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order
  '(elpaca :repo "https://github.com/progfolio/elpaca.git"
           :ref nil
           :depth 1
           :inherit ignore
           :files (:defaults "elpaca-test.el" (:exclude "extensions"))
           :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28)
      (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil))
      (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)

(setq elpaca-queue-limit 30)
(setq elpaca-menu-functions '(elpaca-menu-melpa elpaca-menu-gnu-elpa elpaca-menu-nongnu-elpa))

(defmacro my-emacs-configure (&rest body)
  "Evaluate BODY and report errors without aborting startup."
  (declare (indent 0))
  `(condition-case err
       (progn ,@body)
     ((error user-error)
      (message "Configuration error near `%S': %S" (car ',body) err))))

;; Keep generated Custom settings out of init.el.
(setq custom-file (expand-file-name "custom.el" my-emacs-state-directory))
(load custom-file :no-error :no-message)

;; Sane defaults.
(setq make-backup-files nil
      create-lockfiles nil
      backup-inhibited nil
      recentf-save-file (expand-file-name "recentf" my-emacs-state-directory)
      savehist-file (expand-file-name "savehist" my-emacs-state-directory)
      save-place-file (expand-file-name "saveplace" my-emacs-state-directory)
      initial-buffer-choice t
      initial-scratch-message nil)

(setq-default indent-tabs-mode nil
              tab-width 4
              truncate-lines t)

(savehist-mode 1)
(recentf-mode 1)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(which-key-mode 1)
(global-visual-line-mode 1)

(keymap-global-unset "C-z")
;; macOS-style Cmd-backspace to kill whole line
(keymap-global-set "s-DEL" #'kill-whole-line)

;;; Pointer/click support
(my-emacs-configure
  (context-menu-mode 1)
  (mouse-wheel-mode 1)
  (xterm-mouse-mode 1) ; useful if Emacs runs in a terminal
  (setq mouse-1-click-follows-link t
        mouse-wheel-scroll-amount '(1 ((shift) . 5) ((control) . text-scale))
        mouse-wheel-progressive-speed nil
        mouse-wheel-follow-mouse t
        mouse-drag-copy-region nil
        make-pointer-invisible t)
  ;; Make buttons/widgets feel like modern GUI links.
  (with-eval-after-load 'button
    (define-key button-map [mouse-1] #'push-button))
  (with-eval-after-load 'wid-edit
    (define-key widget-keymap [mouse-1] #'widget-button-click))
  ;; Plain URLs become clickable in text/prog buffers.
  (add-hook 'text-mode-hook #'goto-address-mode)
  (add-hook 'prog-mode-hook #'goto-address-prog-mode))

;;; Completion (built-in, minimal)
(my-emacs-configure
  (setq completion-styles '(basic substring partial-completion flex)
        completion-category-defaults nil
        completion-ignore-case t
        read-buffer-completion-ignore-case t
        read-file-name-completion-ignore-case t)
  (minibuffer-depth-indicate-mode 1)
  (minibuffer-electric-default-mode 1)
  ;; Built-in vertical completions for M-x, file names, buffers, etc.
  (fido-vertical-mode 1))

;;; Packages you asked for

;; Magit's current dependency chain wants a newer `compat' than the one
;; bundled with Emacs 30.  Install it explicitly before Magit so Elpaca
;; does not try to satisfy the dependency with the built-in copy.
(elpaca compat)
(elpaca transient)
(elpaca-wait)

(elpaca magit
  (keymap-global-set "C-c g" #'magit-status)
  (with-eval-after-load 'magit
    (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)))

(elpaca projectile
  (projectile-mode 1)
  (setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" my-emacs-state-directory)
        projectile-project-search-path '("~")
        projectile-completion-system 'default
        projectile-switch-project-action #'projectile-dired)
  (define-key global-map (kbd "C-c p") projectile-command-map)
  )

(elpaca treemacs
  (setq treemacs-persist-file (expand-file-name "treemacs-persist" my-emacs-state-directory)
        treemacs-width 32
        treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-project-follow-cleanup t)
  (keymap-global-set "C-c t" #'treemacs)
  (keymap-global-set "C-c T" #'treemacs-select-window)
  (with-eval-after-load 'treemacs
    (treemacs-project-follow-mode 1)
    (treemacs-follow-mode 1)
    (treemacs-filewatch-mode 1)))

(elpaca treemacs-projectile
  (with-eval-after-load 'treemacs
    (require 'treemacs-projectile)))

;;; Appearance
(my-emacs-configure
  ;; A comfortable size above Emacs' usual 10pt default.
  (set-face-attribute 'default nil :height 150)
  (load-theme 'misterioso :no-confirm))

(provide 'init)
;;; init.el ends here
