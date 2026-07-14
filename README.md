# Prabhanshu's emacs config maintenance notes (for AI assistants)

This directory is the user's `~/.emacs.d`. The user intends to maintain this
config **for life**, so changes should keep it small, readable, and durable.
The canonical user-facing doc is `README.md` — keep it in sync with `init.el`.

## User & intent

- macOS user, Emacs 30.x (built-in `treesit` + `eglot` required; Emacs 29+
  minimum).
- Returning-to-Emacs, now committing to it long-term.
- **Clojure is the daily language** → CIDER stack (not clojure-lsp).
- Other languages of interest: Swift, Rust, JS/TS, HTML/CSS.
- Preferences: minimal, explicit keybindings, prefer built-ins, one readable
  `init.el`, no `use-package`, no large wholesale config imports.

## Files

| File | Role |
|---|---|
| `init.el` | Whole config; read top to bottom. |
| `early-init.el` | Pre-package startup tweaks (GC, frame, no package.el). |
| `README.md` | User-facing docs (canonical). Keep in sync with `init.el`. |
| `AGENTS.md` | This file — conventions for AI assistants. |
| `.gitignore` | Keeps generated state out of git (`tree-sitter/`, `.cache/`, `.state/`, `transient/`). |

## Architecture summary (current `init.el`)

1. **Elpaca bootstrap** → `(elpaca name ...)` declarations; body runs after build.
2. `my-emacs-configure` — `condition-case` wrapper so one bad block can't abort startup.
3. Sane defaults + built-in modes (savehist, recentf, delete-selection, electric-pair, show-paren, which-key, visual-line).
4. macOS keybindings (Cmd arrows, Cmd-[/], Cmd-backspace, `C-c w` theme switcher).
5. Pointer/click support (context-menu, mouse-wheel, xterm-mouse, buttonized URLs).
6. Minibuffer completion via built-in `fido-vertical-mode` (NOT vertico).
7. **LSP:** `eglot` (built-in), auto-start in `prog-mode`, `eglot-server-programs`
   extended for `-ts-mode` names (Swift/Rust/TS/HTML/CSS). Clojure excluded.
8. **In-buffer completion:** `corfu` (auto popup) + `cape` (file/dabbrev backends).
9. `flymake` for diagnostics in eglot buffers.
10. `compat`/`transient` pinned + `elpaca-wait` before Magit (Magit needs newer than Emacs 30 ships).
11. `magit`, `projectile`, `treemacs` + `treemacs-projectile`.
12. `base16-theme` (materia) with hand-tuned mode-line faces.
13. **Tree-sitter:** `treesit-auto`, `treesit-auto-install t`, `treesit-font-lock-level 4`, grammars in `~/.emacs.d/tree-sitter/`.
14. `pi-coding-agent` (PATH amended for nvm; `exec-path-from-shell` copies `FIREWORKS_API_KEY`).
15. `markdown-mode`, `swift-ts-mode` (no built-in Swift mode).
16. **Clojure:** `clojure-mode` + `cider` + `paredit` + `flycheck`/`flycheck-clj-kondo`.
    Flycheck enabled ONLY in `clojure-mode-hook`; everything else stays on flymake.
17. `ediff` (plain windows, horizontal split).
18. Appearance: Be Vietnam Pro 16pt, Menlo fixed-pitch, transparent macOS title bar.

## Conventions for editing this config

### Adding a package
Add an `(elpaca name ...)` block in the matching `init.el` section. Do **not**
rely on `M-x package-install` for anything meant to persist — a clean
`~/.emacs.d/.cache/` wipe would lose it. Explain in the `README.md` feature
section why the package earns its maintenance cost.

### Adding a language
1. Highlighting: if Emacs has a built-in `foo-ts-mode`, `treesit-auto` handles
   it. If not, add a third-party mode from MELPA (like `swift-ts-mode`).
2. LSP/jump-to-def: install the server binary (brew/npm), then add an
   `eglot-server-programs` entry for the mode name.
3. For **Clojure specifically**: use CIDER, not LSP. Do not add clojure-lsp back.
4. Linting: prefer `flymake`. Only use `flycheck` where the tool's integration
   requires it (currently only clj-kondo for Clojure).

### Style
- Keep `init.el` readable: clear sections, short comments, explicit keybindings.
- No `use-package` (use `elpaca` forms + `with-eval-after-load`).
- Don't import large external configs wholesale; adapt ideas only.
- Keep `README.md` and `AGENTS.md` in sync with `init.el` after substantive changes.
- One focused commit per change ("Add CIDER for Clojure", not "misc updates").

