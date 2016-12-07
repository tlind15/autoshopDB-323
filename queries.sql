CREATE VIEW steady_names_v AS
SELECT name, custID, phone, email FROM steady INNER JOIN customer USING (custID) INNER JOIN individual USING (custID)
UNION
SELECT name, custID, phone, email FROM steady INNER JOIN customer USING (custID) INNER JOIN business USING (custID);

CREATE VIEW steady_visit_v AS
SELECT * FROM steady_names_v INNER JOIN vehicle_owner USING (custID) INNER JOIN visit USING (custID, vehicleID);

CREATE VIEW steady_maintenance_v AS
	SELECT name, ST_ID, custID, vehicleID, date, maint_item_name, finalcost FROM
	steady_visit_v INNER JOIN maintenance_pack_item USING (ST_ID, custID, vehicleID, date)
	UNION
	SELECT name, ST_ID, custID, vehicleID, date, maint_item_name, finalcost FROM
	steady_visit_v INNER JOIN maintenance_item_work USING (ST_ID, custID, vehicleID, date);

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
    

/*Extra Queries*/
/*Show each employee, denote whether they are past or present and list the retirement/benefits tier number*/

SELECT firstName, lastName, 'Present' as Employment_Status, tierNumber FROM (
	employee INNER JOIN present USING (employeeID) INNER JOIN benefits_tier
    USING (tierNumber)
)

UNION

SELECT firstName, lastName, 'Past' as Employment_Status, tierNumber FROM (
	employee INNER JOIN past USING (employeeID) INNER JOIN retirement_tier
    USING (tierNumber)
);

/*Show all employees who have won employee of the month in the past year*/
SELECT firstName, lastName, a.employeeID, b.monthAwarded, b.yearAwarded, reward.name, reward.description FROM
employee INNER JOIN employee_of_the_month as a USING (employeeID) INNER JOIN
employee_reward as b ON a.month = b.monthAwarded AND 
    a.year = b.yearAwarded and a.employeeID = b.employeeID INNER JOIN
    reward ON b.rewardName = reward.name
    WHERE b.yearAwarded >= YEAR(curdate()) - 1;
    




--#15
SELECT firstName, lastName 
FROM employee_type INNER JOIN employee USING (type)
WHERE type = 'Service Technician and Mechanic';

--#14
SELECT skillName, Count(mechanic_skill.skill) as Number_Taught
FROM skill INNER JOIN mechanic_skill ON skill.skillName = mechanic_skill.skill
GROUP BY skillName
ORDER BY Number_Taught ASC LIMIT 3;

--#13

SELECT firstName, lastName, Num_Mentored, Skills
FROM (
	SELECT firstName, lastName, Count(mentorEmployeeID) as Num_Mentored, group_concat(DISTINCT mentorSkill) as Skills
	FROM employee INNER JOIN mechanic_skill USING (employeeID) INNER JOIN
	mentorship ON mechanic_skill.employeeID = mentorship.mentorEmployeeID AND 
    mechanic_skill.skill = mentorship.mentorSkill
	GROUP BY firstName, lastName
) as sub
WHERE Num_Mentored = (
	SELECT Max(Num_Mentored) FROM (
		SELECT firstName, lastName, Count(mentorEmployeeID) as Num_Mentored, group_concat(DISTINCT mentorSkill) as Skills
		FROM employee INNER JOIN mechanic_skill USING (employeeID) INNER JOIN
		mentorship ON mechanic_skill.employeeID = mentorship.mentorEmployeeID AND 
		mechanic_skill.skill = mentorship.mentorSkill
		GROUP BY firstName, lastName) as sub2
);

--#12
SELECT name, SUM(Order_Cost) as 'Total Part Cost'
FROM (
	SELECT partName, name, (quantity * priceForOne) as Order_Cost
	FROM (
		SELECT * FROM Supplier INNER JOIN Part_Order ON supplier.name = Part_Order.supplierName
	WHERE date >= curdate() - interval 365 DAY
    ) as sub
) as sub2
GROUP BY name
ORDER BY 'Total Part Cost' limit 3;

--#11
SELECT name, count(name) as Parts_Supplied
	FROM (
		SELECT name, partName FROM (
		SELECT * FROM Supplier INNER JOIN Part_Order ON supplier.name = Part_Order.supplierName
		WHERE date >= curdate() - interval 365 day
	) as sub
	GROUP BY name, partName
) as sub3
GROUP BY name
ORDER BY parts_supplied desc limit 3;

