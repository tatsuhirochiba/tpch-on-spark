use tpch100g_parquet;

insert overwrite table q22_customer_tmp
select
  c_acctbal, c_custkey, substr(c_phone, 1, 2) as cntrycode
from
  customer
where
  substr(c_phone, 1, 2) = '13' or
  substr(c_phone, 1, 2) = '31' or
  substr(c_phone, 1, 2) = '23' or
  substr(c_phone, 1, 2) = '29' or
  substr(c_phone, 1, 2) = '30' or
  substr(c_phone, 1, 2) = '18' or
  substr(c_phone, 1, 2) = '17';

select
  cntrycode, count(1) as numcust, sum(c_acctbal) as totacctbal
from
  (select cntrycode, c_acctbal, avg_acctbal 
	 from 
	  (select avg(c_acctbal) as avg_acctbal
     from
       q22_customer_tmp
     where
       c_acctbal > 0.00
    ) ct1,
    (select cntrycode, c_acctbal 
		 from
		   (select o_custkey
        from orders
        group by o_custkey
       ) ot
     right outer join q22_customer_tmp ct
     on
      ct.c_custkey = ot.o_custkey
     where
      o_custkey is null
    ) ct2
  ) a
where
  c_acctbal > avg_acctbal
group by cntrycode
order by cntrycode;
