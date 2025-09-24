-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

use mavenmovies;

select * from rental;

select * from inventory;

select * from customer;

select * from payment;

select * from film;

select * from category;

select * from film_category;

select * from language;

select * from actor;

select * from film_actor;

select * from address;

select * from city;

select * from country;


-- Q1 You need to provide customer firstname, lastname and email id to the marketing team

select first_name, last_name, email
from customer;

-- Q2 How many movies are with rental rate of $0.99?

select count(*) as Cheapest_rentals
from film 
where rental_rate = 0.99; 

-- Q3 We want to see rental rate and how many movies are in each rental category

select rental_rate, count(*) as total_no_of_movies
from film 
group by rental_rate;

-- Q4 Which rating has the most films?

select rating, count(*) as Rating_category
from film 
group by rating
order by Rating_category desc;

-- Q5 Which rating is most prevalant in each store?

select I.store_id, F.rating, count(F.rating) as Total_films
from inventory as I left join 
	film as F
on I.film_id = F.film_id
group by I.store_id, F.rating
order by Total_films desc; 

-- Q6 List of films by Film Name, Category, Language

select F.title, C.name as Category, Lang.name as Language
from film as F left join Film_category as FC
on F.film_id = FC.film_id left join  category as C
on FC.category_id = C.category_id left join language as Lang
on F.language_id = Lang.language_id;
 
 -- Q7 How many times each movie has been rented out?
 
 select F.title, count(R.rental_id) as Renting_rate
 from rental as R left join inventory as INV
 on R.inventory_id = INV.inventory_id left join film as F
 on INV.film_id = F.film_id 
 group by F.title
 order by Renting_rate desc;
 
 -- Q8 REVENUE PER FILM (TOP 10 GROSSERS)
 
 select Rental_id_transaction.title as Film_name, sum(P.amount) as Gross_revenue
 from (select R.rental_id, F.film_id, F.title
       from rental as R left join inventory as INV
       on R.inventory_id = INV.inventory_id left join film as F
       on INV.film_id = F.film_id) as Rental_id_transaction left join payment as P
on Rental_id_transaction.rental_id = p.rental_id
group by Rental_id_transaction.title
order by Gross_revenue desc
limit 10;

-- Q9 Most Spending Customer so that we can send him/her rewards or rebate points

select C.customer_id, C.First_name, sum(P.amount) as Revenue
from payment as P left join customer as C
on P.customer_id= C.customer_id
Group by C.customer_id
order by revenue desc
limit 5;

-- Q10 Which Store has historically brought the most revenue?

select S.store_id, sum(P.amount) as Store_revenue
from payment as P left join staff as S
on P.staff_id = S.staff_id
group by S.store_id
order by Store_revenue desc;

-- Q11 Revenue as per time series

select extract( Year from payment_date) as Year,Date_format(payment_date,"%b") as month_name, sum(amount) as Revenue
from payment
group by extract( Year from payment_date),Date_format(payment_date,"%b");

-- Q12 How many rentals we have for each month

select monthname(rental_date) as Month, extract(year from rental_date) as Year, count(rental.rental_id) as Rentals
from rental
group by extract(year from rental_date), monthname(rental_date)
order by Rentals desc;

-- Q13 Reward users who have rented at least 30 times (with details of customers)

select customer_id, count(rental_id) as Rentals
from rental
group by customer_id
having Rentals >= 30
order by customer_id;

SELECT LOYAL_CUSTOMERS.CUSTOMER_ID,C.FIRST_NAME,C.LAST_NAME,C.EMAIL,AD.PHONE
FROM (SELECT CUSTOMER_ID,COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING NUMBER_OF_RENTALS >=30
ORDER BY CUSTOMER_ID) AS LOYAL_CUSTOMERS LEFT JOIN CUSTOMER AS C
		ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID
										LEFT JOIN ADDRESS AS AD
		ON C.ADDRESS_ID = AD.ADDRESS_ID;
        
-- Q14 Could you pull all payments from our first 100 customers (based on customer ID)

select customer_id,rental_id,amount,payment_date
from payment
where customer_id < 101;

-- Q15 Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

select customer_id,rental_id,amount,payment_date
from payment
where customer_id < 101 and amount > 5 and payment_date > '2006-01-01';

-- Q16 Now, could you please write a query to pull all payments from those specific customers, along with payments over $5, from any customer?

