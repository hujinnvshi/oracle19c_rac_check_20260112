# Oracle RAC 19c 维护脚本使用指南

## 脚本清单

### 1. rac_daily_health_check.sh
**每日健康检查脚本**

功能:
- 集群CRS状态检查
- 集群资源状态
- 数据库实例状态
- ASM磁盘组状态
- 表空间使用率
- 系统资源检查
- 磁盘和网络状态
- Alert日志错误检查

用法:
```bash
./rac_daily_health_check.sh
```

输出:
- 报告保存在 `./rac_check_reports/` 目录
- 文件名格式: `rac_daily_check_YYYYMMDD_HHMMSS.txt`

建议:
- 配置为每日定时任务
- 建议在业务低峰期执行

### 2. rac_quick_check.sh
**快速状态检查脚本**

功能:
- 快速检查集群核心状态
- 数据库实例状态
- 集群资源概览
- ASM磁盘组概览
- 系统负载
- VIP状态
- 严重告警检查

用法:
```bash
./rac_quick_check.sh
```

特点:
- 输出简洁，带颜色标识
- 快速完成（约30秒）
- 适合日常快速巡检

### 3. rac_tablespace_monitor.sh
**表空间监控脚本**

功能:
- 表空间使用率详情
- 超阈值告警（默认85%/95%）
- 临时表空间使用情况
- UNDO表空间使用情况

用法:
```bash
./rac_tablespace_monitor.sh
```

告警阈值:
- WARNING_THRESHOLD: 85% (可修改)
- CRITICAL_THRESHOLD: 95% (可修改)

建议:
- 每周执行一次
- 可集成到监控系统

### 4. rac_cluster_manager.sh
**集群资源管理脚本**

功能:
- 查看资源状态
- 启动/停止/重启资源
- 列出所有资源
- 集群健康检查

用法:
```bash
# 显示帮助
./rac_cluster_manager.sh help

# 查看所有资源状态
./rac_cluster_manager.sh status

# 查看特定资源状态
./rac_cluster_manager.sh status ora.orcl.db

# 启动资源
./rac_cluster_manager.sh start ora.orcl.db

# 停止资源
./rac_cluster_manager.sh stop ora.orcl.db

# 重启资源
./rac_cluster_manager.sh restart ora.orcl.db

# 列出所有资源
./rac_cluster_manager.sh list

# 健康检查
./rac_cluster_manager.sh health
```

常用资源名:
```
ora.orcl.db          # 数据库实例
ora.asm              # ASM实例
ora.LISTENER.lsnr    # 监听器
ora.scan1.vip        # SCAN VIP
ora.rac1.vip         # 节点1 VIP
ora.rac2.vip         # 节点2 VIP
ora.DATA.dg          # DATA磁盘组
ora.CRS_GIMR.dg      # CRS磁盘组
```

### 5. rac_log_cleanup.sh
**日志清理脚本**

功能:
- Alert日志清理
- 监听器日志清理
- Clusterware日志清理
- 审计日志清理
- Trace文件清理
- 临时文件清理
- 已删除文件空间释放

用法:
```bash
./rac_log_cleanup.sh
```

默认保留策略:
- 普通日志: 90天
- 审计日志: 30天

注意事项:
- 执行前需要确认
- 建议在业务低峰期执行
- 执行前建议备份重要日志
- 可根据需求修改保留天数

## 脚本配置

所有脚本默认配置:
```bash
NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
```

如需修改，编辑各脚本文件顶部的配置参数。

## 权限设置

首次使用前需要设置执行权限:
```bash
chmod +x *.sh
```

## 定时任务配置建议

### 每日健康检查
```bash
# 每天凌晨2点执行
0 2 * * * /home/admin/oracle19c_rac_check/rac_daily_health_check.sh
```

### 快速检查
```bash
# 每小时执行一次
0 * * * * /home/admin/oracle19c_rac_check/rac_quick_check.sh
```

### 表空间监控
```bash
# 每周一上午9点执行
0 9 * * 1 /home/admin/oracle19c_rac_check/rac_tablespace_monitor.sh
```

### 日志清理
```bash
# 每月1号凌晨3点执行
0 3 1 * * /home/admin/oracle19c_rac_check/rac_log_cleanup.sh
```

## 注意事项

1. **免密登录**: 脚本依赖SSH免密登录，已配置完成
2. **权限要求**: 脚本需要root用户执行（或配置sudo）
3. **备份建议**: 执行维护操作前建议先备份
4. **业务影响**: 停止/重启资源会影响业务，请谨慎操作
5. **日志检查**: 定期检查脚本执行日志
6. **脚本更新**: 根据实际环境变化更新脚本配置

## 常见问题

### 1. 执行提示权限不足
```bash
chmod +x rac_*.sh
```

### 2. SSH连接失败
检查免密登录配置:
```bash
ssh root@172.16.48.131 "hostname"
ssh root@172.16.48.133 "hostname"
```

### 3. SQL*Plus命令失败
检查Oracle用户环境变量和监听器状态

### 4. 脚本执行缓慢
- 检查网络延迟
- 检查节点负载
- 检查磁盘I/O

## 报告文件

### 健康检查报告
- 目录: `./rac_check_reports/`
- 命名: `rac_daily_check_YYYYMMDD_HHMMSS.txt`

### 一次性检查报告
- 集群报告: `rac_health_report_YYYYMMDD_HHMMSS.txt`
- 优化建议: `rac_optimization_recommendations.txt`

## 技术支持

如有问题或建议，请联系DBA团队。

## 更新日志

- 2026-01-12: 初始版本创建
  - 配置免密登录
  - 创建5个维护脚本
  - 完成集群健康检查
  - 生成优化建议文档
