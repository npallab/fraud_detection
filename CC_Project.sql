
--Unusually High Transactions:
SELECT * FROM transaction WHERE amount >1000

--Multiple Transactions in a Short Time Frame:
SELECT card,count(id) from transaction
GROUP BY card;


--Transactions in Different Locations within a Short Time:
SELECT t1.*
FROM transaction t1
JOIN transaction t2 ON t1.card = t2.card AND t1.id != t2.id
WHERE t1.date BETWEEN t2.date - INTERVAL 10 MINUTE AND t2.date + INTERVAL 10 MINUTE
AND t1.id_merchant != t2.id_merchant;

--High Transaction Frequency with a Single Merchant:
SELECT t2.name, COUNT(t1.id) as Transaction_Freq from transaction t1 JOIN merchant t2 ON t1.id_merchant=t2.id
GROUP BY t2.name
ORDER BY Transaction_Freq 

--Transactions with High Amounts within a Specific Merchant Category:

SELECT * from transaction t1 JOIN merchant m1  ON t1.id_merchant = m1.id JOIN merchant_category m3 ON m1.id_merchant_category=m3.id
WHERE m3.name='restaurant'
ORDER BY amount DESC
LIMIT 5

--Transactions by a Cardholder in Different Merchant Categories in a Short Time:
SELECT ch.name, t1.date, m1.name as merchant_name_1, mc1.name as category_name_1, m2.name as merchant_name_2, mc2.name as category_name_2
FROM transaction t1
JOIN transaction t2 ON t1.card = t2.card AND t1.id != t2.id
JOIN credit_card cc ON t1.card = cc.card
JOIN card_holder ch ON cc.id_card_holder = ch.id
JOIN merchant m1 ON t1.id_merchant = m1.id
JOIN merchant m2 ON t2.id_merchant = m2.id
JOIN merchant_category mc1 ON m1.id_merchant_category = mc1.id
JOIN merchant_category mc2 ON m2.id_merchant_category = mc2.id
WHERE t1.date BETWEEN t2.date - INTERVAL 10 MINUTE AND t2.date + INTERVAL 10 MINUTE
AND mc1.id != mc2.id;

--Total Amount Spent by Each Cardholder :
SELECT sum(amount),name from transaction t1 JOIN credit_card c1 ON t1.card=c1.card JOIN card_holder c2 ON c1.id_card_holder=c2.id 
GROUP BY name;

--Frequent Transactions with Different Merchants within the Same Category:

SELECT count(amount),m1.id from transaction t1 JOIN merchant m1 ON t1.id_merchant=m1.id JOIN merchant_category m2 ON m1.id_merchant_category=m2.id
GROUP BY m1.id

--Transactions by a Cardholder with Large Amount Variances:

SELECT t1.id,t1.card,t1.amount,ABS(t1.amount-t2.amount) as Var FROM transaction t1 JOIN transaction t2 ON t1.id != t2.id AND t1.card=t2.card
ORDER BY Var DESC

--Transactions Made at Odd Hours:

SELECT t1.id,t1.amount,HOUR(t1.`date`) as HR from transaction t1 WHERE HOUR(t1.`date`) BETWEEN 1 and 4.5 -- Assuming 1 to 4:30 as Odd HOUR_SECOND

--Transactions Exceeding a Certain Threshold Multiple Times in a Day:
SELECT COUNT(amount) as CNT,SUM(amount) AS SM,DATE(`date`) as Dt, card from transaction
GROUP BY card,Dt
ORDER BY CNT DESC


--Transactions Made in Quick Succession (within a minute):
SELECT t1.id,t1.amount,t1.`date` FROM transaction t1 JOIN transaction t2 ON t1.card=t2.card and t1.id != t2.id
WHERE TIMESTAMPDIFF(SECOND,t1.`date`,t2.`date`)<30

--Large Number of Transactions to the Same Merchant by Different Cardholders:
SELECT COUNT(DISTINCT t1.card ) as Count_of_Unique_cards,t2.name from transaction t1 JOIN merchant t2 ON t1.id_merchant=t2.id
group by t2.name

--Multiple Transactions with Same Amount from Different Merchants:
SELECT t1.id,t1.amount,t1.card,t1.`date`,t1.id_merchant,m1.name from transaction t1 JOIN transaction t2 ON t1.amount=t2.amount AND t1.id_merchant !=t2.id_merchant JOIN merchant m1 ON t1.id_merchant=m1.id


