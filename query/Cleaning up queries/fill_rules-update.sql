/*
  Description: Gets all of the bucket, attribute and value names for all active stategies. 
*/
WITH 
	bav AS (
		SELECT DISTINCT
		  strategy_versions.customer_id,
		  b.id AS bucket_id,
		  b.name AS Bucket,
  		  attribute_id,
		  a.name AS Attribute,
		  v.id AS value_ids,
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
		ORDER BY 
		  strategy_versions.customer_id,
		  Bucket,
		  Attribute,
		  Value
	),
	 

	detail AS (
	SELECT DISTINCT
		--bucket_id,
		-- bucket,
		bav.attribute_id,
		attribute,
		REGEXP_REPLACE(gl_a.guideline,'<.+?>','','g') AS attribute_guideline,
		value_ids,
		value AS values,
		gl_v.guideline AS value_guideline
	FROM bav
	LEFT JOIN guidelines AS gl_a
		USING(customer_id,attribute_id)
	LEFT JOIN guidelines AS gl_v
		USING(customer_id,value_id)
	WHERE LOWER(attribute) LIKE REGEXP_REPLACE(LOWER('{attribute}'),' ','_','g')
	AND NOT EXISTS 
		(
		SELECT
			value_id
		FROM curation_rules
		INNER JOIN curation_rule_attributes AS cra
			ON curation_rule_id = curation_rules.id
		WHERE curation_rules.customer_id = {customer_id}
		AND cra.attribute_id = bav.attribute_id
		AND value_id = value_ids
		AND enabled = True
		)
	ORDER BY value ASC
	)
	
	
	SELECT *
	FROM detail