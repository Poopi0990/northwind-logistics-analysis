-- 1. Średni czas dostawy (ShippedDate - OrderDate) dla krajów
-- Celem jest sprawdzenie, ile średnio dni trwa dostawa zamówienia
-- (Można użyć funkcji julianday do obliczenia różnicy dat)

SELECT O.ShipCity || ',' || o.ShipCountry AS ShipLocation, C.Country AS CustomerCountry,
  ROUND(AVG(julianday(ShippedDate) - julianday(OrderDate)), 2) AS avg_delivery_days
FROM Orders as O
LEFT JOIN CUSTOMERS AS C ON O.CustomerID = C.CustomerID
GROUP BY ShipCity, C.Country
ORDER BY avg_delivery_days DESC;
