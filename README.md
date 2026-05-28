# My dotfiles

![Screen shot](https://example.com)

My configuration for:
- Hyprland
- UWSM
- SDDM
- Waybar
- Rofi
- Dunst
- Dolphin
- Fish
- Kitty
- Tmux
- Neovim + associated plugins
- Claude Code
- Other less significant things

Uses [Tinty](https://github.com/tinted-theming/tinty) to theme the system.

(I use Arch, btw :sunglasses:)



## Install

1. Clone the repo
   ```sh
   git clone git@github.com:brynmailer/dotfiles.git
   cd dotfiles
   ```
2. Run the install script
   ```sh
   ./install.sh            # full install (Arch only)
   ./install.sh --minimal  # SSH-only setup, works on Arch or Debian
   ```

The script detects the OS (Arch via pacman/paru, Debian-based via apt), installs the package set for the chosen mode, bootstraps rustup + nvm (node LTS) + Tinty + tpm, installs the Claude Code CLI and `claude-mermaid`, sets `fish` as your login shell, and runs `stow --dotfiles -t ~ .`. Every step is idempotent — re-running is safe.

### Modes

- **Full** (Arch only) — installs the Hyprland desktop stack as well: Hyprland, Waybar, Rofi, Dunst, SDDM, UWSM, Dolphin, Kitty, plus `grim`/`slurp`/`wl-clipboard`/`playerctl`/`wireplumber`/`libnotify`.
- **`--minimal`** — installs only what's needed on a remote SSH box: fish, tmux, neovim, fzf, ripgrep, git, jq, keychain, stow, rustup, nvm + node LTS, Claude Code, `claude-mermaid`, `prettierd`, Tinty, tpm.

Full mode is Arch-only because the desktop stack doesn't have practical apt equivalents; running `./install.sh` on Debian without `--minimal` will error.

### Layout

The repo is laid out for [GNU Stow](https://www.gnu.org/software/stow/) with `--dotfiles`, so `dot-config/nvim/init.lua` lands at `~/.config/nvim/init.lua`. Nothing else in the configs depends on Stow — if you want to manage things differently, just preserve that mapping.

## Claude Code workflow

Four top-level modes. The active mode is in `$CLAUDE_MODE` (shown coloured in the statusline) and drives the simple-mode scope-creep hook.

| Shell abbr | Mode      | Agent       | Purpose                                                                                  |
| ---------- | --------- | ----------- | ---------------------------------------------------------------------------------------- |
| `cc`       | Simple    | (none)      | Rote tasks. Drift hook nudges → blocks if request looks non-trivial.                     |
| `ccp`      | Professor | `professor` | Socratic knowledge building. Read-only.                                                  |
| `ccs`      | Scribe    | `scribe`    | Writing aggregation. Read-only; surfaces sources, structure, gaps.                       |
| `cce`      | Engineer  | `engineer`  | Orchestrator. Lives in the main pane; dispatches stage agents into a secondary pane.     |

### Engineering: two-pane workflow

Launch `cce` in a tmux window. The orchestrator lives there. When you're ready for a stage (prereq → scope → (spec) → plan → implement), the orchestrator writes a short context summary to `/tmp/claude-handoff-<agent>.md` and invokes `~/.claude/bin/handoff.sh <agent> <context-file>`, which kills any existing secondary pane, splits horizontally, and launches `claude --agent <agent> --append-system-prompt-file <context-file>`. At most two panes per window, enforced by the script.

**Each project gets one design doc**, path chosen by the user during the scope stage; plan and implement read/append to that same file.

### Layout

```
dot-claude/
  CLAUDE.md             # workflow map (loaded every session)
  settings.json         # base settings + statusline + drift hook + default outputStyle + permissions + MCP servers
  agents/               # one agent per mode + per engineering stage
  output-styles/        # candid.md (default for every session)
  skills/               # diagram/ — Mermaid validate-render-save process
  bin/                  # handoff.sh — orchestrator's pane-and-agent dispatcher
  hooks/                # simple-drift.sh, statusline.sh
```

### Setup notes

- `jq`, `claude-mermaid`, and the Claude Code CLI are all installed by `install.sh`. Verify the Mermaid MCP server with `claude mcp list`; live-reload previews open in the browser on ports 3737–3747.
- Before first `stow`, back up or remove any existing `~/.claude/CLAUDE.md` and `~/.claude/settings.json` — stow won't overwrite real files.
- The drift hook is silent unless `$CLAUDE_MODE` is `simple` (or unset). First trip nudges; second consecutive trip blocks. To unblock: switch modes, or rephrase to avoid trigger words.
