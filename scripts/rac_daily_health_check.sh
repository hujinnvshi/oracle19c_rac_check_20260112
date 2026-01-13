#!/bin/bash
#####################################################################
# Oracle RAC 19c 每日健康检查脚本
# 作者: Admin
# 创建日期: 2026-01-12
# 用途: 自动化检查Oracle RAC集群健康状态
#####################################################################

# 配置参数
NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
REPORT_DIR="./rac_check_reports"
REPORT_FILE="${REPORT_DIR}/rac_daily_check_$(date +%Y%m%d_%H%M%S).txt"

# 创建报告目录
mkdir -p "${REPORT_DIR}"

# 函数: 打印标题
print_header() {
    echo "================================================================================" | tee -a "${REPORT_FILE}"
    echo "$1" | tee -a "${REPORT_FILE}"
    echo "================================================================================" | tee -a "${REPORT_FILE}"
    echo "" | tee -a "${REPORT_FILE}"
}

# 函数: 执行远程命令
exec_remote() {
    local node=$1
    local user=$2
    local cmd=$3
    ssh ${user}@${node} "${cmd}"
}

# 开始检查
{
    echo "================================================================================"
    echo "            Oracle RAC 19c 每日健康检查报告"
    echo "================================================================================"
    echo "检查时间: $(date)"
    echo "检查主机: $(hostname)"
    echo ""
} | tee "${REPORT_FILE}"

# 1. 集群基础状态检查
print_header "1. 集群CRS状态检查"

echo ">>> 节点 ${NODE1} CRS状态:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "su - grid -c 'crsctl check crs'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 节点 ${NODE2} CRS状态:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "su - grid -c 'crsctl check crs'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 集群版本信息:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "su - grid -c 'crsctl query crs activeversion'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 2. 集群资源状态检查
print_header "2. 集群资源状态"

exec_remote "${NODE1}" "${REMOTE_USER}" "su - grid -c 'crsctl status resource -t'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 3. 节点状态检查
print_header "3. 集群节点信息"

exec_remote "${NODE1}" "${REMOTE_USER}" "su - grid -c 'olsnodes -n -i'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 4. 数据库实例状态
print_header "4. 数据库实例状态"

echo ">>> 节点 ${NODE1} 数据库实例:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 50
col instance_name format a15
col status format a10
select instance_name, status, to_char(startup_time, 'YYYY-MM-DD HH24:MI:SS') as startup_time from v\\\$instance;
exit;
SQLEOF\"" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 节点 ${NODE2} 数据库实例:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 50
col instance_name format a15
col status format a10
select instance_name, status, to_char(startup_time, 'YYYY-MM-DD HH24:MI:SS') as startup_time from v\\\$instance;
exit;
SQLEOF\"" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 5. ASM磁盘组状态
print_header "5. ASM磁盘组状态"

exec_remote "${NODE1}" "${REMOTE_USER}" "su - grid -c 'asmcmd lsdg'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 6. 表空间使用率检查
print_header "6. 表空间使用率"

exec_remote "${NODE1}" "${REMOTE_USER}" "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 100
col tablespace_name format a25
col used_pct format a10
select
    df.tablespace_name,
    round(df.bytes/1024/1024,2) as size_mb,
    round(fs.bytes/1024/1024,2) as free_mb,
    round((df.bytes-fs.bytes)/df.bytes*100,2) || '%' as used_pct
from
    (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) df,
    (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) fs
where df.tablespace_name = fs.tablespace_name
order by (df.bytes-fs.bytes)/df.bytes desc;
exit;
SQLEOF\"" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 7. 系统资源检查
print_header "7. 系统资源状态"

echo ">>> 节点 ${NODE1}:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "free -h" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "uptime" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 节点 ${NODE2}:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "free -h" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "uptime" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 8. 磁盘使用率检查
print_header "8. 磁盘使用情况"

echo ">>> 节点 ${NODE1}:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "df -h | grep -E '^/dev/'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 节点 ${NODE2}:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "df -h | grep -E '^/dev/'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 9. 网络配置检查
print_header "9. VIP网络状态"

echo ">>> 节点 ${NODE1} 网络:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE1}" "${REMOTE_USER}" "ip a show | grep -E 'inet ' | grep -v '127.0.0.1'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo ">>> 节点 ${NODE2} 网络:" | tee -a "${REPORT_FILE}"
exec_remote "${NODE2}" "${REMOTE_USER}" "ip a show | grep -E 'inet ' | grep -v '127.0.0.1'" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 10. 最近错误日志检查
print_header "10. Alert日志最近错误 (最近1小时)"

exec_remote "${NODE1}" "${REMOTE_USER}" "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 100
select originating_timestamp, message_text from X\\\$DBG_ALERTTEXT where originating_timestamp > sysdate-1/24 and message_text like '%ORA-%' order by originating_timestamp desc rownum <= 20;
exit;
SQLEOF\"" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

# 11. 检查总结
print_header "11. 检查总结"

echo "检查完成时间: $(date)" | tee -a "${REPORT_FILE}"
echo "报告文件: ${REPORT_FILE}" | tee -a "${REPORT_FILE}"
echo "" | tee -a "${REPORT_FILE}"

echo "================================================================================" | tee -a "${REPORT_FILE}"
echo "                          检查报告结束" | tee -a "${REPORT_FILE}"
echo "================================================================================" | tee -a "${REPORT_FILE}"

echo ""
echo "========================================="
echo "  每日健康检查完成!"
echo "  报告已保存到: ${REPORT_FILE}"
echo "========================================="
