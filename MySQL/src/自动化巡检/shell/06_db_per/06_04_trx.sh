mysql -uroot -N -e "SELECT trx_id,trx_state,trx_started,now() as date,trx_query FROM information_schema.INNODB_TRX;"
