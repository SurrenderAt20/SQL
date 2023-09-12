--GROUP: cit12, Members: Cristina-Genoveva Bodnari, Filoftea-Bianca Grecu, Karsten Heiseldal, Lasse Vestergaard Fuglsbjerg, Alex Pozsgai

-- 1. Find the names of all the instructors from Biology department
select name
from instructor
where dept_name = 'Biology';

-- 2. Find the names of courses in Computer science department which have 3 credits
select title
from course
where dept_name = 'Comp. Sci.'
and credits = 3;

-- 3. For the student with ID 30397, show all course_id and title of all courses registered for by the student.
select Distinct course_id, title
from takes natural join course
where id = '30397'
order by course_id;

-- 4. As above, but show the total number of credits for such courses (taken by that student). 
-- Don't display the tot_creds value from the student table, you should use SQL aggregation on courses taken by the student.
select DISTINCT course_id, title, SUM(credits)
from takes natural join course
where id = '30397'
group by course_id, title
order by course_id;

-- 5. Now display the total credits (over all courses) for each of the students having more than 85 in total credits, along with the ID of the student; 
-- don't bother about the name of the student. 
-- don't bother about students who have not registered
select id, sum(credits)
from takes natural join course
group by id
having sum(credits) > 85;

-- 6. Find the names of all students who have taken any course at the Languages department with the grade 'A+' (there should be no duplicate names)
select DISTINCT name
from student natural join takes
where dept_name = 'Languages' AND
grade like 'A+'
order by name;

-- 7. Display the IDs of all instructors from the Marketing department who have never taught a course (interpret "taught" as "taught or is scheduled to teach")
select instructor.id
from instructor natural join department left join teaches on instructor.id = teaches.id
where dept_name = 'Marketing' AND teaches.course_id is null;

-- 8. As above, but display the names of the instructors also, not just the IDs.
select instructor.id, instructor.name
from instructor natural join department left join teaches on instructor.id = teaches.id
where dept_name = 'Marketing' AND teaches.course_id is null;

-- 9. Using the university schema, write an SQL query to find the number of students in each section in year 2009.
-- The result columns should be “course_id, sec_id, year, semester, num”, where the latter is the number. 
-- You do not need to output sections with 0 students.
select course_id, sec_id, semester, year, count(course_id) as num
from takes
where year = 2009
group by course_id, sec_id, semester, year;

/* 10. Find the maximum and minimum enrollment across all 
sections, considering only sections that had some enrollment, don't 
worry about those that had no students taking that section. Tip: you 
can use a subquery in from or a with-clause to provide an 
intermediate table on (course_id,sec_id, semester,year,num) where 
num is the count of enrolled students.
*/
select Max(num), Min(num)
from
(
	select course_id, sec_id, semester, year, count(sec_id) as num
	from takes
	group by course_id, sec_id, semester, year
);

-- 11. Find all sections that had the maximum enrollment (along with the enrollment). Tip: you can use a subquery in from or a with-clause.
select course_id, sec_id, semester, year, count(course_id) as num
from takes
group by course_id, sec_id, semester, year
having count(course_id) =
(
	select Max(num)
	from
	(
		select course_id, sec_id, semester, year, count(course_id) as num
		from takes
		group by course_id, sec_id, semester, year
	)
);

-- 12. As in in Q10, but now also include sections with no students taking them; the enrollment for such sections should be treated as 0. Tip: Use aggregation and outer join 

select Max(num), Min(num)
from
(
	select course_id, sec_id, semester, year, count(sec_id) as num
	from takes natural full outer join course 
	group by course_id, sec_id, semester, year
);

-- 13. Find all courses that the instructor with id '19368' have taught
select *
from teaches
where id = '19368';

-- 14. Find instructors who have taught all the above courses. Hint: one option is to use "... not exists (... except ...)"
select DISTINCT id
from teaches
where course_id in 
(
	select course_id
	from teaches
	where id = '19368'
);
-- 15. Insert each instructor as a student, with tot_creds = 0, in the same department
insert into student 
select id, name, dept_name, 0 as tot_cred
from instructor
where instructor.id in
(
	(
	select id from instructor) 
	EXCEPT 
	(
	select id from student)
);

-- 16. Now delete all the newly added "students" above (note: already existing students who happened to have tot_creds = 0 should not get deleted)
delete from student
where id in 
(
	(
	select id
	from instructor) 
	EXCEPT 
	(
	select id
	from student
	where tot_cred != 0)
);

/* 17. You may have noticed that the tot_cred value for students 
do not always match the credits from courses they have taken. Write 
a query to compare these that show a students id and tot_cred 
together with the correct calculated total credits. Show only the 
cases where the two values match
*/
select id, tot_cred, sum(credits)
from student natural join takes, course
where takes.course_id = course.course_id
group by id
HAVING sum(credits) = tot_cred;

-- 18. Write and execute a query to update tot_cred for all students to the correct calculated value based on the credits passed - thereby bringing the database back to consistency.
update student Stud
set tot_cred = 
(
select sum(credits) as tot_cred
from takes, course
where takes.course_id = course.course_id
and Stud.id = takes.id
);

-- 19. Run Q17 again, but now only show when the two values differ
select id, tot_cred, sum(credits)
from student natural join takes, course
where takes.course_id = course.course_id
group by id
HAVING sum(credits) != tot_cred;

-- 20. Update the salary of each instructor to 29001 + 10000 times the number of course sections they have taught.
UPDATE instructor inst 
SET salary = 29001 + 10000 * (
    SELECT
    CASE
        WHEN COUNT(*) = 0
    THEN 0
        ELSE COUNT(*) 
    END
    FROM
        teaches 
    WHERE
        inst.ID = teaches.ID 
);
    
-- 21. List name and salary for the 10 first instructors (alphabetic order)
select id, name, salary
from instructor
order by name, salary
LIMIT 10;