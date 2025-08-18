CREATE DATABASE Retail_Data_analysis_solution


SELECT * FROM Customer1

SELECT * FROM prod_Cat

SELECT * FROM [Transaction]

------------------------------------DATA PREPARATION AND UNDERSTANDING-------------------------

--Ans Q1

SELECT  count (*) AS [COUNT] 
FROM Customer1
UNION
SELECT Count (*) AS [COUNT] 
FROM prod_cat
UNION
SELECT count (*) AS [COUNT] 
FROM [Transaction]


--Ans Q2

SELECT count(DISTINCT (transaction_id)) AS RETURN_COUNT
FROM [Transaction]
WHERE QTY<0

--Ans Q3 [Format Date]

-- Convert the date variables into valid date format From [Transaction] 
-- Convert the date variables into valid date format while import for Customer1, However, 
-- code written below for convert.

SELECT CONVERT(DATE, tran_date,105) AS TRANS_DATE From [Transaction] 
SELECT CONVERT(DATE, DOB,105) AS DOB From Customer1 

---Ans Q4

SELECT DATEDIFF(DD,MIN(CONVERT(DATE, tran_date,105)), 
MAX(CONVERT(DATE, tran_date,105))) AS [DAYS], DATEDIFF(MM,MIN(CONVERT(DATE, tran_date,105)),
MAX(CONVERT(DATE, tran_date,105))) AS MONTHS,
DATEDIFF(YY, MIN(CONVERT(DATE, tran_date,105)),MAX(CONVERT(DATE, tran_date,105))) AS YEARS
FROM [Transaction]


--Ans Q5

SELECT PROD_CAT, PROD_SUBCAT FROM PROD_CAT
WHERE PROD_SUBCAT = 'DIY'

--------------------------------------DATA ANALYSIS-------------------------------
--Ans Q1

SELECT  TOP 1 STORE_TYPE, (Count (transaction_id)) AS TRANS_COUNT
FROM [Transaction]
GROUP BY STORE_TYPE 
ORDER BY TRANS_COUNT DESC 

--Ans Q2

SELECT  GENDER, Count (customer_Id) AS GENDER_COUNT
FROM Customer1
WHERE GENDER IN ('M', 'F')
GROUP BY GENDER

--Ans Q3

SELECT TOP 1 CITY_CODE, Count (customer_Id) AS CUSTOMER_COUNT
FROM Customer1
GROUP BY CITY_CODE
ORDER BY CUSTOMER_COUNT DESC

--Ans Q4

SELECT PROD_CAT, Count (prod_subcat) AS COUNT_PROD_SUBCAT
FROM PROD_CAT
Where PROD_CAT = 'Books'
GROUP BY PROD_CAT

--Ans Q5

SELECT PROD_CAT_CODE, MAX(Qty) AS MAX_PROD
FROM [Transaction]
GROUP BY PROD_CAT_CODE


--Ans Q6

SELECT SUM (cast (total_amt AS float)) AS NET_Revenue
FROM prod_Cat AS P
Join [Transaction] AS T
ON P.prod_cat_code = T.prod_cat_code
AND P.prod_sub_cat_code = T.prod_subcat_code
WHERE Prod_Cat = 'Electronics' OR prod_cat = 'Books'


--Ans Q7
SELECT COUNT(*) AS TOTAL_CUST FROM(
		SELECT CUST_ID, COUNT(DISTINCT(transaction_id)) AS TRANS_COUNT FROM [Transaction]
		WHERE Qty >0
		GROUP BY CUST_ID
		HAVING COUNT(DISTINCT(transaction_id))>10
		) AS X


--Ans Q8

SELECT SUM(cast (total_amt AS float)) AS COMB_REV
FROM prod_Cat AS A
inner join [Transaction] AS B
ON A.prod_cat_code = B.prod_cat_code AND
A.prod_sub_cat_code = B.prod_subcat_code
WHERE prod_cat in ('Electronics', 'Clothing')
AND Store_type = 'Flagship store'
AND QTY > 0

		
--Ans Q9 

SELECT prod_subcat, SUM(cast (total_amt AS float)) AS TOT_REV
FROM Customer1 AS C
JOIN [Transaction] AS T
ON C.customer_Id = T. cust_id
LEFT JOIN Prod_Cat AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE GENDER = 'M' AND prod_cat = 'Electronics'
GROUP BY prod_subcat

