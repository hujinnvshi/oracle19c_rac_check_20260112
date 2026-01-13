# Claude Code 自动化功能指南

## 📋 概述

Claude Code **没有传统的"全自动模式"**，但提供了多种**半自动化功能**，可以实现高度自动化的工作流程。

## 🚀 Claude Code 的自动化功能

### 1. Headless 模式 (主要自动化方式)

**非交互式执行**，适合集成到脚本和CI/CD：

```bash
claude -p "Your task description" \
  --allowedTools "Bash,Read,Write" \
  --output-format json
```

**关键特性**:
- ✅ 无需UI交互
- ✅ JSON格式输出
- ✅ 可限制工具使用
- ✅ 程序化控制

**实际应用示例**:

```bash
# 自动诊断Oracle问题
claude -p "分析以下RAC集群状态并诊断问题: $(cat cluster_status.txt)" \
  --allowedTools "Bash,Read" \
  --output-format json > diagnosis_result.json
```

### 2. 内置子代理 (自动执行特定任务)

| 子代理 | 功能 | 使用场景 |
|--------|------|----------|
| **Code Reviewer** | 代码审查 | 自动检查代码质量 |
| **Test Runner** | 运行测试 | 自动测试验证 |
| **Explore Agent** | 快速探索 | 理解代码库结构 |
| **Plan Agent** | 方案设计 | 规划实施步骤 |

**使用示例**:

```bash
# 让Explore Agent分析代码库
我需要快速了解这个Oracle RAC项目的结构，主要关注哪些部分？
```

### 3. 自定义 Slash Commands

创建可重复使用的自动化命令：

```bash
# 在项目CLAUDE.md中定义
rac-diagnose: |
  诊断Oracle RAC集群问题

  claude -p "诊断RAC集群: {{input}}" \
    --append-system-prompt "你是Oracle专家..." \
    --allowedTools "Bash,Read,Grep"
```

### 4. 多轮对话 (Session管理)

```bash
# 启动会话
SESSION_ID=$(claude -p "分析RAC状态" --output-format json | jq -r '.sessionId')

# 继续会话
claude --resume "$SESSION_ID" -p "现在生成优化报告"
```

## 💡 在Oracle RAC项目中的应用

### 已创建的自动化脚本

#### 1. claude_auto_rac_helper.sh

**功能**: 结合Claude Code的半自动化RAC管理工具

```bash
cd scripts
./claude_auto_rac_helper.sh
```

**菜单选项**:
1. 自动诊断集群问题
2. 自动生成优化报告
3. 自动审查RAC脚本
4. 自动生成维护计划
5. 使用Claude分析日志

**特点**:
- 使用Claude Code headless模式
- JSON格式输出结果
- 会话文件可追溯

#### 2. auto_rac_monitor.sh

**功能**: 自动监控和响应系统

```bash
# 单次检查
./scripts/auto_rac_monitor.sh single

# 守护进程模式
./scripts/auto_rac_monitor.sh daemon
```

**监控项目**:
- 表空间使用率
- 集群状态
- 数据库实例
- 磁盘空间

**自动响应**:
- 检测到问题时自动分析
- 可配置自动修复操作
- 集成Claude Code分析

## 📊 自动化级别对比

| 级别 | 模式 | 需要人工介入 | 适用场景 |
|------|------|-------------|----------|
| **全手动** | 交互式对话 | 高 | 复杂决策 |
| **半自动** | Headless + 脚本 | 中 | 重复性任务 |
| **自动监控** | 守护进程 | 低 | 7×24监控 |
| **全自动** | 脚本 + Claude | 极低 | 标准化操作 |

## 🛠️ 实战案例

### 案例1: 自动化故障诊断

```bash
#!/bin/bash
# 自动故障诊断脚本

# 1. 收集信息
./rac_quick_check.sh > status.txt

# 2. Claude分析
RESULT=$(claude -p "诊断这个RAC集群问题: $(cat status.txt)" \
  --output-format json)

# 3. 解析结果
echo "$RESULT" | jq '.text' > diagnosis_report.txt

# 4. 根据建议执行
echo "$RESULT" | jq '.text' | grep "建议:" | while read suggestion; do
    echo "执行: $suggestion"
    # 这里可以添加自动执行逻辑
done
```

### 案例2: 自动化代码审查

```bash
#!/bin/bash
# 自动代码审查

for script in scripts/*.sh; do
    echo "审查: $script"

    claude -p "审查这个Oracle脚本的代码质量: $(cat $script | head -100)" \
      --append-system-prompt "关注: 安全性、错误处理、性能" \
      --allowedTools "Read,Grep" \
      > "reviews/$(basename $script).review.txt"
done
```

### 案例3: 自动化日志分析

```bash
#!/bin/bash
# 自动分析Oracle日志

LOG_FILE="/u01/app/oracle/diag/rdbms/orcl/orcl1/trace/alert_orcl1.log"

claude -p "分析Oracle Alert日志中的错误:
文件: $LOG_FILE
时间范围: 最近24小时

请提供:
1. ORA-错误统计
2. 严重程度分析
3. 根因分析
4. 解决方案" \
  --allowedTools "Read,Grep,Bash" \
  > "log_analysis_$(date +%Y%m%d).txt"
```

## ⚙️ 配置Claude Code自动化

