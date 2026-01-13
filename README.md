# Oracle RAC 19c 集群管理工具集

> **完整的Oracle RAC 19c双节点集群自动化管理和监控工具集**

## 📋 项目概述

本项目为Oracle RAC 19c双节点集群提供了完整的自动化管理工具集，包括健康检查、启动停止、资源管理、日志清理等8个Shell脚本，以及详细的使用文档和配置记录。

### 集群信息

| 项目 | 信息 |
|------|------|
| **集群版本** | Oracle 19c (19.0.0.0.0) |
| **节点配置** | rac1 (172.16.48.131) + rac2 (172.16.48.133) |
| **数据库** | ORCL (orcl1 + orcl2) |
| **ASM磁盘组** | CRS_GIMR (600GB) + DATA (600GB) |
| **状态** | ✅ 所有服务 ONLINE |

## 🚀 快速开始

### 推荐使用综合管理工具

```bash
cd scripts
./rac_cluster_manager_full.sh
```

### 其他常用操作

```bash
# 快速检查集群状态
./scripts/rac_quick_check.sh

# 启动集群
./scripts/rac_cluster_start.sh

# 停止集群
./scripts/rac_cluster_stop.sh

# 查看帮助
./scripts/rac_cluster_manager.sh help
```

## 📁 项目结构

```
oracle19c_rac_check_20260112/
│
├── scripts/                    # Shell脚本目录
│   ├── rac_cluster_manager_full.sh    # ⭐ 综合管理工具（推荐）
│   ├── rac_cluster_start.sh           # 集群启动脚本
│   ├── rac_cluster_stop.sh            # 集群停止脚本
│   ├── rac_daily_health_check.sh      # 每日健康检查
│   ├── rac_quick_check.sh             # 快速状态检查
│   ├── rac_tablespace_monitor.sh      # 表空间监控
│   ├── rac_cluster_manager.sh         # 资源管理工具
│   ├── rac_log_cleanup.sh             # 日志清理
│   └── disable_gui.sh                 # 图形界面禁用脚本
│
├── docs/                       # 文档目录
│   ├── README.md                        # 本文件
│   ├── START_STOP_GUIDE.md              # 启停操作指南
│   ├── TASK_SUMMARY.md                  # 任务完成总结
│   ├── CLUSTER_MANAGEMENT_SUMMARY.md    # 工具集详细说明
│   ├── GUI_DISABLED_FINAL.md            # 图形界面关闭报告
│   └── GIT_COMMIT_SUMMARY.md            # Git提交总结
│
├── reports/                    # 报告目录
│   ├── cluster/                  # 集群相关报告
│   │   ├── rac_cluster_info.txt              # 集群完整信息
│   │   ├── rac_cluster_status.txt           # CRS状态
│   │   ├── rac_cluster_nodes.txt            # 节点信息
│   │   ├── rac_resources_status.txt         # 资源状态
│   │   ├── rac_vip_status.txt               # VIP状态
│   │   └── rac_asm_diskgroup.txt            # ASM磁盘组
│   │
│   ├── system/                   # 系统相关报告
│   │   ├── rac_network_131.txt               # 节点1网络配置
│   │   ├── rac_network_133.txt               # 节点2网络配置
│   │   ├── rac_system_131.txt                # 节点1系统资源
│   │   ├── rac_system_133.txt                # 节点2系统资源
│   │   ├── rac_performance_131.txt           # 节点1性能指标
│   │   └── rac_performance_133.txt           # 节点2性能指标
│   │
│   ├── gui/                      # 图形界面相关报告
│   │   └── gui_status_report.txt             # GUI状态报告
│   │
│   └── health/                   # 健康检查报告
│       └── rac_health_report_*.txt          # 历史健康检查报告
│
└── archive/                    # 存档目录
    ├── rac_autostart_check.txt          # 开机自启动检查
    ├── rac_node2_autostart.txt          # 节点2自启动状态
    ├── rac_db_threads.txt               # 数据库线程信息
    └── rac_db_instance.txt              # 数据库实例信息
```

