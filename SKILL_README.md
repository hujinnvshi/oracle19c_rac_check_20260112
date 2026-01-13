# Oracle RAC 19c 集群管理 Skill

> 可复用的Oracle RAC集群管理技能包
> 适用于任何Oracle RAC 19c环境的检查、配置和维护

## 📋 Skill说明

本Skill提供完整的Oracle RAC 19c集群管理流程，包括：
- 自动化检查脚本
- 配置管理
- 问题诊断
- 优化建议
- 维护文档

## 🚀 快速开始

### 使用本Skill管理新RAC环境

**前置条件**:
1. 两节点Oracle RAC 19c集群
2. root用户SSH访问权限
3. Python 3.x (可选，用于高级功能)

**使用步骤**:

1. **准备环境配置文件**
   ```bash
   # 创建环境配置
   cp env_config.example.sh env_config.sh

   # 编辑配置文件
   vi env_config.sh
   ```

2. **配置环境变量**
   ```bash
   # 在env_config.sh中设置
   NODE1="新环境节点1IP"
   NODE2="新环境节点2IP"
   REMOTE_USER="root"
   CLUSTER_NAME="集群名称"
   DB_NAME="数据库名"
   ```

3. **生成定制化脚本**
   ```bash
   ./scripts/generate_custom_scripts.sh env_config.sh
   ```

4. **执行检查**
   ```bash
   ./scripts/rac_quick_check.sh
   ```

## 📁 目录结构

```
oracle_rac_19c_skill/
│
├── 📄 README.md                    # 本文档
├── 📄 QUICK_START.md              # 快速开始指南
│
├── 📂 templates/                  # 模板文件
│   ├── env_config.example.sh      # 环境配置模板
│   ├── crontab.template           # 定时任务模板
│   └── maintenance_plan.md        # 维护计划模板
│
├── 📂 scripts/                    # 核心脚本
│   ├── generate_custom_scripts.sh # 生成定制脚本
│   ├── init_rac_env.sh            # 初始化RAC环境
│   ├── rac_full_checkup.sh        # 完整检查
│   └── health_check/              # 健康检查脚本
│
├── 📂 docs/                       # 文档
│   ├── best_practices.md          # 最佳实践
│   ├── troubleshooting.md         # 故障排查
│   └── optimization_guide.md      # 优化指南
│
└── 📂 environments/               # 环境目录
    ├── prod_rac01/                # 生产环境1
    ├── test_rac01/                # 测试环境1
    └── dev_rac01/                 # 开发环境1
```

## 🛠️ 核心功能

### 1. 环境管理

#### 创建新环境
```bash
# 使用模板创建新环境
./scripts/init_rac_env.sh \
  --name "新环境名称" \
  --node1 "节点1IP" \
  --node2 "节点2IP" \
  --cluster "集群名" \
  --database "数据库名"
```

#### 环境配置文件格式
```bash
# environments/production/env_config.sh
NODE1="192.168.1.101"
NODE2="192.168.1.102"
REMOTE_USER="root"
CLUSTER_NAME="rac-prod"
DB_NAME="PRODDB"

# 环境特定配置
ENV_TYPE="production"
BACKUP_RETENTION_DAYS=30
MONITORING_ENABLED="yes"
```

### 2. 标准化检查流程

#### 自动化检查清单
```bash
# 完整检查（约30分钟）
./scripts/rac_full_checkup.sh --env production

# 快速检查（约5分钟）
./scripts/rac_full_checkup.sh --env production --mode quick

# 只检查特定项
./scripts/rac_full_checkup.sh --env production --check cluster,storage,performance
```

#### 检查项目
- [ ] 集群ware状态
- [ ] 节点状态
- [ ] 资源状态
- [ ] 数据库实例
- [ ] ASM磁盘组
- [ ] 表空间使用率
- [ ] 网络配置
- [ ] 系统资源
- [ ] 备份状态
- [ ] 安全配置

### 3. 报告生成

#### 自动生成报告
```bash
# 生成完整报告
./scripts/generate_report.sh --env production --type full

# 生成对比报告
./scripts/generate_report.sh --env production --compare test_rac01

# 生成趋势报告
./scripts/generate_report.sh --env production --trend 30days
```

### 4. 问题诊断

