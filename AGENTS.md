# AGENTS.md — Emacs config maintenance notes

This directory is the user's `~/.emacs.d` and currently contains a deliberately minimal Emacs setup.

## User intent

The user is returning to Emacs after a long break and wants this agent to help with all Emacs setup, usage, and maintenance.

Preference: keep the config **very minimal**, easy to reason about, and easy to maintain. Do not import large configs wholesale. Use principles from Protesilaos Stavrou's dotemacs: clear sections, simple helpers, explicit keybindings, small amount of code, robust startup.

Initial requested features:

- Magit
- Projectile
- Nice tree navigator
- Pointer/click support
- Decent modeline
- Elpaca package manager

The user also mentioned: "transparent taskbar". This is not yet implemented/clarified. It may mean Emacs frame transparency, macOS title/tab bar appearance, or OS taskbar/dock/panel transparency. Ask before changing.

## Current files

- `early-init.el`
- `init.el`
- `savehist`
- `AGENTS.md`
- Elpaca directories may exist under `elpaca/` after bootstrap.

## Current setup summary

### `early-init.el`

Contains early UI/startup tweaks:

- disables menu bar, tool bar, scroll bar
- disables splash/startup screens
- sets basic frame resize behavior
- quiets bell
- temporarily increases GC threshold during startup
- temporarily clears `file-name-handler-alist`, restored on `emacs-startup-hook`
- sets:

```elisp
(setq package-enable-at-startup nil)
```

because Elpaca manages packages.

### `init.el`

Uses Elpaca, not `package.el`.

Important helpers:

```elisp
my-emacs-configure
my-emacs-keybind
```

`my-emacs-configure` catches errors and reports them without aborting all startup. `my-emacs-keybind` is a tiny explicit keybinding helper.

Basic built-in modes enabled:

- `savehist-mode`
- `recentf-mode`
- `delete-selection-mode`
- `global-auto-revert-mode`
- `electric-pair-mode`
- `show-paren-mode`
- `which-key-mode`

Quit safety:

- `C-x C-c` disabled
- `C-x C-c C-c` bound to `save-buffers-kill-emacs`

Completion is built-in/minimal:

```elisp
(setq completion-styles '(basic substring partial-completion flex)
      completion-category-defaults nil
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      read-file-name-completion-ignore-case t)
```

Theme:

```elisp
(load-theme 'modus-vivendi :no-confirm)
```

## Package manager: Elpaca

The config uses the standard Elpaca bootstrap.

Packages installed/queued:

- `compat`
- `transient`
- `magit`
- `projectile`
- `treemacs`
- `treemacs-projectile`
- `doom-modeline`

Why `compat` and `transient` are explicit:

Magit failed on this user's Emacs because built-in versions were too old:

- `with-editor` wanted `compat >= 31.0`
- Magit wanted `transient >= 0.13`

So the config now does:

```elisp
(elpaca compat)
(elpaca transient)
(elpaca-wait)

(elpaca magit ...)
```

This ensures newer Elpaca-installed dependencies are available before Magit.

Important: a previous line causing a warning was removed:

