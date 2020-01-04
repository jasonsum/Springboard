/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT 
	NAME
FROM
	Facilities
WHERE (MEMBERCOST IS NOT NULL) AND (MEMBERCOST > 0)

/* Q2: How many facilities do not charge a fee to members? */
SELECT 
	COUNT(*)
FROM
	Facilities
WHERE (MEMBERCOST IS NULL) OR (MEMBERCOST = 0)

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT 
	FACID
	,NAME
	,MEMBERCOST
	,MONTHLYMAINTENANCE
FROM Facilities
WHERE MEMBERCOST > 0
AND MEMBERCOST < (0.2 * MONTHLYMAINTENANCE)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT 
	*
FROM Facilities
WHERE FACID IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT 
	CASE
		WHEN MONTHLYMAINTENANCE >= 100 THEN 'expensive'
		WHEN MONTHLYMAINTENANCE < 100 THEN 'cheap'
	END AS 'LABEL'
	,NAME
	,MONTHLYMAINTENANCE
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT 
	FIRSTNAME
	,SURNAME
FROM Members
WHERE JOINDATE IN 
	(SELECT MAX(JOINDATE) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT 
	DISTINCT(CONCAT(FIRSTNAME," ",SURNAME))
	,f.name
FROM 
	Members m, Facilities f, Bookings b
WHERE lower(f.name) LIKE '%tennis court%'
AND b.facid = f.facid 
AND m.memid = b.memid
ORDER BY 1

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT 
	f.name
	,CONCAT(m.firstname," ",m.surname)
	,CASE
		WHEN b.memid = 0 THEN b.slots * f.GUESTCOST
		WHEN b.memid > 0 THEN b.slots * f.MEMBERCOST
	end as COST
FROM Bookings b, Facilities f, Members m
where b.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
AND b.facid = f.facid AND  b.memid = m.memid	
HAVING COST > 30
ORDER BY COST DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select 
		CONCAT(m.firstname," ",m.surname) as name
		,a.name
		,a.COST	
from Members m
		,Bookings b
INNER JOIN (SELECT
					b2.bookID
					,f2.name
					,CASE
				WHEN b2.memid = 0 THEN b2.slots * f2.GUESTCOST	
				WHEN b2.memid > 0 THEN b2.slots * f2.MEMBERCOST
					END AS COST
				FROM Bookings b2, Facilities f2
				WHERE b2.facid = f2.facid) a
			on b.bookID	= a.bookID
			AND a.COST > 30
WHERE m.memid = b.memID
AND b.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
ORDER BY COST DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT
	f.name	
	,SUM(a.COST) AS REVENUE
FROM Facilities	f
INNER JOIN (SELECT
					f2.facid
					,b2.bookID
					,CASE
				WHEN b2.memid = 0 THEN b2.slots * f2.GUESTCOST	
				WHEN b2.memid > 0 THEN b2.slots * f2.MEMBERCOST
					END AS COST
				FROM Bookings b2, Facilities f2
				WHERE b2.facid = f2.facid) a
			on f.facID	= a.facID
GROUP BY f.name	
HAVING REVENUE	< 1000
ORDER BY REVENUE