#### 自动诊断流程
```bash
# 诊断问题
./scripts/diagnose.sh --env production --issue "集群资源离线"

# 自动修复尝试
./scripts/diagnose.sh --env production --issue "表空间满" --auto-fix

# 生成诊断报告
./scripts/diagnose.sh --env production --full-scan
```

## 📊 环境对比

### 多环境管理

```bash
# 查看所有环境
./scripts/list_environments.sh

# 对比环境配置
./scripts/compare_environments.sh production test_rac01

# 批量操作
./scripts/batch_operation.sh --envs "production,test" --operation "check_cluster"
```

## 🔧 自定义和扩展

### 添加自定义检查项

```bash
# 在scripts/health_check/目录下添加
vi scripts/health_check/custom_check.sh

# 在环境配置中启用
echo "CUSTOM_CHECKS=(custom_check)" >> environments/production/config.sh
```

### 集成现有工具

```bash
# 集成Claude Code
./scripts/claude_integration.sh --env production --analyze

# 集成监控工具
./scripts/monitoring_integration.sh --env production --platform "prometheus"
```

## 📖 使用场景

### 场景1: 新环境初次检查
```bash
# 1. 创建环境配置
./scripts/init_rac_env.sh --name "new_rac" --node1 "10.0.0.1" --node2 "10.0.0.2"

# 2. 执行完整检查
./scripts/rac_full_checkup.sh --env new_rac --mode full

# 3. 生成报告
./scripts/generate_report.sh --env new_rac --type full

# 4. 提供优化建议
./scripts/optimization_analyzer.sh --env new_rac
```

### 场景2: 日常巡检
```bash
# 快速检查所有环境
./scripts/batch_operation.sh --all-envs --operation "quick_check"

# 生成巡检报告
./scripts/generate_daily_report.sh --all-envs
```

### 场景3: 问题排查
```bash
# 诊断问题
./scripts/diagnose.sh --env production --issue "性能慢"

# 查看历史数据
./scripts/history_analyzer.sh --env production --days 7
```

### 场景4: 环境迁移
```bash
# 导出配置
./scripts/export_config.sh --env production > prod_config.tar.gz

# 导入到新环境
./scripts/import_config.sh --source prod_config.tar.gz --env new_env
```

## 🎓 最佳实践

### 环境命名规范
```
{类型}_{位置}_{编号}

示例:
- prod_beijing_rac01    # 北京生产集群1
- prod_shanghai_rac01    # 上海生产集群1
- test_beijing_rac01     # 北京测试集群1
- dev_beijing_rac01      # 北京开发集群1
```

### 配置管理
1. **版本控制**: 所有环境配置纳入Git
2. **变更记录**: 使用变更日志记录配置修改
3. **权限管理**: 不同环境使用不同的SSH密钥

### 报告管理
1. **定期生成**: 每日/每周/每月自动生成
2. **归档保存**: 历史报告保存至少1年
3. **趋势分析**: 定期分析性能趋势

## 🔐 安全考虑

### 密码管理
```bash
# 使用环境变量
export ORACLE_PASSWORD="password"

# 或使用加密配置文件
./scripts/encrypt_config.sh --env production
```

### 权限控制
```bash
# 限制脚本执行权限
chmod 750 scripts/*.sh

# 使用sudo执行特定操作
sudo -u oracle ./scripts/database_check.sh
```

## 📞 故障排查

### 常见问题

**Q: 脚本执行失败**
```bash
# 检查环境配置
cat environments/production/env_config.sh

# 验证SSH连接
ssh root@$NODE1 hostname

# 查看详细日志
./scripts/rac_full_checkup.sh --env production --debug
```

**Q: 报告生成失败**
```bash
# 检查报告目录权限
ls -ld reports/production/

# 查看错误日志
tail -f logs/production_error.log
```

## 📚 相关文档

- **QUICK_START.md** - 快速开始指南
- **best_practices.md** - 最佳实践
- **troubleshooting.md** - 故障排查
- **optimization_guide.md** - 优化指南

## 🔄 版本历史

- **v1.0** (2026-01-12) - 初始版本
  - 基础检查功能
  - 环境管理
  - 报告生成

## 💡 贡献指南

改进本Skill:
1. Fork项目
2. 创建feature分支
3. 提交改进
4. 创建Pull Request

---

**Skill版本**: 1.0
**适用版本**: Oracle RAC 19c
**维护状态**: 活跃维护
**许可证**: 内部使用
