CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `getFilteredProductList`(
					IN color_cd VARCHAR(2),
                    IN gnder VARCHAR(1),
                    IN id_type INT(11))
transation: BEGIN

	SELECT 	i.model,
			iq.gender,
			c.color_description,
			iq.size,
			i.model_description,
			i.model_detailed_description,
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
			ON c.color_code = iq.color_color_code
	WHERE 	IF(color_cd != "", iq.color_color_code = color_cd, TRUE) &&
			IF(gnder != "", iq.gender = gnder, TRUE) &&
			IF(id_type >=0, i.type_type_id = id_type, TRUE);
END