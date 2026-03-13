/*
# 表名
dws_map_ad_stats_s_d

# 数据起始日期
2024-01-01

# 更新频率
D-1/3/7/14

# 备注
- 广告数据依赖SDK回传，存在延迟更新，需要之后再次更新

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mn_external_query.r_developer_ad_total

# 结果字段（字段名-类型-comment）
map_id      varchar 地图ID
ctype       int     地图类型（1-存档，2-地图）
ad_revenue  double  广告收入（元）
ad_cnt      bigint  广告次数
ad_user     bigint  广告人数
ad_ecpm     double  广告eCPM（元）
dt          varchar 数据起始日期：2024-01-01

*/

with
args as (select '2025-12-20' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,ad_data as (
    select try_cast(map_id as varchar) as map_id
    ,sum(ad_players) as ad_user
    ,sum(ad_times) as ad_cnt
    ,sum(round(revenue,2)) as ad_revenue
    from hive.mn_external_query.r_developer_ad_total
    where dt=(select dt from args)
    and (
        map_id not in (0,-1) --0=非地图，-1=统计
        and country='all'
        and channel=-1
        and studio=-1
        and ad_position=-1
        and itemname='all'
    )
    group by 1
)
select t1.map_id,t2.ctype
,ad_revenue
,ad_cnt
,ad_user
,round(ad_revenue*1000/ad_cnt,2) as ad_ecpm
,(select dt from args) as dt
from ad_data t1
inner join map_data t2 on t1.map_id=t2.map_id
order by 1
;