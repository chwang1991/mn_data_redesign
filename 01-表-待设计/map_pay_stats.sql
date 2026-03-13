/*
# 表名
map_pay_stats

# 数据起始日期
2024-01-01

# 更新频率
D-1

# 备注
- hive.mnv_ads_ugc_cn.map_consumption_details_day 这张表上游数据来自mysql，
用于目前开发者收益，对应迷你币消费日志的
and why='gm.exec'
and reason in (
    'ministudio_shop','kfz_iap_finish','kfz_skin_buy' --（包含：道具内购，皮肤）
    ,'kfz_iap_reward','kfz_sub_coin_exchange','kfz_unlock_pay_map'--（不包含：打赏，子币，付费解锁）
)
- 真假币判断自 2022-01-01 起生效

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mnv_ads_ugc_cn.map_consumption_details_day

# 结果字段（字段名-类型-comment）

map_id                  varchar 地图ID
ctype                   int     地图类型（1-存档，2-地图）
minicoin                bigint  迷你币消费数量
minicoin_payer          bigint  迷你币消费人数
minibean                bigint  迷你豆消费数量
minibean_payer          bigint  迷你豆消费人数
minipoint               bigint  迷你点消费数量
minipoint_payer         bigint  迷你点消费人数
minicoin_valid          bigint  迷你币(真)消费数量
minicoin_valid_payer    bigint  迷你币(真)消费人数
minicoin_invalid        bigint  迷你币(假)消费数量
minicoin_invalid_payer  bigint  迷你币(假)消费人数
minibean_valid          bigint  迷你豆(真)消费数量
minibean_valid_payer    bigint  迷你豆(真)消费人数
minibean_invalid        bigint  迷你豆(假)消费数量
minibean_invalid_payer  bigint  迷你豆(假)消费人数
dt                      varchar 数据起始日期：2024-01-01

*/

with
args as (select '2026-01-01' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,currency_data1 as (
    select map_id
    ,sum(if(event_code='coin_pay' ,pay_cnt ,0)) as minicoin
    ,sum(if(event_code='coin_pay' ,user_cnt,0)) as minicoin_payer
    ,sum(if(event_code='bean_pay' ,pay_cnt ,0)) as minibean
    ,sum(if(event_code='bean_pay' ,user_cnt,0)) as minibean_payer
    ,sum(if(event_code='point_pay',pay_cnt ,0)) as minipoint
    ,sum(if(event_code='point_pay',user_cnt,0)) as minipoint_payer
    from (
        select map_id,event_code
        ,sum(pay_cnt) as pay_cnt
        ,count(distinct uin) as user_cnt
        from hive.mnv_ads_ugc_cn.map_consumption_details_day
        where dt=(select dt from args)
        group by 1,2
    )
    group by 1
)
,currency_data2 as (
    select map_id
    ,sum(if(event_code='coin_pay' and valid='1',pay_cnt ,0)) as minicoin_valid
    ,sum(if(event_code='coin_pay' and valid='1',user_cnt,0)) as minicoin_valid_payer
    ,sum(if(event_code='coin_pay' and valid='0',pay_cnt ,0)) as minicoin_invalid
    ,sum(if(event_code='coin_pay' and valid='0',user_cnt,0)) as minicoin_invalid_payer
    ,sum(if(event_code='bean_pay' and valid='1',pay_cnt ,0)) as minibean_valid
    ,sum(if(event_code='bean_pay' and valid='1',user_cnt,0)) as minibean_valid_payer
    ,sum(if(event_code='bean_pay' and valid='0',pay_cnt ,0)) as minibean_invalid
    ,sum(if(event_code='bean_pay' and valid='0',user_cnt,0)) as minibean_invalid_payer
    from (
        select map_id,event_code,valid
        ,sum(pay_cnt) as pay_cnt
        ,count(distinct uin) as user_cnt
        from hive.mnv_ads_ugc_cn.map_consumption_details_day
        where dt=(select dt from args)
        and event_code in ('coin_pay','bean_pay')
        group by 1,2,3
    )
    group by 1
)
,currency_data as (
    select t1.map_id
    ,minicoin,minicoin_payer
    ,minibean,minibean_payer
    ,minipoint,minipoint_payer
    ,minicoin_valid,minicoin_valid_payer
    ,minicoin_invalid,minicoin_invalid_payer
    ,minibean_valid,minibean_valid_payer
    ,minibean_invalid,minibean_invalid_payer
    ,(select dt from args) as dt
    from currency_data1 t1
    left join currency_data2 t2 on t1.map_id=t2.map_id
)
select t1.map_id,t2.ctype
,minicoin,minicoin_payer
,minibean,minibean_payer
,minipoint,minipoint_payer
,minicoin_valid,minicoin_valid_payer
,minicoin_invalid,minicoin_invalid_payer
,minibean_valid,minibean_valid_payer
,minibean_invalid,minibean_invalid_payer
,(select dt from args) as dt
from currency_data t1
inner join map_data t2 on t1.map_id=t2.map_id
;