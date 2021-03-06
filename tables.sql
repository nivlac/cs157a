use RReservation;

-- delete existing tables
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS Restaurant;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS ReservationArchive;
SET FOREIGN_KEY_CHECKS=1;

-- allow events to run
SET GLOBAL event_scheduler = ON;
SET SQL_SAFE_UPDATES = 0;


-- create tables

CREATE TABLE Customer(
	customer_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(128) UNIQUE NOT NULL,
    login_password VARCHAR(256) NOT NULL,
    my_name VARCHAR(256),
    phone_number VARCHAR(20));

CREATE TABLE Restaurant(
	restaurant_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(256) NOT NULL,
    capacity INTEGER NOT NULL);

CREATE TABLE Manager(
	manager_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    my_name VARCHAR(256) ,
    username VARCHAR(128) UNIQUE NOT NULL,
    login_password VARCHAR(256) NOT NULL,
    restaurant_id INTEGER,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id));

CREATE TABLE Reservation(
	reservation_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    reservation_timestamp TIMESTAMP,
    reservation_duration TIME, 
    restaurant_id INTEGER,
    customer_id INTEGER,
    party_count INTEGER,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id));

CREATE TABLE ReservationArchive( 
	reservation_id INTEGER NOT NULL PRIMARY KEY,
    reservation_timestamp TIMESTAMP,
    reservation_duration TIME, 
    restaurant_id INTEGER,
    customer_id INTEGER,
    party_count INTEGER,
    FOREIGN KEY (restaurant_id) REFERENCES Restaurant(restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id));


-- triggers 

-- delete Reservations of deleted users 
CREATE TRIGGER on_delete_user 
BEFORE DELETE ON Customer FOR EACH ROW
DELETE FROM Reservation 
WHERE old.customer_id = customer_id;

-- deleted reservation goes into reservationarchive
CREATE TRIGGER trigger_delete_reservation
BEFORE DELETE ON reservation
FOR EACH ROW
    INSERT INTO reservationarchive 
    SELECT * 
      FROM reservation
     WHERE reservation_id = OLD.reservation_id; 
    
    
-- delete reservations past their start time
-- triggered on viewing reservationarchive
DELIMITER $$
DROP PROCEDURE IF EXISTS cleanup_old_reservations$$

CREATE PROCEDURE cleanup_old_reservations ()
BEGIN
START TRANSACTION;
  DELETE FROM reservation
  WHERE reservation_timestamp < NOW();
COMMIT;
END$$

DELIMITER ;
     

-- insert predefined tuples

INSERT INTO Customer (username, login_password, my_name, phone_number)
	VALUES("username1", "password1", "Trevor Nemanic", "408-000-0001");
INSERT INTO Customer (username, login_password, my_name, phone_number)
	VALUES("username2", "password2", "Calvin Keith", "408-000-0002");
INSERT INTO Customer (username, login_password, my_name, phone_number)
	VALUES("username3", "password3", "Jonathan Pak", "408-000-0003");
INSERT INTO Customer (username, login_password, my_name, phone_number)
	VALUES("username4", "password4", "Stephen Curry", "408-000-0004");
    
INSERT INTO RESTAURANT(restaurant_name, capacity)
	VALUES("Creasian", 25);    
INSERT INTO RESTAURANT(restaurant_name, capacity)
	VALUES("Peanuts", 50);
    
INSERT INTO Manager(my_name, username, login_password, restaurant_id)
	VALUES("Satya Nadella", "username1", "password1", 1);
INSERT INTO Manager(my_name, username, login_password, restaurant_id)
	VALUES("Tim Cook", "username2", "password2", 1);
INSERT INTO Manager(my_name, username, login_password, restaurant_id)
	VALUES("Ginni Rometty", "username3", "password3", 2);
    
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-02 18:00:00', '03:00:00',  1, 1, 20);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-02 19:00:00', '02:00:00',  1, 1, 1);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-02 20:00:00', '01:00:00',  1, 1, 1);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-02 19:00:00', '01:00:00',  1, 1, 1);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-02 20:00:00', '02:00:00',  1, 1, 1);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-03 20:00:00', '01:00:00',  1, 1, 1);
    
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-03 18:00:00', '01:00:00',  2, 1, 40);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2015-12-03 18:00:00', '01:00:00',  2, 1, 10);
    
-- past reservations
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2000-02-21 03:30:00', '00:15:00',  1, 1, 13);
INSERT INTO Reservation(reservation_timestamp, reservation_duration, restaurant_id, customer_id, party_count)
	VALUES('2014-11-03 05:00:00', '00:30:00',  2, 1, 10);
