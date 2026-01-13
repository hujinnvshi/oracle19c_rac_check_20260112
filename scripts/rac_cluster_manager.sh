#!/bin/bash
#####################################################################
# Oracle RAC 集群资源管理脚本
# 用途: 快速管理集群资源（启动/停止/重启/状态）
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"

# 显示使用帮助
show_help() {
    echo "========================================="
    echo "  Oracle RAC 集群资源管理工具"
    echo "========================================="
    echo ""
    echo "用法: $0 [选项] [资源名]"
    echo ""
    echo "选项:"
    echo "  status [资源名]     - 查看资源状态 (默认显示所有)"
    echo "  start <资源名>      - 启动指定资源"
    echo "  stop <资源名>       - 停止指定资源"
    echo "  restart <资源名>    - 重启指定资源"
    echo "  list                - 列出所有资源"
    echo "  health              - 集群健康检查"
    echo "  help                - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 status                    # 查看所有资源状态"
    echo "  $0 status ora.orcl.db        # 查看数据库资源状态"
    echo "  $0 restart ora.orcl.db       # 重启数据库"
    echo "  $0 health                    # 健康检查"
    echo ""
    echo "常用资源名:"
    echo "  ora.orcl.db                  # 数据库实例"
    echo "  ora.asm                      # ASM实例"
    echo "  ora.LISTENER.lsnr            # 监听器"
    echo "  ora.scan1.vip                # SCAN VIP"
    echo "  ora.rac1.vip / ora.rac2.vip  # 节点VIP"
    echo ""
}

# 列出所有资源
list_resources() {
    echo "========================================="
    echo "  集群资源列表"
    echo "========================================="
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource -t'" | grep -E "^ora" | awk '{print $1}' | sort -u
}

# 查看资源状态
check_status() {
    local resource=$1
    echo "========================================="
    echo "  资源状态查询"
    echo "========================================="
    echo "查询时间: $(date)"
    echo ""

    if [ -z "${resource}" ]; then
        echo "显示所有资源状态:"
        echo ""
        ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource -t'"
    else
        echo "资源 ${resource} 的详细状态:"
        echo ""
        ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ${resource}'"
    fi
}

# 停止资源
stop_resource() {
    local resource=$1

    if [ -z "${resource}" ]; then
        echo "错误: 请指定要停止的资源名"
        echo "用法: $0 stop <资源名>"
        exit 1
    fi

    echo "========================================="
    echo "  停止资源: ${resource}"
    echo "========================================="
    echo "正在停止资源 ${resource}..."
    echo ""

    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl stop resource ${resource}'"

    echo ""
    echo "等待5秒后检查状态..."
    sleep 5

    echo ""
    echo "资源当前状态:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ${resource}'"
}

# 启动资源
start_resource() {
    local resource=$1

    if [ -z "${resource}" ]; then
        echo "错误: 请指定要启动的资源名"
        echo "用法: $0 start <资源名>"
        exit 1
    fi

    echo "========================================="
    echo "  启动资源: ${resource}"
    echo "========================================="
    echo "正在启动资源 ${resource}..."
    echo ""

    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl start resource ${resource}'"

    echo ""
    echo "等待5秒后检查状态..."
    sleep 5

    echo ""
    echo "资源当前状态:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ${resource}'"
}

# 重启资源
restart_resource() {
    local resource=$1

    if [ -z "${resource}" ]; then
        echo "错误: 请指定要重启的资源名"
        echo "用法: $0 restart <资源名>"
        exit 1
    fi

    echo "========================================="
    echo "  重启资源: ${resource}"
    echo "========================================="

    echo "步骤1: 停止资源..."
    stop_resource "${resource}"

    echo ""
    echo "========================================="
    echo "步骤2: 启动资源..."
    start_resource "${resource}"
}

# 健康检查
health_check() {
    echo "========================================="
    echo "  集群健康检查"
    echo "========================================="
    echo "检查时间: $(date)"
    echo ""

    # 1. CRS状态
    echo "【1. CRS服务状态】"
    echo -n "  节点1: "
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl check crs'" >/dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常"
    echo -n "  节点2: "
    ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl check crs'" >/dev/null 2>&1 && echo "✅ 正常" || echo "❌ 异常"
    echo ""

    # 2. 节点状态
    echo "【2. 集群节点状态】"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'olsnodes -s'"
    echo ""

    # 3. 关键资源状态
    echo "【3. 关键资源状态】"
    echo "  数据库实例:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.orcl.db'" | grep -E "STATE=|TARGET=" | sed 's/^/    /'
    echo ""
    echo "  ASM实例:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.asm'" | grep -E "STATE=|TARGET=" | sed 's/^/    /'
    echo ""
    echo "  监听器:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.LISTENER.lsnr'" | grep -E "STATE=|TARGET=" | sed 's/^/    /'
    echo ""
    echo "  SCAN VIP:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.scan1.vip'" | grep -E "STATE=|TARGET=" | sed 's/^/    /'
    echo ""

    # 4. VIP状态
    echo "【4. 节点VIP状态】"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.rac1.vip'" | grep "STATE=" | sed 's/^/  节点1 VIP: /'
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource ora.rac2.vip'" | grep "STATE=" | sed 's/^/  节点2 VIP: /'
    echo ""

    # 5. ASM磁盘组
    echo "【5. ASM磁盘组状态】"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'asmcmd lsdg --suppressheader'" | awk '{printf "  %-15s %s\n", $NF, $2}'
    echo ""

    echo "========================================="
    echo "  健康检查完成"
    echo "========================================="
}

# 主程序
case "$1" in
    status)
        check_status "$2"
        ;;
    start)
        start_resource "$2"
        ;;
    stop)
        stop_resource "$2"
        ;;
    restart)
        restart_resource "$2"
        ;;
    list)
        list_resources
        ;;
    health)
        health_check
        ;;
    help|--help|-h|"")
        show_help
        ;;
    *)
        echo "错误: 未知选项 '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
