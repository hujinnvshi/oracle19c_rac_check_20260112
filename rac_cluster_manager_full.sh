#!/bin/bash
#####################################################################
# Oracle RAC 集群综合管理脚本
# 用途: 提供集群的启动、停止、重启和状态查询功能
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
LOG_DIR="./rac_logs"

# 创建日志目录
mkdir -p ${LOG_DIR}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 显示主菜单
show_main_menu() {
    clear
    echo ""
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}  Oracle RAC 集群管理工具${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    echo "集群节点:"
    echo "  节点1: ${NODE1} (rac1)"
    echo "  节点2: ${NODE2} (rac2)"
    echo ""
    echo "========================================="
    echo "  请选择操作:"
    echo "========================================="
    echo ""
    echo "  ${GREEN}1${NC}) 启动集群"
    echo "  ${RED}2${NC}) 停止集群"
    echo "  ${YELLOW}3${NC}) 重启集群"
    echo "  ${BLUE}4${NC}) 查看集群状态"
    echo "  ${BLUE}5${NC}) 快速健康检查"
    echo "  ${BLUE}6${NC}) 查看集群资源"
    echo "  ${BLUE}7${NC}) 查看数据库状态"
    echo "  ${BLUE}8${NC}) 查看ASM状态"
    echo "  ${BLUE}9${NC}) 查看网络配置"
    echo "  ${BLUE}10${NC}) 检查开机自启动"
    echo "  ${BLUE}11${NC}) 查看系统资源"
    echo "  ${YELLOW}12${NC}) 节点管理"
    echo "  ${BLUE}0${NC}) 退出"
    echo ""
    echo -n "请输入选项 [0-12]: "
}

# 启动集群
start_cluster() {
    ./rac_cluster_start.sh
}

# 停止集群
stop_cluster() {
    ./rac_cluster_stop.sh
}

# 重启集群
restart_cluster() {
    echo ""
    echo -e "${YELLOW}=========================================${NC}"
    echo -e "${YELLOW}  重启集群${NC}"
    echo -e "${YELLOW}=========================================${NC}"
    echo ""
    echo "警告: 重启集群会导致服务中断!"
    echo ""
    read -p "确认要重启集群吗? (yes/no): " confirm

    if [ "${confirm}" != "yes" ]; then
        echo "操作已取消"
        read -p "按回车键继续..."
        return
    fi

    echo ""
    echo "步骤1: 停止集群..."
    ./rac_cluster_stop.sh

    echo ""
    echo "等待30秒后启动..."
    sleep 30

    echo ""
    echo "步骤2: 启动集群..."
    ./rac_cluster_start.sh

    echo ""
    echo -e "${GREEN}集群重启完成!${NC}"
    read -p "按回车键继续..."
}

# 查看集群状态
view_cluster_status() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  集群状态${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> CRS状态"
    echo "节点1:"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl check crs'" 2>/dev/null
    echo "节点2:"
    ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl check crs'" 2>/dev/null
    echo ""

    echo ">>> 集群节点"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'olsnodes -s'" 2>/dev/null
    echo ""

    echo ">>> 集群版本"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl query crs activeversion'" 2>/dev/null
    echo ""

    read -p "按回车键继续..."
}

# 快速健康检查
quick_health_check() {
    ./rac_quick_check.sh
    read -p "按回车键继续..."
}

# 查看集群资源
view_cluster_resources() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  集群资源状态${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl status resource -t'" 2>/dev/null

    echo ""
    read -p "按回车键继续..."
}

# 查看数据库状态
view_database_status() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  数据库状态${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> 数据库实例状态"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'srvctl status database -d orcl'" 2>/dev/null
    echo ""

    echo ">>> 实例详情 (节点1)"
    ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 50
col instance_name format a15
col status format a10
col open_mode format a15
select instance_name, status, open_mode, to_char(startup_time, 'YYYY-MM-DD HH24:MI:SS') as startup_time from v\\\$instance;
exit;
SQLEOF\"" 2>/dev/null
    echo ""

    echo ">>> 实例详情 (节点2)"
    ssh ${REMOTE_USER}@${NODE2} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 50
col instance_name format a15
col status format a10
select instance_name, status, to_char(startup_time, 'YYYY-MM-DD HH24:MI:SS') as startup_time from v\\\$instance;
exit;
SQLEOF\"" 2>/dev/null
    echo ""

    read -p "按回车键继续..."
}

