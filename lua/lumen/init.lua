local M = {}

M.config = {
  bin = "lumen",
  --- Branch or ref to compare from (set to false/nil with reference nil for working tree only)
  base = "develop",
  head = "HEAD",
  --- true → develop...HEAD (since merge-base); false → develop..HEAD
  use_triple_dot = true,
  --- Full reference; overrides base/head/dots when set (e.g. "main..feature")
  reference = nil,
  theme = nil,
  watch = false,
  stacked = false,
  file = nil,
  args = "",
  cwd = "git_root", --- "git_root" | "cwd" | absolute path string
  keymap = "<leader>gL",
  ---@type "open"|"pick_diff"
  keymap_action = "pick_diff",
  desc = "Lumen diff",
  snacks_win = {
    position = "float",
    border = "rounded",
    height = 0.92,
    width = 0.92,
  },
}

local function resolve_cwd()
  local c = M.config.cwd
  if c == "cwd" or c == false then
    return vim.loop.cwd()
  end
  if type(c) == "string" and c ~= "git_root" and c ~= "" then
    return c
  end
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = vim.loop.cwd()
  else
    path = vim.fn.fnamemodify(path, ":h")
  end
  return vim.fs.root(path, ".git") or vim.loop.cwd()
end

function M.resolve_reference()
  local ref = M.config.reference
  if ref ~= nil and ref ~= false and ref ~= "" then
    return ref
  end
  local base = M.config.base
  if base == nil or base == false or base == "" then
    return nil
  end
  local dots = M.config.use_triple_dot ~= false and "..." or ".."
  local head = M.config.head or "HEAD"
  return base .. dots .. head
end

local function build_cmd()
  local parts = { M.config.bin or "lumen", "diff" }

  if M.config.theme and M.config.theme ~= "" then
    parts[#parts + 1] = "-t"
    parts[#parts + 1] = M.config.theme
  end
  if M.config.watch then
    parts[#parts + 1] = "-w"
  end
  if M.config.stacked then
    parts[#parts + 1] = "--stacked"
  end
  if M.config.file and M.config.file ~= "" then
    parts[#parts + 1] = "-f"
    parts[#parts + 1] = M.config.file
  end

  local reference = M.resolve_reference()
  if reference then
    parts[#parts + 1] = reference
  end

  local args = M.config.args
  if args and args ~= "" then
    return table.concat(parts, " ") .. " " .. args
  end
  return table.concat(parts, " ")
end

---@param title string
---@param on_pick fun(ref: string)
local function pick_local_branch(title, on_pick)
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    vim.notify("lumen: snacks.picker no disponible", vim.log.levels.ERROR)
    return
  end

  snacks.picker.git_branches({
    all = false,
    title = title,
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local ref = item.branch or item.commit
      if not ref or ref == "" then
        vim.notify("lumen: rama no válida", vim.log.levels.WARN)
        return
      end
      vim.schedule(function()
        on_pick(ref)
      end)
    end,
  })
end

--- Pick head branch, then base branch, and open lumen with `base...head`.
function M.pick_diff()
  pick_local_branch("Lumen: rama (cambios)", function(head)
    pick_local_branch("Lumen: comparar con", function(base)
      M.open({
        base = base,
        head = head,
        use_triple_dot = true,
        reference = nil,
      })
    end)
  end)
end

function M.open(overrides)
  overrides = overrides or {}
  local prev = vim.deepcopy(M.config)
  M.config = vim.tbl_deep_extend("force", M.config, overrides)

  local cmd = build_cmd()
  local cwd = resolve_cwd()
  local snacks_win = vim.deepcopy(M.config.snacks_win)

  M.config = prev

  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.terminal then
    if snacks.terminal.open then
      snacks.terminal.open(cmd, {
        cwd = cwd,
        win = snacks_win,
      })
    else
      snacks.terminal(cmd, { cwd = cwd })
    end
    return
  end

  local tok, toggleterm = pcall(require, "toggleterm.terminal")
  if tok then
    local Terminal = toggleterm.Terminal
    local term = Terminal:new({
      cmd = cmd,
      cwd = cwd,
      direction = "float",
      hidden = true,
      on_open = function()
        vim.cmd("startinsert!")
      end,
    })
    term:toggle()
    return
  end

  local shell_cmd = string.format("cd %s && %s", vim.fn.shellescape(cwd), cmd)
  vim.cmd("tabnew | terminal " .. shell_cmd)
  vim.cmd("startinsert")
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if M.config.keymap then
    local action = M.config.keymap_action == "open" and M.open or M.pick_diff
    local desc = M.config.desc
    if M.config.keymap_action == "pick_diff" and desc == "Lumen diff" then
      desc = "Lumen diff (pick branches)"
    elseif M.config.keymap_action == "open" and desc == "Lumen diff" then
      desc = "Lumen diff (configured range)"
    end
    vim.keymap.set("n", M.config.keymap, function()
      action()
    end, { desc = desc })
  end
end

return M