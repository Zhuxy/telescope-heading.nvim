local telescope_heading = {
    treesitter = false,
    -- Default to showing all heading levels (1-6)
    markdown_headings = {1, 2, 3, 4, 5, 6},
}

telescope_heading.setup = function(opts)
    telescope_heading.picker_opts = opts.picker_opts or {}
    telescope_heading.treesitter = vim.F.if_nil(opts.treesitter, false)
    if opts.markdown_headings ~= nil then
        telescope_heading.markdown_headings = opts.markdown_headings
    end
end

return telescope_heading
