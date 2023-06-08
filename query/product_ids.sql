WITH motion_syndication_status AS (SELECT
    products."id"  AS "id",
    curated_product_fields."value"  AS "value"
FROM public.curated_product_fields  AS curated_product_fields
INNER JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
INNER JOIN public.customers  AS customers ON (products."customer_id") = (customers."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
WHERE (customers."name" ) = 'motionapac' AND (attributes."name" ) = 'Syndication Status'
GROUP BY
    1,
    2)
SELECT
    motion_enrich_validation."categories.level_1"  AS "motion_enrich_validation.category_level_1",
    motion_enrich_validation."categories.level_2"  AS "motion_enrich_validation.category_level_2",
    motion_syndication_status.value AS "motion_syndication_status.value",
    motion_syndication_status.id AS "motion_syndication_status.id",
    COUNT(DISTINCT ( motion_enrich_validation."products.external_id"  ) ) AS "motion_enrich_validation.product_count"
FROM customers__144__curation_record AS motion_enrich_validation
LEFT JOIN LATERAL UNNEST(
            STRING_TO_ARRAY(
                REGEXP_REPLACE(
                    (motion_enrich_validation."curated_product_fields.value"),
                    '(\[\")|(\"\])|\"','','g'
                ),
                ','
            )
        ) AS unnested_value
      ON TRUE

INNER JOIN motion_syndication_status ON (motion_enrich_validation."curated_product_fields.product_id") = motion_syndication_status.id
WHERE (motion_syndication_status.value) = 'Syndicated'
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    5 DESC