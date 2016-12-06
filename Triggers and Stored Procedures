/******************************************************************************************************************************
*	Triggers and Stored Procedures
******************************************************************************************************************************/
/*
	Calculate Premier monthly payment for a given vehicle owner for a given year
		-miles driven per year to find maintenance intervals that will occur, sum up costs and subtract 5%
*/

CREATE TRIGGER Premier_Monthly_Payment_event
BEFORE UPDATE On Premier
 begin
 	if(old.month)
 	paymentTotal := paymentTotal - paymentTotal * .05;
end
/*
	-If Steady/Premier uses points on their visit
	-make sure the customer has earned the amount of points they intend to use
	-make sure they don’t use more points than the total of their maintenance items are worth
	-subtract the pointsUsed from their points total
*/
Create Trigger Points_event
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
/*
	If Steady Customer refers a customer
	-In maintenance pack item/ time work, if maint_item_name = oil change and final cost is $0 use
	count to find total possible referred benefits available and subtract referred benefits used for
	actual amount. If actual amount > 1 allow the insert of the $0 oil change and add one to Referred
	Benefits used. 
*/
Create Trigger Steady_Refers_event
/*
	-For any mechanicID attribute use trigger/stored procedure to check if that employeeID corresponds
	 to an employee of type Mechanic or both (be sure to ignore casing)
*/
Create Trigger MechanicID_event
/*
	For any ST_ID attribute use trigger/stored procedure to check if that employeeID 
	corresponds to a Service Technician or both (ignore casing)
*/
Create Trigger EmployeeID_event
/*
	Derive costs of maintenance items by using equation $25/hour * 10% markup
*/
Create Trigger Maintenance_Item_event
/*
	Calculate the monthly retirement pay of a given employee
*/
Create Trigger Past_event
After Insert on Past 
begin

end
/*
	Calculate the current amount of vacation/sick hours that an employee has
*/
Create Trigger Vacation_SickHours_event
/*
	When a email is added to Prospective Email, check if the custID belongs to a
	 prospective customer, if it does and their id already appears 3 or more times do not allow the insert
*/
Create Trigger Prospective_Email_event
