WITH 
	active_strategy_bucket_atts AS (
        SELECT DISTINCT
		  strategy_versions.customer_id,
          b.id AS bucket_id,
		  b.name AS Bucket,
		  a.name AS Attribute,
		  attribute_id,
		  v.id,
		  v.name AS Value
		FROM buckets AS b
		  JOIN strategy_buckets AS sb ON b.id = sb.bucket_id
		  JOIN strategy_buckets_attributes AS sba ON sb.id = sba.strategy_bucket_id
		  JOIN strategy_buckets_attributes_values AS sbva ON sba.id = sbva.strategy_buckets_attribute_id
		  JOIN strategy_versions ON sb.strategy_version_id = strategy_versions.id
		  JOIN attributes AS a ON sba.attribute_id = a.id
		  JOIN values AS v ON sbva.value_id = v.id
		-- conditions
		WHERE strategy_versions.customer_id = {customer_id}
		AND sba.status = 'OPT_IN'
		AND sbva.status = 'OPT_IN'
     	AND strategy_versions.active = True
     	AND LOWER(a.name) LIKE LOWER('{attribute}')
        AND LOWER(b.name) LIKE LOWER('{bucket}')
		ORDER BY 
		  strategy_versions.customer_id,
		  Bucket,
		  Attribute,
	  	  attribute_id,
		  Value,
		  v.id
    ),
    --all of the info you want to see about these products
    products_from_buckets AS ( 
        SELECT
            id AS product_id
            ,external_id
            ,CONCAT_WS('|',name, description) as long_desc
            --,name AS long_desc
        FROM products
        WHERE customer_id = {customer_id}
        AND active = True
        AND EXISTS (
            SELECT
                product_id
                ,bucket_id
            FROM products_buckets AS pb
            WHERE customer_id = {customer_id}
            AND EXISTS (
                SELECT
                    bucket_id
                FROM active_strategy_bucket_atts AS asba
                WHERE asba.bucket_id = pb.bucket_id
            )
        )
    ),
    
    not_curated_yet AS (
        SELECT
            *
        FROM products_from_buckets AS pfb
        WHERE NOT EXISTS (
                SELECT
                    customer_id
                    ,product_id
                FROM curated_product_fields AS cpf
                WHERE name = REGEXP_REPLACE(REGEXP_REPLACE(LOWER('{attribute}'),'\s','_','g'),'\W','','g')
                AND cpf.customer_id = {customer_id}
                AND cpf.product_id = pfb.product_id
        )
    ),
	
	matching AS (
	SELECT
			external_id
            , long_desc
			,regexp_matches(long_desc, '{regex_pattern}') as matches
		FROM not_curated_yet
	),

	d_matches AS (
	SELECT 
        external_id
        , long_desc
        , ARRAY_AGG(DISTINCT _matches) AS matches
	FROM matching,
	UNNEST(matches) _matches 
	GROUP BY
		1
		,2
	)
	
	
	SELECT 
		*
	FROM d_matches 
	