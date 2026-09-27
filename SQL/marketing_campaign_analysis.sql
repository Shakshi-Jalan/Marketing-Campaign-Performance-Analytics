-- 1. Session-Level Data Inspection

SELECT
  fullVisitorId,
  visitId,
  date,
  channelGrouping,
  trafficSource.source AS source,
  trafficSource.medium AS medium,
  trafficSource.campaign AS campaign,
  device.deviceCategory AS device,
  totals.visits,
  totals.pageviews,
  totals.transactions,
  totals.totalTransactionRevenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170101`;


-- 2. Source & Medium Performance

SELECT
  trafficSource.source AS source,
  trafficSource.medium AS medium,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170101`
GROUP BY
  source,
  medium
ORDER BY
  revenue DESC;


-- 3. Campaign Performance (January 1, 2017)

SELECT
  trafficSource.campaign AS campaign,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_20170101`
WHERE
  trafficSource.campaign IS NOT NULL
GROUP BY
  campaign
ORDER BY
  revenue DESC;


-- 4. Full January Channel Performance

SELECT
  channelGrouping AS channel,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  channel
ORDER BY
  revenue DESC;


-- 5. Device Performance

SELECT
  device.deviceCategory AS device,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  device
ORDER BY
  revenue DESC;


-- 6. Daily Revenue & Conversion Trend

SELECT
  PARSE_DATE('%Y%m%d', date) AS day,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  day
ORDER BY
  day;


-- 7. Day of Week Performance

SELECT
  FORMAT_DATE(
    '%A',
    PARSE_DATE('%Y%m%d', date)
  ) AS day_of_week,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    SUM(totals.totalTransactionRevenue) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  day_of_week
ORDER BY
  CASE day_of_week
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
  END;


-- 8. Revenue per Session by Channel

SELECT
  channelGrouping AS channel,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000,
    2
  ) AS revenue,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000 / COUNT(*),
    2
  ) AS revenue_per_session
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  channel
ORDER BY
  revenue_per_session DESC;


-- 9. Conversion Efficiency by Channel

SELECT
  channelGrouping AS channel,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  channel
HAVING
  SUM(totals.transactions) IS NOT NULL
ORDER BY
  conversion_rate DESC;


-- 10. Overall KPIs

SELECT
  COUNT(*) AS total_sessions,
  SUM(totals.transactions) AS total_transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS overall_conversion_rate,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000,
    2
  ) AS total_revenue,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000 / COUNT(*),
    2
  ) AS revenue_per_session
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131';


-- 11. Full January Campaign Performance

SELECT
  COALESCE(trafficSource.campaign, '(not set)') AS campaign,
  COUNT(*) AS sessions,
  SUM(totals.transactions) AS transactions,
  ROUND(
    SUM(totals.transactions) / COUNT(*) * 100,
    2
  ) AS conversion_rate,
  ROUND(
    COALESCE(SUM(totals.totalTransactionRevenue), 0) / 1000000,
    2
  ) AS revenue
FROM
  `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
  _TABLE_SUFFIX BETWEEN '20170101' AND '20170131'
GROUP BY
  campaign
ORDER BY
  revenue DESC;
