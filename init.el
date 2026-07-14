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
      initial-scratch-message nil
      ;; *scratch* starts in org-mode instead of lisp-interaction
      initial-major-mode 'org-mode)

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
;; macOS-style: Cmd-backspace kills line, C-backspace kills word
;; Cmd-up/down goes to start/end of file
;; Note: angle brackets required for non-character keys

(keymap-global-set "s-<up>" #'beginning-of-buffer)
(keymap-global-set "s-<down>" #'end-of-buffer)

;; Window navigation with Cmd-[ and Cmd-]
(keymap-global-set "s-]" (lambda () (interactive) (other-window 1)))
(keymap-global-set "s-[" (lambda () (interactive) (other-window -1)))

;; Quick theme preview - disable current theme, load new one without prompts
(defun my-preview-theme (theme)
  "Disable current theme and load THEME without confirmation prompts."
  (interactive
   (list (intern (completing-read "Theme: "
                                   (mapcar #'symbol-name
                                           (custom-available-themes))))))
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme :no-confirm)
  (message "Loaded theme: %s" theme))

(keymap-global-set "C-c w" #'my-preview-theme)

(defun my-kill-whole-line-or-previous ()
  "Kill the current whole line.  If already on an empty line, move up first."
  (interactive)
  (if (looking-at-p "^[[:space:]]*$")
      (when (= (forward-line -1) 0)
        (kill-whole-line))
    (kill-whole-line)))

(keymap-global-set "s-<backspace>" #'my-kill-whole-line-or-previous)
(keymap-global-set "C-<backspace>" #'backward-kill-word)

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

;;; LSP via eglot (built into Emacs 30) + in-buffer completion (corfu/cape)
;; eglot connects to a per-language "language server" and provides:
;;   jump-to-definition  (M-.)
;;   find-references     (M-?)
;;   pop back            (M-,)
;;   rename symbol       (M-x eglot-rename)
;;   diagnostics         (flymake, shown in mode line + M-x flymake-show-buffer-diagnostics)
;;   completion-at-point (TAB / corfu popup)
;;
;; Start it automatically when opening a file in a language that has a server.
;; Silence the noisy "Connected" / "Disconnected" echoes.
(my-emacs-configure
  (setq eglot-autoshutdown t            ; stop server when last buffer closes
        eglot-events-buffer-size 0      ; no *eglot events* log spam
        ;; Send sync with the editor (completion etc.)
        eglot-send-changes-idle-time 0.3)
  ;; Tell eglot which server to launch for the tree-sitter (-ts-) major modes,
  ;; since eglot's defaults key off the classic (non-ts) mode names.
  (with-eval-after-load 'eglot
    (add-to-list 'eglot-server-programs
                 '((swift-ts-mode :language-id "swift") .
                   ("sourcekit-lsp")))
    (add-to-list 'eglot-server-programs
                 '((rust-ts-mode) . ("rust-analyzer")))
    (add-to-list 'eglot-server-programs
                 '((tsx-ts-mode typescript-ts-mode js-ts-mode js2-ts-mode)
                   . ("typescript-language-server" "--stdio")))
    (add-to-list 'eglot-server-programs
                 '((html-ts-mode) . ("vscode-html-language-server" "--stdio")))
    (add-to-list 'eglot-server-programs
                 '((css-ts-mode) . ("vscode-css-language-server" "--stdio"))))
  ;; Bind eglot's events so they don't echo in the echo area.
  (fset 'eglot--message #'message)
  ;; Auto-start eglot in prog modes (it no-ops if no server is configured).
  (add-hook 'prog-mode-hook #'eglot-ensure))

;; Corfu: completion popup at point. Cape: completion backends/adapters
;; (e.g. `cape-file' so you get path completion too).
(elpaca corfu
  (global-corfu-mode 1)
  (setq corfu-auto t                 ; popup as you type
        corfu-auto-delay 0.15
        corfu-auto-prefix 2
        corfu-cycle t                 ; TAB cycles candidates
        corfu-quit-no-match 'separator
        corfu-preview-current 'insert)
  ;; TAB completes, S-TAB cycles backward, RET accepts.
  (keymap-set corfu-map "RET" #'corfu-send)
  (keymap-set corfu-map "TAB" #'corfu-insert)
  ;; No auto-popup while writing prose (org, markdown, etc.);
  ;; M-TAB still completes on demand.
  (add-hook 'text-mode-hook (lambda () (setq-local corfu-auto nil))))

(elpaca cape
  (require 'cape)
  ;; Merge LSP (eglot) + file + dabbrev completions.
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; Built-in Flymake for diagnostics (eglot feeds it). Nice UI in the mode line.
(my-emacs-configure
  (setq eldoc-echo-area-use-multiline-p 3)
  (add-hook 'eglot-managed-mode-hook #'flymake-mode))

;; Magit's current dependency chain wants a newer `compat' than the one
;; bundled with Emacs 30.  Install it explicitly before Magit so Elpaca
;; does not try to satisfy the dependency with the built-in copy.
(elpaca compat)
(elpaca transient)
(elpaca-wait)

(elpaca magit
  (keymap-global-set "C-c g" #'magit-status)
  (keymap-global-set "C-c c" #'magit-commit-create)
  (keymap-global-set "C-c P" #'magit-push-current-to-upstream)
  (with-eval-after-load 'magit
    (setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)))

(elpaca projectile
  (projectile-mode 1)
  (setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" my-emacs-state-directory)
        projectile-project-search-path '("~")
        projectile-completion-system 'default
        ;; After picking a project, go straight to its file list
        projectile-switch-project-action #'projectile-find-file)
  ;; Projectile never scans for projects on its own — populate the list by
  ;; scanning the search path shortly after startup. Visited projects float
  ;; to the top (MRU), so s-p behaves like autojump: recent first, type to
  ;; flex-narrow.
  (run-with-idle-timer 0.5 nil #'projectile-discover-projects-in-search-path)
  (keymap-global-set "C-c p" projectile-command-map)
  ;; macOS Cmd+P: files in current project, or project picker when
  ;; outside any project (e.g. fresh startup in *scratch*)
  (defun my-projectile-find-file-dwim ()
    "Find file in project; if not in a project, pick one first."
    (interactive)
    (if (projectile-project-p)
        (projectile-find-file)
      (projectile-switch-project)))
  (keymap-global-set "s-p" #'my-projectile-find-file-dwim))

(elpaca treemacs
  (setq treemacs-persist-file (expand-file-name "treemacs-persist" my-emacs-state-directory)
        treemacs-width 32
        treemacs-position 'left
        treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-project-follow-cleanup t
        ;; Mouse-friendly settings
        treemacs-doubleclick-to-toggle-node t
        treemacs-click-will-visit-file t
        treemacs-migrate-marks-on-rename t)
  (keymap-global-set "C-c t" #'treemacs)
  (keymap-global-set "C-c T" #'treemacs-select-window)
  (with-eval-after-load 'treemacs
    (treemacs-project-follow-mode 1)
    (treemacs-follow-mode 1)
    (treemacs-filewatch-mode 1)
    ;; Better mouse behavior - single click to open, double to toggle dirs
    (define-key treemacs-mode-map [mouse-1] #'treemacs-leftclick-action)
    (define-key treemacs-mode-map [double-mouse-1] #'treemacs-doubleclick-action)))

(elpaca treemacs-projectile
  (with-eval-after-load 'treemacs
    (require 'treemacs-projectile)))

;; Theme: port of my VS Code (Dark 2026 + settings.json customizations).
;; Flat, minimal — no boxes or extra decoration.
(my-emacs-configure
  (add-to-list 'custom-theme-load-path
               (expand-file-name "themes/" user-emacs-directory))
  (load-theme 'vscode-dark-2026 :no-confirm))

;; Bracket/paren pair colors, cycling through VS Code's six bracket colors
;; (defined in the theme).
(elpaca rainbow-delimiters
  (setq rainbow-delimiters-max-face-count 6)
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;;; Tree-sitter for modern syntax highlighting
;; Tell Emacs where grammars are installed
(setq treesit-extra-load-path
      (list (expand-file-name "tree-sitter" user-emacs-directory)))

;; Enable font-lock everywhere and crank it to maximum decoration.
;; This covers both classic regex-based major modes and tree-sitter modes.
(setq font-lock-maximum-decoration t)
(global-font-lock-mode 1)

(elpaca treesit-auto
  (require 'treesit-auto)
  ;; Auto-use Tree-sitter modes when grammars exist, fallback otherwise.
  ;; Install missing grammars automatically (no prompt) so every language
  ;; gets tree-sitter highlighting the first time you open a file.
  (setq treesit-auto-install t)
  ;; Maximum tree-sitter fontification: operators, delimiters, all
  ;; functions/variables/properties, not just keywords and strings.
  (setq treesit-font-lock-level 4)
  (global-treesit-auto-mode 1))

;; pi-coding-agent - Emacs frontend for the pi coding agent
;; Add nvm's pi location to PATH (GUI Emacs doesn't inherit shell PATH)
(add-to-list 'exec-path "/Users/prabhanshu/.nvm/versions/node/v25.5.0/bin")
(setenv "PATH" (concat "/Users/prabhanshu/.nvm/versions/node/v25.5.0/bin:" (getenv "PATH")))

;; Inherit shell environment variables (API keys from zshrc).
;; The shell launch costs ~500ms, so do it once and cache the result;
;; later startups just load the cache (instant). Delete the cache file
;; if the key ever changes.
(defvar my-env-cache-file (expand-file-name "env-cache.el" my-emacs-state-directory))
(if (file-exists-p my-env-cache-file)
    (load my-env-cache-file :no-error :no-message)
  (elpaca exec-path-from-shell
    (run-with-idle-timer 1 nil
                         (lambda ()
                           (exec-path-from-shell-copy-env "FIREWORKS_API_KEY")
                           (when-let* ((key (getenv "FIREWORKS_API_KEY")))
                             (with-temp-file my-env-cache-file
                               (insert (format "(setenv \"FIREWORKS_API_KEY\" %S)\n" key))))))))

(elpaca pi-coding-agent
  ;; Requires the `pi` CLI to be installed:
  ;; npm install -g @mariozechner/pi-coding-agent
  ;; M-x pi-coding-agent to start a session
  (with-eval-after-load 'pi-coding-agent
    ;; Alias 'pi to 'pi-coding-agent for quick access
    (defalias 'pi 'pi-coding-agent)))

;; Markdown mode (no built-in markdown-ts-mode yet, use traditional mode)
(elpaca markdown-mode
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode)))

;; Swift: Emacs has no built-in Swift mode.  `swift-ts-mode' provides a
;; tree-sitter major mode that uses the grammar in ~/.emacs.d/tree-sitter/.
(elpaca swift-ts-mode
  (add-to-list 'auto-mode-alist '("\\.swift\\'" . swift-ts-mode)))

;; swift-ts-mode paints @attributes (@Published, @MainActor) with the type
;; face, which the theme leaves uncolored. Override them to keyword blue,
;; matching VS Code's storage.modifier color.
(defun my-swift-ts-blue-attributes ()
  "Fontify Swift attribute nodes with the keyword face."
  (setq-local treesit-font-lock-settings
              (append treesit-font-lock-settings
                      (treesit-font-lock-rules
                       :language 'swift
                       :feature 'keyword
                       :override t
                       '((attribute) @font-lock-keyword-face))))
  (treesit-font-lock-recompute-features))
(add-hook 'swift-ts-mode-hook #'my-swift-ts-blue-attributes)

;;; Clojure (daily language): clojure-mode + CIDER REPL + paredit + clj-kondo
;; Emacs has no built-in Clojure mode, so we install `clojure-mode' (the
;; battle-tested regex major mode, used by every serious Clojure setup).
;; CIDER gives an interactive nREPL: eval forms, jump to definitions,
;; inspect docs, debug.  Paredit gives structured editing of parentheses.
;; clj-kondo is the standard Clojure linter (requires the `clj-kondo' CLI).
(elpaca clojure-mode
  (add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-mode))
  (add-to-list 'auto-mode-alist '("\\.cljs\\'" . clojure-mode))
  (add-to-list 'auto-mode-alist '("\\.cljc\\'" . clojure-mode))
  (add-to-list 'auto-mode-alist '("\\.cljd\\'" . clojure-mode))
  (add-to-list 'auto-mode-alist '("\\.edn\\'" . clojure-mode)))

(elpaca cider
  (with-eval-after-load 'cider
    (setq cider-repl-display-in-current-window t
          cider-repl-use-pretty-printing t
          cider-font-lock-dynamically t ; highlight symbols from the REPL
          cider-save-file-on-load        'always
          cider-print-fn                 'fipp)))

;; Paredit: structured paren editing for Lisps.
(elpaca paredit
  (dolist (hook '(clojure-mode-hook
                  emacs-lisp-mode-hook
                  lisp-mode-hook
                  lisp-interaction-mode-hook))
    (add-hook hook #'enable-paredit-mode)))

;; clj-kondo linting in Clojure buffers (requires `brew install clj-kondo').
;; We use flycheck ONLY for Clojure; other languages stay on flymake via eglot.
(elpaca flycheck
  (with-eval-after-load 'flycheck
    (require 'flycheck-clj-kondo)
    (add-to-list 'flycheck-checkers 'clojure-joker-kondo)))
(elpaca flycheck-clj-kondo)
(add-hook 'clojure-mode-hook #'flycheck-mode)

;;; Ediff (built-in diff merge tool)
(my-emacs-configure
  ;; Set up window behavior before ediff loads
  (setq ediff-split-window-function #'split-window-horizontally
        ediff-window-setup-function #'ediff-setup-windows-plain)
  ;; Configure after ediff loads
  (with-eval-after-load 'ediff
    (setq ediff-keep-variants nil
          ediff-make-buffers-readonly-at-startup nil
          ediff-merge-revisions-with-ancestor t
          ediff-show-clashes-only t)))

;;; Appearance
;; Minimal modeline: modified dot and buffer name. Nothing else.
(setq-default mode-line-format
              '("  "
                (:eval (if (buffer-modified-p) "• " "  "))
                mode-line-buffer-id))

;; Line numbers in the left gutter, like VS Code — always on, everywhere,
;; except UI buffers where they're noise.
(setq-default display-line-numbers-width 3)
(global-display-line-numbers-mode 1)
(dolist (hook '(treemacs-mode-hook dired-mode-hook magit-mode-hook
                help-mode-hook messages-buffer-mode-hook))
  (add-hook hook (lambda () (display-line-numbers-mode -1))))

(my-emacs-configure
  ;; macOS transparent title bar
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  ;; Font: Be Vietnam Pro at 160 (16pt)
  (add-to-list 'default-frame-alist '(font . "Be Vietnam Pro-16"))
  (set-face-attribute 'default nil :family "Be Vietnam Pro" :height 160)
  ;; Use an actual monospace font for fixed-pitch contexts (code, dired tables)
  (set-face-attribute 'fixed-pitch nil :family "Menlo" :height 160)
  ;; Force Dired to use monospace so columns align properly
  (add-hook 'dired-mode-hook
            (lambda ()
              (setq buffer-face-mode-face 'fixed-pitch)
              (buffer-face-mode 1)))
  ;; Apply to current frame if already exists
  (when (display-graphic-p)
    (set-frame-font "Be Vietnam Pro-16" nil t)))

(provide 'init)
;;; init.el ends here
