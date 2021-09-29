-- Justin Delgado Portion
create table Payment(
    PaymentID INT(8) NOT NULL,
    Amount DECIMAL(7,2) NOT NULL,
    PaymentType varchar(8) NOT NULL,
    PRIMARY KEY(PaymentID)
    )ENGINE=InnoDB;

create table Amenities_List(
    AmenitiesListID INT(8),
    FreeContinentalBreakfast boolean,
    GymAccess boolean,
    PoolAccess boolean,
    Parking boolean,
    WiFiAccess boolean,
    PRIMARY KEY(AmenitiesListID)
    )ENGINE=InnoDB;

create table Supplies(
    SuppliesID int(8),
    SponsorID int(8),
    SupplyName varchar(32),
    VendorName varchar(32),
    Quantity int(8),
    PRIMARY KEY(SuppliesID)
    )ENGINE=InnoDB;
    
create table Sponsors(
    SponsorID int(8),
    SupplyName varchar(32),
    SuppliesID int(8),
    PRIMARY KEY(SponsorID),
    FOREIGN KEY(SuppliesID) REFERENCES Supplies(SuppliesID)
    )ENGINE=InnoDB;
    
-- Jonathan Perez Portion
create table RoomType(
RoomTypeID INT(8) not null,
RoomTypeName varchar(16) default null,
MaxGuestQuantity INT(2) not null,
CostPerNight decimal(5,2) not null,
Primary Key(RoomTypeID)
)ENGINE=InnoDB;

create table RoomKey(
RoomKeyID INT(8) not null,
Barcode INT(12) not null,
`Active` boolean not null,
IssueDate date not null,
Primary Key(RoomKeyID)
)ENGINE=InnoDB;

create table Room(
RoomNumber INT(8) not null,
RoomTypeID INT(8) not null,
FloorNumber INT(8) not null,
RoomKeyID INT(8) not null,
CostOfRoomPerNight DECIMAL(5,2),
Primary Key(RoomNumber),
Foreign Key(RoomTypeID) References RoomType(RoomTypeID),
Foreign Key(RoomKeyID) references RoomKey(RoomKeyID)
)ENGINE=InnoDB;

create table Guests(
GuestID INT(9) not null,
Fname varchar(16) default null,
Lname varchar(16) default null,
Email varchar(64) default null,
RoomNumber int(3) not null,
Blacklisted boolean not null,
Primary Key(GuestID),
Foreign Key(RoomNumber) references Room(RoomNumber)
)ENGINE=InnoDB;

-- Nicholas Caballero Portion
create table `Department`(
`DepartmentID` int(8) primary key,
`DepartmentName` varchar(15),
`DepartmentDescription` varchar(150)
)ENGINE=InnoDB;

create table `Manager`(
`ManagerID` int(8) primary key,
`FName` varchar(16),
`LName` varchar(16),
`DepartmentID` int(8),
foreign key(DepartmentID) references Department(DepartmentID)
)ENGINE=InnoDB;

create table `Job`(
`JobID` int(8) primary key,
`JobName` varchar(32),
`JobDescription` varchar(250)
)ENGINE=InnoDB;

create table `Employee`(
`EmployeeID` int(8) primary key,
`FName` varchar(16),
`LName` varchar(16),
`JoinDate` date,
`ManagerID` int(8),
foreign key(ManagerID) references Manager(ManagerID),
`JobID` int(8),
foreign key(JobID) references Job(JobID),
`DepartmentID` int(8),
foreign key(DepartmentID) references Department(DepartmentID)
)ENGINE=InnoDB;

create table `Reservations`(
`ReservationID` int(8) primary key,
`Service` varchar(32),
`EmployeeID` int(8),
foreign key(EmployeeID) references Employee(EmployeeID),
`GuestID` INT(9),
foreign key(GuestID) references Guests(GuestID),
`StartDate` date,
`StartTime` time,
`EndDate` date,
`EndTime` time,
`PaymentID` INT(8),
foreign key(PaymentID) references Payment(PaymentID),
`ReservationActive` boolean,
`AmenitiesListID` INT(8),
foreign key(AmenitiesListID) references Amenities_List(AmenitiesListID)
)ENGINE=InnoDB;

select*from amenities_list;
select*from department;
select*from employee;
select*from guests;
select*from job;
select*from manager;
select*from payment;
select*from reservations;
select*from room;
select*from roomkey;
select*from roomtype;
select*from sponsors;
select*from supplies;

select*from guests;
select*from employee;
select*from payment;
select*from amenities_list;
select*from job;

select*from employee;
select*from job;

DELIMITER //

create procedure SelectGuest (IN LastName varchar(16))
BEGIN
SELECT *
FROM Guests WHERE Lname=LastName;
END//

DELIMITER ;