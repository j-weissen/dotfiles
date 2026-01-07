export EDITOR=lvim
export SUDO_EDITOR=lvim
export PATH="$PATH:$HOME/Software/fairy:$HOME/.local/bin:$HOME/Software/cmake-4.1.2-linux-x86_64/bin:$HOME/Software/flutter/bin:$HOME/Software/typst-x86_64-unknown-linux-musl:$HOME/Software/firefox"
export ZSH_THEME=kolo
export XDG_CONFIG_HOME="$HOME/.config"

alias xrandr-mirror="xrandr --output HDMI-1 --mode 1920x1080 --same-as eDP-1"
alias xrandr-kvm="xrandr --output DP-3 --mode "
alias nixer="sudo nixos-rebuild switch --flake $HOME/dotfiles/nixos#$HOSTNAME"
alias hypr-mirror="hyprctl keyword monitor 'eDP-1, mirror'"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source "$HOME/.cargo/env"

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="daveverwer"
plugins=(git)

source $ZSH/oh-my-zsh.sh
