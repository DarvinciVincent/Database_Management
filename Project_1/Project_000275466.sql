create table Location(
	LID int,
	Address varchar(100),
	Country varchar(50),
	Primary key(LID)
);

create table Customer(
	CID int,
	customer_name varchar(50),
	Email varchar(50),
	LID int,
	primary key(CID),
	foreign key (LID) references Location(LID)
);

create table Project(
	PrID int,
	Pr_name varchar(50),
	Budget money,
	startDate date not null,
	Deadline date not null,
	CID int,
	Primary key (PrID),
	foreign key (CID) references Customer(CID)--Primary key (PrID,Deadline),
);--xARTITION BY Range (Deadline);

/*CREATE TABLE Pr_Deadline_Q1 PARTITION OF Project
FOR VALUES FROM ('2021-01-01') TO ('2021-03-31');

CREATE TABLE Pr_Deadline_Q2 PARTITION OF Project
FOR VALUES FROM ('2021-04-01') TO ('2021-06-30');

CREATE TABLE Pr_Deadline_Q3 PARTITION OF Project
FOR VALUES FROM ('2021-07-01') TO ('2021-09-30');

CREATE TABLE Pr_Deadline_Q4 PARTITION OF Project
FOR VALUES FROM ('2021-10-01') TO ('2021-12-31');

CREATE TABLE Pr_Deadline_other PARTITION OF Project DEFAULT; */


create table Department(
	DepID serial,
	Department_name varchar(50),
	LID int,
	primary key(DepID),
	foreign key (LID) references Location(LID)
);

create table Role(
	RoleID int,
	Role_name varchar(50),
	primary key(RoleID)
);

create table Employee(
	EmpID int,
	Email varchar(50),
	Employee_name varchar(50),
	DepID int,
	primary key(EmpID),
	foreign key (DepID) references Department(DepID)
);

create table User_group(
	GrID serial,
	Usergroup_Name varchar(50),
	PrID int,
	primary key(GrID),
	foreign key (PrID) references Project(PrID)
);

create table Emp_Pr(
	PrID int,
	EmpID int,
	started date,
	foreign key (PrID) references Project(PrID),
	foreign key (EmpID) references Employee(EmpID)
);

create table Emp_Role(
	RoleID int,
	EmpID int,
	Description varchar (100),
	foreign key (RoleID) references Role(RoleID),
	foreign key (EmpID) references Employee(EmpID)
);

create table Emp_Usergroup(
	GrID int,
	EmpID int,
	foreign key (GrID) references User_group(GrID),
	foreign key (EmpID) references Employee(EmpID)
);

/* DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public; */

create role Project1_users with 
LOGIN 
CREATEDB
CREATEROLE
NOINHERIT
REPLICATION
CONNECTION LIMIT -1
VALID UNTIL '2022-04-30T23:59:00+03:00' 
PASSWORD 'xxxxxx';

GRANT ALL PRIVILEGES on Project to Project1_users;

/*'SELECT con.*
       FROM pg_catalog.pg_constraint con
            INNER JOIN pg_catalog.pg_class rel
                       ON rel.oid = con.conrelid
            INNER JOIN pg_catalog.pg_namespace nsp
                       ON nsp.oid = connamespace
       WHERE nsp.nspname = 'public'
             AND rel.relname = 'customer'; */
			 
ALTER TABLE public.department
    ADD CONSTRAINT "Department_name_Check" 
	CHECK (department_name = 'HR' 
		   or department_name = 'Software' 
		   or department_name='Data' 
		   or department_name = 'ICT'
		   or department_name='Customer Support');


-- trigger 1
create or replace function is_emp_in_project()
 RETURNS trigger AS
$$
BEGIN
	if (select count(*) 
	  from employee_project 
	  where prid = (select prid from user_group where grid = New.grid) and Empid = New.EmpID) < 1
	then raise exception 'employee not in project';
	else
	return NEW;
	end if;	
END;
$$
LANGUAGE 'plpgsql';

create trigger check_emp_in_project
before insert or update on emp_usergroup
for each row
execute function is_emp_in_project();


-- trigger 2
create or replace function create_group_project()
 RETURNS trigger AS
$$
BEGIN
	Insert into User_group(Usergroup_Name,PrID) values
		((select concat(New.Pr_name,'_','group')),New.PrID);
END;
$$
LANGUAGE 'plpgsql';

create trigger create_new_usergroup
after insert on Project
for each row
execute function create_group_project();	

-- trigger 3
create or replace function create_department_for_new_location()
 RETURNS trigger AS
$$
BEGIN
	Insert into Department(Usergroup_Name,PrID) values
		('HR',New.LID),
		('Software',New.LID),
		('Data',New.LID),
		('ICT',New.LID),
		('Customer support',New.LID);
END;
$$x
LANGUAGE 'plpgsql';

create trigger department_for_new_location
after insert on location
for each row
execute function create_department_for_new_location();	
