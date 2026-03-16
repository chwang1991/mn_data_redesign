/*
# 表名
dws_cn.dws_consumption_user_map_stats_i_d

# 数据起始日期
2024-01-01

# 更新频率
D-1

# 备注
- 地图内购买星星、家具、商店等冒险相关行为都没有地图ID
- hive.mnv_ads_ugc_cn.map_consumption_details_day 这张表上游数据来自mysql，
用于目前开发者收益，对应迷你币消费日志的
and why='gm.exec'
and reason in ('ministudio_shop','kfz_iap_finish','kfz_skin_buy')
少了

- 真假币判断自 2022-01-01 起生效

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day
hive.mnv_ads_ugc_cn.map_consumption_details_day

# 结果字段（字段名-类型-comment）
uin         bigint  用户ID
map_id      varchar 地图ID
ctype       int     地图类型（1-存档，2-地图）
minicoin    bigint  迷你币消费数量
minibean    bigint  迷你豆消费数量
minipoint   bigint  迷你点消费数量
dt          varchar 数据起始日期：2024-01-01

*/
-- *验收
desc dws_cn.dws_consumption_user_map_stats_i_d;
select * from dws_cn.dws_consumption_user_map_stats_i_d
where dt='2026-02-01'
order by 1,2,3 limit 100
;

with
args as (select '2026-02-01' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,minicoin_data as (
    select uin
    ,coalesce(
         json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.map_id')
        ,json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.mapid')
        ,json_extract_scalar(args,'$[1].map_id')
    ) as map_id
    ,try_cast(sum(abs(diff)) as bigint) as minicoin
    from hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day
    where dt=(select dt from args)
    and diff<0
    and (why='gm.exec' and reason in (
         'ministudio_shop'
        ,'kfz_iap_finish'
        ,'kfz_skin_buy'
        ,'kfz_iap_reward'
        ,'kfz_sub_coin_exchange'
        ,'kfz_unlock_pay_map'
    ))
    group by 1,2
)
,minibean_data as (
    select try_cast(uin as bigint) as uin,map_id
    ,sum(pay_cnt) as minibean
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt=(select dt from args)
    and event_code='bean_pay'
    group by 1,2
)
,minipoint_data as (
    select try_cast(uin as bigint) as uin,map_id
    ,sum(pay_cnt) as minipoint
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt=(select dt from args)
    and event_code='point_pay'
    group by 1,2
)
,pay_data as (
    select uin,map_id
    ,sum(minicoin)  as minicoin
    ,sum(minibean)  as minibean
    ,sum(minipoint) as minipoint
    from (
        select uin,map_id,minicoin,0 as minibean,0 as minipoint from minicoin_data
        union all
        select uin,map_id,0 as minicoin,minibean,0 as minipoint from minibean_data
        union all
        select uin,map_id,0 as minicoin,0 as minibean,minipoint from minipoint_data
    )
    group by 1,2
)
select t1.uin,t1.map_id,t2.ctype
,minicoin
,minibean
,minipoint
,(select dt from args) as dt
from pay_data t1
inner join map_data t2 on t1.map_id=t2.map_id
order by 1,2,3 limit 100
;