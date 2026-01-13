#!/bin/bash
#####################################################################
# Oracle RAC 环境配置模板
# 用途: 新环境的配置文件模板
#####################################################################

# ========================================
# 基础配置
# ========================================

# 节点配置
NODE1="172.16.48.131"           # 节点1 IP地址
NODE2="172.16.48.133"           # 节点2 IP地址
REMOTE_USER="root"              # SSH用户

# 集群配置
CLUSTER_NAME="rac-cluster"      # 集群名称
DB_NAME="ORCL"                  # 数据库名称
DB_UNIQUE_NAME="ORCL"           # 数据库唯一名

# ========================================
# 环境类型
# ========================================

# 环境类型: production/test/development
ENV_TYPE="production"

# 环境描述
ENV_DESC="Oracle RAC 19c 生产环境"

# ========================================
# 路径配置
# ========================================

# Oracle Base
ORACLE_BASE="/u01/app"

# Grid Home
GRID_HOME="/u01/app/grid/19.0.0"

# Oracle Home
ORACLE_HOME="/u01/app/oracle/product/19.0.0/db_1"

# ========================================
# 用户配置
# ========================================

# Grid用户
GRID_USER="grid"
GRID_GROUP="oinstall"

# Oracle用户
ORACLE_USER="oracle"
ORACLE_GROUP="oinstall"

# ========================================
# 网络配置
# ========================================

# 公网网络
PUBLIC_NETWORK="172.16.48.0/24"

# 私有网络
PRIVATE_NETWORK="10.10.15.0/24"

# SCAN配置
SCAN_NAME="rac-scan"
SCAN_IP="172.16.48.135"

# VIP配置
VIP1="172.16.48.132"
VIP2="172.16.48.134"

# ========================================
# 监控配置
# ========================================

# 是否启用监控
MONITORING_ENABLED="yes"

# 监控间隔(秒)
CHECK_INTERVAL=300

# 告警阈值
TABLESPACE_WARNING_THRESHOLD=85
TABLESPACE_CRITICAL_THRESHOLD=95
DISK_WARNING_THRESHOLD=80
DISK_CRITICAL_THRESHOLD=90

# ========================================
# 备份配置
# ========================================

# 备份保留天数
BACKUP_RETENTION_DAYS=30

# 备份目录
BACKUP_BASE="/backup"

# RMAN配置
RMAN_CATALOG=""
USE_CATALOG="no"

# ========================================
# 日志配置
# ========================================

# 日志保留天数
LOG_RETENTION_DAYS=90

# 日志目录
LOG_BASE="./rac_logs"

# 是否启用详细日志
VERBOSE_LOGGING="yes"

# ========================================
# 自动化配置
# ========================================

# 是否启用自动表空间监控
AUTO_TABLESPACE_MONITOR="yes"

# 是否启用自动日志清理
AUTO_LOG_CLEANUP="yes"

# 是否启用健康检查自动执行
AUTO_HEALTH_CHECK="yes"

# ========================================
# 报告配置
# ========================================

# 报告目录
REPORT_DIR="./rac_reports"

# 报告格式: text/html/json
REPORT_FORMAT="text"

# 是否生成对比报告
GENERATE_COMPARE_REPORT="yes"

# ========================================
# 安全配置
# ========================================

# SSH端口
SSH_PORT=22

# SSH密钥路径
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

# 是否使用sudo
USE_SUDO="no"

# ========================================
# 通知配置
# ========================================

# 钉钉告警
DINGTALK_WEBHOOK=""
DINGTALK_ENABLED="no"

# 企业微信告警
WECHAT_WEBHOOK=""
WECHAT_ENABLED="no"

# 邮件告警
EMAIL_SMTP_HOST=""
EMAIL_FROM=""
EMAIL_TO=""
EMAIL_ENABLED="no"

# ========================================
# Claude Code集成
# ========================================

# 是否启用Claude Code辅助
CLAUDE_ENABLED="no"

# Claude Code路径
CLAUDE_CMD="claude"

# Claude分析输出目录
CLAUDE_OUTPUT_DIR="./claude_sessions"

# ========================================
# 自定义检查
# ========================================

# 自定义检查脚本列表（空格分隔）
CUSTOM_CHECKS=""

# 跳过的检查项（空格分隔）
SKIP_CHECKS=""

# ========================================
# 其他配置
# ========================================

# 时区
TIMEZONE="Asia/Shanghai"

# 语言设置
LANG="en_US.UTF-8"

# 字符集
NLS_LANG="AMERICAN_AMERICA.AL32UTF8"

# ========================================
# 版本信息
# ========================================

# 配置文件版本
CONFIG_VERSION="1.0"

# 最后更新时间
LAST_UPDATE="2026-01-12"

# 更新人
UPDATE_BY="admin"
