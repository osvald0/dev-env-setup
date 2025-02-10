#!/bin/bash

set -e # Stop script if any command fails

echo "Starting installation..."

echo "Creating backups and removing old setup..."
backup_dir="$HOME/.setup-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$backup_dir"

backup_files=(
	"$HOME/.zshrc"
	"$HOME/.tmux.conf"
	"$HOME/.config/nvim"
	"$HOME/.zsh"
)

for file in "${backup_files[@]}"; do
	if [ -e "$file" ]; then
		echo "Backing up $file to $backup_dir"
		cp -r "$file" "$backup_dir/"
		rm -rf "$file"
	fi
done

rollback() {
	echo "An error occurred! Rolling back..."
	for file in "${backup_files[@]}"; do
		if [ -e "$backup_dir/$(basename "$file")" ]; then
			echo "Restoring $file..."
			rm -rf "$file"
			cp -r "$backup_dir/$(basename "$file")" "$file"
		fi
	done
	echo "Rollback complete!"
	exit 1
}

trap rollback ERR # Run rollback function if the script fails

echo "Installing dependencies..."
brew install zsh git curl fzf bat eza tmux neovim

mkdir -p "$HOME/.zsh/plugins"
mkdir -p "$HOME/.config/nvim/lua/plugins"

echo "Installing Zsh plugins..."
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/plugins/zsh-syntax-highlighting"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.zsh/plugins/powerlevel10k"
git clone --depth=1 https://github.com/rupa/z.git "$HOME/.zsh/plugins/z"

echo "Installing FZF key bindings..."
$(brew --prefix)/opt/fzf/install --all

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	echo "Installing Tmux Plugin Manager (TPM)..."
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "Copying configuration files..."
[ -f "zshrc.conf" ] && cp zshrc.conf "$HOME/.zshrc"
[ -f "tmux.conf" ] && cp tmux.conf "$HOME/.tmux.conf"

echo "Installing Tmux plugins..."
"$HOME/.tmux/plugins/tpm/bin/install_plugins"

if [ ! -d "$HOME/.config/nvim" ]; then
	echo "Installing LazyVim..."
	git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
	rm -rf "$HOME/.config/nvim/.git"
fi

echo "Adding LazyVim plugin configurations..."
[ -f "lazyvim-plugins.lua" ] && cp lazyvim-plugins.lua "$HOME/.config/nvim/lua/plugins/custom.lua"
[ -f "lazyvim-tailwind.lua" ] && cp lazyvim-tailwind.lua "$HOME/.config/nvim/lua/plugins/tailwind.lua"
[ -f "lazyvim-linting.lua" ] && cp lazyvim-linting.lua "$HOME/.config/nvim/lua/plugins/linting.lua"
[ -f "lazyvim-theme.lua" ] && cp lazyvim-theme.lua "$HOME/.config/nvim/lua/plugins/theme.lua"
[ -f "lazyvim-multicursor.lua" ] && cp lazyvim-multicursor.lua "$HOME/.config/nvim/lua/plugins/multicursor.lua"
[ -f "lazyvim-biome.lua" ] && cp lazyvim-biome.lua "$HOME/.config/nvim/lua/plugins/biome.lua"

echo "Setup complete! Restarting shell..."
exec zsh
