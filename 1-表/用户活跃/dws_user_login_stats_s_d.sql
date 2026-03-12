/*
# 表名
dws_user_login_stats_s_d

# 数据起始日期
2024-01-01

# 更新频率
D-1/2/3/7/14/30/60/90

# 备注
用户留存标记统一用0/1，没有null

# 依赖
hive.dwd_cn.dwd_real_active_user_detail_i_d

# 结果字段（字段名-类型-comment）
uin         bigint      UIN
channels    array(int)  登录渠道列表
is_new      int         是否新增（注册+实名）
is_d7rtn    int         是否7日回流，0/1
is_d30rtn   int         是否30日回流，0/1
is_d2r      int         是否Day2留存（次日），0/1
is_d3r      int         是否Day3留存（三日），0/1
...
is_d90r     int         是否Day90留存（九十日），0/1
dt          varchar     数据起始日期：2024-01-01
*/


with
args as (select '2026-01-28' as dt)
,uin as (
    select uin
    ,array_sort(array_distinct(array_agg(try_cast(channel_id as int)))) as channels
    ,max(if(user_type='新增玩家'    ,1,0)) as is_new
    ,max(if(user_type='7日回流用户' ,1,0)) as is_d7rtn
    ,max(if(user_type='30日回流'    ,1,0)) as is_d30rtn
    from hive.dwd_cn.dwd_real_active_user_detail_i_d
    where dt=(select dt from args)
    group by 1
)
,ret_data as (
    select uin
    ,array_agg(date_diff('day',(select date(dt) from args),date(dt))) as login_dayx
    from hive.dwd_cn.dwd_real_active_user_detail_i_d
    where dt between (select cast(date(dt)+interval'1' day as varchar) from args)
                 and (select cast(date(dt)+interval'89'day as varchar) from args)
    and uin in (select uin from uin)
    group by 1
)
select t1.uin
,t1.channels
,t1.is_new
,t1.is_d7rtn
,t1.is_d30rtn
,max(if(contains(login_dayx,1) ,1,0)) as is_d2r
,max(if(contains(login_dayx,2) ,1,0)) as is_d3r
,max(if(contains(login_dayx,3) ,1,0)) as is_d4r
,max(if(contains(login_dayx,4) ,1,0)) as is_d5r
,max(if(contains(login_dayx,5) ,1,0)) as is_d6r
,max(if(contains(login_dayx,6) ,1,0)) as is_d7r
,max(if(contains(login_dayx,7) ,1,0)) as is_d8r
,max(if(contains(login_dayx,8) ,1,0)) as is_d9r
,max(if(contains(login_dayx,9) ,1,0)) as is_d10r
,max(if(contains(login_dayx,10),1,0)) as is_d11r
,max(if(contains(login_dayx,11),1,0)) as is_d12r
,max(if(contains(login_dayx,12),1,0)) as is_d13r
,max(if(contains(login_dayx,13),1,0)) as is_d14r
,max(if(contains(login_dayx,14),1,0)) as is_d15r
,max(if(contains(login_dayx,15),1,0)) as is_d16r
,max(if(contains(login_dayx,16),1,0)) as is_d17r
,max(if(contains(login_dayx,17),1,0)) as is_d18r
,max(if(contains(login_dayx,18),1,0)) as is_d19r
,max(if(contains(login_dayx,19),1,0)) as is_d20r
,max(if(contains(login_dayx,20),1,0)) as is_d21r
,max(if(contains(login_dayx,21),1,0)) as is_d22r
,max(if(contains(login_dayx,22),1,0)) as is_d23r
,max(if(contains(login_dayx,23),1,0)) as is_d24r
,max(if(contains(login_dayx,24),1,0)) as is_d25r
,max(if(contains(login_dayx,25),1,0)) as is_d26r
,max(if(contains(login_dayx,26),1,0)) as is_d27r
,max(if(contains(login_dayx,27),1,0)) as is_d28r
,max(if(contains(login_dayx,28),1,0)) as is_d29r
,max(if(contains(login_dayx,29),1,0)) as is_d30r
,max(if(contains(login_dayx,30),1,0)) as is_d31r
,max(if(contains(login_dayx,31),1,0)) as is_d32r
,max(if(contains(login_dayx,32),1,0)) as is_d33r
,max(if(contains(login_dayx,33),1,0)) as is_d34r
,max(if(contains(login_dayx,34),1,0)) as is_d35r
,max(if(contains(login_dayx,35),1,0)) as is_d36r
,max(if(contains(login_dayx,36),1,0)) as is_d37r
,max(if(contains(login_dayx,37),1,0)) as is_d38r
,max(if(contains(login_dayx,38),1,0)) as is_d39r
,max(if(contains(login_dayx,39),1,0)) as is_d40r
,max(if(contains(login_dayx,40),1,0)) as is_d41r
,max(if(contains(login_dayx,41),1,0)) as is_d42r
,max(if(contains(login_dayx,42),1,0)) as is_d43r
,max(if(contains(login_dayx,43),1,0)) as is_d44r
,max(if(contains(login_dayx,44),1,0)) as is_d45r
,max(if(contains(login_dayx,45),1,0)) as is_d46r
,max(if(contains(login_dayx,46),1,0)) as is_d47r
,max(if(contains(login_dayx,47),1,0)) as is_d48r
,max(if(contains(login_dayx,48),1,0)) as is_d49r
,max(if(contains(login_dayx,49),1,0)) as is_d50r
,max(if(contains(login_dayx,50),1,0)) as is_d51r
,max(if(contains(login_dayx,51),1,0)) as is_d52r
,max(if(contains(login_dayx,52),1,0)) as is_d53r
,max(if(contains(login_dayx,53),1,0)) as is_d54r
,max(if(contains(login_dayx,54),1,0)) as is_d55r
,max(if(contains(login_dayx,55),1,0)) as is_d56r
,max(if(contains(login_dayx,56),1,0)) as is_d57r
,max(if(contains(login_dayx,57),1,0)) as is_d58r
,max(if(contains(login_dayx,58),1,0)) as is_d59r
,max(if(contains(login_dayx,59),1,0)) as is_d60r
,max(if(contains(login_dayx,60),1,0)) as is_d61r
,max(if(contains(login_dayx,61),1,0)) as is_d62r
,max(if(contains(login_dayx,62),1,0)) as is_d63r
,max(if(contains(login_dayx,63),1,0)) as is_d64r
,max(if(contains(login_dayx,64),1,0)) as is_d65r
,max(if(contains(login_dayx,65),1,0)) as is_d66r
,max(if(contains(login_dayx,66),1,0)) as is_d67r
,max(if(contains(login_dayx,67),1,0)) as is_d68r
,max(if(contains(login_dayx,68),1,0)) as is_d69r
,max(if(contains(login_dayx,69),1,0)) as is_d70r
,max(if(contains(login_dayx,70),1,0)) as is_d71r
,max(if(contains(login_dayx,71),1,0)) as is_d72r
,max(if(contains(login_dayx,72),1,0)) as is_d73r
,max(if(contains(login_dayx,73),1,0)) as is_d74r
,max(if(contains(login_dayx,74),1,0)) as is_d75r
,max(if(contains(login_dayx,75),1,0)) as is_d76r
,max(if(contains(login_dayx,76),1,0)) as is_d77r
,max(if(contains(login_dayx,77),1,0)) as is_d78r
,max(if(contains(login_dayx,78),1,0)) as is_d79r
,max(if(contains(login_dayx,79),1,0)) as is_d80r
,max(if(contains(login_dayx,80),1,0)) as is_d81r
,max(if(contains(login_dayx,81),1,0)) as is_d82r
,max(if(contains(login_dayx,82),1,0)) as is_d83r
,max(if(contains(login_dayx,83),1,0)) as is_d84r
,max(if(contains(login_dayx,84),1,0)) as is_d85r
,max(if(contains(login_dayx,85),1,0)) as is_d86r
,max(if(contains(login_dayx,86),1,0)) as is_d87r
,max(if(contains(login_dayx,87),1,0)) as is_d88r
,max(if(contains(login_dayx,88),1,0)) as is_d89r
,max(if(contains(login_dayx,89),1,0)) as is_d90r
(select dt from args) as dt
from uin t1
left join ret_data t2 on t1.uin=t2.uin
group by 2,3,4,5,6
;