local Markdown = {}
local heading_config = require('telescope._extensions.heading.config')

local function should_include_heading(level)
    for _, l in ipairs(heading_config.markdown_headings or {1, 2, 3, 4, 5, 6}) do
        if l == level then
            return true
        end
    end
    return false
end

function Markdown.get_headings(filepath, start, total)
    local headings = {}
    local index = start
    local patterns = {
        {level = 1, pattern = '# '},
        {level = 2, pattern = '## '},
        {level = 3, pattern = '### '},
        {level = 4, pattern = '#### '},
        {level = 5, pattern = '##### '},
        {level = 6, pattern = '###### '},
    }
    local is_code_block = false
    while index <= total do
        local line = vim.fn.getline(index)
        -- process markdown code blocks
        if vim.startswith(line, '```') then
            is_code_block = not is_code_block
            goto next
        else
            if is_code_block then
                goto next
            end
        end
        -- match heading
        for _, item in ipairs(patterns) do
            if vim.startswith(line, item.pattern) and should_include_heading(item.level) then
                table.insert(headings, {
                    heading = vim.trim(line),
                    line = index,
                    path = filepath,
                })
                break
            end
        end

        ::next::
        index = index + 1
    end

    return headings
end

local function get_heading_level(line)
    local level = 0
    while level < #line and line:sub(level + 1, level + 1) == '#' do
        level = level + 1
    end
    return level
end

function Markdown.ts_get_headings(filepath, bufnr)
    local ts = vim.treesitter
    local query = [[
    (atx_heading) @heading
    ]]
    local parse_query = ts.query.parse or ts.parse_query
    local parsed_query = parse_query('markdown', query)
    local parser = ts.get_parser(bufnr, 'markdown')
    local root = parser:parse()[1]:root()
    local start_row, _, end_row, _ = root:range()

    local headings = {}
    for _, node in parsed_query:iter_captures(root, bufnr, start_row, end_row) do
        local row, _ = node:range()
        local line = vim.fn.getline(row + 1)
        local level = get_heading_level(line)
        if should_include_heading(level) then
            table.insert(headings, {
                heading = vim.trim(line),
                line = row + 1,
                path = filepath,
            })
        end
    end
    return headings
end

return Markdown
