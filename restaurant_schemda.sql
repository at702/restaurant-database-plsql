
-- Structure of Team 8 File
-- 1. DROP TABLES
-- 2. CREATE TABLES
-- 3. CREATE SEQUENCES
-- 4. CREATE FUNCTIONS
-- 5. CREATE PROCEDURES
-- 6. EXECUTION BLOCK
-- 7. SQL QUERY

SET SERVEROUTPUT ON;


-- 1. DROP TABLES (reverse dependency order)

DROP TABLE Recommendations CASCADE CONSTRAINTS;
DROP TABLE Reviews CASCADE CONSTRAINTS;
DROP TABLE Orders CASCADE CONSTRAINTS;
DROP TABLE Inventory CASCADE CONSTRAINTS;
DROP TABLE MenuItems CASCADE CONSTRAINTS;
DROP TABLE Waiters CASCADE CONSTRAINTS;
DROP TABLE Customers CASCADE CONSTRAINTS;
DROP TABLE Restaurants CASCADE CONSTRAINTS;
DROP TABLE CuisineTypes CASCADE CONSTRAINTS;

-- DROP SEQUENCES
DROP SEQUENCE seqCuisineID;
DROP SEQUENCE seqRestaurantID;
DROP SEQUENCE waiter_seq;
DROP SEQUENCE seq_menu_item_id;
DROP SEQUENCE seq_inventory_id;
DROP SEQUENCE seq_customer;
DROP SEQUENCE seq_order;
DROP SEQUENCE seq_review;
DROP SEQUENCE seq_recommendation;


-- 2. CREATE TABLES 


--  CuisineTypes
CREATE TABLE CuisineTypes (
    cuisineID       NUMBER PRIMARY KEY,
    cuisineTypeName VARCHAR(50) NOT NULL UNIQUE
);

--  Restaurants
CREATE TABLE Restaurants (
    restaurantID   NUMBER PRIMARY KEY,
    restaurantName VARCHAR(100),
    strAddress     VARCHAR(200),
    cityName       VARCHAR(200),
    stateName      VARCHAR(50),
    zip            NUMBER,
    cuisineID      NUMBER,
    CONSTRAINT fk_cuisineType FOREIGN KEY (cuisineID) REFERENCES CuisineTypes(cuisineID)
);

--  Waiters
CREATE TABLE Waiters (
    waiter_id     NUMBER PRIMARY KEY,
    waiter_name   VARCHAR2(100) UNIQUE,
    restaurant_id NUMBER,
    CONSTRAINT fk_waiters_restaurant
    Foreign key (restaurant_id) 
   REFERENCES Restaurants(restaurantID)
);

--  Customers
CREATE TABLE Customers (
    customer_id        NUMBER PRIMARY KEY,
    name               VARCHAR2(100),
    email              VARCHAR2(100),
    street_address     VARCHAR2(200),
    city               VARCHAR2(100),
    state              VARCHAR2(50),
    zip                VARCHAR2(10),
    credit_card_number VARCHAR2(20)
);

--  MenuItems
CREATE TABLE MenuItems (
    menu_item_id NUMBER PRIMARY KEY,
    cuisineID    NUMBER NOT NULL,
    item_name    VARCHAR2(100) UNIQUE NOT NULL,
    price        NUMBER(8,2) NOT NULL,
    CONSTRAINT fk_menuitems_cuisine
        FOREIGN KEY (cuisineID) REFERENCES CuisineTypes(cuisineID)
);

-- Inventory
CREATE TABLE Inventory (
    inventory_id NUMBER PRIMARY KEY,
    restaurantID NUMBER NOT NULL,
    menu_item_id NUMBER NOT NULL,
    quantity     NUMBER NOT NULL,
    CONSTRAINT fk_inventory_restaurant
        FOREIGN KEY (restaurantID) REFERENCES Restaurants(restaurantID),
    CONSTRAINT fk_inventory_menuitem
        FOREIGN KEY (menu_item_id) REFERENCES MenuItems(menu_item_id),
    CONSTRAINT uq_inventory_rest_menu UNIQUE (restaurantID, menu_item_id)
);

--  Orders
CREATE TABLE Orders (
    order_id     NUMBER PRIMARY KEY,
    restaurantID NUMBER,
    customer_id  NUMBER,
    menu_item_id NUMBER,
    waiter_id    NUMBER,
    order_date   DATE,
    amount_paid  NUMBER(10,2),
    tip          NUMBER(10,2),
    CONSTRAINT fk_order_restaurant
        FOREIGN KEY (restaurantID) REFERENCES Restaurants(restaurantID),
    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_order_menu
        FOREIGN KEY (menu_item_id) REFERENCES MenuItems(menu_item_id),
   CONSTRAINT fk_order_waiter
       FOREIGN KEY (waiter_id) REFERENCES Waiters(waiter_id) 
);

--  Reviews
CREATE TABLE Reviews (
    review_id      NUMBER PRIMARY KEY,
    restaurantID   NUMBER NOT NULL,
    reviewer_email VARCHAR2(100) NOT NULL,
    stars_given    NUMBER(1) CHECK (stars_given BETWEEN 1 AND 5),
    review_text    VARCHAR2(500),
    CONSTRAINT fk_review_restaurant
        FOREIGN KEY (restaurantID) REFERENCES Restaurants(restaurantID)
);

--  Recommendations
CREATE TABLE Recommendations (
    recommendation_id   NUMBER PRIMARY KEY,
    customer_id         NUMBER NOT NULL,
    restaurantID        NUMBER NOT NULL,
    recommendation_date DATE,
    CONSTRAINT fk_recommend_customer
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    CONSTRAINT fk_recommend_restaurant
        FOREIGN KEY (restaurantID) REFERENCES Restaurants(restaurantID)
);


