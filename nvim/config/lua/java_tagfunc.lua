-- java_tagfunc.lua
-- 包装 vim.lsp.tagfunc：返回 {} 而非 vim.NIL，防止 Vim 回落到文件 tags 触发 E433/E426。
-- 当 jdtls 未索引完时只静默无结果，不报 "No tags file"。
local M = {}

function M.tagfunc(pattern, flags)
    local ok, result = pcall(vim.lsp.tagfunc, pattern, flags)
    if not ok then
        return {}
    end
    -- vim.NIL 会触发 tags 文件回落 → E433；改为返回 {}（"tag not found" 但不报 E433）
    if result == nil or result == vim.NIL then
        return {}
    end
    return result
end

return M
