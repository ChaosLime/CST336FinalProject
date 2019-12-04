CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `transaction_checkout`(
					IN login_user VARCHAR(15))
transation: BEGIN

-- Get highest sequence from specific user in Cart table so looping becomes easy
SET @cartIndexItr := 
	(SELECT highest_seq FROM
		(SELECT username, MAX(sequence) as highest_seq
		FROM cart
		WHERE username = login_user) vt);

-- Start loop to iterate through each item in cart
inventory_reduction_loop: LOOP
	SELECT quantity_in_cart, inventory_quantities_inventory_model,
			inventory_quantities_color_color_code,
            inventory_quantities_size, inventory_quantities_gender
	INTO 	@cart_qty, @product_model,
			@product_color_code, @product_size, @product_gender
	FROM cart c
	WHERE 	c.username = login_user &&
			c.sequence = @cartIndexItr;
            
	SET @availableQty := 
		(SELECT quantity_on_hand
		FROM inventory_quantities iq
		WHERE 	iq.inventory_model = @product_model &&
				iq.size = @product_size &&
                iq.gender = @product_gender &&
				iq.color_color_code = @product_color_code);

	START TRANSACTION;
		UPDATE inventory_quantities iq
		SET iq.quantity_on_hand = 	@availableQty - @cart_qty
		WHERE 	iq.inventory_model = @product_model &&
				iq.size = @product_size &&
                iq.gender = @product_gender &&
				iq.color_color_code = @product_color_code;
        
        DELETE FROM cart
        WHERE 	username = login_user &&
				sequence = @cartIndexItr;
	COMMIT;
    
    -- Decrement the counter and check to see if we are done. If we are, then leave loop
    SET @cartIndexItr := @cartIndexItr - 1;
    IF @cartIndexItr < 0 THEN
		LEAVE inventory_reduction_loop;
	END IF;
END LOOP;
END