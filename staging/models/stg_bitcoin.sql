/** This model retrieves all columns from the 'transactions' table in the 
    'bigquery-public-data.crypto_bitcoin' dataset. It filters the records 
    to only include transactions where the block timestamp is within the 
    last 3 months from the current date. Then it materializes the result
    as a table in BigQuery. **/
select *
from `bigquery-public-data.crypto_bitcoin.transactions`
where date(block_timestamp) >= date_sub(current_date(), interval 3 month)