-- 3. CREATE SEQUENCES

CREATE SEQUENCE seqCuisineID       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seqRestaurantID    START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE waiter_seq         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_menu_item_id   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_inventory_id   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_customer       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_order          START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_review         START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_recommendation START WITH 1 INCREMENT BY 1;


-- 4. CREATE FUNCTIONS


--  find_cuisine_type_id
CREATE OR REPLACE FUNCTION find_cuisine_type_id (v_cuisineName IN VARCHAR2)
RETURN NUMBER
AS
    cuis_id NUMBER;
BEGIN
    SELECT cuisineID INTO cuis_id
      FROM CuisineTypes
     WHERE cuisineTypeName = v_cuisineName;
    RETURN cuis_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

--  find_restaurant_id
CREATE OR REPLACE FUNCTION find_restaurant_id (v_restaurantName IN VARCHAR2)
RETURN NUMBER
AS
    r_id NUMBER;
BEGIN
    SELECT restaurantID INTO r_id
      FROM Restaurants
     WHERE restaurantName = v_restaurantName;
    RETURN r_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END;
/

--  Find_Waiter_ID
CREATE OR REPLACE FUNCTION Find_Waiter_ID (p_waiter_name VARCHAR2)
RETURN NUMBER
IS
    v_waiter_id NUMBER;
BEGIN
    SELECT waiter_id INTO v_waiter_id
      FROM Waiters
     WHERE waiter_name = p_waiter_name;
    RETURN v_waiter_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('Waiter was NOT found');
        RETURN NULL;
    WHEN OTHERS THEN
        dbms_output.put_line('Error in Find_Waiter_ID ' || SQLERRM);
        RETURN NULL;
END;
/

--  FIND_MENU_ITEM_ID
CREATE OR REPLACE FUNCTION FIND_MENU_ITEM_ID (v_item_name IN VARCHAR2)
RETURN NUMBER
IS
    v_menu_item_id NUMBER;
BEGIN
    SELECT menu_item_id INTO v_menu_item_id
      FROM MenuItems
     WHERE LOWER(item_name) = LOWER(v_item_name);
    RETURN v_menu_item_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('FIND_MENU_ITEM_ID: no item named ' || v_item_name);
        RETURN -1;
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('FIND_MENU_ITEM_ID: duplicate name ' || v_item_name);
        RETURN -1;
END;
/


--  FIND_ORDER_ID
CREATE OR REPLACE FUNCTION FIND_ORDER_ID (
    p_customer_name VARCHAR2,
    p_item_name VARCHAR2
)
RETURN NUMBER
IS
    v_order_id NUMBER;
BEGIN

    SELECT o.order_id
    INTO v_order_id
    FROM Orders o
    JOIN Customers c
        ON o.customer_id = c.customer_id
    JOIN MenuItems m
        ON o.menu_item_id = m.menu_item_id
    WHERE c.name = p_customer_name
    AND m.item_name = p_item_name;

    RETURN v_order_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Order not found');
        RETURN NULL;

END;
/

--  FIND_CUSTOMER_ID
CREATE OR REPLACE FUNCTION FIND_CUSTOMER_ID (p_name VARCHAR2)
RETURN NUMBER
IS
    v_id NUMBER;
BEGIN
    SELECT customer_id INTO v_id
      FROM Customers
     WHERE name = p_name;
    RETURN v_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Customer not found');
        RETURN NULL;
END;
/


-- 5. CREATE PROCEDURES


--  Procedure 1 - new_cuisine
CREATE OR REPLACE PROCEDURE new_cuisine (v_cuisineTypeName IN VARCHAR2)
AS
BEGIN
    INSERT INTO CuisineTypes (cuisineID, cuisineTypeName)
    VALUES (seqCuisineID.NEXTVAL, v_cuisineTypeName);
    DBMS_OUTPUT.PUT_LINE('The newest cuisine is ' || v_cuisineTypeName);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Cuisine ' || v_cuisineTypeName || ' already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('new_cuisine error: ' || SQLERRM);
END;
/

--  Procedure 2 - new_restaurant
CREATE OR REPLACE PROCEDURE new_restaurant (
    v_restaurantName  IN VARCHAR2,
    v_strAddress      IN VARCHAR2,
    v_cityName        IN VARCHAR2,
    v_stateName       IN VARCHAR2,
    v_zip             IN NUMBER,
    v_CuisineTypeName IN VARCHAR2
)
AS
    v_cuisineID NUMBER;
BEGIN
    SELECT cuisineID INTO v_cuisineID
      FROM CuisineTypes
     WHERE cuisineTypeName = v_CuisineTypeName;

    INSERT INTO Restaurants (restaurantID, restaurantName, strAddress, cityName, stateName, zip, cuisineID)
    VALUES (seqRestaurantID.NEXTVAL, v_restaurantName, v_strAddress, v_cityName, v_stateName, v_zip, v_cuisineID);

    DBMS_OUTPUT.PUT_LINE('New Restaurant added: ' || v_restaurantName || '!');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE(v_CuisineTypeName || ' is not a valid type of cuisine. Try again.');
END;
/

