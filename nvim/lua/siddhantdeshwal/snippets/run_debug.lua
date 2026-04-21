local function run_cp_code()
    -- 1. Auto-save the current file before running
    vim.cmd('silent! write')

    local file = vim.fn.expand('%:p')     -- Full path to file
    local dir = vim.fn.expand('%:p:h')    -- Directory of file
    local filename = vim.fn.expand('%:t') -- File name with extension
    local noext = vim.fn.expand('%:t:r')  -- File name without extension
    local ext = vim.fn.expand('%:e')      -- Extension

    local in_file = dir .. '/input.txt'
    local out_file = dir .. '/output.txt'

    -- 2. Create input file if it doesn't exist so the redirect doesn't fail
    if vim.fn.filereadable(in_file) == 0 then io.open(in_file, "w"):close() end

    local cmd = ""

    -- 3. Build the language-specific execution command
    if ext == "cpp" then
        -- C++: -O3 for max speed, Sanitizers for memory/array bug catching, timeout for infinite loops
        local out_bin = dir .. '/' .. noext .. '.out'
        cmd = string.format(
            '{ g++ -O3 -Wall -Wextra -fsanitize=address,undefined -std=c++20 "%s" -o "%s" 2>&1 && timeout 3s "%s" < "%s" 2>&1 ; } > "%s"',
            file, out_bin, out_bin, in_file, out_file
        )
    elseif ext == "py" then
        -- Python: Direct execution with timeout
        cmd = string.format(
            'timeout 3s python3 "%s" < "%s" > "%s" 2>&1',
            file, in_file, out_file
        )
    elseif ext == "java" then
        -- Java: Compile and run with timeout
        cmd = string.format(
            '{ javac "%s" 2>&1 && timeout 3s java -cp "%s" "%s" < "%s" 2>&1 ; } > "%s"',
            file, dir, noext, in_file, out_file
        )
    else
        vim.notify("Auto-run not supported for: " .. ext, vim.log.levels.WARN)
        return
    end

    vim.notify("Compiling & Running...", vim.log.levels.INFO, { title = "CP Runner" })

    -- 4. Execute asynchronously! (Zero UI freezing)
    vim.fn.jobstart({ "bash", "-c", cmd }, {
        on_exit = function(_, exit_code)
            if exit_code == 124 then
                -- 124 is the standard Linux exit code for the 'timeout' command
                vim.notify("Time Limit Exceeded (3s)", vim.log.levels.ERROR, { title = "CP Runner" })

                -- Append TLE warning directly to the output text file
                local f = io.open(out_file, "a")
                if f then
                    f:write("\n\n[PROCESS KILLED: Time Limit Exceeded (3s Infinite Loop Protection)]")
                    f:close()
                end
            elseif exit_code == 0 then
                vim.notify("Execution Success!", vim.log.levels.INFO, { title = "CP Runner" })
            else
                vim.notify("Finished with Errors.", vim.log.levels.WARN, { title = "CP Runner" })
            end

            -- 5. Force Neovim to refresh the output.txt buffer immediately
            vim.cmd('checktime')
        end
    })
end

-- Bind it to <leader>rd
vim.keymap.set('n', '<leader>rd', run_cp_code, { noremap = true, silent = true, desc = "Run/Debug Code" })

-- Tell Neovim to automatically reload files if they change outside the editor (crucial for output.txt)
vim.opt.autoread = true
