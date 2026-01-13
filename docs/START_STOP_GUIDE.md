# Oracle RAC 集群启动停止指南

## 概述

本指南介绍Oracle RAC 19c集群的安全启动和停止操作。

**重要提示**:
- ⚠️ 启动和停止操作会影响业务，请在维护窗口执行
- ⚠️ 执行前确保已通知所有用户
- ⚠️ 建议在业务低峰期进行
- ✅ 集群已配置为开机自启动

## 脚本说明

### 1. rac_cluster_start.sh - 集群启动脚本
按正确顺序启动Oracle RAC集群所有服务。

**功能**:
- 启动集群ware (CRS)
- 等待资源稳定
- 启动数据库实例
- 启动监听器
- 验证所有服务状态
- 执行健康检查

**使用方法**:
```bash
./rac_cluster_start.sh
```

**启动选项**:
```
1) 完整启动 (集群ware+数据库+所有服务)
2) 仅启动数据库
3) 启动数据库+监听器
4) 仅启动集群ware
5) 启动节点1集群
6) 启动节点2集群
7) 健康检查
0) 取消
```

### 2. rac_cluster_stop.sh - 集群停止脚本
按正确顺序停止Oracle RAC集群所有服务。

**功能**:
- 停止数据库实例
- 停止监听器
- 停止ASM实例
- 停止集群ware (CRS)
- 验证所有服务已停止

**使用方法**:
```bash
./rac_cluster_stop.sh
```

**停止选项**:
```
1) 完整关闭 (数据库+监听器+ASM+集群ware)
2) 仅停止数据库
3) 停止数据库+监听器
4) 停止数据库+监听器+ASM
5) 停止节点1集群
6) 停止节点2集群
7) 停止所有集群ware
8) 检查集群状态后退出
0) 取消
```

### 3. rac_cluster_manager_full.sh - 集群综合管理工具
提供完整的集群管理功能，包括启动、停止、状态查询等。

**功能**:
- 集群启动/停止/重启
- 状态查询
- 健康检查
- 节点管理
- 系统资源查看

**使用方法**:
```bash
./rac_cluster_manager_full.sh
```

**主菜单选项**:
```
1) 启动集群
2) 停止集群
3) 重启集群
4) 查看集群状态
5) 快速健康检查
6) 查看集群资源
7) 查看数据库状态
8) 查看ASM状态
9) 查看网络配置
10) 检查开机自启动
11) 查看系统资源
12) 节点管理
0) 退出
```

## 正确的启动顺序

Oracle RAC集群的正确启动顺序:

```
1. 启动集群ware (OHASD/CRS)
   └─ 自动启动大部分集群资源

2. 等待资源稳定 (约60秒)
   └─ 检查所有资源状态

3. 验证关键服务
   ├─ ASM实例 (应自动启动)
   ├─ VIP资源 (应自动启动)
   ├─ SCAN VIP (应自动启动)
   └─ 监听器 (应自动启动)

4. 启动数据库实例
   └─ 使用 srvctl start database

5. 验证数据库状态
   ├─ 检查实例状态
   ├─ 检查表空间
   └─ 测试连接
```

## 正确的停止顺序

Oracle RAC集群的正确停止顺序:

```
1. 停止数据库实例
   └─ srvctl stop database -d orcl -o immediate

2. 停止监听器
   └─ srvctl stop listener

3. 停止ASM实例
   └─ srvctl stop asm

4. 停止集群ware
   └─ crsctl stop cluster -all
   或
   └─ crsctl stop crs (单节点)

5. 验证所有进程已停止
   └─ 检查Oracle进程
```

## 开机自启动配置

### 当前状态
集群已配置为开机自启动:
```bash
# 检查状态
systemctl status oracle-ohasd
systemctl is-enabled oracle-ohasd
```

两个节点的oracle-ohasd服务都是`enabled`状态，会随系统启动自动启动集群ware。

### 手动控制开机自启动

**禁用开机自启动**:
```bash
# 在两个节点上执行
systemctl disable oracle-ohasd
```

**启用开机自启动**:
```bash
# 在两个节点上执行
systemctl enable oracle-ohasd
```

## 常见使用场景

### 场景1: 计划内维护 - 停止集群
```bash
# 1. 通知所有用户
# 2. 停止应用连接
# 3. 执行停止脚本
./rac_cluster_stop.sh
# 选择选项 1 (完整关闭)

# 4. 执行维护操作
...

# 5. 维护完成后启动
./rac_cluster_start.sh
# 选择选项 1 (完整启动)
```