--  Procedure 3 - display_by_cuisine
CREATE OR REPLACE PROCEDURE display_by_cuisine (v_cuisineName IN VARCHAR2)
AS
    CURSOR current_restaurant IS
        SELECT r.restaurantName, r.strAddress, r.cityName, r.stateName, r.zip
          FROM Restaurants r
          JOIN CuisineTypes c ON r.cuisineID = c.cuisineID
         WHERE c.cuisineTypeName = v_cuisineName;
    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Listing restaurants for: ' || v_cuisineName);
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    FOR r IN current_restaurant LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(r.restaurantName || ' | ' || r.strAddress || ', '
                             || r.cityName || ', ' || r.stateName || ' ' || r.zip);
    END LOOP;
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No restaurants found for this cuisine.');
    END IF;
END;
/
-- Procedure  - Report_Income_By_State
-- Calculates report of income total by joining restaurants table, 
-- cuisineTypes table, and orders table then groups by state and cuisine
-- output: The state then the cuisine type, and then the total income if applicable
CREATE OR REPLACE PROCEDURE Report_Income_By_State
AS
    CURSOR cur_income IS
        SELECT 
            r.stateName, 
            c.cuisineTypeName, 
            SUM(o.amount_paid + o.tip) AS total_income
        FROM Restaurants r
        JOIN CuisineTypes c ON r.cuisineID = c.cuisineID
        JOIN Orders o ON r.restaurantID = o.restaurantID
        GROUP BY r.stateName, c.cuisineTypeName
        ORDER BY r.stateName, total_income DESC;
    
    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('State | Cuisine Type | Total Income');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------');
    FOR rec IN cur_income LOOP
        v_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(rec.stateName || ' | ' || rec.cuisineTypeName || ' | $' || TO_CHAR(rec.total_income, '999,999.99'));
    END LOOP;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No income data found. Please ensure orders have been placed.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in Report_Income_By_State: ' || SQLERRM);
END;
/

--  Procedure  - Hire_Waiter
CREATE OR REPLACE PROCEDURE Hire_Waiter (
    p_waiter_name     VARCHAR2,
    p_restaurant_name VARCHAR2
)
IS
    v_restaurant_id NUMBER;
BEGIN
    dbms_output.put_line('Hiring Waiter Name: ' || p_waiter_name);

    v_restaurant_id := find_restaurant_id(p_restaurant_name);

    IF v_restaurant_id IS NULL THEN
   	dbms_output.put_line('ERROR: Restaurant not found, cannot hire waiter');
  	 RETURN;
   END IF; 

    INSERT INTO Waiters
    VALUES (
    waiter_seq.NEXTVAL, 
    p_waiter_name, 
    v_restaurant_id);

    dbms_output.put_line('Waiter was hired!');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in Hire_Waiter' || SQLERRM);
END;
/

--  Procedure - Show_List_Of_Waiters
CREATE OR REPLACE PROCEDURE Show_List_Of_Waiters (p_restaurant_name VARCHAR2)
IS
    v_restaurant_id NUMBER;
    V_found BOOLEAN := FALSE;
BEGIN
    dbms_output.put_line('Showing waiters for restaurant: ' || p_restaurant_name);

    v_restaurant_id := find_restaurant_id(p_restaurant_name);
 
IF v_restaurant_id IS NULL THEN
dbms_output.put_line('ERROR: Restaurant not found');
RETURN;
END IF; 

    FOR rec IN (
        SELECT waiter_id, waiter_name
          FROM Waiters
         WHERE restaurant_id = v_restaurant_id
    )
    LOOP
       v_found := TRUE;
        dbms_output.put_line('ID: ' || rec.waiter_id || ' NAME: ' || rec.waiter_name);
    END LOOP;

IF NOT v_found then
	dbms_output.put_line('No waiters found. ');
END IF;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in Show_List_Of_Waiters ' || SQLERRM);
END;
/

-- Description: 
-- shows total tips earned by each waiter
-- The output of this procuedre is the waiter name and total tips earned..

CREATE OR REPLACE PROCEDURE Report_Tips
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TOTAL TIPS BY WAITER');
    DBMS_OUTPUT.PUT_LINE('==========================================');

    FOR rec IN (
        SELECT w.waiter_id, w.waiter_name,
               NVL(SUM(o.tip),0) AS total_tips
        FROM Waiters w
        LEFT JOIN Orders o
               ON w.waiter_id = o.waiter_id
        GROUP BY w.waiter_id, w.waiter_name
        ORDER BY total_tips DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Waiter: ' || rec.waiter_name ||
            ' | Total Tips: $' || rec.total_tips
        );
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error in Report_Tips: ' || SQLERRM
        );
END;
/

-- Procedure: Report_Tips_By_State
/*
Description: 
Given a state as an input, the procedure shows the total tips earned 
by waiters working at the restaurants located in those states

*/

CREATE OR REPLACE PROCEDURE Report_Tips_By_State (
    p_state VARCHAR2
)
IS
v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('TIPS REPORT FOR STATE: ' || p_state);
    DBMS_OUTPUT.PUT_LINE('==========================================');

    FOR rec IN (
        SELECT w.waiter_name,
               r.restaurantName,
               NVL(SUM(o.tip),0) AS total_tips
        FROM Waiters w
        JOIN Restaurants r
             ON w.restaurant_id = r.restaurantID
        LEFT JOIN Orders o
             ON w.waiter_id = o.waiter_id
        WHERE r.stateName = p_state
        GROUP BY w.waiter_name, r.restaurantName
        ORDER BY total_tips DESC
    )
    LOOP
        v_found := TRUE; 
        DBMS_OUTPUT.PUT_LINE(
            'Waiter: ' || rec.waiter_name ||
            ' | Restaurant: ' || rec.restaurantName ||
            ' | Tips: $' || rec.total_tips
        );
    END LOOP;
