
--QUESTION 1
SELECT COUNT(u_id)
FROM users;


--QUESTION 2
SELECT * FROM transfers;

SELECT COUNT(transfer_id)
FROM transfers
WHERE send_amount_currency = 'CFA';


--QUESTION 3
SELECT COUNT(DISTINCT u_id)
FROM transfers
WHERE send_amount_currency = 'CFA';


--QUESTION 4
SELECT * FROM agent_transactions;

SELECT COUNT (atx_id)
FROM agent_transactions 
WHERE when_created BETWEEN '2018-01-01' AND '2018-12-31';


--QUESTION 5
WITH agentwithdrawers AS 
(SELECT COUNT(agent_id) AS netwithdrawers FROM agent_transactions
HAVING COUNT(amount) IN (SELECT COUNT(amount) FROM agent_transactions WHERE amount > -1
AND amount!=0 HAVING COUNT(amount)>(SELECT COUNT(amount)
FROM agent_transactions WHERE AMOUNT< 1 AND amount !=0)))
SELECT netwithdrawers FROM agentwithdrawers;


--QUESTION 6
SELECT COUNT(atx.atx_id) AS "atx volume city summary" , ag.city
FROM agent_transactions AS atx LEFT OUTER JOIN agents
AS ag ON atx.atx_id = ag.agent_id
WHERE atx.when_created BETWEEN NOW():: DATE-EXTRACT (DOW FROM NOW()):: INTEGER-7
AND NOW ():: DATE-EXTRACT (DOW FROM NOW()):: INTEGER 
GROUP BY ag.city;


--QUESTION 7
SELECT city, volume, country INTO atx_volume_city_summary_with_country
FROM (SELECT agents.city AS city,agents.country AS country, COUNT(atx.atx_id) AS Volume 
FROM agents INNER JOIN agent_transactions AS atx ON agents.agent_id=atx.agent_id
WHERE (atx.when_created > (NOW()-INTERVAL '1 week')) 
GROUP BY agents.country, agents.city)
AS atx_volume_city_summary_with_country;


--QUESTION 8
SELECT w.ledger_location AS "Country", tn.send_amount_currency AS "kind",
SUM(tn.send_amount_scalar) AS "Volume"
FROM transfers AS tn INNER JOIN wallets AS w ON tn.transfer_id = w.wallet_id
WHERE tn.when_created = CURRENT_DATE-INTERVAL '1 week'
GROUP BY w.ledger_location, tn.send_amount_currency;


--QUESTION 9
SELECT COUNT(transfers.source_wallet_id) AS unique_senders,
COUNT(transfer_id) AS transaction_count, transfers.kind AS transfer_kind,
wallets.ledger_location AS country, SUM(transfers.send_amount_scalar)
AS volume FROM transfers INNER JOIN wallets
ON transfers.source_wallet_id = wallets.wallet_id 
WHERE (transfers.when_created > (NOW()-INTERVAL '1 week'))
GROUP BY wallets.ledger_location, transfers.kind;


--QUESTION 10
SELECT tn.send_amount_scalar , tn.source_wallet_id, w.wallet_id
FROM transfers AS tn INNER JOIN wallets AS w ON tn.transfer_id = w.wallet_id
WHERE tn.send_amount_scalar > 10000000 AND 
(tn.send_amount_currency = 'CFA' AND tn.when_created >
CURRENT_DATE-INTERVAL '1 MONTH');