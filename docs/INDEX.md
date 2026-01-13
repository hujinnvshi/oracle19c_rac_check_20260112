# 📚 文档索引

> Oracle RAC 19c 集群管理工具集 - 完整文档导航

## 🗂️ 目录结构说明

本项目采用清晰的分层结构，便于查找和使用：

```
oracle19c_rac_check_20260112/
│
├── 📜 README.md                  # 项目总览（从这里开始）
├── 📜 INDEX.md                   # 本文档（文档导航）
│
├── 📂 scripts/                   # Shell脚本
│   ├── rac_cluster_manager_full.sh      # ⭐ 综合管理工具
│   ├── rac_cluster_start.sh             # 集群启动
│   ├── rac_cluster_stop.sh              # 集群停止
│   ├── rac_daily_health_check.sh        # 每日健康检查
│   ├── rac_quick_check.sh               # 快速检查
│   ├── rac_tablespace_monitor.sh        # 表空间监控
│   ├── rac_cluster_manager.sh           # 资源管理
│   ├── rac_log_cleanup.sh               # 日志清理
│   └── disable_gui.sh                   # 禁用图形界面
│
├── 📂 docs/                      # 文档目录
│   ├── START_STOP_GUIDE.md              # 启停操作指南
│   ├── TASK_SUMMARY.md                  # 任务完成总结
│   ├── CLUSTER_MANAGEMENT_SUMMARY.md    # 工具集详细说明
│   ├── GUI_DISABLED_FINAL.md            # GUI关闭报告
│   └── GIT_COMMIT_SUMMARY.md            # Git提交总结
│
├── 📂 reports/                   # 报告目录
│   ├── 📂 cluster/                     # 集群报告
│   │   ├── rac_cluster_info.txt         # 集群完整信息
│   │   ├── rac_cluster_status.txt        # CRS状态
│   │   ├── rac_cluster_nodes.txt         # 节点信息
│   │   ├── rac_resources_status.txt      # 资源状态
│   │   ├── rac_vip_status.txt            # VIP状态
│   │   └── rac_asm_diskgroup.txt         # ASM磁盘组
│   │
│   ├── 📂 system/                      # 系统报告
│   │   ├── rac_network_131.txt           # 节点1网络
│   │   ├── rac_network_133.txt           # 节点2网络
│   │   ├── rac_system_131.txt            # 节点1系统
│   │   ├── rac_system_133.txt            # 节点2系统
│   │   ├── rac_performance_131.txt       # 节点1性能
│   │   └── rac_performance_133.txt       # 节点2性能
│   │
│   ├── 📂 gui/                         # GUI报告
│   │   └── gui_status_report.txt         # GUI状态
│   │
│   └── 📂 health/                      # 健康检查
│       └── rac_health_report_*.txt       # 历史报告
│
└── 📂 archive/                   # 存档目录
    ├── rac_autostart_check.txt           # 自启动检查
    ├── rac_node2_autostart.txt           # 节点2自启动
    ├── rac_db_threads.txt                # 数据库线程
    └── rac_db_instance.txt               # 数据库实例
```

## 📖 文档分类导航

### 🚀 快速入门

| 文档 | 路径 | 说明 |
|------|------|------|
| **项目总览** | [README.md](README.md) | 项目概述、快速开始、目录结构 |
| **文档索引** | [docs/INDEX.md](docs/INDEX.md) | 本文档，完整导航 |

### 📘 操作指南

| 文档 | 路径 | 说明 |
|------|------|------|
| **启停指南** | [docs/START_STOP_GUIDE.md](docs/START_STOP_GUIDE.md) | 集群启动停止详细操作指南 |

**适用场景**:
- 需要启动或停止集群
- 想了解正确的启停顺序
- 遇到启停问题需要排查

### 📊 总结报告

