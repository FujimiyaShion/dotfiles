#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPERS_REPO="https://github.com/FujimiyaShion/wallpapers.git"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"

# ===== 配置包（stow 目录名|描述）=====
CONFIGS=(
    "zsh|Zsh 配置（starship/zoxide/补全）"
    "git|Git 全局配置"
    "kitty|Kitty 终端 + Catppuccin 主题"
    "nvim|Neovim（lazy.nvim）"
    "niri|Niri 合成器"
    "fastfetch|系统信息展示"
    "starship|提示符主题"
    "btop|系统监视器"
    "cava|音频可视化"
    "mpv|视频播放器"
    "fcitx5|输入法"
    "pacseek|AUR 包管理器前端"
    "go-musicfox|网易云音乐终端"
    "fontconfig|字体配置"
    "noctalia|Niri shell（bar/壁纸）"
    "opencode|AI 编程助手"
)

# ===== 软件包分组（组名|描述|包列表）=====
PKG_GROUPS=(
    "系统基础|内核/固件/文件系统/基础工具|base base-devel sudo linux linux-firmware linux-headers intel-ucode grub grub-btrfs os-prober efibootmgr dosfstools exfat-utils udftools f2fs-tools xfsprogs btrfs-progs btrfs-assistant snapper snapshot gparted fuse3 power-profiles-daemon gst-libav gst-plugins-base gst-plugins-good archlinuxcn-keyring"
    "显卡驱动|NVIDIA + Intel 混合驱动|nvidia-open-dkms nvidia-utils lib32-nvidia-utils libva-nvidia-driver libva-utils intel-media-driver vulkan-intel lib32-vulkan-intel"
    "音频|PipeWire 全家桶|pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber alsa-firmware alsa-ucm-conf sof-firmware decibels"
    "网络|网络管理/代理/下载|networkmanager iwd bluez flclash fragments gvfs-smb"
    "桌面环境|Niri + 登录管理器|niri noctalia greetd greetd-tuigreet xwayland-satellite xorg-xauth xorg-xhost xdg-desktop-portal-gnome xdg-terminal-exec brightnessctl inotify-tools polkit-gnome gnome-keyring gnome-logs"
    "终端与Shell|Zsh/终端/CLI 工具|zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting starship zoxide fzf fd kitty fastfetch btop gdu tree jq 7zip yazi"
    "编辑器与开发|Neovim/Node/opencode|neovim tree-sitter-cli nodejs npm opencode python-pillow imagemagick resvg icoextract ffmpegthumbnailer"
    "输入法与字体|Fcitx5 + 中文字体|fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-rime rime-ice-git rime-pinyin-moegirl noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd ttf-lxgw-wenkai ttf-maplemono-nf-cn-unhinted breeze-cursors"
    "影音游戏|播放器/游戏|mpv cava go-musicfox-git audacity obs-studio steam lutris prismlauncher"
    "办公日常|浏览器/GNOME 应用/文件管理|firefox file-roller gnome-calculator gnome-font-viewer loupe papers nautilus-open-any-terminal yay"
    "AUR 应用|QQ/微信/WPS 等|linuxqq wechat-appimage wps-office-cn wps-office-mui-zh-cn typora-free ani2xcursor pacseek pins-git"
)

usage() {
    cat <<EOF
用法: ./install.sh [选项]

无选项      交互式：选择配置、软件组、是否下载壁纸
--full      非交互，全量安装（所有配置 + 所有软件组 + 壁纸）
--configs   非交互，仅链接全部配置
--pkgs      非交互，仅安装全部软件包
-h, --help  显示帮助
EOF
}

choose_multi() {
    local prompt="$1"; shift
    local -a opts=("$@")
    local n=${#opts[@]} ans ok
    local -a nums
    while true; do
        echo
        echo "== $prompt =="
        for ((i = 0; i < n; i++)); do
            printf "  [%2d] %s\n" "$((i + 1))" "${opts[i]}"
        done
        printf "  输入编号(空格分隔) / 回车=全选 / n=跳过: "
        IFS= read -r ans
        if [[ -z "$ans" ]]; then
            for ((i = 0; i < n; i++)); do echo "${opts[i]}"; done
            return 0
        fi
        if [[ "$ans" == "n" || "$ans" == "N" ]]; then
            return 0
        fi
        read -r -a nums <<<"$ans"
        ok=1
        for num in "${nums[@]}"; do
            if ! [[ "$num" =~ ^[0-9]+$ ]] || ((num < 1 || num > n)); then
                echo "  无效编号: $num"
                ok=0
                break
            fi
        done
        if ((ok)); then
            for num in "${nums[@]}"; do
                echo "${opts[$((num - 1))]}"
            done
            return 0
        fi
    done
}

confirm() {
    local prompt="$1" ans
    printf "%s [y/N] " "$prompt"
    IFS= read -r ans
    [[ "$ans" == "y" || "$ans" == "Y" ]]
}

# ===== 非交互模式参数解析 =====
FULL_MODE=0
CONFIGS_ONLY=0
PKGS_ONLY=0
for arg in "$@"; do
    case "$arg" in
        --full) FULL_MODE=1 ;;
        --configs) CONFIGS_ONLY=1 ;;
        --pkgs) PKGS_ONLY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "未知参数: $arg"; usage; exit 1 ;;
    esac
