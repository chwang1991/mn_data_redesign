/*
# 表名

# 数据起始日期
2024-01-01

# 更新频率
D-1/2/7

# 备注
UGC包含studio
新手引导算作冒险？

# 依赖
mnv_ads_ugc_cn.map_sign_algorithm_stats_day
dim_cn.dim_special_map_a_d
mn_external_query.r_sdk_70000_game_start
mnv_ads_pbg_cn.user_friend_play_stats_day

# 结果字段（字段名-类型-comment）
uin                 bigint  UIN
game_cnt            bigint  游戏次数
game_dur            bigint  游戏时长（秒）
frndgame_cnt        bigint  好友同玩次数
frndgame_dur        bigint  好友同玩时长
game_is_d2r         int     次日复玩，0/1
game_is_d7r         int     7日复玩，0/1
adv_game_cnt        bigint  冒险-游戏次数（不含新手引导）
adv_game_dur        bigint  冒险-游戏时长
adv_frndgame_cnt    bigint  冒险-好友同玩次数
adv_frndgame_dur    bigint  冒险-好友同玩时长
adv_is_d2r          int     冒险-次日复玩，0/1
adv_is_d7r          int     冒险-7日复玩，0/1
cre_game_cnt        bigint  创造-游戏次数
cre_game_dur        bigint  创造-游戏时长
cre_frndgame_cnt    bigint  创造-好友同玩次数
cre_frndgame_dur    bigint  创造-好友同玩时长
cre_is_d2r          int     创造-次日复玩，0/1
cre_is_d7r          int     创造-7日复玩，0/1
ugc_game_cnt        bigint  UGC-游戏次数
ugc_game_dur        bigint  UGC-游戏时长
ugc_frndgame_cnt    bigint  UGC-好友同玩次数
ugc_frndgame_dur    bigint  UGC-好友同玩时长
ugc_is_d2r          int     UGC-次日复玩，0/1
ugc_is_d7r          int     UGC-7日复玩，0/1
ogc_game_cnt        bigint  OGC-游戏次数
ogc_game_dur        bigint  OGC-游戏时长
ogc_frndgame_cnt    bigint  OGC-好友同玩次数
ogc_frndgame_dur    bigint  OGC-好友同玩时长
ogc_is_d2r          int     OGC-次日复玩，0/1
ogc_is_d7r          int     OGC-7日复玩，0/1
other_game_cnt      bigint  其他-游戏次数
other_game_dur      bigint  其他-游戏时长
other_frndgame_cnt  bigint  其他-好友同玩次数
other_frndgame_dur  bigint  其他-好友同玩时长
other_is_d2r        int     其他-次日复玩，0/1
other_is_d7r        int     其他-7日复玩，0/1
dt                  varchar 数据起始日期：2024-01-01

*/


