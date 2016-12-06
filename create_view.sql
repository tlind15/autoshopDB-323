/*Used for queries and Views*/
CREATE VIEW premier_names_v AS
SELECT name, custID, phone, email FROM premier INNER JOIN customer USING (custID) INNER JOIN individual USING (custID)
UNION
SELECT name, custID, phone, email FROM premier INNER JOIN customer USING (custID) INNER JOIN business USING (custID);

CREATE VIEW premier_visit_v AS
SELECT * FROM premier_names_v INNER JOIN vehicle_owner USING (custID) INNER JOIN visit USING (custID, vehicleID);

CREATE VIEW premier_maintenance_v AS

	SELECT name, ST_ID, custID, vehicleID, date, maint_item_name, finalcost FROM
	premier_visit_v INNER JOIN maintenance_pack_item USING (ST_ID, custID, vehicleID, date)
	UNION
	SELECT name, ST_ID, custID, vehicleID, date, maint_item_name, finalcost FROM
	premier_visit_v INNER JOIN maintenance_item_work USING (ST_ID, custID, vehicleID, date);



/*View 1*/
CREATE VIEW Customer_v AS 
(SELECT name, 'Premier' as Customer_Type, TIMESTAMPDIFF(YEAR,registerDate,CURDATE()) AS 'Years as Customer' 
FROM Individual INNER JOIN Customer USING (custID) INNER JOIN 
Premier USING (custID))

UNION

(SELECT name, 'Premier' as Customer_Type, TIMESTAMPDIFF(YEAR,registerDate,CURDATE()) AS 'Years as Customer'  
FROM Business INNER JOIN Customer USING (custID) INNER JOIN 
Premier USING (custID))

UNION

(SELECT name, 'Steady' as Customer_Type, TIMESTAMPDIFF(YEAR,registerDate,CURDATE()) AS 'Years as Customer' 
FROM Individual INNER JOIN Customer USING (custID) INNER JOIN 
Steady USING (custID))

UNION

(SELECT name, 'Steady' as Customer_Type, TIMESTAMPDIFF(YEAR,registerDate,CURDATE()) AS 'Years as Customer'  
FROM Business INNER JOIN Customer USING (custID) INNER JOIN 
Steady USING (custID))

UNION

(SELECT name, 'Prospective' as Customer_Type, 'N/A' AS 'Years as Customer' 
FROM Individual INNER JOIN Customer USING (custID) INNER JOIN 
Prospective USING (custID))

UNION

(SELECT name, 'Prospective' as Customer_Type, 'N/A' AS 'Years as Customer'  
FROM Business INNER JOIN Customer USING (custID) INNER JOIN 
Prospective USING (custID));

/*View 2*/
CREATE VIEW Customer_Addresses_v AS
SELECT name, 'Business' as Customer_Account, group_concat(street) as Addresses FROM
Customer INNER JOIN Business USING (custID) INNER JOIN Address USING (custID)
GROUP BY name
UNION
SELECT name, 'Individual' as Customer_Account, street as Addresses FROM
Customer INNER JOIN Individual USING (custID);

 

/*View 3*/
CREATE VIEW Mechanic_mentor_v AS      
    SELECT DISTINCT a.firstName as mentorfirstName, a.lastName as mentorlastName, c.firstName as menteefirstName, 
    c.lastName as menteelastName FROM Employee as a INNER JOIN
	Mechanic_Skill USING (EmployeeID) INNER JOIN Mentorship ON Mechanic_Skill.EmployeeID = Mentorship.mentorEmployeeID
	INNER JOIN Employee as c ON Mentorship.EmployeeID = c.EmployeeID;

CREATE VIEW premier_costs AS
SELECT name, ST_ID, custID, vehicleID, date, SUM(finalcost) as Visit_Cost FROM premier_maintenance_v
GROUP BY ST_ID, custID, vehicleID, date) as sub INNER JOIN Premier_Payment USING (custID));   
/*View 4*/
CREATE VIEW premier_profits AS (
SELECT name, (visit_cost - paymentTotal) as Savings FROM (
SELECT name, ST_ID, custID, vehicleID, date, SUM(finalcost) as Visit_Cost FROM premier_maintenance_v
GROUP BY ST_ID, custID, vehicleID, date) as sub INNER JOIN Premier_Payment USING (custID));



/*View 5*/
CREATE VIEW Prospective_resurrection_v AS
SELECT name, MAX(date) as 'Most Recent Contact' FROM (
	SELECT name, custID, date FROM (
		(SELECT name, custID 
		FROM individual INNER JOIN Customer USING (custID)

		UNION 

		SELECT name, custID
		FROM business INNER JOIN customer USING (custID)) as sub

		INNER JOIN Prospective USING (custID) INNER JOIN
		Prospective_Email USING (custID))
	) as sub2
    
    WHERE custID in (
		SELECT custID FROM (
		SELECT name, custID, Count(custID) FROM (
			(SELECT name, custID 
			FROM individual INNER JOIN Customer USING (custID))

			UNION 

			(SELECT name, custID
			FROM business INNER JOIN customer USING (custID))) as sub2

			INNER JOIN Prospective USING (custID) INNER JOIN
			Prospective_Email USING (custID)


			GROUP BY name
			HAVING Count(custID) >= 3
    ) as sub3
);