IF NOT v_found then
	dbms_output.put_line ('No tip data found for this state.');
END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error in Report_Tips_By_State: ' || SQLERRM
        );
END;
/


-- Procedure 9 - new_menuItem
CREATE OR REPLACE PROCEDURE new_menuItem (
    v_cuisineTypeName IN VARCHAR2,
    v_item_name       IN VARCHAR2,
    v_price           IN NUMBER
)
AS
    v_cuisineID NUMBER;
BEGIN
    dbms_output.put_line('new_menuItem called: cuisine=' || v_cuisineTypeName
                         || ', item=' || v_item_name || ', price=' || v_price);

    v_cuisineID := FIND_CUISINE_TYPE_ID(v_cuisineTypeName);

    IF v_cuisineID IS NULL THEN
        dbms_output.put_line('  -> cuisine ' || v_cuisineTypeName || ' not found; aborting');
        RETURN;
    END IF;

    INSERT INTO MenuItems (menu_item_id, cuisineID, item_name, price)
    VALUES (seq_menu_item_id.NEXTVAL, v_cuisineID, v_item_name, v_price);

    dbms_output.put_line('The newest menu item added is ' || v_item_name
        || ' ($' || v_price || ') under ' || v_cuisineTypeName);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('new_menuItem error: ' || SQLERRM);
END;
/

--  Procedure 10 - add_to_inventory
CREATE OR REPLACE PROCEDURE add_to_inventory (
    v_restaurant_name IN VARCHAR2,
    v_item_name       IN VARCHAR2,
    v_quantity        IN NUMBER
)
AS
    v_restaurantID NUMBER;
    v_menu_item_id NUMBER;
BEGIN
    dbms_output.put_line('add_to_inventory called: restaurant=' || v_restaurant_name
        || ', item=' || v_item_name || ', qty=' || v_quantity);
    v_restaurantID := FIND_RESTAURANT_ID(v_restaurant_name);
    v_menu_item_id := FIND_MENU_ITEM_ID(v_item_name);

    IF v_restaurantID IS NULL THEN
        dbms_output.put_line('  restaurant ' || v_restaurant_name || ' not found; aborting');
        RETURN;
    END IF;
    IF v_menu_item_id = -1 THEN
        dbms_output.put_line('  item ' || v_item_name || ' not found; aborting');
        RETURN;
    END IF;

    INSERT INTO Inventory (inventory_id, restaurantID, menu_item_id, quantity)
    VALUES (seq_inventory_id.NEXTVAL, v_restaurantID, v_menu_item_id, v_quantity);

    dbms_output.put_line('Stocked ' || v_quantity || ' x ' || v_item_name
                         || ' at ' || v_restaurant_name);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('add_to_inventory error: ' || SQLERRM);
END;
/

--  Procedure 11 - report_menu_items
CREATE OR REPLACE PROCEDURE report_menu_items
AS
    CURSOR inventory_cursor IS
        SELECT 
            r.restaurantName,
            m.item_name,
            m.price,
            i.quantity,
            c.cuisineTypeName
        FROM Inventory i
        JOIN Restaurants r ON i.restaurantID = r.restaurantID
        JOIN MenuItems m ON i.menu_item_id = m.menu_item_id
        JOIN CuisineTypes c ON m.cuisineID = c.cuisineID
        ORDER BY r.restaurantName, m.item_name;
    
    v_count NUMBER := 0;
BEGIN
    dbms_output.put_line('          MENU ITEMS INVENTORY REPORT          ');
  dbms_output.put_line('------------------------------------------------------------------------');
    dbms_output.put_line('Restaurant | Item | Cuisine | Price | Qty');
    dbms_output.put_line('---------------------------------------------------------------');
    
    -- Loop through all inventory items
    FOR rec IN inventory_cursor LOOP
        dbms_output.put_line(
            RPAD(rec.restaurantName, 17) || ' | ' ||
            RPAD(rec.item_name, 12) || ' | ' ||
            RPAD(rec.cuisineTypeName, 10) || ' | $' ||
            LPAD(TO_CHAR(rec.price, '999.99'), 5) || ' | ' ||
            LPAD(rec.quantity, 3)
        );
        v_count := v_count + 1;
    END LOOP;
    
    dbms_output.put_line('---------------------------------------------------------------');
    dbms_output.put_line('Total inventory records: ' || v_count);
    dbms_output.put_line('===============================================');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in report_menu_items: ' || SQLERRM);
END;
/
--  Procedure 12 - update_inventory
CREATE OR REPLACE PROCEDURE update_inventory (
    v_restaurant_name IN VARCHAR2,
    v_item_name IN VARCHAR2,
    v_reduce_by IN NUMBER
)
AS
    v_restaurantID NUMBER;
    v_menu_item_id NUMBER;
    v_current_qty NUMBER;
    v_new_qty NUMBER;
