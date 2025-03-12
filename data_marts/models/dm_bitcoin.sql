/** 
  This query retrieves the balance of each address from the 'stg_bitcoin' table in the 
  'astrafy-bt-challenge.staging' dataset. It first identifies coinbase addresses 
  (addresses that received the mining rewards) and excludes them from the final result.
  The balance for each address is calculated as the total received minus the total sent 
  by aggregating the respective values from the 'inputs' and 'outputs' arrays. The result 
  is returned with the address and balance of each non-coinbase address.
**/

with coinbase_addresses as
  (select 
    distinct address
  from 
    `astrafy-bitcoin-project`.staging.stg_bitcoin, 
    unnest(outputs) as output, 
    unnest(output.addresses) as address
  where is_coinbase),

  addresses_total_sent as
  (select
    address,
    sum(coalesce(value,0)) as total_sent
  from 
    `astrafy-bitcoin-project`.staging.stg_bitcoin, 
    unnest(inputs) as input, 
    unnest(input.addresses) as address
  group by address),

  addresses_total_received as
  (select
    address,
    sum(coalesce(value,0)) as total_received
  from
    `astrafy-bitcoin-project`.staging.stg_bitcoin, 
    unnest(outputs) as output, 
    unnest(output.addresses) as address
  group by address)

select *
from 
  (select
    coalesce(ts.address, tr.address) as address,
    coalesce(total_received, 0) - coalesce(total_sent, 0) as balance
  from addresses_total_sent ts
  full outer join addresses_total_received tr on ts.address = tr.address)
where address not in (select address from coinbase_addresses)