		-- Below are five stored procedures that are easy to call and contain one
		-- or more queries, update, insert, or deletes to achieve a certain goal.
		-- See the comments below for details.

-- **********************************************************************************
-- =============	transaction_add_cart_item	====================================|
-- Stored Procedure to add items to the cart table.									|
-- This should be the only way that someone enters data into the cart table			|
-- =============	Argument Breakdown	============================================|
-- arg definition		fk constraint source										|
-- arg1:username		users														|
-- arg2:model			inventory_inventory_quantities								|
-- arg3:size			inventory_inventory_quantities								|
-- arg4:color			inventory_inventory_quantities								|
-- arg5:gender																		|
-- arg6:qty desired																	|
-- =============	Notes	========================================================|
-- arg6 must be greater than 0 to result in an add									|
-- =================================================================================|
CALL transaction_add_cart_item("generic", "WLIL", 10, "BK", "M", 1);			--  |
-- **********************************************************************************

-- **********************************************************************************
-- =============	transaction_checkout	========================================|
-- Stored Procedure to remove items from cart and inventory.						|
-- This should be the only way that the cart is emptied during checkout				|
-- =============	Argument Breakdown	============================================|
-- arg definition		fk constraint source										|
-- arg1:username		users														|
-- =================================================================================|
CALL transaction_checkout("generic");											--  |
-- **********************************************************************************

-- **********************************************************************************
-- =============	getFilteredProductList	========================================|
-- Stored Procedure provide filtered search results.								|
-- This should be the primary method of searching for products						|
-- =============	Argument Breakdown	============================================|
-- arg definition		fk constraint source										|
-- arg1:color			color														|
-- arg2:gender																		|
-- arg3:type			inventory													|
-- arg4:size																		|
-- =============	Notes	========================================================|
-- If arg 1, 2 & 3 are passed as an empty strings, the filter will not be			|
-- applied on those search parameters.												|
-- If arg 4 is <=0 then it will be interpeted as the other args that were			|
-- passed as an empty string.														|
-- =================================================================================|
CALL getFilteredProductList("GR", "M", -1, 10);									--  |
-- **********************************************************************************

-- **********************************************************************************
-- =============	getInventoryValuation	========================================|
-- Stored Procedure to get aggregate data from various tables and insert			|
-- different views.																	|
-- =============	Argument Breakdown	============================================|
-- arg definition		fk constraint source										|
-- arg1:reportNumber																|
-- =============	Notes	========================================================|
-- arg1=1:Complete inventory valuation												|
-- arg1=2:Inventory valuation by model												|
-- arg1=3:Inventory valuation by gender												|
-- arg1=4:Inventory valuation by type												|
-- arg1=5:Inventory valuation by color												|
-- arg1=6:Average Sales Price - Entire Inventory									|
-- arg1=7:Total Quantity by model													|
-- arg1=8:Total Qty available (quantity_on_hand - quantity_in_cart) by uniq product	|
-- arg1=9:Total Qty available (quantity_on_hand - quantity_in_cart) by Model		|
-- arg1=10:Total Qty available (quantity_on_hand - quantity_in_cart) by size		|
-- arg1=11:Total Qty available (quantity_on_hand - quantity_in_cart) by color		|
-- arg1=12:Total Qty available (quantity_on_hand - quantity_in_cart) by gender		|
-- =================================================================================|
CALL getInventoryValuation(12);													--  |
-- **********************************************************************************

-- **********************************************************************************
-- =============	getCartItems	================================================|
-- Stored Procedure to get all cart items by user.									|
-- =============	Argument Breakdown	============================================|
-- arg definition		fk constraint source										|
-- arg1:username		users														|
-- =================================================================================|
CALL getCartItems("generic");													--  |
-- **********************************************************************************

			-- =================================================================================
			-- =================================================================================
			-- Below are a bunch of queries that I made that I thought would be useful and are
			-- available for anyeone to modify and use for their own purposes.
			-- =================================================================================
			-- =================================================================================

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
-- Average Sales Price - Entire Inventory
SELECT iq.inventory_model, SUM(iq.quantity_on_hand) AS total_qty_on_hand
FROM inventory_quantities iq
GROUP BY iq.inventory_model;
-- Total Qty in Cart by model
SELECT c.inventory_quantities_inventory_model, SUM(quantity_in_cart) AS total_quantity_in_cart
FROM cart c
GROUP BY c.inventory_quantities_inventory_model;
-- Total Qty available (quantity_on_hand - quantity_in_cart) by each unique product
SELECT iq.inventory_model, iq.size, iq.color_color_code, iq.gender, SUM(iq.quantity_on_hand) - SUM(COALESCE(c.quantity_in_cart, 0)) AS quantity_available
FROM inventory_quantities iq LEFT JOIN (SELECT 	inventory_quantities_inventory_model, inventory_quantities_color_color_code, 
												inventory_quantities_size, inventory_quantities_gender, SUM(quantity_in_cart) AS quantity_in_cart
										FROM cart vc
                                        GROUP BY 	inventory_quantities_inventory_model, inventory_quantities_color_color_code,
													inventory_quantities_size, inventory_quantities_gender) c
	ON 	iq.inventory_model = c.inventory_quantities_inventory_model &&
		iq.size = c.inventory_quantities_size &&
        iq.color_color_code = c.inventory_quantities_color_color_code &&
        iq.gender = c.inventory_quantities_gender
