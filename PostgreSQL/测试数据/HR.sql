create database testdb;
create user hr with password 'hr@123';
grant all privileges on database testdb to hr;
\c testdb hr
create schema authorization hr;
set search_path='hr';
-- ----------------------------
-- Table structure for COUNTRIES
-- ----------------------------
DROP TABLE if exists COUNTRIES;
CREATE TABLE COUNTRIES (
  COUNTRY_ID CHAR(2)  NOT NULL,
  COUNTRY_NAME VARCHAR(40) ,
  REGION_ID numeric 
);
COMMENT ON COLUMN COUNTRIES.COUNTRY_ID IS 'Primary key of countries table.';
COMMENT ON COLUMN COUNTRIES.COUNTRY_NAME IS 'Country name';
COMMENT ON COLUMN COUNTRIES.REGION_ID IS 'Region ID for the country. Foreign key to region_id column in the departments table.';
COMMENT ON TABLE COUNTRIES IS 'country table. Contains 25 rows. References with locations table.';

-- ----------------------------
-- Records of COUNTRIES
-- ----------------------------
INSERT INTO COUNTRIES VALUES ('AR', 'Argentina', '2'),
								('AU', 'Australia', '3'),
								('BE', 'Belgium', '1'),
								('BR', 'Brazil', '2'),
								('CA', 'Canada', '2'),
								('CH', 'Switzerland', '1'),
								('CN', 'China', '3'),
								('DE', 'Germany', '1'),
								('DK', 'Denmark', '1'),
								('EG', 'Egypt', '4'),
								('FR', 'France', '1'),
								('HK', 'HongKong', '3'),
								('IL', 'Israel', '4'),
								('IN', 'India', '3'),
								('IT', 'Italy', '1'),
								('JP', 'Japan', '3'),
								('KW', 'Kuwait', '4'),
								('MX', 'Mexico', '2'),
								('NG', 'Nigeria', '4'),
								('NL', 'Netherlands', '1'),
								('SG', 'Singapore', '3'),
								('UK', 'United Kingdom', '1'),
								('US', 'United States of America', '2'),
								('ZM', 'Zambia', '4'),
								('ZW', 'Zimbabwe', '4');

-- ----------------------------
-- Table structure for DEPARTMENTS
-- ----------------------------
DROP TABLE if exists DEPARTMENTS;
CREATE TABLE DEPARTMENTS (
  DEPARTMENT_ID numeric(4,0)  NOT NULL,
  DEPARTMENT_NAME VARCHAR(30)  NOT NULL,
  MANAGER_ID numeric(6,0) ,
  LOCATION_ID numeric(4,0) 
);
COMMENT ON COLUMN DEPARTMENTS.DEPARTMENT_ID IS 'Primary key column of departments table.';
COMMENT ON COLUMN DEPARTMENTS.DEPARTMENT_NAME IS 'A not null column that shows name of a department. Administration,Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public Relations, Sales, Finance, and Accounting. ';
COMMENT ON COLUMN DEPARTMENTS.MANAGER_ID IS 'Manager_id of a department. Foreign key to employee_id column of employees table. The manager_id column of the employee table references this column.';
COMMENT ON COLUMN DEPARTMENTS.LOCATION_ID IS 'Location id where a department is located. Foreign key to location_id column of locations table.';
COMMENT ON TABLE DEPARTMENTS IS 'Departments table that shows details of departments where employees work. Contains 27 rows; references with locations, employees, and job_history tables.';

-- ----------------------------
-- Records of DEPARTMENTS
-- ----------------------------
INSERT INTO DEPARTMENTS VALUES ('10', 'Administration', '200', '1700'),
                                   ('20', 'Marketing', '201', '1800'),
                                   ('30', 'Purchasing', '114', '1700'),
                                   ('40', 'Human Resources', '203', '2400'),
                                   ('50', 'Shipping', '121', '1500'),
                                   ('60', 'IT', '103', '1400'),
                                   ('70', 'Public Relations', '204', '2700'),
                                   ('80', 'Sales', '145', '2500'),
                                   ('90', 'Executive', '100', '1700'),
                                   ('100', 'Finance', '108', '1700'),
                                   ('110', 'Accounting', '205', '1700'),
                                   ('120', 'Treasury', NULL, '1700'),
                                   ('130', 'Corporate Tax', NULL, '1700'),
                                   ('140', 'Control And Credit', NULL, '1700'),
                                   ('150', 'Shareholder Services', NULL, '1700'),
                                   ('160', 'Benefits', NULL, '1700'),
                                   ('170', 'Manufacturing', NULL, '1700'),
                                   ('180', 'Construction', NULL, '1700'),
                                   ('190', 'Contracting', NULL, '1700'),
                                   ('200', 'Operations', NULL, '1700'),
                                   ('210', 'IT Support', NULL, '1700'),
                                   ('220', 'NOC', NULL, '1700'),
                                   ('230', 'IT Helpdesk', NULL, '1700'),
                                   ('240', 'Government Sales', NULL, '1700'),
                                   ('250', 'Retail Sales', NULL, '1700'),
                                   ('260', 'Recruiting', NULL, '1700'),
                                   ('270', 'Payroll', NULL, '1700');

