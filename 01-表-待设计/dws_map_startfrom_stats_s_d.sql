/*
# 表名
dws_map_startfrom_stats_s_d

# 数据起始日期
2024-01-01

# 更新频率
D-1

# 备注

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mn_external_query.r_sdk_70000_game_start

# 结果字段（字段名-类型-comment）
dt          varchar 数据起始日期：2024-01-01
map_id      varchar 地图ID
startfrom   varchar 游戏启动位置：好友跟邀/新手引导/组队/搜索/活动/排行榜/聊天频道/联机大厅/开始游戏/沙盒工坊/沙盒联机/其他
game_cnt    bigint  游戏次数
game_user   bigint  游戏人数
game_dur    bigint  游戏时长（秒）

*/
with
args as (select '2025-12-20' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,game_data as (
    select cid as map_id
    ,case
        when regexp_like(trace_id,'friend#(accept|follow)')         or scene_id in ('31','2801')    then '好友跟邀'
        when regexp_like(trace_id,'NewplayerGuide')                 or scene_id in ('3902')         then '新手引导'
        when regexp_like(trace_id,'team')                           or scene_id in ('1005')         then '组队'
        when regexp_like(trace_id,'search')                         or scene_id in ('54')           then '搜索'
        when regexp_like(trace_id,'activity')                       or scene_id in ('98')           then '活动'
        when regexp_like(trace_id,'RankingList')                                                    then '排行榜'
        when regexp_like(trace_id,'social')                         or scene_id in ('67')           then '聊天频道'
        when regexp_like(trace_id,'FRONT_PAGE_FEED')                or card_id='FRONT_PAGE_FEED'    then '联机大厅/推荐'
        when regexp_like(trace_id,'RANKING_BOARD_CONTAINER')                                        then '联机大厅/新热榜'
        when regexp_like(trace_id,'RECOMMENDATION')                                                 then '联机大厅/精选'
        when regexp_like(trace_id,'LABEL_CONTAINER')                                                then '联机大厅/分类'
        when regexp_like(trace_id,'STUDIO_CONTAINER')                                               then '联机大厅/studio专区'
        when regexp_like(trace_id,'lobby|FRONT_PAGE')               or scene_id in ('18')           then '联机大厅/其他'
        when regexp_like(trace_id,'startgame|STOREHOUSE|gamestart') or scene_id in ('402')          then '开始游戏'
        when regexp_like(trace_id,'workshop|MAP')                   or scene_id in ('3')            then '沙盒工坊'
        when regexp_like(trace_id,'sandbox')                        or scene_id in ('1007')         then '沙盒联机'
        else '其他'
    end as startfrom
    ,count(*) as game_cnt
    ,count(distinct uin) as game_user
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
    group by 1,2
)
select t1.map_id,t2.ctype
,startfrom
,game_cnt,game_user,game_dur
,(select dt from args) as dt
from game_data t1
inner join map_data t2 on t1.map_id=t2.map_id
;