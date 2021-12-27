-- Function for make mapping easier.
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

additional_plugins = {
  {"ellisonleao/gruvbox.nvim", requires = {"rktjmp/lush.nvim"}}
}

-- Set the "hard" version of the Gruvbox theme.
vim.g.gruvbox_contrast_dark = "hard"
vim.cmd("colorscheme gruvbox")

-- Reduce the width of the sign column and clear its color.
vim.opt.signcolumn = "yes:1"
vim.cmd("highlight clear SignColumn")

-- map("n", "<C-t>", ":ToggleTerm<CR>")
-- map("t", "<C-t>", ":ToggleTerm<CR>")

user_lualine_style = 1 -- You can choose between 1, 2, 3, 4 and 5
user_indent_blankline_style = 1 -- You can choose between 1, 2, 3, 4,5 and 6

