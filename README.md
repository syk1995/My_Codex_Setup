# My Codex Setup

个人 Codex 配置快照，用于在另一台电脑恢复工作环境。

## 仓库内容

- `config.toml`：模型、权限、配置档和 MCP 设置，保留原机器配置。
- `AGENTS.md`：全局编码偏好。
- `rules/default.rules`：原机器保存的命令批准规则。
- `skills/`：个人安装的技能及其脚本、模板、资源。

不包含登录凭据 `auth.json`、对话历史、运行缓存、插件缓存和 Codex 内置的 `skills/.system/`。内置技能由 Codex 安装提供，插件请在新电脑按需重新安装或连接。本仓库不包含 MCP 服务源码及其 Python 环境。

## 在新电脑恢复

下面的命令适用于 Linux、macOS 或 WSL。先安装 Codex，再克隆：

```bash
git clone https://github.com/syk1995/My_Codex_Setup.git
cd My_Codex_Setup
```

退出正在运行的 Codex。如果已有配置，先备份，然后复制：

```bash
codex_config_dir="${CODEX_HOME:-$HOME/.codex}"
if [ -d "$codex_config_dir" ]; then
  cp -a "$codex_config_dir" "${codex_config_dir}.backup-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$codex_config_dir/skills" "$codex_config_dir/rules"
cp config.toml AGENTS.md "$codex_config_dir/"
cp -R skills/. "$codex_config_dir/skills/"
```

启动前，编辑目标目录中的 `config.toml`，调整以下原机器路径：

- `[sandbox_workspace_write].writable_roots` 中的工作目录。
- `[projects."..."]` 中的项目目录。
- `[mcp_servers.*].command` 中的启动脚本路径。

原配置中的本地 MCP 启动脚本：

```text
/home/llr/ilc/shi/data/MCP/ParticlePhysics-MCP-Server/run_stdio.sh
/home/llr/ilc/shi/data/MCP/Codex_CustomFuncions/run_stdio.sh
```

需要另外部署这两个 MCP 项目并重建依赖环境；暂时不用时可从新电脑配置中移除对应 MCP 配置块。技能及命令规则中也可能引用原机器的路径。

如需沿用原机器的命令批准规则，检查并调整 `rules/default.rules` 后复制：

```bash
cp rules/default.rules "$codex_config_dir/rules/"
```

安装了 CLI 后，重新登录并查看 MCP 配置：

```bash
codex login
codex mcp list
```

项目自己的 `AGENTS.md` 和 `.codex/` 应随项目仓库另外迁移。此快照保留原设置；新版本若报告某个配置项不受支持，应按该版本提示更新。

## 更新快照

在仓库目录执行，使用正在运行的 Codex 的配置目录作为来源：

```bash
codex_config_dir="${CODEX_HOME:-$HOME/.codex}"
cp "$codex_config_dir/config.toml" "$codex_config_dir/AGENTS.md" .
cp "$codex_config_dir/rules/default.rules" rules/
rsync -a --exclude='.system/' --exclude='__pycache__/' --exclude='*.pyc' --exclude='.venv/' --exclude='node_modules/' "$codex_config_dir/skills/" skills/
git diff
git status --short
git add config.toml AGENTS.md rules skills
git commit -m "Update Codex configuration snapshot"
git push
```

该更新命令不会自动删除旧技能；移除技能时也需要在仓库中删除对应目录。提交前检查配置和规则中没有新增密钥或令牌，凭据应留在本机。

## 官方参考

- [Codex 配置](https://learn.chatgpt.com/docs/config-file/config-basic)
- [登录与凭据存储](https://learn.chatgpt.com/docs/auth)
