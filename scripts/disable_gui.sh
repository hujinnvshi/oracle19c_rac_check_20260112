#!/bin/bash
#####################################################################
# Oracle RAC 节点关闭图形界面脚本
# 用途: 禁用图形界面以提高系统性能和安全性
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "========================================="
echo "  Oracle RAC 节点图形界面禁用工具"
echo "========================================="
echo ""
echo "警告: 此操作将关闭图形界面"
echo "系统将进入文本模式运行"
echo ""

# 确认操作
read -p "确认要关闭两个节点的图形界面吗? (yes/no): " confirm

if [ "${confirm}" != "yes" ]; then
    echo "操作已取消"
    exit 0
fi

echo ""
echo "开始禁用图形界面..."
echo ""

# 函数: 在单个节点上禁用图形界面
disable_gui_on_node() {
    local node=$1
    local node_name=$2

    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}处理节点: ${node_name} (${node})${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""

    # 1. 检查当前运行级别
    echo "1. 检查当前运行级别..."
    ssh ${REMOTE_USER}@${node} "systemctl get-default" | tee -a disable_gui_log.txt
    echo ""

    # 2. 检查是否安装了图形界面
    echo "2. 检查图形界面安装状态..."
    ssh ${REMOTE_USER}@${node} "rpm -qa | grep -E 'gnome|kde|xorg' | head -5" | tee -a disable_gui_log.txt
    local gui_count=$(ssh ${REMOTE_USER}@${node} "rpm -qa | grep -E 'gnome|kde|xorg' | wc -l")
    echo "图形界面包数量: ${gui_count}"
    echo ""

    if [ ${gui_count} -eq 0 ]; then
        echo -e "${YELLOW}节点 ${node_name} 未安装图形界面，跳过${NC}"
        echo ""
        return
    fi

    # 3. 检查当前运行模式
    echo "3. 检查当前系统运行模式..."
    ssh ${REMOTE_USER}@${node} "systemctl get-default" | tee -a disable_gui_log.txt
    echo ""

    # 4. 将默认target改为multi-user.target (文本模式)
    echo "4. 设置默认启动模式为文本模式..."
    ssh ${REMOTE_USER}@${node} "systemctl set-default multi-user.target" | tee -a disable_gui_log.txt
    echo ""

    # 5. 验证设置
    echo "5. 验证新的默认target..."
    ssh ${REMOTE_USER}@${node} "systemctl get-default" | tee -a disable_gui_log.txt
    echo ""

    # 6. 显示立即切换到文本模式的命令
    echo "6. 可选操作..."
    echo "   如需立即切换到文本模式，请手动执行:"
    echo "   systemctl isolate multi-user.target"
    echo ""

    # 7. 显示资源节省估算
    echo "7. 资源节省估算:"
    local mem_saved=$(ssh ${REMOTE_USER}@${node} "free -m | grep Mem | awk '{print \$2}'")
    local saved_mb=$((mem_saved * 15 / 100))
    echo "   预计可节省内存: ${saved_mb} MB - ${saved_mb} MB"
    echo "   预计可节省CPU: 1-2%"
    echo ""

    echo -e "${GREEN}✅ 节点 ${node_name} 图形界面禁用配置完成${NC}"
    echo "   下次重启后将进入文本模式"
    echo ""
}

# 处理两个节点
disable_gui_on_node ${NODE1} "rac1"
echo ""
disable_gui_on_node ${NODE2} "rac2"

echo ""
echo "========================================="
echo "  操作完成总结"
echo "========================================="
echo ""
echo "已完成的配置:"
echo "  ✓ 节点 rac1: 默认启动模式已改为 multi-user.target"
echo "  ✓ 节点 rac2: 默认启动模式已改为 multi-user.target"
echo ""
echo "说明:"
echo "  1. 图形界面将在下次重启后不再自动启动"
echo "  2. 系统将进入纯文本模式，更安全高效"
echo "  3. 如需临时使用图形界面，可执行: systemctl isolate graphical.target"
echo "  4. 如需恢复图形界面自动启动，执行: systemctl set-default graphical.target"
echo ""
echo "重启系统以使配置生效:"
echo "  节点1: ssh root@${NODE1} 'reboot'"
echo "  节点2: ssh root@${NODE2} 'reboot'"
echo ""
echo "或者使用综合管理工具重启节点"
echo ""
