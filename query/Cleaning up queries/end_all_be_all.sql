

SELECT
    curated_product_fields."name"   AS "attribute",
    curated_product_fields."value",
    customers."name"  AS "customers_name",
    products."external_id",
    products."name"  AS "long_desc",
    CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "resolution",
    buckets."name"  AS "buckets"
    
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
INNER JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")
LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")

WHERE (curated_product_fields."name" ) LIKE '{attribute}'
-- AND (curated_product_fields."value" ) LIKE '%n/a%' 
AND (customers."name" ) LIKE '{customer_name}'  
AND (buckets."name" ) LIKE {buckets}



GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7
ORDER BY
    1,
    2,
    3,
    4,
    5 DESC