GROUP BY iq.inventory_model, iq.size, iq.color_color_code, iq.gender;
-- Total Qty available (quantity_on_hand - quantity_in_cart) by Model
SELECT iq.inventory_model, SUM(iq.quantity_on_hand) - SUM(COALESCE(c.quantity_in_cart, 0)) AS quantity_available
FROM inventory_quantities iq LEFT JOIN (SELECT 	inventory_quantities_inventory_model, inventory_quantities_color_color_code, 
												inventory_quantities_size, inventory_quantities_gender, SUM(quantity_in_cart) AS quantity_in_cart
										FROM cart vc
                                        GROUP BY 	inventory_quantities_inventory_model, inventory_quantities_color_color_code,
													inventory_quantities_size, inventory_quantities_gender) c
	ON 	iq.inventory_model = c.inventory_quantities_inventory_model &&
		iq.size = c.inventory_quantities_size &&
        iq.color_color_code = c.inventory_quantities_color_color_code &&
        iq.gender = c.inventory_quantities_gender
GROUP BY iq.inventory_model;
-- Total Qty available (quantity_on_hand - quantity_in_cart) by size
SELECT iq.size, SUM(iq.quantity_on_hand) - SUM(COALESCE(c.quantity_in_cart, 0)) AS quantity_available
FROM inventory_quantities iq LEFT JOIN (SELECT 	inventory_quantities_inventory_model, inventory_quantities_color_color_code, 
												inventory_quantities_size, inventory_quantities_gender, SUM(quantity_in_cart) AS quantity_in_cart
										FROM cart vc
                                        GROUP BY 	inventory_quantities_inventory_model, inventory_quantities_color_color_code,
													inventory_quantities_size, inventory_quantities_gender) c
	ON 	iq.inventory_model = c.inventory_quantities_inventory_model &&
		iq.size = c.inventory_quantities_size &&
        iq.color_color_code = c.inventory_quantities_color_color_code &&
        iq.gender = c.inventory_quantities_gender
GROUP BY iq.size;
-- Total Qty available (quantity_on_hand - quantity_in_cart) by color
SELECT iq.color_color_code, SUM(iq.quantity_on_hand) - SUM(COALESCE(c.quantity_in_cart, 0)) AS quantity_available
FROM inventory_quantities iq LEFT JOIN (SELECT 	inventory_quantities_inventory_model, inventory_quantities_color_color_code, 
												inventory_quantities_size, inventory_quantities_gender, SUM(quantity_in_cart) AS quantity_in_cart
										FROM cart vc
                                        GROUP BY 	inventory_quantities_inventory_model, inventory_quantities_color_color_code,
													inventory_quantities_size, inventory_quantities_gender) c
	ON 	iq.inventory_model = c.inventory_quantities_inventory_model &&
		iq.size = c.inventory_quantities_size &&
        iq.color_color_code = c.inventory_quantities_color_color_code &&
        iq.gender = c.inventory_quantities_gender
GROUP BY iq.color_color_code;
-- Total Qty available (quantity_on_hand - quantity_in_cart) by gender
SELECT iq.gender, SUM(iq.quantity_on_hand) - SUM(COALESCE(c.quantity_in_cart, 0)) AS quantity_available
FROM inventory_quantities iq LEFT JOIN (SELECT 	inventory_quantities_inventory_model, inventory_quantities_color_color_code, 
												inventory_quantities_size, inventory_quantities_gender, SUM(quantity_in_cart) AS quantity_in_cart
										FROM cart vc
                                        GROUP BY 	inventory_quantities_inventory_model, inventory_quantities_color_color_code,
													inventory_quantities_size, inventory_quantities_gender) c
	ON 	iq.inventory_model = c.inventory_quantities_inventory_model &&
		iq.size = c.inventory_quantities_size &&
        iq.color_color_code = c.inventory_quantities_color_color_code &&
        iq.gender = c.inventory_quantities_gender
GROUP BY iq.gender;