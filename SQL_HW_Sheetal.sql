-- SQL and SQLWorkbench Homework | Feb 1, 2020
-- Submitted by : Sheetal Bongale | UT Data Analysis and Visualization
-- MySQL and MySQLWorkbench exercise to execute queries on the Sakila database.
-- --------------------------------------------------------------------------- --
USE sakila;
SHOW TABLES;

-- 1a. Display the first and last names of all actors from the table actor.
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
	first_name,
	last_name, 
	CONCAT (first_name, ' ', last_name) AS 'Actor Name'
FROM actor a;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT 
	actor_id,
	first_name, 
	last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT
	actor_id, 
	first_name, 
	last_name
FROM actor
WHERE last_name LIKE '%GEN%';
    
-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT 
	actor_id, 
	first_name, 
	last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY 
	last_name,
    first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT
	country_id, 
	country
FROM country
WHERE country IN ('Afghanistan' , 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD column description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor ADD column description BLOB;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
	last_name,
	COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors:
SELECT 
	last_name, 
	COUNT(last_name)
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
/* DESCRIBE address;*/

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT 
	s.first_name, 
	s.last_name, 
	a.address
FROM staff s 
LEFT JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT 
	s.first_name, 
	s.last_name, 
	SUM(p.amount) AS 'Total Amount'
FROM staff s 
JOIN payment p ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
-- Use inner join.
SELECT 
	title, 
	COUNT(actor_id) 
FROM film
INNER JOIN film_actor a ON a.film_id = film.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
	f.title, 
	count(i.inventory_id)  AS "Total Copies"
FROM inventory i
INNER JOIN film f ON i.film_id = f.film_id
WHERE f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT 
	first_name, 
	last_name, 
	SUM(p.amount) AS "Total Payment"
FROM customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
GROUP BY p.customer_id 
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
	f.title,
	l.name AS 'Language'
FROM film f
INNER JOIN language l ON f.language_id = l.language_id
WHERE (l.name = 'English') AND f.title LIKE 'K%' OR f.title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT
    first_name,
    last_name
FROM actor
WHERE actor_id IN
	(
    Select actor_id
	FROM film_actor
	WHERE film_id IN 
	(
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
	));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT 
	concat(first_name," ", last_name) AS 'Customer Name',
	email
FROM customer
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country = 'canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
-- Option 1:
SELECT 
	title,
	category 
FROM film_list
WHERE category = 'family';
-- Option 2:
SELECT 
	f.title,
    c.name
FROM film as f
JOIN film_category USING (film_id)
JOIN category as c USING(category_id)
WHERE c.name = 'Family';
-- Option 3:
SELECT f.title
FROM film AS f
WHERE film_id IN
	(
	SELECT film_id
	FROM film_category
	WHERE category_id IN
	(
		SELECT category_id 
		FROM category AS c
		WHERE c.name = 'Family'
	));

-- 7e. Display the most frequently rented movies in descending order.
SELECT 
	title, 
	COUNT(title) as 'Rentals'
FROM film f
INNER JOIN inventory i ON (f.film_id = i.film_id)
INNER JOIN rental r ON (i.inventory_id = r.inventory_id)
GROUP by title
ORDER BY Rentals desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
	store_id,
	SUM(p.amount) AS 'Gross Amount $'
FROM payment AS p
JOIN rental USING (rental_id)
JOIN inventory USING (inventory_id)
JOIN store USING (store_id)
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT 
	store_id,
	city,
	country
FROM store
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id);

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT 
	name, 
	SUM(amount) AS 'Gross Revenue $'
FROM rental
JOIN inventory USING (inventory_id)
JOIN payment USING (rental_id)
JOIN film_category USING (film_id)
JOIN category USING (category_id)
GROUP BY name
ORDER BY SUM(amount) desc
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres AS
SELECT 
	name AS 'Genre',
	SUM(amount) AS 'Gross Revenue $'
FROM rental
JOIN inventory USING(inventory_id)
JOIN payment USING(rental_id)
JOIN film_category USING(film_id)
JOIN category USING (category_id)
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five_Genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_Genres;
