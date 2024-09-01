use music;


# ------------------------------------------------------------------ BASIC ------------------------------------------------------------------

#Q1 => Who is the senior most employee based on job title?

select Name , Title , Date_hire from
(select Name , Title , Date_hire , Rank() over(partition by employee.title order by date(Date_hire) ) as ranks from
(select employee.first_name as Name , employee.title as Title , employee.hire_date as Date_hire
from
employee
order by employee.title) as data1 ) as data2
where ranks = 1;


#Q2 => Which countries have the most Invoices?

SELECT 
    invoice.billing_country AS Country,
    COUNT(invoice_id) AS Total_Invoice
FROM
    invoice
GROUP BY Country
ORDER BY Total_Invoice DESC
LIMIT 1;

#Q3 => Write a SQL query to fetch the top 3 customers who have spent the most on invoices.

SELECT 
    customer.first_name AS Name,
    ROUND(SUM(invoice.total), 2) AS Total_Amount
FROM
    invoice
        JOIN
    customer ON invoice.customer_id = customer.customer_id
GROUP BY Name
ORDER BY Total_Amount DESC
LIMIT 3;

#Q4 => Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT 
    invoice.billing_city AS City,
    ROUND(SUM(invoice.total), 2) AS Total_Amount
FROM
    invoice
GROUP BY City
ORDER BY Total_Amount DESC;

# ------------------------------------------------------------------ Intermediate ------------------------------------------------------------------

#Q5 => Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT
    customer.first_name AS FIRST_NAME,
    customer.last_name AS LAST_NAME,
    customer.email AS EMAIL
FROM
    customer
        JOIN
    invoice ON invoice.customer_id = customer.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
ORDER BY EMAIL;

#Q6 => Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT 
    artist.name, COUNT(album2.title) AS Total_Track
FROM
    artist
        JOIN
    album2 ON artist.artist_id = album2.artist_id
        JOIN
    track ON track.album_id = album2.album_id
        JOIN
    genre ON genre.genre_id = track.genre_id
WHERE
    genre.name = 'Rock'
GROUP BY artist.name
ORDER BY Total_Track DESC;

# Q7 => eturn all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

SELECT 
    track.name AS Track_Name,
    track.milliseconds AS length_in_millisecond
FROM
    track
WHERE
    milliseconds >= (SELECT 
            AVG(track.milliseconds) AS avg_len
        FROM
            track)
ORDER BY length_in_millisecond DESC;


# ------------------------------------------------------------------ Advanced ------------------------------------------------------------------

#Q8 => Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

SELECT 
    customer.first_name AS Name,
    artist.name AS Artist,
    round(SUM(invoice_line.unit_price * invoice_line.quantity),2) AS Spent
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    album2 ON album2.album_id = track.album_id
        JOIN
    artist ON artist.artist_id = album2.artist_id
GROUP BY Name , Artist
ORDER BY Name , Spent DESC;

#Q9 => We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres

select Country , Name , Total_Purchases from  
(select Country , Name , Total_Purchases , Rank() over(partition by Country order by Total_Purchases desc) as ranks from
(SELECT 
    customer.country AS Country,
    genre.name AS Name,
    SUM(invoice_line.quantity) AS Total_Purchases
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice_line.invoice_id = invoice.invoice_id
        JOIN
    track ON track.track_id = invoice_line.track_id
        JOIN
    genre ON genre.genre_id = track.genre_id
GROUP BY Country , Name
ORDER BY Country , Total_Purchases DESC) as data1) data2
where 
ranks = 1
order by Total_Purchases desc;

#Q10 => Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

select Country , name , total_Amount from
(select Country , name , total_Amount , rank() over(partition by Country order by total_Amount desc) as ranks from 
(SELECT 
    invoice.billing_country AS Country,
    customer.first_name AS name,
    ROUND(SUM(invoice.total), 2) AS total_Amount
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
GROUP BY invoice.billing_country , name
ORDER BY Country , total_Amount DESC) as data1) as data2
where ranks = 1
order by total_Amount desc;