CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `getInventoryValuation`(IN valuationType INT(1))
transation: BEGIN
	IF valuationType = 1 THEN
		-- Complete inventory valuation  
		SELECT "All Inventory", SUM(iq.quantity_on_hand * i.price) AS inventory_value
		FROM inventory_quantities iq JOIN inventory i
			ON iq.inventory_model = i.model;
	ELSEIF valuationType = 2 THEN
		-- Inventory valuation by model
		SELECT i.model, SUM(iq.quantity_on_hand * i.price) AS inventory_value
		FROM inventory_quantities iq JOIN inventory i
			ON iq.inventory_model = i.model
		GROUP BY i.model;
	ELSEIF valuationType = 3 THEN
		-- Inventory valuation by gender
		SELECT iq.gender, SUM(iq.quantity_on_hand * i.price) AS inventory_value
		FROM inventory_quantities iq JOIN inventory i
			ON iq.inventory_model = i.model
		GROUP BY iq.gender;
	ELSEIF valuationType = 4 THEN
		-- Inventory valuation by type
		SELECT t.type_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
		FROM inventory_quantities iq
			JOIN inventory i
				ON iq.inventory_model = i.model
			JOIN type t
				ON t.type_id = i.type_type_id
		GROUP BY t.type_description;
	ELSEIF valuationType = 5 THEN
		-- Inventory valuation by color
		SELECT c.color_description, SUM(iq.quantity_on_hand * i.price) AS inventory_value
		FROM inventory_quantities iq
			JOIN inventory i
				ON iq.inventory_model = i.model
			JOIN color c
				ON c.color_code = iq.color_color_code
		GROUP BY c.color_description;
	END IF;
END