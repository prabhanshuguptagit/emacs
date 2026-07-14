;;; vscode-dark-2026-theme.el --- Match my VS Code (Dark 2026 + customizations) -*- lexical-binding: t; -*-

;; Palette sources:
;;   - workbench.colorCustomizations / editor.tokenColorCustomizations
;;     from VS Code settings.json
;;   - Dark 2026 defaults for tokens the overrides don't cover
;;     (functions #d2a8ff, parameters #ffa657, types/tags #7ee787,
;;      attributes #9cdcfe, numbers/constants #79c0ff)

;;; Code:

(deftheme vscode-dark-2026
  "Faithful port of my VS Code setup: Dark 2026 base with custom token colors.")

(let ((bg        "#2d3743")  ; editor.background
      (fg        "#DCDCCC")  ; editor.foreground
      (keyword   "#75c7f3")  ; keyword/storage/tag/constant.language override
      (string    "#d39864")  ; string override
      (comment   "#73ab59")  ; comment override
      (func      "#d2a8ff")  ; Dark 2026 functions
      (param     "#ffa657")  ; Dark 2026 parameters
      (type      "#7ee787")  ; Dark 2026 types/tags
      (attr      "#9cdcfe")  ; Dark 2026 HTML attributes
      (num       "#79c0ff")  ; Dark 2026 numbers/constants
      (cssprop   "#b3bc71")  ; support.type.property-name override
      (cursor    "#ff6296")  ; editorCursor.foreground
      (hlline    "#333333")  ; editor.lineHighlightBackground
      (selection "#3c5a58")  ; editor.selectionBackground #30918245 flattened onto bg
      (linenum   "#5e6469")  ; editorLineNumber.foreground
      (linenum-a "#b2b3aa")  ; editorLineNumber.activeForeground
      (panel-bg  "#212225")  ; sideBar/statusBar.background
      (panel-fg  "#b2b3aa")  ; sideBar/statusBar.foreground
      (widget-bg "#2e2f34")  ; hover widget / list hover
      (sel-fg    "#d8d8d8")  ; list selection foreground
      (accent    "#59776b")  ; badge/button green
      (err       "#ab5855")  ; editorError.foreground
      (warn      "#e6c18a")  ; editorWarning.foreground
      (match-bg  "#59776b")) ; find match highlight

  (custom-theme-set-faces
   'vscode-dark-2026

   ;; Core
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,cursor))))
   `(region ((t (:background ,selection :extend t))))
   `(highlight ((t (:background ,widget-bg))))
   `(hl-line ((t (:background ,hlline :extend t))))
   `(fringe ((t (:background ,bg))))
   `(shadow ((t (:foreground ,linenum))))
   `(minibuffer-prompt ((t (:foreground ,keyword))))
   `(link ((t (:foreground ,attr :underline t))))
   `(link-visited ((t (:foreground ,func :underline t))))
   `(escape-glyph ((t (:foreground ,keyword))))
   `(error ((t (:foreground ,err))))
   `(warning ((t (:foreground ,warn))))
   `(success ((t (:foreground ,comment))))
   `(match ((t (:background ,match-bg :foreground ,sel-fg))))
   `(isearch ((t (:background ,match-bg :foreground "#ecf0f5"))))
   `(lazy-highlight ((t (:background "#3e5249"))))
   `(show-paren-match ((t (:background "#4a5a68" :weight bold))))
   `(show-paren-mismatch ((t (:background ,err :foreground ,fg))))
   `(trailing-whitespace ((t (:background ,err))))

   ;; Font-lock — the part that makes code look like VS Code
   `(font-lock-keyword-face ((t (:foreground ,keyword))))
   `(font-lock-builtin-face ((t (:foreground ,keyword))))
   `(font-lock-preprocessor-face ((t (:foreground ,keyword))))
   `(font-lock-string-face ((t (:foreground ,string))))
   `(font-lock-doc-face ((t (:foreground ,comment))))
   `(font-lock-comment-face ((t (:foreground ,comment))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,comment))))
   `(font-lock-function-name-face ((t (:foreground ,fg))))
   `(font-lock-function-call-face ((t (:foreground ,fg))))
   `(font-lock-type-face ((t (:foreground ,fg))))
   `(font-lock-constant-face ((t (:foreground ,keyword))))
   `(font-lock-number-face ((t (:foreground ,num))))
   `(font-lock-variable-name-face ((t (:foreground ,fg))))
   `(font-lock-variable-use-face ((t (:foreground ,fg))))
   `(font-lock-property-name-face ((t (:foreground ,fg))))
   `(font-lock-property-use-face ((t (:foreground ,fg))))
   `(font-lock-operator-face ((t (:foreground ,fg))))
   `(font-lock-punctuation-face ((t (:foreground ,fg))))
   `(font-lock-bracket-face ((t (:foreground ,fg))))
   `(font-lock-delimiter-face ((t (:foreground ,fg))))
   `(font-lock-escape-face ((t (:foreground ,keyword))))
   `(font-lock-misc-punctuation-face ((t (:foreground ,fg))))
   `(font-lock-negation-char-face ((t (:foreground ,fg))))
   `(font-lock-regexp-face ((t (:foreground ,string))))
   `(font-lock-warning-face ((t (:foreground ,warn))))

   ;; Line numbers (gutter)
   `(line-number ((t (:foreground ,linenum :background ,bg))))
   `(line-number-current-line ((t (:foreground ,linenum-a :background ,hlline))))

   ;; Mode line — flat, like the VS Code status bar
   `(mode-line ((t (:background ,panel-bg :foreground ,panel-fg :box nil))))
   `(mode-line-inactive ((t (:background "#29323c" :foreground ,linenum :box nil))))
   `(mode-line-highlight ((t (:background ,accent :foreground "#ecf0f5"))))
   `(mode-line-emphasis ((t (:foreground ,sel-fg :weight bold))))
   `(mode-line-buffer-id ((t (:foreground ,sel-fg :weight bold))))

   ;; Completion (fido/icomplete, corfu)
   `(icomplete-selected-match ((t (:background ,widget-bg :foreground ,sel-fg :weight bold))))
   `(completions-common-part ((t (:foreground ,sel-fg :weight bold))))
   `(completions-first-difference ((t (:foreground ,fg))))
   `(corfu-default ((t (:background ,panel-bg :foreground ,panel-fg))))
   `(corfu-current ((t (:background ,widget-bg :foreground ,sel-fg))))
   `(corfu-border ((t (:background ,widget-bg))))
   `(corfu-bar ((t (:background ,linenum))))

   ;; Bracket pair colors — editorBracketHighlight.foreground1..6
   `(rainbow-delimiters-depth-1-face ((t (:foreground "#5caeef"))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground "#dfb976"))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground "#47b18e"))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground "#4fb1bc"))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground "#d88bb7"))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground "#abb2c0"))))
   `(rainbow-delimiters-unmatched-face ((t (:foreground ,err :weight bold))))

   ;; Flymake / diagnostics
   `(flymake-error ((t (:underline (:style wave :color ,err)))))
   `(flymake-warning ((t (:underline (:style wave :color ,warn)))))
   `(flymake-note ((t (:underline (:style wave :color ,accent)))))
   `(eglot-highlight-symbol-face ((t (:background "#3a4450"))))

   ;; Treemacs / dired
   `(treemacs-root-face ((t (:foreground ,panel-fg :weight bold))))
   `(treemacs-directory-face ((t (:foreground ,panel-fg))))
   `(treemacs-file-face ((t (:foreground ,panel-fg))))
   `(treemacs-git-untracked-face ((t (:foreground "#6aa389"))))
   `(dired-directory ((t (:foreground ,keyword))))

   ;; Magit / diffs
   `(diff-added ((t (:foreground "#6cc244"))))
   `(diff-removed ((t (:foreground "#e85c52"))))
   `(magit-diff-added ((t (:foreground "#6cc244" :background unspecified))))
   `(magit-diff-removed ((t (:foreground "#e85c52" :background unspecified))))
   `(magit-diff-added-highlight ((t (:foreground "#6cc244" :background ,hlline))))
   `(magit-diff-removed-highlight ((t (:foreground "#e85c52" :background ,hlline))))
   `(magit-section-heading ((t (:foreground ,keyword :weight bold))))
   `(magit-branch-local ((t (:foreground ,attr))))
   `(magit-branch-remote ((t (:foreground ,type))))

   ;; Markdown / org headings — blue + bold like markup.heading
   `(markdown-header-face ((t (:foreground ,keyword :weight bold))))
   `(org-level-1 ((t (:foreground ,keyword :weight bold))))
   `(org-level-2 ((t (:foreground ,keyword :weight bold))))
   `(outline-1 ((t (:foreground ,keyword :weight bold))))
   `(outline-2 ((t (:foreground ,keyword :weight bold))))))

(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'vscode-dark-2026)
;;; vscode-dark-2026-theme.el ends here