## 🛠️ 工具脚本说明

### 1. 综合管理工具 (rac_cluster_manager_full.sh) ⭐

**功能最全面的管理工具，推荐日常使用**

- ✅ 集群启动/停止/重启
- ✅ 状态查询和监控
- ✅ 健康检查
- ✅ 节点管理
- ✅ 系统资源查看

**使用方法**:
```bash
cd scripts
./rac_cluster_manager_full.sh
```

**菜单选项**:
```
1) 启动集群          7) 查看数据库状态
2) 停止集群          8) 查看ASM状态
3) 重启集群          9) 查看网络配置
4) 查看集群状态      10) 检查开机自启动
5) 快速健康检查      11) 查看系统资源
6) 查看集群资源      12) 节点管理
```

### 2. 启动/停止脚本

#### rac_cluster_start.sh
安全启动Oracle RAC集群

- ✅ 按正确顺序启动
- ✅ 等待资源稳定
- ✅ 验证服务状态
- ✅ 生成操作日志

#### rac_cluster_stop.sh
安全停止Oracle RAC集群

- ✅ 按正确顺序停止
- ✅ 验证进程已停止
- ✅ 生成操作日志

**使用方法**:
```bash
cd scripts
./rac_cluster_start.sh   # 启动集群
./rac_cluster_stop.sh    # 停止集群
```

### 3. 健康检查脚本

#### rac_daily_health_check.sh
每日完整健康检查

**检查内容**:
- CRS服务状态
- 集群资源状态
- 数据库实例状态
- ASM磁盘组状态
- 表空间使用率
- 系统资源使用
- Alert日志错误

**输出**: 报告保存到 `reports/health/`

**建议**: 每日定时执行（如凌晨2点）

#### rac_quick_check.sh
快速状态检查

**检查内容**:
- 集群核心状态
- 数据库实例状态
- 资源概览
- 系统负载
- 严重告警

**特点**: 输出简洁，带颜色标识

**建议**: 每小时或按需执行

### 4. 专项监控脚本

#### rac_tablespace_monitor.sh
表空间使用率监控

**功能**:
- 表空间使用详情
- 超阈值告警 (85%/95%)
- 临时表空间检查
- UNDO表空间检查

**建议**: 每周执行

#### rac_cluster_manager.sh
资源快速管理工具

**功能**:
- 查看资源状态
- 启动/停止/重启资源
- 列出所有资源
- 健康检查

**常用资源**:
```bash
./scripts/rac_cluster_manager.sh status ora.orcl.db
./scripts/rac_cluster_manager.sh restart ora.orcl.db
```

### 5. 维护脚本

#### rac_log_cleanup.sh
日志文件清理

**清理内容**:
- Alert日志
- 监听器日志
- Clusterware日志
- 审计日志
- Trace文件
- 临时文件

**保留策略**:
- 普通日志: 90天
- 审计日志: 30天

**建议**: 每月执行

#### disable_gui.sh
图形界面禁用脚本

**功能**: 关闭图形界面以节省资源

**效果**: 节省 500MB-1GB 内存

## 📖 文档导航

### 快速入门
- 📖 **[本README](README.md)** - 项目总览和快速开始
- 📖 **[START_STOP_GUIDE.md](docs/START_STOP_GUIDE.md)** - 集群启停操作指南

### 详细说明
- 📖 **[CLUSTER_MANAGEMENT_SUMMARY.md](docs/CLUSTER_MANAGEMENT_SUMMARY.md)** - 工具集完整说明
- 📖 **[TASK_SUMMARY.md](docs/TASK_SUMMARY.md)** - 任务完成总结和配置信息

### 操作记录
- 📖 **[GUI_DISABLED_FINAL.md](docs/GUI_DISABLED_FINAL.md)** - 图形界面关闭报告
- 📖 **[GIT_COMMIT_SUMMARY.md](docs/GIT_COMMIT_SUMMARY.md)** - Git提交总结

