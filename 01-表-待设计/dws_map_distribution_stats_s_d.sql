/*
# 表名
dws_map_distribution_stats_s_d

# 数据起始日期
2026-01-01

# 更新频率
D-1

# 备注

# 依赖
hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
hive.mnv_ads_user_growth_cn.r_sdk_70000_scene_18
hive.mnv_ads_ugc_cn.r_sdk_70000_scene_3
hive.mnv_ads_pbg_cn.r_sdk_70000_scene_1007
hive.mnv_ads_product_cn.r_sdk_70000_scene_54
hive.mnv_ads_analyst_cn.r_sdk_70000_scene_68
hive.mn_external_query.r_sdk_70000_game_start

# 结果字段（字段名-类型-comment）
dt          varchar 数据起始日期：2024-01-01
map_id      varchar 地图ID
expo_place  varchar 曝光位置：联机大厅/推荐、联机大厅/新热榜、联机大厅/精选、联机大厅/分类、联机大厅/studio专区、沙盒工坊、沙盒联机、搜索、排行榜
expo_cnt    bigint  曝光次数
game_cnt    bigint  游戏次数
ctr         double  点击率（游戏次数/曝光次数）

*/
with
args as (select '2025-12-20' as dt)
,map_data as (
    select wid as map_id,ctype
    from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
    where dt=(select dt from args)
)
,expo_data_lobby as (
    select map_id
	,case
        when regexp_like(card_id,'FRONT_PAGE')          then '联机大厅/推荐'
		when regexp_like(card_id,'HOTTEST_BOARD')       then '联机大厅/新热榜'
		when regexp_like(card_id,'_REC|OFFICIAL_MAP')   then '联机大厅/精选'
		when regexp_like(card_id,'_CONTENT')            then '联机大厅/分类'
        when regexp_like(card_id,'STUDIO_CONTAINER')    then '联机大厅/studio专区'
	end as expo_place
    ,count(1) as expo_cnt
    from (
	    select cid,card_id
	    from hive.mnv_ads_user_growth_cn.r_sdk_70000_scene_18
	    where dt=(select dt from args)
	    and regexp_like(card_id,'FRONT_PAGE|HOTTEST_BOARD|_REC|OFFICIAL_MAP|_CONTENT|STUDIO_CONTAINER')
	    and regexp_like(comp_id,'Card')
	    and event_code='view'
	    and cid is not null
    )
    cross join unnest(regexp_extract_all(cid,'\d+')) as t(map_id)
    group by 1,2
)
,expo_data_workshop as (
    select map_id,'沙盒工坊' as expo_place,count(1) as expo_cnt
    from (
	    select cid
	    from hive.mnv_ads_ugc_cn.r_sdk_70000_scene_3
	    where dt=(select dt from args)
	    and regexp_like(comp_id,'Card')
	    and event_code='view'
	    and cid is not null
    )
    cross join unnest(regexp_extract_all(cid,'\d+')) as t(map_id)
    group by 1
)
,expo_data_sandboxroom as (
    select map_id,'沙盒联机' as expo_place,count(1) as expo_cnt
    from (
	    select cid
	    from hive.mnv_ads_pbg_cn.r_sdk_70000_scene_1007
	    where dt=(select dt from args)
        and regexp_like(card_id,'CARD')
        and comp_id='-'
        and event_code='view'
	    and cid is not null
    )
    cross join unnest(regexp_extract_all(cid,'\d+')) as t(map_id)
    group by 1
)
,expo_data_search as (
	select cid as map_id,'搜索' as expo_place,count(1) as expo_cnt
    from hive.mnv_ads_product_cn.r_sdk_70000_scene_54
    where dt=(select dt from args)
    and regexp_like(comp_id,'Card')
    and event_code='view'
    group by 1
)
,expo_data_rankingboard as (
    select cid as map_id,'排行榜' as expo_place,count(1) as expo_cnt
    from (
	    select cid
	    from hive.mnv_ads_analyst_cn.r_sdk_70000_scene_68
	    where dt=(select dt from args)
	    and regexp_like(card_id,'CARD2')
        and comp_id='-'
        and event_code='view'
	    and cid is not null
    )
    cross join unnest(regexp_extract_all(cid,'\d+')) as t(map_id)
    group by 1
)
,expo_data as (
    select * from (
        select * from expo_data_lobby
        union all
        select * from expo_data_workshop
        union all
        select * from expo_data_sandboxroom
        union all
        select * from expo_data_search
        union all
        select * from expo_data_rankingboard
    )
    where expo_cnt>=1000
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
select t1.map_id,t2.ctype,t1.expo_place
,expo_cnt,game_cnt
,game_cnt*1.000000/expo_cnt as ctr
,(select dt from args) as dt
from expo_data t1
inner join map_data t2 on t1.map_id=t2.map_id
left join game_data t3 on t1.map_id=t3.map_id and t1.expo_place=t3.startfrom
;

