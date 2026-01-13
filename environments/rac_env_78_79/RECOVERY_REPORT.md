# 环境恢复报告 - rac_env_78_79

## 执行时间
2026-01-13 10:12

---

## ✅ 已完成的修复

### 1. ASM权限修复
- **节点1**: `/var/tmp/.oracle` 已创建并设置正确权限
- **节点2**: `/var/tmp/.oracle` 已创建并设置正确权限
- 权限: `drwxrwxrwx grid:oinstall`

### 2. 主机名配置修复
- **问题**: 节点1主机名为 `rac1`，但集群配置期望 `racn1`
- **修复**: 已将节点1主机名更改为 `racn1`
- 命令: `hostnamectl set-hostname racn1`

---

## 🔴 发现的严重问题

### 问题1: 节点1不在集群配置中 ⚠️ **关键问题**

**症状**:
```bash
$ olsnodes -a
racn2	Hub
```

**影响**:
- 节点1 (racn1) 完全不在集群配置中
- CRS无法在节点1上启动，因为节点从未被添加到集群
- 这不是启动失败，而是配置缺失

**根本原因**:
节点1可能：
1. 从未完成集群添加流程
2. 被意外从集群中删除
3. 集群配置损坏导致节点信息丢失

---

### 问题2: 数据库无法启动

**症状**:
```
ORA-00205: error in identifying control file, check alert log for more info
ORA-15040: diskgroup is incomplete
```

**影响**:
- 控制文件位于 `+MGMT/ORCL/CONTROLFILE/`
- MGMT磁盘组需要两个节点在线（Normal冗余）
- 节点1不在集群中，导致MGMT磁盘组不完整
- 数据库无法MOUNT

---

### 问题3: 集群资源状态

**当前状态**:
- 节点2 CRS: ✅ 正常运行
- 节点1 CRS: ❌ 未配置
- ASM实例:
  - 节点1: OFFLINE
  - 节点2: ONLINE
- 数据库实例:
  - orcl1: OFFLINE
  - orcl2: UNKNOWN（无法启动）

---

## 🔧 恢复方案

### 方案A: 将节点1重新添加到集群 ⭐ **推荐**

#### 步骤1: 准备节点1

```bash
# 1. 确保主机名正确（已完成）
hostnamectl set-hostname racn1

# 2. 停止oracle-ohasd服务
ssh root@172.16.48.78 "systemctl stop oracle-ohasd"

# 3. 清理旧的集群配置
ssh root@172.16.48.78 "rm -rf /u01/app/grid/crsdata/racn1"

# 4. 验证网络配置
ssh root@172.16.48.78 "
cat /etc/hosts | grep racn1
ip addr show | grep -E '172.16.48.78|fd00:2::11'
"
```

#### 步骤2: 从节点2运行添加节点脚本

```bash
# 在节点2上执行
ssh root@172.16.48.79 "su - grid -c '
cd /u01/app/19.3.0/grid/oui/bin
./addNode.sh -silent \
  CLUSTER_NEW_NODES={racn1} \
  CLUSTER_NEW_NODE_VIPS={racn1-vip|172.16.48.132} \
  CLUSTER_NEW_PRIVATE_NAMES={racn1-prv}
'"
```

#### 步骤3: 在节点1上运行配置脚本

```bash
# 在节点1上运行添加节点的root脚本
ssh root@172.16.48.78 "
cd /u01/app/19.3.0/grid/addnode
sh rootaddnode.sh
"
```

#### 步骤4: 验证节点添加

```bash
ssh root@172.16.48.79 "su - grid -c 'olsnodes -n'"
# 应该显示:
# racn1  1
# racn2  2
```

#### 步骤5: 启动节点1 CRS和数据库

```bash
# 启动节点1 CRS
ssh root@172.16.48.78 "systemctl start oracle-ohasd"

# 等待60秒后检查状态
ssh root@172.16.48.78 "su - grid -c 'crsctl check crs'"

# 启动数据库
ssh root@172.16.48.79 "su - grid -c 'srvctl start database -d orcl'"

# 验证数据库状态
ssh root@172.16.48.79 "su - grid -c 'srvctl status database -d orcl'"
```

---

### 方案B: 在节点2上启动单实例数据库 ⚠️ **临时方案**

如果只是临时需要访问数据库，可以在节点2上启动单实例：

```bash
# 1. 停止集群管理的数据库
ssh root@172.16.48.79 "su - grid -c 'srvctl stop database -d orcl'"

# 2. 在节点2上手动启动单实例
ssh root@172.16.48.79 "su - oracle -c 'sqlplus / as sysdba <<EOF
startup nomount;
alter system set cluster_database=false scope=spfile;
shutdown immediate;
startup;
EOF'"

# ⚠️ 注意: 这只是临时方案，会破坏RAC功能
```

---

### 方案C: 重新安装集群 ❌ **最后手段**

如果节点1配置严重损坏，可能需要重新安装：

