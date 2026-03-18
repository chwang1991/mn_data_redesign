/*
# 表名


# 数据起始日期
2024-01-01

# 更新频率
D-2/3/7/14/30

# 备注

# 依赖

# 结果字段（字段名-类型-comment）
is_remove_flagged_user  int             是否排除异常用户
dau                     bigint          DAU
d2r                     decimal(38,4)   次日留存
d7r                     decimal(38,4)   7日留存
game_dur                bigint          游戏时长（秒）
pay_revenue             decimal(38,2)   充值收入（含直播，VIP）
ad_revenue              decimal(38,2)   广告收入
mianliu_revenue         decimal(38,2)   免流收入
payer                   bigint          充值人数
arpu                    decimal(38,4)   ARPU
payrate                 decimal(38,4)   付费率
arppu                   decimal(38,4)   ARPPU
new_user                bigint          新增-人数
new_d2r                 decimal(38,4)   新增-次日留存
new_d7r                 decimal(38,4)   新增-7日留存
new_game_dur            bigint          新增-游戏时长（秒）
new_pay_revenue         decimal(38,2)   新增-充值收入
new_payer               bigint          新增-充值人数
rtn_user                bigint          回流-人数
rtn_d2r                 decimal(38,4)   回流-次日留存
rtn_d7r                 decimal(38,4)   回流-7日留存
rtn_game_dur            bigint          回流-游戏时长（秒）
rtn_pay_revenue         decimal(38,2)   回流-充值收入
rtn_payer               bigint          回流-充值人数
act_user                bigint          活跃-人数
act_d2r                 decimal(38,4)   活跃-次日留存
act_d7r                 decimal(38,4)   活跃-7日留存
act_game_dur            bigint          活跃-游戏时长（秒）
act_pay_revenue         decimal(38,2)   活跃-充值收入
act_payer               bigint          活跃-充值人数
adv_user                bigint          冒险-人数
adv_d2r                 decimal(38,4)   冒险-次日复玩
adv_d7r                 decimal(38,4)   冒险-7日复玩
adv_game_dur            bigint          冒险-游戏时长（秒）
adv_minicoin_revenue    decimal(38,2)   冒险-消费收入
adv_ad_revenue          decimal(38,2)   冒险-广告收入
adv_payer               bigint          冒险-消费人数
map_user                bigint          地图-人数
map_d2r                 decimal(38,4)   地图-次日复玩
map_d7r                 decimal(38,4)   地图-7日复玩
map_game_dur            bigint          地图-游戏时长（秒）
map_minicoin_revenue    decimal(38,2)   地图-消费收入
map_ad_revenue          decimal(38,2)   地图-广告收入
map_payer               bigint          地图-消费人数
dt                      varchar         数据起始日期：2024-01-01

*/

-- *验收

desc hive.mnv_temp_cn.dws_user_login_stat_s_d;
desc hive.mnv_temp_cn.dws_user_game_stat_s_d;
desc hive.mnv_temp_cn.dws_user_pay_stat_s_d;
desc hive.mnv_temp_cn.dws_user_consume_minicoin_stat_s_d;
desc hive.mnv_temp_cn.dws_map_game_stat_s_d;

