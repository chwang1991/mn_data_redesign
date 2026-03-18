/*
日迷你币消费用户的迷你币消费统计
前置表：
    hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day
*/

--【11】迷你币类目月消耗
-- !没细分家具

with
params as (
    select
     '2025-11-01' as sdt
    ,'2025-12-31' as edt
)

select
case
--【直售类型】
when ((why='servantsvr.huodong_rm_minicoin' and args like '%purchase_change_skin%') or (why='shopsvr.skin_buy') or (why='gm.exec' and reason='mall_buy_skin')) then '皮肤直售'
when (why='gm.exec' and reason in ('recommend_homepage','sanrio_buy_skin','discount_buy_skin')) then '皮肤直售'
when (why='shopsvr.avatar_skin_buy' or (why='gm.exec' and reason in ('buy_avatar_mall_coin','buy_avatar_recommend_homepage'))) then 'avt直售'
when (why='shopsvr.avatar_seat_unlock' or (why='gm.exec' and reason like 'buy_act_position%')) then 'avt直售'
when (why in ('shopsvr.rider_upgrade','shopsvr.rider_upgrade_v2','shop.auto_convert_old_rider')) then '坐骑直售'
when (why='shopsvr.item_buy' and json_extract_scalar(args,'$[0]')not in ('12750','12751')) then '道具直售'
when (why='gm.exec' and reason='businesspainting_buy') then '喷漆直售'
when (why='gm.exec' and reason in ('weponskin_buy','weapon_wash')) then '武器直售' --购买和清洗
when (reason in ('buy_store_action','buy_act_position','buy_act_position5')) then '买动作'
--【抽奖】
when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[2]')='lotto') then '常驻抽奖' --活动-抽奖
when (why='servantsvr.huodong_rm_minicoin' and (json_query(args,'lax $[3]') like '%"aname":"home_fruit_cost1%')) then '常驻抽奖' --家园-活动果实消耗
when (why='servantsvr.huodong_rm_minicoin' and json_query(args,'lax $[3]') like '%treasure_chest_fruit_cost%') then '常驻抽奖' --商城宝箱（扭蛋）
when ((why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12752') or (why='gm.exec' and reason in ('buy_mount_lotterites','mall_buy_mount_upgrade'))) then '坐骑抽卡与升级' --坐骑抽卡机
when (why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12751' and version<68864 ) then '常驻抽奖' --好运烟花
when reason in ('crystal_treasures_buy','crystal_treasures_lottery') then '常驻抽奖' --晶灵秘宝
when ((why='gm.exec' and reason='welfare_lottery' and cast(json_extract_scalar(json_extract_scalar(args,'$[1].ext'),'$.buy_id') as int)<=10 ) or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].num') in ('10','20','88')) or (why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12751' and version>=68864)) then '常驻抽奖' --筑梦
when ( (why='gm.exec' and reason='welfare_lottery' and cast(json_extract_scalar(json_extract_scalar(args,'$[1].ext'),'$.buy_id') as int)>10 ) or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].ext') like '%10040%' ) or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].num') in ('68','318'))) then '常驻抽奖' --星辉
--【开发者】
when (reason='kfz_unlock_pay_map') then '地图内购' --251014新增付费解锁
when (why='gm.exec' and reason='mall_bag_op_del') then '地图内购' --地图购买星星
when (why='gm.exec' and reason='kfz_skin_buy') then '地图内购' --地图内开发者商店购买自定义皮肤
when reason in ('kfz_iap_finish','ministudio_shop') then '地图内购'
when (why='gm.exec' and reason like '%unlock_mat%') then '地图内购'
when (why like 'shopsvr.dev_item%' or (why='gm.exec' and reason like 'kfz_iap%')  or (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int ) not in (select uin from mnv_ads_config_cn.miniworld_developer_whitelist_uin ) )) then '地图内购'
when (why='shopsvr.exchange_star') then '地图内购'
when (reason='kfz_sub_coin_exchange') then '地图内购' --开发者商店子币兑换
when (reason='resources_buy_goods') then '地图内购' --资源统一版本，资源商店购买商品
when (reason='map_shop_order_paid') then '地图内购' --2601冒险新商品
--【社交】
when (why in ('shopsvr.send_skin_present','shopsvr.send_avatar_present','shopsvr.send_item_present')) then '赠送'
when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[3]') like '%present_switch_gift%') then '赠送' --赠送礼包
when (reason in ('present_weponskin','mall_friends_give','minivip_buy_to_give','minivip_agree_to_give')) then '赠送'
when (why='gm.exec' and reason='buy_friends_gift') then '赠送' --购买赠送默契礼物
when (reason='posting_lottery_1' ) then '红包' --动态红包抽奖支付红包
when (why='gm.exec' and reason='red_packet_make' ) then '红包'
when (reason='unlock_bestpart_pos')then '社交关系' --拍档位置扩充消耗
when (reason='unlock_family_member')then '社交关系' --家族
--【礼包】
when (why='gm.exec' and reason in('pushactivity_gift_buy','pushactivity_gift_buy_new')) then '礼包相关'
when ( (why='servantsvr.huodong_rm_minicoin' and ( json_query(args,'lax $[3]') like '%buy_gift%' or json_query(args,'lax $[3]') like '%buy_switch_gift%' or json_query(args,'lax $[3]') like '%buy_select_gift%' or json_query(args,'lax $[3]') like '%use_switch_gift%') ) or (why='gm.exec' and reason='welfare_gift_buy')) then '礼包相关'
when (( why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[2]') !='lotto' and json_query(args,'lax $[3]') not like '%"aname":"home_fruit_cost1%' and json_query(args,'lax $[3]') not like '%buy_gift%' and json_query(args,'lax $[3]') not like '%treasure_chest_fruit_cost%' and json_query(args,'lax $[3]') not like '%buy_switch_gift%' and json_query(args,'lax $[3]') not like '%bp_upgrade%' and json_query(args,'lax $[3]') not like '%battlepass_purchase_level%' and json_query(args,'lax $[3]') not like '%buy_newbie_welfare%' and json_query(args,'lax $[3]') not like '%purchase_change_skin%' and json_query(args,'lax $[3]') not like '%use_switch_gift%' and json_query(args,'lax $[3]') not like '%buy_select_gift%' and json_query(args,'lax $[3]') not like '%present_switch_gift%' ) or (why='gm.exec' and reason='business_activity' )) then '礼包相关'
when (reason='mall_promo_gift') then '礼包相关' --非抽奖类型礼包
--【家园】
when ( (why='servantsvr.huodong_rm_minicoin' and (json_query(args,'lax $[3]') like '%bp_upgrade%' or json_query(args,'lax $[3]') like '%battlepass_purchase_level%') ) or why='shopsvr.exchange_bp') then 'bp升级'
when (why='gm.exec' and reason in('try_draw','MyHomeland_HomelandShop_FurnitureLottery', 'MyHomeland_HomelandShop_PetLottery','MyHomeland_HomelandShop_DunHuang_Lottery','shop_buy','craft_ask','MyHomeland_FarmBusinessman_BuyItems','MyHomeland_RanchBusinessman_BuyItems','MyHomeland_HomelandShop_BuyFurniture')) then '新版家园消耗'
--【兑换迷你豆】
when ((why='shopsvr.exchange') or (why='shopsvr.item_buy' and json_extract_scalar(args,'$[0]')='12750')) then '兑换迷你豆'
when (why='gm.exec' and reason='mall_buy_minibean') then '兑换迷你豆'
--【大会员/交易行】
when (why='gm.exec' and reason='vip_mini_goto_buy_impl') then '迷你币大会员'
when (why='gm.exec' and reason='trading_goods_buy') then '交易行'
--【其他】
when (why='shopsvr.item_buy') then '其他'--实际是道具直售的一部分
when (why='shopsvr.role_upgrade') then '其他'
when (why='baseinfo.rename') then '其他'
when (why='gm.exec' and reason like '%unlock_photo%') then '其他'
when (why='gm.exec' and reason in ('buy_room','update_room','auto_pay_room')) then '其他'
when (why='gm.exec' and reason='unlock_map_list_cell') then '其他'
when (why='gm.exec' and reason like '%create_guild%') then '其他'
when (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) in (select uin from mnv_ads_config_cn.miniworld_developer_whitelist_uin where uin_type=1 )) then '其他'
when (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1]  as int) in (select uin from mnv_ads_config_cn.miniworld_developer_whitelist_uin where uin_type=0)) then '其他'
when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[3]') like '%buy_newbie_welfare%') then '其他'
when (why='shopsvr.items_capacity_buy') then '其他' --扩容仓库位
when (why='gm.exec' and reason='business_interactive') then '其他' --互动剧
when (reason in ('add_res_capacity'))then '其他' --2601新资源中心扩容
when (reason in ('building_bag_unlock'))then '其他' --2601方块解锁
--【活动】
when (why='gm.exec' and reason='business_buy_skin_activity_cost') then '活动直售/抽奖' --商业化卖皮肤礼包活动扣迷你币
when (why='gm.exec' and reason in ('forge_item_exchange','pullin_buy_ticket','spring_lottery_buy_ticket','sanrio_forge_item_exchange','vip_theme_batchbuy','vip_theme_friend','vip_theme_buyticket','mod20_buy_gift','mod21_buy_gift','mod22_buy_gift','mod23_buy_gift','act93_buy_gift')) then '活动直售/抽奖' --历史活动堆积
when regexp_like(reason,'buy_score') then '活动直售/抽奖'
when regexp_like(reason,'buy_welfare_cost') then '活动直售/抽奖' --彩蛋购买
when regexp_like(reason,'center_mod') then '活动直售/抽奖'
when regexp_like(reason,'buy_act_skin') then '活动直售/抽奖'
when regexp_like(reason,'buy_act_gift') then '活动直售/抽奖'
when regexp_like(reason,'daily_gift') then '活动直售/抽奖'
when regexp_like(reason,'buy_welfare') then '活动直售/抽奖'
when reason in ('activity99_buy_skin','activity99_flush_discount') then '活动直售/抽奖' --下架皮肤折扣购买
when reason in ('activity_128_buy_reward_item','activity_128_lottery_item','activity_128_create_group','activity_128_join_group') then '活动直售/抽奖' --团购活动
when reason in ('activity_129_buy_skin') then '活动直售/抽奖' --2511兽娘
when reason in ('activity_132_exchange_coin') then '活动直售/抽奖' --2601武则天
end as consume_type
from mnv_ads_account_cn.acc_oplog_minicoin_details_day
where dt between (select sdt from params) and (select edt from params)
and diff<0
and not (
(why in ('gm.recharge','gm.minicoin_add'))
or (why='gm.exec' and coalesce(reason,'')='gm_set')
or (why='gm.exec' and reason in ('gm_error_recovery','gm_supply_minicoin','gm_refund_empty_minicoin','[biz]css_items_remove','[biz]css_items_reissue','gm_supply_minicoin','gm_internal_benefits','gm_test_account','asset_recycle_item'))))
group by 1,2 order by 1,2
;







