/*
# 表名

# 数据起始日期
2024-01-01

# 更新频率
D-1

# 备注

# 依赖
mnv_ads_user_pays_cn.ord_payed_details_day

# 结果字段（字段名-类型-comment）
uin             bigint          用户ID
paym            decimal(38,2)   充值金额
minicoin        decimal(38,2)   迷你币（含VIP）
activity        decimal(38,2)   充值活动
minivip         decimal(38,2)   大会员
subscription    decimal(38,2)   订阅迷你币
pay_for_another decimal(38,2)   代付
live            decimal(38,2)   直播
other           decimal(38,2)   其他
dt              varchar         数据起始日期：2024-01-01

*/

with
args as (select '2026-02-01' as dt)
,pay_data as (
    select uin
    ,case merge_order_type
        when 'minicoin'             then '迷你币' --含VIP
        when 'activity_direct_buy'  then '充值活动'
        when 'minivip_direct_buy'   then '大会员'
        when 'subscription'         then '订阅迷你币'
        when 'pay_for_another'      then '代付'
        when 'external_store'       then '直播'
        else '其他'
    end as pay_type
    ,sum(order_pay_money) as rmb
    from hive.mnv_ads_user_pays_cn.ord_payed_details_day
    where dt=(select dt from args)
    and order_pay_money>0
    group by 1,2
)
select uin
,sum(rmb) as paym
,sum(if(pay_type='迷你币'    ,rmb,0)) as minicoin
,sum(if(pay_type='充值活动'  ,rmb,0)) as activity
,sum(if(pay_type='大会员'    ,rmb,0)) as minivip
,sum(if(pay_type='订阅迷你币',rmb,0)) as subscription
,sum(if(pay_type='代付'      ,rmb,0)) as pay_for_another
,sum(if(pay_type='直播'      ,rmb,0)) as live
,sum(if(pay_type='其他'      ,rmb,0)) as other
,(select dt from args) as dt
from pay_data
group by 1
;