## ⏰ 定时任务配置

### 编辑crontab
```bash
crontab -e
```

### 推荐配置

```bash
# 每日凌晨2点完整健康检查
0 2 * * * cd /home/admin/zncode/oracle19c_rac_check_20260112 && ./scripts/rac_daily_health_check.sh

# 每小时快速检查
0 * * * * cd /home/admin/zncode/oracle19c_rac_check_20260112 && ./scripts/rac_quick_check.sh

# 每周一上午9点表空间监控
0 9 * * 1 cd /home/admin/zncode/oracle19c_rac_check_20260112 && ./scripts/rac_tablespace_monitor.sh

# 每月1号凌晨3点日志清理
0 3 1 * * cd /home/admin/zncode/oracle19c_rac_check_20260112 && ./scripts/rac_log_cleanup.sh
```

## 📊 集群配置信息

### 硬件配置
- **节点数量**: 2个
- **CPU**: 每节点16核
- **内存**: 每节点62GB
- **存储**: 1.1TB根分区 + 1.2TB数据盘

### 网络配置
```
节点1 (rac1):
  - 物理IP: 172.16.48.131
  - VIP: 172.16.48.132
  - 私网: 10.10.15.132

节点2 (rac2):
  - 物理IP: 172.16.48.133
  - VIP: 172.16.48.134
  - SCAN: 172.16.48.135
  - 私网: 10.10.15.134
```

### ASM存储
- **CRS_GIMR**: 600GB, 使用率 1.74%
- **DATA**: 600GB, 使用率 11.65%

### 数据库
- **数据库名**: ORCL
- **实例**: orcl1 (rac1) + orcl2 (rac2)
- **角色**: PRIMARY
- **状态**: READ WRITE

## ✅ 系统优化状态

### 已完成的优化
- ✅ SSH免密登录配置
- ✅ 图形界面已关闭 (节省500MB-1GB内存)
- ✅ 集群开机自启动已启用
- ✅ 系统运行在文本模式

### 重要优化建议

#### 高优先级 ⚠️
1. **Swap配置不一致**
   - 节点1: 无Swap
   - 节点2: 38GB
   - 建议: 统一配置16-32GB

2. **内存利用率低**
   - 当前: 8-9%
   - 建议: 增加SGA/PGA配置

3. **私有网络冗余**
   - 当前: 单私网
   - 建议: 配置双私网

#### 中优先级
- 定期监控表空间增长
- 配置RMAN自动备份
- 启用数据库审计
- 配置监控告警

详细建议请查看: `reports/cluster/rac_optimization_recommendations.txt`

## 🔧 系统管理

### 验证集群状态
```bash
cd scripts
./rac_quick_check.sh
```

### 启动集群
```bash
cd scripts
./rac_cluster_start.sh
# 或使用综合工具
./rac_cluster_manager_full.sh
# 选择: 1) 启动集群
```

### 停止集群
```bash
cd scripts
./rac_cluster_stop.sh
# 或使用综合工具
./rac_cluster_manager_full.sh
# 选择: 2) 停止集群
```

### 重启集群
```bash
cd scripts
./rac_cluster_manager_full.sh
# 选择: 3) 重启集群
```

## 📞 技术支持

- 查看详细文档: `docs/` 目录
- 查看历史报告: `reports/` 目录
- GitHub仓库: https://github.com/hujinnvshi/oracle19c_rac_check_20260112

## 📝 更新日志

### 2026-01-12
- ✅ 创建完整的集群管理工具集
- ✅ 配置SSH免密登录
- ✅ 关闭图形界面
- ✅ 生成完整文档和报告
- ✅ 提交到GitHub仓库

## 📄 许可证

本项目为内部管理工具，仅供团队内部使用。

---

**项目创建**: 2026-01-12
**Oracle版本**: 19c (19.0.0.0.0)
**集群状态**: ✅ 正常运行
**维护人员**: DBA Team
