CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `transaction_add_cart_item`(
					IN login_user VARCHAR(15),
                    IN product_model VARCHAR(15),
                    IN product_size DECIMAL(3,1),
                    IN product_color_code VARCHAR(2),
                    IN product_gender VARCHAR(1),
                    IN desired_qty INT(11))
transation: BEGIN

-- Find the available quantity of the desired product
SET @availableQty := 
	(SELECT quantity_on_hand
	FROM inventory_quantities
	WHERE 	inventory_model = product_model &&
			size = product_size &&
            gender = product_gender &&
			color_color_code = product_color_code);

-- Find the total allocated quantity that is in the cart for the desired product
SET @cartQty := 
	(SELECT COALESCE(SUM(quantity_in_cart), 0)
	FROM cart
	WHERE 	inventory_quantities_inventory_model = product_model &&
			inventory_quantities_size = product_size &&
            inventory_quantities_gender = product_gender &&
			inventory_quantities_color_color_code = product_color_code);

-- Check to see if the desired quantity is available for cart allocation. End transation early if not
IF desired_qty > @availableQty - @cartQty THEN
	LEAVE transation;
END IF;

SET @highestSeq := (SELECT highest_seq FROM
						(SELECT username, COALESCE(MAX(sequence), 0) as highest_seq
						FROM cart
						WHERE username = login_user) vt);

START TRANSACTION;
	-- Providing that the quantities work out, insert the quantities into the cart table
	INSERT INTO cart
	(username, sequence, quantity_in_cart, inventory_quantities_inventory_model,
    inventory_quantities_color_color_code, inventory_quantities_size, inventory_quantities_gender)
    VALUES (login_user, @highestSeq + 1, desired_qty, product_model, 
			product_color_code, product_size, product_gender);
COMMIT;
END