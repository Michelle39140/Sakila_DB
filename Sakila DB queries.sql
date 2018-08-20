use sakila;

/* 1a. Display the first and last names of all actors from the table actor. */
/* DESCRIBE actor; */
select first_name,last_name from actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column "Actor Name". */
select concat(first_name," ",last_name) as "Actor Name" from actor;

/* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information? */
select actor_id,first_name,last_name from actor
where first_name = "Joe";

/* 2b. Find all actors whose last name contain the letters GEN */
select actor_id,first_name,last_name from actor
where last_name like '%GEN%';

/* 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order */
select actor_id,first_name,last_name from actor
where last_name like '%LI%'
order by last_name ASC, first_name ASC;

/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China */
select country_id, country from country
where country in ('Afghanistan', 'Bangladesh', 'China');

/* 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named "description" and use the data type BLOB*/
alter table actor
add column description BLOB;
select * from actor;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column*/
alter table actor
drop column description;
select * from actor;

/* 4a. List the last names of actors, as well as how many actors have that last name */
select last_name, count(first_name) as 'number of actors' from actor
group by last_name
order by `number of actors` desc;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors */
select last_name, count(first_name) as 'number of actors' from actor
group by last_name
having `number of actors`>=2
order by `number of actors` desc;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record */
select * from actor
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

select * from actor
where first_name = 'HARPO' and last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO */
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and last_name = 'WILLIAMS';

select * from actor
where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

/* 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? */
show create table address;
/* result:
CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
*/

/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address */
select first_name, last_name, address from staff
inner join address using (address_id);

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment */
select concat(first_name, " ",last_name) as "employee", sum(amount) as "total amount" 
from payment
inner join staff using (staff_id)
where payment_date like '2005-08-%'
group by `employee`;

/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join */
select title, count(actor_id) as 'number of actors' 
from film f
inner join film_actor fa on f.film_id = fa.film_id
group by title;

/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system? */
select title, count(inventory_id) as 'number of copies'
from film inner join inventory using (film_id)
where title = 'Hunchback Impossible';

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name */
select first_name, last_name, sum(amount) as 'total payment'
from customer c inner join payment using (customer_id)
group by c.customer_id
order by last_name asc;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English */
select title from film 
where 
language_id in (
	select language_id from `language`
	where `name` = 'English')
and 
(title like 'K%' 
or 
title like 'Q%');

/* 7b. Use subqueries to display all actors who appear in the film Alone Trip */
select first_name, last_name from actor 
where actor_id in (
	select actor_id from film_actor
    where film_id in (
		select film_id from film
		where title = 'Alone Trip'
		)
);

/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information */
select c.first_name, c.last_name, c.email 
from customer c
inner join address using (address_id)
inner join city using (city_id)
inner join country using (country_id)
where country = 'Canada';

/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films */
select title from film
where film_id in (
    select film_id from film_category
	where category_id in (
		select category_id from category
		where name = 'Family'
    )
);

/* 7e. Display the most frequently rented movies in descending order */
select f.title,count(r.rental_id) as 'number of rental'
from film f
inner join inventory i using (film_id)
inner join rental r using (inventory_id)
group by f.title
order by `number of rental` desc;

/* 7f. Write a query to display how much business, in dollars, each store brought in */
select s.store_id, sum(p.amount) as 'total dollars'
from store s
inner join customer c using (store_id)
inner join payment p using (customer_id)
group by s.store_id;

/* 7g. Write a query to display for each store its store ID, city, and country */
select s.store_id, c.city, cn.country
from store s 
inner join address using (address_id)
inner join city c using (city_id)
inner join country cn using (country_id);

/* 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
select ca.name, sum(p.amount) as 'gross revenue'
from category ca
inner join film_category using (category_id)
inner join inventory using (film_id)
inner join rental using (inventory_id)
inner join payment p using (rental_id)
group by ca.name
order by `gross revenue` desc
limit 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view */
create or replace view top_five_genres as
select ca.name, sum(p.amount) as 'gross revenue'
from category ca
inner join film_category using (category_id)
inner join inventory using (film_id)
inner join rental using (inventory_id)
inner join payment p using (rental_id)
group by ca.name
order by `gross revenue` desc
limit 5;


/* 8b. How would you display the view that you created in 8a? */
select * from top_five_genres;

/* 8c. You find that you no longer need the view top_five_genres. Write a query to delete it */
drop view if exists top_five_genres;
        