

-- What is the strategy version
SELECT * FROM strategy_versions sv 
WHERE customer_id = 5; -- param: customer_id to get strategy version ID

-- What is the attribute ID
SELECT * FROM "attributes" a 
WHERE a."name" LIKE 'Cord Length'; -- param: attribute name to get attribute_id

-- What is the buckets
SELECT * FROM (SELECT * FROM strategy_buckets sb WHERE strategy_version_id = 668) AS active_strat
INNER JOIN strategy_buckets_attributes sba ON active_strat.id = sba.strategy_bucket_id
WHERE sba.attribute_id = 2426 -- param: put in the strategy version ID
AND sba.status = 'OPT_IN';