

-- SELECT
--     (DATE(curated_product_fields_audit."created_at" )) AS "curated_product_fields_audit.created_date",
--     CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "curation_tasks.resolution",
--     curation_tasks."customer_id"  AS "curation_tasks.customer_id",
--     attributes."snake_case_name"  AS "attributes.snake_case_name"
-- FROM public.curated_product_fields_audit  AS curated_product_fields_audit
-- LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields_audit."curation_task_id") = (curation_tasks."id")
-- LEFT JOIN public.curation_jobs  AS curation_jobs ON (curated_product_fields_audit."curation_job_id") = (curation_jobs."id")
-- LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
-- LEFT JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
-- WHERE ((( curated_product_fields_audit."created_at"  ) >= ((SELECT TIMESTAMP '2021-06-14')) AND ( curated_product_fields_audit."created_at"  ) < ((SELECT (TIMESTAMP '2021-06-14' + (1 || ' day')::INTERVAL))))) AND (curation_tasks."customer_id" ) = 90 AND (CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END ) LIKE '%rules%'
-- GROUP BY
--     1,
--     2,
--     3,
--     4
-- ORDER BY
--     1 DESC
            
            
SELECT
	curated_product_fields."name" AS "attribute",
	curated_product_fields."value",
	customers."name"  AS "customer_name",
	products."external_id",
	products."description"  AS "long_desc",
	CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
LEFT JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")

WHERE 
-- (((curated_product_fields."name") = '{attribute}')), 
customer_id=90 
AND DATE(created_at) = '2021-06-14'
AND (((customers."name") LIKE '{customer_name}'))
GROUP BY 1,2,3,4,5,6
ORDER BY 2 DESC










