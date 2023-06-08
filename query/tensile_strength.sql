WITH 
/*
* bulk n/a by attribute and bucket
* 
*/
active_strategy_bucket_atts AS (
        -- curation_tasks that haven't gone out yet. Includes freetext
        SELECT DISTINCT 
            b.id AS bucket_id
            ,A.NAME AS "Attribute"
            ,a.snake_case_name
            ,B.NAME AS "Bucket"
        FROM BUCKETS AS B
        JOIN STRATEGY_BUCKETS AS SB ON
            B.ID = SB.BUCKET_ID
        JOIN STRATEGY_BUCKETS_ATTRIBUTES AS SBA ON
            SB.ID = SBA.STRATEGY_BUCKET_ID
        JOIN STRATEGY_VERSIONS ON
            SB.STRATEGY_VERSION_ID = STRATEGY_VERSIONS.ID
        JOIN ATTRIBUTES AS A ON
            SBA.ATTRIBUTE_ID = A.ID
        WHERE STRATEGY_VERSIONS.CUSTOMER_ID = %(customer_id)s
        AND SBA.STATUS = 'OPT_IN'
        AND sb.active = True
        AND STRATEGY_VERSIONS.active = True
        AND a.snake_case_name = %(snake_case_name)s
        ORDER BY 
            "Attribute"
            ,"Bucket"
),
products_from_buckets AS ( 
    SELECT
        buckets
        ,ba.bucket_id
        ,id AS product_id
        ,external_id
        ,name AS product_name
        ,description AS long_desc
        ,url
        ,image_url
        ,cast(products.custom_fields AS jsonb) AS "custom_fields"
    FROM products
    INNER JOIN(
        SELECT
            product_id
            ,bucket_id
            ,b.name AS buckets
        FROM products_buckets AS pb
        INNER JOIN buckets AS b
            ON b.id = bucket_id
        WHERE customer_id = %(customer_id)s
        AND EXISTS (
            SELECT
                bucket_id
            FROM active_strategy_bucket_atts AS asba
            WHERE asba.bucket_id = pb.bucket_id
        )
    ) AS ba
    ON product_id = products.id
    WHERE customer_id = %(customer_id)s
    AND active = True
),
	curation AS (
		 SELECT
			product_id
		    ,value
			    /* was a test to convert the array to string but causes an error trying because of inconsistency
			    regexp_split_to_array(
			    	regexp_replace(value, e'(\[\\")|(\\"\])', '')
			    	,e'\\",\\"')
			    )) AS curated_values 
			    */
		FROM curated_product_fields AS cpf
		WHERE LOWER(name) IN (SELECT DISTINCT snake_case_name FROM active_strategy_bucket_atts)
		AND cpf.customer_id = %(customer_id)s
		GROUP BY
			1,2
	),
	curation_join AS (
	    SELECT
	        pfb.*
	        ,c.*
	    FROM products_from_buckets AS pfb
	    INNER JOIN curation AS c
	    	ON c.product_id = pfb.product_id
	)
SELECT
   *
FROM curation_join