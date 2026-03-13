/*
# 表名
map_ret_lt_ltv

# 数据起始日期
2024-01-01

# 更新频率
D-2/3/7/14/30

# 备注
- 仅包含游戏人数>=100的地图（人数太少时统计指标失真）
- 每日的数据需要多次更新
- 全部用户和30日新用户分两次更新

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mn_external_query.r_sdk_70000_game_start
hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day

# 结果字段（字段名-类型-comment）
user_type       varchar 用户类型：全部用户/30日新用户
map_id          varchar 地图ID
ctype           int     地图类型（1-存档，2-地图）
game_user       bigint  游戏人数
d2r             double  次日复玩率
d3r             double  3日复玩率
d7r             double  7日复玩率
lt7             double  LT7
lt14            double  LT14
lt30            double  LT30
ltv7_minicoin   double  LTV7（迷你币）
ltv14_minicoin  double  LTV14（迷你币）
ltv30_minicoin  double  LTV30（迷你币）
dt              varchar 数据起始日期：2024-01-01

*/


-- *全部用户
with
args as (select '2025-12-20' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,map_user_data0 as (
    select cid as map_id
    from hive.mn_external_query.r_sdk_70000_game_start
    where dt=(select dt from args)
    and (
        (game_start_success_time is not null) --加载成功
        and (game_session_period_seconds between 0 and 24*60*60) --时长正常
        and (uin>=10000) --排除官方账号
        and (channel not in ('85','86','196','299','991')) --渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) --地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) --排除家园
    )
    group by 1
    having count(distinct uin)>=100
)
,map_user_data as (
    select distinct cid as map_id,uin
    from hive.mn_external_query.r_sdk_70000_game_start
    where dt=(select dt from args)
    and (
        (game_start_success_time is not null) --加载成功
        and (game_session_period_seconds between 0 and 24*60*60) --时长正常
        and (uin>=10000) --排除官方账号
        and (channel not in ('85','86','196','299','991')) --渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) --地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) --排除家园
    )
    and cid in (select map_id from map_user_data0)
)
,game_data as (
    select distinct dt,cid as map_id,uin
    from hive.mn_external_query.r_sdk_70000_game_start
    where dt between (select dt from args)
                 and (select cast(date(dt)+interval'29'day as varchar) from args)
    and (
        (game_start_success_time is not null) --加载成功
        and (game_session_period_seconds between 0 and 24*60*60) --时长正常
        and (uin>=10000) --排除官方账号
        and (channel not in ('85','86','196','299','991')) --渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) --地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) --排除家园
    )
    and (cid,uin) in (select map_id,uin from map_user_data)
)
,minicoin_data as (
    select dt,map_id
    ,sum(pay_cnt) as minicoin
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt between (select dt from args)
                 and (select cast(date(dt)+interval'29'day as varchar) from args)
    and (map_id,try_cast(uin as bigint)) in (select map_id,uin from map_user_data)
    group by 1,2
)
,ret_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))=1,1,0))    as d2r_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))=2,1,0))    as d3r_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))=6,1,0))    as d7r_cnt
    from game_data
    group by 1
)
,lt_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))<=6,1,0))   as lt7_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))<=13,1,0))  as lt14_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))<=29,1,0))  as lt30_cnt
    from game_data
    group by 1
)
,ltv_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))<=6,minicoin,0))   as ltv7_minicoin
    ,sum(if(day(date(dt)-(select date(dt) from args))<=13,minicoin,0))  as ltv14_minicoin
    ,sum(if(day(date(dt)-(select date(dt) from args))<=29,minicoin,0))  as ltv30_minicoin
    from minicoin_data
    group by 1
)
select 'all' as user_type,t1.map_id,t2.ctype
,game_user
,try(d2r_cnt*1.0000/game_user)      as d2r
,try(d3r_cnt*1.0000/game_user)      as d3r
,try(d7r_cnt*1.0000/game_user)      as d7r
,try(lt7_cnt*1.0000/game_user)      as lt7
,try(lt14_cnt*1.0000/game_user)     as lt14
,try(lt30_cnt*1.0000/game_user)     as lt30
,try(ltv7_minicoin*1.00/game_user)  as ltv7_minicoin
,try(ltv14_minicoin*1.00/game_user) as ltv14_minicoin
,try(ltv30_minicoin*1.00/game_user) as ltv30_minicoin
,(select dt from args) as dt
from (select map_id,count(*) as game_user from map_user_data group by 1) t1
inner join map_data t2 on t1.map_id=t2.map_id
left join ret_data t3 on t1.map_id=t3.map_id
left join lt_data  t4 on t1.map_id=t4.map_id
left join ltv_data t5 on t1.map_id=t5.map_id
;

