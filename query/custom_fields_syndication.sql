
SELECT 
        attributes."name"  AS attributes,
        products.external_id,
        products.name,
        products.description AS long_desc,
        products.custom_fields,
        products.url,
        products.image_url,
        products.family_id 
	FROM products 
        LEFT JOIN public.products_buckets  AS products_buckets ON (products."id")=(products_buckets."product_id") 
        LEFT JOIN public.buckets  AS buckets ON (products_buckets."bucket_id") = (buckets."id")
        LEFT JOIN public.curation_tasks  AS curation_tasks ON (products_buckets."curation_task_id") = (curation_tasks."id")
        LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
        LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
        LEFT JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
    
	WHERE products.customer_id = 90
	AND text(custom_fields) LIKE '%"s:%'

