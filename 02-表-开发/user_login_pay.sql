/*
# 表名

# 数据起始日期
2024-01-01

# 更新频率
D-1/2/3/7/14/30/60/90

# 备注
用户留存标记统一用0/1，没有null
LTV计算直接采用充值订单表，包含直播

# 依赖
hive.dwd_cn.dwd_real_active_user_detail_i_d
hive.mnv_ads_user_pays_cn.ord_payed_details_day

# 结果字段（字段名-类型-comment）
uin             bigint          UIN
channel_list    array(varchar)  登录渠道列表
is_new          int             是否新增（注册+实名）
is_d7rtn        int             是否7日回流，0/1
is_d30rtn       int             是否30日回流，0/1
is_login_dayx   array(int)      Day1-Day90是否登录，0/1
paym_dayx       array(double)   Day1-Day90付费，保留2位
dt              varchar         数据起始日期：2024-01-01
*/

with
args as (select '2026-02-01' as dt)
,uin as (
    select uin
    ,array_distinct(array_agg(channel_id)) as channels
    ,max(if(user_type='新增玩家'    ,1,0)) as is_new
    ,max(if(user_type='7日回流用户' ,1,0)) as is_d7rtn
    ,max(if(user_type='30日回流'    ,1,0)) as is_d30rtn
    from hive.dwd_cn.dwd_real_active_user_detail_i_d
    where dt=(select dt from args)
    group by 1
)
,ret_data0 as (
    select uin
    ,date_diff('day',(select date(dt) from args),date(dt))+1 as dayx
    from hive.dwd_cn.dwd_real_active_user_detail_i_d
    where dt between (select cast(date(dt)+interval'1' day as varchar) from args)
                 and (select cast(date(dt)+interval'89'day as varchar) from args)
    and uin in (select uin from uin)
    group by 1,2
)
,ret_data as (
    select uin
    ,max(if(dayx=2 ,1,0)) as is_d2r
    ,max(if(dayx=3 ,1,0)) as is_d3r
    ,max(if(dayx=4 ,1,0)) as is_d4r
    ,max(if(dayx=5 ,1,0)) as is_d5r
    ,max(if(dayx=6 ,1,0)) as is_d6r
    ,max(if(dayx=7 ,1,0)) as is_d7r
    ,max(if(dayx=8 ,1,0)) as is_d8r
    ,max(if(dayx=9 ,1,0)) as is_d9r
    ,max(if(dayx=10,1,0)) as is_d10r
    ,max(if(dayx=11,1,0)) as is_d11r
    ,max(if(dayx=12,1,0)) as is_d12r
    ,max(if(dayx=13,1,0)) as is_d13r
    ,max(if(dayx=14,1,0)) as is_d14r
    ,max(if(dayx=15,1,0)) as is_d15r
    ,max(if(dayx=16,1,0)) as is_d16r
    ,max(if(dayx=17,1,0)) as is_d17r
    ,max(if(dayx=18,1,0)) as is_d18r
    ,max(if(dayx=19,1,0)) as is_d19r
    ,max(if(dayx=20,1,0)) as is_d20r
    ,max(if(dayx=21,1,0)) as is_d21r
    ,max(if(dayx=22,1,0)) as is_d22r
    ,max(if(dayx=23,1,0)) as is_d23r
    ,max(if(dayx=24,1,0)) as is_d24r
    ,max(if(dayx=25,1,0)) as is_d25r
    ,max(if(dayx=26,1,0)) as is_d26r
    ,max(if(dayx=27,1,0)) as is_d27r
    ,max(if(dayx=28,1,0)) as is_d28r
    ,max(if(dayx=29,1,0)) as is_d29r
    ,max(if(dayx=30,1,0)) as is_d30r
    ,max(if(dayx=31,1,0)) as is_d31r
    ,max(if(dayx=32,1,0)) as is_d32r
    ,max(if(dayx=33,1,0)) as is_d33r
    ,max(if(dayx=34,1,0)) as is_d34r
    ,max(if(dayx=35,1,0)) as is_d35r
    ,max(if(dayx=36,1,0)) as is_d36r
    ,max(if(dayx=37,1,0)) as is_d37r
    ,max(if(dayx=38,1,0)) as is_d38r
    ,max(if(dayx=39,1,0)) as is_d39r
    ,max(if(dayx=40,1,0)) as is_d40r
    ,max(if(dayx=41,1,0)) as is_d41r
    ,max(if(dayx=42,1,0)) as is_d42r
    ,max(if(dayx=43,1,0)) as is_d43r
    ,max(if(dayx=44,1,0)) as is_d44r
    ,max(if(dayx=45,1,0)) as is_d45r
    ,max(if(dayx=46,1,0)) as is_d46r
    ,max(if(dayx=47,1,0)) as is_d47r
    ,max(if(dayx=48,1,0)) as is_d48r
    ,max(if(dayx=49,1,0)) as is_d49r
    ,max(if(dayx=50,1,0)) as is_d50r
    ,max(if(dayx=51,1,0)) as is_d51r
    ,max(if(dayx=52,1,0)) as is_d52r
    ,max(if(dayx=53,1,0)) as is_d53r
    ,max(if(dayx=54,1,0)) as is_d54r
    ,max(if(dayx=55,1,0)) as is_d55r
    ,max(if(dayx=56,1,0)) as is_d56r
    ,max(if(dayx=57,1,0)) as is_d57r
    ,max(if(dayx=58,1,0)) as is_d58r
    ,max(if(dayx=59,1,0)) as is_d59r
    ,max(if(dayx=60,1,0)) as is_d60r
    ,max(if(dayx=61,1,0)) as is_d61r
    ,max(if(dayx=62,1,0)) as is_d62r
    ,max(if(dayx=63,1,0)) as is_d63r
    ,max(if(dayx=64,1,0)) as is_d64r
    ,max(if(dayx=65,1,0)) as is_d65r
    ,max(if(dayx=66,1,0)) as is_d66r
    ,max(if(dayx=67,1,0)) as is_d67r
    ,max(if(dayx=68,1,0)) as is_d68r
    ,max(if(dayx=69,1,0)) as is_d69r
    ,max(if(dayx=70,1,0)) as is_d70r
    ,max(if(dayx=71,1,0)) as is_d71r
    ,max(if(dayx=72,1,0)) as is_d72r
    ,max(if(dayx=73,1,0)) as is_d73r
    ,max(if(dayx=74,1,0)) as is_d74r
    ,max(if(dayx=75,1,0)) as is_d75r
    ,max(if(dayx=76,1,0)) as is_d76r
    ,max(if(dayx=77,1,0)) as is_d77r
    ,max(if(dayx=78,1,0)) as is_d78r
    ,max(if(dayx=79,1,0)) as is_d79r
    ,max(if(dayx=80,1,0)) as is_d80r
    ,max(if(dayx=81,1,0)) as is_d81r
    ,max(if(dayx=82,1,0)) as is_d82r
    ,max(if(dayx=83,1,0)) as is_d83r
    ,max(if(dayx=84,1,0)) as is_d84r
    ,max(if(dayx=85,1,0)) as is_d85r
    ,max(if(dayx=86,1,0)) as is_d86r
    ,max(if(dayx=87,1,0)) as is_d87r
    ,max(if(dayx=88,1,0)) as is_d88r
    ,max(if(dayx=89,1,0)) as is_d89r
    ,max(if(dayx=90,1,0)) as is_d90r
    from ret_data0
    group by 1
)
,pay_data0 as (
    select uin
    ,date_diff('day',(select date(dt) from args),date(dt))+1 as dayx
    ,sum(order_pay_money) as paym
    from hive.mnv_ads_user_pays_cn.ord_payed_details_day
    where dt between (select dt from args)
                 and (select cast(date(dt)+interval'89'day as varchar) from args)
    and order_pay_money>0
    and uin in (select uin from uin)
    group by 1,2
)
,pay_data as (
    select uin
    ,max(if(dayx=1 ,paym,0)) as paym_d1
    ,max(if(dayx=2 ,paym,0)) as paym_d2
    ,max(if(dayx=3 ,paym,0)) as paym_d3
    ,max(if(dayx=4 ,paym,0)) as paym_d4
    ,max(if(dayx=5 ,paym,0)) as paym_d5
    ,max(if(dayx=6 ,paym,0)) as paym_d6
    ,max(if(dayx=7 ,paym,0)) as paym_d7
    ,max(if(dayx=8 ,paym,0)) as paym_d8
    ,max(if(dayx=9 ,paym,0)) as paym_d9
    ,max(if(dayx=10,paym,0)) as paym_d10
    ,max(if(dayx=11,paym,0)) as paym_d11
    ,max(if(dayx=12,paym,0)) as paym_d12
    ,max(if(dayx=13,paym,0)) as paym_d13
    ,max(if(dayx=14,paym,0)) as paym_d14
    ,max(if(dayx=15,paym,0)) as paym_d15
    ,max(if(dayx=16,paym,0)) as paym_d16
    ,max(if(dayx=17,paym,0)) as paym_d17
    ,max(if(dayx=18,paym,0)) as paym_d18
    ,max(if(dayx=19,paym,0)) as paym_d19
    ,max(if(dayx=20,paym,0)) as paym_d20
    ,max(if(dayx=21,paym,0)) as paym_d21
    ,max(if(dayx=22,paym,0)) as paym_d22
    ,max(if(dayx=23,paym,0)) as paym_d23
    ,max(if(dayx=24,paym,0)) as paym_d24
    ,max(if(dayx=25,paym,0)) as paym_d25
    ,max(if(dayx=26,paym,0)) as paym_d26
    ,max(if(dayx=27,paym,0)) as paym_d27
    ,max(if(dayx=28,paym,0)) as paym_d28
    ,max(if(dayx=29,paym,0)) as paym_d29
    ,max(if(dayx=30,paym,0)) as paym_d30
    ,max(if(dayx=31,paym,0)) as paym_d31
    ,max(if(dayx=32,paym,0)) as paym_d32
    ,max(if(dayx=33,paym,0)) as paym_d33
    ,max(if(dayx=34,paym,0)) as paym_d34
    ,max(if(dayx=35,paym,0)) as paym_d35
    ,max(if(dayx=36,paym,0)) as paym_d36
    ,max(if(dayx=37,paym,0)) as paym_d37
    ,max(if(dayx=38,paym,0)) as paym_d38
    ,max(if(dayx=39,paym,0)) as paym_d39
    ,max(if(dayx=40,paym,0)) as paym_d40
    ,max(if(dayx=41,paym,0)) as paym_d41
    ,max(if(dayx=42,paym,0)) as paym_d42
    ,max(if(dayx=43,paym,0)) as paym_d43
    ,max(if(dayx=44,paym,0)) as paym_d44
    ,max(if(dayx=45,paym,0)) as paym_d45
    ,max(if(dayx=46,paym,0)) as paym_d46
    ,max(if(dayx=47,paym,0)) as paym_d47
    ,max(if(dayx=48,paym,0)) as paym_d48
    ,max(if(dayx=49,paym,0)) as paym_d49
    ,max(if(dayx=50,paym,0)) as paym_d50
    ,max(if(dayx=51,paym,0)) as paym_d51
    ,max(if(dayx=52,paym,0)) as paym_d52
    ,max(if(dayx=53,paym,0)) as paym_d53
    ,max(if(dayx=54,paym,0)) as paym_d54
    ,max(if(dayx=55,paym,0)) as paym_d55
    ,max(if(dayx=56,paym,0)) as paym_d56
    ,max(if(dayx=57,paym,0)) as paym_d57
    ,max(if(dayx=58,paym,0)) as paym_d58
    ,max(if(dayx=59,paym,0)) as paym_d59
    ,max(if(dayx=60,paym,0)) as paym_d60
    ,max(if(dayx=61,paym,0)) as paym_d61
    ,max(if(dayx=62,paym,0)) as paym_d62
    ,max(if(dayx=63,paym,0)) as paym_d63
    ,max(if(dayx=64,paym,0)) as paym_d64
    ,max(if(dayx=65,paym,0)) as paym_d65
    ,max(if(dayx=66,paym,0)) as paym_d66
    ,max(if(dayx=67,paym,0)) as paym_d67
    ,max(if(dayx=68,paym,0)) as paym_d68
    ,max(if(dayx=69,paym,0)) as paym_d69
    ,max(if(dayx=70,paym,0)) as paym_d70
    ,max(if(dayx=71,paym,0)) as paym_d71
    ,max(if(dayx=72,paym,0)) as paym_d72
    ,max(if(dayx=73,paym,0)) as paym_d73
    ,max(if(dayx=74,paym,0)) as paym_d74
    ,max(if(dayx=75,paym,0)) as paym_d75
    ,max(if(dayx=76,paym,0)) as paym_d76
    ,max(if(dayx=77,paym,0)) as paym_d77
    ,max(if(dayx=78,paym,0)) as paym_d78
    ,max(if(dayx=79,paym,0)) as paym_d79
    ,max(if(dayx=80,paym,0)) as paym_d80
    ,max(if(dayx=81,paym,0)) as paym_d81
    ,max(if(dayx=82,paym,0)) as paym_d82
    ,max(if(dayx=83,paym,0)) as paym_d83
    ,max(if(dayx=84,paym,0)) as paym_d84
    ,max(if(dayx=85,paym,0)) as paym_d85
    ,max(if(dayx=86,paym,0)) as paym_d86
    ,max(if(dayx=87,paym,0)) as paym_d87
    ,max(if(dayx=88,paym,0)) as paym_d88
    ,max(if(dayx=89,paym,0)) as paym_d89
    ,max(if(dayx=90,paym,0)) as paym_d90
    from pay_data0
    group by 1
)
select t1.uin
,t1.channels
,t1.is_new
,t1.is_d7rtn
,t1.is_d30rtn
,coalesce(is_d2r,0)  as is_d2r
,coalesce(is_d3r,0)  as is_d3r
,coalesce(is_d4r,0)  as is_d4r
,coalesce(is_d5r,0)  as is_d5r
,coalesce(is_d6r,0)  as is_d6r
,coalesce(is_d7r,0)  as is_d7r
,coalesce(is_d8r,0)  as is_d8r
,coalesce(is_d9r,0)  as is_d9r
,coalesce(is_d10r,0) as is_d10r
,coalesce(is_d11r,0) as is_d11r
,coalesce(is_d12r,0) as is_d12r
,coalesce(is_d13r,0) as is_d13r
,coalesce(is_d14r,0) as is_d14r
,coalesce(is_d15r,0) as is_d15r
,coalesce(is_d16r,0) as is_d16r
,coalesce(is_d17r,0) as is_d17r
,coalesce(is_d18r,0) as is_d18r
,coalesce(is_d19r,0) as is_d19r
,coalesce(is_d20r,0) as is_d20r
,coalesce(is_d21r,0) as is_d21r
,coalesce(is_d22r,0) as is_d22r
,coalesce(is_d23r,0) as is_d23r
,coalesce(is_d24r,0) as is_d24r
,coalesce(is_d25r,0) as is_d25r
,coalesce(is_d26r,0) as is_d26r
,coalesce(is_d27r,0) as is_d27r
,coalesce(is_d28r,0) as is_d28r
,coalesce(is_d29r,0) as is_d29r
,coalesce(is_d30r,0) as is_d30r
,coalesce(is_d31r,0) as is_d31r
,coalesce(is_d32r,0) as is_d32r
,coalesce(is_d33r,0) as is_d33r
,coalesce(is_d34r,0) as is_d34r
,coalesce(is_d35r,0) as is_d35r
,coalesce(is_d36r,0) as is_d36r
,coalesce(is_d37r,0) as is_d37r
,coalesce(is_d38r,0) as is_d38r
,coalesce(is_d39r,0) as is_d39r
,coalesce(is_d40r,0) as is_d40r
,coalesce(is_d41r,0) as is_d41r
,coalesce(is_d42r,0) as is_d42r
,coalesce(is_d43r,0) as is_d43r
,coalesce(is_d44r,0) as is_d44r
,coalesce(is_d45r,0) as is_d45r
,coalesce(is_d46r,0) as is_d46r
,coalesce(is_d47r,0) as is_d47r
,coalesce(is_d48r,0) as is_d48r
,coalesce(is_d49r,0) as is_d49r
,coalesce(is_d50r,0) as is_d50r
,coalesce(is_d51r,0) as is_d51r
,coalesce(is_d52r,0) as is_d52r
,coalesce(is_d53r,0) as is_d53r
,coalesce(is_d54r,0) as is_d54r
,coalesce(is_d55r,0) as is_d55r
,coalesce(is_d56r,0) as is_d56r
,coalesce(is_d57r,0) as is_d57r
,coalesce(is_d58r,0) as is_d58r
,coalesce(is_d59r,0) as is_d59r
,coalesce(is_d60r,0) as is_d60r
,coalesce(is_d61r,0) as is_d61r
,coalesce(is_d62r,0) as is_d62r
,coalesce(is_d63r,0) as is_d63r
,coalesce(is_d64r,0) as is_d64r
,coalesce(is_d65r,0) as is_d65r
,coalesce(is_d66r,0) as is_d66r
,coalesce(is_d67r,0) as is_d67r
,coalesce(is_d68r,0) as is_d68r
,coalesce(is_d69r,0) as is_d69r
,coalesce(is_d70r,0) as is_d70r
,coalesce(is_d71r,0) as is_d71r
,coalesce(is_d72r,0) as is_d72r
,coalesce(is_d73r,0) as is_d73r
,coalesce(is_d74r,0) as is_d74r
,coalesce(is_d75r,0) as is_d75r
,coalesce(is_d76r,0) as is_d76r
,coalesce(is_d77r,0) as is_d77r
,coalesce(is_d78r,0) as is_d78r
,coalesce(is_d79r,0) as is_d79r
,coalesce(is_d80r,0) as is_d80r
,coalesce(is_d81r,0) as is_d81r
,coalesce(is_d82r,0) as is_d82r
,coalesce(is_d83r,0) as is_d83r
,coalesce(is_d84r,0) as is_d84r
,coalesce(is_d85r,0) as is_d85r
,coalesce(is_d86r,0) as is_d86r
,coalesce(is_d87r,0) as is_d87r
,coalesce(is_d88r,0) as is_d88r
,coalesce(is_d89r,0) as is_d89r
,coalesce(is_d90r,0) as is_d90r
,coalesce(paym_d1,0) as paym_d1
,coalesce(paym_d2,0) as paym_d2
,coalesce(paym_d3,0) as paym_d3
,coalesce(paym_d4,0) as paym_d4
,coalesce(paym_d5,0) as paym_d5
,coalesce(paym_d6,0) as paym_d6
,coalesce(paym_d7,0) as paym_d7
,coalesce(paym_d8,0) as paym_d8
,coalesce(paym_d9,0) as paym_d9
,coalesce(paym_d10,0) as paym_d10
,coalesce(paym_d11,0) as paym_d11
,coalesce(paym_d12,0) as paym_d12
,coalesce(paym_d13,0) as paym_d13
,coalesce(paym_d14,0) as paym_d14
,coalesce(paym_d15,0) as paym_d15
,coalesce(paym_d16,0) as paym_d16
,coalesce(paym_d17,0) as paym_d17
,coalesce(paym_d18,0) as paym_d18
,coalesce(paym_d19,0) as paym_d19
,coalesce(paym_d20,0) as paym_d20
,coalesce(paym_d21,0) as paym_d21
,coalesce(paym_d22,0) as paym_d22
,coalesce(paym_d23,0) as paym_d23
,coalesce(paym_d24,0) as paym_d24
,coalesce(paym_d25,0) as paym_d25
,coalesce(paym_d26,0) as paym_d26
,coalesce(paym_d27,0) as paym_d27
,coalesce(paym_d28,0) as paym_d28
,coalesce(paym_d29,0) as paym_d29
,coalesce(paym_d30,0) as paym_d30
,coalesce(paym_d31,0) as paym_d31
,coalesce(paym_d32,0) as paym_d32
,coalesce(paym_d33,0) as paym_d33
,coalesce(paym_d34,0) as paym_d34
,coalesce(paym_d35,0) as paym_d35
,coalesce(paym_d36,0) as paym_d36
,coalesce(paym_d37,0) as paym_d37
,coalesce(paym_d38,0) as paym_d38
,coalesce(paym_d39,0) as paym_d39
,coalesce(paym_d40,0) as paym_d40
,coalesce(paym_d41,0) as paym_d41
,coalesce(paym_d42,0) as paym_d42
,coalesce(paym_d43,0) as paym_d43
,coalesce(paym_d44,0) as paym_d44
,coalesce(paym_d45,0) as paym_d45
,coalesce(paym_d46,0) as paym_d46
,coalesce(paym_d47,0) as paym_d47
,coalesce(paym_d48,0) as paym_d48
,coalesce(paym_d49,0) as paym_d49
,coalesce(paym_d50,0) as paym_d50
,coalesce(paym_d51,0) as paym_d51
,coalesce(paym_d52,0) as paym_d52
,coalesce(paym_d53,0) as paym_d53
,coalesce(paym_d54,0) as paym_d54
,coalesce(paym_d55,0) as paym_d55
,coalesce(paym_d56,0) as paym_d56
,coalesce(paym_d57,0) as paym_d57
,coalesce(paym_d58,0) as paym_d58
,coalesce(paym_d59,0) as paym_d59
,coalesce(paym_d60,0) as paym_d60
,coalesce(paym_d61,0) as paym_d61
,coalesce(paym_d62,0) as paym_d62
,coalesce(paym_d63,0) as paym_d63
,coalesce(paym_d64,0) as paym_d64
,coalesce(paym_d65,0) as paym_d65
,coalesce(paym_d66,0) as paym_d66
,coalesce(paym_d67,0) as paym_d67
,coalesce(paym_d68,0) as paym_d68
,coalesce(paym_d69,0) as paym_d69
,coalesce(paym_d70,0) as paym_d70
,coalesce(paym_d71,0) as paym_d71
,coalesce(paym_d72,0) as paym_d72
,coalesce(paym_d73,0) as paym_d73
,coalesce(paym_d74,0) as paym_d74
,coalesce(paym_d75,0) as paym_d75
,coalesce(paym_d76,0) as paym_d76
,coalesce(paym_d77,0) as paym_d77
,coalesce(paym_d78,0) as paym_d78
,coalesce(paym_d79,0) as paym_d79
,coalesce(paym_d80,0) as paym_d80
,coalesce(paym_d81,0) as paym_d81
,coalesce(paym_d82,0) as paym_d82
,coalesce(paym_d83,0) as paym_d83
,coalesce(paym_d84,0) as paym_d84
,coalesce(paym_d85,0) as paym_d85
,coalesce(paym_d86,0) as paym_d86
,coalesce(paym_d87,0) as paym_d87
,coalesce(paym_d88,0) as paym_d88
,coalesce(paym_d89,0) as paym_d89
,coalesce(paym_d90,0) as paym_d90
,(select dt from args) as dt
from uin t1
left join ret_data t2 on t1.uin=t2.uin
left join pay_data t3 on t1.uin=t3.uin
;