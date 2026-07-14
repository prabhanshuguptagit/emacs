# prabhanshu's emacs

Working man's emacs config.

- **Platform:** macOS · **Emacs:** 29+ (developed on 30) · **Packages:** [Elpaca](https://github.com/progfolio/elpaca)
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
