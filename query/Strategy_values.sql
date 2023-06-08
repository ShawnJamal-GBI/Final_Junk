SELECT
    attributes."name"  AS "attribute",
    attributes."snake_case_name"  AS "name",
    values."name"  AS "value",
    buckets."name"  AS "bucket",
    customers."id"  AS "customers.id"
FROM public.strategy_buckets_attributes_values  AS strategy_buckets_attributes_values
INNER JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (strategy_buckets_attributes_values."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
INNER JOIN public.values  AS values ON (strategy_buckets_attributes_values."value_id") = (values."id")
INNER JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
INNER JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
INNER JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
INNER JOIN public.strategy_versions  AS strategy_versions ON (strategy_buckets."strategy_version_id") = (strategy_versions."id")
INNER JOIN public.customers  AS customers ON (strategy_versions."customer_id") = (customers."id")
WHERE (customers."id" ) = '{customer_id}'
GROUP BY
    1,
    2,
    3,
    4,
    5
ORDER BY
    1