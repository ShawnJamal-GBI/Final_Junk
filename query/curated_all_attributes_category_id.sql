
SELECT
	curated_product_fields."name" AS "attribute",
     buckets."name"  AS "buckets",
     buckets."id" AS "bucket_id",
	curated_product_fields."value",
	customers."name"  AS "customer_name",
	products."external_id",
    categories."external_id"  AS "category_id",
	products."description"  AS "long_desc",
        (DATE(curated_product_fields."curated_at" )) AS "curated_date",
	CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END,
    curation_tasks."curated_by"  AS "curation_tasks.curated_by"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
LEFT JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")
LEFT JOIN public.categories_products  AS categories_products ON (curated_product_fields."product_id") = (categories_products."product_id")
LEFT JOIN public.categories  AS categories ON (categories_products."category_id") = (categories."id")
LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
LEFT JOIN public.strategy_buckets  AS strategy_buckets ON (strategy_buckets_attributes."strategy_bucket_id") = (strategy_buckets."id")
LEFT JOIN public.buckets  AS buckets ON (strategy_buckets."bucket_id") = (buckets."id")
WHERE ((customers."id") = '{customer_id}')
-- AND((categories."id")='{category_id}')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11
ORDER BY 2 DESC










