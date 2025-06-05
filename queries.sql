-- Średni czas dostawy (ShippedDate - OrderDate) dla krajów
-- Celem jest sprawdzenie, ile średnio dni trwa dostawa zamówienia uwzględniając kraj klienta i miejsce załadunku tak aby dane były przejrzyste do odczytu. 
-- (Można użyć funkcji julianday do obliczenia różnicy dat)
-- Pomaga zidentyfikować miejsca, gdzie dostawy są najwolniejsze.

SELECT 
  O.ShipCity || ',' || o.ShipCountry AS ShipLocation, 
  C.Country AS CustomerCountry,
  ROUND(AVG(julianday(ShippedDate) - julianday(OrderDate)), 2) AS avg_delivery_days 
FROM Orders as O
LEFT JOIN CUSTOMERS AS C ON O.CustomerID = C.CustomerID
GROUP BY ShipCity, C.Country
ORDER BY avg_delivery_days DESC;

-- Grupuje zamówienia według NUMERU ZAMÓWIENIA i sumuje koszty przewozu towaru.
-- Przypisuje każdemu zamówieniu kategorię na podstawie sumy:
-- 'VIP' (>200), 'Duże' (100–200), 'Małe' (<100).
-- Umożliwia analizę wartości zamówień pod kątem kosztowym.
-- Posegregowane wg. SUMY FRACHTU rosnąco. 

SELECT 
	OrderID AS 'NUMER ZAMÓWIENIE',
	SUM(Freight) AS 'SUMA FRACHTU',
	CASE WHEN SUM(Freight) > 200 THEN 'VIP' 
		   WHEN SUM(Freight) BETWEEN 100 AND 200 THEN 'Duże'
		   WHEN SUM(Freight) < 100 THEN 'Małe' END AS 'KATEGORIA ZAMÓWIENIA'
FROM Invoices
  GROUP BY OrderID
  ORDER BY SUM(Freight) ASC;

-- Zlicza, ile zamówień zostało zrealizowanych przez każdego przewoźnika.
-- Łączy tabelę Orders z Shippers na podstawie ShipVia - czyli indywitalnego numer przewoźnika.
-- Pokazuje, po nazwie który przewoźnik obsługuje najwięcej ładunków.

SELECT 
  S.CompanyName AS Przewoznik,
  COUNT(O.OrderID) AS Liczba_Zamowien
FROM Shippers AS S
JOIN Orders AS O ON S.ShipperID = O.ShipVia
GROUP BY S.CompanyName
ORDER BY Liczba_Zamowien DESC;

-- Oblicza najdłuższ czas dostawy (w dniach) dla każdego zamówienia.
-- Znajduje zamówienie z najdłuższym czasem realizacji.
-- Może wskazywać problemy operacyjne np. opóźnienia, przeładunki, postoje w porcie.

SELECT 'Najdłuższa' AS Typ, OrderID, CustomerID,
       ROUND(julianday(ShippedDate) - julianday(OrderDate), 2) AS DeliveryTime
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY DeliveryTime DESC
LIMIT 1

-- Oblicza najkrótszy czas dostawy (w dniach) dla każego zamówienia.
-- Znajduje zamówienie z najkrótszym czasem realizacji.
-- Może wskazywać super-szybkie realizacje i predyspozycje jeśli jest to możlwie do optymalizacji dostaw z podobną lokalizacją.
  
SELECT 'Najkrótsza' AS Typ, OrderID, CustomerID,
       ROUND(julianday(ShippedDate) - julianday(OrderDate), 2) AS DeliveryTime
FROM Orders
WHERE ShippedDate IS NOT NULL
ORDER BY DeliveryTime ASC
LIMIT 1;

-- Zlicza liczbę zamówień dla każdego klienta.
-- Pokazuje tylko tych, którzy złożyli więcej niż 5 zamówień.
-- Pomaga wyodrębnić lojalnych lub strategicznych klientów.

SELECT 
  C.CompanyName,
  COUNT(O.OrderID) AS All_Customer_Orders
FROM Customers AS C
JOIN Orders AS O ON C.CustomerID = O.CustomerID
GROUP BY C.CompanyName
HAVING COUNT(O.OrderID) > 5;

-- Dla każdego zamówienia łączy dane klienta z fakturą.
-- Tworzy jedną kolumnę z ID klienta i nazwą firmy.
-- Klasyfikuje koszt dostawy jako "Droga dostawa" (>100) lub "Standardowa".
-- Pomaga szybko zidentyfikować kosztowne zamówienia logistyczne.

SELECT 
  I.OrderID,
  I.CustomerID || ',' || C.CompanyName AS 'Nazwa firmy',
  I.Freight,
  CASE WHEN I.FREIGHT > 100 THEN 'Droga dostawa' ELSE 'Standardowa' END AS 'Typ Dostawy' 
FROM invoices AS I
JOIN Customers AS C ON I.CustomerID = C.CustomerID
GROUP BY I.OrderID;
