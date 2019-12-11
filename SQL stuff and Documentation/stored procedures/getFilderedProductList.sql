CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `getFilteredProductList`(
					IN color_cd VARCHAR(2),
                    IN gnder VARCHAR(1),
                    IN id_type INT(11),
                    IN model_size DECIMAL(3,1))
BEGIN

SELECT 	i.model,
		iq.gender,
		c.color_description,
        c.color_code,
		iq.size,
		i.model_description,
		i.model_detailed_description,
		t.type_description,
		iq.image_path,
		iq.quantity_on_hand - COALESCE((SELECT SUM(quantity_in_cart)
										FROM cart
										WHERE 	cart.inventory_quantities_inventory_model = i.model &&
												cart.inventory_quantities_color_color_code = c.color_code &&
												cart.inventory_quantities_size = iq.size &&
												cart.inventory_quantities_gender = iq.gender), 0) AS quantity_on_hand,
		i.price
	FROM inventory_quantities iq
		JOIN inventory i
			ON iq.inventory_model = i.model
		JOIN type t
			ON t.type_id = i.type_type_id
		JOIN color c
			ON c.color_code = iq.color_color_code
	WHERE 	IF(color_cd != "", iq.color_color_code = color_cd, TRUE) &&
			IF(gnder != "", iq.gender = gnder, TRUE) &&
			IF(id_type >=0, i.type_type_id = id_type, TRUE) &&
           	IF(model_size != "", iq.size = model_size, TRUE);
END