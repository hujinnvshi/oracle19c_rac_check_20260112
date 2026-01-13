# Oracle RAC 集群管理工具集 - 总结文档

## 项目概述

本项目为Oracle RAC 19c双节点集群提供了完整的维护管理工具集，包括健康检查、启动停止、资源管理等8个Shell脚本。

**集群信息**:
- 节点: rac1 (172.16.48.131) + rac2 (172.16.48.133)
- 版本: Oracle 19c (19.0.0.0.0)
- 数据库: ORCL (orcl1 + orcl2)

## 工具脚本清单 (8个)

### 📊 健康检查类

#### 1. rac_daily_health_check.sh
- **用途**: 每日完整健康检查
- **大小**: 6.9 KB
- **功能**:
  - CRS状态检查
  - 集群资源状态
  - 数据库实例状态
  - ASM磁盘组检查
  - 表空间使用率
  - 系统资源检查
  - Alert日志错误
- **输出**: 报告保存至 ./rac_check_reports/
- **推荐**: 每日定时执行

#### 2. rac_quick_check.sh
- **用途**: 快速状态检查
- **大小**: 3.2 KB
- **功能**:
  - 集群核心状态
  - 数据库实例状态
  - 资源概览
  - 系统负载
  - 严重告警
- **特点**: 输出简洁，带颜色标识
- **推荐**: 每小时或按需执行

#### 3. rac_tablespace_monitor.sh
- **用途**: 表空间使用率监控
- **大小**: 4.8 KB
- **功能**:
  - 表空间使用详情
  - 超阈值告警 (85%/95%)
  - 临时表空间检查
  - UNDO表空间检查
- **推荐**: 每周执行

### 🛠️ 资源管理类

#### 4. rac_cluster_manager.sh
- **用途**: 集群资源快速管理
- **大小**: 7.0 KB
- **功能**:
  - 查看资源状态
  - 启动/停止/重启资源
  - 列出所有资源
  - 健康检查
- **常用资源**: ora.orcl.db, ora.asm, ora.LISTENER.lsnr
- **特点**: 命令行工具，适合自动化

### 🚀 启动停止类

#### 5. rac_cluster_start.sh
- **用途**: 安全启动集群
- **大小**: 9.7 KB
- **功能**:
  - 按正确顺序启动集群
  - 等待资源稳定
  - 验证服务状态
  - 生成操作日志
- **选项**: 完整启动/仅数据库/仅集群ware
- **日志**: ./rac_logs/rac_start_*.log

#### 6. rac_cluster_stop.sh
- **用途**: 安全停止集群
- **大小**: 6.9 KB
- **功能**:
  - 按正确顺序停止集群
  - 验证进程已停止
  - 生成操作日志
- **选项**: 完整关闭/仅数据库/仅集群ware
- **日志**: ./rac_logs/rac_stop_*.log

#### 7. rac_cluster_manager_full.sh
- **用途**: 集群综合管理工具
- **大小**: 14 KB
- **功能**:
  - 集群启动/停止/重启
  - 状态查询
  - 健康检查
  - 节点管理
  - 系统资源查看
  - 网络配置检查
- **特点**: 交互式菜单，功能全面
- **推荐**: 日常管理使用

### 🧹 维护清理类

#### 8. rac_log_cleanup.sh
- **用途**: 日志文件清理
- **大小**: 6.7 KB
- **功能**:
  - Alert日志清理
  - 监听器日志清理
  - Clusterware日志清理
  - 审计日志清理
  - Trace文件清理
  - 临时文件清理
- **保留**: 普通日志90天，审计日志30天
- **推荐**: 每月执行

## 文档清单

### 1. README.md
- 脚本使用指南
- 定时任务配置
- 常见问题解答

### 2. START_STOP_GUIDE.md
- 集群启动停止详细指南
- 正确的启动/停止顺序
- 故障处理方法
- 最佳实践

### 3. TASK_SUMMARY.md
- 任务完成总结
- 集群配置信息
- 优化建议汇总

### 4. CLUSTER_MANAGEMENT_SUMMARY.md
- 本文档
- 工具集完整说明

### 5. rac_cluster_info.txt
- 集群信息汇总
- 配置参数记录

### 6. rac_optimization_recommendations.txt
- 优化建议详细说明
- 高/中/低优先级建议

## 使用建议

### 日常管理流程

