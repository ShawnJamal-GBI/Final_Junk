
SELECT
-- 	curated_product_fields."name" AS "attribute",
--      buckets."name"  AS "buckets",
--      buckets."id" AS "bucket_id",
	curated_product_fields."value",
	customers."name"  AS "customer_name",
    attributes."snake_case_name"  AS "snake_case_name",
	products."external_id",
    curated_product_fields."curated_at" AS "Curated Date",
    curated_product_fields."updated_at" AS "Updated Date"
-- 	products."description"  AS "long_desc",
--         (DATE(curated_product_fields."curated_at" )) AS "curated_date",
-- 	CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END,
--     curation_tasks."curated_by"  AS "curation_tasks.curated_by"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
LEFT JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
-- LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
-- LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
-- LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
-- LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
-- WHERE (curated_product_fields."curated_at") >= '{dateszs}' OR (curated_product_fields."updated_at") >= '{dateszs}' 
-- (((customers."id") != 5))
GROUP BY 1,2,3,4,5,6
ORDER BY 4 DESC










