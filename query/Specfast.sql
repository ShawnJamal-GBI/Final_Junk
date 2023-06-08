SELECT
	products_buckets."customer_id" AS "customer_id",
	customers."name" AS "customer_name",
	products_buckets."product_id" AS "product_id",
	products."external_id" AS "external_id",
	products_buckets."bucket_id"  AS "bucket_id",
	buckets."name"  AS "bucket_name",
    attributes."name"  AS "attribute_name",
    attributes."snake_case_name"  AS "snake_case_name"
FROM public.strategy_versions  AS strategy_versions
INNER JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_versions."id") = (strategy_buckets."strategy_version_id")
INNER JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
INNER JOIN (SELECT * FROM public.products_buckets WHERE customer_id IN (144)) AS products_buckets ON (products_buckets."bucket_id") = (strategy_buckets."bucket_id")
INNER JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (strategy_buckets."id") = (strategy_buckets_attributes."strategy_bucket_id")
INNER JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
INNER JOIN public.customers  AS customers ON (products_buckets."customer_id") = (customers."id")
INNER JOIN public.products AS products ON (products."id") = (products_buckets."product_id")
WHERE 
	(strategy_versions."customer_id") IN (144) AND
	(strategy_versions."active" ) AND 
	(strategy_buckets."active") AND 
	(strategy_buckets_attributes."status" ) = 'OPT_IN' AND
	(products.custom_fields->>'specfast')::boolean IS true
GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
ORDER BY
    3