## Keybindings (don't clobber these)
- `s-<up/down>` begin/end of buffer; `s-[/]` prev/next window;
  `s-<backspace>` kill whole line; `C-<backspace>` backward-kill-word.
- `C-c w` theme switcher; `s-p` projectile-find-file; `C-c p` projectile map.
- `C-c g/c/P` magit; `C-c t/T` treemacs.
- `C-z` intentionally unset.
- LSP: `M-.` / `M-,` / `M-?`; CIDER also uses `M-.` (REPL-backed).

## External toolchain (language servers / tools)

Install only for languages used. Emacs finds these on `PATH` automatically.

| Language | Tool | Install |
|---|---|---|
| Clojure | `clj-kondo` (linter) | `brew install clj-kondo` |
| Swift | `sourcekit-lsp` | comes with Xcode Command Line Tools |
| Rust | `rust-analyzer` | `brew install rust-analyzer` |
| TS/JS | `typescript-language-server` + `typescript` | `npm i -g typescript typescript-language-server` |
| HTML/CSS/JSON | `vscode-langservers-extracted` | `npm i -g vscode-langservers-extracted` |
| C/C++ | `clangd` | already at `/usr/bin/clangd` |
| any | `ripgrep` (project search) | `brew install ripgrep` |

Servers run as separate OS processes, lazily per language, shut down on last
buffer close (`eglot-autoshutdown`). Clojure uses CIDER, not a server.

## Known gotchas
- **GUI Emacs PATH:** doesn't inherit shell PATH. The nvm bin dir is added
  explicitly and `exec-path-from-shell` copies `FIREWORKS_API_KEY`. If a new
  language server isn't found, extend the PATH handling rather than expecting
  the user to set it.
- **Magit deps:** `compat` + `transient` must be pinned and `elpaca-wait`ed
  before Magit or it fails to load on Emacs 30.
- **No built-in mode for Swift/Clojure:** a package is unavoidable for these.
  Chose `swift-ts-mode` (tree-sitter) and `clojure-mode` (regex, CIDER-pairing).
- **`.cache/` vs `.state/`:** `.cache/` is disposable (Elpaca builds, eln-cache);
  `.state/` is session memory (recentf, savehist, custom.el). Both gitignored.

## Cleanup recipe for stubborn Elpaca builds
```sh
rm -rf ~/.emacs.d/.cache/elpaca/builds/<pkg> ~/.emacs.d/.cache/elpaca/sources/<pkg>
```
then restart Emacs. For a full reset: `rm -rf ~/.emacs.d/.cache` (grammars in
`~/.emacs.d/tree-sitter/` are preserved since they're outside `.cache/`).

## Maintenance recipes (agent reference)

### Add a package
`(elpaca name ...)` block in the matching `init.el` section, then restart.
Never rely on `M-x package-install` — it won't survive a clean `.cache/` wipe.

### Add a language
1. Highlighting: if Emacs has `foo-ts-mode` built in, `treesit-auto` handles
   it. If not, add a third-party mode from MELPA (e.g. `swift-ts-mode`) and
   an `auto-mode-alist` entry.
2. LSP: install the server binary (brew/npm), add an `eglot-server-programs`
   entry for the mode name.
3. Clojure: use CIDER, not LSP. Do not reintroduce clojure-lsp.
4. Linting: prefer `flymake`; only use `flycheck` where a tool's integration
   requires it (currently clj-kondo for Clojure, scoped to clojure-mode-hook).

### Update everything
```
M-x elpaca-update-all
M-x treesit-auto-install-all   ; refresh grammars
```

### Debugging
- Package didn't install → `M-x elpaca-manager`, check build log.
- No highlighting for language Y → `M-x treesit-ready-p RET Y RET`; nil =
  grammar didn't build, check `~/.emacs.d/tree-sitter/`.
- eglot won't connect → `M-: (executable-find "<server>")` must return a
  path in GUI Emacs. If nil, PATH isn't inherited — extend the nvm PATH line
  or `exec-path-from-shell`.
- Slow startup → `.cache/` and `.state/` grow; the `early-init.el` GC trick
  already speeds cold start; `rm -rf .cache` for a clean rebuild.

### Commit conventions
One focused commit per change ("Add CIDER for Clojure"). Keep `init.el`
readable. Keep `README.md` human-short; put agent-only detail here.