### 安装Claude Code CLI

```bash
# macOS
brew tap anthropic/claude
brew install claude

# Linux
curl -fsSL https://code.anthropic.com/install.sh | sh

# 验证安装
claude --version
```

### 配置文件

创建 `~/.claude/config.json`:

```json
{
  "allowedTools": ["Bash", "Read", "Write", "Grep"],
  "permissionMode": "acceptEdits",
  "defaultModel": "claude-sonnet-4-5-20250929",
  "maxTokens": 200000
}
```

### 权限管理

```bash
# 允许所有工具（谨慎使用）
claude -p "task" --permission-mode acceptEdits

# 限制工具（推荐）
claude -p "task" --allowedTools "Read,Grep"

# 仅读取操作
claude -p "task" --allowedTools "Read"
```

## 🎯 最佳实践

### 1. 安全性

✅ **推荐做法**:
```bash
# 限制工具使用
claude -p "task" --allowedTools "Read,Grep"
```

❌ **避免**:
```bash
# 不要在关键系统上使用acceptEdits
claude -p "task" --permission-mode acceptEdits
```

### 2. 错误处理

```bash
# 检查退出码
if claude -p "task" --output-format json > result.json; then
    echo "成功"
    # 处理结果
else
    echo "失败"
    exit 1
fi
```

### 3. 会话管理

```bash
# 保存会话ID
SESSION_ID=$(claude -p "first task" --output-format json | jq -r '.sessionId')

# 后续使用
claude --resume "$SESSION_ID" -p "follow-up task"
```

### 4. 日志记录

```bash
# 记录所有Claude操作
claude -p "task" --output-format json 2>&1 | tee claude_$(date +%Y%m%d).log
```

## 📈 集成到现有工具

### 与cron集成

```bash
# crontab -e
# 每小时自动检查
0 * * * * cd /path/to/project && ./scripts/auto_rac_monitor.sh single

# 每日完整检查
0 2 * * * cd /path/to/project && ./scripts/claude_auto_rac_helper.sh
```

### 与现有脚本集成

```bash
# 在现有脚本中调用Claude
#!/bin/bash

# 传统检查
./rac_quick_check.sh > status.txt

# 如果发现问题，使用Claude分析
if grep -q "ERROR" status.txt; then
    claude -p "分析这些错误: $(cat status.txt)" \
      --allowedTools "Read" \
      > claude_analysis.txt
fi
```

### CI/CD集成

```yaml
# .github/workflows/rac-check.yml
name: RAC Health Check

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨2点

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Run RAC check
        run: |
          ./scripts/rac_quick_check.sh

      - name: Claude analysis
        run: |
          claude -p "分析RAC健康检查结果" \
            --allowedTools "Read" \
            --output-format json
```

## 🔒 安全注意事项

### ⚠️ 重要警告

1. **不要在关键生产环境使用acceptEdits模式**
   - Claude可能修改文件
   - 建议使用Read模式，人工审查后再应用

2. **限制工具权限**
   ```bash
   # 推荐
   --allowedTools "Read,Grep"

   # 不推荐
   --allowedTools "Bash,Write,Edit"
   ```

3. **审查自动生成的脚本**
   - 在执行前始终审查Claude生成的代码
   - 在测试环境先验证

4. **保护敏感信息**
   - 不要在提示中包含密码
   - 使用环境变量传递敏感信息

## 📚 相关资源

### 官方文档

- [Headless模式](https://code.claude.com/docs/en/headless.md)
- [CLI参考](https://code.claude.com/docs/en/cli-reference.md)
- [Slash命令](https://code.claude.com/docs/en/custom-commands.md)
- [权限管理](https://code.claude.com/docs/en/permissions.md)

### 本项目工具

1. **scripts/claude_auto_rac_helper.sh** - Claude辅助的RAC管理
2. **scripts/auto_rac_monitor.sh** - 自动监控脚本

## 💬 常见问题

### Q: Claude Code能完全自动化吗？

A: 不能。Claude Code需要：
- 明确的任务描述
- 人工监督和验证
- 在关键操作上人工确认

最佳实践是：**半自动化**，Claude提供建议，人工做最终决策。

### Q: Headless模式安全吗？

A: 如果配置得当：
- ✅ 限制工具权限
- ✅ 审查输出
- ✅ 在测试环境验证

则相对安全。但始终建议在非关键系统上使用。

### Q: 能替代DBA吗？

A: 不能。Claude Code是**辅助工具**：
- ✅ 帮助收集和分析信息
- ✅ 提供优化建议
- ✅ 自动化重复性任务
- ❌ 不能替代专业判断
- ❌ 不能处理复杂故障

## 🎓 总结

Claude Code的自动化功能：

| 功能 | 自动化程度 | 推荐场景 |
|------|-----------|----------|
| **交互式对话** | 低 | 复杂问题、学习 |
| **Headless模式** | 中 | 重复性任务、批量处理 |
| **守护进程监控** | 高 | 7×24监控 |
| **Claude + 人工决策** | 最高 | 生产环境推荐 |

**推荐方案**: 使用**半自动化模式**，Claude提供建议和分析，人工做最终决策和执行。

---

**文档更新**: 2026-01-12
**Claude Code版本**: 1.x
**Oracle版本**: 19c
