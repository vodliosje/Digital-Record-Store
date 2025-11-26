--who the best performing employees are
SELECT
	e.FirstName || ' ' || e.LastName AS EmployeeName,
	SUM(i.Total) AS TotalSales
FROM
	Employee e 
JOIN
	Customer c ON e.EmployeeId = c.SupportRepId 
JOIN
	Invoice i ON c.CustomerID = i.CustomerId
WHERE e.Title = "Sales Support Agent"
GROUP BY e.EmployeeId , EmployeeName 
ORDER BY TotalSales DESC;

--which genres sell best in Europe vs. USA.
WITH GenreSales AS (
	SELECT
		c.Country,
		g.Name AS GenreName,
		SUM(il.UnitPrice*il.Quantity) AS TotalRevenue
	FROM
		Customer c
	JOIN Invoice i ON c.CustomerId = i.CustomerId 
	JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
	JOIN Track t ON il.TrackId = t.TrackId
	JOIN Genre g ON t.GenreID = g.GenreId 
	GROUP BY 
		c.Country,
		g.Name
),

RankedGenreSales AS (
	SELECT
		Country,
		GenreName,
		TotalRevenue,
		DENSE_RANK() OVER (PARTITION BY Country ORDER BY TotalRevenue DESC) as GenreRank
	FROM 
		GenreSales 
)

SELECT
	Country,
	GenreName,
	TotalRevenue
FROM
	RankedGenreSales
WHERE
	GenreRank = 1
ORDER BY
	Country ASC;

--Top 5 Selling Artists
SELECT 
	a.Name,
	SUM(il.Quantity) AS TrackSold
FROM
	Artist a
JOIN Album a2 ON a.ArtistId = a2.ArtistId
JOIN Track t ON a2.AlbumId = t.AlbumId 
JOIN InvoiceLine il ON il.TrackId = t.TrackId
GROUP BY 
	a.Name
ORDER BY
	TrackSold DESC
LIMIT 5;

--Identify the lowest-selling genre (by dollar revenue) for customers residing in cities in Germany
SELECT
	c.City,
	g.Name as GenreName,
	SUM(il.UnitPrice *il.Quantity ) AS TotalRevenue
FROM
	Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
JOIN Track t ON t.TrackId = il.TrackId 
JOIN Genre g ON t.GenreId = g.GenreId 
WHERE
	c.Country = "Germany"
GROUP BY
	c.City,
	g.Name
ORDER BY
	TotalRevenue ASC;

--Ranking Customers by Purchase Frequency
WITH CustomerInvoiceCount AS (
	SELECT
		c.CustomerId ,
		c.Country,
		COUNT(i.InvoiceId) AS InvoiceCount
	FROM Customer c
	JOIN Invoice i ON c.CustomerId = i.CustomerId 
	GROUP BY c.CustomerId,
	c.Country 
),
RankedCustomer AS (
	SELECT
		CustomerId,
		Country,
		InvoiceCount,
		DENSE_RANK() OVER (PARTITION BY Country ORDER BY InvoiceCount DESC) as Rank
	FROM 
		CustomerInvoiceCount 
)
SELECT
	c.FirstName || " " || c.LastName AS CustomerName,
	rc.Country,
	rc.InvoiceCount
FROM 
	RankedCustomer rc
JOIN Customer c ON c.CustomerId = rc.CustomerId
WHERE
	rc.Rank = 1
ORDER BY
	rc.Country ASC;

