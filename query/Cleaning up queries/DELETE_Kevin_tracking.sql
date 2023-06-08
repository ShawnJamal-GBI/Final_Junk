SELECT
    attributes."name"  AS "attributes",
    attributes."snake_case_name"  AS "snake_case_name",
    products."external_id"  AS "external_id",
    products.id AS product_id,
    products."description"  AS "long_desc",
        (DATE(curated_product_fields."curated_at" )) AS "curated_date",
    customers."id"  AS "customers_id",
    buckets."name"  AS "buckets",
    curated_product_fields."value"  AS "value",
    CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END

FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
INNER JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")
LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
WHERE (customers."id" ) = 5
AND ((( attributes."snake_case_name"  ) LIKE '{attribute}' ESCAPE '^')) 
GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
ORDER BY
    6 DESC