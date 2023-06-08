WITH 
	bav AS (
		SELECT DISTINCT 
			b.id AS bucket_id
			,A.NAME AS attribute
			,B.NAME AS bucket
			,question_type
		FROM BUCKETS AS B
		JOIN strategy_buckets AS SB ON
			b.id = sb.bucket_id
		JOIN strategy_buckets_attributes AS SBA ON
			sb.id = sba.strategy_bucket_id
		JOIN strategy_versions ON
			sb.strategy_version_id = strategy_versions.id
		JOIN ATTRIBUTES AS A ON
			sba.attribute_id = a.id
		WHERE strategy_versions.customer_id = 5
		AND SBA.STATUS = 'OPT_IN'
		AND sb.active = TRUE
		-- AND LOWER(a.name) LIKE '%connect%port%'
		ORDER BY 
			attribute
			,bucket
	),
	attribute_buckets_products AS (
		SELECT
			attribute
			,bucket
			,product_id
		FROM bav
		INNER JOIN (
			SELECT
				bucket_id,
				product_id
			FROM products_buckets
			WHERE customer_id = 5
			) AS pb
		USING(bucket_id)
	),
	remaining_curation AS (
		SELECT
			attribute
			,bucket
			,product_id
		FROM attribute_buckets_products
		WHERE NOT EXISTS (
			SELECT
			    product_id
			    ,name
			FROM curated_product_fields AS cpf
			WHERE cpf.customer_id = 5
			-- AND LOWER(name) LIKE '%connect%port%'
			AND attribute_buckets_products.product_id = cpf.product_id
		)
	), 
	available_attributes AS (
		SELECT
			bucket
			,ARRAY_AGG(attribute ORDER BY attribute ASC) AS attributes
			,external_id
			,name
			,description 
			-- ,custom_fields
			-- ,CONCAT_WS(' | ',name ,description, custom_fields) AS long_desc
		FROM products
		INNER JOIN (
			SELECT
				bucket
				,attribute
				,product_id
			FROM remaining_curation
			) AS rc 
			ON product_id = products.id
		WHERE customer_id = 115
		AND active = True
		GROUP BY
			bucket
			,attribute
			,external_id
			,name
			,description 
	)
	SELECT *
	FROM available_attributes
-- 	WHERE 'Origin' = ANY(attributes)