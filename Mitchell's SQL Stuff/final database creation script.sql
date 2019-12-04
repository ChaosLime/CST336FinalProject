-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema cst336_db030
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema cst336_db030
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `cst336_db030` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci ;
USE `cst336_db030` ;

-- -----------------------------------------------------
-- Table `cst336_db030`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cst336_db030`.`users` ;

CREATE TABLE IF NOT EXISTS `cst336_db030`.`users` (
  `username` VARCHAR(15) NOT NULL,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  `admin` TINYINT(4) NOT NULL,
  PRIMARY KEY (`username`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`color`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cst336_db030`.`color` ;

CREATE TABLE IF NOT EXISTS `cst336_db030`.`color` (
  `color_code` VARCHAR(2) NOT NULL,
  `color_description` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`color_code`),
  UNIQUE INDEX `color_code_UNIQUE` (`color_code` ASC) ,
  UNIQUE INDEX `color_description_UNIQUE` (`color_description` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_unicode_ci;


-- -----------------------------------------------------
-- Table `cst336_db030`.`type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `cst336_db030`.`type` ;

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
DROP TABLE IF EXISTS `cst336_db030`.`inventory` ;

CREATE TABLE IF NOT EXISTS `cst336_db030`.`inventory` (
  `model` VARCHAR(15) NOT NULL,
  `model_description` VARCHAR(255) NOT NULL,
  `model_detailed_description` VARCHAR(1024) NULL DEFAULT NULL,
  `price` DECIMAL(5,2) UNSIGNED NOT NULL,
  `type_type_id` INT(11) NOT NULL,
  PRIMARY KEY (`model`),
  UNIQUE INDEX `part_code_UNIQUE` (`model` ASC) ,
  INDEX `fk_inventory_type1_idx` (`type_type_id` ASC) ,
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
DROP TABLE IF EXISTS `cst336_db030`.`inventory_quantities` ;

CREATE TABLE IF NOT EXISTS `cst336_db030`.`inventory_quantities` (
  `inventory_model` VARCHAR(15) NOT NULL,
  `color_color_code` VARCHAR(2) NOT NULL,
  `size` DECIMAL(3,1) NOT NULL,
  `gender` VARCHAR(1) NOT NULL,
  `quantity_on_hand` INT(10) UNSIGNED NOT NULL,
  `image_path` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`inventory_model`, `color_color_code`, `size`, `gender`),
  INDEX `fk_inventory_quantities_inventory_idx` (`inventory_model` ASC) ,
  INDEX `fk_inventory_quantities_color1_idx` (`color_color_code` ASC) ,
  INDEX `size` (`size` ASC) ,
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
DROP TABLE IF EXISTS `cst336_db030`.`cart` ;

CREATE TABLE IF NOT EXISTS `cst336_db030`.`cart` (
  `username` VARCHAR(15) NOT NULL,
  `sequence` INT(11) NOT NULL,
  `quantity_in_cart` INT(10) UNSIGNED NULL DEFAULT NULL,
  `inventory_quantities_inventory_model` VARCHAR(15) NOT NULL,
  `inventory_quantities_color_color_code` VARCHAR(2) NOT NULL,
  `inventory_quantities_size` DECIMAL(3,1) NOT NULL,
  `inventory_quantities_gender` VARCHAR(1) NOT NULL,
  PRIMARY KEY (`username`, `sequence`),
  INDEX `fk_cart_inventory_quantities1_idx` (`inventory_quantities_inventory_model` ASC, `inventory_quantities_color_color_code` ASC, `inventory_quantities_size` ASC, `inventory_quantities_gender` ASC) ,
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
DROP TABLE IF EXISTS `cst336_db030`.`favorites` ;

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
-- procedure transaction_add_cart_item
-- -----------------------------------------------------

USE `cst336_db030`;
DROP procedure IF EXISTS `cst336_db030`.`transaction_add_cart_item`;

DELIMITER $$
USE `cst336_db030`$$
CREATE DEFINER=`cst336_dbUser030`@`%` PROCEDURE `transaction_add_cart_item`(
					IN login_user VARCHAR(15),
                    IN product_model VARCHAR(15),
                    IN product_size INT(11),
                    IN product_color_code VARCHAR(2),
                    IN desired_qty INT(11))
transation: BEGIN

-- Find the available quantity of the desired product
SET @availableQty := 
	(SELECT quantity_on_hand
	FROM inventory_quantities
	WHERE 	inventory_model = product_model &&
			size = product_size &&
			color_color_code = product_color_code);

-- Find the total allocated quantity that is in the cart for the desired product
SET @cartQty := 
	(SELECT SUM(quantity_in_cart)
	FROM cart
	WHERE 	inventory_quantities_inventory_model = product_model &&
			inventory_quantities_size = product_size &&
			inventory_quantities_color_color_code = product_color_code);

-- Check to see if the desired quantity is available for cart allocation. End transation early if not
IF desired_qty > @availableQty - @cartQty THEN
	LEAVE transation;
END IF;

SET @highestSeq := (SELECT highest_seq FROM
						(SELECT username, MAX(sequence) as highest_seq
						FROM cart
						WHERE username = login_user) vt);
                        
IF ISNULL(@highestSeq) THEN
	SET @highestSeq := 0;
END IF;

START TRANSACTION;
	-- Providing that the quantities work out, insert the quantities into the cart table
	INSERT INTO cart
	(username, sequence, quantity_in_cart, inventory_quantities_inventory_model,
    inventory_quantities_color_color_code, inventory_quantities_size)
    VALUES (login_user, @highestSeq + 1, desired_qty, product_model, 
			product_color_code, product_size);
COMMIT;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure transaction_checkout
-- -----------------------------------------------------

USE `cst336_db030`;
DROP procedure IF EXISTS `cst336_db030`.`transaction_checkout`;

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
            inventory_quantities_size
	INTO 	@cart_qty, @product_model,
			@product_color_code, @product_size
	FROM cart c
	WHERE 	c.username = login_user &&
			c.sequence = @cartIndexItr;
            
	SET @availableQty := 
		(SELECT quantity_on_hand
		FROM inventory_quantities iq
		WHERE 	iq.inventory_model = @product_model &&
				iq.size = @product_size &&
				iq.color_color_code = @product_color_code);

	START TRANSACTION;
		UPDATE inventory_quantities iq
		SET iq.quantity_on_hand = 	@availableQty - @cart_qty
		WHERE 	iq.inventory_model = @product_model &&
				iq.color_color_code = @product_color_code &&
				iq.size = @product_size;
        
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
