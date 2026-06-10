# 补全配置
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# 加载 ~/.completion 目录下所有补全文件
for f in ~/.completion/_*; do
  source "$f"
done
