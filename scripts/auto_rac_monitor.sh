#!/bin/bash
#####################################################################
# Oracle RAC 自动监控和响应脚本
# 结合Claude Code实现半自动化运维
#####################################################################

# 配置
NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
LOG_DIR="./auto_monitor_logs"
ALERT_THRESHOLD=85

# 创建日志目录
mkdir -p "$LOG_DIR"

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_DIR/auto_monitor.log"
}

# 发送告警
send_alert() {
    local severity=$1
    local message=$2

    log "[$severity] $message"

    # 这里可以集成钉钉、企业微信、邮件等告警方式
    # 示例: 钉钉webhook
    # curl -X POST "https://oapi.dingtalk.com/robot/send?access_token=xxx" \
    #   -H 'Content-Type: application/json' \
    #   -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"$message\"}}"
}

# 检查表空间使用率
check_tablespaces() {
    log "检查表空间使用率..."

    ./scripts/rac_tablespace_monitor.sh > "$LOG_DIR/tablespace_check.txt" 2>&1

    # 提取超阈值的表空间
    critical=$(grep -i "严重" "$LOG_DIR/tablespace_check.txt" | wc -l)
    warning=$(grep -i "警告" "$LOG_DIR/tablespace_check.txt" | wc -l)

    if [ $critical -gt 0 ]; then
        send_alert "CRITICAL" "发现 $critical 个表空间使用率严重告警！"
        return 1
    elif [ $warning -gt 0 ]; then
        send_alert "WARNING" "发现 $warning 个表空间使用率警告"
        return 1
    fi

    log "表空间检查正常"
    return 0
}

# 检查集群状态
check_cluster() {
    log "检查集群状态..."

    local status=$(ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl check crs'" 2>&1)

    if echo "$status" | grep -q "offline"; then
        send_alert "CRITICAL" "集群服务离线！"
        return 1
    fi

    log "集群状态正常"
    return 0
}

# 检查数据库实例
check_database() {
    log "检查数据库实例状态..."

    local status=$(ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
select status from v\\\$instance where rownum=1;
exit;
SQLEOF\"" 2>&1)

    if ! echo "$status" | grep -q "OPEN"; then
        send_alert "CRITICAL" "数据库实例未OPEN！"
        return 1
    fi

    log "数据库状态正常"
    return 0
}

# 检查磁盘空间
check_disk_space() {
    log "检查磁盘空间..."

    local disk_usage=$(ssh ${REMOTE_USER}@${NODE1} "df -h | grep -E '^/dev/' | awk '{print \$5}' | sed 's/%//'")

    for usage in $disk_usage; do
        if [ $usage -gt 90 ]; then
            send_alert "CRITICAL" "磁盘使用率超过90%: ${usage}%"
            return 1
        elif [ $usage -gt 80 ]; then
            send_alert "WARNING" "磁盘使用率超过80%: ${usage}%"
        fi
    done

    log "磁盘空间正常"
    return 0
}

# 自动响应
auto_response() {
    local issue_type=$1

    log "启动自动响应流程: $issue_type"

    case $issue_type in
        "tablespace")
            log "尝试自动清理表空间..."
            # 自动清理临时表空间
            ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
alter tablespace temp shrink space;
exit;
SQLEOF\"" 2>&1 | tee -a "$LOG_DIR/auto_response.log"
            ;;

        "cluster")
            log "尝试自动重启集群资源..."
            # 这里需要谨慎，可能只是记录
            log "集群问题需要人工介入"
            ;;

        "disk")
            log "尝试自动清理日志..."
            ./scripts/rac_log_cleanup.sh 2>&1 | tee -a "$LOG_DIR/auto_response.log"
            ;;

        *)
            log "未知的自动响应类型: $issue_type"
            ;;
    esac
}

# 主监控循环
main_monitor() {
    log "开始自动监控检查..."

    local has_issue=0

    # 执行各项检查
    check_tablespaces || has_issue=1
    check_cluster || has_issue=1
    check_database || has_issue=1
    check_disk_space || has_issue=1

    # 如果有问题，使用Claude Code分析
    if [ $has_issue -eq 1 ]; then
        log "检测到问题，启动Claude Code分析..."

        if command -v claude &> /dev/null; then
            claude -p "Oracle RAC监控发现以下问题，请分析并提供解决方案:

$(tail -50 "$LOG_DIR/auto_monitor.log")

请提供:
1. 问题根因分析
2. 紧急程度评估
3. 建议的解决方案
4. 预防措施
" \
                --allowedTools "Read,Write" \
                --output-format json \
                > "$LOG_DIR/claude_analysis_$(date +%Y%m%d_%H%M%S).json"

            log "Claude分析完成"
        fi
    fi

    log "监控检查完成"
}

# 定时任务模式
daemon_mode() {
    log "启动守护进程模式..."
    log "检查间隔: 300秒 (5分钟)"

    while true; do
        main_monitor
        sleep 300
    done
}

# 一次性检查模式
single_mode() {
    log "执行一次性监控检查"
    main_monitor
}

# 菜单
case "${1:-single}" in
    "daemon"|"d")
        echo "启动守护进程模式 (按Ctrl+C停止)"
        daemon_mode
        ;;
    "single"|"s"|"")
        single_mode
        ;;
    *)
        echo "用法: $0 [single|daemon]"
        echo "  single  - 执行一次检查 (默认)"
        echo "  daemon  - 持续监控模式"
        exit 1
        ;;
esac
