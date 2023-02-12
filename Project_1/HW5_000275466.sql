--Name: Nghia Nguyen
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
  shipcountry    VARCHAR(15) NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)  
);

/*a)Create the following roles: user, manager, owner. 
--Grant all privileges to owner, read privileges to user, and insert privileges to manager.*/

CREATE ROLE "user " WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
	
CREATE ROLE "manager " WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
	
CREATE ROLE "owner " WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
	


GRANT ALL PRIVILEGES on Orders to "owner ";
Grant select on Orders to "user ";
Grant insert on Orders to "manager ";

--b) b) Create a new role: trainee. 
--Grant privileges only to columns orderdate and shippeddate to trainee and set the role valid until 30.5.2022.

CREATE ROLE "trainee" WITH
	NOLOGIN
	NOSUPERUSER
	NOCREATEDB
	NOCREATEROLE
	INHERIT
	NOREPLICATION
	CONNECTION LIMIT -1;
	
ALTER ROLE trainee
	VALID UNTIL '2022-05-30T23:59:00+03:00';
	
GRANT ALL PRIVILEGES (orderdate,shippeddate) on public.Orders to trainee;

--c)  Create a function get_shipping_info(varchar) that returns a table. 
CREATE OR REPLACE FUNCTION get_shipping_info(shipname_1 VARCHAR)
	RETURNS TABLE (shipname VARCHAR, shipaddress VARCHAR, shipcity VARCHAR, shipcountry VARCHAR)
	AS $$
	BEGIN
		RETURN QUERY
		SELECT Orders.shipname, Orders.shipaddress, Orders.shipcity, Orders.shipcountry
		FROM Orders
		WHERE Orders.shipname = shipname_1::VARCHAR;
	END
	$$ LANGUAGE 'plpgsql';

-- d) Extend the function in c) so that it accepts three parameters: get_shipping_info(varchar, timestamp, money).
CREATE OR REPLACE FUNCTION get_shipping_info(shipname_1 VARCHAR, orderdate_1 TIMESTAMP, freight_1 MONEY)
	RETURNS TABLE (shipname VARCHAR, shipaddress VARCHAR, shipcity VARCHAR, shipcountry VARCHAR)
	AS $$
	BEGIN
		RETURN QUERY
		SELECT Orders.shipname, Orders.shipaddress, Orders.shipcity, Orders.shipcountry
		FROM Orders
		WHERE Orders.shipname = shipname_1::VARCHAR AND Orders.orderdate <= orderdate_1::TIMESTAMP AND ((Orders.freight >= freight_1 - 10::MONEY) AND (Orders.freight <= freight_1 + 10::MONEY));
	END
	$$ LANGUAGE 'plpgsql';

