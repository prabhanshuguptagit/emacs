# prabhanshu's emacs

A small Emacs config, small enough to hold in your head and maintain for life.

- **Platform:** macOS · **Emacs:** 29+ (developed on 30) · **Packages:** [Elpaca](https://github.com/progfolio/elpaca)
- **Daily language:** Clojure (via CIDER)
- **Philosophy:** prefer built-ins, explicit keybindings, one readable `init.el`.

## Quick start

```bash
git clone https://github.com/prabhanshuguptagit/emacs.git ~/.emacs.d
brew install clj-kondo ripgrep
```

Open Emacs. On first launch Elpaca downloads and builds every package (a minute or two, once). Tree-sitter grammars compile automatically the first time you open a file of each language.

Install language servers only for languages you use (see [Toolchain](#toolchain)).

## What's in here

- **Syntax highlighting** — tree-sitter for ~20 languages via `treesit-auto`, maxed-out fontification. Swift uses a MELPA mode (Emacs has no built-in).
- **Jump to definition / LSP** — `eglot` auto-starts per language; servers run as separate processes, lazily, shut down when you close the buffer.
- **Completion** — `corfu` popup at point + `cape` (file/word backends); minibuffer uses built-in `fido-vertical-mode`.
- **Clojure** — `clojure-mode` + `cider` (interactive REPL) + `paredit` + `clj-kondo` linting. Not LSP — CIDER is richer for a daily language.
- **Git** — Magit. **Projects** — Projectile + Treemacs. **Diffs** — Ediff (plain side-by-side windows).
- **Theme** — `base16-materia` with a hand-tuned mode line. `C-c w` switches themes live.
- **Font** — Be Vietnam Pro 16pt; Menlo for fixed-pitch/code.

## Toolchain

Install only what you use. Emacs finds these on `PATH` automatically.

| Language | Tool | Install |
|---|---|---|
| Clojure | `clj-kondo` (linter) | `brew install clj-kondo` |
| Swift | `sourcekit-lsp` | comes with Xcode Command Line Tools |
| Rust | `rust-analyzer` | `brew install rust-analyzer` |
| TS/JS | `typescript-language-server` | `npm i -g typescript typescript-language-server` |
| HTML/CSS/JSON | `vscode-langservers-extracted` | `npm i -g vscode-langservers-extracted` |
| C/C++ | `clangd` | already at `/usr/bin/clangd` |
| any | `ripgrep` (project search) | `brew install ripgrep` |

## Keybindings

| Key | Action |
|---|---|
| `s-p` | projectile find file (Quick Open) |
| `s-<up>` / `s-<down>` | begin / end of buffer |
| `s-]` / `s-[` | next / previous window |
| `s-<backspace>` | kill whole line |
| `C-<backspace>` | backward kill word |
| `C-c w` | theme switcher |
| `C-c g` / `C-c c` / `C-c P` | magit status / commit / push |
| `C-c p` | projectile prefix |
| `C-c t` / `C-c T` | treemacs toggle / select |

LSP (eglot buffers): `M-.` jump to def · `M-,` pop back · `M-?` references · `M-x eglot-rename`.

Clojure: `C-c M-j` jack in · `C-c C-k` eval form · `C-c C-d d` docs · `M-.` jump to def.

## Files

- `init.el` — the whole config, top to bottom.
- `early-init.el` — pre-package startup tweaks.
- `README.md` — this file. `AGENTS.md` — notes for AI assistants maintaining the config.
- `tree-sitter/`, `.cache/`, `.state/`, `transient/` — generated, gitignored.

## What's deliberately not here

Add when you feel the pain: `vertico`/`orderless`/`consult` minibuffer stack, `lsp-mode`, `company-mode`, `org-roam`/`denote`, `doom-modeline`.
