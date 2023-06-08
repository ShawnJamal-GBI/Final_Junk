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
            WHERE STRATEGY_VERSIONS.CUSTOMER_ID = 5 -- {customer_id}
            AND SBA.STATUS = 'OPT_IN'
            AND b.name = 'Charging Adapters & Power Banks'
            AND a.name = 'Charging Time (Minutes)'
            --AND A.NAME = 'PRODUCT TYPE'
            ORDER BY 
                "Attribute"
                ,"Bucket"
    ),
    
    products_from_buckets AS ( 
        SELECT
            id AS product_id
            ,external_id
            ,name AS product_name
        FROM products
        WHERE customer_id = 127
        AND active = True
        AND EXISTS (
            SELECT
                product_id
                ,bucket_id
            FROM products_buckets AS pb
            WHERE customer_id = 127
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
                WHERE name = REGEXP_REPLACE(REGEXP_REPLACE(LOWER('Charging Time (Minutes)'),'\s','_','g'),'\W','','g')
                AND cpf.customer_id = 127
                AND cpf.product_id = pfb.product_id
        )
    )
    
    SELECT *
    FROM not_curated_yet