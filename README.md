# prabhanshu's emacs

A small, durable Emacs configuration built on **Elpaca**, **tree-sitter**,
and (for Clojure) **CIDER**. The goal is a setup that's small enough to hold
in your head and maintain for life.

- **Platform:** macOS (works elsewhere with minor PATH tweaks)
- **Emacs:** 29+ (built-in `treesit` and `eglot` required); developed on 30.x
- **Package manager:** [Elpaca](https://github.com/progfolio/elpaca)
- **Philosophy:** prefer built-ins, explicit keybindings, clear sections,
  one file (`init.el`) you can read top to bottom.

---

## Quick start

```bash
git clone https://github.com/prabhanshuguptagit/emacs.git ~/.emacs.d
```

First launch: open Emacs. Elpaca bootstraps itself, then downloads and builds
every package listed in `init.el`. This takes a minute or two and only happens
once. Tree-sitter grammars compile automatically (via the system C compiler)
the first time you open a file of each language.

Install the external language tools you actually use (see
[Toolchain](#external-toolchain)):

```bash
brew install clj-kondo rust-analyzer
npm install -g typescript typescript-language-server vscode-langservers-extracted
```

Then `M-x cider-jack-in` in a Clojure project, or just open a file in any
language and start editing.

---

## Directory layout

Everything lives under `~/.emacs.d/`. Generated/ephemeral state is kept out of
git (see `.gitignore`) so the repo stays clean.

| Path | Purpose | Tracked? |
|---|---|---|
| `init.el` | The whole configuration. Read it top to bottom. | ✅ |
| `early-init.el` | Pre-package-load startup tweaks (frame, GC, garbage). | ✅ |
| `README.md` | This file — user-facing docs. | ✅ |
| `AGENTS.md` | Notes for AI assistants working on this config. | ✅ |
| `tree-sitter/` | Compiled grammar `.dylib`s (auto-built). | ❌ gitignored |
| `.cache/` | Disposable caches, Elpaca sources/builds, eln-cache. | ❌ gitignored |
| `.state/` | Persistent state: recentf, savehist, saveplace, custom.el. | ❌ gitignored |
| `transient/` | transient (Magit menus) history. | ❌ gitignored |

### Why split cache vs state

- `.cache/` can be deleted freely; it's rebuilt from `init.el` + the network.
- `.state/` is your session memory (recent files, minibuffer history, custom
  theme tweaks). Worth keeping across machines but intentionally not committed
  because it's machine-specific.

---

## Package management: Elpaca

`init.el` bootstraps Elpaca on first run. Packages are declared with the
`elpaca` form:

```elisp
(elpaca magit
  (keymap-global-set "C-c g" #'magit-status)
  ...)
```

The body runs after the package is built. To add a package, add an
`(elpaca name ...)` block in the right section and restart Emacs — Elpaca
installs it permanently. (See [Maintenance recipes](#maintenance-recipes).)

Two helpers wrap configuration so a single package's failure can't abort
startup:

- `my-emacs-configure` — `condition-case` around a block of config.
- `elpaca-wait` is used once (after `compat`/`transient`) so Magit's
  dependencies are ready before Magit loads.

---

## Features

### Syntax highlighting (tree-sitter)

Emacs 29+ has tree-sitter built in. We use [`treesit-auto`](https://github.com/emacs-tree-sitter/treesit-auto)
to auto-select `*-ts-mode` versions of major modes and auto-install grammars
into `~/.emacs.d/tree-sitter/`.

```elisp
(setq treesit-auto-install t        ; silently build grammars on demand
      treesit-font-lock-level 4)    ; max highlighting: operators, etc.
(global-treesit-auto-mode 1)
```

Built-in `-ts-mode`s cover ~20 languages out of the box (bash, c, cpp, css,
html, java, js, json, python, rust, toml, tsx, typescript, yaml, ...).

**Languages with no built-in mode** (Swift) get a third-party tree-sitter
mode from MELPA: `swift-ts-mode`.

### Jump-to-definition / LSP (eglot)

[`eglot`](https://joaotavora.github.io/eglot/) (built into Emacs 30) is the
LSP client. It auto-starts in every `prog-mode` buffer that has a configured
language server. Each server is a separate external program (see
[Toolchain](#external-toolchain)); eglot launches it on demand and shuts it
down when you close the last buffer (`eglot-autoshutdown`).

`eglot-server-programs` is extended for the tree-sitter `-ts-mode` names,
since eglot's defaults key off the classic mode names.

> **Note:** Clojure does **not** use eglot/LSP here. It uses CIDER (below).

### In-buffer completion (corfu + cape)

- [`corfu`](https://github.com/minad/corfu) — popup completion at point,
  auto-shown as you type (`corfu-auto t`). `TAB` cycles, `RET` accepts.
- [`cape`](https://github.com/minad/cape) — extra backends: file paths
  (`cape-file`) and word-from-buffer (`cape-dabbrev`).
- LSP completions flow through `completion-at-point` automatically.

The minibuffer still uses built-in `fido-vertical-mode` (vertical
`*Completions*` for `M-x`, buffers, files) — no Vertico/Consult stack.

### Clojure (daily language) — CIDER

The canonical Clojure stack, all from MELPA:

| Package | Role |
|---|---|
| `clojure-mode` | Major mode + regex font-lock (battle-tested). |
| `cider` | Interactive nREPL: eval, docs, navigation, debug. |
| `paredit` | Structured paren editing in all Lisps. |
| `flycheck` + `flycheck-clj-kondo` | Lint via `clj-kondo` (Clojure only). |

`M-x cider-jack-in` (`C-c M-j` in a Clojure buffer) starts the REPL. From
there: `C-c C-k` eval the top-level form, `C-c C-d d` docs, `M-.` jump to
definition (CIDER provides its own xref backend for the running REPL).

We deliberately do **not** use `clojure-lsp` for Clojure — CIDER's REPL-backed
navigation/refactoring is richer for a daily language. `clojure-ts-mode` was
tried and dropped in favor of `clojure-mode` (the CIDER-pairing that everyone
runs). The tree-sitter Clojure grammar still sits in `tree-sitter/` if you
ever want to switch back.

Flycheck is enabled **only in `clojure-mode`**; every other language stays on
built-in `flymake` (fed by eglot). This keeps one diagnostic system per
language and avoids double-squiggles.

### Git — Magit

| Key | Action |
|---|---|
| `C-c g` | `magit-status` |
| `C-c c` | commit |
| `C-c P` | push current to upstream |

`compat` and `transient` are pinned first because Magit needs newer versions
than Emacs 30 ships.

### Project navigation — Projectile + Treemacs

| Key | Action |
|---|---|
| `s-p` (Cmd+P) | projectile find file ("Quick Open") |
| `C-c p` | projectile command map |
| `C-c t` | toggle Treemacs |
| `C-c T` | select Treemacs window |

`projectile-project-search-path` is `("~")` — adjust if you keep projects in
specific folders.

### Themes & fonts

- Theme: `base16-materia` (Nord-like), with hand-tuned mode-line faces.
- `C-c w` — live theme switcher (disables current, loads chosen, no prompts).
- Default font: **Be Vietnam Pro 16pt**; fixed-pitch (code/Dired): **Menlo**.
- macOS transparent title bar, dark appearance.

### Ediff

Plain-window, side-by-side diffs (`ediff-setup-windows-plain`,
`split-window-horizontally`). No separate frame per diff.

### pi coding agent

`M-x pi` (aliased) launches the [pi](https://github.com/earendil-works/pi-coding-agent)
coding agent inside Emacs. PATH is amended so GUI Emacs finds the `node`/`pi`
binaries under nvm, and `exec-path-from-shell` copies `FIREWORKS_API_KEY`
from your shell.

---

## External toolchain

These are the only things `init.el` can't install for you. Install just the
ones for languages you use. Emacs finds them on `PATH` automatically (GUI Emacs
inherits PATH via the nvm entry + `exec-path-from-shell`).

| Language | Server / tool | Install |
|---|---|---|
| Clojure | `clj-kondo` (linter) | `brew install clj-kondo` |
| Clojure | nREPL deps (cider-nrepl) | handled by CIDER on jack-in |
| Swift | `sourcekit-lsp` | included with Xcode Command Line Tools |
| Rust | `rust-analyzer` | `brew install rust-analyzer` |
| TS/JS | `typescript-language-server` + `typescript` | `npm i -g typescript typescript-language-server` |
| HTML/CSS/JSON | `vscode-langservers-extracted` | `npm i -g vscode-langservers-extracted` |
| C/C++ | `clangd` | already at `/usr/bin/clangd` |
| (any) | `ripgrep` (project search) | `brew install ripgrep` |

Servers run as **separate OS processes**, started lazily per language, shut
down when you close the last buffer. Emacs itself stays fast; you only pay
RAM for languages you're actively editing. (See `eglot-autoshutdown`.)

---

## Keybindings reference

### Global

| Key | Action |
|---|---|
| `s-<up>` / `s-<down>` | beginning / end of buffer |
| `s-]` / `s-[` | next / previous window |
| `s-<backspace>` | kill whole line (or previous if empty) |
| `C-<backspace>` | backward kill word |
| `C-c w` | theme switcher |
| `C-z` | (unset) |

### Project / git / tree

| Key | Action |
|---|---|
| `s-p` | projectile find file |
| `C-c p` | projectile prefix |
| `C-c g` / `C-c c` / `C-c P` | magit status / commit / push |
| `C-c t` / `C-c T` | treemacs toggle / select |

### LSP / xref (when eglot is active)

| Key | Action |
|---|---|
| `M-.` | jump to definition |
| `M-,` | pop back |
| `M-?` | find references |
| `M-x eglot-rename` | rename symbol |
| `C-h .` | eldoc for symbol at point |
| `M-x flymake-show-buffer-diagnostics` | list diagnostics |

### Corfu (completion popup)

| Key | Action |
|---|---|
| auto | pops up while typing |
| `TAB` | cycle / insert |
| `RET` | accept |

### Clojure / CIDER (in `clojure-mode`)

| Key | Action |
|---|---|
| `C-c M-j` | `cider-jack-in` (start REPL) |
| `C-c C-k` | eval top-level form |
| `C-c C-d d` | doc for symbol at point |
| `M-.` / `M-,` | jump to def / pop back (REPL-backed) |
| `M-x cider` | browse CIDER commands |

---

## Maintenance recipes

This section is the "for life" part — how to keep the config honest.

### Add a package

Add an `(elpaca name ...)` block in `init.el` under the matching section,
then restart Emacs. Elpaca installs it permanently. Never rely on
`M-x package-install` for things you want to keep — it won't survive a clean
`.cache/` wipe.

### Add a new language

1. **Highlighting:** if Emacs has a built-in `foo-ts-mode`, you're done —
   `treesit-auto` picks it and builds the grammar on first open. If not (like
   Swift), add a third-party mode: `(elpaca foo-ts-mode (add-to-list 'auto-mode-alist '("\\\\.foo\\\\'" . foo-ts-mode)))`.
2. **LSP / jump-to-def:** `brew`/`npm` install the server, then add an
   `eglot-server-programs` entry for the mode name. eglot auto-starts it.
3. **Linting:** prefer `flymake` (built-in). For Clojure we use `flycheck`
   because clj-kondo's integration is flycheck-based.

### Update everything

```elisp
M-x elpaca-update-all      ; rebuild all packages
M-x treesit-install-all-grammars ; (or M-x treesit-auto-install-all) refresh grammars
```

Delete `~/.emacs.d/.cache/` to force a fully clean rebuild if a package is
misbehaving.

### Where things live (debugging)

- "Package X didn't install" → `M-x elpaca-manager`, find it, check build log.
- "No highlighting for language Y" → `M-x treesit-ready-p RET Y RET`;
  if nil, the grammar didn't build — check `~/.emacs.d/tree-sitter/`.
- "eglot won't connect" → is the server binary on `PATH` inside GUI Emacs?
  `M-: (executable-find "rust-analyzer")` should return a path. If nil, PATH
  isn't inherited — extend the nvm PATH line or `exec-path-from-shell`.
- "Slow startup" → `~/.emacs.d/.cache/` and `.state/` grow over time; the
  `early-init.el` GC trick already speeds cold start.

### Commit conventions

Small, focused commits ("Add CIDER for Clojure", "Bump treesit-font-lock-level
to 4"). Keep `init.el` readable — prefer clear sections and comments over
clever macros. `AGENTS.md` documents the conventions AI assistants should
follow when editing this repo.

---

## What's intentionally not here

(Kept out for simplicity. Add when you actually feel the pain.)

- `vertico`/`orderless`/`marginalia`/`consult`/`embark` — the modern
  minibuffer stack. `fido-vertical-mode` covers the basics; upgrade later.
- `lsp-mode` — heavier than eglot; not needed.
- `company-mode` — replaced by `corfu` (lighter, modern).
- `org-roam`/`denote`/email — not in scope yet.
- `which-key` is on; `doom-modeline`/icons are not.

---

## License

Personal dotfiles. Do what you want.