```elisp
(elpaca `(,@elpaca-order))
```

It produced:

```text
Warning (emacs): elpaca loaded before Elpaca activation
```

We are relying on bootstrap-loading Elpaca instead of asking Elpaca to manage itself during startup.

## Agent convention: Installing packages

When the user asks to "install" a package (e.g., "can you install markdown-mode?"), **do not** just tell them to run `M-x package-install`. Instead, **add the package to `init.el`** using the Elpaca form:

```elisp
(elpaca package-name)
```

Place it in an appropriate section (with related packages, or in a "Packages" section). This ensures the installation is **persistent** across restarts.

If the user wants to try something temporarily first, they can still use `M-x package-install` (which works via Elpaca's compatibility shim), but the agent's default action should be adding to `init.el`.

## Requested package config

### Magit

Key:

- `C-c g` → `magit-status`

Config:

```elisp
(setq magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
```

### Projectile

Enabled globally:

```elisp
(projectile-mode 1)
```

Key:

- `C-c p` → `projectile-command-map`

Current project search path:

```elisp
'("~/Code" "~/Projects" "~/work")
```

May need to adjust to the user's actual project directories.

### Treemacs

Keys:

- `C-c t` → `treemacs`
- `C-c T` → `treemacs-select-window`

Enabled when loaded:

- `treemacs-project-follow-mode`
- `treemacs-follow-mode`
- `treemacs-filewatch-mode`

### Doom modeline

Enabled:

```elisp
(doom-modeline-mode 1)
```

Icons disabled for now:

```elisp
(setq doom-modeline-icon nil)
```

This avoids requiring icon fonts during initial setup.

## Pointer/click support

The user explicitly wants to be able to click on things.

Current config includes:

```elisp
(context-menu-mode 1)
(mouse-wheel-mode 1)
(xterm-mouse-mode 1)
(setq mouse-1-click-follows-link t
      mouse-wheel-scroll-amount '(1 ((shift) . 5) ((control) . text-scale))
      mouse-wheel-progressive-speed nil
      mouse-wheel-follow-mouse t
      mouse-drag-copy-region nil
      make-pointer-invisible t)
```

Also:

- `mouse-1` pushes buttons via `button-map`
- `mouse-1` clicks widgets via `widget-keymap`
- URLs are buttonized/clickable via:
  - `goto-address-mode` in text buffers
  - `goto-address-prog-mode` in programming buffers

## Known issues already encountered

Screenshots showed Elpaca/Magit dependency failures:

1. Magit failed because `with-editor` needed newer `compat`.
2. Magit failed because current Magit needed newer `transient`.
3. Elpaca warned that `elpaca` was loaded before activation; fixed by removing the self-queue line.

If stale Elpaca builds remain problematic, remove affected repos/builds, e.g.:

```sh
rm -rf ~/.emacs.d/elpaca/repos/compat ~/.emacs.d/elpaca/builds/compat
rm -rf ~/.emacs.d/elpaca/repos/transient ~/.emacs.d/elpaca/builds/transient
rm -rf ~/.emacs.d/elpaca/repos/with-editor ~/.emacs.d/elpaca/builds/with-editor
rm -rf ~/.emacs.d/elpaca/repos/magit ~/.emacs.d/elpaca/builds/magit
```

Then restart Emacs.

## Style guidelines for future changes

- Keep it minimal.
- Prefer built-in features when reasonable.
- Avoid introducing `use-package` unless the user asks. Current config uses direct `elpaca` declarations plus simple helpers.
- Avoid copying large sections from Prot's config. Adapt ideas only.
- Prefer explicit keybindings over remaps for readability.
- When adding packages, explain why they are worth the maintenance cost.
- Keep icons/fonts optional.
- Ask before adding large completion stacks like Vertico/Orderless/Marginalia/Consult/Embark. They are good, but not part of initial minimal setup yet.
- Ask before adding LSP, Org GTD, email, Denote, etc.

## Useful current keybindings

- `C-c g` — Magit status
- `C-c p` — Projectile prefix
- `C-c t` — Treemacs
- `C-c T` — select Treemacs window
- `C-x C-c C-c` — quit Emacs

## Next likely tasks

- Clarify and implement "transparent taskbar".
- Confirm Emacs version and platform. User appears to be on macOS from screenshot paths.
- Verify Elpaca startup is clean after latest edits.
- Confirm clicking behavior in GUI Emacs and terminal Emacs.
- Possibly add frame transparency if that is what the user meant, e.g. `alpha-background`/`alpha` frame parameters depending on Emacs version/build.
- Possibly adjust Projectile search paths.
- Possibly choose a better modeline if `doom-modeline` is too heavy or icon fonts become desired.
