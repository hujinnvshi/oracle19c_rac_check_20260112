#!/bin/bash
#####################################################################
# Oracle RAC 19c 快速状态检查脚本
# 用途: 快速查看RAC集群整体状态
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "  Oracle RAC 19c 快速状态检查"
echo "  检查时间: $(date +%Y-%m-%d\ %H:%M:%S)"
echo "========================================="
echo ""

# 1. 集群状态
echo -e "【集群状态】"
echo -n "  节点 ${NODE1} CRS: "
ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl check crs'" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}正常${NC}"
else
    echo -e "${RED}异常${NC}"
fi

echo -n "  节点 ${NODE2} CRS: "
ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl check crs'" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}正常${NC}"
else
    echo -e "${RED}异常${NC}"
fi
echo ""

# 2. 数据库实例状态
echo "【数据库实例】"
echo "  节点1实例:"
ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set pages 0
select instance_name || ': ' || status from v\\\$instance;
exit;
SQLEOF\"" 2>/dev/null | grep -v "^$" | sed 's/^/    /'

echo "  节点2实例:"
ssh ${REMOTE_USER}@${NODE2} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set pages 0
select instance_name || ': ' || status from v\\\$instance;
exit;
SQLEOF\"" 2>/dev/null | grep -v "^$" | sed 's/^/    /'
echo ""

# 3. 集群资源概览
echo "【集群资源】"
ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource -t'" | grep -E "ora\.(orcl|asm|LISTENER|scan|rac)\." | head -20 | sed 's/^/  /'
echo ""

# 4. ASM磁盘组
echo "【ASM磁盘组】"
ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'asmcmd lsdg --suppressheader'" | awk '{printf "  %-15s 总空间: %6sGB  已用: %6sGB  使用率: %s%%\n", \$NF, \$9/1024/1024, (\$9-\$10)/1024/1024, int((\$9-\$10)/\$9*100)}'
echo ""

# 5. 系统负载
echo "【系统负载】"
echo -n "  节点1: "
ssh ${REMOTE_USER}@${NODE1} "uptime" | awk -F'load average:' '{print \$2}'
echo -n "  节点2: "
ssh ${REMOTE_USER}@${NODE2} "uptime" | awk -F'load average:' '{print \$2}'
echo ""

# 6. VIP状态
echo "【VIP状态】"
ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource -w \"TYPE = ora.cluster_vip.type\" -t'" | grep -E "ora.rac[0-9]+.vip|STATE=" | grep -B1 "ONLINE" | sed 's/^/  /'
echo ""

# 7. 告警信息
echo "【近期告警】"
ALERT_COUNT=$(ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set pages 0
select count(*) from X\\\$DBG_ALERTTEXT where originating_timestamp > sysdate-1/24 and message_text like '%ORA-00600%';
exit;
SQLEOF\"" 2>/dev/null | tail -1)

if [ "${ALERT_COUNT}" -gt 0 ]; then
    echo -e "  ${YELLOW}发现 ${ALERT_COUNT} 个严重错误告警${NC}"
else
    echo -e "  ${GREEN}无严重错误告警${NC}"
fi
echo ""

echo "========================================="
echo "  快速检查完成"
echo "========================================="
