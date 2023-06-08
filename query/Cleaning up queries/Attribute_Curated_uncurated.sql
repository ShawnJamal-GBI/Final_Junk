WITH 

	bav AS (
		SELECT DISTINCT
		  strategy_versions.customer_id, --
		  b.name AS Bucket, --strategy buckets
          a.snake_case_name AS attribute_join_key, --attributes
		  a.name AS Attribute, --attributes
		  attribute_id,
		  v.id, --values
		  v.name AS Value
		FROM buckets AS b
		  JOIN strategy_buckets AS sb ON b.id = sb.bucket_id --Strategy buckets
		  JOIN strategy_buckets_attributes AS sba ON sb.id = sba.strategy_bucket_id --attributes
		  JOIN strategy_buckets_attributes_values AS sbva ON sba.id = sbva.strategy_buckets_attribute_id--values
		  JOIN strategy_versions ON sb.strategy_version_id = strategy_versions.id --strategy versions
		  JOIN attributes AS a ON sba.attribute_id = a.id
		  JOIN values AS v ON sbva.value_id = v.id
        
		-- conditions
		WHERE strategy_versions.customer_id = {customer_id} -- param: customer Id
		      AND sba.status = 'OPT_IN' --What is this?-client uses to go into system
		      AND sbva.status = 'OPT_IN'
		      AND strategy_versions.active = True --what is this?
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
		WHERE CARDINALITY(parent_hierarchy) <= 3 --V2, another bucket, another bucket
		AND parent_hierarchy[1]= 6595 --V2 ID
	),
	
	child_buckets AS (  --same above except merge heiarchy
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
	WHERE products.customer_id = {customer_id}
	AND active = True