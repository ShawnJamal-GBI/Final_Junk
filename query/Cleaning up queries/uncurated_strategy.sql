WITH
active_strategy_bucket_atts AS (
            -- curation_tasks that haven't gone out yet. Includes freetext
            SELECT DISTINCT
                b.id AS bucket_id
                ,A.NAME AS "Attribute"
                ,B.NAME AS "Bucket"
                ,question_type AS "Question Type"
                ,CONCAT('https://enrich.edgecase.io/dashboard/editor/',
                CAST(strategy_versions.customer_id AS VARCHAR),
                '?ref[buckets]=',CAST(b.id  AS VARCHAR),':',
                REGEXP_REPLACE(REGEXP_REPLACE(TRIM(b.name), '\s' , '%20','g'), '&', '%26','g')
                ) AS "Editor Link"
            FROM BUCKETS AS B
            JOIN STRATEGY_BUCKETS AS SB ON
                B.ID = SB.BUCKET_ID
            JOIN STRATEGY_BUCKETS_ATTRIBUTES AS SBA ON
                SB.ID = SBA.STRATEGY_BUCKET_ID
            JOIN STRATEGY_VERSIONS ON
                SB.STRATEGY_VERSION_ID = STRATEGY_VERSIONS.ID
            JOIN ATTRIBUTES AS A ON
                SBA.ATTRIBUTE_ID = A.ID
            WHERE STRATEGY_VERSIONS.CUSTOMER_ID = '{customer_id}' -- {customer_id}
            AND SBA.STATUS = 'OPT_IN'
--             AND b.name = {buckets}
            AND a.snake_case_name = '{attribute}' 
            --AND A.NAME = 'PRODUCT TYPE'
            ORDER BY
                "Attribute"
                ,"Bucket"
    ),
   
    products_from_buckets AS (
        SELECT
            products.id AS product_id
            ,products.external_id
            ,products.name AS product_name
            ,products.description as "long_desc"
            ,products.customer_id
            ,attributes."name"  AS "attributes"
            ,buckets."name"  AS "buckets"
            ,v."id" as "values"
--            ,b.name
        FROM products
        LEFT JOIN public.products_buckets  AS products_buckets ON (products."id")=(products_buckets."product_id") 
        LEFT JOIN public.buckets  AS buckets ON (products_buckets."bucket_id") = (buckets."id")
        LEFT JOIN public.curation_tasks  AS curation_tasks ON (products_buckets."curation_task_id") = (curation_tasks."id")
        LEFT JOIN public.curation_jobs  AS curation_jobs ON (curation_tasks."curation_job_id") = (curation_jobs."id")
		LEFT JOIN public.strategy_buckets_attributes  AS strategy_buckets_attributes ON (curation_jobs."strategy_buckets_attribute_id") = (strategy_buckets_attributes."id")
		LEFT JOIN public.attributes  AS attributes ON (strategy_buckets_attributes."attribute_id") = (attributes."id")
        LEFT JOIN public.guidelines  AS guidelines ON (strategy_buckets_attributes."guideline_id") = (guidelines."id")
		LEFT JOIN public.values  AS v ON (guidelines."value_id") = (v."id")
        
        
        
        WHERE products.customer_id = '{customer_id}'
        AND active = True
        AND EXISTS (
            SELECT
                product_id
                ,bucket_id
            FROM products_buckets AS pb
            WHERE customer_id = '{customer_id}'
            AND active = True
--             AND (buckets."name") = {buckets}
            AND EXISTS (
                SELECT
                    bucket_id
                FROM active_strategy_bucket_atts AS asba
                WHERE asba.bucket_id = pb.bucket_id
            )
            AND product_id = products.id
        )
    ),
   
    not_curated_yet AS (
        SELECT
            *
        FROM products_from_buckets AS pfb
        WHERE NOT EXISTS (
                SELECT
                    name AS attribute
                    ,external_id
                    ,product_name
                FROM curated_product_fields AS cpf
                WHERE name = REGEXP_REPLACE(REGEXP_REPLACE(LOWER('{attribute}'),'\s','_','g'),'\W','','g')
                AND cpf.customer_id = '{customer_id}'
                AND cpf.product_id = pfb.product_id
        )
    )
   
    SELECT *
    FROM not_curated_yet
