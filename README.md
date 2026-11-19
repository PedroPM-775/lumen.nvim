# lumen.nvim

Launch [lumen](https://github.com/PedroPM-775/lumen) from Neovim: side-by-side diffs between branches, with an optional branch picker.

## Requirements

- [lumen](https://github.com/PedroPM-775/lumen) on your `PATH`
- [snacks.nvim](https://github.com/folke/snacks.nvim) for branch picker (`pick_diff` / `:LumenPick`); terminal also uses snacks when available
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) optional fallback terminal

## Installation

### lazy.nvim

```lua
{
  "PedroPM-775/lumen.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  opts = {
    base = "develop",
    head = "HEAD",
    use_triple_dot = true,
    keymap = "<leader>gL",
    keymap_action = "pick_diff", -- "open" | "pick_diff"
  },
}
```

## Usage

| | |
|---|---|
| `<leader>gL` | Default keymap (see `keymap_action`) |
| `:Lumen` | Open diff with configured `base...head` (default `develop...HEAD`) |
| `:Lumen main..feature` | Explicit git revision range |
| `:LumenPick` | Pick head branch, then base branch, then open lumen |

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `bin` | `"lumen"` | lumen executable |
| `base` | `"develop"` | Base ref |
| `head` | `"HEAD"` | Head ref |
| `use_triple_dot` | `true` | `true` → `base...head`, `false` → `base..head` |
| `reference` | `nil` | If set, overrides `base`/`head` (e.g. `"main..feature"`) |
| `theme` | `nil` | lumen `-t` theme |
| `watch` | `false` | lumen `-w` |
| `stacked` | `false` | `--stacked` |
| `file` | `nil` | `-f` file filter |
| `args` | `""` | Extra CLI args |
| `cwd` | `"git_root"` | `"git_root"`, `"cwd"`, or absolute path |
| `keymap` | `"<leader>gL"` | Set to `false` to disable |
| `keymap_action` | `"pick_diff"` | `"open"` or `"pick_diff"` |
| `desc` | auto | Keymap description |
| `snacks_win` | float 92% | snacks terminal window |

## Terminal backends

1. snacks.nvim terminal
2. toggleterm.nvim
3. `:terminal` in a new tab (git root)