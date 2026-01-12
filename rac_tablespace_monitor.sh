#!/bin/bash
#####################################################################
# Oracle RAC 表空间使用率监控脚本
# 用途: 检查表空间使用情况，超过阈值时告警
#####################################################################

NODE1="172.16.48.131"
REMOTE_USER="root"
WARNING_THRESHOLD=85
CRITICAL_THRESHOLD=95

echo "========================================="
echo "  Oracle RAC 表空间监控"
echo "  检查时间: $(date +%Y-%m-%d\ %H:%M:%S)"
echo "========================================="
echo ""

# 获取表空间使用率
ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 100
col tablespace_name format a25
col size_gb format 999,999.99
col free_gb format 999,999.99
col used_pct format 999.99
col status format a10

select
    df.tablespace_name,
    round(df.bytes/1024/1024/1024,2) as size_gb,
    round(fs.bytes/1024/1024/1024,2) as free_gb,
    round((df.bytes-fs.bytes)/df.bytes*100,2) as used_pct,
    ts.status
from
    (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) df,
    (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) fs,
    dba_tablespaces ts
where df.tablespace_name = fs.tablespace_name
  and df.tablespace_name = ts.tablespace_name
order by (df.bytes-fs.bytes)/df.bytes desc;
exit;
SQLEOF\"" 2>/dev/null | tee tablespace_usage.txt

echo ""
echo "========================================="
echo "  告警检查 (阈值: ${WARNING_THRESHOLD}% / ${CRITICAL_THRESHOLD}%)"
echo "========================================="

# 检查是否超过阈值
CRITICAL_COUNT=$(grep -v "^$" tablespace_usage.txt | grep -v "TABLESPACE_NAME" | awk -v threshold=${CRITICAL_THRESHOLD} '{if ($5+0 > threshold) print $0}' | wc -l)
WARNING_COUNT=$(grep -v "^$" tablespace_usage.txt | grep -v "TABLESPACE_NAME" | awk -v threshold=${WARNING_THRESHOLD} '{if ($5+0 > threshold && $5+0 <= '${CRITICAL_THRESHOLD}') print $0}' | wc -l)

if [ ${CRITICAL_COUNT} -gt 0 ]; then
    echo ""
    echo "【严重告警】以下表空间使用率超过 ${CRITICAL_THRESHOLD}%:"
    grep -v "^$" tablespace_usage.txt | grep -v "TABLESPACE_NAME" | awk -v threshold=${CRITICAL_THRESHOLD} '{if ($5+0 > threshold) print $0}' | while read line; do
        echo "  ⚠️  ${line}"
    done
fi

if [ ${WARNING_COUNT} -gt 0 ]; then
    echo ""
    echo "【警告】以下表空间使用率超过 ${WARNING_THRESHOLD}%:"
    grep -v "^$" tablespace_usage.txt | grep -v "TABLESPACE_NAME" | awk -v threshold=${WARNING_THRESHOLD} '{if ($5+0 > threshold && $5+0 <= '${CRITICAL_THRESHOLD}') print $0}' | while read line; do
        echo "  ⚡ ${line}"
    done
fi

if [ ${CRITICAL_COUNT} -eq 0 ] && [ ${WARNING_COUNT} -eq 0 ]; then
    echo "  ✅ 所有表空间使用率正常"
fi

# 检查临时表空间
echo ""
echo "========================================="
echo "  临时表空间使用情况"
echo "========================================="

ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 100
col tablespace_name format a25
col used_gb format 999,999.99
col total_gb format 999,999.99
col used_pct format 999.99

select
    d.tablespace_name,
    round(d.used_bytes*2/1024/1024/1024,2) as used_gb,
    round(d.total_bytes*2/1024/1024/1024,2) as total_gb,
    round(d.used_bytes/d.total_bytes*100,2) as used_pct
from
    (select tablespace_name, sum(bytes_used) used_bytes, sum(bytes_free) + sum(bytes_used) total_bytes
     from v\\\$temp_extent_pool
     group by tablespace_name) d
order by d.used_bytes/d.total_bytes desc;
exit;
SQLEOF\"" 2>/dev/null

# UNDO表空间检查
echo ""
echo "========================================="
echo "  UNDO表空间使用情况"
echo "========================================="

ssh ${REMOTE_USER}@${NODE1} "su - oracle -c \"sqlplus -S / as sysdba <<'SQLEOF'
set lines 200 pages 100
col tablespace_name format a15
col status format a10
col size_gb format 999,999.99
col used_gb format 999,999.99
col used_pct format 999.99

select
    d.tablespace_name,
    d.status,
    round(df.bytes/1024/1024/1024,2) as size_gb,
    round((df.bytes - fs.bytes)/1024/1024/1024,2) as used_gb,
    round((df.bytes - fs.bytes)/df.bytes*100,2) as used_pct
from dba_tablespaces d,
     (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) df,
     (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) fs
where d.contents = 'UNDO'
  and d.tablespace_name = df.tablespace_name(+)
  and d.tablespace_name = fs.tablespace_name(+)
order by d.tablespace_name;
exit;
SQLEOF\"" 2>/dev/null

rm -f tablespace_usage.txt
echo ""
echo "========================================="
echo "  监控检查完成"
echo "========================================="