-- *建表
create table
hive.mnv_temp_cn.ads_core_stat_s_d
(
    -- *登录与留存
     dau                        bigint          comment 'DAU'
    ,d2r_user                   bigint          comment 'D2留存用户数'
    ,d7r_user                   bigint          comment 'D7留存用户数'
    -- *游戏行为
    ,game_user                  bigint          comment '游戏用户数'
    ,game_dur                   bigint          comment '游戏时长'
    ,game_d2r_user              bigint          comment '游戏D2留存用户数'
    ,game_d7r_user              bigint          comment '游戏D7留存用户数'
    ,adv_game_user              bigint          comment '冒险游戏用户数'
    ,adv_game_dur               bigint          comment '冒险游戏时长'
    ,adv_game_d2r_user          bigint          comment '冒险游戏D2留存用户数'
    ,adv_game_d7r_user          bigint          comment '冒险游戏D7留存用户数'
    ,cre_game_user              bigint          comment '创造游戏用户数'
    ,cre_game_dur               bigint          comment '创造游戏时长'
    ,cre_game_d2r_user          bigint          comment '创造游戏D2留存用户数'
    ,cre_game_d7r_user          bigint          comment '创造游戏D7留存用户数'
    ,map_game_user              bigint          comment '地图游戏用户数'
    ,map_game_dur               bigint          comment '地图游戏时长'
    ,map_game_d2r_user          bigint          comment '地图游戏D2留存用户数'
    ,map_game_d7r_user          bigint          comment '地图游戏D7留存用户数'
    ,ugc_game_user              bigint          comment 'UGC游戏用户数'
    ,ugc_game_dur               bigint          comment 'UGC游戏时长'
    ,ugc_game_d2r_user          bigint          comment 'UGC游戏D2留存用户数'
    ,ugc_game_d7r_user          bigint          comment 'UGC游戏D7留存用户数'
    ,ogc_game_user              bigint          comment 'OGC游戏用户数'
    ,ogc_game_dur               bigint          comment 'OGC游戏时长'
    ,ogc_game_d2r_user          bigint          comment 'OGC游戏D2留存用户数'
    ,ogc_game_d7r_user          bigint          comment 'OGC游戏D7留存用户数'
    ,studio_game_user           bigint          comment 'studio游戏用户数'
    ,studio_game_dur            bigint          comment 'studio游戏时长'
    ,studio_game_d2r_user       bigint          comment 'studio游戏D2留存用户数'
    ,studio_game_d7r_user       bigint          comment 'studio游戏D7留存用户数'
    -- *收入
    ,revenue                    decimal(38,2)   comment '收入金额'
    -- *充值
    ,pay_total                  decimal(38,2)   comment '充值金额'
    ,pay_user                   bigint          comment '充值用户数'
    ,pay_minicoin               decimal(38,2)   comment '充值-迷你币 金额'
    ,pay_minicoin_user          bigint          comment '充值-迷你币 用户数'
    ,pay_activity               decimal(38,2)   comment '充值-活动 金额'
    ,pay_activity_user          bigint          comment '充值-活动 用户数'
    ,pay_minivip                decimal(38,2)   comment '充值-大会员 金额'
    ,pay_minivip_user           bigint          comment '充值-大会员 用户数'
    ,pay_other                  decimal(38,2)   comment '充值-其他 金额'
    ,pay_other_user             bigint          comment '充值-其他 用户数'
    -- *免流
    ,mianliu_rvn                decimal(38,2)   comment '免流收入金额'
    -- *广告
    ,ad_rvn                     decimal(38,2)   comment '广告收入金额'
    ,ad_cnt                     bigint          comment '广告展示次数'
    ,ad_adv_rvn                 decimal(38,2)   comment '广告-冒险 收入金额'
    ,ad_adv_cnt                 bigint          comment '广告-冒险 展示次数'
    ,ad_ptf_rvn                 decimal(38,2)   comment '广告-平台 收入金额'
    ,ad_ptf_cnt                 bigint          comment '广告-平台 展示次数'
    ,ad_dev_rvn                 decimal(38,2)   comment '广告-开发者 收入金额'
    ,ad_dev_cnt                 bigint          comment '广告-开发者 展示次数'
    ,ad_ugc_rvn                 decimal(38,2)   comment '广告-UGC 收入金额'
    ,ad_ugc_cnt                 bigint          comment '广告-UGC 展示次数'
    ,ad_ogc_rvn                 decimal(38,2)   comment '广告-OGC 收入金额'
    ,ad_ogc_cnt                 bigint          comment '广告-OGC 展示次数'
    ,ad_studio_rvn              decimal(38,2)   comment '广告-studio 收入金额'
    ,ad_studio_cnt              bigint          comment '广告-studio 展示次数'
    -- *消费
    ,cons_total                 decimal(38,2)   comment '消费迷你币 数量'
    ,cons_user                  bigint          comment '消费迷你币 用户数'
    ,cons_ingame                decimal(38,2)   comment '消费迷你币-地图内购 数量'
    ,cons_ingame_user           bigint          comment '消费迷你币-地图内购 用户数'
    ,cons_gacha                 decimal(38,2)   comment '消费迷你币-常驻抽奖 数量'
    ,cons_gacha_user            bigint          comment '消费迷你币-常驻抽奖 用户数'
    ,cons_dirbuy                decimal(38,2)   comment '消费迷你币-直购 数量'
    ,cons_dirbuy_user           bigint          comment '消费迷你币-直购 用户数'
    ,cons_activity              decimal(38,2)   comment '消费迷你币-活动与礼包 数量'
    ,cons_activity_user         bigint          comment '消费迷你币-活动与礼包 用户数'
    ,cons_social                decimal(38,2)   comment '消费迷你币-社交 数量'
    ,cons_social_user           bigint          comment '消费迷你币-社交 用户数'
    ,cons_minibean              decimal(38,2)   comment '消费迷你币-兑换迷你豆 数量'
    ,cons_minibean_user         bigint          comment '消费迷你币-兑换迷你豆 用户数'
    ,cons_other                 decimal(38,2)   comment '消费迷你币-其他 数量'
    ,cons_other_user            bigint          comment '消费迷你币-其他 用户数'
    ,cons_ingame_adv            decimal(38,2)   comment '消费迷你币-地图内购-冒险 数量'
    ,cons_ingame_adv_user       bigint          comment '消费迷你币-地图内购-冒险 用户数'
    ,cons_ingame_map            decimal(38,2)   comment '消费迷你币-地图内购-地图 数量'
    ,cons_ingame_map_user       bigint          comment '消费迷你币-地图内购-地图 用户数'
    ,cons_ingame_ugc            decimal(38,2)   comment '消费迷你币-地图内购-UGC 数量'
    ,cons_ingame_ugc_user       bigint          comment '消费迷你币-地图内购-UGC 用户数'
    ,cons_ingame_ogc            decimal(38,2)   comment '消费迷你币-地图内购-OGC 数量'
    ,cons_ingame_ogc_user       bigint          comment '消费迷你币-地图内购-OGC 用户数'
    ,cons_ingame_studio         decimal(38,2)   comment '消费迷你币-地图内购-studio 数量'
    ,cons_ingame_studio_user    bigint          comment '消费迷你币-地图内购-studio 用户数'
    ,cons_ingame_other          decimal(38,2)   comment '消费迷你币-地图内购-其他 数量'
    ,cons_ingame_other_user     bigint          comment '消费迷你币-地图内购-其他 用户数'
    -- *新增
    ,new_dau                    bigint          comment '新增-用户数'
    ,new_d2r_user               bigint          comment '新增-D2留存用户数'
    ,new_d7r_user               bigint          comment '新增-D7留存用户数'
    ,new_game_user              bigint          comment '新增-游戏用户数'
    ,new_game_dur               bigint          comment '新增-游戏时长'
    ,new_pay_total              decimal(38,2)   comment '新增-充值金额'
    ,new_pay_user               bigint          comment '新增-充值用户数'
    -- *回流
    ,d30rtn_dau                 bigint          comment '30日回流-用户数'
    ,d30rtn_d2r_user            bigint          comment '30日回流-D2留存用户数'
    ,d30rtn_d7r_user            bigint          comment '30日回流-D7留存用户数'
    ,d30rtn_game_user           bigint          comment '30日回流-游戏用户数'
    ,d30rtn_game_dur            bigint          comment '30日回流-游戏时长'
    ,d30rtn_pay_total           decimal(38,2)   comment '30日回流-充值金额'
    ,d30rtn_pay_user            bigint          comment '30日回流-充值用户数'
    ,dt                         varchar         comment '日期'
)
with (format='ORC',partitioned_by=ARRAY['dt'])
;
desc hive.mnv_temp_cn.ads_core_stat_s_d
;
select *
from hive.mnv_temp_cn.ads_core_stat_s_d
;

