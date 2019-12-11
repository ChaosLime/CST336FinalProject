-- Adminer 4.7.3 MySQL dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP DATABASE IF EXISTS `cst336_db030`;
CREATE DATABASE `cst336_db030` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `cst336_db030`;

DELIMITER ;;

CREATE PROCEDURE `getCartItems`(IN login_user VARCHAR(15))
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

END;;

CREATE PROCEDURE `getFilteredProductList`(
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
END;;

CREATE PROCEDURE `getInventoryValuation`(IN reportType INT(1))
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
END;;

CREATE PROCEDURE `transaction_add_cart_item`(
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
IF desired_qty > @availableQty - @cartQty OR desired_qty <= 0 THEN
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
END;;

CREATE PROCEDURE `transaction_checkout`(
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
END;;

DELIMITER ;

DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart` (
  `username` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `sequence` int(11) NOT NULL,
  `quantity_in_cart` int(10) unsigned DEFAULT NULL,
  `inventory_quantities_inventory_model` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `inventory_quantities_color_color_code` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  `inventory_quantities_size` decimal(3,1) NOT NULL,
  `inventory_quantities_gender` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`username`,`sequence`),
  KEY `fk_cart_inventory_quantities1_idx` (`inventory_quantities_inventory_model`,`inventory_quantities_color_color_code`,`inventory_quantities_size`,`inventory_quantities_gender`),
  CONSTRAINT `cart_ibfk` FOREIGN KEY (`username`) REFERENCES `users` (`username`),
  CONSTRAINT `fk_cart_inventory_quantities1` FOREIGN KEY (`inventory_quantities_inventory_model`, `inventory_quantities_color_color_code`, `inventory_quantities_size`, `inventory_quantities_gender`) REFERENCES `inventory_quantities` (`inventory_model`, `color_color_code`, `size`, `gender`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `cart` (`username`, `sequence`, `quantity_in_cart`, `inventory_quantities_inventory_model`, `inventory_quantities_color_color_code`, `inventory_quantities_size`, `inventory_quantities_gender`) VALUES
('generic',	1,	5,	'WLIL',	'BL',	5.0,	'W'),
('generic',	2,	3,	'WLIL',	'GR',	4.0,	'W'),
('generic',	3,	3,	'WLIL',	'RD',	4.0,	'W'),
('generic',	4,	0,	'WLIL',	'BK',	4.0,	'W'),
('generic',	5,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	6,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	7,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	8,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	9,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	10,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	11,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	12,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	13,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	14,	1,	'WLIL',	'BK',	4.0,	'W'),
('generic',	15,	1,	'WLIL',	'BL',	4.0,	'W'),
('generic',	16,	1,	'WLIL',	'BL',	4.0,	'W'),
('generic',	17,	1,	'WLIL',	'RD',	4.0,	'W'),
('generic',	18,	1,	'WLIL',	'GR',	4.0,	'W'),
('generic',	19,	1,	'WLIR',	'WH',	4.0,	'W'),
('generic',	20,	2,	'WLIL',	'WH',	4.0,	'W'),
('generic',	21,	2,	'WLIL',	'GR',	4.0,	'W'),
('generic',	22,	1,	'WLIL',	'GR',	4.0,	'W'),
('generic',	23,	1,	'WLIR',	'BK',	4.0,	'W'),
('generic',	24,	1,	'WLIL',	'RD',	8.0,	'M'),
('generic',	25,	1,	'WLIL',	'RD',	7.0,	'M'),
('generic',	26,	1,	'WLIL',	'BK',	5.0,	'W'),
('generic',	27,	1,	'WLIT',	'WH',	12.0,	'M'),
('generic',	28,	1,	'WLIL',	'BK',	4.5,	'W'),
('generic',	29,	1,	'WLIL',	'RD',	9.5,	'M'),
('generic',	30,	1,	'WLIL',	'RD',	5.0,	'W'),
('generic',	31,	1,	'WLIL',	'RD',	5.0,	'W'),
('generic',	32,	1,	'WLIL',	'RD',	5.0,	'W'),
('generic',	33,	1,	'WLIL',	'RD',	4.0,	'W'),
('testUser',	1,	1,	'WLIL',	'BK',	10.0,	'M'),
('testUser',	2,	1,	'WLIL',	'BK',	10.0,	'M')
ON DUPLICATE KEY UPDATE `username` = VALUES(`username`), `sequence` = VALUES(`sequence`), `quantity_in_cart` = VALUES(`quantity_in_cart`), `inventory_quantities_inventory_model` = VALUES(`inventory_quantities_inventory_model`), `inventory_quantities_color_color_code` = VALUES(`inventory_quantities_color_color_code`), `inventory_quantities_size` = VALUES(`inventory_quantities_size`), `inventory_quantities_gender` = VALUES(`inventory_quantities_gender`);

DROP TABLE IF EXISTS `color`;
CREATE TABLE `color` (
  `color_code` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  `color_description` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`color_code`),
  UNIQUE KEY `color_code_UNIQUE` (`color_code`),
  UNIQUE KEY `color_description_UNIQUE` (`color_description`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `color` (`color_code`, `color_description`) VALUES
('BK',	'Black'),
('BL',	'Blue'),
('GR',	'Green'),
('RD',	'Red'),
('WH',	'White')
ON DUPLICATE KEY UPDATE `color_code` = VALUES(`color_code`), `color_description` = VALUES(`color_description`);


DROP TABLE IF EXISTS `inventory`;
CREATE TABLE `inventory` (
  `model` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `model_description` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `model_detailed_description` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(5,2) unsigned NOT NULL,
  `type_type_id` int(11) NOT NULL,
  PRIMARY KEY (`model`),
  UNIQUE KEY `part_code_UNIQUE` (`model`),
  KEY `fk_inventory_type1_idx` (`type_type_id`),
  CONSTRAINT `fk_inventory_type1` FOREIGN KEY (`type_type_id`) REFERENCES `type` (`type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `inventory` (`model`, `model_description`, `model_detailed_description`, `price`, `type_type_id`) VALUES
('WLIL',	'A lifter made for lifting. Lift heavy and lift often, you workhorse, you.',	'The leather used in the NOBULL Lifter is hand selected, top grain material, embedded with natural oils. The result is an exceptionally strong and durable leather, with rich texture.;The Lifter\'s stacked leather heel consists of individually cut layers, bonded, waxed, finished and buffed for smooth, beautiful contours that reveal the natural grains. 2-3 hours of precise handwork goes into each heel and outsole.;Molded, removable sockliner.;18.5mm heel to toe drop.',	49.99,	0),
('WLIR',	'The Knit Runner features a lightweight, breathable, stretch knit upper that moves with you.',	'The upper of the Knit Runner features a seamless, breathable and stretch knit sock construction.;The outsole lug pattern was designed for multi-environment usage, at home on the road as well as off.;Reflective laces for visibility when you need it most.;Removable molded anatomical sockliner.;Medial post out of higher durometer EVA.;The Knit Runner comes with two pairs of reflective laces.;10mm heel to toe drop.;Weight: 10.6 oz. (Men\'s Size 9)',	69.99,	1),
('WLIT',	'Run, climb, slide, grind, lift....these kicks have you covered.',	'Lightweight, breathable and flexible protection that moves the way you do. 	The upper of the Trainer features a seamless one-piece construction of SuperFabric®, an extremely durable, breathable and abrasion resistant material.;The SuperFabric® guard plates are applied on a highly flexible mesh base layer, creating a 360 degree shield from zombies, rope climbs, and excuses.;The outsole lug pattern was designed for multi-environment usage, allowing for an easy transition between inside and outside with the right blend of flexibility, traction and support.;High carbon lateral and medial guards for added protection on sidewalls.;Reflective NOBULL logo for visibility when you need it most.;Breathable perforated microsuede tongue.;Molded, anatomical sockliner.;Medial rope grip.;The Trainer comes with two pairs of laces.;4mm heel to toe drop.',	64.99,	2)
ON DUPLICATE KEY UPDATE `model` = VALUES(`model`), `model_description` = VALUES(`model_description`), `model_detailed_description` = VALUES(`model_detailed_description`), `price` = VALUES(`price`), `type_type_id` = VALUES(`type_type_id`);

DROP TABLE IF EXISTS `inventory_quantities`;
CREATE TABLE `inventory_quantities` (
  `inventory_model` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `color_color_code` varchar(2) COLLATE utf8_unicode_ci NOT NULL,
  `size` decimal(3,1) NOT NULL,
  `gender` varchar(1) COLLATE utf8_unicode_ci NOT NULL,
  `quantity_on_hand` int(10) unsigned NOT NULL,
  `image_path` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`inventory_model`,`color_color_code`,`size`,`gender`),
  KEY `fk_inventory_quantities_inventory_idx` (`inventory_model`),
  KEY `fk_inventory_quantities_color1_idx` (`color_color_code`),
  KEY `size` (`size`),
  CONSTRAINT `fk_inventory_quantities_color` FOREIGN KEY (`color_color_code`) REFERENCES `color` (`color_code`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_quantities_inventory` FOREIGN KEY (`inventory_model`) REFERENCES `inventory` (`model`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `inventory_quantities` (`inventory_model`, `color_color_code`, `size`, `gender`, `quantity_on_hand`, `image_path`) VALUES
('WLIL',	'BK',	4.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	4.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	5.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	5.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	6.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	6.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	6.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	7.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	7.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	7.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	7.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	8.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	8.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	8.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	8.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	9.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	9.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	9.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	9.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	10.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	10.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	10.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	10.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	11.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	11.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	11.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	11.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	12.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	12.0,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	12.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	12.5,	'W',	10,	'womens/lifters/black.png'),
('WLIL',	'BK',	13.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	13.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	14.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	14.5,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BK',	15.0,	'M',	10,	'mens/lifters/black.png'),
('WLIL',	'BL',	4.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	4.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	5.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	5.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	6.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	6.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	6.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	7.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	7.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	7.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	7.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	8.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	8.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	8.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	8.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	9.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	9.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	9.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	9.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	10.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	10.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	10.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	10.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	11.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	11.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	11.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	11.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	12.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	12.0,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	12.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	12.5,	'W',	10,	'womens/lifters/blue.png'),
('WLIL',	'BL',	13.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	13.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	14.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	14.5,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'BL',	15.0,	'M',	10,	'mens/lifters/blue.png'),
('WLIL',	'GR',	4.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	4.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	5.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	5.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	6.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	6.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	6.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	7.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	7.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	7.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	7.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	8.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	8.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	8.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	8.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	9.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	9.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	9.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	9.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	10.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	10.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	10.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	10.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	11.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	11.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	11.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	11.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	12.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	12.0,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	12.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	12.5,	'W',	10,	'womens/lifters/green.png'),
('WLIL',	'GR',	13.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	13.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	14.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	14.5,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'GR',	15.0,	'M',	10,	'mens/lifters/green.png'),
('WLIL',	'RD',	4.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	4.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	5.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	5.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	6.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	6.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	6.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	7.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	7.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	7.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	7.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	8.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	8.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	8.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	8.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	9.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	9.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	9.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	9.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	10.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	10.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	10.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	10.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	11.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	11.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	11.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	11.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	12.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	12.0,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	12.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	12.5,	'W',	10,	'womens/lifters/red.png'),
('WLIL',	'RD',	13.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	13.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	14.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	14.5,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'RD',	15.0,	'M',	10,	'mens/lifters/red.png'),
('WLIL',	'WH',	4.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	4.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	5.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	5.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	6.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	6.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	6.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	7.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	7.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	7.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	7.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	8.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	8.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	8.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	8.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	9.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	9.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	9.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	9.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	10.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	10.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	10.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	10.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	11.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	11.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	11.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	11.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	12.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	12.0,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	12.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	12.5,	'W',	10,	'womens/lifters/white.png'),
('WLIL',	'WH',	13.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	13.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	14.0,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	14.5,	'M',	10,	'mens/lifters/white.png'),
('WLIL',	'WH',	15.0,	'M',	10,	'mens/lifters/white.png'),
('WLIR',	'BK',	4.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	4.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	5.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	5.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	6.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	6.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	6.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	7.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	7.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	7.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	7.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	8.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	8.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	8.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	8.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	9.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	9.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	9.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	9.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	10.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	10.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	10.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	10.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	11.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	11.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	11.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	11.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	12.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	12.0,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	12.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	12.5,	'W',	10,	'womens/runners/black.png'),
('WLIR',	'BK',	13.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	13.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	14.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	14.5,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BK',	15.0,	'M',	10,	'mens/runners/black.png'),
('WLIR',	'BL',	4.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	4.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	5.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	5.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	6.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	6.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	6.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	7.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	7.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	7.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	7.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	8.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	8.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	8.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	8.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	9.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	9.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	9.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	9.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	10.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	10.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	10.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	10.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	11.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	11.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	11.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	11.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	12.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	12.0,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	12.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	12.5,	'W',	10,	'womens/runners/blue.png'),
('WLIR',	'BL',	13.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	13.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	14.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	14.5,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'BL',	15.0,	'M',	10,	'mens/runners/blue.png'),
('WLIR',	'GR',	4.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	4.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	5.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	5.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	6.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	6.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	6.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	7.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	7.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	7.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	7.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	8.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	8.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	8.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	8.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	9.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	9.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	9.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	9.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	10.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	10.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	10.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	10.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	11.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	11.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	11.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	11.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	12.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	12.0,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	12.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	12.5,	'W',	10,	'womens/runners/green.png'),
('WLIR',	'GR',	13.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	13.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	14.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	14.5,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'GR',	15.0,	'M',	10,	'mens/runners/green.png'),
('WLIR',	'RD',	4.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	4.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	5.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	5.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	6.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	6.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	6.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	7.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	7.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	7.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	7.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	8.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	8.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	8.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	8.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	9.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	9.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	9.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	9.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	10.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	10.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	10.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	10.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	11.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	11.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	11.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	11.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	12.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	12.0,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	12.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	12.5,	'W',	10,	'womens/runners/red.png'),
('WLIR',	'RD',	13.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	13.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	14.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	14.5,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'RD',	15.0,	'M',	10,	'mens/runners/red.png'),
('WLIR',	'WH',	4.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	4.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	5.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	5.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	6.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	6.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	6.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	7.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	7.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	7.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	7.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	8.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	8.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	8.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	8.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	9.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	9.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	9.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	9.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	10.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	10.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	10.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	10.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	11.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	11.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	11.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	11.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	12.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	12.0,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	12.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	12.5,	'W',	10,	'womens/runners/white.png'),
('WLIR',	'WH',	13.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	13.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	14.0,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	14.5,	'M',	10,	'mens/runners/white.png'),
('WLIR',	'WH',	15.0,	'M',	10,	'mens/runners/white.png'),
('WLIT',	'BK',	4.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	4.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	5.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	5.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	6.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	6.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	6.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	7.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	7.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	7.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	7.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	8.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	8.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	8.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	8.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	9.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	9.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	9.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	9.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	10.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	10.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	10.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	10.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	11.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	11.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	11.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	11.5,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	12.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	12.0,	'W',	10,	'womens/trainers/black.png'),
('WLIT',	'BK',	12.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	13.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	13.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	14.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	14.5,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BK',	15.0,	'M',	10,	'mens/trainers/black.png'),
('WLIT',	'BL',	4.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	4.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	5.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	5.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	6.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	6.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	6.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	7.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	7.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	7.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	7.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	8.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	8.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	8.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	8.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	9.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	9.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	9.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	9.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	10.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	10.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	10.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	10.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	11.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	11.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	11.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	11.5,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	12.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	12.0,	'W',	10,	'womens/trainers/blue.png'),
('WLIT',	'BL',	12.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	13.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	13.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	14.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	14.5,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'BL',	15.0,	'M',	10,	'mens/trainers/blue.png'),
('WLIT',	'GR',	4.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	4.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	5.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	5.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	6.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	6.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	6.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	7.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	7.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	7.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	7.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	8.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	8.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	8.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	8.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	9.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	9.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	9.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	9.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	10.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	10.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	10.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	10.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	11.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	11.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	11.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	11.5,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	12.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	12.0,	'W',	10,	'womens/trainers/green.png'),
('WLIT',	'GR',	12.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	13.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	13.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	14.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	14.5,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'GR',	15.0,	'M',	10,	'mens/trainers/green.png'),
('WLIT',	'RD',	4.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	4.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	5.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	5.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	6.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	6.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	6.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	7.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	7.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	7.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	7.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	8.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	8.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	8.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	8.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	9.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	9.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	9.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	9.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	10.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	10.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	10.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	10.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	11.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	11.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	11.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	11.5,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	12.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	12.0,	'W',	10,	'womens/trainers/red.png'),
('WLIT',	'RD',	12.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	13.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	13.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	14.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	14.5,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'RD',	15.0,	'M',	10,	'mens/trainers/red.png'),
('WLIT',	'WH',	4.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	4.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	5.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	5.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	6.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	6.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	6.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	7.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	7.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	7.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	7.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	8.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	8.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	8.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	8.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	9.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	9.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	9.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	9.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	10.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	10.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	10.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	10.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	11.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	11.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	11.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	11.5,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	12.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	12.0,	'W',	10,	'womens/trainers/white.png'),
('WLIT',	'WH',	12.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	13.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	13.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	14.0,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	14.5,	'M',	10,	'mens/trainers/white.png'),
('WLIT',	'WH',	15.0,	'M',	10,	'mens/trainers/white.png')
ON DUPLICATE KEY UPDATE `inventory_model` = VALUES(`inventory_model`), `color_color_code` = VALUES(`color_color_code`), `size` = VALUES(`size`), `gender` = VALUES(`gender`), `quantity_on_hand` = VALUES(`quantity_on_hand`), `image_path` = VALUES(`image_path`);

DROP TABLE IF EXISTS `type`;
CREATE TABLE `type` (
  `type_id` int(11) NOT NULL,
  `type_description` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `type` (`type_id`, `type_description`) VALUES
(0,	'Lifter'),
(1,	'Runner'),
(2,	'Trainer')
ON DUPLICATE KEY UPDATE `type_id` = VALUES(`type_id`), `type_description` = VALUES(`type_description`);

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `username` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `first_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `last_name` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(72) COLLATE utf8_unicode_ci NOT NULL,
  `admin` tinyint(4) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO `users` (`username`, `first_name`, `last_name`, `password`, `admin`) VALUES
('asdf',	'asdf',	'asdf',	'asdf',	0),
('generic',	'test',	'user',	'password',	0),
('testAdmin',	'Jane',	'Doe',	'123456',	1),
('testUser',	'John',	'Doe',	'123456',	0)
ON DUPLICATE KEY UPDATE `username` = VALUES(`username`), `first_name` = VALUES(`first_name`), `last_name` = VALUES(`last_name`), `password` = VALUES(`password`), `admin` = VALUES(`admin`);

-- 2019-12-10 23:54:13