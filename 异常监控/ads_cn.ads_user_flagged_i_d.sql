/*
# 表名
ads_cn.ads_user_flagged_i_d

# 数据起始日期
2025-11-01

# 更新频率
D-1

# 备注
- 未来包含所有疑似异常账号，目前先标记【疑似模拟请求】

# 依赖
hive.dwd_cn.dwd_real_active_user_detail_i_d
hive.mn_external_query.r_sdk_70000_scene_9999
hive.mn_external_query.r_sdk_70000_scene_3701
hive.mnv_ads_cloud_cn.r_sdk_70000_scene_3702
hive.mn_external_query.r_sdk_70000_scene_3901
hive.mnv_ads_pbg_cn.r_sdk_70000_scene_3902

# 结果字段（字段名-类型-comment）
dt              varchar 数据起始日期：2025-11-01
uin             bigint  UIN
flag            varchar 异常标记：疑似模拟请求

*/

-- 疑似模拟请求：仅官版（1/110）登录，有服务端登录记录，无客户端登录记录（9999，3701，3702，3901，3902）
with
args as (select '2026-03-08' as dt)
,data1 as (
    select uin
    from (
        select uin
        ,array_distinct(array_agg(channel_id)) as channels
        from hive.dwd_cn.dwd_real_active_user_detail_i_d
        where dt=(select dt from args)
        group by 1
    )
    where cardinality(filter(channels,x->x not in ('1','110')))=0
)
,data2 as (
    select distinct uin
    from hive.mn_external_query.r_sdk_70000_scene_9999
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args) and (select dt from args)
    union
    select distinct uin
    from hive.mn_external_query.r_sdk_70000_scene_3701
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args) and (select dt from args)
    union
    select distinct uin
    from hive.mnv_ads_cloud_cn.r_sdk_70000_scene_3702
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args) and (select dt from args)
    union
    select distinct uin
    from hive.mn_external_query.r_sdk_70000_scene_3901
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args) and (select dt from args)
    union
    select distinct uin
    from hive.mnv_ads_pbg_cn.r_sdk_70000_scene_3902
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args) and (select dt from args)
)
select (select dt from args) as dt
,t1.uin
,'疑似模拟请求' as flag
from data1 t1
left join data2 t2 on t1.uin=t2.uin
where t2.uin is null
;