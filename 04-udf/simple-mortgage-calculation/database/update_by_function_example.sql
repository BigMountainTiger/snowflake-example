-- Create tge test table and function
-- parameters need to be upper case
CREATE OR REPLACE FUNCTION Example_func(A FLOAT, DV DATE)
RETURNS DATE NOT NULL
LANGUAGE JAVASCRIPT
AS $$
  A = parseInt(A);
	DV = DV.setMonth(DV.getMonth() + A);
	return DV;
$$;

SELECT Example_func(2, '1/2/2022');


CREATE OR REPLACE TABLE TTB (A INT, B DATE);
TRUNCATE TABLE TTB;

INSERT INTO TTB VALUES(1, '1/1/2022');
INSERT INTO TTB VALUES(2, '2/2/2022');
SELECT * FROM TTB;

-- Update by function call
UPDATE TTB SET B = Example_func(A, B);
SELECT * FROM TTB;

-- Drop the test table and function
DROP TABLE IF EXISTS TTB;
DROP FUNCTION IF EXISTS Example_func(FLOAT, DATE);