# 🚀 AstroNvimV5 Configuration

Welcome to my customized AstroNvimV5 configuration! This setup has been optimized for an efficient and powerful development workflow. Below, you'll find all the details on how to install, configure, and use this setup, along with some helpful tips and tricks.

---

## 🔧 Features

This configuration supports development in the following languages:

| Language   | AutoCompletion | Debug |
| ---------- | -------------- | ----- |
| Typescript | ✅             | ✅    |
| Vue        | ✅             | ✅    |
| React      | ✅             | ✅    |
| Solid      | ✅             | ✅    |
| Angular    | ✅             | ✅    |
| Node       | ✅             | ✅    |
| Python     | ✅             | ✅    |
| Rust       | ✅             | ✅    |
| Go         | ✅             | ✅    |

- **TypeScript**: `vtsls`.
- **Vue**: `volar2`.
- **React**: `vtsls`.
- **Angular**: `angular server`.
- **Node**: `vtsls`.
- **Python**: `basedpyright`.
- **Go**: `gopls`.
- **Rust**: `rust-analyzer`.
- **Markdown**: `markdown-preview.nvim`.

## Database Query

- Support full syntax hints at query time, including database tables & table columns.
- Supports a modern array of backends, including NoSQL databases:
  - Big Query
  - ClickHouse
  - DuckDB
  - Impala
  - jq
  - MongoDB
  - MySQL
  - MariaDB
  - Oracle
  - osquery
  - PostgreSQL
  - Presto
  - Redis
  - Snowflake
  - SQL Server
  - SQLite
  - Your own easily implemented adapter

![mysql_query](assets/imgs/mysql_query.png)

---

## 🛠️ Installation

### 1. Install Lua 5.1

