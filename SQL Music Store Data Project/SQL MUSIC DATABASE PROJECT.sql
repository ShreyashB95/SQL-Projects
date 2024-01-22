EASY QUESTIONS

Q1: Who is the senior most employee based on job title?

SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC
LIMIT 1

Q2: Which countries have the most Invoices?

SELECT COUNT(*) AS COUNT, BILLING_COUNTRY
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY COUNT DESC

Q3: What are top 3 values of total invoice?

SELECT TOTAL FROM INVOICE
ORDER BY TOTAL DESC
LIMIT 3

Q4: Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals

SELECT SUM(TOTAL) AS INVOICE_TOTAL, BILLING_CITY
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY INVOICE_TOTAL DESC

Q5:Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money

SELECT CUSTOMER.CUSTOMER_ID, CUSTOMER.FIRST_NAME, CUSTOMER.LAST_NAME, SUM(INVOICE.TOTAL) AS TOTAL
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY CUSTOMER.CUSTOMER_ID
ORDER BY TOTAL DESC
LIMIT 1


MODERATE QUESTIONS

Q1: Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT EMAIL,FIRST_NAME, LAST_NAME
FROM CUSTOMER
JOIN INVOICE ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
WHERE TRACK_ID IN(
	SELECT TRACK_ID FROM TRACK
	JOIN GENRE ON TRACK.GENRE_ID = GENRE.GENRE_ID
	WHERE GENRE.NAME LIKE 'Rock'
	)
ORDER BY EMAIL;

Q2: Lets invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands 

SELECT ARTIST.ARTIST_ID, ARTIST.NAME, COUNT(ARTIST.ARTIST_ID) AS NUMBER_OF_SONGS
FROM TRACK
JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME LIKE 'Rock'
GROUP BY ARTIST.ARTIST_ID
ORDER BY NUMBER_OF_SONGS DESC
LIMIT 10;

Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first

SELECT NAME, MILLISECONDS
FROM TRACK
WHERE MILLISECONDS > (
  SELECT AVG(MILLISECONDS) AS AVG_TRACK_LENGTH
  FROM TRACK)
ORDER BY MILLISECONDS DESC; 


ADVANCED QUESTIONS 

Q1: Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent 

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

Q2: We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1
-- 
Q3: Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how 
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount 

WITH CUSTOMTER_WITH_COUNTRY AS (
		SELECT CUSTOMER.CUSTOMER_ID,FIRST_NAME,LAST_NAME,BILLING_COUNTRY,SUM(TOTAL) AS TOTAL_SPENDING,
		ROW_NUMBER() OVER(PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL) DESC) AS ROWNO 
		FROM INVOICE
		JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM CUSTOMTER_WITH_COUNTRY WHERE ROWNO <= 1