-- *更新：D-1,D-2,D-7
insert into
hive.mnv_temp_cn.ads_core_stat_s_d
with params as (select '$[yyyy-MM-dd]' as dt)
-- with params as (select '2025-12-20' as dt)
-- @核心数据
,user_login_stat as (
    select count(uin) as dau
    ,sum(is_d2r) as d2r_user
    ,sum(is_d7r) as d7r_user
    from hive.mnv_temp_cn.dws_user_login_stat_s_d
    where dt=(select dt from params)
)
,user_game_stat as (
    select count(uin)                       as game_user
    ,sum(game_dur)                          as game_dur
    ,sum(game_is_d2r)                       as game_d2r_user
    ,sum(game_is_d7r)                       as game_d7r_user
    ,count(if(adv_game_cnt>0,uin,null))     as adv_game_user
    ,sum(adv_game_dur)                      as adv_game_dur
    ,sum(adv_is_d2r)                        as adv_game_d2r_user
    ,sum(adv_is_d7r)                        as adv_game_d7r_user
    ,count(if(cre_game_cnt>0,uin,null))     as cre_game_user
    ,sum(cre_game_dur)                      as cre_game_dur
    ,sum(cre_is_d2r)                        as cre_game_d2r_user
    ,sum(cre_is_d7r)                        as cre_game_d7r_user
    ,count(if(ugc_game_cnt+ogc_game_cnt+studio_game_cnt>0,uin,null)) as map_game_user
    ,sum(ugc_game_dur+ogc_game_dur+studio_game_dur)                  as map_game_dur
    ,sum(if(ugc_is_d2r+ogc_is_d2r+studio_is_d2r>0,1,0))              as map_game_d2r_user
    ,sum(if(ugc_is_d7r+ogc_is_d7r+studio_is_d7r>0,1,0))              as map_game_d7r_user
    ,count(if(ugc_game_cnt>0,uin,null))     as ugc_game_user
    ,sum(ugc_game_dur)                      as ugc_game_dur
    ,sum(ugc_is_d2r)                        as ugc_game_d2r_user
    ,sum(ugc_is_d7r)                        as ugc_game_d7r_user
    ,count(if(ogc_game_cnt>0,uin,null))     as ogc_game_user
    ,sum(ogc_game_dur)                      as ogc_game_dur
    ,sum(ogc_is_d2r)                        as ogc_game_d2r_user
    ,sum(ogc_is_d7r)                        as ogc_game_d7r_user
    ,count(if(studio_game_cnt>0,uin,null))  as studio_game_user
    ,sum(studio_game_dur)                   as studio_game_dur
    ,sum(studio_is_d2r)                     as studio_game_d2r_user
    ,sum(studio_is_d7r)                     as studio_game_d7r_user
    from hive.mnv_temp_cn.dws_user_game_stat_s_d
    where dt=(select dt from params)
)
,user_pay_stat as (
    select count(uin)               as pay_user
    ,sum(pay_total)                 as pay_total
    ,count(if(minicoin>0,uin,null)) as pay_minicoin_user
    ,sum(minicoin)                  as pay_minicoin
    ,count(if(activity>0,uin,null)) as pay_activity_user
    ,sum(activity)                  as pay_activity
    ,count(if(minivip>0,uin,null))  as pay_minivip_user
    ,sum(minivip)                   as pay_minivip
    ,count(if(subscription+pay_for_another+other>0,uin,null))   as pay_other_user
    ,sum(subscription+pay_for_another+other)                    as pay_other
    from hive.mnv_temp_cn.dws_user_pay_stat_s_d
    where dt=(select dt from params)
)
,user_consume_minicoin_stat as (
    select count(uin)                       as cons_user
    ,sum(consume_total)                     as cons_total
    ,count(if(ingame>0,uin,null))           as cons_ingame_user
    ,sum(ingame)                            as cons_ingame
    ,count(if(gacha>0,uin,null))            as cons_gacha_user
    ,sum(gacha)                             as cons_gacha
    ,count(if(dirbuy>0,uin,null))           as cons_dirbuy_user
    ,sum(dirbuy)                            as cons_dirbuy
    ,count(if(activity>0,uin,null))         as cons_activity_user
    ,sum(activity)                          as cons_activity
    ,count(if(social>0,uin,null))           as cons_social_user
    ,sum(social)                            as cons_social
    ,count(if(minibean>0,uin,null))         as cons_minibean_user
    ,sum(minibean)                          as cons_minibean
    ,count(if(other>0,uin,null))            as cons_other_user
    ,sum(other)                             as cons_other
    ,count(if(ingame_adv>0,uin,null))       as cons_ingame_adv_user
    ,sum(ingame_adv)                        as cons_ingame_adv
    ,count(if(ingame_ugc+ingame_ogc+ingame_studio>0,uin,null)) as cons_ingame_map_user
    ,sum(ingame_ugc+ingame_ogc+ingame_studio)                  as cons_ingame_map
    ,count(if(ingame_ugc>0,uin,null))       as cons_ingame_ugc_user
    ,sum(ingame_ugc)                        as cons_ingame_ugc
    ,count(if(ingame_ogc>0,uin,null))       as cons_ingame_ogc_user
    ,sum(ingame_ogc)                        as cons_ingame_ogc
    ,count(if(ingame_studio>0,uin,null))    as cons_ingame_studio_user
    ,sum(ingame_studio)                     as cons_ingame_studio
    ,count(if(ingame_other>0,uin,null))     as cons_ingame_other_user
    ,sum(ingame_other)                      as cons_ingame_other
    from hive.mnv_temp_cn.dws_user_consume_minicoin_stat_s_d
    where dt=(select dt from params)
)
,mianliu_data as (
    select sum(money) as mianliu_rvn
    from hive.dws_cn.dws_fin_recharge_daily_stat_1d_s_d_cn
    where dt=(select dt from params)
    and recharge_type2='all'
    and is_new='all'
    and country='all'
    and reg_channel='all'
    and login_channel='all'
    and version='all'
    and recharge_type='all'
    and project not in ('all','迷你币充值币卡')
    and object_type='all'
    and recharge_type1='all'
    and location='partner'
    and money>0
)
,ad_data1 as (
    select
     max(if(ad_slot_type='all'   ,ad_revenue,0))  as ad_rvn
    ,max(if(ad_slot_type='all'   ,ad_cnt,0))      as ad_cnt
    ,max(if(ad_slot_type='冒险'  ,ad_revenue,0))  as ad_adv_rvn
    ,max(if(ad_slot_type='冒险'  ,ad_cnt,0))      as ad_adv_cnt
    ,max(if(ad_slot_type='平台'  ,ad_revenue,0))  as ad_ptf_rvn
    ,max(if(ad_slot_type='平台'  ,ad_cnt,0))      as ad_ptf_cnt
    ,max(if(ad_slot_type='开发者',ad_revenue,0))  as ad_dev_rvn
    ,max(if(ad_slot_type='开发者',ad_cnt,0))      as ad_dev_cnt
    from (
        select coalesce(t2.ad_slot_type,'all') as ad_slot_type
        ,sum(t1.revenue) as ad_revenue
        ,sum(t1.finish_times) as ad_cnt
        from (
            select try_cast(ad_id as int) as ad_id,revenue,finish_times
            from hive.mn_opadmin.opadmin_ad_finish
            where dt=(select dt from params)
            and country ='all'
            and platform='all'
            and channel ='all'
            and version ='all'
            and try_cast(ad_id as int)>0
        ) t1
        left join hive.mnv_temp_cn.dim_ad_slot t2
        on ad_id=t2.ad_slot_id
        group by cube(t2.ad_slot_type)
    )
)
,ad_data2 as (
    select
     max(if(map_type='ugc',ad_rvn,0)) as ad_ugc_rvn
    ,max(if(map_type='ugc',ad_cnt,0)) as ad_ugc_cnt
    ,max(if(map_type='ogc',ad_rvn,0)) as ad_ogc_rvn
    ,max(if(map_type='ogc',ad_cnt,0)) as ad_ogc_cnt
    ,max(if(map_type='studio',ad_rvn,0)) as ad_studio_rvn
    ,max(if(map_type='studio',ad_cnt,0)) as ad_studio_cnt
    from (
        select map_type
        ,sum(ad_cnt) as ad_cnt
        ,sum(ad_revenue) as ad_rvn
        from hive.mnv_temp_cn.dws_map_game_stat_s_d
        where dt=(select dt from params)
        group by 1
    )
)
-- @新增用户
,new_data as (
    select count(t1.uin)                    as new_dau
    ,sum(is_d2r)                            as new_d2r_user
    ,sum(is_d7r)                            as new_d7r_user
    ,count(t2.uin)                          as new_game_user
    ,sum(t2.game_dur)                       as new_game_dur
    ,sum(t3.pay_total)                      as new_pay_total
    ,count(t3.uin)                          as new_pay_user
    from (
        select *
        from hive.mnv_temp_cn.dws_user_login_stat_s_d
        where dt=(select dt from params)
        and is_new=1
    ) t1
    left join (
        select *
        from hive.mnv_temp_cn.dws_user_game_stat_s_d
        where dt=(select dt from params)
    ) t2
    on t1.uin=t2.uin
    left join (
        select *
        from hive.mnv_temp_cn.dws_user_pay_stat_s_d
        where dt=(select dt from params)
    ) t3
    on t1.uin=t3.uin
)
-- @回流用户
,d30rtn_data as (
    select count(t1.uin)                    as d30rtn_dau
    ,sum(t1.is_d2r)                         as d30rtn_d2r_user
    ,sum(t1.is_d7r)                         as d30rtn_d7r_user
    ,count(t2.uin)                          as d30rtn_game_user
    ,sum(t2.game_dur)                       as d30rtn_game_dur
    ,sum(t3.pay_total)                      as d30rtn_pay_total
    ,count(t3.uin)                          as d30rtn_pay_user
    from (
        select *
        from hive.mnv_temp_cn.dws_user_login_stat_s_d
        where dt=(select dt from params)
        and is_d30rtn=1
    ) t1
    left join (
        select *
        from hive.mnv_temp_cn.dws_user_game_stat_s_d
        where dt=(select dt from params)
    ) t2
    on t1.uin=t2.uin
    left join (
        select *
        from hive.mnv_temp_cn.dws_user_pay_stat_s_d
        where dt=(select dt from params)
    ) t3
    on t1.uin=t3.uin
)
select
-- *登录与留存
 dau
