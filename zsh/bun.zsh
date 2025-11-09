source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# bun completions
[ -s "/Users/skye/.bun/_bun" ] && source "/Users/skye/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
