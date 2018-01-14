## Homework Assignment

USE sakila;

#* 1a. Display the first and last names of all actors from the table `actor`.
 
SELECT first_name,last_name 
FROM actor 
ORDER BY first_name, last_name;

#* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT CONCAT(first_name, ' ' , last_name) AS actor_name 
FROM actor 
ORDER BY actor_name;

#* 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id,first_name,last_name 
FROM actor 
WHERE first_name = 'Joe';

#* 2b. Find all actors whose last name contain the letters `GEN`:

SELECT * 
FROM actor 
WHERE last_name LIKE '%GEN%';

#* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT * 
FROM actor 
WHERE last_name LIKE '%LI%' 
ORDER BY last_name, first_name;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country 
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

#* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
#alter table actor drop column middle_name;

ALTER TABLE actor 
ADD COLUMN middle_name VARCHAR(100) AFTER first_name;

#* 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.

ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;

#* 3c. Now delete the `middle_name` column.

ALTER TABLE actor 
DROP COLUMN middle_name;

#* 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) last_name_count 
FROM actor 
GROUP BY last_name ORDER BY last_name;
  	
#* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) last_name_count 
FROM actor GROUP BY last_name 
HAVING COUNT(last_name)>=2;  	
    
#* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor 
SET first_name = 'HARPO' 
WHERE first_name = 'groucho' AND last_name = 'williams' AND actor_id = 172;

SELECT * FROM actor WHERE actor_id = 172;

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor 
SET first_name = (CASE WHEN first_name = 'harpo' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END) 
WHERE actor_id = 172;

#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

DESCRIBE address;

#* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

#Describe address;
#describe staff;

SELECT s.first_name, s.last_name, a.address 
FROM staff s INNER JOIN address a 
	ON s.address_id = a.address_id;

#* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. 

#describe payment;

SELECT CONCAT(s.first_name, ' ', s.last_name) staff_member, SUM(p.amount) amount_rung_up 
FROM staff s INNER JOIN payment p
	ON s.staff_id = p.staff_id
WHERE p.payment_date like '2005-08%'
GROUP BY CONCAT(s.first_name, ' ', s.last_name);

#* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

#DESCRIBE film;
#DESCRIBE film_actor;
#SELECT * FROM film;
#SELECT * FROM film_actor;

SELECT f.title, COUNT(fa.actor_id) actor_count
FROM film f INNER JOIN film_actor fa
	ON f.film_id = fa.film_id
GROUP BY f.title
ORDER BY f.title;
#* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

#DESCRIBE inventory;

SELECT COUNT(i.film_id) film_copies
FROM inventory i INNER JOIN film f
	ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

#* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

#DESCRIBE payment;
#DESCRIBE customer;

SELECT c.first_name, c.last_name, SUM(p.amount) amount_paid
FROM customer c INNER JOIN payment p 
	ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name;

#  ```
#  	![Total amount paid](Images/total_payment.png)
#  ```

#* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

#DESCRIBE film;
#DESCRIBE language;

SELECT f.title
FROM film f 
WHERE (f.title LIKE 'K%' OR f.title LIKE 'Q%') AND 
	f.language_id in(
		select l.language_id 
		from language l 
        where l.name = 'english')
ORDER BY f.title;

#* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select a.first_name, a.last_name
FROM actor as a
where a.actor_id in 
	(select fa.actor_id 
	from film_actor fa
	where fa.film_id in(
		select f.film_id
		from film f
		where f.title = 'Alone Trip'));

#* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

#DESCRIBE customer;
#DESCRIBE address;
#DESCRIBE city;
#DESCRIBE country;

SELECT c.first_name, c.last_name, c.email, country.country
FROM (customer c INNER JOIN address a
	ON c.address_id = a.address_id)
		INNER JOIN city
			ON a.city_id = city.city_id
				INNER JOIN country
					ON city.country_id = country.country_id
WHERE country.country = 'canada';

#* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

#DESCRIBE film;
#DESCRIBE film_category;
#DESCRIBE category;
#select * from category;

SELECT f.title, c.name
FROM (film f INNER JOIN film_category fc
	ON f.film_id = fc.film_id)
		INNER JOIN category c
			ON fc.category_id = c.category_id
WHERE c.name = 'family';

#* 7e. Display the most frequently rented movies in descending order.

#DESCRIBE rental;
#DESCRIBE payment;

SELECT f.title, COUNT(p.rental_id) times_rented
FROM payment p INNER JOIN rental r
	ON p.rental_id = r.rental_id
		INNER JOIN inventory i
			ON i.inventory_id = r.inventory_id
				INNER JOIN film f
					ON f.film_id = i.film_id
GROUP BY f.title
ORDER BY times_rented DESC;
#* 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(p.amount) AS total_dollars
FROM store s INNER JOIN customer c
	ON s.store_id = c.store_id
		INNER JOIN payment p
			ON c.customer_id = p.customer_id
GROUP BY s.store_id;

#* 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, city.city, country.country
FROM store s INNER JOIN address a
	ON s.address_id = a.address_id
		INNER JOIN city
			ON a.city_id = city.city_id
				INNER JOIN country
					ON city.country_id = country.country_id;
                   
	
#* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
 select c.name, sum(p.amount) gross_revenue
 from category c inner join film_category fc
	on c.category_id = fc.category_id
		inner join inventory i
			on fc.film_id = i.film_id
				inner join rental r
					on i.inventory_id = r.inventory_id
						inner join payment p
							on r.rental_id = p.rental_id
group by c.category_id
order by gross_revenue desc
limit 5;
    
    
#* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
Create view top_five_cat_gross_rev as (
 select c.name, sum(p.amount) gross_revenue
 from category c inner join film_category fc
	on c.category_id = fc.category_id
		inner join inventory i
			on fc.film_id = i.film_id
				inner join rental r
					on i.inventory_id = r.inventory_id
						inner join payment p
							on r.rental_id = p.rental_id
group by c.category_id
order by gross_revenue desc
limit 5
);

#* 8b. How would you display the view that you created in 8a?
select * 
FROM top_five_cat_gross_rev;

#* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP view top_five_cat_gross_rev;

### Appendix: List of Tables in the Sakila DB

#* A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

#```sql
#	'actor'
#	'actor_info'
#	'address'
#	'category'
#	'city'
#	'country'
#	'customer'
#	'customer_list'
#	'film'
#	'film_actor'
#	'film_category'
#	'film_list'
#	'film_text'
#	'inventory'
#	'language'
#	'nicer_but_slower_film_list'
#	'payment'
#	'rental'
#	'sales_by_film_category'
#	'sales_by_store'
#	'staff'
#	'staff_list'
#	'store'
#```
