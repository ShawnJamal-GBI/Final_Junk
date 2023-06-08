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
SELECT * FROM (
SELECT *, DENSE_RANK() OVER (ORDER BY z___min_rank) as z___pivot_row_rank, RANK() OVER (PARTITION BY z__pivot_col_rank ORDER BY z___min_rank) as z__pivot_col_ordering, CASE WHEN z___min_rank = z___rank THEN 1 ELSE 0 END AS z__is_highest_ranked_cell FROM (
SELECT *, MIN(z___rank) OVER (PARTITION BY "strategy_vs_curation.attribute","strategy_vs_curation.question_type","strategy_vs_curation.value") as z___min_rank FROM (
SELECT *, RANK() OVER (ORDER BY "strategy_vs_curation.attribute" ASC, z__pivot_col_rank, "strategy_vs_curation.question_type", "strategy_vs_curation.value") AS z___rank FROM (
SELECT *, DENSE_RANK() OVER (ORDER BY CASE WHEN "strategy_vs_curation.source" IS NULL THEN 1 ELSE 0 END, "strategy_vs_curation.source") AS z__pivot_col_rank FROM (
SELECT
    strategy_vs_curation."source"  AS "strategy_vs_curation.source",
    strategy_vs_curation."attribute"  AS "strategy_vs_curation.attribute",
    strategy_vs_curation."question_type"  AS "strategy_vs_curation.question_type",
    strategy_vs_curation."value"  AS "strategy_vs_curation.value",
    COUNT(*) AS "strategy_vs_curation.count"
FROM strategy_vs_curation
WHERE ((( strategy_vs_curation."attribute"  ) NOT LIKE 'q^_ml^_%' ESCAPE '^' OR ( strategy_vs_curation."attribute"  ) IS NULL))
GROUP BY
    1,
    2,
    3,
    4) ww
) bb WHERE z__pivot_col_rank <= 16384
) aa
) xx
) zz
 WHERE (z__pivot_col_rank <= 50 OR z__is_highest_ranked_cell = 1) AND (z___pivot_row_rank <= 50000 OR z__pivot_col_ordering = 1) ORDER BY z___pivot_row_rank