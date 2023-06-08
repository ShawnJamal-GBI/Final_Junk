                              
WITH strategy_vs_curation AS (WITH
        attribute_and_value AS (
          SELECT
              name as attribute_name,
            regexp_split_to_array(
              regexp_replace(value,
                    '(\[|\"|\])',
                    '',
                    'g'),','
                    ) as nested_value_name
          FROM curated_product_fields
          WHERE (customer_id = '{customer_id}')
          AND value != 'n/a'
        ),

        unique_attribute_value_curated AS (
          SELECT DISTINCT
            'curation' AS source,
            attribute_name AS attribute,
            value_name AS value
          FROM attribute_and_value,
          UNNEST(nested_value_name) as value_name
        ),


        unique_attribute_value_strategy AS (
          SELECT DISTINCT
            'strategy' AS source,
            a.snake_case_name AS Attribute,
            v.name AS Value,
            question_type
          FROM buckets AS b
          JOIN STRATEGY_BUCKETS AS SB ON
            B.ID = SB.BUCKET_ID
          JOIN STRATEGY_BUCKETS_ATTRIBUTES AS SBA ON
            SB.ID = SBA.STRATEGY_BUCKET_ID
          JOIN STRATEGY_VERSIONS ON
            SB.STRATEGY_VERSION_ID = STRATEGY_VERSIONS.ID
          JOIN ATTRIBUTES AS A ON
            SBA.ATTRIBUTE_ID = A.ID
          LEFT JOIN strategy_buckets_attributes_values AS sbva
            ON sba.id = sbva.strategy_buckets_attribute_id
          LEFT JOIN values AS v
            ON sbva.value_id = v.id
          -- conditions
          WHERE (strategy_versions.customer_id = '{customer_id}')
              AND sba.status = 'OPT_IN'
             -- AND sbva.status IN ('OPT_IN', NULL)
             AND strategy_versions.active = True
        ),

        full_joins As (
          SELECT DISTINCT
            CASE
            WHEN (uavs.source IS NOT NULL AND uavc.source IS NOT NULL) THEN 'Strategy & Curation'
            ELSE coalesce(uavs.source, uavc.source) END AS source
            ,attribute
            ,value
          FROM unique_attribute_value_strategy AS uavs
           FULL OUTER JOIN unique_attribute_value_curated AS uavc
            USING(attribute,value)
        )

        SELECT DISTINCT
          qt.question_type,
          full_joins.*
        FROM full_joins
        LEFT JOIN unique_attribute_value_strategy AS qt
          USING(attribute)
        WHERE full_joins.value IS NOT NULL
        ORDER BY attribute ASC , full_joins.value ASC
       )
SELECT
    strategy_vs_curation."attribute"  AS "attribute",
    strategy_vs_curation."question_type"  AS "question_type",
    strategy_vs_curation."value"  AS "value",
    strategy_vs_curation."source"  AS "source",
    COUNT(*) AS "count"
FROM strategy_vs_curation
WHERE LENGTH("question_type" ) <> 0 AND ((( "attribute"  ) NOT LIKE 'q^_ml^_%' ESCAPE '^' OR ( "attribute"  ) IS NULL)) AND ("question_type" ) IS NOT NULL AND ("question_type" ) NOT LIKE '%freetext%'
GROUP BY
    1,
    2,
    3,
    4
ORDER BY
    4,
    5