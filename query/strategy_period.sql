SELECT
    curated_product_fields."customer_id"  AS "curated_product_fields.customer_id",
    attributes."snake_case_name"  AS "attributes.snake_case_name",
    buckets."name"  AS "buckets.name",
    buckets."id"  AS "buckets.id",
    curated_product_fields."value"  AS "curated_product_fields.value"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
WHERE (curated_product_fields."customer_id") = '{customer_id}'
GROUP BY
    1,
    2,
    3,
    4,
    5
ORDER BY
    1