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
	