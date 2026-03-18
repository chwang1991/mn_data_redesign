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
dt                      varchar 数据起始日期：2024-01-01

*/

-- *验收
desc dws_cn.dws_consumption_map_stats_i_d;
select * from dws_cn.dws_consumption_map_stats_i_d
where dt='2026-02-01'
order by 3 desc limit 100
;

with
args as (select '2026-02-01' as dt)
select map_id,ctype
,sum(minicoin)                   as minicoin
,count(if(minicoin>0,uin,null))  as minicoin_payer
,sum(minibean)                   as minibean
,count(if(minibean>0,uin,null))  as minibean_payer
,sum(minipoint)                  as minipoint
,count(if(minipoint>0,uin,null)) as minipoint_payer
,(select dt from args) as dt
from dws_cn.dws_consumption_user_map_stats_i_d
where dt=(select dt from args)
group by 1,2
;