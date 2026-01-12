#!/bin/bash
#####################################################################
# Oracle RAC 日志清理脚本
# 用途: 清理Oracle相关日志文件，避免磁盘空间耗尽
# 注意: 执行前请确认了解清理策略
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
LOG_RETENTION_DAYS=90  # 日志保留天数
AUDIT_RETENTION_DAYS=30  # 审计日志保留天数

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Oracle RAC 日志清理工具"
echo "  执行时间: $(date)"
echo "========================================="
echo ""
echo "警告: 此操作将清理旧日志文件，请确认后再执行!"
echo "日志保留天数: ${LOG_RETENTION_DAYS} 天"
echo ""

# 确认执行
read -p "是否继续执行? (yes/no): " confirm
if [ "${confirm}" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

echo ""
echo "开始清理..."
echo ""

# 函数: 清理指定目录的日志
cleanup_logs() {
    local node=$1
    local dir=$2
    local pattern=$3
    local days=$4
    local desc=$5

    echo -n "  清理 ${node} ${desc}... "
    local count=$(ssh ${REMOTE_USER}@${node} "find ${dir} -name '${pattern}' -mtime +${days} -type f 2>/dev/null | wc -l")

    if [ ${count} -gt 0 ]; then
        ssh ${REMOTE_USER}@${node} "find ${dir} -name '${pattern}' -mtime +${days} -type f -delete 2>/dev/null"
        echo -e "${GREEN}已清理 ${count} 个文件${NC}"
    else
        echo -e "${YELLOW}无需清理${NC}"
    fi
}

# 1. 清理Alert日志 (如果被归档)
echo "【1. Alert日志清理】"
# Alert trace日志通常在 $ORACLE_BASE/diag/rdbms/*/trace/alert_*.log
# 注意: 不清理当前活跃的alert日志
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # 查找并清理归档的alert日志
    ssh ${REMOTE_USER}@${node} "find /u01/app/oracle/diag/rdbms/orcl/*/trace -name 'alert_*.log.[0-9]*' -mtime +${LOG_RETENTION_DAYS} -type f -delete 2>/dev/null"
    ssh ${REMOTE_USER}@${node} "find /u01/app/oracle/diag/rdbms/orcl/*/trace -name 'alert_*.log.gz' -mtime +${LOG_RETENTION_DAYS} -type f -delete 2>/dev/null"
    echo "  已清理归档的Alert日志"
done
echo ""

# 2. 清理监听器日志
echo "【2. 监听器日志清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # 监听器日志通常在 $ORACLE_HOME/log/diag/tnslsnr
    cleanup_logs ${node} "/u01/app/grid/diag/tnslsnr" "listener*.log.[0-9]*" ${LOG_RETENTION_DAYS} "监听器归档日志"
    cleanup_logs ${node} "/u01/app/grid/diag/tnslsnr" "listener*.log.gz" ${LOG_RETENTION_DAYS} "监听器压缩日志"
done
echo ""

# 3. 清理Clusterware日志
echo "【3. Clusterware日志清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # CRS日志
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/log" "*.log.[0-9]*" ${LOG_RETENTION_DAYS} "CRS归档日志"
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/log" "*.log.gz" ${LOG_RETENTION_DAYS} "CRS压缩日志"

    # CSSD日志
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/cssd" "ocssd*.log.[0-9]*" ${LOG_RETENTION_DAYS} "CSSD归档日志"

    # EVMD日志
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/evmd" "evmd*.log.[0-9]*" ${LOG_RETENTION_DAYS} "EVMD归档日志"
done
echo ""

# 4. 清理RACG日志
echo "【4. RACG日志清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/racg" "core*" ${LOG_RETENTION_DAYS} "RACG core文件"
    cleanup_logs ${node} "/u01/app/grid/crsdata/*/racg" "*.log.[0-9]*" ${LOG_RETENTION_DAYS} "RACG归档日志"
done
echo ""

# 5. 清理审计日志
echo "【5. 审计日志清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # 数据库审计日志
    cleanup_logs ${node} "/u01/app/oracle/admin/*/adump" "*.aud" ${AUDIT_RETENTION_DAYS} "数据库审计日志"
done
echo ""

# 6. 清理trace文件
echo "【6. Trace文件清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # 旧的trace文件
    cleanup_logs ${node} "/u01/app/oracle/diag/rdbms/orcl/*/trace" "*.trc" ${LOG_RETENTION_DAYS} "Trace文件"
    cleanup_logs ${node} "/u01/app/oracle/diag/rdbms/orcl/*/trace" "*.trc.gz" ${LOG_RETENTION_DAYS} "压缩Trace文件"

    # CDMP文件 (core dump)
    cleanup_logs ${node} "/u01/app/oracle/diag/rdbms/orcl/*/incident" "cdmp_*" ${LOG_RETENTION_DAYS} "Incident dump文件"
    cleanup_logs ${node} "/u01/app/oracle/diag/rdbms/orcl/*/trace" "cdmp_*" ${LOG_RETENTION_DAYS} "Trace目录dump文件"
done
echo ""

# 7. 清理操作系统日志
echo "【7. 操作系统日志清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    cleanup_logs ${node} "/var/log" "cron-*" ${LOG_RETENTION_DAYS} "旧cron日志"
    cleanup_logs ${node} "/var/log" "maillog-*" ${LOG_RETENTION_DAYS} "旧maillog"
    cleanup_logs ${node} "/var/log" "secure-*" ${LOG_RETENTION_DAYS} "旧secure日志"
    cleanup_logs ${node} "/var/log" "messages-*" ${LOG_RETENTION_DAYS} "旧messages日志"
done
echo ""

# 8. 清理临时文件
echo "【8. 临时文件清理】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # Oracle临时文件
    cleanup_logs ${node} "/tmp" ".oracle_*" ${LOG_RETENTION_DAYS} "Oracle临时文件"

    # 系统临时目录清理 (只清理超过90天的文件)
    ssh ${REMOTE_USER}@${node} "find /tmp -type f -mtime +${LOG_RETENTION_DAYS} -delete 2>/dev/null"
    echo "  已清理系统临时目录"
done
echo ""

# 9. 清空已删除但仍被进程占用的文件空间
echo "【9. 清理已删除文件的磁盘空间】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    # 查找已删除但仍被占用的文件
    ssh ${REMOTE_USER}@${node} "lsof +L1 2>/dev/null | grep -i oracle | grep deleted" | while read line; do
        pid=$(echo $line | awk '{print $2}')
        fd=$(echo $line | awk '{print $4}' | tr -d 'w')
        if [ ! -z "${pid}" ] && [ ! -z "${fd}" ]; then
            echo "  清理进程 ${pid} 的文件描述符 ${fd}"
            ssh ${REMOTE_USER}@${node} ": > /proc/${pid}/fd/${fd} 2>/dev/null"
        fi
    done
done
echo ""

# 10. 显示清理后的磁盘空间
echo "【10. 清理后的磁盘空间】"
for node in ${NODE1} ${NODE2}; do
    echo "节点 ${node}:"
    ssh ${REMOTE_USER}@${node} "df -h | grep -E '^/dev/' | head -5"
    echo ""
done

echo "========================================="
echo "  日志清理完成"
echo "========================================="
echo ""
echo "建议:"
echo "1. 定期检查清理策略是否合适"
echo "2. 重要日志可以考虑归档到备份存储"
echo "3. 监控磁盘空间使用趋势"
echo ""
