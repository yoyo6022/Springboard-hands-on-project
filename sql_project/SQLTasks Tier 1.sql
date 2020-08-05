/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, AND partly in Jupyter via a Python connection.

This is Tier 1 of the CASE study, which means that there'll be mORe guidance fOR you about how to
setup your local SQLite connection in PART 2 of the CASE study.

The questions in the CASE study are exactly the same AS with Tier 2.

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface.
Log in BY pASting the following URL into your browser, AND
using the following Username AND PASswORd:

URL: https://sql.springboard.com/
Username: student
PASswORd: learn_sql@springboard

The data you need is in the "COUNTry_club" databASe. This databASe
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, AND
    iii) the "Members" table.

In this CASE study, you'll be ASked a series of questions. You can
solve them using the platfORm, but fOR the final deliverable,
pASte the code fOR each solution into this script, AND upload it
to your GitHub.

BefORe starting with the questions, feel free to take your time,
explORing the data, AND getting acquainted with the 3 tables. */


/* QUESTIONS
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT * FROM Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) FROM Facilities
WHERE membercost = 0
/* 4 clubs do not charge member fee */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
WHERE the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, AND monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < monthlymaintenance*0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 AND 5.
Try writing the query without using the OR operatOR. */
SELECT * FROM Facilities
WHERE  facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled AS
'cheap' OR 'expensive', depending on if their monthly maintenance cost is
mORe than $100. Return the name AND monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance < 100 THEN 'cheap'
     ELSE 'expensive' END AS Type
FROM Facilities


/* Q6: You'd LIKE to get the first AND lASt name of the lASt member(s)
who signed up. Try not to use the LIMIT clause fOR your solution. */
SELECT surname, firstname, joindate
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

-- OR

SELECT  surname, firstname, joindate
FROM Members
ORDER BY joindate DESC


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, AND the name of the member
fORmatted AS a single column. Ensure no duplicate data, AND ORDER BY
the member name. */
SELECT DISTINCT concat(m.surname, ' ', m.firstname, ' at ',  f.name) as member__fac_name
From Members m
JOIN  Bookings b
ON m.memid = b.memid
JOIN Facilities f
ON b.facid = f.facid
WHERE f.name LIKE 'Tennis%' AND m.memid <> 0
ORDER BY concat(m.surname, ' ', m.firstname)




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (OR guest) mORe than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), AND
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member fORmatted AS a single column, AND the cost.
ORDER BY DESCending cost, AND do not use any subqueries. */
SELECT f.name AS fac_name, concat(m.surname, ' ', m.firstname) AS member_name,
CASE WHEN b.memid != 0 THEN b.slots*f.membercost
ELSE b.slots*f.guestcost END AS cost
FROM Bookings b
JOIN Members m
ON b.memid = m.memid
JOIN Facilities f
ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%' AND b.memid != 0 AND b.slots*f.membercost > 30
OR b.starttime LIKE '2012-09-14%' AND b.memid = 0 AND b.slots*f.guestcost > 30
ORDER BY cost DESC

-- or

SELECT f.name AS fac_name, concat(m.surname, ' ', m.firstname) AS member_name,
CASE WHEN b.memid != 0 THEN b.slots*f.membercost
ELSE b.slots*f.guestcost END AS cost
FROM Bookings b
JOIN Members m
ON b.memid = m.memid
JOIN Facilities f
ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
AND
CASE WHEN b.memid != 0 THEN b.slots*f.membercost
ELSE  b.slots*f.guestcost  END > 30
ORDER BY cost DESC


/* Q9: This time, produce the same result AS in Q8, but using a subquery. */
SELECT f.name, CONCAT(m.surname, ' ',  m.firstname) AS memname,
CASE WHEN b.memid != 0 THEN b.slots*f.membercost
ELSE b.slots*f.guestcost
END AS cost
FROM Bookings b
JOIN Facilities f
ON b.facid = f.facid
JOIN Members m
ON b.memid = m.memid
WHERE b.starttime LIKE '2012-09-14%'
AND (
    SELECT CASE WHEN b.memid != 0 THEN b.slots*f.membercost
    ELSE b.slots*f.guestcost
    END AS cost
       ) > 30
ORDER BY cost DESC

-- or
SELECT fac_name, member_name, cost
FROM
(
SELECT f.name AS fac_name,
CONCAT(m.surname, ' ', m.firstname) AS member_name,
CASE WHEN b.memid != 0 THEN b.slots*f.membercost
ELSE b.slots*f.guestcost END AS cost
FROM Bookings b
JOIN Members m
ON b.memid = m.memid
JOIN Facilities f
ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%'
) AS booking

WHERE cost > 30
ORDER BY cost DESC


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the databASe on your machine.

Copy AND pASte the LocalSQLConnection.py script into an empty Jupyter notebook, AND run it.

Make sure that the SQLFiles folder containing thes files is in your wORking directORy, AND
that you haven't changed the name of the .db file FROM 'sqlite\db\pythonsqlite'.

You should see the output FROM the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tASks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface AS AND WHEN you need to.

You'll need to pASte your query into value of the 'query1' variable AND run the code block again to get an output.

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name AND total revenue, sORted BY revenue. Remember
that there's a different cost fOR guests AND members! */
SELECT *
FROM
(SELECT fac_name, sum(cost) AS total_revenue
FROM(
SELECT f.name AS fac_name,
CASE WHEN b.memid != 0 THEN b.slots*f.membercost ELSE b.slots*f.guestcost end AS cost
FROM Bookings b
JOIN Facilities f
ON b.facid = f.facid) AS sub
GROUP BY fac_name) AS sub2
WHERE total_revenue  < 1000
ORDER BY total_revenue DESC

/* Q11: Produce a repORt of members AND who recommended them in alphabetic surname,firstname ORDER */
SELECT
m.surname|| ' '|| m.firstname AS member,
(SELECT surname||' '||firstname
FROM Members
WHERE memid = m.recommendedBY) AS recommender
FROM Members AS m
WHERE m.memid != 0
ORDER BY member


/* Q12: Find the facilities with their usage BY member, but not guests */
SELECT f.name AS fac_name, sum(b.slots) AS fac_usage
FROM Facilities f
JOIN Bookings b
ON b.facid = f.facid
WHERE b.memid != 0
GROUP BY f.name


/* Q13: Find the facilities usage BY month, but not guests */
SELECT f.name AS name,  strftime('%m',b.starttime) AS month,  sum(b.slots) AS fac_usage
FROM Facilities f
JOIN Bookings b
ON f.facid=b.facid
WHERE b.memid != 0
GROUP BY month,name
ORDER BY month, fac_usage DESC
