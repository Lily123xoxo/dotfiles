# Path
export PATH="$HOME/.local/bin:$PATH"
export TERMINAL=kitty

# Source modular files (guard pattern - silently skips if not present yet)
[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Source modular function/completion directories
[[ -d "$HOME/.zsh_functions" ]] && {
  fpath=("$HOME/.zsh_functions" $fpath)
  for func in "$HOME"/.zsh_functions/*; do
    autoload -Uz "${func:t}"
  done
}
autoload -Uz compinit && compinit

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# Fastfetch on terminal start
sleep 0.1 && fastfetch
bindkey "^[[3~" delete-char