Neovim requires LuaJIT, so Lua 5.1 is currently the best version to use. [Why Neovim uses Lua 5.1](https://neovim.io/doc/user/lua.html).

#### Install Luarocks

```bash
wget https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz
tar zxpf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1

./configure --lua-version=5.1 --lua-suffix=5.1
make
sudo make install

luarocks --version
```

#### Install Lua 5.1

```bash
wget https://www.lua.org/ftp/lua-5.1.5.tar.gz
tar zxpf lua-5.1.5.tar.gz
cd lua-5.1.5

# For macOS
make macosx

make test
sudo make install

which lua
lua -v
```

### 2. Ensure System Commands Are Available

Make sure the following commands are installed on your system:

- `npm`
- `rustc`
- `go`
- `tmux`

### 3. Install Dependencies

Use `brew`, `npm`, and `pip` to install the necessary dependencies:

```bash
# Homebrew packages
brew install fzf fd lazygit ripgrep gdu bottom protobuf gnu-sed ast-grep lazydocker trash imagemagick chafa delta coreutils

# Node.js packages
npm install -g tree-sitter-cli neovim @styled/typescript-styled-plugin

# Python packages, for render-markdown.nvim
pip install pynvim pylatexenc
```

### 4. Install AstroNvim

Backup your existing Neovim configuration and clone the customized AstroNvim setup:

```bash
mv ~/.config/nvim ~/.config/nvim.bak
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim

# Clone the customized AstroNvim configuration
git clone https://github.com/chaozwn/astronvim_with_coc_or_mason ~/.config/nvim
```

---

## 🖥️ Workflow Screenshots

Here are some screenshots showcasing the workflow with `kitty`, `tmux`, `yazi`, and AstroNvim.

### Kitty + tmux + AstroNvim

![homepage](assets/imgs/homepage.png)

### Kitty

![wezterm](assets/imgs/wezterm.png)

### tmux

![tmux](assets/imgs/tmux.png)

### yazi

![yazi](assets/imgs/yazi.png)

---

## 🔗 Other Configurations

- **Kitty**: [https://github.com/chaozwn/kitty](https://github.com/chaozwn/kitty)
- **tmux**: [https://github.com/chaozwn/tmux](https://github.com/chaozwn/tmux)
- **yazi**: [https://github.com/chaozwn/yazi](https://github.com/chaozwn/yazi)

---

## 🦀 Rust Development Note

When working with Rust, note that `rustup` and `mason` install `rust-analyzer` differently, which may cause some [bugs](https://github.com/rust-lang/rust-analyzer/issues/17289). Manual installation is recommended:

```bash
rustup component add rust-analyzer
```

---

## 💡 Tips & Tricks

### Use Lazygit

Trigger command: `<leader>tl`

![lazygit](assets/imgs/lazygit.png)

### Install Bottom

Trigger command: `<Leader>tt`

```bash
brew install bottom
```

![bottom](assets/imgs/bottom.png)

### Neovim Requirements

Ensure Neovim dependencies are installed

```bash
# Install Neovim dependencies
npm install -g neovim
pip install pynvim
```

### Markdown Image Paste

To enable image pasting in Markdown files, install the `pngpaste` Python package:

```bash
brew install pngpaste
```

### Show Image in Neovim

Add to `.zshrc` and `.bashrc`

```bash
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"
```

### Input Method Auto Switch

```bash
brew install --cask squirrel
```

modify `squirrel.custom.yaml`

```yaml
patch:
  show_notifications_when: always # status notification，always open（always）always close（never）

  # support auto switch in vim mode
  app_options:
    org.vim.MacVim:
      no_inline: true
      vim_mode: true
    uk.foon.Neovim:
      no_inline: true
      vim_mode: true
    com.qvacua.VimR:
      no_inline: true
      vim_mode: true
    com.ident.goneovim:
      no_inline: true
      vim_mode: true
    com.googlecode.iterm2:
      no_inline: true
      vim_mode: false
    com.apple.Terminal:
      no_inline: true
      vim_mode: false
    #com.apple.iWork.Numbers:
    #no_inline: true
    com.alfredapp.Alfred:
      ascii_mode: true
    com.jetbrains.intellij:
      vim_mode: true
    com.jetbrains.datagrip:
      vim_mode: true
    com.jetbrains.WebStorm:
      vim_mode: true
    # Obsidian
    md.obsidian:
      vim_mode: true
    net.kovidgoyal.kitty:
      vim_mode: true
    # AntDraw in Edge
    com.microsoft.edgemac.app.jndbnbljngolcchhjbajncidekccnlck:
      no_inline: true
    # AntDraw in Chrome
    com.google.Chrome.app.jndbnbljngolcchhjbajncidekccnlck:
      no_inline: true
```

### minial start

```shell
nvim -u /Users/jayce.zhao/.config/nvim/mini_astronvim.lua .
```

---

## 🎛️ General Mappings

Here are the general key mappings for this configuration:

| Action                          | Keybinding          |
| ------------------------------- | ------------------- |
| **Leader key**                  | `Space`             |
| **Resize up**                   | `Ctrl + Up`         |
| **Resize down**                 | `Ctrl + Down`       |
| **Resize left**                 | `Ctrl + Left`       |
| **Resize right**                | `Ctrl + Right`      |
| **Move to upper window**        | `Ctrl + k`          |
| **Move to lower window**        | `Ctrl + j`          |
| **Move to left window**         | `Ctrl + h`          |
| **Move to right window**        | `Ctrl + l`          |
| **Force write**                 | `Ctrl + s`          |
| **Force quit**                  | `Ctrl + q`          |
| **New file**                    | `Leader + n`        |
| **Close buffer**                | `Leader + c`        |
| **Next tab (real Vim tab)**     | `]t`                |
| **Previous tab (real Vim tab)** | `[t`                |
| **Toggle comment**              | `Leader + /`        |
| **Horizontal split**            | `\`                 |
| **Vertical split**              | <code>&#124;</code> |

---

## 📝 Notes

### LSP Hover Information

You can use `vim.lsp.buf.hover()` to display hover information about the symbol under the cursor in a floating window. Calling the function twice will jump into the floating window.

- **Keybinding**: `KK`

### Setting DAP Breakpoints

To quickly set a DAP (Debug Adapter Protocol) breakpoint, use `<Ctrl-LeftClick>` on the line number.

---

## 🧑‍💻 Supported Neovim Version

This configuration supports Neovim version `>= 0.10`.

---

## 📝 License

This configuration is open-source and available under the [MIT License](https://opensource.org/licenses/MIT).

---

Feel free to explore, customize, and enjoy this powerful Neovim setup! If you have any questions or encounter issues, don't hesitate to reach out.

Happy coding! 🚀

---
