#!/bin/bash
set -e # Exit on error

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "🚀 Setting up dotfiles..."

# MacOS System Settings
echo "⚙️  Configuring macOS..."
touch $HOME/.hushlogin
defaults write com.apple.finder AppleShowAllFiles YES

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew is not installed. Please install it first:"
  echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi

# Install Homebrew packages
echo "📦 Installing Homebrew packages..."
brew bundle --file=./brew/Brewfile

# Setup dotfiles with GNU Stow
echo "🔗 Setting up symlinks with stow..."

# List of packages to stow
PACKAGES=("eza" "helix" "starship" "fastfetch" "zsh" "ghostty" "nvim" "yazi")

for package in "${PACKAGES[@]}"; do
  echo "  → Linking $package..."
  # Use --adopt to handle existing files (moves them into dotfiles repo)
  # Use --restow to refresh links
  stow --restow --verbose=1 "$package" 2>&1 | grep -v "BUG in find_stowed_path" || true
done

echo ""
echo "✅ Done! Please restart your terminal."
echo "💡 Tip: Run 'source ~/.zshrc' to reload shell config without restarting."
