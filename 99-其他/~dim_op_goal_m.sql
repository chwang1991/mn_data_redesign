/*
# 表名
dim_op_goal_m

# 备注
来源：???

# 结果字段（字段名-类型-comment）
dt          varchar 日期（每月1日）
mau         bigint  目标MAU
pay         bigint  目标充值收入（含直播*）
update_dt   varchar 数据更新日期

*/

with
args as (select '2026-03-02' as update_dt)
select dt,dau,pay
,(select update_dt from args) as update_dt
from (values
 ('2025-01-01',5592900,1170788)

) as t(dt,mau,pay)
;