```bash
# ⚠️ 警告: 这将删除所有集群配置
# 1. 完全删除节点1上的Grid Infrastructure
ssh root@172.16.48.78 "
/u01/app/19.3.0/grid/crs/install/rootcrs.sh -deconfig -force -verbose
"

# 2. 从节点2删除节点1的配置
ssh root@172.16.48.79 "su - grid -c '
/u01/app/19.3.0/grid/bin/crsctl delete node -n racn1
'"

# 3. 重新运行集群安装添加节点1
# (需要Oracle安装响应文件)
```

---

## 📊 当前集群状态汇总

| 组件 | 节点1 (racn1/78) | 节点2 (racn2/79) | 状态 |
|------|----------------|----------------|------|
| 主机名 | ✅ racn1 (已修复) | ✅ racn2 | 正常 |
| 在集群中 | ❌ **未配置** | ✅ 已配置 | **异常** |
| CRS服务 | ❌ 未运行 | ✅ 运行中 | 异常 |
| ASM实例 | ❌ OFFLINE | ✅ ONLINE | 异常 |
| 数据库实例 | ❌ OFFLINE | ❌ UNKNOWN | 异常 |
| VIP | ❌ 不存在 | ✅ 正常 | 异常 |

---

## 🎯 推荐行动计划

### 立即执行 (关键)

1. **将节点1重新添加到集群** (方案A)
   - 预计时间: 30-60分钟
   - 风险: 中等
   - 影响: 需要在节点2上运行添加节点脚本

### 短期 (如需要临时访问)

2. **启动单实例数据库** (方案B)
   - 预计时间: 5-10分钟
   - 风险: 低
   - ⚠️ 仅用于紧急访问，不是长期方案

### 长期 (如果方案A失败)

3. **重新安装集群** (方案C)
   - 预计时间: 2-4小时
   - 风险: 高
   - 影响: 需要停机，可能需要完整重新安装

---

## 📝 技术细节

### OCR配置
```
ocrconfig_loc=+DATA/rac/OCRFILE/registry.255.1174667865
```

### Voting Disks
```
1. /dev/sdc [DATA]
2. /dev/sdd [DATA]
3. /dev/sde [DATA]
```

### ASM磁盘组
```
DATA:  600GB, Normal冗余, MOUNTED
MGMT:  600GB, Normal冗余, MOUNTED (不完整)
```

### 网络配置 (节点1)
```
Public:  172.16.48.78
VIP:     172.16.48.132
Private: fd00:3::13
```

---

## ⚠️ 重要注意事项

1. **不要强制启动数据库**
   - 在节点1未加入集群前，MGMT磁盘组将始终不完整
   - 强制启动可能导致数据损坏

2. **备份当前配置**
   ```bash
   ssh root@172.16.48.79 "su - grid -c 'ocrconfig -manualbackup'"
   ```

3. **监控集群日志**
   - 节点1: `/u01/app/grid/crsdata/racn1/crs/trace/alert.log`
   - 节点2: `/u01/app/grid/diag/crs/racn2/crs/trace/alert.log`

4. **时间同步很重要**
   - 两个节点已配置NTP并同步
   - 不要修改系统时间

---

## 📞 下一步建议

### 如果您希望我继续执行恢复:

请选择以下选项之一：

**选项1: 执行方案A（推荐）**
- 我会执行添加节点到集群的完整流程
- 需要Oracle安装响应文件或确认添加节点参数
- 预计30-60分钟完成

**选项2: 执行方案B（临时）**
- 我会在节点2上启动单实例数据库
- 仅用于紧急访问，RAC功能不可用
- 5-10分钟完成

**选项3: 您手动执行**
- 我已经提供了详细的步骤
- 您可以根据实际情况选择合适的方案

---

## 📋 检查清单

在执行任何恢复操作前，请确认：

- [ ] 已备份当前OCR配置
- [ ] 已验证两个节点的网络连通性
- [ ] 已确认两个节点的SSH互信正常
- [ ] 已验证存储连接正常 (/dev/sd*)
- [ ] 有足够的维护窗口（如果需要停机）
- [ ] 有Oracle安装介质（如果需要重新安装）

---

**报告生成**: 2026-01-13 10:12
**状态**: ⚠️ 需要执行集群节点添加操作
**优先级**: 🔴 高

---

## 🔍 根本原因分析

### 为什么节点1不在集群中？

可能的原因：

1. **安装未完成**
   - 集群安装过程中断
   - 节点添加脚本未执行完成

2. **配置被破坏**
   - OCR损坏导致节点信息丢失
   - 人为错误删除节点

3. **主机名变更**
   - 原始安装可能使用不同的主机名
   - 主机名变更导致配置不匹配

### 建议的预防措施

1. **定期备份OCR**
   ```bash
   crsctl backup css
   ocrconfig -manualbackup
   ```

2. **监控集群配置**
   ```bash
   olsnodes -n -t -s
   crsctl query css votedisk
   ```

3. **文档化所有变更**
   - 记录主机名变更
   - 记录网络配置变更
   - 记录所有集群操作

---

**报告结束**
