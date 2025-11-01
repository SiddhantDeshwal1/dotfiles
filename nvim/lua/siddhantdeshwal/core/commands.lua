vim.api.nvim_create_user_command("Runcpp", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r") -- same as file but without extension

  -- Compile the file
  os.execute("g++ -std=c++20 -O2 -Wall " .. file .. " -o " .. output)

  -- Check if any terminal buffer is open
  local term_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      term_buf = buf
      break
    end
  end

  -- Open terminal if none
  if not term_buf then
    vim.cmd("split | terminal")
    term_buf = vim.api.nvim_get_current_buf()
  else
    vim.api.nvim_set_current_buf(term_buf)
  end

  -- Run the program
  local cmd = output
  vim.fn.chansend(vim.b.terminal_job_id, "./" .. vim.fn.fnamemodify(output, ":t") .. "\n")
end, {})
