--Name: Nghia Nguyen
--Student number: 000275466

CREATE TABLE purchases (
  id SERIAL,
  n varchar(255) NOT NULL,
  d DATE default NULL,
  i varchar(50) NOT NULL,
  PRIMARY KEY (id)
);
-- a) For each customer: articles that the customer bought at the same day of month for two consecutive months
select P1.n as "Customer", P1.d as "Purchase date 1", 
		P1.i as "Articles 1", P2.d as "Purchase date 2", 
		P2.i as "Articles 2" from purchases P1, purchases P2
where extract(day from P1.d) = extract(day from P2.d) and 
	  ((extract(month from P1.d) = extract(month from P2.d) - 1 and 
	  extract(year from P1.d) = extract(year from P2.d)) or
	  (extract(month from P1.d) = 12 and extract(month from P2.d) = 1 and 
	  extract(year from P1.d) = extract(year from P2.d)-1)) and P1.n = P2.n;
	  
-- b) For each customer: timeslot in which the customer has been active
select n, 
max(d)-min(d) as "Customers_active_timeslot" from purchases
group by n
order by n;

-- c) All purchases of customers in February and March of leap years
select * from purchases
where (extract(year from d)%4 = 0) and 
      (extract(year from d)%100 != 0 
	   or extract(year from d)%400 = 0) 
	   and (extract(month from d) = 2 or extract(month from d) = 3);

-- d) Get pairs of customers - each with more than a singleton purchase - that have overlapping active purchase periods.
select T1.customer as customer_1, T2.customer as customer_2, 
	   T1.first_date as first_date_1, T1.last_date as last_date_1, 
	   T2.first_date as first_date_2, T2.last_date as last_date_2 from 
(select n as customer, count(*) as count, min(d) as first_date, max(d) as last_date from purchases
 group by n
 order by n) T1, 
(select n as customer, count(*) as count, min(d) as first_date, max(d) as last_date from purchases
 group by n
 order by n) T2
where 
T1.customer != T2.customer and (T1.first_date <= T2.first_date and T1.last_date >= T2.first_date) and (T1.count > 1 and T2.count > 1);

-- e) All purchases of the last Fridays of a month.
select *, to_char(d, 'Day') AS "Day_purchases" from purchases
where to_char(d, 'Day') = 'Friday' 
and extract(month from d+7) != extract(month from d);