| 文档 | 路径 | 说明 |
|------|------|------|
| **任务总结** | [docs/TASK_SUMMARY.md](docs/TASK_SUMMARY.md) | 任务完成情况、集群信息、优化建议 |
| **工具集说明** | [docs/CLUSTER_MANAGEMENT_SUMMARY.md](docs/CLUSTER_MANAGEMENT_SUMMARY.md) | 8个工具脚本的详细说明 |
| **GUI关闭报告** | [docs/GUI_DISABLED_FINAL.md](docs/GUI_DISABLED_FINAL.md) | 图形界面关闭操作和验证 |
| **Git提交总结** | [docs/GIT_COMMIT_SUMMARY.md](docs/GIT_COMMIT_SUMMARY.md) | Git提交内容和文件清单 |

## 🛠️ 脚本工具导航

### 🎯 推荐使用

| 脚本 | 路径 | 用途 | 使用频率 |
|------|------|------|----------|
| **综合管理工具** | [scripts/rac_cluster_manager_full.sh](../scripts/rac_cluster_manager_full.sh) | 集群综合管理 | ⭐⭐⭐⭐⭐ |
| **快速检查** | [scripts/rac_quick_check.sh](../scripts/rac_quick_check.sh) | 快速状态检查 | ⭐⭐⭐⭐⭐ |

### 🔄 启停管理

| 脚本 | 路径 | 功能 |
|------|------|------|
| **集群启动** | [scripts/rac_cluster_start.sh](../scripts/rac_cluster_start.sh) | 安全启动集群 |
| **集群停止** | [scripts/rac_cluster_stop.sh](../scripts/rac_cluster_stop.sh) | 安全停止集群 |

### 📋 监控检查

| 脚本 | 路径 | 功能 | 频率 |
|------|------|------|------|
| **每日健康检查** | [scripts/rac_daily_health_check.sh](../scripts/rac_daily_health_check.sh) | 完整健康检查 | 每日 |
| **表空间监控** | [scripts/rac_tablespace_monitor.sh](../scripts/rac_tablespace_monitor.sh) | 表空间使用率监控 | 每周 |

### 🔧 资源管理

| 脚本 | 路径 | 功能 |
|------|------|------|
| **资源管理工具** | [scripts/rac_cluster_manager.sh](../scripts/rac_cluster_manager.sh) | 快速管理集群资源 |
| **日志清理** | [scripts/rac_log_cleanup.sh](../scripts/rac_log_cleanup.sh) | 清理Oracle日志 |

### ⚙️ 系统配置

| 脚本 | 路径 | 功能 |
|------|------|------|
| **禁用图形界面** | [scripts/disable_gui.sh](../scripts/disable_gui.sh) | 关闭GUI节省资源 |

## 📊 报告文件导航

### 🏢 集群相关报告

**目录**: `reports/cluster/`

| 文件 | 说明 | 查看时机 |
|------|------|----------|
| `rac_cluster_info.txt` | 集群完整配置信息 | 了解集群配置 |
| `rac_cluster_status.txt` | CRS服务状态 | 检查CRS状态 |
| `rac_cluster_nodes.txt` | 节点信息 | 查看节点配置 |
| `rac_resources_status.txt` | 所有资源状态 | 检查资源运行状态 |
| `rac_vip_status.txt` | VIP详细状态 | 检查VIP配置 |
| `rac_asm_diskgroup.txt` | ASM磁盘组信息 | 检查ASM状态 |

**查看命令**:
```bash
cd reports/cluster
cat rac_cluster_info.txt
```

### 💻 系统相关报告

**目录**: `reports/system/`

| 文件 | 说明 | 查看时机 |
|------|------|----------|
| `rac_network_131.txt` | 节点1网络配置 | 检查网络配置 |
| `rac_network_133.txt` | 节点2网络配置 | 检查网络配置 |
| `rac_system_131.txt` | 节点1系统资源 | 检查资源使用 |
| `rac_system_133.txt` | 节点2系统资源 | 检查资源使用 |
| `rac_performance_131.txt` | 节点1性能指标 | 性能分析 |
| `rac_performance_133.txt` | 节点2性能指标 | 性能分析 |

