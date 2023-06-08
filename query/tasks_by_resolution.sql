



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
          WHERE ((( DATE(stopped_at) ) >= ((SELECT DATE_TRUNC('day', DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago'))))) AND ( DATE(stopped_at) ) < ((SELECT DATE_TRUNC('day', (DATE_TRUNC('year', DATE_TRUNC('day', CURRENT_TIMESTAMP AT TIME ZONE 'America/Chicago')) + (1 || ' year')::INTERVAL))))))
          AND status = 'complete'
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
SELECT
    COALESCE(SUM(tasks_by_resolution."Human External" ), 0) AS "tasks_by_resolution.human_external",
    COALESCE(SUM((tasks_by_resolution."Rules Curation" + tasks_by_resolution."Bulk" + tasks_by_resolution."Upload" + tasks_by_resolution."Manual Update")), 0) AS "tasks_by_resolution.internal"
FROM tasks_by_resolution