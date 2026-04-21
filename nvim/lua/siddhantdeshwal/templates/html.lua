local M = {}

M.lines = function()
    return {
        "<!DOCTYPE html>",
        '<html lang="en">',
        "<head>",
        '    <meta charset="UTF-8">',
        '    <meta name="viewport" content="width=device-width, initial-scale=1.0">',
        "    <title>Document</title>",
        "</head>",
        "<body>",
        "    ",
        "</body>",
        "</html>",
    }
end

M.cursor_offset = -3 -- land inside <body>

return M
