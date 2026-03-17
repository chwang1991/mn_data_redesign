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

-- and map_id not in (select map_id from dim_cn.dim_special_map_a_d where map_tag='ogc')

-- *验收

-- *数据
-- *是否剔除异常账号
-- *是否排除OGC
with
args as (select
     '2026-02-01' as sdt
    ,'2026-02-28' as edt
    ,1 as is_remove_flagged_user
    ,0 as is_remove_ogc_map
)
,removed_map as (
    select map_id
    from dim_cn.dim_special_map_a_d
    where (map_tag='adv')
    or (map_tag='ogc' and 1=(select is_remove_ogc_map from args))
)
,dau as (
    select dt
    ,count(distinct uin) as dau
    from dwd_cn.dwd_real_active_user_detail_i_d
    where dt between (select sdt from args) and (select edt from args)
    and (dt,uin) not in (
        select dt,uin
        from ads_cn.ads_user_flagged_i_d
        where dt between (select sdt from args) and (select edt from args)
        and flag='疑似模拟请求'
        and 1=(select is_remove_flagged_user from args)
    )
    group by 1
)
,game_dur as (
    select dt
    ,sum(game_period_seconds) as game_dur
    from mn_external_query.r_sdk_70000_game_start
    where dt between (select sdt from args) and (select edt from args)
    and (
        (game_start_success_time is not null) -- 加载成功
        and (game_session_period_seconds between 0 and 24*60*60) -- 时长正常
        and (uin>=10000) -- 账号限制
        and (channel not in ('85','86','196','299','991')) -- 渠道限制
        and (regexp_like(coalesce(cid,''),'^\d{10,15}$')) -- 地图ID有效
        and (floor((cast(cid as bigint)-cast(cid as bigint)%pow(2,32))/pow(2,32))<>23282) -- 非家园
    )
    group by 1
)
,iap_minicoin_data as (
    select dt
    ,sum(abs(diff)) as iap_minicoin
    from mnv_ads_account_cn.acc_oplog_minicoin_details_day
    where dt between (select sdt from args) and (select edt from args)
    and diff<0
    and not (
        (why in ('gm.recharge','gm.minicoin_add'))
        or (why='gm.exec' and coalesce(reason,'')='gm_set')
        or (why='gm.exec' and reason in ('gm_error_recovery','gm_supply_minicoin','gm_refund_empty_minicoin','[biz]css_items_remove','[biz]css_items_reissue','gm_supply_minicoin','gm_internal_benefits','gm_test_account','asset_recycle_item'))
    )
    and (
           (reason='kfz_iap_finish') --开发者：商店内购
        or (reason='ministudio_shop') --开发者：studio内购
        or (why='gm.exec' and reason='kfz_skin_buy') --开发者：自定义皮肤
        or (reason='kfz_sub_coin_exchange') --开发者：兑换子币
        or (reason='kfz_unlock_pay_map') --开发者：付费解锁地图（251014）
        or (why like 'shopsvr.dev_item%' or (why='gm.exec' and reason like 'kfz_iap%') or (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) not in (select uin from mnv_ads_config_cn.miniworld_developer_whitelist_uin)))
        or (why='gm.exec' and reason='mall_bag_op_del') --冒险：买星星
        or (why='shopsvr.exchange_star') --冒险：买星星
        or (reason='map_shop_order_paid') --冒险：内购（260122）
        or (reason='building_bag_unlock') --冒险：背包解锁/家具解锁（260122）
        or (reason='resources_buy_goods') --购买资源包
        or (why='gm.exec' and reason like '%unlock_mat%') --购买材质包
    )
    group by 1
)
,ugc_game_data as (
    select dt
    ,count(distinct uin) as ugc_game_user
    ,sum(game_dur) as ugc_game_dur
    from dws_cn.dws_client_game_user_map_stats_i_d
    where dt between (select sdt from args) and (select edt from args)
    and ctype=2
    and map_id not in (select map_id from removed_map)
    group by 1
)
,ugc_minicoin_data as (
    select dt
    ,count(distinct uin) as ugc_minicoin_payer
    ,sum(minicoin) as ugc_minicoin
    from dws_cn.dws_consumption_user_map_stats_i_d
    where dt between (select sdt from args) and (select edt from args)
    and ctype=2
    and minicoin>0
    and map_id not in (select map_id from removed_map)
    group by 1
)
,ugc_ad_data as (
    select dt
    ,sum(ad_times) as ugc_ad_cnt
    ,sum(round(revenue,2)) as ugc_ad_revenue
    from hive.mn_external_query.r_developer_ad_total
    where dt between (select sdt from args) and (select edt from args)
    and map_id not in (0,-1) -- 0=非地图，-1=统计
    and country     = 'all'
    and channel     = -1
    and studio      = -1
    and ad_position = -1
    and itemname    = 'all'
    and map_id in (
        select try_cast(wid as bigint) as map_id
        from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
        where dt=(select edt from args)
        and ctype=2
    )
    and map_id not in (select try_cast(map_id as bigint) from removed_map)
    group by 1
)
select t1.dt
,dau
,ugc_game_user
,ugc_game_user*1.0000/dau as ugc_game_user_rate
,(ugc_game_dur)/3600 as ugc_game_dur_hr
,ugc_game_dur*1.0000/game_dur as ugc_game_dur_rate
,ugc_game_dur/ugc_game_user as ugc_avg_dur
,iap_minicoin/13 as iap_rmb
,ugc_minicoin/13 as ugc_rmb
,ugc_minicoin_payer as ugc_payer
,(ugc_minicoin/13)*1.00/ugc_game_user as ugc_arpu
,ugc_minicoin_payer*1.0000/ugc_game_user as ugc_payrate
,(ugc_minicoin/13)*1.00/ugc_minicoin_payer as ugc_arppu
,round(ugc_ad_revenue) as ugc_ad_revenue
,round(ugc_ad_revenue*1000/ugc_ad_cnt,2) as ugc_ad_ecpm
,ugc_ad_cnt
from dau t1
left join game_dur          t2 on t1.dt=t2.dt
left join iap_minicoin_data t3 on t1.dt=t3.dt
left join ugc_game_data     t4 on t1.dt=t4.dt
left join ugc_minicoin_data t5 on t1.dt=t5.dt
left join ugc_ad_data       t6 on t1.dt=t6.dt
order by 1 desc
;