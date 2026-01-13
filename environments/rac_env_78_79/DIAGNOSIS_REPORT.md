# 环境名称: rac_env_78_79

## 🔴 严重问题诊断

### 问题1: 节点1 CRS服务未启动

**症状**: `CRS-4639: Could not contact Oracle High Availability Services`

**影响**: 节点1完全无法访问集群资源

**紧急程度**: 🔴 严重

**建议解决方案**:
```bash
# 1. 检查节点1 CRS状态
ssh root@172.16.48.78 "ps -ef | grep -E 'ohasd|crsd' | head -5"

# 2. 尝试启动CRS
ssh root@172.16.48.78 "cd /home/grid/grid && ./bin/crsctl start crs"

# 3. 如果失败，检查集群日志
ssh root@172.16.48.78 "tail -50 /home/grid/grid/log/$(hostname)/alert*.log"
```

### 问题2: 数据库实例未启动

**症状**:
- 节点1: ORA-01034: ORACLE not available
- 节点2: ORA-01034: ORACLE not available

**影响**: 数据库实例不可访问

**紧急程度**: 🔴 严重

**建议解决方案**:
```bash
# 1. 检查集群资源状态
ssh root@172.16.48.78 "su - grid -c 'crsctl status resource -t'"

# 2. 如果CRS正常，启动数据库
ssh root@172.16.48.78 "su - grid -c 'srvctl start database -d ORCL'"

# 3. 检查实例状态
ssh root@172.16.48.78 "su - oracle -c 'sqlplus / as sysdba'"
```

### 问题3: ASM权限问题

**症状**: `/var/tmp/.oracle is missing or not writable`

**影响**: ASM无法正常工作

**紧急程度**: 🟡 中等

**建议解决方案**:
```bash
# 修复权限
ssh root@172.16.48.78 "mkdir -p /var/tmp/.oracle && chmod 777 /var/tmp/.oracle"
ssh root@172.16.48.79 "mkdir -p /var/tmp/.oracle && chmod 777 /var/tmp/.oracle"

# 更改所有者
ssh root@172.16.48.78 "chown grid:oinstall /var/tmp/.oracle"
ssh root@172.16.48.79 "chown grid:oinstall /var/tmp/.oracle"
```

---

## 📋 推荐恢复步骤

### 步骤1: 修复ASM权限 (两节点)
```bash
ssh root@172.16.48.78 "mkdir -p /var/tmp/.oracle && chmod 777 /var/tmp/.oracle && chown grid:oinstall /var/tmp/.oracle"
ssh root@172.16.48.79 "mkdir -p /var/tmp/.oracle && chmod 777 /var/tmp/.oracle && chown grid:oinstall /var/tmp/.oracle"
```

### 步骤2: 启动节点1 CRS
```bash
ssh root@172.16.48.78 "su - grid -c 'crsctl start crs'"
# 等待60秒
```

### 步骤3: 检查集群状态
```bash
# 使用我们的检查脚本
cd /path/to/oracle19c_rac_check_20260112
./scripts/rac_cluster_manager_full.sh
```

### 步骤4: 启动数据库（如果CRS正常）
```bash
# 使用集群管理工具启动
./scripts/rac_cluster_start.sh
```

---

## ⚠️ 注意事项

1. **不要在节点1 CRS未启动时强制操作**
2. **先修复权限问题，再启动服务**
3. **确保两个节点时间同步**
4. **检查存储连接**

---

## 📞 需要协助?

如果需要帮助恢复这个环境，请提供以下信息：
1. 节点1的CRS日志
2. 集群安装时间
3. 上次正常运行时间

---

**报告生成时间**: 2026-01-12 09:32
**检查状态**: 发现严重问题，需要立即处理
