CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `getCartItems`(IN login_user VARCHAR(15))
BEGIN

SELECT c.quantity_in_cart, c.inventory_quantities_inventory_model,
	   c.inventory_quantities_color_color_code, c.inventory_quantities_size,
	   c.inventory_quantities_gender, iq.image_path
FROM cart c JOIN inventory_quantities iq 
ON 	c.inventory_quantities_inventory_model = iq.inventory_model AND 
	c.inventory_quantities_color_color_code = iq.color_color_code AND
	c.inventory_quantities_size = iq.size AND
	c.inventory_quantities_gender = iq.gender
WHERE c.username = login_user;

END