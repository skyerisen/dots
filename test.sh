#!/bin/bash
# Test script for dotfiles setup
# This script backs up existing configs, tests setup, and can restore them

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🧪 Dotfiles Test Script${NC}"
echo ""

# Function to backup existing configs
backup_configs() {
    echo -e "${YELLOW}📦 Backing up existing configs to: $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Backup files that will be replaced
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
    [ -f "$HOME/.aliases.zsh" ] && cp "$HOME/.aliases.zsh" "$BACKUP_DIR/.aliases.zsh"
    [ -f "$HOME/.exports.zsh" ] && cp "$HOME/.exports.zsh" "$BACKUP_DIR/.exports.zsh"
    
    # Backup .config directories
    [ -d "$HOME/.config/eza" ] && cp -r "$HOME/.config/eza" "$BACKUP_DIR/config-eza"
    [ -d "$HOME/.config/helix" ] && cp -r "$HOME/.config/helix" "$BACKUP_DIR/config-helix"
    [ -d "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$BACKUP_DIR/starship.toml"
    [ -d "$HOME/.config/fastfetch" ] && cp -r "$HOME/.config/fastfetch" "$BACKUP_DIR/config-fastfetch"
    
    echo -e "${GREEN}✓ Backup complete${NC}"
    echo ""
}

# Function to remove existing configs (for clean test)
remove_configs() {
    echo -e "${YELLOW}🗑️  Removing existing configs for clean test...${NC}"
    
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.aliases.zsh"
    rm -f "$HOME/.exports.zsh"
    rm -rf "$HOME/.config/eza"
    rm -rf "$HOME/.config/helix"
    rm -f "$HOME/.config/starship.toml"
    rm -rf "$HOME/.config/fastfetch"
    
    echo -e "${GREEN}✓ Configs removed${NC}"
    echo ""
}

# Function to verify symlinks
verify_links() {
    echo -e "${YELLOW}🔍 Verifying symlinks...${NC}"
    
    local all_good=true
    
    # Check zsh files
    for file in .zshrc .aliases.zsh .exports.zsh; do
        if [ -L "$HOME/$file" ]; then
            echo -e "${GREEN}✓${NC} $HOME/$file → $(readlink $HOME/$file)"
        else
            echo -e "${RED}✗${NC} $HOME/$file is not a symlink!"
            all_good=false
        fi
    done
    
    # Check .config files
    if [ -L "$HOME/.config/eza" ]; then
        echo -e "${GREEN}✓${NC} ~/.config/eza → $(readlink $HOME/.config/eza)"
    else
        echo -e "${RED}✗${NC} ~/.config/eza is not linked!"
        all_good=false
    fi
    
    if [ -L "$HOME/.config/helix" ]; then
        echo -e "${GREEN}✓${NC} ~/.config/helix → $(readlink $HOME/.config/helix)"
    else
        echo -e "${RED}✗${NC} ~/.config/helix is not linked!"
        all_good=false
    fi
    
    if [ -L "$HOME/.config/starship.toml" ]; then
        echo -e "${GREEN}✓${NC} ~/.config/starship.toml → $(readlink $HOME/.config/starship.toml)"
    else
        echo -e "${RED}✗${NC} ~/.config/starship.toml is not linked!"
        all_good=false
    fi
    
    if [ -L "$HOME/.config/fastfetch" ]; then
        echo -e "${GREEN}✓${NC} ~/.config/fastfetch → $(readlink $HOME/.config/fastfetch)"
    else
        echo -e "${RED}✗${NC} ~/.config/fastfetch is not linked!"
        all_good=false
    fi
    
    echo ""
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}✅ All symlinks are correct!${NC}"
    else
        echo -e "${RED}❌ Some symlinks are missing or incorrect!${NC}"
        return 1
    fi
}

# Function to restore backup
restore_backup() {
    if [ -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}🔄 Restoring from backup...${NC}"
        
        # Remove stow symlinks first
        cd "$DOTFILES_DIR"
        stow -D eza helix starship fastfetch zsh 2>/dev/null || true
        
        # Restore files
        [ -f "$BACKUP_DIR/.zshrc" ] && cp "$BACKUP_DIR/.zshrc" "$HOME/.zshrc"
        [ -f "$BACKUP_DIR/.aliases.zsh" ] && cp "$BACKUP_DIR/.aliases.zsh" "$HOME/.aliases.zsh"
        [ -f "$BACKUP_DIR/.exports.zsh" ] && cp "$BACKUP_DIR/.exports.zsh" "$HOME/.exports.zsh"
        [ -d "$BACKUP_DIR/config-eza" ] && cp -r "$BACKUP_DIR/config-eza" "$HOME/.config/eza"
        [ -d "$BACKUP_DIR/config-helix" ] && cp -r "$BACKUP_DIR/config-helix" "$HOME/.config/helix"
        [ -f "$BACKUP_DIR/starship.toml" ] && cp "$BACKUP_DIR/starship.toml" "$HOME/.config/starship.toml"
        [ -d "$BACKUP_DIR/config-fastfetch" ] && cp -r "$BACKUP_DIR/config-fastfetch" "$HOME/.config/fastfetch"
        
        echo -e "${GREEN}✓ Backup restored${NC}"
    else
        echo -e "${RED}No backup found at $BACKUP_DIR${NC}"
    fi
}

# Main menu
echo "Select test mode:"
echo "1) Clean test (backup, remove configs, run setup, verify)"
echo "2) Idempotent test (run setup on existing configs, verify)"
echo "3) Restore from backup"
echo "4) Just verify current symlinks"
read -p "Choice [1-4]: " choice

case $choice in
    1)
        backup_configs
        remove_configs
        echo -e "${YELLOW}🚀 Running setup.sh...${NC}"
        "$DOTFILES_DIR/setup.sh"
        echo ""
        verify_links
        echo ""
        echo -e "${YELLOW}💡 Backup location: $BACKUP_DIR${NC}"
        echo -e "${YELLOW}💡 To restore: ./test.sh and choose option 3${NC}"
        ;;
    2)
        backup_configs
        echo -e "${YELLOW}🚀 Running setup.sh on existing configs...${NC}"
        "$DOTFILES_DIR/setup.sh"
        echo ""
        verify_links
        echo ""
        echo -e "${GREEN}✅ Idempotent test passed! Setup can run multiple times safely.${NC}"
        ;;
    3)
        restore_backup
        ;;
    4)
        verify_links
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac
