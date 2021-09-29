-- Caballero Views
create view vw_employee as
SELECT 
		employee.EmployeeID as "Employee ID",
		employee.FName as "First Name",
        employee.LName as "Last Name",
        employee.JoinDate as "Join Date",
        manager.FName as "Manager First Name",
        manager.LName as "Manager Last Name",
        job.JobName as "Job Name",
        department.DepartmentName as "Department Name"
FROM (employee, manager, job, department)
join manager as Manager_ID on employee.ManagerID=manager.ManagerID
join job as Job_ID on employee.JobID=job.JobID
join department as Department_ID on employee.DepartmentID=department.DepartmentID
GROUP BY employee.EmployeeID
ORDER BY employee.LName;

select*from vw_employee;
	
create view vw_active_reservations as 
SELECT
	reservations.ReservationID as "Reservation ID",
    reservations.Service as "Service",
    employee.LName as "Employee Last Name",
    guests.Lname as "Guest Last Name",
    reservations.StartDate as "Start Date",
    reservations.StartTime as "Start Time",
    reservations.EndDate as "End Date",
    reservations.EndTime as "End Time",
    payment.Amount as "Amount Due",
    AmenitiesListID as "Amenities List ID"
FROM
	(reservations, payment, guests, employee)
join payment as payment_ID on reservations.PaymentID=payment.PaymentID
join guests as guest_ID on reservations.GuestID=guests.GuestID
join employee as employee_ID on reservations.EmployeeID=employee.EmployeeID
WHERE
	ReservationActive=1
GROUP BY reservations.ReservationID;
    
select*from vw_active_reservations;

create view vw_greater_than_one_thousand as
SELECT
	reservations.ReservationID as "Reservation ID",
    guests.Lname as "Guest Last Name",
    payment.Amount as "Amount Due"
FROM
	(reservations, guests, payment)
join reservations as `payment_ID` on reservations.PaymentID=payment.PaymentID
join reservations as `guest_ID` on reservations.GuestID=guests.GuestID
WHERE
	payment.Amount > 1000
GROUP BY 
	reservations.ReservationID
ORDER BY
	payment.Amount;
    
select*from vw_greater_than_one_thousand;
    
create view roomAndRoomType as
SELECT
	room.RoomNumber as "Room Number",
    roomtype.RoomTypeName as "Room Type",
    roomtype.MaxGuestQuantity as "Max Guest Quantity",
    roomtype.CostPerNight as "Cost Per Night"
FROM
	(room, roomtype)
join roomtype as roomtype_ID on room.RoomTypeID=roomtype.RoomTypeID
GROUP BY room.RoomNumber;

select*from roomAndRoomType;

--End Caballero Views


-- Caballero Stored Procedures

DELIMITER //
create procedure departmentStaff(IN department_Name varchar(15))
BEGIN
	SELECT
		employee.FName as "First Name",
        employee.LName as "Last Name",
        department.DepartmentName as "Department Name"
	FROM (employee, department)
    join employee as employeeTable on department.DepartmentID=employee.DepartmentID
    WHERE
		department.DepartmentName=department_Name AND department.DepartmentID=employee.DepartmentID
	GROUP BY employee.FName, employee.LName;
END//
DELIMITER ;

CALL departmentStaff("Human Resources");

DELIMITER //
create procedure deleteEmployee(IN employeeID int)
BEGIN
	DELETE FROM employee WHERE employee.EmployeeID=employeeID;
END //
DELIMITER ;

CALL deleteEmployee(75201);

select*from employee;

insert into employee (EmployeeID, FName, LName, JoinDate, ManagerID, JobID, DepartmentID)
values (75201, "Brucie", "Laraway", '2010/02/03', 550016, 60622, 910001);

DELIMITER //
create procedure addRoomReservation(IN employee_ID int, IN guest_ID int, IN start_Date date, IN start_Time time, 
IN end_Date date, IN end_Time time, IN payment_ID int, IN amenities_ID int, IN room_ID int, IN roomkey_ID int)
BEGIN
	IF NOT EXISTS(select*from roomkey, room where room.RoomNumber=room_ID 
    AND roomkey.RoomKeyID=roomkey_ID AND roomkey.Active=1) THEN
		insert into reservations (ReservationID, Service, EmployeeID, GuestID, StartDate, StartTime, 
        EndDate, EndTime, PaymentID, ReservationActive, AmenitiesListID)
		values ((FLOOR(RAND()*(2999999-2000000+1))+2000000), 'Room', employee_ID, guest_ID, 
        start_Date, start_Time, end_Date, end_Time, payment_ID, 1, amenities_ID);
		UPDATE guests SET RoomNumber=room_ID WHERE GuestID=guest_ID;
        select*from guests where GuestID=guest_ID;
        UPDATE room SET RoomKeyID=roomkey_ID WHERE RoomNumber=room_ID;
        select*from room where RoomNumber=room_ID;
		UPDATE roomkey SET roomkey.Active=1 WHERE RoomKeyID=roomkey_ID;
        select*from roomkey where RoomKeyID=roomkey_ID;
    END IF;
