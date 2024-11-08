
create table course
	(course_id		varchar(8), 
	 title			varchar(50), 
	 dept_name		varchar(20),
	 credits		numeric(2,0) check (credits > 0),
	 primary key (course_id)
	);

create table takes
	(ID			varchar(5), 
	 course_id		varchar(8),
	 sec_id			varchar(8), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 grade		        varchar(2),
	 primary key (ID, course_id, sec_id, semester, year)
	);


	-----------Some used test queries ----------

SELECT count(*) FROM course c WHERE EXISTS (SELECT * FROM takes t WHERE t.course_id = c.course_id);

SELECT c.course_id FROM course c WHERE EXISTS (SELECT * FROM takes t WHERE t.course_id = c.course_id) ORDER BY c.course_id LIMIT 10;

select count(*) from course c inner JOIN takes t on c.course_id=t.course_id and c.year=t.year; 

select count(*) from takes t1 inner JOIN takes t2 on t1.course_id=t2.course_id and t1.year>t2.year; 