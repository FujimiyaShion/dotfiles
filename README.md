# dotfiles

我的 Arch Linux + niri 个人配置，基于 [GNU Stow](https://www.gnu.org/software/stow/) 管理，一键恢复环境。

## 包含内容

| 目录 | 内容 |
|------|------|
| `zsh/` | .zshrc（starship、zoxide、zsh-autosuggestions、语法高亮） |
| `git/` | .gitconfig |
| `kitty/` | kitty 终端 + Catppuccin 主题 |
| `nvim/` | Neovim 配置（lazy.nvim 插件管理，lazy-lock.json 锁定版本） |
| `niri/` | niri 合成器 config.kdl |
| `fastfetch/` | 系统信息展示 |
| `starship/` | 提示符主题（Catppuccin Macchiato 调色板） |
| `btop/` `cava/` `mpv/` | 终端工具 |
| `fcitx5/` | 输入法 |
| `pacseek/` | AUR 包管理器前端 |
| `go-musicfox/` | 网易云音乐终端客户端 |
| `fontconfig/` | 字体配置 |
| `noctalia/` | niri shell（bar/通知/壁纸）配置 |
| `opencode/` | AI 编程助手配置 |
| `packages/` | pacman 官方包 + AUR 包清单 |

## 新机器一键安装

```bash
# 1. 装 Arch 后先装 yay（AUR helper）
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si

# 2. 克隆本仓库并执行安装
git clone https://github.com/FujimiyaShion/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh    # 交互式安装
```

### 安装选项

`./install.sh` 默认交互式，依次让你：

1. **选择配置**：16 个配置包多选（回车=全选，`n`=跳过，可输编号如 `1 3 5`）
2. **选择软件组**：11 个软件组多选（系统基础/显卡驱动/音频/网络/桌面环境/终端Shell/编辑器开发/输入法字体/影音游戏/办公日常/AUR 应用）
3. **是否下载壁纸**：可选，壁纸在单独仓库 [wallpapers](https://github.com/FujimiyaShion/wallpapers)，会克隆到 `~/Pictures/Wallpapers`（noctalia 默认从这里读壁纸）

非交互模式：

```bash
./install.sh --full      # 全量安装（所有配置 + 所有软件组 + 壁纸）
./install.sh --configs   # 只链接全部配置
./install.sh --pkgs      # 只安装全部软件包
```

> 注意：`packages/pkglist.txt`、`packages/aurlist.txt` 为全量包清单备份，交互模式下的软件组即按此划分。

## 日常更新配置

配置通过符号链接指向本仓库，所以：

1. 直接修改 `~/dotfiles` 里的文件，改动即时生效
2. 提交推送到 GitHub：`cd ~/dotfiles && git add -A && git commit -m "update" && git push`

## 添加新的配置

以添加某个新软件的配置为例：

```bash
mkdir -p ~/dotfiles/<软件名>/.config
mv ~/.config/<软件名> ~/dotfiles/<软件名>/.config/   # 移动进仓库
cd ~/dotfiles && stow -t ~ <软件名>                   # 自动建立符号链接
```