# 查看ASM状态
view_asm_status() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  ASM状态${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> ASM实例状态"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'srvctl status asm'" 2>/dev/null
    echo ""

    echo ">>> ASM磁盘组"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'asmcmd lsdg'" 2>/dev/null
    echo ""

    echo ">>> ASM磁盘使用情况"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'asmcmd lsdg --suppressheader'" | awk '{printf "  %-15s 总空间: %6sGB  已用: %6sGB  使用率: %s%%\n", $NF, $9/1024/1024, ($9-$10)/1024/1024, int(($9-$10)/$9*100)}'
    echo ""

    read -p "按回车键继续..."
}

# 查看网络配置
view_network_config() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  网络配置${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> 节点1网络"
    ssh ${REMOTE_USER}@${NODE1} "ip a show | grep -E '^[0-9]+:|inet ' | grep -v '127.0.0.1'" | sed 's/^/  /'
    echo ""

    echo ">>> 节点2网络"
    ssh ${REMOTE_USER}@${NODE2} "ip a show | grep -E '^[0-9]+:|inet ' | grep -v '127.0.0.1'" | sed 's/^/  /'
    echo ""

    echo ">>> VIP状态"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'srvctl status vip'" 2>/dev/null | sed 's/^/  /'
    echo ""

    echo ">>> SCAN状态"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'srvctl status scan'" 2>/dev/null | sed 's/^/  /'
    echo ""

    echo ">>> 监听器状态"
    ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'srvctl status listener'" 2>/dev/null | sed 's/^/  /'
    echo ""

    read -p "按回车键继续..."
}

# 检查开机自启动
check_autostart() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  开机自启动状态${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> 节点1"
    echo "oracle-ohasd服务:"
    ssh ${REMOTE_USER}@${NODE1} "systemctl is-enabled oracle-ohasd 2>/dev/null" | sed 's/^/  /'
    ssh ${REMOTE_USER}@${NODE1} "systemctl status oracle-ohasd 2>/dev/null" | grep -E "Loaded:|Active:" | sed 's/^/  /'
    echo ""

    echo ">>> 节点2"
    echo "oracle-ohasd服务:"
    ssh ${REMOTE_USER}@${NODE2} "systemctl is-enabled oracle-ohasd 2>/dev/null" | sed 's/^/  /'
    ssh ${REMOTE_USER}@${NODE2} "systemctl status oracle-ohasd 2>/dev/null" | grep -E "Loaded:|Active:" | sed 's/^/  /'
    echo ""

    echo "✅ 集群已配置为开机自启动"
    echo ""
    echo "说明: oracle-ohasd服务为enabled时，集群ware会在系统启动时自动启动"
    echo ""

    read -p "按回车键继续..."
}