-- *更新:D-1
with args as (select '2026-02-01' as dt)
,minicoin_data0 as (
    select uin
    ,case
        -- @地图内购
        when (reason='kfz_unlock_pay_map') then '地图内购' --251014新增付费解锁
        when (why='gm.exec' and reason='mall_bag_op_del') then '地图内购' --地图购买星星
        when (why='gm.exec' and reason='kfz_skin_buy') then '地图内购' --地图内开发者商店购买自定义皮肤
        when reason in ('kfz_iap_finish','ministudio_shop') then '地图内购'
        when (why='gm.exec' and reason like '%unlock_mat%') then '地图内购'
        when (why like 'shopsvr.dev_item%' or (why='gm.exec' and reason like 'kfz_iap%') or (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) not in (select uin from hive.mnv_ads_config_cn.miniworld_developer_whitelist_uin ))) then '地图内购'
        when (why='shopsvr.exchange_star') then '地图内购'
        when (reason='kfz_sub_coin_exchange') then '地图内购' --开发者商店子币兑换
        when (reason='resources_buy_goods') then '地图内购' --资源统一版本，资源商店购买商品
        -- @常驻抽奖
        when reason in ('crystal_treasures_buy','crystal_treasures_lottery') then '常驻抽奖1' --晶灵秘宝
        when ((why='gm.exec' and reason='welfare_lottery' and cast(json_extract_scalar(json_extract_scalar(args,'$[1].ext'),'$.buy_id') as int)>10) or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].ext') like '%10040%') or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].num') in ('68','318'))) then '常驻抽奖1' --星辉
        when ((why='gm.exec' and reason='welfare_lottery' and cast(json_extract_scalar(json_extract_scalar(args,'$[1].ext'),'$.buy_id') as int)<=10) or (why='gm.exec' and reason='welfare_lottery' and args not like '%buy_id%' and json_extract_scalar(args,'$[1].id')='10002' and json_extract_scalar(args,'$[1].num') in ('10','20','88')) or (why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12751' and version>=68864)) then '常驻抽奖2' --筑梦
        when ((why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12752') or (why='gm.exec' and reason in ('buy_mount_lotterites','mall_buy_mount_upgrade'))) then '常驻抽奖-其他' --坐骑抽卡机
        when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[2]')='lotto') then '常驻抽奖-其他' --活动-抽奖
        when (why='servantsvr.huodong_rm_minicoin' and json_query(args,'lax $[3]') like '%"aname":"home_fruit_cost1%') then '常驻抽奖-其他' --家园-活动果实消耗
        when (why='servantsvr.huodong_rm_minicoin' and json_query(args,'lax $[3]') like '%treasure_chest_fruit_cost%') then '常驻抽奖-其他' --商城宝箱（扭蛋）
        when (why='shopsvr.exchange_item' and json_extract_scalar(args,'$[1]')='12751' and version<68864 ) then '常驻抽奖-其他' --好运烟花
        -- @皮肤直售
        when ((why='servantsvr.huodong_rm_minicoin' and args like '%purchase_change_skin%') or (why='shopsvr.skin_buy') or (why='gm.exec' and reason='mall_buy_skin')) then '皮肤直售'
        when (why='gm.exec' and reason in ('recommend_homepage','sanrio_buy_skin','discount_buy_skin')) then '皮肤直售'
        -- @avt直售
        when (why='shopsvr.avatar_skin_buy' or (why='gm.exec' and reason in ('buy_avatar_mall_coin','buy_avatar_recommend_homepage'))) then 'avt直售'
        when (why='shopsvr.avatar_seat_unlock' or (why='gm.exec' and reason like 'buy_act_position%')) then 'avt直售'
        -- @坐骑直售
        when (why in ('shopsvr.rider_upgrade','shopsvr.rider_upgrade_v2','shop.auto_convert_old_rider')) then '坐骑直售'
        -- @武器直售
        when (why='gm.exec' and reason in ('weponskin_buy','weapon_wash')) then '武器直售'
        -- @买动作
        when (reason in ('buy_store_action','buy_act_position','buy_act_position5')) then '买动作'
        -- @喷漆直售
        when (why='gm.exec' and reason='businesspainting_buy') then '喷漆直售'
        -- @道具直售
        when (why='shopsvr.item_buy' and json_extract_scalar(args,'$[0]') not in ('12750','12751')) then '道具直售'
        -- @活动直售/抽奖
        when (why='gm.exec' and reason='business_buy_skin_activity_cost') then '活动直售/抽奖' --商业化卖皮肤礼包活动扣迷你币
        when (why='gm.exec' and reason in ('forge_item_exchange','pullin_buy_ticket','spring_lottery_buy_ticket','sanrio_forge_item_exchange','vip_theme_batchbuy','vip_theme_friend','vip_theme_buyticket','mod20_buy_gift','mod21_buy_gift','mod22_buy_gift','mod23_buy_gift')) then '活动直售/抽奖' --历史活动堆积
        when regexp_like(reason,'buy_score') then '活动直售/抽奖'
        when regexp_like(reason,'buy_welfare_cost') then '活动直售/抽奖' --彩蛋购买
        when regexp_like(reason,'center_mod') then '活动直售/抽奖'
        when regexp_like(reason,'buy_act_skin') then '活动直售/抽奖'
        when regexp_like(reason,'buy_act_gift') then '活动直售/抽奖'
        when reason in ('activity99_buy_skin','activity99_flush_discount') then '活动直售/抽奖' --下架皮肤折扣购买
        -- @礼包相关
        when (why='gm.exec' and reason in('pushactivity_gift_buy','pushactivity_gift_buy_new')) then '礼包相关'
        when ((why='servantsvr.huodong_rm_minicoin' and (json_query(args,'lax $[3]') like '%buy_gift%' or json_query(args,'lax $[3]') like '%buy_switch_gift%' or json_query(args,'lax $[3]') like '%buy_select_gift%' or json_query(args,'lax $[3]') like '%use_switch_gift%')) or (why='gm.exec' and reason='welfare_gift_buy')) then '礼包相关'
        when ((why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[2]') !='lotto' and json_query(args,'lax $[3]') not like '%"aname":"home_fruit_cost1%' and json_query(args,'lax $[3]') not like '%buy_gift%' and json_query(args,'lax $[3]') not like '%treasure_chest_fruit_cost%' and json_query(args,'lax $[3]') not like '%buy_switch_gift%' and json_query(args,'lax $[3]') not like '%bp_upgrade%' and json_query(args,'lax $[3]') not like '%battlepass_purchase_level%' and json_query(args,'lax $[3]') not like '%buy_newbie_welfare%' and json_query(args,'lax $[3]') not like '%purchase_change_skin%' and json_query(args,'lax $[3]') not like '%use_switch_gift%' and json_query(args,'lax $[3]') not like '%buy_select_gift%' and json_query(args,'lax $[3]') not like '%present_switch_gift%') or (why='gm.exec' and reason='business_activity')) then '礼包相关'
        when (reason='mall_promo_gift') then '礼包相关' --非抽奖类型礼包
        -- @赠送
        when (why in ('shopsvr.send_skin_present','shopsvr.send_avatar_present','shopsvr.send_item_present')) then '赠送'
        when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[3]') like '%present_switch_gift%') then '赠送' --赠送礼包
        when (reason in ('present_weponskin','mall_friends_give','minivip_buy_to_give','minivip_agree_to_give')) then '赠送'
        when (why='gm.exec' and reason='buy_friends_gift') then '赠送' --购买赠送默契礼物
        -- @红包
        when (reason='posting_lottery_1') then '红包' --动态红包抽奖支付红包
        when (why='gm.exec' and reason='red_packet_make' ) then '红包'
        -- @社交关系
        when (reason='unlock_bestpart_pos')then '社交功能' --拍档位置扩充消耗
        when (reason='unlock_family_member')then '社交功能' --家族
        -- @bp升级
        when ( (why='servantsvr.huodong_rm_minicoin' and (json_query(args,'lax $[3]') like '%bp_upgrade%' or json_query(args,'lax $[3]') like '%battlepass_purchase_level%')) or why='shopsvr.exchange_bp') then 'bp升级'
        -- @新版家园消耗
        when (why='gm.exec' and reason in('try_draw','MyHomeland_HomelandShop_FurnitureLottery','MyHomeland_HomelandShop_PetLottery','MyHomeland_HomelandShop_DunHuang_Lottery','shop_buy','craft_ask','MyHomeland_FarmBusinessman_BuyItems','MyHomeland_RanchBusinessman_BuyItems','MyHomeland_HomelandShop_BuyFurniture')) then '新版家园消耗'
        -- @兑换迷你豆
        when ((why='shopsvr.exchange') or (why='shopsvr.item_buy' and json_extract_scalar(args,'$[0]')='12750')) then '兑换迷你豆'
        when (why='gm.exec' and reason='mall_buy_minibean') then '兑换迷你豆'
        -- @迷你币大会员
        when (why='gm.exec' and reason='vip_mini_goto_buy_impl') then '迷你币大会员'
        -- @交易行
        when (why='gm.exec' and reason='trading_goods_buy') then '交易行'
        -- @改名
        when (why='baseinfo.rename') then '改名'
        -- @其他
        when (why='shopsvr.item_buy') then '其他'--实际是道具直售的一部分
        when (why='shopsvr.role_upgrade') then '其他'
        when (why='gm.exec' and reason like '%unlock_photo%') then '其他'
        when (why='gm.exec' and reason in ('buy_room','update_room','auto_pay_room')) then '其他'
        when (why='gm.exec' and reason='unlock_map_list_cell') then '其他'
        when (why='gm.exec' and reason like '%create_guild%') then '其他'
        when (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) in (select uin from hive.mnv_ads_config_cn.miniworld_developer_whitelist_uin where uin_type=1)) then '其他'
        when (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) in (select uin from hive.mnv_ads_config_cn.miniworld_developer_whitelist_uin where uin_type=0)) then '其他'
        when (why='servantsvr.huodong_rm_minicoin' and json_extract_scalar(args,'$[3]') like '%buy_newbie_welfare%') then '其他'
        when (why='shopsvr.items_capacity_buy') then '其他' --扩容仓库位
        when (why='gm.exec' and reason='business_interactive') then '其他' --互动剧
        else '其他'
    end as consume_type
    ,sum(diff*-1) as minicoin
    from hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day
    where dt=(select dt from params)
    and diff<0
    and not (
        (why in ('gm.recharge','gm.minicoin_add'))
        or (why='gm.exec' and coalesce(reason,'')='gm_set')
        or (why='gm.exec' and reason in (
             'gm_error_recovery'
            ,'gm_supply_minicoin'
            ,'gm_refund_empty_minicoin'
            ,'gm_supply_minicoin'
            ,'gm_internal_benefits'
            ,'gm_test_account'
            ,'[biz]css_items_remove'
            ,'[biz]css_items_reissue'
            ,'asset_recycle_item'))
    )
    group by 1,2
)
,minicoin_data as (
    select uin
    ,sum(minicoin) as consume_total
    ,max(if(consume_type='地图内购'     ,minicoin,0)) as ingame
    ,max(if(consume_type='常驻抽奖1'    ,minicoin,0)) as gacha_1 --晶灵星辉
    ,max(if(consume_type='常驻抽奖2'    ,minicoin,0)) as gacha_2 --筑梦
    ,max(if(consume_type='常驻抽奖-其他',minicoin,0)) as gacha_other
    ,max(if(consume_type='皮肤直售'     ,minicoin,0)) as dirbuy_skin
    ,max(if(consume_type='avt直售'      ,minicoin,0)) as dirbuy_avatar
    ,max(if(consume_type='坐骑直售'     ,minicoin,0)) as dirbuy_rider
    ,max(if(consume_type='武器直售'     ,minicoin,0)) as dirbuy_weapon
    ,max(if(consume_type='买动作'       ,minicoin,0)) as dirbuy_action
    ,max(if(consume_type='喷漆直售'     ,minicoin,0)) as dirbuy_paint
    ,max(if(consume_type='道具直售'     ,minicoin,0)) as dirbuy_item
    ,max(if(consume_type='活动直售/抽奖',minicoin,0)) as activity_event
    ,max(if(consume_type='礼包相关'     ,minicoin,0)) as activity_bundle
    ,max(if(consume_type='赠送'         ,minicoin,0)) as social_gift
    ,max(if(consume_type='红包'         ,minicoin,0)) as social_redpacket
    ,max(if(consume_type='社交功能'     ,minicoin,0)) as social_socialfunc
    ,max(if(consume_type='兑换迷你豆'   ,minicoin,0)) as minibean
    ,max(if(consume_type='新版家园消耗' ,minicoin,0)) as other_homeland
    ,max(if(consume_type='迷你币大会员' ,minicoin,0)) as other_minivip
    ,max(if(consume_type='交易行'       ,minicoin,0)) as other_auction
    ,max(if(consume_type='改名'         ,minicoin,0)) as other_rename
    ,max(if(consume_type='bp升级'       ,minicoin,0)) as other_bp
    ,max(if(consume_type='其他'         ,minicoin,0)) as other_other
    from minicoin_data0
    group by 1
)
,map_tbl_dt as (
    select max(dt) as dt
    from (
        select dt,count(*) as cnt
        from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
        where dt between (select cast(date(dt)-interval'1'day as varchar) from params)
                     and (select dt from params)
        group by 1
    )
    where cnt>0
)
,map_data as (
    select t1.map_id
    ,case
        when t1.is_studio=1        then 'studio'
        when t1.last_label=15      then 'adv' --整合包（混了一部分存档）
        when t2.map_id is not null then 'adv'
        when t3.map_id is not null then 'ogc'
        else 'ugc'
    end as map_type
    from (
        select wid as map_id,is_studio,last_label
        from hive.mnv_ads_ugc_cn.map_sign_algorithm_stats_day
        where dt=(select dt from map_tbl_dt)
        and (ctype=2 or last_label=15)
    ) t1
    left join hive.mnv_temp_cn.dim_adv_map t2 on t1.map_id=t2.map_id
    left join hive.mnv_temp_cn.dim_ogc_map t3 on t1.map_id=t3.map_id
)
,inmap_data0 as (
    select t1.uin
    ,case
        when (t1.why='gm.exec' and t1.reason='mall_bag_op_del') then 'adv'
        when t2.map_type='adv'      then 'adv'
        when t2.map_type='ogc'      then 'ogc'
        when t2.map_type='studio'   then 'studio'
        when t2.map_type='ugc'      then 'ugc'
        else 'other'
    end as consume_type
    ,sum(minicoin) as minicoin
    from (
        select uin
        ,coalesce(
             json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.map_id')
            ,json_value(json_query(args,'lax $[1].ext' OMIT QUOTES),'lax $.mapid')
            ,json_extract_scalar(args,'$[1].map_id')
        ) as map_id
        ,diff*-1 as minicoin
        ,why,reason
        from hive.mnv_ads_account_cn.acc_oplog_minicoin_details_day
        where dt=(select dt from params)
        and diff<0
        and not (
            (why in ('gm.recharge','gm.minicoin_add'))
            or (why='gm.exec' and coalesce(reason,'')='gm_set')
            or (why='gm.exec' and reason in (
                 'gm_error_recovery','gm_supply_minicoin','gm_refund_empty_minicoin'
                ,'[biz]css_items_remove','[biz]css_items_reissue','gm_supply_minicoin'
                ,'gm_internal_benefits','gm_test_account')
            )
        )
        and (
            (why='gm.exec' and reason='kfz_iap_finish')
            or (why='gm.exec' and reason='ministudio_shop')
            or (why='gm.exec' and reason='kfz_unlock_pay_map')
            or (reason='resources_buy_goods')
            or (why='gm.exec' and reason='mall_bag_op_del')
            or (why='gm.exec' and reason='kfz_skin_buy')
            or (why='gm.exec' and reason like '%unlock_mat%')
            or (why like 'shopsvr.dev_item%' or (why='gm.exec' and reason like 'kfz_iap%') or (why='gm.exec' and reason='cm_rm_minicoin' and cast(split(json_extract_scalar(args,'$[1].uin_goods_id'),'_')[1] as int) not in (select uin from hive.mnv_ads_config_cn.miniworld_developer_whitelist_uin)))
            or (why='shopsvr.exchange_star')
            or (reason='kfz_sub_coin_exchange')
        )
    ) t1
    left join map_data t2
    on t1.map_id=t2.map_id
    group by 1,2
)
,inmap_data as (
    select uin
    ,max(if(consume_type='adv'   ,minicoin,0)) as ingame_adv
    ,max(if(consume_type='ugc'   ,minicoin,0)) as ingame_ugc
    ,max(if(consume_type='ogc'   ,minicoin,0)) as ingame_ogc
    ,max(if(consume_type='studio',minicoin,0)) as ingame_studio
    ,max(if(consume_type='other' ,minicoin,0)) as ingame_other
    from inmap_data0
    group by 1
)
select t1.uin
,consume_total
-- 主类
,ingame
,(gacha_1+gacha_2+gacha_other) as gacha
,(dirbuy_skin+dirbuy_avatar+dirbuy_rider+dirbuy_weapon+dirbuy_action+dirbuy_paint+dirbuy_item) as dirbuy
,(activity_event+activity_bundle) as activity
,(social_gift+social_redpacket+social_socialfunc) as social
,minibean
,(other_homeland+other_minivip+other_auction+other_rename+other_bp+other_other) as other
-- 重点子类
,coalesce(t2.ingame_adv,0)    as ingame_adv
,coalesce(t2.ingame_ugc,0)    as ingame_ugc
,coalesce(t2.ingame_ogc,0)    as ingame_ogc
,coalesce(t2.ingame_studio,0) as ingame_studio
,coalesce(t2.ingame_other,0)  as ingame_other
,gacha_1
,gacha_2
,gacha_other
,dirbuy_skin
,dirbuy_avatar
,dirbuy_rider
,dirbuy_weapon
,dirbuy_action
,dirbuy_paint
,dirbuy_item
,activity_event
,activity_bundle
,social_gift
,social_redpacket
,social_socialfunc
,other_homeland
,other_minivip
,other_auction
,other_rename
,other_bp
,other_other
,(select dt from params) as dt
from minicoin_data t1
left join inmap_data t2 on t1.uin=t2.uin
;

select *
from hive.mnv_temp_cn.dws_user_consume_minicoin_stat_s_d
limit 1000
;