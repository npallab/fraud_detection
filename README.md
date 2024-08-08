
# Fraud Detection in Credit Card Transactions


The objective of this project is to detect potential fraud in credit card transactions using a structured schema and various SQL queries. The schema includes tables for card holders, credit cards, merchants, merchant categories, and transactions. This report provides an overview of the schema and the SQL queries used to identify suspicious activities and patterns that may indicate fraudulent behavior.




## Schema

Card Holder 
```bash
CREATE TABLE card_holder (
    id SERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_card_holder PRIMARY KEY (id)
);
```
Credit Card Table

```bash
CREATE TABLE credit_card (
    card VARCHAR(20) NOT NULL,
    id_card_holder INT NOT NULL,
    CONSTRAINT pk_credit_card PRIMARY KEY (card)
);
```
Merchant Table

```bash
CREATE TABLE merchant (
    id SERIAL NOT NULL,
    name VARCHAR(255) NOT NULL,
    id_merchant_category INT NOT NULL,
    CONSTRAINT pk_merchant PRIMARY KEY (id)
);
```
Merchant Category Table
```bash
CREATE TABLE merchant_category (
    id SERIAL NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_merchant_category PRIMARY KEY (id)
);
```
Transaction Table
``` bash
CREATE TABLE transaction (
    id INT NOT NULL,
    date TIMESTAMP NOT NULL,
    amount FLOAT NOT NULL,
    card VARCHAR(20) NOT NULL,
    id_merchant INT NOT NULL,
    CONSTRAINT pk_transaction PRIMARY KEY (id)
);
```
**SQL Queries and Analysis**

**Unusually High Transactions**

```bash
SELECT * FROM transaction WHERE amount > 1000;
```
This query identifies transactions where the amount exceeds a predefined threshold, indicating potential fraud.

**Multiple Transactions in a Short Time Frame**

```bash
SELECT card, COUNT(id) FROM transaction GROUP BY card;
```
This query counts the number of transactions per card to identify cards with an unusually high frequency of transactions.

**Transactions in Different Locations within a Short Time**

```bash
SELECT t1.*
FROM transaction t1
JOIN transaction t2 ON t1.card = t2.card AND t1.id != t2.id
WHERE t1.date BETWEEN t2.date - INTERVAL 10 MINUTE AND t2.date + INTERVAL 10 MINUTE
AND t1.id_merchant != t2.id_merchant;
```
This query identifies transactions made with the same card in different locations within a short time frame.

**High Transaction Frequency with a Single Merchant**

```bash
SELECT t2.name, COUNT(t1.id) as Transaction_Freq 
FROM transaction t1 
JOIN merchant t2 ON t1.id_merchant = t2.id
GROUP BY t2.name
ORDER BY Transaction_Freq;
```
This query identifies merchants with a high frequency of transactions from different cardholders.

**Transactions with High Amounts within a Specific Merchant Category**

```bash
SELECT * 
FROM transaction t1 
JOIN merchant m1 ON t1.id_merchant = m1.id 
JOIN merchant_category m3 ON m1.id_merchant_category = m3.id
WHERE m3.name = 'restaurant'
ORDER BY amount DESC
LIMIT 5;
```

This query identifies the top transactions by amount within a specific merchant category.

**Transactions by a Cardholder in Different Merchant Categories in a Short Time**

```bash
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
```
This query identifies transactions made by the same cardholder in different merchant categories within a short time frame.

**Total Amount Spent by Each Cardholder**

```bash
SELECT SUM(amount), name 
FROM transaction t1 
JOIN credit_card c1 ON t1.card = c1.card 
JOIN card_holder c2 ON c1.id_card_holder = c2.id 
GROUP BY name;
```
This query calculates the total amount spent by each cardholder.

**Frequent Transactions with Different Merchants within the Same Category**

```bash
SELECT COUNT(amount), m1.id 
FROM transaction t1 
JOIN merchant m1 ON t1.id_merchant = m1.id 
JOIN merchant_category m2 ON m1.id_merchant_category = m2.id
GROUP BY m1.id;
```
This query counts the number of transactions with different merchants within the same category.

**Transactions by a Cardholder with Large Amount Variances**

```bash
SELECT t1.id, t1.card, t1.amount, ABS(t1.amount - t2.amount) as Var 
FROM transaction t1 
JOIN transaction t2 ON t1.id != t2.id AND t1.card = t2.card
ORDER BY Var DESC;
```
This query identifies transactions by the same cardholder with large variances in transaction amounts.

**Transactions Made at Odd Hours**

```bash
SELECT t1.id, t1.amount, HOUR(t1.`date`) as HR 
FROM transaction t1 
WHERE HOUR(t1.`date`) BETWEEN 1 AND 4.5; 
-- Assuming 1 to 4:30 as Odd Hours
```
This query identifies transactions made at unusual hours.

**Transactions Exceeding a Certain Threshold Multiple Times in a Day**

```bash
SELECT COUNT(amount) as CNT, SUM(amount) AS SM, DATE(`date`) as Dt, card 
FROM transaction
GROUP BY card, Dt
ORDER BY CNT DESC;
```
This query identifies cards that exceed a certain transaction threshold multiple times in a day.

**Transactions Made in Quick Succession (within a minute)**

```bash
SELECT t1.id, t1.amount, t1.`date` 
FROM transaction t1 
JOIN transaction t2 ON t1.card = t2.card and t1.id != t2.id
WHERE TIMESTAMPDIFF(SECOND, t1.`date`, t2.`date`) < 30;
```
This query identifies transactions made in quick succession with the same card.

**Large Number of Transactions to the Same Merchant by Different Cardholders**

```bash
SELECT COUNT(DISTINCT t1.card) as Count_of_Unique_cards, t2.name 
FROM transaction t1 
JOIN merchant t2 ON t1.id_merchant = t2.id
GROUP BY t2.name;
```
This query identifies merchants with a large number of transactions from different cardholders.

**Multiple Transactions with Same Amount from Different Merchants**

```bash
SELECT t1.id, t1.amount, t1.card, t1.`date`, t1.id_merchant, m1.name 
FROM transaction t1 
JOIN transaction t2 ON t1.amount = t2.amount AND t1.id_merchant != t2.id_merchant 
JOIN merchant m1 ON t1.id_merchant = m1.id;
```
**This query identifies transactions with the same amount from different merchants.**

**Conclusion**
This project demonstrates the use of SQL queries to detect potential fraudulent activities in credit card transactions. By analyzing transaction patterns, frequencies, and anomalies, we can identify suspicious behaviors that may indicate fraud. The provided schema and queries serve as a foundation for building a robust fraud detection system. Further enhancements can include integrating machine learning models and real-time analytics to improve the accuracy and efficiency of fraud detection.
## Tech Stack

**Warehouse:** Snowflake



