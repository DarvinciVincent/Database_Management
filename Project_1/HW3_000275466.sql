-- Name: Nghia Nguyen
-- Student number: 000275466

-- a) Adds X amount of days (given by the user)  to the "requireddate" value based on custid or orderid
CREATE OR REPLACE PROCEDURE requireddate(custid_ INT, orderid_ INT, X_ INT)
LANGUAGE 'plpgsql'
AS 
$$
BEGIN
	UPDATE orders
	SET requireddate = requireddate + (X_::INTEGER || ' days')::INTERVAL
	WHERE 
		CASE
			WHEN orderid_ IS NULL THEN custid = custid_
			ELSE orderid = orderid_
		END;
END;
$$;

-- b) Create a procedure that adds 10 % to the freight money
CREATE OR REPLACE PROCEDURE HW_3b()
LANGUAGE 'plpgsql'
AS 
$$
BEGIN
	UPDATE orders
	SET freight = freight*(1.1);
END;
$$;

-- c) Create a procedure that rounds the freight costs to nearest 10 €
CREATE OR REPLACE PROCEDURE HW_3c()
LANGUAGE plpgsql
AS 
$$
BEGIN
	UPDATE orders
	SET freight = (ROUND(freight::NUMERIC, -1))::MONEY; -- with -1 for ten, -2 for hundred and so on
END;
$$;

/* d) Create a procedure that sets 'shippedBeforeRequired' to true 
if shippeddate is smaller than requrieddate and false if vice-versa */

Alter table Orders
ADD COLUMN shippedBeforeRequired BOOL;

CREATE OR REPLACE PROCEDURE update_shippedBeforeRequired()
LANGUAGE 'plpgsql'
AS 
$$
BEGIN
	UPDATE orders
	SET shippedBeforeRequired =
		CASE 
			WHEN shippeddate < requireddate THEN TRUE
			ELSE FALSE
		END;
END;
$$;