# 查看系统资源
view_system_resources() {
    clear
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  系统资源${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    echo ">>> 节点1"
    echo "内存:"
    ssh ${REMOTE_USER}@${NODE1} "free -h" | sed 's/^/  /'
    echo "负载:"
    ssh ${REMOTE_USER}@${NODE1} "uptime" | sed 's/^/  /'
    echo ""

    echo ">>> 节点2"
    echo "内存:"
    ssh ${REMOTE_USER}@${NODE2} "free -h" | sed 's/^/  /'
    echo "负载:"
    ssh ${REMOTE_USER}@${NODE2} "uptime" | sed 's/^/  /'
    echo ""

    echo ">>> 磁盘使用"
    echo "节点1:"
    ssh ${REMOTE_USER}@${NODE1} "df -h | grep -E '^/dev/' | head -5" | sed 's/^/  /'
    echo ""
    echo "节点2:"
    ssh ${REMOTE_USER}@${NODE2} "df -h | grep -E '^/dev/' | head -5" | sed 's/^/  /'
    echo ""

    read -p "按回车键继续..."
}

# 节点管理子菜单
node_management() {
    while true; do
        clear
        echo ""
        echo -e "${YELLOW}=========================================${NC}"
        echo -e "${YELLOW}  节点管理${NC}"
        echo -e "${YELLOW}=========================================${NC}"
        echo ""
        echo "  1) 停止节点1集群"
        echo "  2) 停止节点2集群"
        echo "  3) 启动节点1集群"
        echo "  4) 启动节点2集群"
        echo "  5) 重启节点1集群"
        echo "  6) 重启节点2集群"
        echo "  0) 返回主菜单"
        echo ""
        echo -n "请输入选项 [0-6]: "

        read choice

        case ${choice} in
            1)
                echo ""
                echo "停止节点1集群..."
                ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl stop crs'" 2>/dev/null
                echo "节点1集群已停止"
                read -p "按回车键继续..."
                ;;
            2)
                echo ""
                echo "停止节点2集群..."
                ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl stop crs'" 2>/dev/null
                echo "节点2集群已停止"
                read -p "按回车键继续..."
                ;;
            3)
                echo ""
                echo "启动节点1集群..."
                ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl start crs'" 2>/dev/null
                echo "等待60秒..."
                sleep 60
                echo "节点1集群已启动"
                read -p "按回车键继续..."
                ;;
            4)
                echo ""
                echo "启动节点2集群..."
                ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl start crs'" 2>/dev/null
                echo "等待60秒..."
                sleep 60
                echo "节点2集群已启动"
                read -p "按回车键继续..."
                ;;
            5)
                echo ""
                echo "重启节点1集群..."
                ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl stop crs'" 2>/dev/null
                echo "等待30秒..."
                sleep 30
                ssh ${REMOTE_USER}@${NODE1} "su - grid -c 'crsctl start crs'" 2>/dev/null
                echo "等待60秒..."
                sleep 60
                echo "节点1集群已重启"
                read -p "按回车键继续..."
                ;;
            6)
                echo ""
                echo "重启节点2集群..."
                ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl stop crs'" 2>/dev/null
                echo "等待30秒..."
                sleep 30
                ssh ${REMOTE_USER}@${NODE2} "su - grid -c 'crsctl start crs'" 2>/dev/null
                echo "等待60秒..."
                sleep 60
                echo "节点2集群已重启"
                read -p "按回车键继续..."
                ;;
            0)
                return
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                sleep 2
                ;;
        esac
    done
}

# 主程序
main() {
    # 检查脚本是否存在
    if [ ! -x "./rac_cluster_start.sh" ]; then
        chmod +x ./rac_cluster_start.sh 2>/dev/null
    fi
    if [ ! -x "./rac_cluster_stop.sh" ]; then
        chmod +x ./rac_cluster_stop.sh 2>/dev/null
    fi
    if [ ! -x "./rac_quick_check.sh" ]; then
        chmod +x ./rac_quick_check.sh 2>/dev/null
    fi

    while true; do
        show_main_menu
        read choice

        case ${choice} in
            1)
                start_cluster
                ;;
            2)
                stop_cluster
                ;;
            3)
                restart_cluster
                ;;
            4)
                view_cluster_status
                ;;
            5)
                quick_health_check
                ;;
            6)
                view_cluster_resources
                ;;
            7)
                view_database_status
                ;;
            8)
                view_asm_status
                ;;
            9)
                view_network_config
                ;;
            10)
                check_autostart
                ;;
            11)
                view_system_resources
                ;;
            12)
                node_management
                ;;
            0)
                echo ""
                echo "退出集群管理工具"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                echo -e "${RED}无效选项，请重新选择${NC}"
                sleep 2
                ;;
        esac
    done
}

# 执行主程序
main
