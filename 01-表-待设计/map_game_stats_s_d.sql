/*
# 表名
map_game_stats_s_d

# 数据起始日期
2024-01-01

# 更新频率
D-1

# 备注
- 好友同玩时长不超过用户的游戏时长

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mn_external_query.r_sdk_70000_game_start
hive.mnv_ads_pbg_cn.user_friend_play_stats_day

# 结果字段（字段名-类型-comment）
map_id          varchar 地图ID
ctype           int     地图类型（1-存档，2-地图）
game_cnt        bigint  游戏次数
game_user       bigint  游戏人数
game_dur        bigint  游戏时长（秒）
frndgame_cnt    bigint  好友同玩次数
frndgame_user   bigint  好友同玩人数
frndgame_dur    bigint  好友同玩时长（秒）
dt              varchar 数据起始日期：2024-01-01

*/
with
args as (select '2024-01-01' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,game_data1 as (
    select cid as map_id,uin,game_session_id
    ,sum(game_period_seconds) as game_dur
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
    group by 1,2,3
)
,frndgame_data as (
    select cid as map_id,uin,game_session_id
    ,sum(friend_session_period_seconds) as frndgame_dur
    from hive.mnv_ads_pbg_cn.user_friend_play_stats_day
    where dt=(select dt from args)
    and friend_session_period_seconds between 0 and 24*60*60
    group by 1,2,3
)
,game_data as (
    select t1.map_id,t1.uin,t1.game_session_id
    ,t1.game_dur
    ,case
        when t2.frndgame_dur is null        then 0
        when t2.frndgame_dur<=t1.game_dur    then t2.frndgame_dur
        else t1.game_dur
    end as frndgame_dur
    from game_data1 t1
    left join frndgame_data t2
    on t1.map_id=t2.map_id and t1.uin=t2.uin and t1.game_session_id=t2.game_session_id
)
select t1.map_id,t2.ctype
,count(game_session_id)                                     as game_cnt
,count(distinct uin)                                        as game_user
,sum(game_dur)                                              as game_dur
,count(distinct if(frndgame_dur>0,game_session_id,null))    as frndgame_cnt
,count(distinct if(frndgame_dur>0,uin,null))                as frndgame_user
,sum(frndgame_dur)                                          as frndgame_dur
,(select dt from args) as dt
from game_data t1
inner join map_data t2 on t1.map_id=t2.map_id
group by 1,2
;