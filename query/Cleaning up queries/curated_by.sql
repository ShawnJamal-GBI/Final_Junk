SELECT
    attributes."name"  AS "attributes",
    attributes."snake_case_name"  AS "snake_case_name",
    curated_product_fields."value"  AS "value",
    products."customer_id"  AS "customer_id",
    products."external_id"  AS "external_id",
    CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "curation_tasks.resolution",
    buckets."name"  AS "buckets",
    curated_product_fields."curation_task_id"  AS "curation_task_id",
    curation_tasks."curated_by"  AS "curated_by",
    (DATE(curated_product_fields."curated_at" )) AS "date"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
WHERE (curation_tasks."curated_by" ) = 762 --Shawn is 762 Ian is 775
AND (products."customer_id" ) = {customer_id}
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
    1
    

-- SELECT
--     attributes."name"  AS "attributes",
--     attributes."snake_case_name"  AS "snake_case_name",
--     products."external_id"  AS "external_id",
--     products."customer_id"  AS "customer_id",
--     curated_product_fields."value"  AS "value",
--     CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "resolution",
--     buckets."name"  AS "buckets",
--     curation_tasks."curated_by"  AS "curated_by",
--         (DATE(curated_product_fields."curated_at" )) AS "date"
-- FROM public.curated_product_fields  AS curated_product_fields
-- LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
-- LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
-- LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
-- LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
-- LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
-- LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
-- LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
-- -- WHERE (curation_tasks."curated_by" ) = 762
-- WHERE (products."customer_id" ) = 
-- -- AND attributes."snake_case_name" = '{attributes}'
-- GROUP BY
--     1,
--     2,
--     3,
--     4,
--     5,
--     6,
--     7,
--     8,
--     9
-- ORDER BY
--     9 DESC