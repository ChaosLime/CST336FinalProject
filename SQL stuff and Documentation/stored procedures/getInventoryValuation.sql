CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `getInventoryValuation`(IN reportType INT(1))
transation: BEGIN

	IF reportType = 1 THEN
    
			-- Complete inventory valuation  
			SELECT "All Inventory", SUM(iq.quantity_on_hand * i.price) AS inventory_value
			FROM inventory_quantities iq JOIN inventory i
				ON iq.inventory_model = i.model;
            
	ELSEIF reportType = 2 THEN
    
			-- Inventory valuation by model
			SELECT i.model, SUM(iq.quantity_on_hand * i.price) AS inventory_value
			FROM inventory_quantities iq JOIN inventory i
				ON iq.inventory_model = i.model
			GROUP BY i.model;
        
	ELSEIF reportType = 3 THEN
    
			-- Inventory valuation by gender
			SELECT iq.gender, SUM(iq.quantity_on_hand * i.price) AS inventory_value
			FROM inventory_quantities iq JOIN inventory i
				ON iq.inventory_model = i.model
			GROUP BY iq.gender;
        
	ELSEIF reportType = 4 THEN
    
			-- Inventory valuation by type
			SELECT t.type_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
			FROM inventory_quantities iq
				JOIN inventory i
					ON iq.inventory_model = i.model
				JOIN type t
					ON t.type_id = i.type_type_id
			GROUP BY t.type_description;
        
	ELSEIF reportType = 5 THEN
    
			-- Inventory valuation by color
			SELECT c.color_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
			FROM inventory_quantities iq
				JOIN inventory i
					ON iq.inventory_model = i.model
				JOIN color c
					ON c.color_code = iq.color_color_code
			GROUP BY c.color_description;
        
	ELSEIF reportType = 6 THEN
    
			-- Average Sales Price - Entire Inventory
			SELECT ROUND(AVG(i.price), 2) AS average_price
			FROM inventory i;
        
	ELSEIF reportType = 7 THEN
    
			-- Total Quantity by model
			SELECT iq.inventory_model, SUM(iq.quantity_on_hand) AS total_qty_on_hand
			FROM inventory_quantities iq
			GROUP BY iq.inventory_model;
       
	ELSEIF reportType = 8 THEN
    
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
                       
	ELSEIF reportType = 9 THEN

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
               
	ELSEIF reportType = 10 THEN

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
               
	ELSEIF reportType = 11 THEN

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
               
	ELSEIF reportType = 12 THEN

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
        
	END IF;
END