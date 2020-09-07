-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  from pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear -- replace this line
  from people
  where weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear -- replace this line
  from people
  where namefirst like '% %'
  order by namefirst asc, namelast asc
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, avg(height), count(*) -- replace this line
  from people
  group by birthyear
  order by birthyear asc
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, avgheight, count
  from q1iii
  where avgheight > 70
  order by birthyear asc
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, people.playerid, yearid -- replace this line
  from people, HallOfFame
  where people.playerid = HallOfFame.playerid and inducted = 'Y'
  order by yearid desc, people.playerid asc
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, q2i.playerid, collegeplaying.schoolid, q2i.yearid -- replace this line
  from q2i, schools, collegeplaying
  where q2i.playerid = collegeplaying.playerid and
        collegeplaying.schoolid = schools.schoolid and
        schools.state = 'CA'
  order by q2i.yearid desc, collegeplaying.schoolid asc, q2i.playerid asc
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT q2i.playerid, namefirst, namelast, collegeplaying.schoolid -- replace this line
  from q2i
  left join collegeplaying
  on q2i.playerid = collegeplaying.playerid
  order by q2i.playerid desc, collegeplaying.schoolid asc
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  select people.playerid, namefirst, namelast, yearid,
  1.0*(batting.H+batting.H2B+batting.H3B*2+batting.HR*3)/batting.AB as slg

  from people, batting
  -- replace this line
  where people.playerid = batting.playerid and batting.AB>50
  order by slg desc, yearid asc, people.playerid asc
  limit 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  with x as(select playerid, sum(H) as H, sum(H2B) as H2B, sum(H3B) as H3B, sum(HR) as HR, sum(AB) as AB
  FROM Batting
  group by playerid)

  SELECT people.playerid, namefirst, namelast,
  1.0*(x.H+x.H2B+x.H3B*2+x.HR*3)/x.AB as lslg
  from people, x
  where people.playerid = x.playerid and x.AB > 50
  order by lslg desc, people.playerid asc
  limit 10

   -- replace this line
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  with x as(select playerid, sum(H) as H, sum(H2B) as H2B, sum(H3B) as H3B, sum(HR) as HR, sum(AB) as AB
  FROM Batting
  group by playerid),

  y as (select playerid, AB, 1.0*(H+H2B+H3B*2+HR*3)/AB as lslg
  from x),

  z as(select lslg
  from y
  where playerid = "mayswi01")

  SELECT namefirst, namelast, y.lslg -- replace this line
  from people, y, z
  where people.playerid = y.playerid and y.AB>50 and y.lslg > z.lslg

;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, min(salary), max(salary), avg(salary) -- replace this line
  from salaries
  group by yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  with x as (select min, max from q4i where yearid=2016),
       y as (select * from salaries where yearid=2016),
       binid as (values (0), (1), (2), (3), (4), (5), (6), (7), (8), (9)),


      z as (select column1 as c, min+1.0/10.0*column1*(max-min) as low, min+1.0/10.0*(column1+1)*(max-min) as high,
             salary
      from x, binid, y
      where ((salary>=min+1.0/10.0*column1*(max-min) and salary<min+1.0/10.0*(column1+1)*(max-min)) or (c=9 and salary=max)  ))

  select c, low, high, count(*)
  from z
  group by c
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  -- with x as (select * from salaries order by yearid asc),

  with x as (SELECT yearid,
         min-lag(min) over (order by yearid),
         max-lag(max) over (order by yearid),
         avg-lag(avg) over (order by yearid)
  from q4i)-- replace this line

  select * from x where yearid!=1985

;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  with x as (SELECT people.playerid as id, namefirst, namelast, salary, yearid -- replace this line
       from people, salaries
       where not EXISTS
       (select salary from salaries as s2 where s2.yearid=2000 and s2.salary>salaries.salary)
       and yearid = 2000
       and people.playerid = salaries.playerid),

       y as (select people.playerid as id, namefirst, namelast, salary, yearid
       from people, salaries
       where not exists
       (select salary from salaries as s2 where s2.yearid=2001 and s2.salary>salaries.salary)
       and yearid = 2001
       and people.playerid = salaries.playerid
     )

  select * from x
  union
  select * from y
  order by yearid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS

with x as(select allstarfull.teamid as id, salary
             from salaries, allstarfull
             where salaries.teamid = allstarfull.teamid
                   and salaries.yearid=2016
                   and salaries.playerid=allstarfull.playerid
                   and allstarfull.yearid=2016)

  SELECT id, max(salary)-min(salary)
  from x
  group by id -- replace this line
;
