/*
# 表名
map_pay_stats

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

map_id              varchar 地图ID
ctype               int     地图类型（1-存档，2-地图）
minicoin            bigint  迷你币消费数量
minicoin_payer      bigint  迷你币消费人数
minibean            bigint  迷你豆消费数量
minibean_payer      bigint  迷你豆消费人数
minipoint           bigint  迷你点消费数量
minipoint_payer     bigint  迷你点消费人数
dt                  varchar 数据起始日期：2024-01-01

*/

with
args as (select '2026-01-01' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,minicoin_data as (
    select coalesce(
         json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.map_id')
        ,json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.mapid')
        ,json_extract_scalar(args,'$[1].map_id')
    ) as map_id
    ,try_cast(sum(abs(diff)) as bigint) as minicoin
    ,count(distinct uin) as minicoin_payer
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
    group by 1
)
,minibean_data as (
    select map_id
    ,sum(pay_cnt) as minibean
    ,count(distinct uin) as minibean_payer
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt=(select dt from args)
    and event_code='bean_pay'
    group by 1
)
,minipoint_data as (
    select map_id
    ,sum(pay_cnt) as minipoint
    ,count(distinct uin) as minipoint_payer
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt=(select dt from args)
    and event_code='point_pay'
    group by 1
)
select t1.map_id,t1.ctype
,coalesce(minicoin,0)           as minicoin
,coalesce(minicoin_payer,0)     as minicoin_payer
,coalesce(minibean,0)           as minibean
,coalesce(minibean_payer,0)     as minibean_payer
,coalesce(minipoint,0)          as minipoint
,coalesce(minipoint_payer,0)    as minipoint_payer
,(select dt from args) as dt
from map_data t1
left join minicoin_data  t2 on t1.map_id=t2.map_id
left join minibean_data  t3 on t1.map_id=t3.map_id
left join minipoint_data t4 on t1.map_id=t4.map_id
where coalesce(minicoin,minibean,minipoint) is not null --至少一种消费记录
order by 1 desc
;