create table Project(
	PrID int,
	Pr_name varchar(50),
	Budget money,
	startDate date not null,
	Deadline date not null,
	Primary key (PrID,Deadline,startDate)
)PARTITION BY Range (Deadline);

CREATE TABLE Pr_Deadline_Q1 PARTITION OF Project
FOR VALUES FROM ('2021-01-01') TO ('2021-03-31')
PARTITION BY RANGE(startDate);

create table q1_s1 partition of Pr_Deadline_Q1
FOR VALUES FROM ('2021-01-01') TO ('2021-03-31');

CREATE TABLE Pr_Deadline_Q2 PARTITION OF Project
FOR VALUES FROM ('2021-04-01') TO ('2021-06-30');	

CREATE TABLE Pr_Deadline_Q3 PARTITION OF Project
FOR VALUES FROM ('2021-07-01') TO ('2021-09-30');

CREATE TABLE Pr_Deadline_Q4 PARTITION OF Project
FOR VALUES FROM ('2021-10-01') TO ('2021-12-31');

CREATE TABLE Pr_Deadline_other PARTITION OF Project DEFAULT;
