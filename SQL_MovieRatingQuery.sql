/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

/*
You've started a new movie-rating website, and you've been collecting data on reviewers' ratings of various movies. There's not much data yet, but you can still try out some interesting queries. Here's the schema: 

Movie ( mID, title, year, director ) 
English: There is a movie with ID number mID, a title, a release year, and a director. 

Reviewer ( rID, name ) 
English: The reviewer with ID number rID has a certain name. 

Rating ( rID, mID, stars, ratingDate ) 
English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate. 
*/


#1 Find the titles of all movies directed by Steven Spielberg. 

SELECT TITLE
FROM MOVIE
WHERE DIRECTOR = "Steven Spielberg";


#2 Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. 

select distinct m.year
from Movie m, Rating r
where m.mID = r.mID and r.stars in (4,5)
order by m.year ASC;


#3 Find the titles of all movies that have no ratings. 

select m.title
from Movie m
left join Rating r
on m.mID = r.mID
where r.rID is NULL;


#4 Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 

select r.name
from Reviewer r, Rating ra
where r.rID = ra.rID
and ra.ratingDate is NULL;


#5 Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 

select r.name, m.title, ra.stars, ra.ratingDate
from Reviewer r, Movie m, Rating ra
where r.rID = ra.rID and ra.mID = m.mID
order by r.name, m.title, ra.stars;


#6 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. 

select name, title
from Movie
join Rating ra1 using (mID)
join Reviewer r using (rID)
join Rating ra2 using (mID)
where 1=1
and ra1.rID = ra2.rID 
and ra1.mID = ra2.mID
and ra1.ratingDate < ra2.ratingDate 
and ra2.stars > ra1.stars;


#7 For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. 

select m.title, max(ra.stars) 
from Movie m, Rating ra
where m.mID = ra.mID
group by m.mID
order by m.title;


#8 For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 

select m.title, max(ra.stars)-min(ra.stars) as spread
from Movie m, Rating ra
where m.mID = ra.mID
group by m.mID
order by spread DESC, m.title;



#9 Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
#(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)

select avg(b4.avg) - avg(a4.avg) from   
(
	select avg(stars) as avg 
	from Rating
    join Movie using (mID)
    where year < 1980
    group by mID
    ) as b4,
(
	select avg(stars) as avg 
	from Rating
    join Movie using (mID)
    where year > 1980
    group by mID
    ) as a4;


#EXTRAS
#1 Find the names of all reviewers who rated Gone with the Wind. 

select name 
from Reviewer
where rID in 
(
	select rID from Rating 
    join Movie using (mID)
    where title = 'Gone with the Wind'
    );


#2 For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 

select r.name, m.title, ra.stars
from Reviewer r, Movie m, Rating ra
where 1=1
and r.rID = ra.rID 
and ra.mID = m.mID
and r.name = m.director;


#3 Return all reviewer names and movie names together in a single list, alphabetized. 
#(Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 

select name from Reviewer
union
select title from Movie;


#4 Find the titles of all movies not reviewed by Chris Jackson.

select title 
from Movie
where title not in 
(
	select m.title from Movie m, Rating ra, Reviewer r
    where m.mID = ra.mID and r.rID = ra.rID
    and r.name = 'Chris Jackson'
    );


#5 For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
#Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 

select distinct r1.name, r2.name
from Reviewer r1, Reviewer r2, Rating t1, Rating t2
where r1.rID = t1.rID
and r2.rID = t2.rID
and t1.rID = t1.rID
and t1.mID = t2.mID 
and r1.name < r2.name


#6 For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 

select r.name, m.title, ra.stars
from Reviewer r, Movie m, Rating ra
where ra.stars is (select min(stars) from Rating)
and r.rID = ra.rID
and m.mID = ra.mID;


#7 List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 

select title, ratings.avgstar
from Movie, 
    (select mID, avg(stars) as avgstar from Rating
    group by mID
    )as ratings
where Movie.mID = ratings.mID
order by Ratings.avgstar DESC, title ASC;


#8 Find the names of all reviewers who have contributed three or more ratings. 
#(As an extra challenge, try writing the query without HAVING or without COUNT.) 

select name
from Reviewer
where (select count(*) from Rating 
       where Reviewer.rID = Rating.rID
       group by rID) >= 3;



#9 Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. 
#(As an extra challenge, try writing the query both with and without COUNT.) 

select m.title, m.director 
from Movie m
where director in
    (
    select director from Movie
    group by director
    having count(mID) > 1
    )
order by director, title;



#10 Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
#(Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 

select title, avg(stars)
from Rating
join Movie using (mID)
group by mID 
having avg(stars) = 
(
    select max(p.avg(stars))
    from (
        select Movie.title, avg(stars) as avgRating
        from Rating
        inner join Movie using (mID)
        group by mID 
        ) as p
   )



#11 Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
#(Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 






#12 For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 

select director, title, max(stars)
from Movie, Rating
where Movie.mID = Rating.mID
and director is not NULL
group by director;







