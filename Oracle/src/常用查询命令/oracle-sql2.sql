 select m.*,
        (select ft.fund_account
           from client.t_client_fundaccount ft
          where ft.client_id = m.clientId
            and ft.account_flag = '1'
            limit 2) fundAccount,
        (select indicate_star
           from client.t_client_indicatestar
          where client_id = m.clientId
            and create_userid = 2238) as clientStar,
        (select decode(count(1), 0, '否', '是')
           from broker.t_brok_relation br, client.t_client_fundaccount ft
          where br.relation_status = '1'
            and ft.client_id = m.clientId
            and br.client_id = ft.fund_account
            limit 2) brokerClient,
        (select nvl(bk.broker_name, '')
           from broker.t_brok_relation br, broker.t_broker bk
          where br.broker_id = bk.broker_id
            and br.relation_status = '1'
            and br.client_id = m.clientId
            limit 2) brokerName,
        (select decode(t5.risk_bear_ablity,
                       '0',
                       '默认保守型-未评估',
                       '1',
                       '积极型',
                       '2',
                       '相对积极型',
                       '3',
                       '稳健型',
                       '4',
                       '相对保守型',
                       '5',
                       '保守型',
                       '6',
                       '默认保守型-已失效')
           from client.t_client_clientrisk t5
          where t5.client_id = m.clientId
            limit 2) riskBearAblity,
        cam.asset_underman AS AUM,
        t3.TOTAL_ASSET as totalAsset,
        t3.CURRENT_ASSET as currentAsset,
        t3.CURRENT_MARKET_VALUE as currentMarketValue,
        t3.TOTAL_BALANCE as totalBalance,
        t3.OUTSTANDING_BALANCE as outstandingBalance,
        t3.BUSINESS_BALANCE_YEAR as balanceYear,
        t3.NET_FARE_YEAR as netFareYear,
        t3.TY_NET_FARE_PRODUCT as tyNetFareProduct,
        t3.TY_BUY_OFSTOCK_BALANCE as tyBuyOfstockBalance,
        t3.TY_BALANCE_NETFLOW as tyBalanceNetflow,
        t3.MAX_HOLD_TOTALASSET_VALUE as maxHoldTotalassetValue,
        t3.STOCK_PROD_ASSET as stockProdAsset,
        t3.NET_ASSET as netAsset,
        decode(t3.VALID_CLIENT, '0', '否', '1', '是') as validClient,
        fc.client_name as clientName,
        fc.email as email,
        to_char(to_date(fc.corp_end_date, 'yyyymmdd'), 'yyyy-mm-dd') as corpEndDate,
        decode(cp.prof_flag, '0', '否', '1', '是', '') as profFlag,
        t7.LY_TURNOVER as lyTurnover,
        to_char(to_date(tc.open_date, 'yyyymmdd'), 'yyyy-mm-dd') as openDate  
         from (select *
           from (select tz.*
                   from (select ll.CLIENT_ID       AS clientId,
                                ll.ORGANIZATION_ID AS organizationId,
                                ll.MAIN_SERVUSERID AS mainServUserId
                           from CLIENT.T_CLIENT_OUTCLIENTID ll
                          WHERE exists
                          (select tss.client_id
                                   from t_serv_servrela tss
                                  where tss.client_id = ll.client_id
                                    and tss.user_id in
                                        (select xua.user_id
                                           from t_xtgl_user xua
                                          where 1 = 1
                                            and (xua.organization_id in
                                                (86242,
                                                  94264,
                                                  89271,
                                                  86331,
                                                  94418,
                                                  97615,
                                                  258,
                                                  100655,
                                                  94772,
                                                  237,
                                                  86247,
                                                  236,
                                                  86329,
                                                  95264,
                                                  42,
                                                  100394,
                                                  235,
                                                  94415,
                                                  91015,
                                                  82215,
                                                  43,
                                                  91016,
                                                  100189,
                                                  86244,
                                                  15,
                                                  90217,
                                                  86216,
                                                  232,
                                                  96014,
                                                  81564,
                                                  9916,
                                                  3,
                                                  81539,
                                                  82226,
                                                  100514,
                                                  91,
                                                  94773,
                                                  82228,
                                                  83701,
                                                  86316,
                                                  88446,
                                                  90214,
                                                  81548,
                                                  81565,
                                                  81556,
                                                  233,
                                                  100395,
                                                  100188,
                                                  86322,
                                                  31,
                                                  86245,
                                                  95568,
                                                  82223,
                                                  66,
                                                  2,
                                                  86324,
                                                  94416,
                                                  88426,
                                                  94714,
                                                  88434,
                                                  90216,
                                                  32,
                                                  97466,
                                                  81572,
                                                  94414,
                                                  86320,
                                                  86215,
                                                  97614,
                                                  90215,
                                                  100615,
                                                  80543,
                                                  81549,
                                                  92815,
                                                  88447,
                                                  86243,
                                                  27)))
                                    and tss.user_relatype in ('2', '3'))
                          order by ll.CLIENT_ID) tz)
          limit 10) m
   left join CLIENT.T_INDEX_CLIENTCURENT t3
     on m.clientId = t3.CLIENT_ID
   left join CLIENT.T_CLIENT_OUTCLIENTID_INFO fc
     on m.clientId = fc.CLIENT_ID
   left join CLIENT.T_CLIENT_COUNTERCLIENT tc
     on m.clientId = tc.CLIENT_ID
   left join CLIENT.T_CLIENT_CLIENTPREFER cp
     on m.clientId = cp.CLIENT_ID
   left join (select *
                from CLIENT.T_INDEX_PANORAMA_MON a
               where a.month_id =
                     (select max(b.month_id)
                        from CLIENT.T_INDEX_PANORAMA_MON b)) t7
     on m.clientId = t7.CLIENT_ID
   left join CLIENT.T_INDEX_ASSETPANORAMA cam
     on m.clientId = cam.CLIENT_ID
    and cam.MONTH_ID = '202109'
  order by m.clientId;