**查看命令**:
```bash
cd reports/system
cat rac_system_131.txt
```

### 🖥️ 图形界面报告

**目录**: `reports/gui/`

| 文件 | 说明 |
|------|------|
| `gui_status_report.txt` | 图形界面状态检查报告 |

### 🏥 健康检查报告

**目录**: `reports/health/`

| 文件 | 说明 | 生成时间 |
|------|------|----------|
| `rac_health_report_*.txt` | 历史健康检查报告 | 按执行时间命名 |

**最新报告**:
```bash
cd reports/health
ls -lt | head -2
```

### 📦 存档文件

**目录**: `archive/`

| 文件 | 说明 |
|------|------|
| `rac_autostart_check.txt` | 开机自启动配置检查 |
| `rac_node2_autostart.txt` | 节点2自启动状态 |
| `rac_db_threads.txt` | 数据库线程信息 |
| `rac_db_instance.txt` | 数据库实例信息 |

## 🔍 快速查找指南

### 我想... 🤔

#### ...查看集群状态
```bash
# 方法1: 使用快速检查脚本（推荐）
cd scripts
./rac_quick_check.sh

# 方法2: 查看历史报告
cat reports/cluster/rac_cluster_status.txt
```

#### ...启动/停止集群
```bash
# 方法1: 使用综合管理工具（推荐）
cd scripts
./rac_cluster_manager_full.sh
# 选择: 1)启动 或 2)停止

# 方法2: 使用专用脚本
cd scripts
./rac_cluster_start.sh  # 启动
./rac_cluster_stop.sh   # 停止
```

#### ...检查表空间使用
```bash
cd scripts
./rac_tablespace_monitor.sh
```

#### ...清理日志
```bash
cd scripts
./rac_log_cleanup.sh
```

#### ...查看优化建议
```bash
# 查看优化建议文档
cat reports/cluster/rac_optimization_recommendations.txt

# 或查看任务总结
cat docs/TASK_SUMMARY.md
```

#### ...了解集群配置
```bash
# 查看完整集群信息
cat reports/cluster/rac_cluster_info.txt

# 或查看项目README
cat README.md
```

#### ...查看启停操作说明
```bash
cat docs/START_STOP_GUIDE.md
```

## 📝 使用建议

### 日常管理流程

**每日**:
1. 运行快速检查: `scripts/rac_quick_check.sh`
2. 查看健康检查报告: `reports/health/`

**每周**:
1. 运行表空间监控: `scripts/rac_tablespace_monitor.sh`
2. 查看系统资源: `reports/system/`

**每月**:
1. 清理日志文件: `scripts/rac_log_cleanup.sh`
2. 审查优化建议: `reports/cluster/rac_optimization_recommendations.txt`

### 维护操作流程

**启动集群**:
1. 阅读: `docs/START_STOP_GUIDE.md`
2. 执行: `scripts/rac_cluster_start.sh`

**停止集群**:
1. 阅读: `docs/START_STOP_GUIDE.md`
2. 执行: `scripts/rac_cluster_stop.sh`

**资源管理**:
1. 查看: `reports/cluster/rac_resources_status.txt`
2. 管理资源: `scripts/rac_cluster_manager.sh`

## 🔗 相关链接

- **GitHub仓库**: https://github.com/hujinnvshi/oracle19c_rac_check_20260112
- **Oracle官方文档**: https://docs.oracle.com/en/database/oracle/oracle-clusterware/19c/

## 💡 提示

1. **所有脚本都在 `scripts/` 目录**
2. **所有文档都在 `docs/` 目录**
3. **所有报告都在 `reports/` 目录**
4. **临时文件在 `archive/` 目录**
5. **推荐使用 `rac_cluster_manager_full.sh` 综合管理工具**

---

**文档更新**: 2026-01-12
**维护人员**: DBA Team
