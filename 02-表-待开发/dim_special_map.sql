/*
# 表名
dim_special_map

# 备注


# 结果字段（字段名-类型-comment）
map_id      varchar 地图ID
map_tag     varchar 地图标签
description varchar 说明
update_dt   varchar 数据更新日期

*/

-- *更新数据
with
args as (select '2026-03-02' as update_dt)
select map_id,map_tag,description
,(select update_dt from args) as update_dt
from (values
 ('33505039877199','adv','冒险新手引导地图')
,('80818399610066','ogc','冲突再起')
,('79385866714034','ogc','沸点战场')
,('5029406704850' ,'ogc','诡异调查组')
) as t(map_id,map_tag,description)
;