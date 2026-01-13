#!/bin/bash
#####################################################################
# Oracle RAC 新环境初始化脚本
# 用途: 快速为新RAC环境生成定制化管理工具
#####################################################################

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0;32m'

echo "========================================="
echo "  Oracle RAC 环境初始化工具"
echo "========================================="
echo ""

# 检查参数
if [ $# -lt 3 ]; then
    echo "用法: $0 <环境名称> <节点1_IP> <节点2_IP> [选项]"
    echo ""
    echo "参数:"
    echo "  环境名称    - 环境标识，如: prod_beijing_rac01"
    echo "  节点1_IP   - 节点1 IP地址"
    echo "  节点2_IP   - 节点2 IP地址"
    echo ""
    echo "选项:"
    echo "  --cluster <名称>   - 集群名称 (默认: rac-cluster)"
    echo "  --database <名称>  - 数据库名称 (默认: ORCL)"
    echo "  --type <类型>      - 环境类型: production/test/development"
    echo "  --user <用户>      - SSH用户 (默认: root)"
    echo ""
    echo "示例:"
    echo "  $0 prod_rac01 192.168.1.101 192.168.1.102"
    echo "  $0 test_rac01 10.0.0.1 10.0.0.2 --type test --database TESTDB"
    echo ""
    exit 1
fi

# 解析参数
ENV_NAME=$1
NODE1=$2
NODE2=$3
shift 3

# 默认值
CLUSTER_NAME="rac-cluster"
DB_NAME="ORCL"
ENV_TYPE="production"
REMOTE_USER="root"

# 解析选项
while [ $# -gt 0 ]; do
    case $1 in
        --cluster)
            CLUSTER_NAME="$2"
            shift 2
            ;;
        --database)
            DB_NAME="$2"
            shift 2
            ;;
        --type)
            ENV_TYPE="$2"
            shift 2
            ;;
        --user)
            REMOTE_USER="$2"
            shift 2
            ;;
        *)
            echo "未知选项: $1"
            exit 1
            ;;
    esac
done

echo "环境信息:"
echo "  环境名称: $ENV_NAME"
echo "  节点1: $NODE1"
echo "  节点2: $NODE2"
echo "  集群名: $CLUSTER_NAME"
echo "  数据库: $DB_NAME"
echo "  类型: $ENV_TYPE"
echo ""

# 确认
read -p "确认创建环境? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "已取消"
    exit 0
fi

echo ""
echo "开始初始化..."
echo ""

# 创建环境目录
ENV_DIR="environments/$ENV_NAME"
mkdir -p "$ENV_DIR"
mkdir -p "$ENV_DIR/logs"
mkdir -p "$ENV_DIR/reports"
mkdir -p "$ENV_DIR/config"

echo "✓ 创建环境目录: $ENV_DIR"

# 生成环境配置文件
cat > "$ENV_DIR/env_config.sh" << EOFCONFIG
#!/bin/bash
# Oracle RAC 环境配置
# 环境: $ENV_NAME
# 创建时间: $(date)

# 节点配置
NODE1="$NODE1"
NODE2="$NODE2"
REMOTE_USER="$REMOTE_USER"

# 集群配置
CLUSTER_NAME="$CLUSTER_NAME"
DB_NAME="$DB_NAME"
DB_UNIQUE_NAME="$DB_NAME"

# 环境类型
ENV_TYPE="$ENV_TYPE"
ENV_DESC="$ENV_NAME - $(date +%Y-%m-%d) 初始化"

# 路径配置
ORACLE_BASE="/u01/app"
GRID_HOME="/u01/app/grid/19.0.0"
ORACLE_HOME="/u01/app/oracle/product/19.0.0/db_1"

# 网络配置
PUBLIC_NETWORK="\$(echo $NODE1 | cut -d. -f1-3).0/24"
SCAN_IP="\$(echo $NODE1 | cut -d. -f1-3).135"
VIP1="\$(echo $NODE1 | cut -d. -f1-3).132"
VIP2="\$(echo $NODE1 | cut -d. -f1-3).134"

# 监控配置
MONITORING_ENABLED="yes"
CHECK_INTERVAL=300
TABLESPACE_WARNING_THRESHOLD=85
TABLESPACE_CRITICAL_THRESHOLD=95

# 日志配置
LOG_BASE="$ENV_DIR/logs"
LOG_RETENTION_DAYS=90

# 报告配置
REPORT_DIR="$ENV_DIR/reports"
REPORT_FORMAT="text"

# 备份配置
BACKUP_RETENTION_DAYS=30

# 自动化配置
AUTO_TABLESPACE_MONITOR="yes"
AUTO_LOG_CLEANUP="yes"
AUTO_HEALTH_CHECK="yes"

# 配置版本
CONFIG_VERSION="1.0"
LAST_UPDATE="$(date +%Y-%m-%d)"
UPDATE_BY="admin"
EOFCONFIG

chmod +x "$ENV_DIR/env_config.sh"
echo "✓ 生成环境配置: $ENV_DIR/env_config.sh"

# 生成定制化脚本
cat > "$ENV_DIR/manage.sh" << 'EOFSCRIPT'
#!/bin/bash
#####################################################################
# Oracle RAC 环境管理脚本
# 自动生成，请勿手动编辑
#####################################################################

# 加载环境配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$(dirname "$SCRIPT_DIR")"
source "$ENV_DIR/env_config.sh"

# 使用主目录的脚本
BASE_DIR="$(dirname "$ENV_DIR")"

# 快速检查
quick_check() {
    echo "执行快速检查..."
    cd "$BASE_DIR/scripts" && ./rac_quick_check.sh
}

