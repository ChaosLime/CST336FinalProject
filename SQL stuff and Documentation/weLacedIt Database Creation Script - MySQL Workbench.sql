-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema cst336_db030
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `cst336_db030` ;

-- -----------------------------------------------------
-- Schema cst336_db030
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `cst336_db030` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ;
USE `cst336_db030` ;

-- -----------------------------------------------------
-- Table `cst336_db030`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`users` (
  `username` VARCHAR(15) NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(72) NOT NULL,
  `admin` TINYINT(4) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`color`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`color` (
  `color_code` VARCHAR(2) NOT NULL,
  `color_description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`color_code`),
  UNIQUE INDEX `color_code_UNIQUE` (`color_code` ASC) VISIBLE,
  UNIQUE INDEX `color_description_UNIQUE` (`color_description` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`type`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`type` (
  `type_id` INT(11) NOT NULL,
  `type_description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`type_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`inventory` (
  `model` VARCHAR(15) NOT NULL,
  `model_description` VARCHAR(255) NOT NULL,
  `model_detailed_description` VARCHAR(1024) NULL DEFAULT NULL,
  `price` DECIMAL(5,2) UNSIGNED NOT NULL,
  `type_type_id` INT(11) NOT NULL,
  PRIMARY KEY (`model`),
  UNIQUE INDEX `part_code_UNIQUE` (`model` ASC) VISIBLE,
  INDEX `fk_inventory_type1_idx` (`type_type_id` ASC) VISIBLE,
  CONSTRAINT `fk_inventory_type1`
    FOREIGN KEY (`type_type_id`)
    REFERENCES `cst336_db030`.`type` (`type_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`inventory_quantities`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`inventory_quantities` (
  `inventory_model` VARCHAR(15) NOT NULL,
  `color_color_code` VARCHAR(2) NOT NULL,
  `size` DECIMAL(3,1) NOT NULL,
  `gender` VARCHAR(1) NOT NULL,
  `quantity_on_hand` INT(10) UNSIGNED NOT NULL,
  `image_path` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`inventory_model`, `color_color_code`, `size`, `gender`),
  INDEX `fk_inventory_quantities_inventory_idx` (`inventory_model` ASC) VISIBLE,
  INDEX `fk_inventory_quantities_color1_idx` (`color_color_code` ASC) VISIBLE,
  INDEX `size` (`size` ASC) VISIBLE,
  CONSTRAINT `fk_inventory_quantities_color`
    FOREIGN KEY (`color_color_code`)
    REFERENCES `cst336_db030`.`color` (`color_code`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_quantities_inventory`
    FOREIGN KEY (`inventory_model`)
    REFERENCES `cst336_db030`.`inventory` (`model`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`cart`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`cart` (
  `username` VARCHAR(15) NOT NULL,
  `sequence` INT(11) NOT NULL,
  `quantity_in_cart` INT(10) UNSIGNED NULL DEFAULT NULL,
  `inventory_quantities_inventory_model` VARCHAR(15) NOT NULL,
  `inventory_quantities_color_color_code` VARCHAR(2) NOT NULL,
  `inventory_quantities_size` DECIMAL(3,1) NOT NULL,
  `inventory_quantities_gender` VARCHAR(1) NOT NULL,
  PRIMARY KEY (`username`, `sequence`),
  INDEX `fk_cart_inventory_quantities1_idx` (`inventory_quantities_inventory_model` ASC, `inventory_quantities_color_color_code` ASC, `inventory_quantities_size` ASC, `inventory_quantities_gender` ASC) VISIBLE,
  CONSTRAINT `cart_ibfk`
    FOREIGN KEY (`username`)
    REFERENCES `cst336_db030`.`users` (`username`),
  CONSTRAINT `fk_cart_inventory_quantities1`
    FOREIGN KEY (`inventory_quantities_inventory_model` , `inventory_quantities_color_color_code` , `inventory_quantities_size` , `inventory_quantities_gender`)
    REFERENCES `cst336_db030`.`inventory_quantities` (`inventory_model` , `color_color_code` , `size` , `gender`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`favorites`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cst336_db030`.`favorites` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `imageURL` VARCHAR(250) NOT NULL,
  `keyword` VARCHAR(25) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = MyISAM
AUTO_INCREMENT = 29
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;

USE `cst336_db030` ;

-- -----------------------------------------------------
-- procedure getCartItems
-- -----------------------------------------------------

DELIMITER $$
USE `cst336_db030`$$
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

END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getFilteredProductList
-- -----------------------------------------------------

DELIMITER $$
USE `cst336_db030`$$
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure getInventoryValuation
-- -----------------------------------------------------

DELIMITER $$
USE `cst336_db030`$$
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure transaction_add_cart_item
-- -----------------------------------------------------

DELIMITER $$
USE `cst336_db030`$$
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
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure transaction_checkout
-- -----------------------------------------------------

DELIMITER $$
USE `cst336_db030`$$
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
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
