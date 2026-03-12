/*
每日用户的冒险模式“等级与经验”
前置表：
    hive.mnv_temp_cn.dws_user_login_stat_s_d
    hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
*/
select min(dt)
from hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
where dt<'2024-02-01'
-- *建表
create table
hive.mnv_temp_cn.dws_user_adv_lv_s_d
(
     uin            bigint
    ,adv_exp        bigint      comment '冒险模式经验值'
    ,max_adv_day    bigint      comment '最大生存天数'
    ,max_mineral    bigint      comment '最高级消耗金属，0~6=无/石/铜/铁/铝/钛/钨'
    ,max_mission    bigint      comment '最高完成任务，0~10=无/初始工具/工匠台/睡觉/熔炉/高级矿工/星能技术/羽蛇神/黑龙或远古巨龙/火山祭坛献祭/虚空幻影'
    ,dt             varchar
)
with (format='ORC',partitioned_by=ARRAY['dt'])
;
desc hive.mnv_temp_cn.dws_user_adv_lv_s_d
;

select uin
,sum(adv_exp) as adv_exp
,max(max_adv_day) as max_adv_day
,max(max_mineral) as max_mineral
,max(max_mission) as max_mission
from hive.mnv_temp_cn.dws_user_adv_lv_s_d
where dt >= '2026-01-01'
group by 1
order by 2 desc
limit 10000
;


-- *更新：D-1
insert into
hive.mnv_temp_cn.dws_user_adv_lv_s_d
with params as (select '$[yyyy-MM-dd]' as dt)
-- with params as (select '2025-12-01' as dt)
--冒险模式经验值
,adv_exp as (
    select uin
    ,sum(try_cast(standby1 as bigint)) as adv_exp
    from hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
    where dt=(select dt from params)
    and comp_id='Material'
    and event_code='add_exp'
    group by 1
)
--最大生存天数（数据最全）
,max_adv_day as (
    select uin
    ,max(life_days) as max_adv_day
    from hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
    where dt=(select dt from params)
    group by 1
)
--最高级消耗金属
,max_mineral as (
    select uin
    ,max(case
        when item_id='104'   then 1 --石
        when item_id='11329' then 2 --铜
        when item_id='11209' then 3 --铁
        when item_id='12758' then 4 --铝
        when item_id='11330' then 5 --钛
        when item_id='11203' then 6 --钨
    end) as max_mineral
    from (
        select uin,item_id
        from (
            select uin
            ,transform(transform(split(standby2,'#'),x->split(x,':')),x->if(cardinality(x)>=2,row(x[1],x[2]))) as item
            from hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
            where dt=(select dt from params)
            and event_code in ('consume')
        )
        cross join unnest(item) as t(item_id,item_num)
        where item_id in ('104','11329','11209','12758','11330','11203')
    )
    group by 1
)
--最高完成任务（有筛选）
,max_mission as (
    select uin
    ,max(case
        when standby1='100201' then 1 --初始工具
        when standby1='100204' then 2 --工匠台
        when standby1='100211' then 3 --睡觉
        when standby1='100305' then 4 --熔炉
        when standby1='100501' then 5 --高级矿工
        when standby1='100604' then 6 --星能技术
        when standby1='100705' then 7 --羽蛇神
        when standby1 in ('101002','101203') then 8 --黑龙或远古巨龙（并行任务）
        when standby1='101401' then 9 --火山祭坛献祭
        when standby1='100101' then 10 --虚空幻影
    end) as max_mission
    from hive.dwd_cn.dwd_sdk_70000_adventure_mode_map_dtl_i_d
    where dt=(select dt from params)
    and comp_id='Task'
    and event_code='task_complete'
    and try_cast(standby1 as bigint) in (100201,100204,100211,100305,100501,100604,100705,101002,101203,101401,100101)
    group by 1
)
--汇总数据
select t1.uin
,coalesce(t2.adv_exp,0)       as adv_exp
,coalesce(t1.max_adv_day,0)   as max_adv_day
,coalesce(t3.max_mineral,0)   as max_mineral
,coalesce(t4.max_mission,0)   as max_mission
,(select dt from params) as dt
from max_adv_day t1
left join adv_exp      t2 on t1.uin=t2.uin
left join max_mineral  t3 on t1.uin=t3.uin
left join max_mission  t4 on t1.uin=t4.uin
;

