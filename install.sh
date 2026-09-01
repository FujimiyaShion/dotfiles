#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STOW_PACKAGES=(
    zsh
    git
    kitty
    nvim
    niri
    fastfetch
    starship
    btop
    cava
    mpv
    fcitx5
    pacseek
    go-musicfox
    fontconfig
    noctalia
    opencode
)

echo "==> 安装基础依赖 (git, stow)"
sudo pacman -S --needed --noconfirm git stow

AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

if [[ -n "$AUR_HELPER" ]]; then
    echo "==> 使用 $AUR_HELPER 安装软件包 (官方仓库 + AUR)"
    # shellcheck disable=SC2046
    "$AUR_HELPER" -S --needed --noconfirm \
        $(cat "$DOTFILES_DIR/packages/pkglist.txt" "$DOTFILES_DIR/packages/aurlist.txt")
else
    echo "==> 未找到 AUR helper，仅安装官方仓库包"
    # shellcheck disable=SC2046
    sudo pacman -S --needed --noconfirm $(cat "$DOTFILES_DIR/packages/pkglist.txt")
    echo "提示: 安装 yay 后重新运行本脚本以安装 AUR 包:"
    echo "  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
fi

echo "==> 链接配置文件到 $HOME"
cd "$DOTFILES_DIR"
for pkg in "${STOW_PACKAGES[@]}"; do
    stow -v -t "$HOME" "$pkg"
done

echo "==> 完成! 重新登录或 source ~/.zshrc 生效"
