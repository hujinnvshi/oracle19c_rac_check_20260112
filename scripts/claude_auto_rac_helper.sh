#!/bin/bash
#####################################################################
# Claude Code 辅助的Oracle RAC自动化管理脚本
# 用途: 结合Claude Code实现半自动化RAC集群管理
#####################################################################

NODE1="172.16.48.131"
NODE2="172.16.48.133"
REMOTE_USER="root"
CLAUDE_SESSION_DIR="./claude_sessions"

# 创建会话目录
mkdir -p "$CLAUDE_SESSION_DIR"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Claude Code 辅助的RAC自动化管理"
echo "========================================="
echo ""

# 检查Claude Code是否可用
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}Claude Code CLI未安装${NC}"
    echo "请访问: https://code.claude.com"
    exit 1
fi

# 菜单选择
echo "请选择自动化任务:"
echo ""
echo "1) 自动诊断集群问题"
echo "2) 自动生成优化报告"
echo "3) 自动审查RAC脚本"
echo "4) 自动生成维护计划"
echo "5) 使用Claude分析日志"
echo "0) 退出"
echo ""
read -p "请输入选项 [0-5]: " choice

case $choice in
    1)
        echo ""
        echo "启动Claude Code进行集群诊断..."
        echo ""

        # 收集集群信息
        ./rac_quick_check.sh > cluster_status.txt 2>&1

        # 使用Claude Code分析
        claude -p "请分析以下Oracle RAC集群状态，并诊断潜在问题：

$(cat cluster_status.txt)

请提供:
1. 问题诊断
2. 严重程度评估
3. 建议的解决方案
" \
            --allowedTools "Bash,Read,Write" \
            --output-format json \
            > "$CLAUDE_SESSION_DIR/diagnosis_$(date +%Y%m%d_%H%M%S).json"

        echo "诊断完成，结果保存在: $CLAUDE_SESSION_DIR/"
        ;;

    2)
        echo ""
        echo "启动Claude Code生成优化报告..."
        echo ""

        claude -p "基于以下Oracle RAC 19c集群配置，请生成详细的性能优化报告:

集群信息: $(cat reports/cluster/rac_cluster_info.txt)
系统资源: $(cat reports/system/rac_system_131.txt)
优化建议: $(cat reports/cluster/rac_optimization_recommendations.txt)

请生成包含以下内容的优化报告:
1. 内存优化建议
2. 网络优化建议
3. ASM磁盘管理建议
4. 参数调优建议
5. 实施优先级排序
" \
            --allowedTools "Read,Write" \
            --output-format json \
            > "$CLAUDE_SESSION_DIR/optimization_$(date +%Y%m%d_%H%M%S).json"

        echo "优化报告已生成: $CLAUDE_SESSION_DIR/"
        ;;

    3)
        echo ""
        echo "启动Claude Code审查RAC脚本..."
        echo ""

        claude -p "请审查以下Oracle RAC管理脚本，找出潜在问题和改进建议:

$(ls scripts/*.sh | head -5 | xargs -I {} sh -c 'echo \"=== {} ===\"; head -50 {}')"

请检查:
1. 错误处理是否完善
2. 是否有安全问题
3. 代码质量
4. 性能优化建议
5. 最佳实践符合度
" \
            --allowedTools "Read,Grep,Bash" \
            --output-format json \
            > "$CLAUDE_SESSION_DIR/code_review_$(date +%Y%m%d_%H%M%S).json"

        echo "代码审查完成: $CLAUDE_SESSION_DIR/"
        ;;

    4)
        echo ""
        echo "启动Claude Code生成维护计划..."
        echo ""

        claude -p "基于以下Oracle RAC集群信息，请生成详细的月度维护计划:

集群配置: $(cat reports/cluster/rac_cluster_info.txt)
当前状态: $(./rac_quick_check.sh 2>&1)

请生成包含以下内容的维护计划:
1. 每日检查项目
2. 每周检查项目
3. 每月检查项目
4. 每季度检查项目
5. 每个项目的具体命令
6. 预计执行时间
7. 风险评估
" \
            --allowedTools "Read,Write" \
            --output-format json \
            > "$CLAUDE_SESSION_DIR/maintenance_plan_$(date +%Y%m%d_%H%M%S).json"

        echo "维护计划已生成: $CLAUDE_SESSION_DIR/"
        ;;

    5)
        echo ""
        echo "使用Claude分析Oracle日志..."
        echo ""

        # 收集日志文件位置
        echo "请提供日志文件路径:"
        read -p "Alert日志路径 (按回车使用默认): " alert_log

        if [ -z "$alert_log" ]; then
            alert_log="/u01/app/oracle/diag/rdbms/orcl/orcl1/trace/alert_orcl1.log"
        fi

        claude -p "请分析以下Oracle Alert日志，找出错误和警告:

文件路径: $alert_log

请提供:
1. 错误和警告统计
2. 严重程度分级
3. 问题根因分析
4. 建议的解决方案
5. 预防措施
" \
            --allowedTools "Read,Grep,Bash" \
            --output-format json \
            > "$CLAUDE_SESSION_DIR/log_analysis_$(date +%Y%m%d_%H%M%S).json"

        echo "日志分析完成: $CLAUDE_SESSION_DIR/"
        ;;

    0)
        echo "退出"
        exit 0
        ;;

    *)
        echo "无效选项"
        exit 1
        ;;
esac

echo ""
echo "========================================="
echo "  Claude Code辅助完成"
echo "========================================="
echo ""
echo "会话文件保存在: $CLAUDE_SESSION_DIR/"
echo "可以使用这些结果进一步自动化操作"
echo ""
