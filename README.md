# My dotfiles

![Screen shot](https://example.com)

My configuration for:
- Hyprland
- UWSM
- SDDM
- Waybar
- Wofi
- Dunst
- Dolphin
- Fish
- Kitty
- Tmux + tmuxp
- Neovim + associated plugins
- Other less significant things

Uses [Tinty](https://github.com/tinted-theming/tinty) to theme the system.

(I use Arch, btw :sunglasses:)



## Set up

**Warning:** I haven't yet gotten around to writing an install script. As a result, you will have to install the various packages/libs/applications (and their dependencies) yourself in order to get this set up. Good luck :thumbsup:

### Prerequisites

I use [GNU Stow](https://www.gnu.org/software/stow/) to allow me to separate the sections of my config that I want version controlled from the inevitable extra cruft that ends up in `~/.config` on every Linux system after a while. On Arch, Stow can be installed with
```sh
pacman -S stow
```

Nothing within this repository is tied to this method of config management though. If you do choose to use another process, please be aware that the folder structure matters. The root of this repository is equivalent to the home directory. Eg `dotfiles/.config/nvim/init.lua` should be placed at `~/.config/nvim/init.lua`.

## Install

1. Clone the repo
   ```sh
   git clone git@github.com:brynmailer/dotfiles.git
   cd dotfiles
   ```
2. Create symlinks in home directory
   ```sh
   stow --dotfiles -t ~ .
   ```