# 完整检查
full_check() {
    echo "执行完整健康检查..."
    cd "$BASE_DIR/scripts" && ./rac_daily_health_check.sh
}

# 表空间监控
tablespace_check() {
    echo "检查表空间..."
    cd "$BASE_DIR/scripts" && ./rac_tablespace_monitor.sh
}

# 集群管理
cluster_manage() {
    echo "打开集群管理工具..."
    cd "$BASE_DIR/scripts" && ./rac_cluster_manager_full.sh
}

# 生成报告
generate_report() {
    echo "生成环境报告..."
    REPORT_FILE="$ENV_DIR/reports/health_report_$(date +%Y%m%d_%H%M%S).txt"

    cat > "$REPORT_FILE" << EOF
========================================
      Oracle RAC 环境健康报告
========================================

环境名称: $ENV_NAME
检查时间: $(date)

集群信息:
  节点1: $NODE1
  节点2: $NODE2
  集群名: $CLUSTER_NAME
  数据库: $DB_NAME
  类型: $ENV_TYPE

系统状态:
$(quick_check | tee -a "$REPORT_FILE")

========================================
  报告结束
========================================
EOF

    echo "✓ 报告已生成: $REPORT_FILE"
}

# 显示帮助
show_help() {
    cat << EOF
Oracle RAC 环境管理脚本

环境: $ENV_NAME
节点: $NODE1, $NODE2

可用命令:
  quick_check          - 快速状态检查
  full_check           - 完整健康检查
  tablespace_check     - 表空间监控
  cluster_manage       - 集群管理工具
  generate_report      - 生成环境报告
  show_config          - 显示环境配置
  show_help            - 显示本帮助

示例:
  $0 quick_check
  $0 generate_report
EOF
}

# 显示配置
show_config() {
    echo "环境配置: $ENV_NAME"
    echo ""
    echo "节点信息:"
    echo "  节点1: $NODE1"
    echo "  节点2: $NODE2"
    echo ""
    echo "集群信息:"
    echo "  集群名: $CLUSTER_NAME"
    echo "  数据库: $DB_NAME"
    echo ""
    echo "环境类型: $ENV_TYPE"
}

# 主程序
case "${1:-help}" in
    quick_check)
        quick_check
        ;;
    full_check)
        full_check
        ;;
    tablespace_check)
        tablespace_check
        ;;
    cluster_manage)
        cluster_manage
        ;;
    generate_report)
        generate_report
        ;;
    show_config)
        show_config
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "未知命令: $1"
        show_help
        exit 1
        ;;
esac
EOFSCRIPT

chmod +x "$ENV_DIR/manage.sh"
echo "✓ 生成管理脚本: $ENV_DIR/manage.sh"

# 生成README
cat > "$ENV_DIR/README.md" << EOFREADME
# $ENV_NAME - Oracle RAC 环境

## 环境信息

- **环境名称**: $ENV_NAME
- **创建时间**: $(date +%Y-%m-%d)
- **节点1**: $NODE1
- **节点2**: $NODE2
- **集群名**: $CLUSTER_NAME
- **数据库**: $DB_NAME
- **环境类型**: $ENV_TYPE

## 快速开始

### 查看环境状态

\`\`\`bash
cd environments/$ENV_NAME
./manage.sh quick_check
\`\`\`

### 执行完整检查

\`\`\`bash
./manage.sh full_check
\`\`\`

### 集群管理

\`\`\`bash
./manage.sh cluster_manage
\`\`\`

### 生成报告

\`\`\`bash
./manage.sh generate_report
\`\`\`

## 环境配置

配置文件: \`env_config.sh\`

重要配置项:
- NODE1, NODE2: 节点IP地址
- CLUSTER_NAME: 集群名称
- DB_NAME: 数据库名称
- ENV_TYPE: 环境类型

## 日志和报告

- **日志目录**: \`logs/\`
- **报告目录**: \`reports/\`

## 维护记录

### $(date +%Y-%m-%d)
- 环境初始化
- 基础配置完成

---

**维护人员**: admin
**最后更新**: $(date +%Y-%m-%d)
EOFREADME

echo "✓ 生成README: $ENV_DIR/README.md"

# 测试SSH连接
echo ""
echo "测试SSH连接..."
if ssh ${REMOTE_USER}@${NODE1} "hostname" >/dev/null 2>&1; then
    echo "✓ 节点1连接正常"
else
    echo -e "${RED}✗ 节点1连接失败，请检查SSH配置${NC}"
fi

if ssh ${REMOTE_USER}@${NODE2} "hostname" >/dev/null 2>&1; then
    echo "✓ 节点2连接正常"
else
    echo -e "${RED}✗ 节点2连接失败，请检查SSH配置${NC}"
fi

# 执行快速检查
echo ""
echo "执行首次环境检查..."
./rac_quick_check.sh > "$ENV_DIR/logs/initial_check.txt" 2>&1
echo "✓ 初始检查完成，结果保存在: $ENV_DIR/logs/initial_check.txt"

# 生成首次报告
echo ""
./manage.sh generate_report

echo ""
echo "========================================="
echo "  ✅ 环境初始化完成！"
echo "========================================="
echo ""
echo "环境目录: $ENV_DIR"
echo "管理脚本: $ENV_DIR/manage.sh"
echo "配置文件: $ENV_DIR/env_config.sh"
echo ""
echo "快速开始:"
echo "  cd environments/$ENV_NAME"
echo "  ./manage.sh quick_check"
echo ""
echo "查看帮助:"
echo "  ./manage.sh show_help"
echo ""
