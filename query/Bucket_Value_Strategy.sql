SELECT
    attributes."snake_case_name"  AS "name",
    buckets."name"  AS "buckets",
    strategy_versions."name"  AS "strategy_versions",
    values."name"  AS "values"
FROM public.strategy_versions  AS strategy_versions
INNER JOIN public.customers  AS customers ON (strategy_versions."customer_id") = (customers."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_versions."id") = (strategy_buckets."strategy_version_id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (strategy_buckets."id") = (strategy_buckets_attributes."strategy_bucket_id")
LEFT JOIN public.strategy_buckets_attributes_values  AS strategy_buckets_attributes_values ON (strategy_buckets_attributes."id") = (strategy_buckets_attributes_values."strategy_buckets_attribute_id")
INNER JOIN public.values  AS values ON (strategy_buckets_attributes_values."value_id") = (values."id")
INNER JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
INNER JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
WHERE (((customers."id") = '{customer_id}'))
AND (strategy_versions."active" ) 
AND (strategy_buckets_attributes_values."status" ) = 'OPT_IN' 
AND (((attributes."snake_case_name" ) LIKE '{attribut}' ESCAPE '^'))
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    1