#!/bin/bash
#####################################################################
# Oracle RAC 集群启动脚本
# 用途: 按正确顺序启动Oracle RAC集群
# 注意: 确保集群已正确关闭后再启动
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
LOG_FILE="./rac_logs/rac_start_$(date +%Y%m%d_%H%M%S).log"

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

# 检查节点是否可达
check_node_reachable() {
    local node=$1
    local node_name=$2

    log "检查节点 ${node_name} 是否可达..."
    if exec_remote ${node} "hostname" >/dev/null 2>&1; then
        log "✅ 节点 ${node_name} 可达"
        return 0
    else
        log "❌ 节点 ${node_name} 不可达"
        return 1
    fi
}

# 启动集群ware (CRS)
start_clusterware() {
    print_header "步骤1: 启动集群ware (CRS)"

    log "正在启动集群ware..."

    # 在两个节点上启动CRS
    log "启动节点1 CRS..."
    exec_remote ${NODE1} "su - grid -c 'crsctl start crs'" | tee -a "${LOG_FILE}"

    log "启动节点2 CRS..."
    exec_remote ${NODE2} "su - grid -c 'crsctl start crs'" | tee -a "${LOG_FILE}"

    log "等待60秒让CRS完全启动..."
    sleep 60

    # 验证CRS状态
    log "验证CRS状态..."
    log "节点1:"
    exec_remote ${NODE1} "su - grid -c 'crsctl check crs'" | tee -a "${LOG_FILE}"
    log "节点2:"
    exec_remote ${NODE2} "su - grid -c 'crsctl check crs'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 集群ware已启动"
}

# 等待资源稳定
wait_for_resources() {
    print_header "等待集群资源稳定"

    log "等待所有资源启动完成..."
    local max_wait=120
    local waited=0

    while [ ${waited} -lt ${max_wait} ]; do
        local offline_count=$(exec_remote ${NODE1} "su - grid -c 'crsctl status resource -t'" | grep -c "OFFLINE" || echo "0")

        if [ ${offline_count} -eq 0 ]; then
            log "✅ 所有资源已启动"
            break
        fi

        log "等待中... (${waited}/${max_wait}秒), 仍有 ${offline_count} 个资源离线"
        sleep 10
        waited=$((waited + 10))
    done

    echo ""
}

# 检查集群资源状态
check_cluster_resources() {
    print_header "检查集群资源状态"

    log "获取集群资源状态..."
    exec_remote ${NODE1} "su - grid -c 'crsctl status resource -t'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 资源状态检查完成"
}

