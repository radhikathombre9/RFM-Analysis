use RFM
DECLARE @today_date as DATE = '2021-01-01';
with base as (
select 
       _CustomerID as customer_id,
	   --Max(OrderDate) as most_recently_purchase_date,
	   DATEDIFF(day, max(OrderDate), @today_date) as recency_score,
	   COUNT(OrderNumber) as frequency_score,
	 CAST (sum([Unit Price]-([Unit Price]*[Discount Applied])-[Unit Cost]) as DECIMAL(16,0) ) monetary_score
from Sales_Data
GROUP BY _CustomerID
),
RFM_Scores AS
(
select customer_id, 
       recency_score,
	   frequency_score,
	   monetary_score,
     NTILE(5) OVER (ORDER BY recency_score DESC) as R,
	 NTILE(5) OVER (ORDER BY frequency_score ASC) as F,
	 NTILE(5) OVER (ORDER BY monetary_score ASC) as M
from base
)
SELECT 
(R + F + M) / 3 AS RFM_Group,
COUNT(RFM.customer_ID) as Customer_count,
SUM(base.monetary_score) as Total_Revenue,
CAST(SUM(base.monetary_score) / COUNT(rfm.customer_id) AS DECIMAL(12,2)) AS AVG_Revenue_per_customer
FROM RFM_Scores as rfm
inner join base on base.customer_id = rfm.customer_id
GROUP BY (R + F + M) / 3
ORDER BY RFM_Group desc

--SELECT customer_id,
--       CONCAT_WS('-',R,F,M) AS RFM_cell,
--	   CAST((CAST(R AS FLOAT) + F + M)/3 AS DECIMAL(16,2)) AS AVG_RFM_Scores
--FROM RFM_Scores