**每日**:
```bash
# 1. 快速检查 (每小时)
./rac_quick_check.sh

# 2. 完整健康检查 (凌晨2点)
./rac_daily_health_check.sh
```

**每周**:
```bash
# 1. 表空间监控
./rac_tablespace_monitor.sh

# 2. 资源状态检查
./rac_cluster_manager.sh status
```

**每月**:
```bash
# 1. 日志清理
./rac_log_cleanup.sh

# 2. 完整健康检查
./rac_daily_health_check.sh

# 3. 审查优化建议
cat rac_optimization_recommendations.txt
```

### 维护操作流程

**启动集群**:
```bash
# 方法1: 使用独立脚本
./rac_cluster_start.sh

# 方法2: 使用综合管理工具
./rac_cluster_manager_full.sh
# 选择: 1) 启动集群
```

**停止集群**:
```bash
# 方法1: 使用独立脚本
./rac_cluster_stop.sh

# 方法2: 使用综合管理工具
./rac_cluster_manager_full.sh
# 选择: 2) 停止集群
```

**重启集群**:
```bash
# 使用综合管理工具
./rac_cluster_manager_full.sh
# 选择: 3) 重启集群
```

### 定时任务配置

**编辑crontab**:
```bash
crontab -e
```

**建议配置**:
```bash
# 每日凌晨2点完整检查
0 2 * * * /home/admin/zncode/oracle19c_rac_check_20260112/rac_daily_health_check.sh

# 每小时快速检查
0 * * * * /home/admin/zncode/oracle19c_rac_check_20260112/rac_quick_check.sh

# 每周一上午9点表空间监控
0 9 * * 1 /home/admin/zncode/oracle19c_rac_check_20260112/rac_tablespace_monitor.sh

# 每月1号凌晨3点日志清理
0 3 1 * * /home/admin/zncode/oracle19c_rac_check_20260112/rac_log_cleanup.sh
```

## 开机自启动状态

✅ **集群已配置为开机自启动**

验证方法:
```bash
# 检查服务状态
systemctl status oracle-ohasd

# 查看是否启用
systemctl is-enabled oracle-ohasd
```

两个节点 (rac1, rac2) 的oracle-ohasd服务都是`enabled`状态。

## 目录结构

```
oracle19c_rac_check_20260112/
├── rac_daily_health_check.sh      # 每日健康检查
├── rac_quick_check.sh              # 快速检查
├── rac_tablespace_monitor.sh       # 表空间监控
├── rac_cluster_manager.sh          # 资源管理工具
├── rac_cluster_start.sh            # 集群启动脚本
├── rac_cluster_stop.sh             # 集群停止脚本
├── rac_cluster_manager_full.sh     # 综合管理工具
├── rac_log_cleanup.sh              # 日志清理
├── README.md                       # 使用指南
├── START_STOP_GUIDE.md             # 启停指南
├── TASK_SUMMARY.md                 # 任务总结
├── CLUSTER_MANAGEMENT_SUMMARY.md   # 本文档
├── rac_cluster_info.txt            # 集群信息
├── rac_optimization_recommendations.txt  # 优化建议
├── rac_logs/                       # 启停日志目录
└── rac_check_reports/              # 检查报告目录
```

## 关键优化建议

### 高优先级 ⚠️
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

### 中优先级
1. 定期监控表空间增长
2. 配置RMAN自动备份
3. 启用数据库审计
4. 配置监控告警

## 快速命令参考

```bash
# 查看集群快速状态
./rac_quick_check.sh

# 启动集群
./rac_cluster_start.sh

# 停止集群
./rac_cluster_stop.sh

# 打开综合管理工具
./rac_cluster_manager_full.sh

# 查看资源状态
./rac_cluster_manager.sh status

# 检查表空间
./rac_tablespace_monitor.sh

# 清理日志
./rac_log_cleanup.sh
```

## 技术支持

- 查看详细文档: README.md, START_STOP_GUIDE.md
- 检查日志: ./rac_logs/
- 查看报告: ./rac_check_reports/

## 版本信息

- **创建日期**: 2026-01-12
- **Oracle版本**: 19c (19.0.0.0.0)
- **脚本版本**: 1.0
- **集群配置**: 双节点RAC

---

**维护工具集创建完成! ✅**

所有脚本已配置执行权限，可直接使用。
