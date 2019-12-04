-- To check inventory level of specific shoe with access to price and description
SELECT *
FROM inventory_quantities iq 
	JOIN inventory i
		ON iq.inventory_model = i.model
	JOIN color c
		ON c.color_code = iq.color_color_code
	JOIN type t
		ON i.type_id = t.type_id
WHERE 	iq.inventory_model = "WLIL" &&
		size = 10 &&
        color_color_code = "BK" &&
        gender = "M";
    
-- To check inventory level of specific shoe minimal
SELECT *
FROM inventory_quantities
WHERE 	inventory_model = "WLIL" &&
		size = 10 &&
        color_color_code = "BK" &&
        gender = "M";
        
-- To check amount of specific product is in the cart table
SELECT COALESCE(SUM(quantity_in_cart), 0) as total_qty_in_cart_table
FROM cart
WHERE 	inventory_quantities_inventory_model = "WLIL" &&
		inventory_quantities_size = 10 &&
        inventory_quantities_color_color_code = "BL" &&
        inventory_quantities_gender = "M";

-- To check amount of specific product is in the cart table
SELECT SUM(quantity_in_cart) as total_qty_in_cart_table
FROM cart
WHERE 	inventory_quantities_inventory_model = "WLIL" &&
		inventory_quantities_size = 10 &&
        inventory_quantities_color_color_code = "BK" &&
        inventory_quantities_gender = "M";
        
-- To get contents of a specific user's cart
SELECT *
FROM cart
WHERE username = "testUser";

-- Add items to cart - will be inside of transaction within stored procedure
INSERT INTO cart
	(username, sequence, quantity_in_cart, inventory_quantities_inventory_model,
    inventory_quantities_color_color_code, inventory_quantities_size, inventory_quantities_gender)
    VALUES ("testUser2",
		(SELECT highest_seq FROM
			(SELECT username, MAX(sequence) as highest_seq
			FROM cart
			WHERE username = "testUser2") vt
		) + 1,
	1, "abc", "BK", 10, "M");

-- Inner Query for insert statement above - to check for highest sequence for specific username
SELECT highest_seq FROM
		(SELECT username, MAX(sequence) as highest_seq
		FROM cart
		WHERE username = "testUser") vt;
        
-- Update inventory_quantities
UPDATE inventory_quantities iq
SET iq.quantity_on_hand = 8
WHERE 	iq.inventory_model = "abc" &&
        iq.color_color_code = "BK" &&
        iq.size = 10 &&
        iq.gender = "M";

-- Query to return the search results based off of filter requirements        
SELECT 	i.model,
		iq.gender,
        c.color_description,
        iq.size,
        i.model_description,
        t.type_description,
        iq.image_path,
        iq.quantity_on_hand,
        i.price
FROM inventory_quantities iq
	JOIN inventory i
		ON iq.inventory_model = i.model
	JOIN type t
		ON t.type_id = i.type_type_id
	JOIN color c
		ON c.color_code = iq.color_color_code;

-- Complete inventory valuation        
SELECT SUM(iq.quantity_on_hand * i.price) AS inventory_value
FROM inventory_quantities iq JOIN inventory i
	ON iq.inventory_model = i.model;
    
-- Inventory valuation by model
SELECT i.model, SUM(iq.quantity_on_hand * i.price) AS inventory_value
FROM inventory_quantities iq JOIN inventory i
	ON iq.inventory_model = i.model
GROUP BY i.model;

-- Inventory valuation by gender
SELECT iq.gender, SUM(iq.quantity_on_hand * i.price) AS inventory_value
FROM inventory_quantities iq JOIN inventory i
	ON iq.inventory_model = i.model
GROUP BY iq.gender;

-- Inventory valuation by type
SELECT t.type_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
FROM inventory_quantities iq
	JOIN inventory i
		ON iq.inventory_model = i.model
	JOIN type t
		ON t.type_id = i.type_type_id
GROUP BY t.type_description;

-- Inventory valuation by color
SELECT c.color_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
FROM inventory_quantities iq
	JOIN inventory i
		ON iq.inventory_model = i.model
	JOIN color c
		ON c.color_code = iq.color_color_code
GROUP BY c.color_description;


-- Tests of stored procedures
CALL transaction_addtransaction_checkout_cart_item("testUser", "WLIL", 10, "BK", "M", 1); 	-- arg1:username	arg2:model		arg3:size	arg4:color	arg5:gender		arg6:qty desired
CALL transaction_checkout("testUser");														-- arg1:username
CALL getFilteredProductList("BK", "M", -1);													-- arg1:color		arg2:gender		arg3:type_id (1=lifter,2=runner,3=trainer)	NOTE:arg1 & arg2 can = "", arg3 must be < 0 to be "blank"
CALL getInventoryValuation(5);																-- arg1:valuationType (1=sumOfAll,2=byModel,3=byGender,4=byType,5=byColor)
