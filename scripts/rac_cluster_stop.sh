#!/bin/bash
#####################################################################
# Oracle RAC 集群安全关闭脚本
# 用途: 按正确顺序关闭Oracle RAC集群
# 注意: 执行前请确认已停止所有应用连接
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
LOG_FILE="./rac_logs/rac_stop_$(date +%Y%m%d_%H%M%S).log"

# 创建日志目录
mkdir -p ./rac_logs

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "${LOG_FILE}"
}

print_header() {
    echo ""
    echo "=========================================" | tee -a "${LOG_FILE}"
    echo "  $1" | tee -a "${LOG_FILE}"
    echo "=========================================" | tee -a "${LOG_FILE}"
    echo "" | tee -a "${LOG_FILE}"
}

# 执行远程命令
exec_remote() {
    local node=$1
    local cmd=$2
    ssh ${REMOTE_USER}@${node} "${cmd}"
}

# 检查集群状态
check_cluster_status() {
    print_header "检查集群状态"

    log "检查节点集群资源状态..."
    exec_remote ${NODE1} "su - grid -c 'crsctl status resource -t'" | tee -a "${LOG_FILE}"
    echo ""
}

# 停止数据库实例
stop_database() {
    print_header "步骤1: 停止数据库实例"

    log "正在停止数据库 ORCL..."

    # 使用srvctl停止数据库
    exec_remote ${NODE1} "su - grid -c 'srvctl stop database -d orcl -o immediate'" | tee -a "${LOG_FILE}"

    log "等待10秒..."
    sleep 10

    # 验证数据库是否已停止
    log "验证数据库状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status database -d orcl'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 数据库已停止"
}

# 停止监听器
stop_listener() {
    print_header "步骤2: 停止监听器"

    log "正在停止监听器..."

    # 停止所有监听器
    exec_remote ${NODE1} "su - grid -c 'srvctl stop listener'" | tee -a "${LOG_FILE}"

    log "等待5秒..."
    sleep 5

    # 验证监听器状态
    log "验证监听器状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status listener'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 监听器已停止"
}

# 停止ASM实例
stop_asm() {
    print_header "步骤3: 停止ASM实例"

    log "正在停止ASM实例..."

    # 停止ASM
    exec_remote ${NODE1} "su - grid -c 'srvctl stop asm'" | tee -a "${LOG_FILE}"

    log "等待5秒..."
    sleep 5

    # 验证ASM状态
    log "验证ASM状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status asm'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ ASM实例已停止"
}

# 停止集群ware
stop_clusterware() {
    print_header "步骤4: 停止集群ware (CRS)"

    log "正在节点1停止集群ware..."
    exec_remote ${NODE1} "su - grid -c 'crsctl stop cluster -all'" | tee -a "${LOG_FILE}"

    log "等待30秒..."
    sleep 30

    # 验证集群状态
    log "验证集群状态..."
    exec_remote ${NODE1} "su - grid -c 'crsctl check crs'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 集群ware已停止"
}

# 在特定节点停止集群
stop_node_clusterware() {
    local node=$1
    local node_name=$2

    log "正在节点 ${node_name} 停止集群ware..."
    exec_remote ${node} "su - grid -c 'crsctl stop crs'" | tee -a "${LOG_FILE}"

    log "等待15秒..."
    sleep 15
}

# 最终验证
final_verification() {
    print_header "最终验证"

    log "检查节点1集群状态..."
    exec_remote ${NODE1} "su - grid -c 'crsctl check crs'" 2>&1 | tee -a "${LOG_FILE}"

    log "检查节点2集群状态..."
    exec_remote ${NODE2} "su - grid -c 'crsctl check crs'" 2>&1 | tee -a "${LOG_FILE}"
    echo ""

    log "检查Oracle进程..."
    exec_remote ${NODE1} "ps -ef | grep -E 'ora_|pmon|smon|dbw0' | grep -v grep" | tee -a "${LOG_FILE}"
    exec_remote ${NODE2} "ps -ef | grep -E 'ora_|pmon|smon|dbw0' | grep -v grep" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 验证完成"
}

# 显示菜单
show_menu() {
    echo ""
    echo "========================================="
    echo "  Oracle RAC 集群关闭选项"
    echo "========================================="
    echo ""
    echo "请选择关闭方式:"
    echo "  1) 完整关闭 (数据库+监听器+ASM+集群ware)"
    echo "  2) 仅停止数据库"
    echo "  3) 停止数据库+监听器"
    echo "  4) 停止数据库+监听器+ASM"
    echo "  5) 停止节点1集群"
    echo "  6) 停止节点2集群"
    echo "  7) 停止所有集群ware"
    echo "  8) 检查集群状态后退出"
    echo "  0) 取消"
    echo ""
    echo -n "请输入选项 [0-8]: "
}

# 主程序
main() {
    clear

    echo "========================================="
    echo "  Oracle RAC 集群安全关闭脚本"
    echo "========================================="
    echo ""
    echo "节点1: ${NODE1} (rac1)"
    echo "节点2: ${NODE2} (rac2)"
    echo ""
    echo "日志文件: ${LOG_FILE}"
    echo ""

    # 检查当前集群状态
    log "开始关闭流程..."
    check_cluster_status

    # 显示菜单
    show_menu
    read choice

    case ${choice} in
        1)
            print_header "执行完整关闭流程"
            stop_database
            stop_listener
            stop_asm
            stop_clusterware
            final_verification
            ;;
        2)
            print_header "仅停止数据库"
            stop_database
            ;;
        3)
            print_header "停止数据库和监听器"
            stop_database
            stop_listener
            ;;
        4)
            print_header "停止数据库、监听器和ASM"
            stop_database
            stop_listener
            stop_asm
            ;;
        5)
            print_header "停止节点1集群"
            stop_node_clusterware ${NODE1} "rac1"
            ;;
        6)
            print_header "停止节点2集群"
            stop_node_clusterware ${NODE2} "rac2"
            ;;
        7)
            print_header "停止所有集群ware"
            stop_clusterware
            ;;
        8)
            print_header "仅检查状态"
            check_cluster_status
            ;;
        0)
            echo "操作已取消"
            exit 0
            ;;
        *)
            echo -e "${RED}无效选项${NC}"
            exit 1
            ;;
    esac

    print_header "关闭操作完成"
    log "集群关闭操作已完成"
    log "日志已保存到: ${LOG_FILE}"

    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}  集群关闭操作完成${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "注意事项:"
    echo "  1. 确认所有应用已停止连接"
    echo "  2. 检查日志文件: ${LOG_FILE}"
    echo "  3. 如需启动集群，使用: ./rac_cluster_start.sh"
    echo ""
}

# 执行主程序
main