BEGIN
    dbms_output.put_line('update_inventory called: restaurant=' || v_restaurant_name
        || ', item=' || v_item_name || ', reduce by=' || v_reduce_by);
    
    -- Get restaurant ID using helper function from Member 1
    v_restaurantID := FIND_RESTAURANT_ID(v_restaurant_name);
    -- Get menu item ID using Member 3 helper function
    v_menu_item_id := FIND_MENU_ITEM_ID(v_item_name);
    
    IF v_restaurantID IS NULL THEN
        dbms_output.put_line('  -> restaurant ' || v_restaurant_name || ' not found; aborting');
        RETURN;
    END IF;
    
    IF v_menu_item_id = -1 THEN
        dbms_output.put_line('  -> item ' || v_item_name || ' not found; aborting');
        RETURN;
    END IF;
    
    -- Get current quantity
    BEGIN
        SELECT quantity INTO v_current_qty
        FROM Inventory
        WHERE restaurantID = v_restaurantID
        AND menu_item_id = v_menu_item_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('  -> No inventory record found for ' || v_item_name 
                || ' at ' || v_restaurant_name);
            RETURN;
    END;
    
    -- Calculate new quantity
    v_new_qty := v_current_qty - v_reduce_by;
    
    -- Check if new quantity would be negative
    IF v_new_qty < 0 THEN
        dbms_output.put_line('  -> ERROR: Cannot reduce by ' || v_reduce_by 
            || '. Current quantity is only ' || v_current_qty);
        RETURN;
    END IF;
    
    -- Update the inventory
    UPDATE Inventory
    SET quantity = v_new_qty
    WHERE restaurantID = v_restaurantID
    AND menu_item_id = v_menu_item_id;
    
    dbms_output.put_line('Updated inventory for ' || v_item_name || ' at ' 
        || v_restaurant_name || ': ' || v_current_qty || ' = ' || v_new_qty);
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('update_inventory error: ' || SQLERRM);
END;
/
--  Procedure 13 - add_customer
CREATE OR REPLACE PROCEDURE add_customer (p_name   VARCHAR2, p_email  VARCHAR2, p_street VARCHAR2, p_city   VARCHAR2, p_state  VARCHAR2, p_zip    VARCHAR2, p_cc     VARCHAR2
)
IS
BEGIN
    INSERT INTO Customers
    VALUES (seq_customer.NEXTVAL, p_name, p_email, p_street,
            p_city, p_state, p_zip, p_cc);
    DBMS_OUTPUT.PUT_LINE('Customer added: ' || p_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ADD_CUSTOMER error: ' || SQLERRM); 
END;
/

--  Procedure 14 - customers_in_state
CREATE OR REPLACE PROCEDURE customers_in_state (p_state VARCHAR2)
IS
BEGIN
    FOR rec IN (
        SELECT name, city
          FROM Customers
         WHERE state = p_state
         ORDER BY name DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(rec.name || ' - ' || rec.city);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('CUSTOMERS_IN_STATE error: ' || SQLERRM); 
END;
/


--  Procedure: PLACE_ORDER
CREATE OR REPLACE PROCEDURE PLACE_ORDER (

    p_customer_name VARCHAR2,
    p_restaurant_name VARCHAR2,
    p_menu_item_name VARCHAR2,
    p_waiter_name VARCHAR2,
    p_order_date DATE

)
IS

v_customer_id NUMBER;
v_restaurant_id NUMBER;
v_menu_item_id NUMBER;
v_waiter_id NUMBER;

v_amount NUMBER;
v_tip NUMBER;
 v_check NUMBER;

BEGIN

DBMS_OUTPUT.PUT_LINE(
'PLACE_ORDER called'
);

v_customer_id :=
FIND_CUSTOMER_ID(p_customer_name);

v_restaurant_id :=
FIND_RESTAURANT_ID(p_restaurant_name);

v_menu_item_id :=
FIND_MENU_ITEM_ID(p_menu_item_name);

v_waiter_id :=
FIND_WAITER_ID(p_waiter_name);

IF v_customer_id IS NULL THEN
DBMS_OUTPUT.PUT_LINE('Customer missing');
RETURN;
END IF;

IF v_restaurant_id IS NULL THEN
	DBMS_OUTPUT.PUT_LINE('Restaurant not found'); 
RETURN;
END IF;

IF v_menu_item_id = -1 THEN
DBMS_OUTPUT.PUT_LINE('Menu item missing');
RETURN;
END IF;

BEGIN
    SELECT quantity 
    INTO v_check
    FROM Inventory
    WHERE restaurantID = v_restaurant_id
      AND menu_item_id = v_menu_item_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cannot place order: item not in inventory for this restaurant');
        RETURN;
END;


IF v_waiter_id IS NULL THEN
DBMS_OUTPUT.PUT_LINE('Waiter missing');
RETURN;
END IF;


SELECT price
INTO v_amount
FROM MenuItems
WHERE menu_item_id = v_menu_item_id;


v_tip :=
ROUND(v_amount * .20,2);


INSERT INTO Orders
VALUES(

seq_order.NEXTVAL,

v_restaurant_id,

v_customer_id,

v_menu_item_id,

v_waiter_id,

p_order_date,

v_amount,

v_tip

);


update_inventory(

p_restaurant_name,

p_menu_item_name,

1

);


DBMS_OUTPUT.PUT_LINE(
'Order created successfully'
);

EXCEPTION

WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE('PLACE_ORDER error: ' || SQLERRM );

END;
/

-- Procedure: BEST_RESTAURANTS
CREATE OR REPLACE PROCEDURE BEST_RESTAURANTS
IS

BEGIN

DBMS_OUTPUT.PUT_LINE(
'TOP 3 RESTAURANTS BY STATE'
);

FOR rec IN (

SELECT *

FROM (

SELECT

r.stateName,

r.restaurantName,

SUM(o.amount_paid) total_income,

ROW_NUMBER()

OVER(

PARTITION BY r.stateName

ORDER BY SUM(o.amount_paid) DESC

)

rn

FROM Restaurants r

JOIN Orders o

ON r.restaurantID =
o.restaurantID

GROUP BY

r.stateName,

r.restaurantName

)

WHERE rn <= 3

ORDER BY stateName

)

LOOP

DBMS_OUTPUT.PUT_LINE(

rec.stateName

|| ' | '

|| rec.restaurantName

|| ' | $'

|| rec.total_income

);

END LOOP;

EXCEPTION

WHEN OTHERS THEN

DBMS_OUTPUT.PUT_LINE('BEST_RESTAURANTS error ' || SQLERRM);

END;
/


--  Procedure 17 - Add_Review
CREATE OR REPLACE PROCEDURE Add_Review (
    p_email           VARCHAR2,
    p_restaurant_name VARCHAR2,
    p_stars           NUMBER,
    p_review_text     VARCHAR2
)
IS
    v_restaurant_id NUMBER;
BEGIN
    dbms_output.put_line('Add Review for ' || p_restaurant_name);

    v_restaurant_id := FIND_RESTAURANT_ID(p_restaurant_name);

    INSERT INTO Reviews (review_id, restaurantID, reviewer_email, stars_given, review_text)
    VALUES (seq_review.NEXTVAL, v_restaurant_id, p_email, p_stars, p_review_text);

    dbms_output.put_line('A review was added!');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in Add_Review. ' || SQLERRM);
END;
/

--  Procedure 18 - Buy_Or_Beware

CREATE OR REPLACE PROCEDURE Buy_Or_Beware (
	p_x IN NUMBER
)
IS
    v_count NUMBER := 0;
BEGIN
    dbms_output.put_line('Buy_Or_Beware called with X = ' || p_x);
 
	-- Print top X restaurants
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Top Rated Restaurants');
    DBMS_OUTPUT.PUT_LINE('==========================================');
 
    v_count := 0;
	FOR rec IN (
        SELECT r.restaurantName,
               c.cuisineTypeName,
               ROUND(AVG(rv.stars_given), 2) AS avg_stars
        FROM Reviews rv
        JOIN Restaurants r  ON rv.restaurantID = r.restaurantID
        JOIN CuisineTypes c ON r.cuisineID     = c.cuisineID
        GROUP BY r.restaurantName, c.cuisineTypeName
        ORDER BY avg_stars DESC
	)
	LOOP
        EXIT WHEN v_count >= p_x;
        DBMS_OUTPUT.PUT_LINE(
            'Avg Stars: ' || rec.avg_stars ||
            ' | Restaurant: ' || rec.restaurantName ||
            ' | Cuisine: ' || rec.cuisineTypeName
        );
        v_count := v_count + 1;
	END LOOP;
	-- Print bottom X restaurants
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('Buyer Beware: Stay Away From...');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    v_count := 0;
	FOR rec IN (
        SELECT r.restaurantName,
               c.cuisineTypeName,
               ROUND(AVG(rv.stars_given), 2) AS avg_stars
        FROM Reviews rv
        JOIN Restaurants r  ON rv.restaurantID = r.restaurantID
        JOIN CuisineTypes c ON r.cuisineID     = c.cuisineID
        GROUP BY r.restaurantName, c.cuisineTypeName
        ORDER BY avg_stars ASC)
	LOOP
        EXIT WHEN v_count >= p_x;
        DBMS_OUTPUT.PUT_LINE(
            'Avg Stars: ' || rec.avg_stars ||
            ' | Restaurant: ' || rec.restaurantName ||
            ' | Cuisine: ' || rec.cuisineTypeName);
        v_count := v_count + 1;
	END LOOP;
 
EXCEPTION
	WHEN OTHERS THEN
        dbms_output.put_line('Error in Buy_Or_Beware: ' || SQLERRM);
END;
/
--  Procedure 19 - Recommend_To_Customer
CREATE OR REPLACE PROCEDURE Recommend_To_Customer (
    p_customer_name IN VARCHAR2,
    p_cuisine_name  IN VARCHAR2)
IS
    v_customer_id	NUMBER;
    v_cuisine_id 	NUMBER;
    v_restaurant_id  NUMBER;
    v_already_visited NUMBER := 0;
BEGIN
    dbms_output.put_line('Recommend_To_Customer: customer=' || p_customer_name || ', cuisine=' || p_cuisine_name);
	    v_customer_id := FIND_CUSTOMER_ID(p_customer_name);
	IF v_customer_id IS NULL THEN
        dbms_output.put_line('  -> Customer not found: ' || p_customer_name);
        RETURN;
	END IF;
     v_cuisine_id := FIND_CUISINE_TYPE_ID(p_cuisine_name);
	IF v_cuisine_id IS NULL THEN
        dbms_output.put_line('  -> Cuisine type not found: ' || p_cuisine_name);
        RETURN;
	END IF;
	BEGIN
       SELECT restaurantID
INTO v_restaurant_id
FROM (
SELECT r.restaurantID
FROM Restaurants r
JOIN Reviews rv
ON r.restaurantID = rv.restaurantID
WHERE r.cuisineID = v_cuisine_id
AND r.restaurantID NOT IN (
SELECT restaurantID
FROM Orders
WHERE customer_id = v_customer_id
)
GROUP BY r.restaurantID
ORDER BY AVG(rv.stars_given) DESC
)
WHERE ROWNUM = 1; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('  -> No unvisited restaurant found for cuisine: ' || p_cuisine_name);
            RETURN;
	END;
    INSERT INTO Recommendations (recommendation_id, customer_id, restaurantID, recommendation_date)
    VALUES (seq_recommendation.NEXTVAL, v_customer_id, v_restaurant_id, SYSDATE);
    dbms_output.put_line('  -> Recommendation added for customer ' || p_customer_name);
EXCEPTION
	WHEN OTHERS THEN
        dbms_output.put_line('Error in Recommend_To_Customer: ' || SQLERRM);
END;
/
--  Procedure 20 - List_Recommendations
CREATE OR REPLACE PROCEDURE List_Recommendations
IS
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('ALL CUSTOMER RECOMMENDATIONS');
    DBMS_OUTPUT.PUT_LINE('==========================================');
	FOR rec IN (
        SELECT cu.name                           AS customer_name,
               r.restaurantName                  AS restaurant_name,
               c.cuisineTypeName                 AS cuisine_name,
               ROUND(AVG(rv.stars_given), 2)     AS avg_stars
        FROM Recommendations rec2
        JOIN Customers	cu ON rec2.customer_id  = cu.customer_id
        JOIN Restaurants  r  ON rec2.restaurantID = r.restaurantID
        JOIN CuisineTypes c  ON r.cuisineID   	= c.cuisineID
        LEFT JOIN Reviews rv ON r.restaurantID    = rv.restaurantID
        GROUP BY cu.name, r.restaurantName, c.cuisineTypeName
        ORDER BY cu.name
	)
	LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Customer: ' || rec.customer_name ||
            ' | Restaurant: ' || rec.restaurant_name ||
            ' | Cuisine: ' || rec.cuisine_name ||
            ' | Avg Stars: ' || NVL(TO_CHAR(rec.avg_stars), 'N/A')
        );
        v_count := v_count + 1;
	END LOOP;
	IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No recommendations found.');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
        dbms_output.put_line('Error in List_Recommendations: ' || SQLERRM);
END;
/

-----
CREATE OR REPLACE PROCEDURE most_popular_restaurant
IS
BEGIN
    FOR rec IN (
        SELECT r.restaurantName,
               COUNT(rv.review_id) AS total_reviews,
               ROUND(AVG(rv.stars_given), 2) AS avg_rating
        FROM Restaurants r
        JOIN Reviews rv ON r.restaurantID = rv.restaurantID
        GROUP BY r.restaurantName
        HAVING COUNT(rv.review_id) = (
            SELECT MAX(review_count)
            FROM (
                SELECT COUNT(review_id) AS review_count
                FROM Reviews
                GROUP BY restaurantID
            )
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Most Popular Restaurant: ' || rec.restaurantName);
        DBMS_OUTPUT.PUT_LINE('Total Reviews: ' || rec.total_reviews);
        DBMS_OUTPUT.PUT_LINE('Average Rating: ' || rec.avg_rating);
    END LOOP;
END;
/

-------
CREATE OR REPLACE PROCEDURE pop_restaurant_by_order
IS
BEGIN
    FOR rec IN (
        SELECT r.restaurantName,
               COUNT(o.order_id) AS total_orders
        FROM Restaurants r
        JOIN Orders o ON r.restaurantID = o.restaurantID
        GROUP BY r.restaurantName
        HAVING COUNT(o.order_id) = (
            SELECT MAX(order_count)
            FROM (
                SELECT COUNT(order_id) AS order_count
                FROM Orders
                GROUP BY restaurantID
            )
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Most Popular Restaurant by Orders: ' || rec.restaurantName);
        DBMS_OUTPUT.PUT_LINE('Total Orders: ' || rec.total_orders);
    END LOOP;
END;
/
----

CREATE OR REPLACE PROCEDURE most_profitable_restaurant
IS
BEGIN
    FOR rec IN (
        SELECT r.restaurantName,
               SUM(o.amount_paid) AS total_income
        FROM Restaurants r
        JOIN Orders o ON r.restaurantID = o.restaurantID
        GROUP BY r.restaurantName
        HAVING SUM(o.amount_paid) = (
            SELECT MAX(total_income)
            FROM (
                SELECT SUM(amount_paid) AS total_income
                FROM Orders
                GROUP BY restaurantID
            )
        )
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Most Profitable Restaurant: ' || rec.restaurantName);
        DBMS_OUTPUT.PUT_LINE('Total Income: $' || rec.total_income);
    END LOOP;
END;
/
--  Procedure 21 - customers_by_zip
CREATE OR REPLACE PROCEDURE customers_by_zip (
    p_zip IN VARCHAR2
)
IS
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('Customers living in zip code ' || p_zip || ':');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    FOR rec IN (
        SELECT name
          FROM Customers
         WHERE zip = p_zip
         ORDER BY name
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Customer: ' || rec.name);
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No customers found in zip code ' || p_zip);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in customers_by_zip: ' || SQLERRM);
END;
/


-- 6. EXECUTION BLOCK

BEGIN
    -- ========== 1 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('==========   Below are 1 Operations ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    new_cuisine('American');
    new_cuisine('Italian');
    new_cuisine('Indian');
    new_cuisine('Ethiopian');

    new_restaurant('Ribs_R_US',    '1000 Ribby Rd', 'Baltimore',     'MD', 21250, 'American');
    new_restaurant('Bella Italia', '1001 Italy Rd', 'Ellicott City', 'MD', 21043, 'Italian');
    new_restaurant('Selasie', '123 Selah Way', 'Beech Creek', 'PA', 16822, 'Ethiopian');
    new_restaurant('Roma', '67 Bella Rd', 'Ellicott City', 'MD', 21043, 'Italian');


   display_by_cuisine('Italian');
   display_by_cuisine('Ethiopian');
   display_by_cuisine('American');

    -- ========== 2 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('==========   Below are  2 Operations ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    Hire_Waiter('Jack',    'Ribs_R_US');
    Hire_Waiter('Jill',    'Ribs_R_US');
    Hire_Waiter('Wendy',   'Ribs_R_US');
    Hire_Waiter('Hailey',  'Ribs_R_US');

    Hire_Waiter('Mary',    'Bella Italia');
    Hire_Waiter('Pat',     'Bella Italia');
    Hire_Waiter('Michael', 'Bella Italia');
    Hire_Waiter('Rakesh',  'Bella Italia');
    Hire_Waiter('Verma',   'Bella Italia');
	
   -- New waiters added for D2
   Hire_Waiter('Mike',    'Roma');
   Hire_Waiter('Judy',    'Roma');
   Hire_Waiter('Trevor',  'Selasie');

    Show_List_Of_Waiters('Bella Italia');


    -- ==========  3 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('==========   Below are 3 Operations ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    new_menuItem('American', 'burger', 10);
    new_menuItem('American', 'fries',   5);
    new_menuItem('American', 'pasta',  15);
    new_menuItem('American', 'salad',  10);
    new_menuItem('American', 'salmon', 20);

    new_menuItem('Italian', 'lasagna',   15);
    new_menuItem('Italian', 'meatballs', 10);
    new_menuItem('Italian', 'spaghetti', 15);
    new_menuItem('Italian', 'pizza',     20);

    -- Add Ethiopian cuisine menu items
    new_menuItem('Ethiopian', 'meat chunks', 12);
    new_menuItem('Ethiopian', 'legume stew', 10);
    new_menuItem('Ethiopian', 'flatbread', 3);

    add_to_inventory('Ribs_R_US',    'burger',  50);
    add_to_inventory('Ribs_R_US',    'fries',  150);
    add_to_inventory('Bella Italia', 'lasagna',  10);
    add_to_inventory('Bella Italia', 'meatballs', 5);
    add_to_inventory('Bella Italia', 'pizza', 20); 

    -- Add inventory to Selasie restaurant
    add_to_inventory('Selasie', 'meat chunks', 150);
    add_to_inventory('Selasie', 'legume stew', 150);
    add_to_inventory('Selasie', 'flatbread',   500);

    -- Report menu items test two
    report_menu_items;

    -- Update inventory - reduce quantities
    update_inventory('Selasie', 'meat chunks', 50);
    update_inventory('Bella Italia', 'lasagna', 2);

    -- Report menu items Test two
    report_menu_items;

   
    -- ========== 4 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('========== Below are 4 Operations ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    add_customer('Cust1',   'cust1@gmail.com',   '123 A St', 'Columbia',      'MD', '21045', '1111');
    add_customer('Cust11',  'cust11@gmail.com',  '456 B St', 'Columbia',      'MD', '21045', '2222');
    add_customer('Cust3',   'cust3@gmail.com',   '789 C St', 'Ellicott City', 'MD', '21046', '3333');
    add_customer('Cust111', 'cust111@gmail.com', '321 D St', 'Columbia',      'MD', '21045', '4444');

    FOR rec IN (
        SELECT name FROM Customers WHERE zip = '21045'
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Customer in 21045: ' || rec.name);
    END LOOP;

    customers_in_state('MD');

PLACE_ORDER( 'Cust1', 'Ribs_R_US','burger', 'Jack', SYSDATE);

PLACE_ORDER('Cust11','Bella Italia', 'lasagna', 'Mary', SYSDATE);

PLACE_ORDER('Cust3', 'Bella Italia', 'pizza', 'Michael', SYSDATE);

PLACE_ORDER('Cust111', 'Selasie', 'meat chunks', 'Trevor', SYSDATE); 

    -- ========== 5 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('========== Below are 5 Operations =======');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    Add_Review('cust1@gmail.com', 'Ribs_R_US',    4, 'Wonderful place, but expensive');
    Add_Review('cust1@gmail.com', 'Bella Italia', 2, 'Very bad food. I''m Italian and Bella Italia does NOT give you authentic Italian food');
    Add_Review('abc@abc.com',     'Ribs_R_US',    4, 'I liked the food. Good experience');
    Add_Review('dce@abc.com',     'Ribs_R_US',    5, 'Excellent');
    Add_Review('abc@abc.com',     'Bella Italia', 3, 'So-so');

    -- ========== 6 ==========
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('========== Below are 6 Operations =======');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    customers_by_zip('21045');
END;
/


-- 7. SQL QUERY

-- Show all restaurants
SELECT * FROM Restaurants;

-- Show inventory for Ribs_R_US
SELECT * FROM Inventory WHERE restaurantID = FIND_RESTAURANT_ID('Ribs_R_US');

-- Show inventory for Bella Italia
SELECT * FROM Inventory WHERE restaurantID = FIND_RESTAURANT_ID('Bella Italia');




--  ===== REPORTS =======

-- ========== # 1 Reports ==========
BEGIN
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('==========   Below are #1 Reports  ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    Report_Income_By_State;
END;
/
-- ========== #2 Reports ==========
BEGIN
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('==========   Below are # 2 Reports  ========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    Report_Tips;

    Report_Tips_By_State('MD');

    Report_Tips_By_State('PA');
END;
/

BEGIN

DBMS_OUTPUT.PUT_LINE(
'========== #4 REPORTS =========='
);

BEST_RESTAURANTS;

END;
/


-- ========== #6 Reports ==========
BEGIN
    DBMS_OUTPUT.PUT_LINE('===============================================');
    DBMS_OUTPUT.PUT_LINE('========== Below are # 6 Reports =========');
    DBMS_OUTPUT.PUT_LINE('===============================================');

    customers_by_zip('21045');

    most_popular_restaurant;

    pop_restaurant_by_order;

    most_profitable_restaurant;
END;
/