,if(d2r_user=0,null,d2r_user) as d2r_user
,if(d7r_user=0,null,d7r_user) as d7r_user
-- *游戏行为
,game_user
,game_dur
,if(game_d2r_user=0,null,game_d2r_user) as game_d2r_user
,if(game_d7r_user=0,null,game_d7r_user) as game_d7r_user
,adv_game_user
,adv_game_dur
,if(adv_game_d2r_user=0,null,adv_game_d2r_user) as adv_game_d2r_user
,if(adv_game_d7r_user=0,null,adv_game_d7r_user) as adv_game_d7r_user
,cre_game_user
,cre_game_dur
,if(cre_game_d2r_user=0,null,cre_game_d2r_user) as cre_game_d2r_user
,if(cre_game_d7r_user=0,null,cre_game_d7r_user) as cre_game_d7r_user
,map_game_user
,map_game_dur
,if(map_game_d2r_user=0,null,map_game_d2r_user) as map_game_d2r_user
,if(map_game_d7r_user=0,null,map_game_d7r_user) as map_game_d7r_user
,ugc_game_user
,ugc_game_dur
,if(ugc_game_d2r_user=0,null,ugc_game_d2r_user) as ugc_game_d2r_user
,if(ugc_game_d7r_user=0,null,ugc_game_d7r_user) as ugc_game_d7r_user
,ogc_game_user
,ogc_game_dur
,if(ogc_game_d2r_user=0,null,ogc_game_d2r_user) as ogc_game_d2r_user
,if(ogc_game_d7r_user=0,null,ogc_game_d7r_user) as ogc_game_d7r_user
,studio_game_user
,studio_game_dur
,if(studio_game_d2r_user=0,null,studio_game_d2r_user) as studio_game_d2r_user
,if(studio_game_d7r_user=0,null,studio_game_d7r_user) as studio_game_d7r_user
-- *收入
,mianliu_rvn+ad_rvn+pay_total as revenue
-- *充值
,pay_total
,pay_user
,pay_minicoin
,pay_minicoin_user
,pay_activity
,pay_activity_user
,pay_minivip
,pay_minivip_user
,pay_other
,pay_other_user
-- *免流
,mianliu_rvn
-- *广告
,ad_rvn
,ad_cnt
,ad_adv_rvn
,ad_adv_cnt
,ad_ptf_rvn
,ad_ptf_cnt
,ad_dev_rvn
,ad_dev_cnt
,ad_ugc_rvn
,ad_ugc_cnt
,ad_ogc_rvn
,ad_ogc_cnt
,ad_studio_rvn
,ad_studio_cnt
-- *消费迷你币
,cons_total
,cons_user
,cons_ingame
,cons_ingame_user
,cons_gacha
,cons_gacha_user
,cons_dirbuy
,cons_dirbuy_user
,cons_activity
,cons_activity_user
,cons_social
,cons_social_user
,cons_minibean
,cons_minibean_user
,cons_other
,cons_other_user
,cons_ingame_adv
,cons_ingame_adv_user
,cons_ingame_map
,cons_ingame_map_user
,cons_ingame_ugc
,cons_ingame_ugc_user
,cons_ingame_ogc
,cons_ingame_ogc_user
,cons_ingame_studio
,cons_ingame_studio_user
,cons_ingame_other
,cons_ingame_other_user
-- *新增
,new_dau
,if(new_d2r_user=0,null,new_d2r_user) as new_d2r_user
,if(new_d7r_user=0,null,new_d7r_user) as new_d7r_user
,new_game_user
,new_game_dur
,new_pay_total
,new_pay_user
-- *回流
,d30rtn_dau
,if(d30rtn_d2r_user=0,null,d30rtn_d2r_user) as d30rtn_d2r_user
,if(d30rtn_d7r_user=0,null,d30rtn_d7r_user) as d30rtn_d7r_user
,d30rtn_game_user
,d30rtn_game_dur
,d30rtn_pay_total
,d30rtn_pay_user
,(select dt from params) as dt
from user_login_stat
,user_game_stat
,user_pay_stat
,user_consume_minicoin_stat
,mianliu_data
,ad_data1
,ad_data2
,new_data
,d30rtn_data
;