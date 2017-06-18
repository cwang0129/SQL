/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

/*
Students at your hometown high school have decided to organize their social network using databases. So far, they have collected information about sixteen students in four grades, 9-12. Here's the schema: 

Highschooler ( ID, name, grade ) 
English: There is a high school student with unique ID and a given first name in a certain grade. 

Friend ( ID1, ID2 ) 
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 

Likes ( ID1, ID2 ) 
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. 

*/


#1 Find the names of all students who are friends with someone named Gabriel. 

 select h.name from Highschooler h
 where h.ID in
 (
 select f.ID1 as ID from Friend f where ID2 in (
     select h.ID from Highschooler h 
     where h.name ='Gabriel')
  union 
  select f.ID2 as ID from Friend f where ID1 in (
     select h.ID from Highschooler h 
     where h.name ='Gabriel')
 );


#2 For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. 

select h1.name, h1.grade, h2.name, h2.grade
from Highschooler h1
join Likes l on h1.ID = l.ID1
join Highschooler h2 on h2.ID = l.ID2
where h1.grade >= h2.grade + 2
and h1.name <> h2.name;


#3 For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. 

select a.name, a.grade, b.name, b.grade
from Highschooler a
inner join (
    select ID1, ID2 from Likes
    where ID1 in (select ID2 from Likes)
    and ID2 in (select ID1 from Likes)
    )as L
on L.ID1 = a.ID
inner join Highschooler b
on L.ID2 = b.ID
where a.name < b.name


#4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. 

select name, grade 
from Highschooler
where ID not in (select ID1 from Likes
                 union
                 select ID2 from Likes);


#5 For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 

select a.name, a.grade, b.name, b.grade
from Highschooler a, Highschooler b, 
    (select ID1, ID2 from Likes 
    where ID2 not in (select ID1 from Likes)
    )as p
where p.ID1 = a.ID and p.ID2 = b.ID;


#6 Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. 

select h1.name, h1.grade 
from Highschooler h1
where h1.ID not in 
    (
    select ID1 from Friend F, Highschooler h2
    where F.ID1 = h1.ID and F.ID2 = h2.ID
    and h2.grade <> h1.grade
    )
order by h1.grade, h1.name;


#7 For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. 


#8 Find the difference between the number of students in the school and the number of different first names. 

select count(ID) - count(distinct name)
from Highschooler;


#9 Find the name and grade of all students who are liked by more than one other student. 

select name, grade 
from Highschooler
where ID in 
	(
		select ID2 
		from Likes 
		group by ID2 
		having count(*) > 1
	);


#Extras
#1 



#2 Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. 

select name, grade
from Highschooler
where ID not in 
    (select h.ID from Highschooler h
    join Friend f on f.ID1 = h.ID
    join Highschooler h2 on f.ID2 = h2.ID
    where h.grade = h2.grade 
    and h.name <> h2.name
    );


#3 What is the average number of friends per student? (Your result should be just one number.) 

select avg(p.n) from
    (
    select ID1, count(ID2) as n from Friend
    group by ID1
    ) as p;


#4 Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend. 




#5 Find the name and grade of the student(s) with the greatest number of friends. 

select h.name, h.grade 
from Highschooler h 
join Friend f on h.ID = f.ID1
group by f.ID1
having count(*) = (
    select max(p.c) from
        (
        select ID1, count(ID2) as c
        from Friend
        group by ID2
        )as p
    )






