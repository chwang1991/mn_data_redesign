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
args as (select '2026-02-01' as dt)
select map_id,ctype
,sum(game_cnt)                                  as game_cnt
,count(distinct uin)                            as game_user
,sum(game_dur)                                  as game_dur
,sum(frndgame_cnt)                              as frndgame_cnt
,count(distinct if(frndgame_cnt>0,uin,null))    as frndgame_user
,sum(frndgame_dur)                              as frndgame_dur
,(select dt from args) as dt
from dws_cn.dws_client_game_user_map_stats_i_d
where dt=(select dt from args)
group by 1,2
;