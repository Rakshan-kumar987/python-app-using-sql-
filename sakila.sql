use sakila;
show tables;

#### Getting the details of all the tables in the dataset...
use information_schema;
show tables;
select table_name, column_name from columns where table_schema = "sakila";

-- list the names of all english films
select film.title from film inner join language where film.language_id = language.language_id and 
language.name = "English";


select * from sakila.actor;

-- Display the first name and the last name of all actors in the actor table
select first_name, last_name from sakila.actor;
select actor.first_name, actor.last_name from actor;

-- Display the first and the last names in a single column; name the column: "Actor Name"
select concat(first_name, ' ', last_name) as "Actor Name" from sakila.actor;

-- Find the id, name of the actor with the first name "Joe"
select actor_id, first_name, last_name from sakila.actor where first_name = "Joe";

-- find all actors whose last names contains the word "Gen"
select * from sakila.actor where last_name like "%Gen%";

-- find all actors whoe last name contains the letters "NG". 
-- Order the rows by last name and first name, in that order
select concat(first_name, ' ', last_name) as "Actor Name" from sakila.actor where last_name like "%NG%" order by last_name, first_name;

-- list the names of actors, and how many actors have that name
select last_name, count(*) Count from sakila.actor group by last_name order by Count desc;
### we can do the same using the column index numbers...
select last_name, count(*) Count from sakila.actor group by 1 order by 2 desc;

-- List the last names of actors, and how many actors have that name, order by highest frequency 
-- and display only those which are shared by more than two actors
select last_name, count(*) Count from sakila.actor group by last_name having Count > 2 order by Count desc;
#### Order by should be the last part of the query... 

use sakila;
describe address;
describe staff;


-- Extract the names and addresses of staff
select staff.first_name, staff.last_name, address.address from staff inner join address on address.address_id = staff.address_id;

-- Display the total sales generated by each employee
#### staff and payment tables to be used...
select sum(payment.amount), staff.last_name from payment inner join staff on payment.staff_id = staff.staff_id group by last_name;
select concat(staff.first_name, ' ', staff.last_name) Staff, sum(payment.amount) from staff inner join payment on staff.staff_id = payment.staff_id group by payment.staff_id;

-- Display the total sales generated by each employee for the month of July 2005. 
-- Use the staff and payment tables... 
select concat(staff.first_name, ' ', staff.last_name) Staff, 
sum(payment.amount) from staff inner join payment on staff.staff_id = payment.staff_id 
where payment.payment_date like "%-07-%" group by payment.staff_id ;

select concat(staff.first_name, ' ', staff.last_name) Staff, 
sum(payment.amount) from staff inner join payment on staff.staff_id = payment.staff_id  
AND payment.payment_date between '2005-07-01' and '2005-08-01' group by payment.staff_id ;



select concat(staff.first_name, ' ', staff.last_name) Staff, 
payment.amount, payment_date from staff inner join payment on staff.staff_id = payment.staff_id 
where payment.payment_date like "%-07-%";

-- display each film and the number of actors in it
select film.title, count(film_actor.actor_id) from film inner join film_actor on film.film_id = film_actor.film_id group by film.title;

-- display all the first names of the actors in each film
select film.title, concat(actor.first_name," ",actor.last_name) as Name from film inner join film_actor on film_actor.film_id = film.film_id inner join actor on actor.actor_id = film_actor.actor_id order by film.title, Name;

-- Use subqueries to display all actors in the film "American Circus"
#Step 1: Get the first name and last name
#Step 2: find the actor id from the movie
#Step 3:

#We find the Film ID
select film.film_id from film where title = "American Circus";
	#We find the actor id
select actor_id from film_actor;
	#Join the above two...
select actor_id from film_actor where film_id = (select film.film_id from film where title = "American Circus");

	#Display the names of actors
select actor.first_name, actor.last_name from actor;
	#join all the three
select actor.first_name, actor.last_name from actor 
where actor.actor_id in (select actor_id from film_actor where film_id = (select film.film_id from film where title = "American Circus"));

-- Find how many copies of each movie is available in the inventory
select film.title, count(film.title) 
from film inner join inventory
on film.film_id = inventory.film_id
group by film.title;
	#### The same without displaying the title... 
select film_id, count(film_id) from inventory group by film_id;

select inventory.film_id, film.title, count(inventory.film_id)
from inventory inner join film
on inventory.film_id = film.film_id
group by film_id;

-- display the customers along with their payments and display the top 5 payments' list
select concat(customer.first_name, " ", customer.last_name) Name, sum(payment.amount) Amount from customer inner join payment on customer.customer_id = payment.customer_id group by Name order by Amount desc limit 5;


-- get the names and email address of all customers in Canada
		### We need to make use of four tables 
		### Customer -- address -- city -- country
		### country - country_id, country;
		### city - city id, country_id;
		### customer - address_id
		### address - address_id, city_id;
select customer.first_name, customer.last_name, customer.email 
from customer 
inner join address on customer.address_id = address.address_id
inner join city on city.city_id = address.city_id
inner join country on country.country_id = city.country_id
where country.country = "Canada";

-- display most rented movies
		### rental -- inventory -- film
        ### count how many times the movie was rented out... 
select film.title, count(rental.rental_id) as Total_Rentals
from film
inner join inventory on film.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.rental_id
group by 1
order by 2 desc;
##### Here suppose we have group by with giving count in the beginning
	#### then the query will return only one record for each title... 
    



-- determine the sales by each store
		### payment -- staff - store
select sum(payment.amount), store.store_id
from payment
inner join staff on payment.staff_id = staff.staff_id
inner join store on staff.store_id = store.store_id
group by 2;


-- display the top 5 grossing genres
			### category -- film_category -- film -- rental -- inventory -- payment
select category.name as Genre, sum(payment.amount) as Total
from category
inner join film_category on category.category_id = film_category.category_id
inner join inventory on film_category.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join payment on rental.rental_id = payment.rental_id
group by Genre
order by Total desc limit 5;
    
-- display all documentary films
select title
from film
inner join film_category on film.film_id = film_category.film_id
inner join category on film_category.category_id = category.category_id
where category.name = "Documentary";


############## CREATING VIEW AND SAVING ######################
-- create a view of the query above
create view top_5_grossing_genres as 
select category.name as Genre, sum(payment.amount) as Total
from category
inner join film_category on category.category_id = film_category.category_id
inner join inventory on film_category.film_id = inventory.film_id
inner join rental on inventory.inventory_id = rental.inventory_id
inner join payment on rental.rental_id = payment.rental_id
group by Genre
order by Total desc limit 5;

select * from top_5_grossing_genres;
##########################################################





select * from category;
select * from film;
select * from film_category;
select * from rental;
select * from address;
select * from city;

select * from payment;
select * from film;
select * from actor;
select * from film_actor;
select * from actor_info;

select * from address;
select * from staff;
