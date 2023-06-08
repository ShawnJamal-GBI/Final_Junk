WITH tasks_by_resolution AS (WITH
        rule_tasks AS (
          SELECT
            DATE_TRUNC('MONTH',updated_at) AS date_time
            ,customer_id
            ,( COUNT(curation_tasks.id) FILTER(WHERE LOWER(resolution) LIKE '%rules%') + COUNT(curation_tasks.id) FILTER(WHERE LOWER(resolution) LIKE '%family%') ) AS rules_curation
            ,COUNT(curation_tasks.id) FILTER(WHERE LOWER(resolution) LIKE '%bulk%') AS bulk
          FROM curation_tasks
          WHERE type != 'classification'
          AND ((( DATE(updated_at) ) >= ((SELECT DATE_TRUNC('day', DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago'))))) AND ( DATE(updated_at) ) < ((SELECT DATE_TRUNC('day', (DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago')) + (1 || ' year')::INTERVAL))))))
          GROUP BY
            1
           ,2
        ),

        external_tasks AS (
          SELECT
            DATE_TRUNC('MONTH',stopped_at) AS date_time
            ,customer_id
            ,COUNT(curation_tasks.id) AS human_external
          FROM curation_tasks
        WHERE (curated_product_fields."customer_id" ) = '{customer_id}')
--         AND (curated_product_fields."curated_at") >= '{dateszs}'
--         AND (curated_product_fields."curated_at") <= '{dateszsz}'
          AND total_time > 0
          AND total_time IS NOT NULL
          AND curated_by IS NOT NULL
          -- AND resolution != 'bulk'
          -- AND resolution != 'rules'
          GROUP BY
            1
           ,2
        ),

        internal_tasks AS (
          SELECT
            DATE_TRUNC('MONTH',DATE(updated_at))  AS date_time
            ,customer_id
            ,CASE
              WHEN job_id IS NULL AND curation_task_id IS NULL THEN 'Manual Update'
              WHEN job_id IS NOT NULL AND curation_task_id IS NULL THEN 'Upload'
              ELSE NULL END AS resolution
            ,'GroupBy' AS team
            ,CONCAT(CAST(id AS VARCHAR),'-',CAST(product_id AS VARCHAR) ) AS tasks
          FROM curated_product_fields
          WHERE ((( DATE(updated_at) ) >= ((SELECT DATE_TRUNC('day', DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago'))))) AND ( DATE(updated_at) ) < ((SELECT DATE_TRUNC('day', (DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago')) + (1 || ' year')::INTERVAL))))))
        ),

        data_agg AS (
          SELECT
            DATE_TRUNC('MONTH',date_time) AS date_time
            ,customer_id
            ,COUNT(distinct tasks) FILTER(WHERE resolution = 'Upload') AS upload
            ,COUNT(distinct tasks) FILTER(WHERE resolution = 'Manual Update') AS manual_update
          FROM internal_tasks
          GROUP BY
            1
            ,customer_id
        )

        SELECT
          date_time
          ,customer_id
          ,rules_curation AS "Rules Curation"
          ,bulk AS "Bulk"
          ,upload AS"Upload"
          ,manual_update AS "Manual Update"
          ,human_external AS "Human External"
        FROM data_agg
        LEFT JOIN rule_tasks
          USING(date_time, customer_id)
        LEFT JOIN external_tasks
          USING(date_time, customer_id)
       )
  ,  task_source AS (SELECT
    (DATE_TRUNC('day', curated_product_fields."updated_at" )) AS "updated_date",
    curated_product_fields."customer_id"  AS "customer_id",
    customers."name"  AS "customer",
    attributes."name"  AS "attribute",
    curated_product_fields."name"  AS "snake_case_name",
    curated_product_fields."value"  AS "value",
    CASE
WHEN curation_tasks.status = 'complete'
        AND NULLIF(curation_tasks.total_time,0) IS NOT NULL
        AND curation_tasks.curated_by IS NOT NULL  THEN '0'
ELSE '1'
END AS "curation_tasks.task_source__sort_",
    CASE
WHEN curation_tasks.status = 'complete'
        AND NULLIF(curation_tasks.total_time,0) IS NOT NULL
        AND curation_tasks.curated_by IS NOT NULL  THEN 'External'
ELSE 'Internal'
END AS "task_source",
    curation_tasks."product_id"  AS "product_id",
    curated_product_fields."curation_task_id"  AS "curation_task_id"
FROM public.curated_product_fields  AS curated_product_fields
LEFT JOIN public.curation_tasks  AS curation_tasks ON (curated_product_fields."curation_task_id") = (curation_tasks."id")
INNER JOIN public.products  AS products ON (curated_product_fields."product_id") = (products."id")
INNER JOIN public.customers  AS customers ON (products."customer_id") = (customers."id")
LEFT JOIN public.attributes  AS attributes ON (curated_product_fields."name") = (attributes."snake_case_name")
WHERE ((( curated_product_fields."updated_at"  ) >= ((SELECT DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago')))) AND ( curated_product_fields."updated_at"  ) < ((SELECT (DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago')) + (1 || ' year')::INTERVAL)))))
GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10)
SELECT
    (TO_CHAR(DATE_TRUNC('month', tasks_by_resolution."date_time" ), 'YYYY-MM')) AS "tasks_by_resolution.completion_month",
    task_source.snake_case_name AS "task_source.snake_case_name",
    COALESCE(CAST( ( SUM(DISTINCT (CAST(FLOOR(COALESCE( (tasks_by_resolution."Rules Curation" + tasks_by_resolution."Bulk" + tasks_by_resolution."Upload" + tasks_by_resolution."Manual Update") ,0)*(1000000*1.0)) AS DECIMAL(65,0))) + ('x' || MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar))::bit(64)::bigint::DECIMAL(65,0)  *18446744073709551616 + ('x' || SUBSTR(MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar),17))::bit(64)::bigint::DECIMAL(65,0) ) - SUM(DISTINCT ('x' || MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar))::bit(64)::bigint::DECIMAL(65,0)  *18446744073709551616 + ('x' || SUBSTR(MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar),17))::bit(64)::bigint::DECIMAL(65,0)) )  AS DOUBLE PRECISION) / CAST((1000000*1.0) AS DOUBLE PRECISION), 0) AS "tasks_by_resolution.internal",
    COALESCE(CAST( ( SUM(DISTINCT (CAST(FLOOR(COALESCE( tasks_by_resolution."Human External"  ,0)*(1000000*1.0)) AS DECIMAL(65,0))) + ('x' || MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar))::bit(64)::bigint::DECIMAL(65,0)  *18446744073709551616 + ('x' || SUBSTR(MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar),17))::bit(64)::bigint::DECIMAL(65,0) ) - SUM(DISTINCT ('x' || MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar))::bit(64)::bigint::DECIMAL(65,0)  *18446744073709551616 + ('x' || SUBSTR(MD5( CONCAT(tasks_by_resolution.date_time, tasks_by_resolution.customer_id) ::varchar),17))::bit(64)::bigint::DECIMAL(65,0)) )  AS DOUBLE PRECISION) / CAST((1000000*1.0) AS DOUBLE PRECISION), 0) AS "tasks_by_resolution.human_external"
FROM tasks_by_resolution
LEFT JOIN task_source ON (tasks_by_resolution."customer_id") = '{customer_id}'
GROUP BY
    (DATE_TRUNC('month', tasks_by_resolution."date_time" )),
    2
ORDER BY
    1