# 启动数据库实例
start_database() {
    print_header "步骤2: 启动数据库实例"

    log "正在启动数据库 ORCL..."

    # 使用srvctl启动数据库
    exec_remote ${NODE1} "su - grid -c 'srvctl start database -d orcl'" | tee -a "${LOG_FILE}"

    log "等待20秒让数据库完全启动..."
    sleep 20

    # 验证数据库状态
    log "验证数据库状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status database -d orcl'" | tee -a "${LOG_FILE}"
    echo ""

    # 检查数据库实例
    log "检查数据库实例详情..."
    exec_remote ${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 50
select instance_name, status, database_role, open_mode from v\\\$instance;
exit;
SQLEOF\"" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 数据库已启动"
}

# 启动监听器（如果未启动）
start_listener() {
    print_header "步骤3: 检查并启动监听器"

    log "检查监听器状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status listener'" | tee -a "${LOG_FILE}"
    echo ""

    # 如果监听器未运行，启动它
    local listener_status=$(exec_remote ${NODE1} "su - grid -c 'srvctl status listener'" 2>/dev/null | grep -c "ONLINE" || echo "0")

    if [ ${listener_status} -eq 0 ]; then
        log "监听器未运行，正在启动..."
        exec_remote ${NODE1} "su - grid -c 'srvctl start listener'" | tee -a "${LOG_FILE}"

        log "等待10秒..."
        sleep 10

        log "验证监听器状态..."
        exec_remote ${NODE1} "su - grid -c 'srvctl status listener'" | tee -a "${LOG_FILE}"
    else
        log "✅ 监听器已在运行"
    fi
    echo ""
}

# 验证服务
verify_services() {
    print_header "步骤4: 验证集群服务"

    log "检查VIP状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status vip'" | tee -a "${LOG_FILE}"
    echo ""

    log "检查SCAN状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status scan'" | tee -a "${LOG_FILE}"
    echo ""

    log "检查ASM状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status asm'" | tee -a "${LOG_FILE}"
    echo ""

    log "检查节点应用程序状态..."
    exec_remote ${NODE1} "su - grid -c 'srvctl status nodeapps'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 服务验证完成"
}

# 检查数据库连接
check_database_connectivity() {
    print_header "步骤5: 检查数据库连接"

    log "测试本地数据库连接..."
    exec_remote ${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
select 'Database connection successful' as status from dual;
exit;
SQLEOF\"" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 数据库连接检查完成"
}

# 最终健康检查
final_health_check() {
    print_header "最终健康检查"

    log "执行快速健康检查..."

    # 集群状态
    log "集群CRS状态:"
    exec_remote ${NODE1} "su - grid -c 'crsctl check crs'" | tee -a "${LOG_FILE}"
    echo ""

    # 数据库实例
    log "数据库实例:"
    exec_remote ${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200
select instance_name, status, open_mode from v\\\$instance;
exit;
SQLEOF\"" | tee -a "${LOG_FILE}"
    echo ""

    # ASM磁盘组
    log "ASM磁盘组:"
    exec_remote ${NODE1} "su - grid -c 'asmcmd lsdg --suppressheader'" | tee -a "${LOG_FILE}"
    echo ""

    log "✅ 健康检查完成"
}

# 显示菜单
show_menu() {
    echo ""
    echo "========================================="
    echo "  Oracle RAC 集群启动选项"
    echo "========================================="
    echo ""
    echo "请选择启动方式:"
    echo "  1) 完整启动 (集群ware+数据库+所有服务)"
    echo "  2) 仅启动数据库"
    echo "  3) 启动数据库+监听器"
    echo "  4) 仅启动集群ware"
    echo "  5) 启动节点1集群"
    echo "  6) 启动节点2集群"
    echo "  7) 健康检查"
    echo "  0) 取消"
    echo ""
    echo -n "请输入选项 [0-7]: "
}

# 主程序
main() {
    clear

    echo "========================================="
    echo "  Oracle RAC 集群启动脚本"
    echo "========================================="
    echo ""
    echo "节点1: ${NODE1} (rac1)"
    echo "节点2: ${NODE2} (rac2)"
    echo ""
    echo "日志文件: ${LOG_FILE}"
    echo ""

    # 检查节点可达性
    log "检查节点可达性..."
    check_node_reachable ${NODE1} "rac1" || exit 1
    check_node_reachable ${NODE2} "rac2" || exit 1
    echo ""

    # 显示菜单
    show_menu
    read choice

    case ${choice} in
        1)
            print_header "执行完整启动流程"
            start_clusterware
            wait_for_resources
            check_cluster_resources
            start_database
            start_listener
            verify_services
            check_database_connectivity
            final_health_check
            ;;
        2)
            print_header "仅启动数据库"
            start_database
            ;;
        3)
            print_header "启动数据库和监听器"
            start_database
            start_listener
            ;;
        4)
            print_header "仅启动集群ware"
            start_clusterware
            wait_for_resources
            check_cluster_resources
            ;;
        5)
            print_header "启动节点1集群"
            log "启动节点1 CRS..."
            exec_remote ${NODE1} "su - grid -c 'crsctl start crs'" | tee -a "${LOG_FILE}"
            sleep 60
            check_cluster_resources
            ;;
        6)
            print_header "启动节点2集群"
            log "启动节点2 CRS..."
            exec_remote ${NODE2} "su - grid -c 'crsctl start crs'" | tee -a "${LOG_FILE}"
            sleep 60
            check_cluster_resources
            ;;
        7)
            print_header "健康检查"
            final_health_check
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

    print_header "启动操作完成"
    log "集群启动操作已完成"
    log "日志已保存到: ${LOG_FILE}"

    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}  集群启动操作完成${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "集群状态总结:"
    exec_remote ${NODE1} "su - grid -c 'crsctl status resource -t'" | grep -E "ora.orcl.db|ora.asm|ora.LISTENER|ora.scan" | head -10
    echo ""
    echo "注意事项:"
    echo "  1. 验证应用连接正常"
    echo "  2. 检查日志文件: ${LOG_FILE}"
    echo "  3. 如需关闭集群，使用: ./rac_cluster_stop.sh"
    echo ""
}

# 执行主程序
main