-- ----------------------------
-- Table structure for EMPLOYEES
-- ----------------------------
DROP TABLE if exists EMPLOYEES;
CREATE TABLE EMPLOYEES (
  EMPLOYEE_ID numeric(6,0)  NOT NULL,
  FIRST_NAME VARCHAR(20) ,
  LAST_NAME VARCHAR(25)  NOT NULL,
  EMAIL VARCHAR(25)  NOT NULL,
  PHONE_numeric VARCHAR(20) ,
  HIRE_DATE DATE  NOT NULL,
  JOB_ID VARCHAR(10)  NOT NULL,
  SALARY numeric(8,2) ,
  COMMISSION_PCT numeric(2,2) ,
  MANAGER_ID numeric(6,0) ,
  DEPARTMENT_ID numeric(4,0) 
);

COMMENT ON COLUMN EMPLOYEES.EMPLOYEE_ID IS 'Primary key of employees table.';
COMMENT ON COLUMN EMPLOYEES.FIRST_NAME IS 'First name of the employee. A not null column.';
COMMENT ON COLUMN EMPLOYEES.LAST_NAME IS 'Last name of the employee. A not null column.';
COMMENT ON COLUMN EMPLOYEES.EMAIL IS 'Email id of the employee';
COMMENT ON COLUMN EMPLOYEES.PHONE_numeric IS 'Phone numeric of the employee; includes country code and area code';
COMMENT ON COLUMN EMPLOYEES.HIRE_DATE IS 'Date when the employee started on this job. A not null column.';
COMMENT ON COLUMN EMPLOYEES.JOB_ID IS 'Current job of the employee; foreign key to job_id column of the jobs table. A not null column.';
COMMENT ON COLUMN EMPLOYEES.SALARY IS 'Monthly salary of the employee. Must be greater than zero (enforced by constraint emp_salary_min)';
COMMENT ON COLUMN EMPLOYEES.COMMISSION_PCT IS 'Commission percentage of the employee; Only employees in sales department elgible for commission percentage';
COMMENT ON COLUMN EMPLOYEES.MANAGER_ID IS 'Manager id of the employee; has same domain as manager_id in departments table. Foreign key to employee_id column of employees table. (useful for reflexive joins and CONNECT BY query)';
COMMENT ON COLUMN EMPLOYEES.DEPARTMENT_ID IS 'Department id where employee works; foreign key to department_id column of the departments table';
COMMENT ON TABLE EMPLOYEES IS 'employees table. Contains 107 rows. References with departments,jobs, job_history tables. Contains a self reference.';