done

INTERACTIVE=0
[[ -t 0 ]] && INTERACTIVE=1

sel_configs=()
sel_groups=()
want_wallpapers=0

if [[ $FULL_MODE == 1 ]]; then
    mapfile -t sel_configs < <(printf '%s\n' "${CONFIGS[@]}" | cut -d'|' -f1)
    mapfile -t sel_groups < <(printf '%s\n' "${PKG_GROUPS[@]}" | cut -d'|' -f1)
    want_wallpapers=1
elif [[ $CONFIGS_ONLY == 1 ]]; then
    mapfile -t sel_configs < <(printf '%s\n' "${CONFIGS[@]}" | cut -d'|' -f1)
elif [[ $PKGS_ONLY == 1 ]]; then
    mapfile -t sel_groups < <(printf '%s\n' "${PKG_GROUPS[@]}" | cut -d'|' -f1)
elif [[ $INTERACTIVE == 1 ]]; then
    echo "========== dotfiles 安装器 =========="
    mapfile -t sel_configs < <(choose_multi "选择要链接的配置" "${CONFIGS[@]}")
    mapfile -t sel_groups < <(choose_multi "选择要安装的软件组" "${PKG_GROUPS[@]}")
    if confirm "下载壁纸仓库到 $WALLPAPERS_DIR?"; then
        want_wallpapers=1
    fi
else
    echo "非交互终端且未指定模式，默认: 全量安装（不含壁纸）"
    mapfile -t sel_configs < <(printf '%s\n' "${CONFIGS[@]}" | cut -d'|' -f1)
    mapfile -t sel_groups < <(printf '%s\n' "${PKG_GROUPS[@]}" | cut -d'|' -f1)
fi

# ===== 1. 安装软件包 =====
install_pkgs=()
for g in "${sel_groups[@]}"; do
    for entry in "${PKG_GROUPS[@]}"; do
        if [[ "${entry%%|*}" == "$g" ]]; then
            rest="${entry#*|}"
            read -r -a pkgs <<<"${rest#*|}"
            install_pkgs+=("${pkgs[@]}")
            break
        fi
    done
done

if (( ${#install_pkgs[@]} > 0 )); then
    echo
    echo "==> 安装基础依赖 (git, stow)"
    sudo pacman -S --needed --noconfirm git stow

    AUR_HELPER=""
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    fi

    if [[ -n "$AUR_HELPER" ]]; then
        echo "==> 使用 $AUR_HELPER 安装 ${#install_pkgs[@]} 个软件包"
        "$AUR_HELPER" -S --needed --noconfirm "${install_pkgs[@]}"
    else
        echo "==> 未找到 AUR helper，仅安装官方仓库包"
        sudo pacman -S --needed --noconfirm "${install_pkgs[@]}" || true
        echo "提示: AUR 包被跳过。安装 yay 后重跑本脚本:"
        echo "  git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si"
    fi
fi

# ===== 2. 链接配置 =====
if (( ${#sel_configs[@]} > 0 )); then
    echo
    echo "==> 链接配置文件到 $HOME"
    cd "$DOTFILES_DIR"
    for cfg in "${sel_configs[@]}"; do
        stow -v -t "$HOME" "$cfg"
    done
fi

# ===== 3. 下载壁纸 =====
if (( want_wallpapers == 1 )); then
    echo
    if [[ -d "$WALLPAPERS_DIR/.git" ]]; then
        echo "==> 壁纸仓库已存在，执行 pull"
        git -C "$WALLPAPERS_DIR" pull --ff-only
    elif [[ -d "$WALLPAPERS_DIR" && -n "$(ls -A "$WALLPAPERS_DIR" 2>/dev/null)" ]]; then
        echo "==> $WALLPAPERS_DIR 非空且不是 git 仓库，跳过（请手动处理）"
    else
        echo "==> 克隆壁纸仓库到 $WALLPAPERS_DIR"
        git clone "$WALLPAPERS_REPO" "$WALLPAPERS_DIR"
    fi
fi

echo
echo "==> 完成"
