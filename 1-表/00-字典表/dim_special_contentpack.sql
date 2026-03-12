/*
# 表名
dim_special_contentpack

# 备注

# 结果字段（字段名-类型-comment）
cp_id       varchar 整合包ID
description varchar 说明
update_dt   varchar 数据更新日期

*/

with
args as (select '2026-03-02' as update_dt)
select cp_id,description
,(select update_dt from args) as update_dt
from (values
 ('73538430043135','僵尸围城')
,('71343701754879','钓者传说')
,('29924308408238','植物大战僵尸灾变100天')
,('40928538255228','侏罗纪时代')
,('62300488291286','迷你宇宙')
,('37787867017343','迷你世界-轮回')
) as t(cp_id,description)
;
