--Data Quality Check
SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa

--Reformat the Data
SELECT item_id,
       test_a AS test_assignment,
       'item_test_1' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_b AS test_assignment,
       'item_test_2' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_c AS test_assignment,
       'item_test_3' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_d AS test_assignment,
       'item_test_4' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_e AS test_assignment,
       'item_test_5' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_f AS test_assignment,
       'item_test_6' AS test_number,
       CAST('2013-01-05 00:00:00' AS timestamp) AS test_start_date
FROM dsv1069.final_assignments_qa

--Compute Order Binary
SELECT
  order_binary.test_assignment,
  COUNT(DISTINCT order_binary.item_id) AS num_orders,
  SUM(order_binary.orders_30d) AS orders_30d
FROM
  (SELECT
    final_assignments.item_id,
    final_assignments.test_assignment,
    MAX(CASE WHEN DATE(orders.created_at) - DATE(final_assignments.test_start_date) >= 1 
          AND DATE(orders.created_at) - DATE(final_assignments.test_start_date) <= 30
          THEN 1
          ELSE 0 END)                                       AS orders_30d
  FROM dsv1069.final_assignments
  LEFT OUTER JOIN dsv1069.orders
  ON orders.item_id = final_assignments.item_id
  WHERE test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment
    ) order_binary
GROUP BY order_binary.test_assignment

--Compute View Item Metrics
SELECT
  view_binary.test_assignment,
  COUNT(DISTINCT view_binary.item_id) AS num_views,
  SUM(view_binary.views_30d) AS v30,
  AVG(view_binary.views_30d) AS avg_view_30d
FROM
  (SELECT
    final_assignments.item_id,
    final_assignments.test_assignment,
    MAX(CASE WHEN DATE(view_item_events.event_time) - DATE(final_assignments.test_start_date) >= 1 
          AND DATE(view_item_events.event_time) - DATE(final_assignments.test_start_date) <= 30
          THEN 1
          ELSE 0 END)                                       AS views_30d
  FROM dsv1069.final_assignments
  LEFT OUTER JOIN dsv1069.view_item_events
  ON view_item_events.item_id = final_assignments.item_id
  WHERE test_number = 'item_test_2'
  GROUP BY 
    final_assignments.item_id,
    final_assignments.test_assignment
  ORDER BY item_id) view_binary
GROUP BY view_binary.test_assignment