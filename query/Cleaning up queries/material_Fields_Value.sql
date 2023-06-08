


SELECT
	curated_product_fields."name"  AS "attribute",
	curated_product_fields."value",
	customers."name"  AS "customer_name",
	products."external_id",
	products."name"  AS "long_desc",
	CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "curation_tasks.resolution"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
LEFT JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")

WHERE (((curated_product_fields."name") = '{attribute}')) 
AND (((curated_product_fields."value") NOT LIKE '%n/a%' OR (curated_product_fields."value") IS NULL)) 
AND (((customers."name") LIKE '%motionindustriesus%'))
GROUP BY 1,2,3,4,5,6
ORDER BY 5 DESC