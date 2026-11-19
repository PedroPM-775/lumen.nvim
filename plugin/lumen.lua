vim.api.nvim_create_user_command("Lumen", function(opts)
  local lumen = require("lumen")
  local reference = vim.trim(opts.args)
  if reference ~= "" then
    lumen.open({ reference = reference })
  else
    lumen.open()
  end
end, {
  nargs = "?",
  desc = "Open lumen diff (default range from config)",
  complete = "file",
})

vim.api.nvim_create_user_command("LumenPick", function()
  require("lumen").pick_diff()
end, {
  desc = "Pick branches and open lumen diff",
})