--Ans Q10
SELECT X.PROD_SUBCAT, PERCENTAGE_SALES, PERCENTAGE_RETURN FROM(
	SELECT TOP 5 prod_subcat, (SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT))
	AS TOTAL_SALES FROM [TRANSACTION] WHERE QTY>0)) AS PERCENTAGE_SALES FROM prod_Cat AS P
	INNER JOIN [Transaction] AS T
	ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
	WHERE QTY >0
	GROUP BY prod_subcat
	ORDER BY PERCENTAGE_SALES DESC
	) AS X
JOIN
	(SELECT prod_subcat, (SUM(CAST(TOTAL_AMT AS FLOAT))/(SELECT SUM(CAST(TOTAL_AMT AS FLOAT))
	AS TOTAL_SALES FROM [TRANSACTION] WHERE QTY<0)) AS PERCENTAGE_RETURN FROM prod_Cat AS P
	INNER JOIN [Transaction] AS T
	ON P.prod_cat_code = T.prod_cat_code AND P.prod_sub_cat_code = T.prod_subcat_code
	WHERE QTY <0
	GROUP BY prod_subcat
	) AS Y
	ON X.prod_subcat = Y.prod_subcat

------Ans Q11

SELECT  A.CUST_ID, AGE, REVENUE, TRANS_DATE FROM (
SELECT CUST_ID, DATEDIFF(YEAR, DOB, MAX_DATE)AS AGE, REVENUE FROM( 
		SELECT CUST_ID, DOB, MAX (CONVERT(DATE, tran_date, 105)) AS MAX_DATE, SUM(CAST(TOTAL_AMT AS FLOAT)) AS REVENUE FROM Customer1 AS C
		JOIN [Transaction] AS T
		ON C.customer_Id = T.cust_id
		WHERE QTY>0
		GROUP BY cust_id, DOB
		) AS X
		WHERE DATEDIFF(YEAR, DOB, MAX_DATE) BETWEEN 25 AND 35
		) AS A
		JOIN ( 
		SELECT CUST_ID, CONVERT(DATE, TRAN_DATE, 105) AS TRANS_DATE FROM [Transaction]
		GROUP BY CUST_ID, CONVERT(DATE, TRAN_DATE, 105)
		HAVING CONVERT (DATE, tran_date, 105)>= (SELECT (DATEADD(DAY, -30, MAX (CONVERT(DATE, tran_date, 105)))) AS 
		CUTOFF_DATE FROM [Transaction])
		)AS B 
		ON A.cust_id = B.cust_id

--Ans Q12


SELECT TOP 1 PROD_CAT_CODE, SUM ([RETURNS]) AS TOT_RETURNS FROM (
	SELECT PROD_CAT_CODE, CONVERT(DATE, TRAN_DATE, 105)  AS TRANS_DATE, SUM (CAST (Qty AS float)) AS [RETURNS] FROM [Transaction]
	WHERE QTY<0
	GROUP BY PROD_CAT_CODE, CONVERT(DATE, TRAN_DATE, 105)
	HAVING CONVERT (DATE, tran_date, 105)>= (SELECT (DATEADD(DAY, -30, MAX (CONVERT(DATE, tran_date, 105)))) AS 
	CUTOFF_DATE FROM [Transaction]))
	AS X
	GROUP BY PROD_CAT_CODE
	ORDER BY TOT_RETURNS
	
	--Ans Q13

	SELECT Store_type, SUM (CAST (total_amt AS FLOAT)) AS REVENUE, SUM (CAST (Qty AS float)) AS QUANTITY 
	FROM [Transaction]
	WHERE Qty>0
	GROUP BY Store_type
	ORDER BY REVENUE DESC, QUANTITY DESC


--Ans Q14

SELECT PROD_CAT_CODE, avg (CAST(TOTAL_AMT AS FLOAT)) AS AVE_REV FROM [Transaction]
WHERE Qty>0
GROUP by PROD_CAT_CODE
HAVING avg (cast (TOTAL_AMT AS FLOAT))>= (SELECT avg(CAST(TOTAL_AMT AS FLOAT)) FROM [TRANSACTION] WHERE QTY >0)

--Ans Q15

SELECT PROD_SUBCAT_CODE, SUM (CAST (TOTAL_AMT AS FLOAT)) AS REVENUE, AVG (CAST (TOTAL_AMT AS FLOAT)) AS AVG_REVENUE
FROM [Transaction]
WHERE QTY > 0 AND PROD_CAT_CODE IN (SELECT TOP 5 PROD_CAT_CODE FROM [Transaction]
									WHERE QTY >0 
									GROUP BY PROD_CAT_CODE
									ORDER BY SUM (CAST (QTY AS FLOAT)) DESC)
GROUP BY PROD_SUBCAT_CODE
