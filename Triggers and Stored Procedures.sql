/******************************************************************************************************************************
*	Triggers and Stored Procedures
******************************************************************************************************************************/
/*
	Calculate Premier monthly payment for a given vehicle owner for a given year
		-miles driven per year to find maintenance intervals that will occur, sum up costs and subtract 5%
*/

CREATE TRIGGER Premier_Monthly_Payment_event
BEFORE UPDATE On Premier
For EACH ROW
begin
	
end;
/*
	-If Steady/Premier uses points on their visit
	-make sure the customer has earned the amount of points they intend to use
	-make sure they don’t use more points than the total of their maintenance items are worth
	-subtract the pointsUsed from their points total
*/
Create Trigger Points_event
After Update on Points
For EACH ROW
begin

end;
/*
	If Premier customer refers a customer
	-When you insert into Premier Payment table for a given month, look in
	Referred By Premier to see if that customer referred anyone during the previous
	month
		-If yes, subtract $50 from the monthly payment for each customer referred
			-If some amount less than $50 remains that referral is used and the payment becomes free 
			(no fractional usage, roundup to nearest int)
	-For each deduction applied add one to Referred Benefits used
*/
Create Trigger Premire_Refers_event
After Insert on Referred
FOR EACH ROW
begin
end;
/*
	If Steady Customer refers a customer
	-In maintenance pack item/ time work, if maint_item_name = oil change and final cost is $0 use
	count to find total possible referred benefits available and subtract referred benefits used for
	actual amount. If actual amount > 1 allow the insert of the $0 oil change and add one to Referred
	Benefits used. 
*/
Create Trigger Steady_Refers_event
After Insert on Referred
for each row
begin
end;
/*
	-For any mechanicID attribute use trigger/stored procedure to check if that employeeID corresponds
	 to an employee of type Mechanic or both (be sure to ignore casing)
*/
Create Trigger MechanicID_event
After Insert on  Employee
for each row
begin
end;
/*
	For any ST_ID attribute use trigger/stored procedure to check if that employeeID 
	corresponds to a Service Technician or both (ignore casing)
*/
Create Trigger EmployeeID_event
After Update on Employee
for each row
begin
end;
/*
	Derive costs of maintenance items by using equation $25/hour * 10% markup
*/
Create Trigger Maintenance_Item_event
after Update on Maintenance_Item
for each row
begin
end;
/*
	Calculate the monthly retirement pay of a given employee
	(From Business Rules)
*/
Create Trigger Past_event
After Insert on Past 
FOR EACH ROW
begin
	if tierNumber = 0 then
		set baseDollarRate = 0
	if tierNumber = 1 then
		set baseDollarRate = 200
		set tierNumber = 1
	if tierNumber = 2 then
		set baseDollarRate = 225
		set tierNumber = 2
	if tierNumber = 3 then
		set baseDollarRate = 250

	update Retirement_Tier
	set baseDollarRate = 500 * minYearsOnJob;

end;
/*
	Calculate the current amount of vacation/sick hours that an employee has
*/
Create Trigger Vacation_SickHours_event
After Insert on Present
FOR EACH ROW
begin
	update Benefits_Tier
	if tierNumber = 1 then
		set vacationPerHourRate = 0.04
		set sickPerHourRate = 0.03
	if tierNumber = 2 then
		set vacationPerHourRate = 0.06
		set sickPerHourRate = 0.05
	if tierNumber = 3 then
		set vacationPerHourRate = 0.08
		set sickPerHourRate = 0.07
end;
/*
	When a email is added to Prospective Email, check if the custID belongs to a
	 prospective customer, if it does and their id already appears 3 or more times do not allow the insert
*/
Create Trigger Prospective_Email_event
After Insert on Prospective_Email
For EACH ROW
begin
	if(Select custId from Prospective where custID = Prospective.custID) then
    if(Select count(custID) from Prospective_Email where custID = Prospective_Email.custID)then
		/*Do not Insert*/
end;
