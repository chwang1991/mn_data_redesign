/*
# 表名
dim_channel

# 备注
来源：hive.mnv_ads_config_cn.miniworld_channel

# 结果字段（字段名-类型-comment）
channel_id     int     渠道ID
channel_name   varchar 渠道名称
platform_id    int     平台ID，1/2/3=安卓/ios/PC
is_main        int     是否重点渠道，0/1
update_dt      varchar 数据更新日期

*/

with
args as (select '2026-03-02' as update_dt)
select channel_id
,channel_name
,platform_id
,is_main
,(select update_dt from args) as update_dt
from hive.mnv_ads_config_cn.miniworld_channel
where product_id=1 --迷你世界
and status=1 --正常
;