select customer_id,rental_id,amount,payment_date
from payment
where customer_id = 42 or customer_id = 53 or customer_id = 60 or customer_id = 75 or amount > 5;

select customer_id,rental_id,amount,payment_date
from payment
where customer_id = 42 or customer_id in (42,53,60,75);

-- Q17 We need to understand the special features in our films. Could you pull a list of films which include a Behind the Scenes special feature?

select title, special_features
from film
where special_features like '%Behind the scenes';

-- Q18 Unique movie ratings and number of movies

select rating, count(film_id) as No_of_Films
from film 
group by rating;

-- Q19 Could you please pull a count of titles sliced by rental duration?

select rental_duration, count(film_id) as No_of_Films
from film 
group by rental_duration;

select rating, rental_duration, count(film_id) as No_of_Films
from film 
group by rating, rental_duration;

-- Q20 RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

select rating,
       count(film_id) as Count_of_film,
       min(length) as Shortest_film,
       max(length) as Longest_film,
       avg(length) as Avg_Film_Length,
       avg(Rental_Duration) as Avg_Rental_Duration
from film
group by rating
order by Avg_Film_length;

-- Q21 I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate, grouped by replacement cost?

select replacement_cost,
	  count(film_id) as No_of_Films,
      min(rental_rate) as Cheapest_rental,
      max(rental_rate) as Expensive_rental,
      avg(rental_rate) as Avg_rental
from film
group by replacement_cost
order by replacement_cost;

-- Q22 “I’d like to talk to customers that have not rented much from us to understand if there is something we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

select customer_id, count(*) as Total_rentals
from rental
group by customer_id
having Total_rentals < 15;

-- Q23 “I’d like to see if our longest films also tend to be our most expensive rentals. Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

select title, length, rental_rate
from film
order by length desc
limit 20;

-- Q24 CATEGORIZE MOVIES AS PER LENGTH

select title, length, 
      case
          when length < 60 then 'Under 1 hour'
          when length between 60 and 90 then '1 to 1.5 hrs'
          when length > 90 then 'Over 1.5 hrs'
          else 'Error'
	  end as length_bucket
from film;

-- Q25 CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

select distinct title,
       case 
           when rental_duration <= 4 then 'Rental too Short'
           when rental_rate >= 3.99 then 'Too Expensive'
           when rating in ( 'NC-17', 'R') then 'Too Adult'
           when length not between 60 and 90 then 'Too Short or Too Long'
           when description like '%Shark%' then 'No_has_Sharks'
           Else 'Great_Recommendation_for_Children'
		end as Fit_for_recommendation
from film;

-- Q26 “I’d like to know which store each customer goes to, and whether or not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”
           
select customer_id, first_name, last_name,
      case 
		  when store_id = 1 and active = 1 then 'Store 1 Active'
          when store_id = 1 and active = 0 then 'Store 1 Inactive'
		  when store_id = 2 and active = 1 then 'Store 2 Active'
          when store_id = 2 and active = 0 then 'Store 2 Inactive'
	      else 'Error'
	  end as Store_Status
from customer;

-- Q27 “Can you pull for me a list of each film we have in inventory? I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

select distinct inventory.inventory_id,
				inventory.store_id,
                film.title,
                film.description
from film inner join inventory on film.film_id = inventory.film_id;

-- Q28 Actor first_name, last_name and number of movies

select 
      actor.actor_id,
      actor.first_name,
      actor.last_name,
      count(Film_Actor.Film_id) as No_of_Films
from actor left join film_actor 
on actor.actor_id = film_actor.actor_id
group by actor.actor_id;

-- Q29 “One of our investors is interested in the films we carry and how many actors are listed for each film title. Can you pull a list of all titles, 
-- and figure out how many actors are associated with each title?”

select film.Title,
      count( film_actor.actor_id) as No_of_Actors
from film
      left join film_actor
		   on film.film_id = film_actor.film_id
group by film.Title;

-- Q30 “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”

select actor.first_name,
       actor.last_name,
       film.title
from actor inner join film_actor
     on actor.actor_id = film_actor.actor_id
		   inner join film 
	 on film_actor.film_id = film.film_id
order by actor.first_name, actor.last_name;

-- Q31 “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

select distinct f.title, f.description
from inventory as INV left join film as F
on INV.film_id = F.film_id
where INV.store_id = 2;

-- Q32 “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

select first_name,
	   last_name, 'Staff Member' as Designation from staff union 
select first_name,
       last_name, 'Advisors' as Designation from advisor;