-- *数据
with
args as (select '2026-02-01' as dt)
,map_data as (
    select t1.map_id
    ,case
        when t2.map_tag='adv' then 'adv'
        when t2.map_tag='ogc' then 'ogc'
        else 'ugc'
    end as map_type
    from (
        select wid as map_id,is_studio
        from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
        where dt=(select dt from args)
        and ctype=2
    ) t1
    left join dim_cn.dim_special_map_a_d t2 on t1.map_id=t2.map_id
)
,game_data0 as (
    select t1.uin
    ,case
        when t1.map_mode in (0,2,3,6) then 'adv'
        when t3.map_type='adv'        then 'adv'
        when t1.map_mode in (1)       then 'cre'
        when t3.map_type='ogc'        then 'ogc'
        when t3.map_type='ugc'        then 'ugc'
        else 'oth'
    end as game_type
    ,count(*) as game_cnt
    ,sum(game_dur) as game_dur
    ,count(if(t2.frndgame_dur is not null,1,null)) as frndgame_cnt
    ,sum(case
        when t2.frndgame_dur is null      then 0
        when t2.frndgame_dur<=t1.game_dur then t2.frndgame_dur
        else t1.game_dur
    end) as frndgame_dur
    from (
        select uin,cid as map_id,game_session_id,map_mode
        ,sum(game_session_period_seconds) as game_dur
        from hive.mn_external_query.r_sdk_70000_game_start
        where dt=(select dt from args)
        and (
            (game_start_success_time is not null) -- 加载成功
            and (game_session_period_seconds between 0 and 24*60*60) -- 时长正常
            and (uin>=10000) -- 账号限制
            and (channel not in ('85','86','196','299','991')) -- 渠道限制
            and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) -- 地图ID有效
            and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) -- 非家园
        )
        group by 1,2,3,4
    ) t1
    left join (
        select uin,cid as map_id,game_session_id
        ,sum(friend_session_period_seconds) as frndgame_dur
        from hive.mnv_ads_pbg_cn.user_friend_play_stats_day
        where dt=(select dt from args)
        and friend_session_period_seconds between 0 and 24*3600
        group by 1,2,3
    ) t2
    on t1.uin=t2.uin and t1.map_id=t2.map_id and t1.game_session_id=t2.game_session_id
    left join map_data t3
    on t1.map_id=t3.map_id
    group by 1,2
)
,d2_game_data as (
    select t1.uin
    ,case
        when t1.map_mode in (0,2,3,6) then 'adv'
        when t2.map_type='adv'        then 'adv'
        when t1.map_mode in (1)       then 'cre'
        when t2.map_type='ogc'        then 'ogc'
        when t2.map_type='ugc'        then 'ugc'
        else 'oth'
    end as game_type
    from (
        select uin,cid as map_id,map_mode
        from hive.mn_external_query.r_sdk_70000_game_start
        where dt=(select cast(date(dt)+interval'1'day as varchar) from args)
        and (
            (game_start_success_time is not null) -- 加载成功
            and (game_session_period_seconds between 0 and 24*60*60) -- 时长正常
            and (uin>=10000) -- 账号限制
            and (channel not in ('85','86','196','299','991')) -- 渠道限制
            and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) -- 地图ID有效
            and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) -- 非家园
        )
    ) t1
    left join map_data t2 on t1.map_id=t2.map_id
    group by 1,2
)
,d7_game_data as (
    select t1.uin
    ,case
        when t1.map_mode in (0,2,3,6) then 'adv'
        when t2.map_type='adv'        then 'adv'
        when t1.map_mode in (1)       then 'cre'
        when t2.map_type='ogc'        then 'ogc'
        when t2.map_type='ugc'        then 'ugc'
        else 'oth'
    end as game_type
    from (
        select uin,cid as map_id,map_mode
        from hive.mn_external_query.r_sdk_70000_game_start
        where dt=(select cast(date(dt)+interval'6'day as varchar) from args)
        and (
            (game_start_success_time is not null) -- 加载成功
            and (game_session_period_seconds between 0 and 24*60*60) -- 时长正常
            and (uin>=10000) -- 账号限制
            and (channel not in ('85','86','196','299','991')) -- 渠道限制
            and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) -- 地图ID有效
            and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) -- 非家园
        )
    ) t1
    left join map_data t2 on t1.map_id=t2.map_id
    group by 1,2
)
,game_data as (
    select t1.uin,t1.game_type
    ,t1.game_cnt
    ,t1.game_dur
    ,t1.frndgame_cnt
    ,t1.frndgame_dur
    ,if(t2.uin is not null,1,0) as is_d2r
    ,if(t3.uin is not null,1,0) as is_d7r
    from game_data0 t1
    left join d2_game_data t2 on t1.uin=t2.uin and t1.game_type=t2.game_type
    left join d7_game_data t3 on t1.uin=t3.uin and t1.game_type=t3.game_type
)
select uin
,sum(game_cnt) as game_cnt
,sum(game_dur) as game_dur
,sum(frndgame_cnt) as frndgame_cnt
,sum(frndgame_dur) as frndgame_dur
,max(is_d2r)   as game_is_d2r
,max(is_d7r)   as game_is_d7r
,max(if(game_type='adv',game_cnt,0))    as adv_game_cnt
,max(if(game_type='adv',game_dur,0))    as adv_game_dur
,max(if(game_type='adv',frndgame_cnt,0))as adv_frndgame_cnt
,max(if(game_type='adv',frndgame_dur,0))as adv_frndgame_dur
,max(if(game_type='adv',is_d2r,0))      as adv_is_d2r
,max(if(game_type='adv',is_d7r,0))      as adv_is_d7r
,max(if(game_type='cre',game_cnt,0))    as cre_game_cnt
,max(if(game_type='cre',game_dur,0))    as cre_game_dur
,max(if(game_type='cre',frndgame_cnt,0))as cre_frndgame_cnt
,max(if(game_type='cre',frndgame_dur,0))as cre_frndgame_dur
,max(if(game_type='cre',is_d2r,0))      as cre_is_d2r
,max(if(game_type='cre',is_d7r,0))      as cre_is_d7r
,max(if(game_type='ugc',game_cnt,0))    as ugc_game_cnt
,max(if(game_type='ugc',game_dur,0))    as ugc_game_dur
,max(if(game_type='ugc',frndgame_cnt,0))as ugc_frndgame_cnt
,max(if(game_type='ugc',frndgame_dur,0))as ugc_frndgame_dur
,max(if(game_type='ugc',is_d2r,0))      as ugc_is_d2r
,max(if(game_type='ugc',is_d7r,0))      as ugc_is_d7r
,max(if(game_type='ogc',game_cnt,0))    as ogc_game_cnt
,max(if(game_type='ogc',game_dur,0))    as ogc_game_dur
,max(if(game_type='ogc',frndgame_cnt,0))as ogc_frndgame_cnt
,max(if(game_type='ogc',frndgame_dur,0))as ogc_frndgame_dur
,max(if(game_type='ogc',is_d2r,0))      as ogc_is_d2r
,max(if(game_type='ogc',is_d7r,0))      as ogc_is_d7r
,max(if(game_type='oth',game_cnt,0))    as other_game_cnt
,max(if(game_type='oth',game_dur,0))    as other_game_dur
,max(if(game_type='oth',frndgame_cnt,0))as other_frndgame_cnt
,max(if(game_type='oth',frndgame_dur,0))as other_frndgame_dur
,max(if(game_type='oth',is_d2r,0))      as other_is_d2r
,max(if(game_type='oth',is_d7r,0))      as other_is_d7r
,(select dt from args) as dt
from game_data
group by 1
;