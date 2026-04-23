-- Java：用 google-java-format，与项目 Gradle Spotless 的 googleJavaFormat() 默认版本一致（spotless-lib 2.45 → GJF 1.19.2），
-- 避免保存时 conform 无 java 格式化器而回退到 jdtls（Eclipse）导致与 spotlessApply 不一致。
-- JAR：~/.local/share/nvim/google-java-format/google-java-format-1.19.2-all-deps.jar（需 JDK 11+ 的 java 可执行文件）。

local GJF_VERSION = "1.19.2"
local gjf_jar = vim.fn.stdpath("data") .. "/google-java-format/google-java-format-" .. GJF_VERSION .. "-all-deps.jar"

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.java = { "google-java-format" }

    opts.formatters = opts.formatters or {}
    local base = opts.formatters["google-java-format"] or {}
    local gjf_override = {}
    if vim.uv.fs_stat(gjf_jar) then
      gjf_override = {
        command = "java",
        args = { "-jar", gjf_jar, "-" },
      }
    end
    opts.formatters["google-java-format"] = vim.tbl_extend("force", base, gjf_override)

    return opts
  end,
}