--#10
SELECT name, SUM(Profit) FROM (
	SELECT name, maint_item_name, (finalcost - Base_cost) as Profit FROM (
		(SELECT name, custID, maint_item_name, finalcost FROM steady_maintenance_v 
		WHERE date >= curdate() - interval 365 day) as sub1 INNER JOIN

		(SELECT mName, (numOfPartNeeded * priceForOne) as Base_Cost
		FROM maintenance_item INNER JOIN part_maintenance USING (mName)
		INNER JOIN Part_at_Daves ON partSerialNum = Part_at_Daves.serialNum
		INNER JOIN Part_Order ON orderedFromID = Part_Order.orderID) as sub2 ON 
		
		sub1.maint_item_name = sub2.mName
	)
) as sub3

GROUP BY name;


--#9
SELECT name, (visit_cost - paymentTotal) as Savings FROM (
SELECT name, ST_ID, custID, vehicleID, date, SUM(finalcost) as Visit_Cost FROM premier_maintenance_v
GROUP BY ST_ID, custID, vehicleID, date) as sub INNER JOIN premier_payment USING (custID);

--#8
(SELECT name, points FROM premier INNER JOIN customer USING (custID) INNER JOIN individual USING (custID))
UNION
(SELECT name, points FROM premier INNER JOIN customer USING (custID) INNER JOIN business USING (custID))
UNION
(SELECT name, points FROM steady INNER JOIN customer USING (custID) INNER JOIN individual USING (custID))
UNION
(SELECT name, points FROM steady INNER JOIN customer USING (custID) INNER JOIN business USING (custID))
ORDER BY points desc;

--#7
SELECT firstName, lastName FROM (
	SELECT  firstName, lastName, maint_item_name as Items FROM
	mechanic_skill INNER JOIN employee as a USING (employeeID) INNER JOIN maintenance_pack_item as b ON a.employeeID = b.mechanicID
	GROUP BY firstname, lastName
) as sub 
WHERE (sub.firstName, sub.lastName, sub.Items) IN (SELECT firstName, lastName, skill FROM employee INNER JOIN mechanic_skill USING (employeeID));
	
--#6
SELECT 
    make,
    model,
    year,
    milesDriven,
    GROUP_CONCAT(b.maint_item_name) AS Items,
    SUM(cost) AS Total
FROM
    vehicle
        INNER JOIN
    vehicle_interval AS a USING (vehicleID)
        INNER JOIN
    maintenance_interval_item AS b ON a.milesDriven = b.numMiles
        AND a.vehicleID = b.vehicleID
        INNER JOIN
    vehicle_maintenance AS c ON (b.vehicleID = c.vehicleID
        AND b.maint_item_name = c.maint_item_name)
GROUP BY make , model , year , milesDriven;

--#5

--#4
SELECT firstName, lastName, Count(employeeID) as 'Number of Skills'
FROM employee INNER JOIN mechanic_skill USING (employeeID)
GROUP BY firstName, lastName
HAVING Count(employeeID) >= 3;

--#3
SELECT name, SUM(finalcost) as Net_Spending FROM (
	SELECT * FROM (
		SELECT * FROM steady_maintenance_v UNION SELECT * FROM premier_maintenance_v
	) as sub
) as sub2
GROUP BY name
ORDER BY Net_Spending desc LIMIT 3;
--#2
SELECT name, ST_ID, custID, vehicleID, date, SUM(finalcost) FROM (
	SELECT * FROM steady_maintenance_v UNION SELECT * FROM premier_maintenance_v
) as sub
GROUP BY ST_ID, custID, vehicleID, date;



--#1
(SELECT name, phone, email, 'Premier' as Customer_Type 
FROM individual INNER JOIN customer USING (custID) INNER JOIN 
premier USING (custID))

UNION

(SELECT name, phone, email, 'Premier' as Customer_Type 
FROM business INNER JOIN customer USING (custID) INNER JOIN 
premier USING (custID))

UNION

(SELECT name, phone, email, 'Steady' as Customer_Type 
FROM individual INNER JOIN customer USING (custID) INNER JOIN 
steady USING (custID))

UNION

(SELECT name, phone, email, 'Steady' as Customer_Type 
FROM business INNER JOIN customer USING (custID) INNER JOIN 
steady USING (custID))

UNION

(SELECT name, phone, email, 'Prospective' as Customer_Type 
FROM individual INNER JOIN customer USING (custID) INNER JOIN 
prospective USING (custID))

UNION

(SELECT name, phone, email, 'Prospective' as Customer_Type 
FROM business INNER JOIN customer USING (custID) INNER JOIN 
prospective USING (custID));

