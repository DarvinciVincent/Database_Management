-- Name: Nghia Nguyen
-- Student number: 000275466

CREATE TABLE Orders
(
  orderid        INT          NOT NULL,
  custid         INT          NULL,
  empid          INT          NOT NULL,
  orderdate      TIMESTAMP     NOT NULL,
  requireddate   TIMESTAMP     NOT NULL,
  shippeddate    TIMESTAMP     NULL,
  shipperid      INT          NOT NULL,
  freight        MONEY        NOT NULL
    CONSTRAINT DFT_Orders_freight DEFAULT(0),
  shipname       VARCHAR(40) NOT NULL,
  shipaddress    VARCHAR(60) NOT NULL,
  shipcity       VARCHAR(15) NOT NULL,
  shipregion     VARCHAR(15) NULL,
  shippostalcode VARCHAR(10) NULL,
  shipcountry    VARCHAR(15) NOT NULL 
) PARTITION BY RANGE (orderdate);


-- a) Partition the Orders table using orderdate with the following constraints:
--1.
create table order_a_1 partition of Orders
for values from ('20060703 00:00:00.000') to ('20070205 00:00:00.000');

--2.
create table order_a_2 partition of Orders
for values from ('20070205 00:00:00.000') to ('20070819 00:00:00.000');

--3.
create table order_a_3 partition of Orders
for values from ('20070819 00:00:00.000') to ('20080123 00:00:00.000');

--4.
create table order_a_4 partition of Orders
for values from ('20080123 00:00:00.000') to ('20080507 00:00:00.000');

--DEFAULT PARTITION
CREATE TABLE Order_others PARTITION OF Orders DEFAULT;

-- b) Alter the third partition and add a contraint where the freight cost is higher than 50 €
Alter table order_a_3 
add constraint freight_check 
check (freight::NUMERIC > 50.00);


--c) Alter the fourth partition and add a constraint that the shipped date should not be null
alter table  order_a_4
add constraint not_null_shippeddate
check (shippeddate is not null);

--d) Create two partitions of the first partition (so a partition of partitions) using shipcountry so that:
drop table order_a_1;

create table order_a_1 partition of Orders
for values from ('20060703 00:00:00.000') to ('20070205 00:00:00.000')
partition by list(shipcountry);

-- 1. Orders shipped to USA and UK are in one
create table order_shipcountry_d_1 Partition of order_a_1
for values in ('USA','UK');

-- 2. Orders shipped to Germany and Finland are in another
create table order_shipcountry_d_2 Partition of order_a_1
for values in ('Germany','Finland');

-- DEFAULT PARTITION
CREATE TABLE order_shipcountry_others PARTITION OF order_a_1 DEFAULT;

--e) How many rows are in each partition?
select count(*) from order_a_1;--177 rows

select count(*) from order_a_2;-- 187 rows

select count(*) from order_a_3;--93 rows

select count(*) from order_a_4;--194 rows

select count(*) from order_shipcountry_d_1;--38 rows

select count(*) from order_shipcountry_d_2; --27 rows