-- ----------------------------
-- Records of EMPLOYEES
-- ----------------------------
INSERT INTO EMPLOYEES VALUES ('100', 'Steven', 'King', 'SKING', '515.123.4567', TO_DATE('1987-06-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AD_PRES', '24000', NULL, NULL, '90'),
('101', 'Neena', 'Kochhar', 'NKOCHHAR', '515.123.4568', TO_DATE('1989-09-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AD_VP', '17000', NULL, '100', '90'),
('102', 'Lex', 'De Haan', 'LDEHAAN', '515.123.4569', TO_DATE('1993-01-13 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AD_VP', '17000', NULL, '100', '90'),
('103', 'Alexander', 'Hunold', 'AHUNOLD', '590.423.4567', TO_DATE('1990-01-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '9000', NULL, '102', '60'),
('104', 'Bruce', 'Ernst', 'BERNST', '590.423.4568', TO_DATE('1991-05-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '6000', NULL, '103', '60'),
('105', 'David', 'Austin', 'DAUSTIN', '590.423.4569', TO_DATE('1997-06-25 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '4800', NULL, '103', '60'),
('106', 'Valli', 'Pataballa', 'VPATABAL', '590.423.4560', TO_DATE('1998-02-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '4800', NULL, '103', '60'),
('107', 'Diana', 'Lorentz', 'DLORENTZ', '590.423.5567', TO_DATE('1999-02-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '4200', NULL, '103', '60'),
('108', 'Nancy', 'Greenberg', 'NGREENBE', '515.124.4569', TO_DATE('1994-08-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_MGR', '12000', NULL, '101', '100'),
('109', 'Daniel', 'Faviet', 'DFAVIET', '515.124.4169', TO_DATE('1994-08-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_ACCOUNT', '9000', NULL, '108', '100'),
('110', 'John', 'Chen', 'JCHEN', '515.124.4269', TO_DATE('1997-09-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_ACCOUNT', '8200', NULL, '108', '100'),
('111', 'Ismael', 'Sciarra', 'ISCIARRA', '515.124.4369', TO_DATE('1997-09-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_ACCOUNT', '7700', NULL, '108', '100'),
('112', 'Jose Manuel', 'Urman', 'JMURMAN', '515.124.4469', TO_DATE('1998-03-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_ACCOUNT', '7800', NULL, '108', '100'),
('113', 'Luis', 'Popp', 'LPOPP', '515.124.4567', TO_DATE('1999-12-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'FI_ACCOUNT', '6900', NULL, '108', '100'),
('114', 'Den', 'Raphaely', 'DRAPHEAL', '515.127.4561', TO_DATE('1994-12-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_MAN', '11000', NULL, '100', '30'),
('115', 'Alexander', 'Khoo', 'AKHOO', '515.127.4562', TO_DATE('1995-05-18 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_CLERK', '3100', NULL, '114', '30'),
('116', 'Shelli', 'Baida', 'SBAIDA', '515.127.4563', TO_DATE('1997-12-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_CLERK', '2900', NULL, '114', '30'),
('117', 'Sigal', 'Tobias', 'STOBIAS', '515.127.4564', TO_DATE('1997-07-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_CLERK', '2800', NULL, '114', '30'),
('118', 'Guy', 'Himuro', 'GHIMURO', '515.127.4565', TO_DATE('1998-11-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_CLERK', '2600', NULL, '114', '30'),
('119', 'Karen', 'Colmenares', 'KCOLMENA', '515.127.4566', TO_DATE('1999-08-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PU_CLERK', '2500', NULL, '114', '30'),
('120', 'Matthew', 'Weiss', 'MWEISS', '650.123.1234', TO_DATE('1996-07-18 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_MAN', '8000', NULL, '100', '50'),
('121', 'Adam', 'Fripp', 'AFRIPP', '650.123.2234', TO_DATE('1997-04-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_MAN', '8200', NULL, '100', '50'),
('122', 'Payam', 'Kaufling', 'PKAUFLIN', '650.123.3234', TO_DATE('1995-05-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_MAN', '7900', NULL, '100', '50'),
('123', 'Shanta', 'Vollman', 'SVOLLMAN', '650.123.4234', TO_DATE('1997-10-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_MAN', '6500', NULL, '100', '50'),
('124', 'Kevin', 'Mourgos', 'KMOURGOS', '650.123.5234', TO_DATE('1999-11-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_MAN', '5800', NULL, '100', '50'),
('125', 'Julia', 'Nayer', 'JNAYER', '650.124.1214', TO_DATE('1997-07-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3200', NULL, '120', '50'),
('126', 'Irene', 'Mikkilineni', 'IMIKKILI', '650.124.1224', TO_DATE('1998-09-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2700', NULL, '120', '50'),
('127', 'James', 'Landry', 'JLANDRY', '650.124.1334', TO_DATE('1999-01-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2400', NULL, '120', '50'),
('128', 'Steven', 'Markle', 'SMARKLE', '650.124.1434', TO_DATE('2000-03-08 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2200', NULL, '120', '50'),
('129', 'Laura', 'Bissot', 'LBISSOT', '650.124.5234', TO_DATE('1997-08-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3300', NULL, '121', '50'),
('130', 'Mozhe', 'Atkinson', 'MATKINSO', '650.124.6234', TO_DATE('1997-10-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2800', NULL, '121', '50'),
('131', 'James', 'Marlow', 'JAMRLOW', '650.124.7234', TO_DATE('1997-02-16 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2500', NULL, '121', '50'),
('132', 'TJ', 'Olson', 'TJOLSON', '650.124.8234', TO_DATE('1999-04-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2100', NULL, '121', '50'),
('133', 'Jason', 'Mallin', 'JMALLIN', '650.127.1934', TO_DATE('1996-06-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3300', NULL, '122', '50'),
('134', 'Michael', 'Rogers', 'MROGERS', '650.127.1834', TO_DATE('1998-08-26 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2900', NULL, '122', '50'),
('135', 'Ki', 'Gee', 'KGEE', '650.127.1734', TO_DATE('1999-12-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2400', NULL, '122', '50'),
('136', 'Hazel', 'Philtanker', 'HPHILTAN', '650.127.1634', TO_DATE('2000-02-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2200', NULL, '122', '50'),
('137', 'Renske', 'Ladwig', 'RLADWIG', '650.121.1234', TO_DATE('1995-07-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3600', NULL, '123', '50'),
('138', 'Stephen', 'Stiles', 'SSTILES', '650.121.2034', TO_DATE('1997-10-26 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3200', NULL, '123', '50'),
('139', 'John', 'Seo', 'JSEO', '650.121.2019', TO_DATE('1998-02-12 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2700', NULL, '123', '50'),
('140', 'Joshua', 'Patel', 'JPATEL', '650.121.1834', TO_DATE('1998-04-06 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2500', NULL, '123', '50'),
('141', 'Trenna', 'Rajs', 'TRAJS', '650.121.8009', TO_DATE('1995-10-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3500', NULL, '124', '50'),
('142', 'Curtis', 'Davies', 'CDAVIES', '650.121.2994', TO_DATE('1997-01-29 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '3100', NULL, '124', '50'),
('143', 'Randall', 'Matos', 'RMATOS', '650.121.2874', TO_DATE('1998-03-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2600', NULL, '124', '50'),
('144', 'Peter', 'Vargas', 'PVARGAS', '650.121.2004', TO_DATE('1998-07-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '2500', NULL, '124', '50'),
('145', 'John', 'Russell', 'JRUSSEL', '011.44.1344.429268', TO_DATE('1996-10-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '14000', '0.4', '100', '80'),
('146', 'Karen', 'Partners', 'KPARTNER', '011.44.1344.467268', TO_DATE('1997-01-05 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '13500', '0.3', '100', '80'),
('147', 'Alberto', 'Errazuriz', 'AERRAZUR', '011.44.1344.429278', TO_DATE('1997-03-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '12000', '0.3', '100', '80'),
('148', 'Gerald', 'Cambrault', 'GCAMBRAU', '011.44.1344.619268', TO_DATE('1999-10-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '11000', '0.3', '100', '80'),
('149', 'Eleni', 'Zlotkey', 'EZLOTKEY', '011.44.1344.429018', TO_DATE('2000-01-29 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '10500', '0.2', '100', '80'),
('150', 'Peter', 'Tucker', 'PTUCKER', '011.44.1344.129268', TO_DATE('1997-01-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '10000', '0.3', '145', '80'),
('151', 'David', 'Bernstein', 'DBERNSTE', '011.44.1344.345268', TO_DATE('1997-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9500', '0.25', '145', '80'),
('152', 'Peter', 'Hall', 'PHALL', '011.44.1344.478968', TO_DATE('1997-08-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9000', '0.25', '145', '80'),
('153', 'Christopher', 'Olsen', 'COLSEN', '011.44.1344.498718', TO_DATE('1998-03-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '8000', '0.2', '145', '80'),
('154', 'Nanette', 'Cambrault', 'NCAMBRAU', '011.44.1344.987668', TO_DATE('1998-12-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7500', '0.2', '145', '80'),
('155', 'Oliver', 'Tuvault', 'OTUVAULT', '011.44.1344.486508', TO_DATE('1999-11-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7000', '0.15', '145', '80'),
('156', 'Janette', 'King', 'JKING', '011.44.1345.429268', TO_DATE('1996-01-30 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '10000', '0.35', '146', '80'),
('157', 'Patrick', 'Sully', 'PSULLY', '011.44.1345.929268', TO_DATE('1996-03-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9500', '0.35', '146', '80'),
('158', 'Allan', 'McEwen', 'AMCEWEN', '011.44.1345.829268', TO_DATE('1996-08-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9000', '0.35', '146', '80'),
('159', 'Lindsey', 'Smith', 'LSMITH', '011.44.1345.729268', TO_DATE('1997-03-10 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '8000', '0.3', '146', '80'),
('160', 'Louise', 'Doran', 'LDORAN', '011.44.1345.629268', TO_DATE('1997-12-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7500', '0.3', '146', '80'),
('161', 'Sarath', 'Sewall', 'SSEWALL', '011.44.1345.529268', TO_DATE('1998-11-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7000', '0.25', '146', '80'),
('162', 'Clara', 'Vishney', 'CVISHNEY', '011.44.1346.129268', TO_DATE('1997-11-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '10500', '0.25', '147', '80'),
('163', 'Danielle', 'Greene', 'DGREENE', '011.44.1346.229268', TO_DATE('1999-03-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9500', '0.15', '147', '80'),
('164', 'Mattea', 'Marvins', 'MMARVINS', '011.44.1346.329268', TO_DATE('2000-01-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7200', '0.1', '147', '80'),
('165', 'David', 'Lee', 'DLEE', '011.44.1346.529268', TO_DATE('2000-02-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '6800', '0.1', '147', '80'),
('166', 'Sundar', 'Ande', 'SANDE', '011.44.1346.629268', TO_DATE('2000-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '6400', '0.1', '147', '80'),
('167', 'Amit', 'Banda', 'ABANDA', '011.44.1346.729268', TO_DATE('2000-04-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '6200', '0.1', '147', '80'),
('168', 'Lisa', 'Ozer', 'LOZER', '011.44.1343.929268', TO_DATE('1997-03-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '11500', '0.25', '148', '80'),
('169', 'Harrison', 'Bloom', 'HBLOOM', '011.44.1343.829268', TO_DATE('1998-03-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '10000', '0.2', '148', '80'),
('170', 'Tayler', 'Fox', 'TFOX', '011.44.1343.729268', TO_DATE('1998-01-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '9600', '0.2', '148', '80'),
('171', 'William', 'Smith', 'WSMITH', '011.44.1343.629268', TO_DATE('1999-02-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7400', '0.15', '148', '80'),
('172', 'Elizabeth', 'Bates', 'EBATES', '011.44.1343.529268', TO_DATE('1999-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7300', '0.15', '148', '80'),
('173', 'Sundita', 'Kumar', 'SKUMAR', '011.44.1343.329268', TO_DATE('2000-04-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '6100', '0.1', '148', '80'),
('174', 'Ellen', 'Abel', 'EABEL', '011.44.1644.429267', TO_DATE('1996-05-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '11000', '0.3', '149', '80'),
('175', 'Alyssa', 'Hutton', 'AHUTTON', '011.44.1644.429266', TO_DATE('1997-03-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '8800', '0.25', '149', '80'),
('176', 'Jonathon', 'Taylor', 'JTAYLOR', '011.44.1644.429265', TO_DATE('1998-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '8600', '0.2', '149', '80'),
('177', 'Jack', 'Livingston', 'JLIVINGS', '011.44.1644.429264', TO_DATE('1998-04-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '8400', '0.2', '149', '80'),
('178', 'Kimberely', 'Grant', 'KGRANT', '011.44.1644.429263', TO_DATE('1999-05-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '7000', '0.15', '149', NULL),
('179', 'Charles', 'Johnson', 'CJOHNSON', '011.44.1644.429262', TO_DATE('2000-01-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '6200', '0.1', '149', '80'),
('180', 'Winston', 'Taylor', 'WTAYLOR', '650.507.9876', TO_DATE('1998-01-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3200', NULL, '120', '50'),
('181', 'Jean', 'Fleaur', 'JFLEAUR', '650.507.9877', TO_DATE('1998-02-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3100', NULL, '120', '50'),
('182', 'Martha', 'Sullivan', 'MSULLIVA', '650.507.9878', TO_DATE('1999-06-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2500', NULL, '120', '50'),
('183', 'Girard', 'Geoni', 'GGEONI', '650.507.9879', TO_DATE('2000-02-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2800', NULL, '120', '50'),
('184', 'Nandita', 'Sarchand', 'NSARCHAN', '650.509.1876', TO_DATE('1996-01-27 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '4200', NULL, '121', '50'),
('185', 'Alexis', 'Bull', 'ABULL', '650.509.2876', TO_DATE('1997-02-20 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '4100', NULL, '121', '50'),
('186', 'Julia', 'Dellinger', 'JDELLING', '650.509.3876', TO_DATE('1998-06-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3400', NULL, '121', '50'),
('187', 'Anthony', 'Cabrio', 'ACABRIO', '650.509.4876', TO_DATE('1999-02-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3000', NULL, '121', '50'),
('188', 'Kelly', 'Chung', 'KCHUNG', '650.505.1876', TO_DATE('1997-06-14 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3800', NULL, '122', '50'),
('189', 'Jennifer', 'Dilly', 'JDILLY', '650.505.2876', TO_DATE('1997-08-13 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3600', NULL, '122', '50'),
('190', 'Timothy', 'Gates', 'TGATES', '650.505.3876', TO_DATE('1998-07-11 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2900', NULL, '122', '50'),
('191', 'Randall', 'Perkins', 'RPERKINS', '650.505.4876', TO_DATE('1999-12-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2500', NULL, '122', '50'),
('192', 'Sarah', 'Bell', 'SBELL', '650.501.1876', TO_DATE('1996-02-04 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '4000', NULL, '123', '50'),
('193', 'Britney', 'Everett', 'BEVERETT', '650.501.2876', TO_DATE('1997-03-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3900', NULL, '123', '50'),
('194', 'Samuel', 'McCain', 'SMCCAIN', '650.501.3876', TO_DATE('1998-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3200', NULL, '123', '50'),
('195', 'Vance', 'Jones', 'VJONES', '650.501.4876', TO_DATE('1999-03-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2800', NULL, '123', '50'),
('196', 'Alana', 'Walsh', 'AWALSH', '650.507.9811', TO_DATE('1998-04-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3100', NULL, '124', '50'),
('197', 'Kevin', 'Feeney', 'KFEENEY', '650.507.9822', TO_DATE('1998-05-23 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '3000', NULL, '124', '50'),
('198', 'Donald', 'OConnell', 'DOCONNEL', '650.507.9833', TO_DATE('1999-06-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2600', NULL, '124', '50'),
('199', 'Douglas', 'Grant', 'DGRANT', '650.507.9844', TO_DATE('2000-01-13 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SH_CLERK', '2600', NULL, '124', '50'),
('200', 'Jennifer', 'Whalen', 'JWHALEN', '515.123.4444', TO_DATE('1987-09-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AD_ASST', '4400', NULL, '101', '10'),
('201', 'Michael', 'Hartstein', 'MHARTSTE', '515.123.5555', TO_DATE('1996-02-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'MK_MAN', '13000', NULL, '100', '20'),
('202', 'Pat', 'Fay', 'PFAY', '603.123.6666', TO_DATE('1997-08-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'MK_REP', '6000', NULL, '201', '20'),
('203', 'Susan', 'Mavris', 'SMAVRIS', '515.123.7777', TO_DATE('1994-06-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'HR_REP', '6500', NULL, '101', '40'),
('204', 'Hermann', 'Baer', 'HBAER', '515.123.8888', TO_DATE('1994-06-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PR_REP', '10000', NULL, '101', '70'),
('205', 'Shelley', 'Higgins', 'SHIGGINS', '515.123.8080', TO_DATE('1994-06-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AC_MGR', '12000', NULL, '101', '110'),
('206', 'William', 'Gietz', 'WGIETZ', '515.123.8181', TO_DATE('1994-06-07 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AC_ACCOUNT', '8300', NULL, '205', '110');

-- ----------------------------
-- Table structure for JOBS
-- ----------------------------
DROP TABLE if exists JOBS;
CREATE TABLE JOBS (
  JOB_ID VARCHAR(10)  NOT NULL,
  JOB_TITLE VARCHAR(35)  NOT NULL,
  MIN_SALARY numeric(6,0) ,
  MAX_SALARY numeric(6,0) 
)

;
COMMENT ON COLUMN JOBS.JOB_ID IS 'Primary key of jobs table.';
COMMENT ON COLUMN JOBS.JOB_TITLE IS 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';
COMMENT ON COLUMN JOBS.MIN_SALARY IS 'Minimum salary for a job title.';
COMMENT ON COLUMN JOBS.MAX_SALARY IS 'Maximum salary for a job title';
COMMENT ON TABLE JOBS IS 'jobs table with job titles and salary ranges. Contains 19 rows.References with employees and job_history table.';

-- ----------------------------
-- Records of JOBS
-- ----------------------------
INSERT INTO JOBS VALUES ('AD_PRES', 'President', '20000', '40000'),
                            ('AD_VP', 'Administration Vice President', '15000', '30000'),
                            ('AD_ASST', 'Administration Assistant', '3000', '6000'),
                            ('FI_MGR', 'Finance Manager', '8200', '16000'),
                            ('FI_ACCOUNT', 'Accountant', '4200', '9000'),
                            ('AC_MGR', 'Accounting Manager', '8200', '16000'),
                            ('AC_ACCOUNT', 'Public Accountant', '4200', '9000'),
                            ('SA_MAN', 'Sales Manager', '10000', '20000'),
                            ('SA_REP', 'Sales Representative', '6000', '12000'),
                            ('PU_MAN', 'Purchasing Manager', '8000', '15000'),
                            ('PU_CLERK', 'Purchasing Clerk', '2500', '5500'),
                            ('ST_MAN', 'Stock Manager', '5500', '8500'),
                            ('ST_CLERK', 'Stock Clerk', '2000', '5000'),
                            ('SH_CLERK', 'Shipping Clerk', '2500', '5500'),
                            ('IT_PROG', 'Programmer', '4000', '10000'),
                            ('MK_MAN', 'Marketing Manager', '9000', '15000'),
                            ('MK_REP', 'Marketing Representative', '4000', '9000'),
                            ('HR_REP', 'Human Resources Representative', '4000', '9000'),
                            ('PR_REP', 'Public Relations Representative', '4500', '10500');

-- ----------------------------
-- Table structure for JOB_HISTORY
-- ----------------------------
DROP TABLE if exists JOB_HISTORY;
CREATE TABLE JOB_HISTORY (
  EMPLOYEE_ID numeric(6,0)  NOT NULL,
  START_DATE DATE  NOT NULL,
  END_DATE DATE  NOT NULL,
  JOB_ID VARCHAR(10)  NOT NULL,
  DEPARTMENT_ID numeric(4,0) 
)

;
COMMENT ON COLUMN JOB_HISTORY.EMPLOYEE_ID IS 'A not null column in the complex primary key employee_id+start_date.Foreign key to employee_id column of the employee table';
COMMENT ON COLUMN JOB_HISTORY.START_DATE IS 'A not null column in the complex primary key employee_id+start_date.Must be less than the end_date of the job_history table. (enforced byconstraint jhist_date_interval)';
COMMENT ON COLUMN JOB_HISTORY.END_DATE IS 'Last day of the employee in this job role. A not null column. Must begreater than the start_date of the job_history table.(enforced by constraint jhist_date_interval)';
COMMENT ON COLUMN JOB_HISTORY.JOB_ID IS 'Job role in which the employee worked in the past; foreign key to job_id column in the jobs table. A not null column.';
COMMENT ON COLUMN JOB_HISTORY.DEPARTMENT_ID IS 'Department id in which the employee worked in the past; foreign key to deparment_id column in the departments table';
COMMENT ON TABLE JOB_HISTORY IS 'Table that stores job history of the employees. If an employee changes departments within the job or changes jobs within the department, new rows get inserted into this table with old job information of the employee. Contains a complex primary key: employee_id+start_date.Contains 25 rows. References with jobs, employees, and departments tables.';

-- ----------------------------
-- Records of JOB_HISTORY
-- ----------------------------
INSERT INTO JOB_HISTORY VALUES ('102', TO_DATE('1993-01-13 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1998-07-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'IT_PROG', '60'),
                                   ('101', TO_DATE('1989-09-21 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1993-10-27 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AC_ACCOUNT', '110'),
                                   ('101', TO_DATE('1993-10-28 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1997-03-15 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AC_MGR', '110'),
                                   ('201', TO_DATE('1996-02-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1999-12-19 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'MK_REP', '20'),
                                   ('114', TO_DATE('1998-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '50'),
                                   ('122', TO_DATE('1999-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'ST_CLERK', '50'),
                                   ('200', TO_DATE('1987-09-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1993-06-17 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AD_ASST', '90'),
                                   ('176', TO_DATE('1998-03-24 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1998-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_REP', '80'),
                                   ('176', TO_DATE('1999-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'SA_MAN', '80'),
                                   ('200', TO_DATE('1994-07-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('1998-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'AC_ACCOUNT', '90');

-- ----------------------------
-- Table structure for LOCATIONS
-- ----------------------------
DROP TABLE if exists LOCATIONS;
CREATE TABLE LOCATIONS (
  LOCATION_ID numeric(4,0)  NOT NULL,
  STREET_ADDRESS VARCHAR(40) ,
  POSTAL_CODE VARCHAR(12) ,
  CITY VARCHAR(30)  NOT NULL,
  STATE_PROVINCE VARCHAR(25) ,
  COUNTRY_ID CHAR(2) 
)

;
COMMENT ON COLUMN LOCATIONS.LOCATION_ID IS 'Primary key of locations table';
COMMENT ON COLUMN LOCATIONS.STREET_ADDRESS IS 'Street address of an office, warehouse, or production site of a company.Contains building numeric and street name';
COMMENT ON COLUMN LOCATIONS.POSTAL_CODE IS 'Postal code of the location of an office, warehouse, or production site of a company. ';
COMMENT ON COLUMN LOCATIONS.CITY IS 'A not null column that shows city where an office, warehouse, or production site of a company is located. ';
COMMENT ON COLUMN LOCATIONS.STATE_PROVINCE IS 'State or Province where an office, warehouse, or production site of a company is located.';
COMMENT ON COLUMN LOCATIONS.COUNTRY_ID IS 'Country where an office, warehouse, or production site of a company is located. Foreign key to country_id column of the countries table.';
COMMENT ON TABLE LOCATIONS IS 'Locations table that contains specific address of a specific office,warehouse, and/or production site of a company. Does not store addresses / locations of customers. Contains 23 rows; references with the departments and countries tables. ';

-- ----------------------------
-- Records of LOCATIONS
-- ----------------------------
INSERT INTO LOCATIONS VALUES ('1000', '1297 Via Cola di Rie', '00989', 'Roma', NULL, 'IT'),
('1100', '93091 Calle della Testa', '10934', 'Venice', NULL, 'IT'),
('1200', '2017 Shinjuku-ku', '1689', 'Tokyo', 'Tokyo Prefecture', 'JP'),
('1300', '9450 Kamiya-cho', '6823', 'Hiroshima', NULL, 'JP'),
('1400', '2014 Jabberwocky Rd', '26192', 'Southlake', 'Texas', 'US'),
('1500', '2011 Interiors Blvd', '99236', 'South San Francisco', 'California', 'US'),
('1600', '2007 Zagora St', '50090', 'South Brunswick', 'New Jersey', 'US'),
('1700', '2004 Charade Rd', '98199', 'Seattle', 'Washington', 'US'),
('1800', '147 Spadina Ave', 'M5V 2L7', 'Toronto', 'Ontario', 'CA'),
('1900', '6092 Boxwood St', 'YSW 9T2', 'Whitehorse', 'Yukon', 'CA'),
('2000', '40-5-12 Laogianggen', '190518', 'Beijing', NULL, 'CN'),
('2100', '1298 Vileparle (E)', '490231', 'Bombay', 'Maharashtra', 'IN'),
('2200', '12-98 Victoria Street', '2901', 'Sydney', 'New South Wales', 'AU'),
('2300', '198 Clementi North', '540198', 'Singapore', NULL, 'SG'),
('2400', '8204 Arthur St', NULL, 'London', NULL, 'UK'),
('2500', 'Magdalen Centre, The Oxford Science Park', 'OX9 9ZB', 'Oxford', 'Oxford', 'UK'),
('2600', '9702 Chester Road', '09629850293', 'Stretford', 'Manchester', 'UK'),
('2700', 'Schwanthalerstr. 7031', '80925', 'Munich', 'Bavaria', 'DE'),
('2800', 'Rua Frei Caneca 1360 ', '01307-002', 'Sao Paulo', 'Sao Paulo', 'BR'),
('2900', '20 Rue des Corps-Saints', '1730', 'Geneva', 'Geneve', 'CH'),
('3000', 'Murtenstrasse 921', '3095', 'Bern', 'BE', 'CH'),
('3100', 'Pieter Breughelstraat 837', '3029SK', 'Utrecht', 'Utrecht', 'NL'),
('3200', 'Mariano Escobedo 9991', '11932', 'Mexico City', 'Distrito Federal,', 'MX');

-- ----------------------------
-- Table structure for REGIONS
-- ----------------------------
DROP TABLE if exists REGIONS;
CREATE TABLE REGIONS (
  REGION_ID numeric  NOT NULL,
  REGION_NAME VARCHAR(25) 
)

;

-- ----------------------------
-- Records of REGIONS
-- ----------------------------
INSERT INTO REGIONS VALUES ('1', 'Europe'),
('2', 'Americas'),
('3', 'Asia'),
('4', 'Middle East and Africa');

-- ----------------------------
-- View structure for EMP_DETAILS_VIEW
-- ----------------------------
CREATE OR REPLACE VIEW EMP_DETAILS_VIEW AS SELECT
  e.employee_id,
  e.job_id,
  e.manager_id,
  e.department_id,
  d.location_id,
  l.country_id,
  e.first_name,
  e.last_name,
  e.salary,
  e.commission_pct,
  d.department_name,
  j.job_title,
  l.city,
  l.state_province,
  c.country_name,
  r.region_name
FROM
  employees e,
  departments d,
  jobs j,
  locations l,
  countries c,
  regions r
WHERE e.department_id = d.department_id
  AND d.location_id = l.location_id
  AND l.country_id = c.country_id
  AND c.region_id = r.region_id
  AND j.job_id = e.job_id ;

-- ----------------------------
-- Function structure for ADD_JOB_HISTORY
-- ----------------------------
CREATE OR REPLACE
PROCEDURE ADD_JOB_HISTORY()
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date,job_id, department_id) 
   VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END;
$$;

-- ----------------------------
-- Function structure for SECURE_DML
-- ----------------------------
CREATE OR REPLACE
PROCEDURE SECURE_DML()
LANGUAGE plpgsql
AS $$
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00' OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE NOTICE 'You may only make changes during normal office hours' ;
  END IF;
END;
$$;


-- ----------------------------
-- Sequence structure for DEPARTMENTS_SEQ
-- ----------------------------
DROP SEQUENCE IF EXISTS DEPARTMENTS_SEQ;
CREATE SEQUENCE DEPARTMENTS_SEQ MINVALUE 1 MAXVALUE 9990 INCREMENT BY 10 ;

-- ----------------------------
-- Sequence structure for EMPLOYEES_SEQ
-- ----------------------------
DROP SEQUENCE IF EXISTS EMPLOYEES_SEQ;
CREATE SEQUENCE EMPLOYEES_SEQ;

-- ----------------------------
-- Sequence structure for LOCATIONS_SEQ
-- ----------------------------
DROP SEQUENCE IF EXISTS LOCATIONS_SEQ;
CREATE SEQUENCE LOCATIONS_SEQ MINVALUE 1 MAXVALUE 9900 INCREMENT BY 100 ;

-- ----------------------------
-- Primary Key structure for table COUNTRIES
-- ----------------------------
ALTER TABLE COUNTRIES ADD CONSTRAINT COUNTRY_C_ID_PK PRIMARY KEY (COUNTRY_ID);

-- ----------------------------
-- Checks structure for table COUNTRIES
-- ----------------------------
ALTER TABLE COUNTRIES ADD CONSTRAINT COUNTRY_ID_NN CHECK (COUNTRY_ID IS NOT NULL) ;

-- ----------------------------
-- Primary Key structure for table DEPARTMENTS
-- ----------------------------
ALTER TABLE DEPARTMENTS ADD CONSTRAINT DEPT_ID_PK PRIMARY KEY (DEPARTMENT_ID);

-- ----------------------------
-- Checks structure for table DEPARTMENTS
-- ----------------------------
ALTER TABLE DEPARTMENTS ADD CONSTRAINT DEPT_NAME_NN CHECK (DEPARTMENT_NAME IS NOT NULL) ;

-- ----------------------------
-- Indexes structure for table DEPARTMENTS
-- ----------------------------
CREATE INDEX DEPT_LOCATION_IX ON DEPARTMENTS (LOCATION_ID ASC);

-- ----------------------------
-- Primary Key structure for table EMPLOYEES
-- ----------------------------
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMP_ID_PK PRIMARY KEY (EMPLOYEE_ID);

-- ----------------------------
-- Uniques structure for table EMPLOYEES
-- ----------------------------
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMAIL_UK UNIQUE (EMAIL) ;

-- ----------------------------
-- Checks structure for table EMPLOYEES
-- ----------------------------
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMAIL_NN CHECK (EMAIL IS NOT NULL) ;
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_HIRE_DATE_NN CHECK (HIRE_DATE IS NOT NULL) ;
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_JOB_NN CHECK (JOB_ID IS NOT NULL) ;
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_LAST_NAME_NN CHECK (LAST_NAME IS NOT NULL) ;
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_SALARY_MIN CHECK (salary > 0) ;

-- ----------------------------
-- Indexes structure for table EMPLOYEES
-- ----------------------------
CREATE INDEX EMP_DEPARTMENT_IX ON EMPLOYEES (DEPARTMENT_ID ASC);
CREATE INDEX EMP_JOB_IX ON EMPLOYEES (JOB_ID ASC);
CREATE INDEX EMP_MANAGER_IX ON EMPLOYEES (MANAGER_ID ASC);
CREATE INDEX EMP_NAME_IX ON EMPLOYEES (LAST_NAME ASC, FIRST_NAME ASC);

-- ----------------------------
-- Triggers structure for table EMPLOYEES
-- ----------------------------
/* CREATE TRIGGER SECURE_EMPLOYEES BEFORE DELETE OR INSERT OR UPDATE ON EMPLOYEES REFERENCING OLD AS OLD NEW AS NEW 
BEGIN
  secure_dml;
END secure_employees;
/
CREATE TRIGGER UPDATE_JOB_HISTORY AFTER UPDATE OF DEPARTMENT_ID, JOB_ID ON EMPLOYEES REFERENCING OLD AS OLD NEW AS NEW FOR EACH ROW 
BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate,
                  :old.job_id, :old.department_id);
END;
/ */

-- ----------------------------
-- Primary Key structure for table JOBS
-- ----------------------------
ALTER TABLE JOBS ADD CONSTRAINT JOB_ID_PK PRIMARY KEY (JOB_ID);

-- ----------------------------
-- Checks structure for table JOBS
-- ----------------------------
ALTER TABLE JOBS ADD CONSTRAINT JOB_TITLE_NN CHECK (JOB_TITLE IS NOT NULL) ;

-- ----------------------------
-- Primary Key structure for table JOB_HISTORY
-- ----------------------------
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_EMP_ID_ST_DATE_PK PRIMARY KEY (EMPLOYEE_ID, START_DATE);

-- ----------------------------
-- Checks structure for table JOB_HISTORY
-- ----------------------------
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_DATE_INTERVAL CHECK (end_date > start_date) ;
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_EMPLOYEE_NN CHECK (EMPLOYEE_ID IS NOT NULL) ;
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_END_DATE_NN CHECK (END_DATE IS NOT NULL) ;
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_JOB_NN CHECK (JOB_ID IS NOT NULL) ;
ALTER TABLE JOB_HISTORY ADD CONSTRAINT JHIST_START_DATE_NN CHECK (START_DATE IS NOT NULL) ;

-- ----------------------------
-- Indexes structure for table JOB_HISTORY
-- ----------------------------
CREATE INDEX JHIST_DEPARTMENT_IX ON JOB_HISTORY (DEPARTMENT_ID ASC);
CREATE INDEX JHIST_EMPLOYEE_IX ON JOB_HISTORY (EMPLOYEE_ID ASC);
CREATE INDEX JHIST_JOB_IX ON JOB_HISTORY (JOB_ID ASC);

-- ----------------------------
-- Primary Key structure for table LOCATIONS
-- ----------------------------
ALTER TABLE LOCATIONS ADD CONSTRAINT LOC_ID_PK PRIMARY KEY (LOCATION_ID);

-- ----------------------------
-- Checks structure for table LOCATIONS
-- ----------------------------
ALTER TABLE LOCATIONS ADD CONSTRAINT LOC_CITY_NN CHECK (CITY IS NOT NULL) ;

-- ----------------------------
-- Indexes structure for table LOCATIONS
-- ----------------------------
CREATE INDEX LOC_CITY_IX ON LOCATIONS (CITY ASC);
CREATE INDEX LOC_COUNTRY_IX ON LOCATIONS (COUNTRY_ID ASC);
CREATE INDEX LOC_STATE_PROVINCE_IX ON LOCATIONS (STATE_PROVINCE ASC);

-- ----------------------------
-- Primary Key structure for table REGIONS
-- ----------------------------
ALTER TABLE REGIONS ADD CONSTRAINT REG_ID_PK PRIMARY KEY (REGION_ID);

-- ----------------------------
-- Checks structure for table REGIONS
-- ----------------------------
ALTER TABLE REGIONS ADD CONSTRAINT REGION_ID_NN CHECK (REGION_ID IS NOT NULL) ;

-- ----------------------------
-- Foreign Keys structure for table COUNTRIES
-- ----------------------------
ALTER TABLE COUNTRIES ADD CONSTRAINT COUNTR_REG_FK FOREIGN KEY (REGION_ID) REFERENCES REGIONS (REGION_ID) ;
