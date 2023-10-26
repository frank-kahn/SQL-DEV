-- 修改会话超时时间
gs_guc reload -N all -I all -c "session_timeout = 86400s"
gs_om -t restart
-- 查看集群状态
gs_om -t status --detail
-- 连接数据库
gsql -p 12345 -d postgres -r