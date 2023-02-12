create table Location(
	LID int,
	Address varchar(100),
	Country varchar(50),
	Primary key(LID)
);
create table Department(
	DepID int,
	Department_name varchar(50),
	LID int,
	primary key(DepID,LID),
	foreign key (LID) references Location(LID)
)PARTITION BY list (LID);

CREATE TABLE Dep_Loc_1 PARTITION OF Department
FOR VALUES in (1);

CREATE TABLE Dep_Loc_2 PARTITION OF Department
FOR VALUES in (2);

CREATE TABLE Dep_Loc_3 PARTITION OF Department
FOR VALUES in (3);

CREATE TABLE Dep_Loc_other PARTITION OF Department DEFAULT;