### 场景2: 单节点维护
```bash
# 使用综合管理工具
./rac_cluster_manager_full.sh

# 选择: 12) 节点管理
# 然后选择:
#   5) 重启节点1集群
#   或
#   6) 重启节点2集群
```

### 场景3: 仅重启数据库
```bash
# 停止
./rac_cluster_stop.sh
# 选择选项 2 (仅停止数据库)

# 启动
./rac_cluster_start.sh
# 选择选项 2 (仅启动数据库)
```

### 场景4: 快速检查集群状态
```bash
# 使用快速检查脚本
./rac_quick_check.sh

# 或使用综合管理工具
./rac_cluster_manager_full.sh
# 选择: 5) 快速健康检查
```

## 日志文件

所有启动和停止操作都会生成日志文件:

```bash
# 启动日志
./rac_logs/rac_start_YYYYMMDD_HHMMSS.log

# 停止日志
./rac_logs/rac_stop_YYYYMMDD_HHMMSS.log
```

日志内容包括:
- 操作时间戳
- 执行的命令
- 命令输出
- 状态验证结果

## 故障处理

### 启动失败

**问题**: 集群ware启动失败

**检查步骤**:
```bash
# 1. 检查系统日志
tail -f /var/log/messages

# 2. 检查集群日志
tail -f /home/grid/grid/log/$(hostname)/alert$(hostname).log

# 3. 检查OHASD日志
tail -f /home/grid/grid/log/$(hostname)/ohasd/ohasd.log

# 4. 验证网络
ping <节点2 IP>
```

**常见原因**:
- 私有网络不通
- 存储连接问题
- ASM磁盘不可用
- 权限问题

### 停止失败

**问题**: 资源无法停止

**检查步骤**:
```bash
# 1. 检查资源依赖关系
crsctl status resource <资源名> -p

# 2. 强制停止资源 (谨慎使用)
crsctl stop resource <资源名> -f

# 3. 检查阻塞会话
# 在数据库中查询活跃会话
```

### VIP无法启动

**问题**: VIP资源无法启动

**检查步骤**:
```bash
# 1. 检查网络接口
ip a show

# 2. 检查VIP配置
srvctl config vip -n <节点名>

# 3. 手动测试VIP
ifconfig <接口>:<编号> <VIP_IP> netmask <子网掩码>
```

## 最佳实践

### 1. 启动前检查
- [ ] 确认网络连接正常
- [ ] 确认存储可访问
- [ ] 检查系统资源充足
- [ ] 查看上次停止日志

### 2. 停止前准备
- [ ] 通知所有用户
- [ ] 停止应用连接
- [ ] 检查是否有长时间运行的作业
- [ ] 备份重要数据

### 3. 操作中监控
- [ ] 实时查看日志输出
- [ ] 监控系统资源
- [ ] 检查错误信息
- [ ] 验证每步操作结果

### 4. 操作后验证
- [ ] 检查集群状态
- [ ] 验证数据库可访问
- [ ] 测试应用连接
- [ ] 检查性能指标
- [ ] 查看alert日志

## 注意事项

### ⚠️ 重要警告

1. **不要强制关闭系统**
   - 必须先停止集群再关机
   - 使用shutdown -h now前先stop cluster

2. **不要同时操作两个节点**
   - 避免两个节点同时重启
   - 逐个节点进行维护

3. **注意时间窗口**
   - 完整启动约需3-5分钟
   - 完整停止约需2-3分钟
   - 预留足够时间

4. **备份重要数据**
   - 操作前确保备份有效
   - 可测试恢复流程

5. **保持记录**
   - 记录所有维护操作
   - 保存操作日志
   - 记录异常情况

## 快速参考

### 常用命令

```bash
# 检查集群状态
crsctl check crs

# 查看集群资源
crsctl status resource -t

# 查看节点状态
olsnodes -s

# 启动数据库
srvctl start database -d orcl

# 停止数据库
srvctl stop database -d orcl -o immediate

# 查看数据库状态
srvctl status database -d orcl

# 启动监听器
srvctl start listener

# 停止监听器
srvctl stop listener

# 查看监听器状态
srvctl status listener
```

### 紧急联系

如遇到无法解决的问题，请联系:
- Oracle支持服务
- DBA团队
- 系统管理员

---

**文档版本**: 1.0
**最后更新**: 2026-01-12
**适用版本**: Oracle RAC 19c
