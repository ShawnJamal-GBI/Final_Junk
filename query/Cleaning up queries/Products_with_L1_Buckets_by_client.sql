WITH 

	bav AS (
		SELECT DISTINCT
		  strategy_versions.customer_id,
		  b.name AS Bucket,
          a.snake_case_name AS attribute_join_key,
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
		WHERE strategy_versions.customer_id = {customer_id} -- param: customer Id
		      AND sba.status = 'OPT_IN'
		      AND sbva.status = 'OPT_IN'
		      AND strategy_versions.active = True
			  AND a.snake_case_name = '{attribute}'
			  AND b.name IN ({bucket_name})
		ORDER BY 
		  strategy_versions.customer_id,
		  Bucket,
		  Attribute,
	  	  attribute_id,
		  Value,
		  v.id
	),

    attribute_and_value AS (
		SELECT
		    name as attribute_name,
			value, 
             product_id
		FROM curated_product_fields
		WHERE customer_id = {customer_id} 
        AND name='{attribute}'
	),
    
	l1_bucket AS (
		SELECT 
			id AS l1_id
			,name AS l1_name
			,parent_hierarchy AS l1_parent_hierarchy
		FROM buckets
		WHERE LOWER(name) LIKE ({bucket_name})
		AND CARDINALITY(parent_hierarchy) <= 3
		AND parent_hierarchy[1]= 6595
	),
	
	child_buckets AS (
		SELECT
			l1_name
			,b.id AS bucket_id
			,b.name AS bucket
			,parent_hierarchy
		FROM buckets AS b
		INNER JOIN l1_bucket
			ON l1_id = any(parent_hierarchy)
	),
	
	
	available_products AS (
		SELECT
			l1_name
			,bucket
			,product_id
			,cb.bucket_id
		FROM products_buckets
		INNER JOIN child_buckets AS cb
			USING(bucket_id)
		WHERE customer_id = {customer_id}
		
	)
	
	
	SELECT
		l1_name
		,bucket
		,product_id
		,name AS product_name
		,description
		,image_url
		,url
	FROM products
	INNER JOIN available_products AS ap
		ON product_id = products.id
    LEFT JOIN attribute_and_value
        USING(product_id)
    LEFT JOIN bav
        USING(Bucket)
	WHERE customer_id = {customer_id}
	AND active = True