END //
DELIMITER ;

CALL addRoomReservation(75757, 2356, '2020-12-08', '15:30:00', '2020-12-11', '10:30:00',76995303, 57743165, 205, 14);

DELIMITER //
CREATE PROCEDURE checkout(IN reservation_ID int,IN guest_ID int)
BEGIN
	DECLARE currentGuestRoomNumber INT;
    DECLARE currentRoomKeyID INT;
    SELECT RoomNumber INTO currentGuestRoomNumber FROM guests WHERE GuestID=guest_ID;
    SELECT RoomKeyID INTO currentRoomKeyID FROM room WHERE RoomNumber=currentGuestRoomNumber;
    UPDATE roomkey SET roomkey.Active=0 WHERE RoomKeyID=currentRoomKeyID;
    UPDATE reservations SET ReservationActive=0 WHERE ReservationID=reservation_ID;
END//
DELIMITER ;
    
DELIMITER //
create procedure amenitiesPackages(IN packageFeature varchar(30))
BEGIN
SELECT lower(packageFeature) into packageFeature;
	CASE
		WHEN packageFeature="free continental breakfast" THEN select AmenitiesListID from amenities_list WHERE FreeContinentalBreakfast=1;
        WHEN packageFeature="gym access" THEN select AmenitiesListID from amenities_list WHERE GymAcces=1;
        WHEN packageFeature="pool access" THEN select AmenitiesListID from amenities_list WHERE PoolAcces=1;
		WHEN packageFeature="parking" THEN select AmenitiesListID from amenities_list WHERE Parking=1;
		WHEN packageFeature="wifi access" THEN select AmenitiesListID from amenities_list WHERE WiFiAccess=1;
        ELSE SELECT 'Invalid input. Please make sure that this is a valid package name';
    END CASE;
END//
DELIMITER ;

call amenitiesPackages("parking");    

DELIMITER //
CREATE PROCEDURE blacklistGuest(IN Guest_ID int)
BEGIN
	UPDATE guests SET blacklisted=1 WHERE GuestID=Guest_ID;
END //
DELIMITER ;


call blacklistGuest(2356);

select*from guests;

--End Caballero Stored Procedures



-- phpMyAdmin SQL Dump
-- version 4.9.5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 09, 2020 at 09:46 PM
-- Server version: 10.3.27-MariaDB
-- PHP Version: 7.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `justinde_hotel`
--

-- --------------------------------------------------------