-- 30日新用户
with
args as (select '2025-12-20' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,map_user_data0 as (
    select cid as map_id,uin
    from hive.mn_external_query.r_sdk_70000_game_start
    where dt between (select cast(date(dt)-interval'30'day as varchar) from args)
    			 and (select dt from args)
    and (
        (game_start_success_time is not null) --加载成功
        and (game_session_period_seconds between 0 and 24*60*60) --时长正常
        and (uin>=10000) --排除官方账号
        and (channel not in ('85','86','196','299','991')) --渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) --地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) --排除家园
    )
    group by 1,2
    having min(dt)=(select dt from args)
)
,map_user_data as (
    select map_id,uin
    from map_user_data0
    where map_id in (
		select map_id
		from map_user_data0
		group by 1
		having count(*)>=100
	)
)
,game_data as (
    select distinct dt,cid as map_id,uin
    from hive.mn_external_query.r_sdk_70000_game_start
    where dt between (select dt from args)
                 and (select cast(date(dt)+interval'29'day as varchar) from args)
    and (
        (game_start_success_time is not null) --加载成功
        and (game_session_period_seconds between 0 and 24*60*60) --时长正常
        and (uin>=10000) --排除官方账号
        and (channel not in ('85','86','196','299','991')) --渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) --地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) --排除家园
    )
    and (cid,uin) in (select map_id,uin from map_user_data)
)
,minicoin_data as (
    select dt,map_id
    ,sum(pay_cnt) as minicoin
    from hive.mnv_ads_ugc_cn.map_consumption_details_day
    where dt between (select dt from args)
                 and (select cast(date(dt)+interval'29'day as varchar) from args)
    and (map_id,try_cast(uin as bigint)) in (select map_id,uin from map_user_data)
    group by 1,2
)
,ret_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))=1,1,0))    as d2r_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))=2,1,0))    as d3r_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))=6,1,0))    as d7r_cnt
    from game_data
    group by 1
)
,lt_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))<=6,1,0))   as lt7_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))<=13,1,0))  as lt14_cnt
    ,sum(if(day(date(dt)-(select date(dt) from args))<=29,1,0))  as lt30_cnt
    from game_data
    group by 1
)
,ltv_data as (
    select map_id
    ,sum(if(day(date(dt)-(select date(dt) from args))<=6,minicoin,0))   as ltv7_minicoin
    ,sum(if(day(date(dt)-(select date(dt) from args))<=13,minicoin,0))  as ltv14_minicoin
    ,sum(if(day(date(dt)-(select date(dt) from args))<=29,minicoin,0))  as ltv30_minicoin
    from minicoin_data
    group by 1
)
select '30日新用户' as user_type,t1.map_id,t2.ctype
,game_user
,try(d2r_cnt*1.0000/game_user)      as d2r
,try(d3r_cnt*1.0000/game_user)      as d3r
,try(d7r_cnt*1.0000/game_user)      as d7r
,try(lt7_cnt*1.0000/game_user)      as lt7
,try(lt14_cnt*1.0000/game_user)     as lt14
,try(lt30_cnt*1.0000/game_user)     as lt30
,try(ltv7_minicoin*1.00/game_user)  as ltv7_minicoin
,try(ltv14_minicoin*1.00/game_user) as ltv14_minicoin
,try(ltv30_minicoin*1.00/game_user) as ltv30_minicoin
,(select dt from args) as dt
from (select map_id,count(*) as game_user from map_user_data group by 1) t1
inner join map_data t2 on t1.map_id=t2.map_id
left join ret_data t3 on t1.map_id=t3.map_id
left join lt_data  t4 on t1.map_id=t4.map_id
left join ltv_data t5 on t1.map_id=t5.map_id
;

-- 测试
select *
from mnv_temp_cn.ads_map_newuser_lt_ltv_s_d
where dt='2025-12-20'
and map_id=''
;