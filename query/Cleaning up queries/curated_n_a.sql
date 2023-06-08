SELECT
    attributes."name"  AS "attribute",
    attributes."snake_case_name"  AS "snake_case_name",
    products."customer_id"  AS "customer_id",
    products."external_id"  AS "external_id",
    products."name"  AS "name",
    products."description"  AS "long_desc",
    CASE WHEN curation_tasks."resolution" IS NULL THEN 'standard' ELSE resolution END  AS "resolution",
        (DATE(curated_product_fields."curated_at" )) AS "date",
    curation_tasks."curated_by"  AS "curated_by",
    curated_product_fields."value"  AS "value"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
LEFT JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
INNER JOIN public.customers  AS customers ON (curated_product_fields."customer_id") = (customers."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
WHERE ((( curated_product_fields."curated_at"  ) >= ((SELECT (DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago') + (-10 || ' day')::INTERVAL))) 
        AND ( curated_product_fields."curated_at"  ) < ((SELECT ((DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago') + (-10 || ' day')::INTERVAL) + (11 || ' day')::INTERVAL))))) 
AND (products."customer_id" ) = 5 
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
    8 DESC

