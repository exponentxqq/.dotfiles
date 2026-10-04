# dsh (DeepSeek Harness) 配置

统一管理 dsh 的 profile 配置与自定义插件。运行时数据（API Key、会话）不在本目录，见下文「挂载机制」。

## 目录结构

| 路径                               | 说明                                                                 |
| ---------------------------------- | -------------------------------------------------------------------- |
| `profiles/<name>/cordis.patch.yml` | 用户配置层（主题、默认模型、provider 等），每个 profile 一份          |
| `profiles/<name>/package.json`     | profile manifest：bundles 列表与树外插件依赖（由 pnpm / dsh plugin 维护） |
| `plugins/<name>/`                  | 自定义插件源码（官方组合包 bundle 形式）                              |
| `install.sh`                       | 安装脚本：纳管旧布局 profile、保障目录，幂等可重复执行                |

## 挂载机制

dsh 容器（`~/develop/docker`）通过 compose volume 把 `profiles/` 挂进容器：

```
~/develop/dotfiles/dsh/profiles  →  /home/docker/.dsh/profiles
        （宿主，版本管理）              （容器，dsh profile 根）
```

- 映射的宿主路径由 docker 仓库 `.env` 的 `DSH_HOST_PROFILES_PATH` 配置
- dsh 在容器内读写的 `~/.dsh/profiles` 实际落盘到本仓库，改动双向即时可见
- `node_modules/`、`.pnpm-store/`、`.plugin-manager/` 等运行产物会被 gitignore 忽略（依赖锁文件入库）
- credentials、sessions、storages 等运行时数据仍在 `/data/dsh`（`DSH_HOST_DATA_PATH`），**不入库**

> **重要**：`/data/dsh/profiles` 是容器内 `~/.dsh/profiles` 的嵌套挂载点，容器运行期间
> 宿主侧**必须保留该目录，切勿删除**——删除会使容器内挂载失效，profile 会回落到宿主目录
> 并被 dsh 按模板重新初始化到宿主机。Docker 仅在容器启动时自动创建，`install.sh` 会主动保障其存在。

## 安装

```bash
sh ~/develop/dotfiles/dsh/install.sh
```

首次纳管：若 `/data/dsh/profiles` 下仍有旧布局的 profile 目录，脚本会将其移入本仓库。

修改 `cordis.patch.yml` 后：dsh 运行中（启用 HMR）会自动重载配置；否则重启容器生效：

```bash
cd ~/develop/docker && docker compose restart dsh
```

### 常用命令

```bash
cd ~/develop/docker

./bin/dsh --profile web --dump-config          # 查看合成后的配置树（含各 patch 层）
./bin/dsh --profile web --dump-config-schema   # 校验配置 schema（会 import 插件，可验证插件可加载）
docker compose logs dsh | grep "dsh web:"      # 取带 token 的启动 URL
```

## 自定义插件

插件采用官方组合包（bundle）形式，一个插件一个目录：

```
plugins/<name>/
├── package.json       # name 建议 dsh-plugin-<name>；声明 dsh.bundle.patch
├── cordis.patch.yml   # insert 本包注册的插件行（按包名引用）
└── index.js           # 插件实现（纯 ESM，导出 name / apply）
```

安装到 profile（容器内路径与宿主一致，用绝对路径即可）：

```bash
cd ~/develop/docker
./bin/dsh plugin --profile web add /home/xuqinqin/develop/dotfiles/dsh/plugins/hello
```

`dsh plugin add` 会自动完成两件事：

1. 以 `link:` 形式写入 profile 的 `package.json` 依赖（pnpm symlink 指向源码目录，**改源码重启 profile 即生效**，无需重装）
2. 因包声明了 `dsh.bundle`，自动把包名追加进 `dsh.profile.bundles` 列表并激活其 patch 层

移除：

```bash
./bin/dsh plugin --profile web remove dsh-plugin-<name>
```

`plugins/hello/` 是可直接复制的示例包（也可复制为新插件目录后改名）。

### 插件开发文档（官方）

- [第一个插件](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/index.zh.md)
- [开发一个工具](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/tool.zh.md)
- [打包与安装插件](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/publish.zh.md)

## 升级注意

dsh 处于 developer preview，官方声明存在破坏性变更。升级 `DSH_VERSION` 前：

1. 提交本仓库改动（`git status` / `git diff`）
2. 备份 `/data/dsh`（credentials、sessions）
3. 升级后执行 `--dump-config` 与 `--dump-config-schema` 检查 patch 兼容性