--
-- Stand-in structure for view `GuestsView`
-- (See below for the actual view)
--
CREATE TABLE `GuestsView` (
`GuestID` int(9)
,`Fname` varchar(16)
,`Lname` varchar(16)
,`Email` varchar(64)
,`RoomNumber` int(3)
,`Blacklisted` tinyint(1)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `SponsorView`
-- (See below for the actual view)
--
CREATE TABLE `SponsorView` (
`SponsorID` int(8)
,`SupplyName` varchar(32)
,`SuppliesID` int(8)
);

-- --------------------------------------------------------

--
-- Structure for view `GuestsView`
--
DROP TABLE IF EXISTS `GuestsView`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `GuestsView`  AS  (select `Guests`.`GuestID` AS `GuestID`,`Guests`.`Fname` AS `Fname`,`Guests`.`Lname` AS `Lname`,`Guests`.`Email` AS `Email`,`Guests`.`RoomNumber` AS `RoomNumber`,`Guests`.`Blacklisted` AS `Blacklisted` from `Guests`) ;

-- --------------------------------------------------------

--
-- Structure for view `SponsorView`
--
DROP TABLE IF EXISTS `SponsorView`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `SponsorView`  AS  (select `Sponsors`.`SponsorID` AS `SponsorID`,`Sponsors`.`SupplyName` AS `SupplyName`,`Sponsors`.`SuppliesID` AS `SuppliesID` from `Sponsors`) ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- Stored Procedures

DELIMITER $$
CREATE PROCEDURE `EmployeePromotion`(IN `Employee_ID` INT(8))
BEGIN
        DECLARE FirstName varchar(16);
    DECLARE LastName varchar(16);
    DECLARE NewManagerID int(6);
        SELECT DISTINCT FName INTO FirstName FROM t.Employee WHERE t.EmployeeID=t.EmployeeID;
    SELECT DISTINCT LName INTO LastName FROM t.Employee WHERE t.EmployeeID=t.Employee_ID;
    SELECT DISTINCT FLOOR(RAND()*(550020-550000+1))+550000 INTO NewManagerID FROM t.Employee Where t.EmployeeID=t.Employee_ID;
    INSERT INTO Manager (FName, LName, ManagerID) VALUES (FirstName, LastName, NewManagerID);
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `AddNewEmployee`(IN DepartmentID int(8), IN EmployeeID int(8), IN FName varchar(16), IN JobID int(8), IN JoinDate datetime, IN LName varchar(16), IN ManagerID varchar(16))
BEGIN
        INSERT INTO Employee (DepartmentID, EmployeeID, FName, JobID, JoinDate, LName, ManagerID)
    Values (DepartmentID, EmployeeID, FName, JobID, JoinDate, LName, ManagerID);
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE `GuestAmenities`(IN FirstName varchar(16))
BEGIN
    Select
        Guests.FName as "First Name",
        Guests.LName as "Last Name",
        Amenities_List.AmenitiesListID as "Amenities ID",
        Amenities_List.FreeContinentalBreakfast as "Free Breakfast",
        Amenities_List.GymAccess as "Gym Access",
        Amenities_List.PoolAccess as "Pool Access",
        Amenities_List.Parking as "Parking",
        Amenities_List.WiFiAccess as "Wifi Access"
    From (Guests, Reservations, Amenities_List)
    join Guests as guestsTable on Reservations.GuestID=Guests.GuestID
    join Amenities_List as Amenities_ListTable on Reservations.AmenitiesListID=Amenities_List.AmenitiesListID
    WHERE
        Guests.FName = FirstName
    GROUP BY Guests.Fname, Guests.Lname;
END$$
DELIMITER ;




DELIMITER $$
CREATE PROCEDURE `PaymentTypeChecker`(IN PaymentCheck varchar(16))
BEGIN
    SELECT PaymentID AS "Payment ID", Amount AS "Amount", PaymentType AS "Payment Type" FROM Payment
    WHERE PaymentType = PaymentCheck;
END$$
DELIMITER ;


-- Perez Stored Procedures

DELIMITER //
CREATE PROCEDURE ActiveCheck(IN Active_Check boolean)
BEGIN
	SELECT DISTINCT
        Room.RoomNumber as "Room",
        Room.FloorNumber as "Floor",
        RoomType.RoomTypeName as "Type",
        RoomKey.`Active` as "Active"
	From (Room, RoomType, RoomKey)
    join RoomType as RoomTypeTable on Room.RoomTypeID=RoomType.RoomTypeID
    join RoomKey as RoomKeyTable on Room.RoomKeyID=RoomKey.RoomKeyID
    WHERE
		RoomKey.`Active`=Active_Check;
END//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE RoomFloors(IN Floor_Number INT(8))
BEGIN
	SELECT DISTINCT
        Room.FloorNumber as "Floor",
        Room.RoomNumber as "Room",
        RoomType.RoomTypeName as "Type"
	From (Room, RoomType)
    join RoomType as RoomTypeTable on Room.RoomTypeID=RoomType.RoomTypeID
    WHERE
		Room.FloorNumber=Floor_Number;
END//
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`cpses_ju9mxcj59b`@`localhost` PROCEDURE `GuestAmenities`(IN FirstName varchar(16))
BEGIN
    Select
        Guests.FName as "First Name",
        Guests.LName as "Last Name",
        Amenities_List.AmenitiesListID as "Amenities ID",
        Amenities_List.FreeContinentalBreakfast as "Free Breakfast",
        Amenities_List.GymAccess as "Gym Access",
        Amenities_List.PoolAccess as "Pool Access",
        Amenities_List.Parking as "Parking",
        Amenities_List.WiFiAccess as "Wifi Access"
    From (Guests, Reservations, Amenities_List)
    join Guests as guestsTable on Reservations.GuestID=Guests.GuestID
    join Amenities_List as Amenities_ListTable on Reservations.AmenitiesListID=Amenities_List.AmenitiesListID
    WHERE
        Guests.FName = FirstName
    GROUP BY Guests.Fname, Guests.Lname;
END$$
DELIMITER ;

-- Delgado and Perez

DELIMITER $$
CREATE PROCEDURE `SelectGuest`(IN Firstname varchar(16))
BEGIN
	SELECT GuestID AS "Guest ID", Fname AS "First Name", 
    Lname AS "Last Name", Email, RoomNumber AS "Room Number",
    Blacklisted FROM Guests WHERE Fname = Firstname; 
END$$
DELIMITER ;