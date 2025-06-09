-- ShopEase E-Commerce SQL Schema and Sample Data

-- 1. Table Definitions
CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    avg_rating DECIMAL(3,2) DEFAULT 0
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    review_text TEXT NOT NULL,
    review_date DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE
);

-- 2. Sample Data
INSERT INTO Products (name, category, price) VALUES
('Smartphone X200', 'Electronics', 24999.00),
('Noise Cancelling Headphones', 'Electronics', 7999.00),
('Classic Sneakers', 'Fashion', 2999.00),
('Urban Backpack', 'Fashion', 1599.00);

INSERT INTO Customers (name, email) VALUES
('Juan Dela Cruz', 'juan@email.com'),
('Maria Santos', 'maria@email.com'),
('Pedro Reyes', 'pedro@email.com');

INSERT INTO Reviews (product_id, customer_id, review_text, review_date) VALUES
(1, 1, 'Great phone, fast and reliable!', '2025-06-01'),
(1, 2, 'Battery life could be better.', '2025-06-02'),
(2, 1, 'Amazing sound quality!', '2025-06-03'),
(3, 3, 'Very comfortable sneakers.', '2025-06-04');

INSERT INTO Ratings (product_id, customer_id, rating) VALUES
(1, 1, 5),
(1, 2, 3),
(2, 1, 4),
(3, 3, 5);

-- 3. SELECT Queries
-- Average product ratings
SELECT p.name, AVG(r.rating) AS avg_rating
FROM Products p
JOIN Ratings r ON p.product_id = r.product_id
GROUP BY p.product_id;

-- Most reviewed products
SELECT p.name, COUNT(rv.review_id) AS review_count
FROM Products p
JOIN Reviews rv ON p.product_id = rv.product_id
GROUP BY p.product_id
ORDER BY review_count DESC;

-- Customer review history
SELECT c.name, p.name AS product, rv.review_text, rv.review_date
FROM Customers c
JOIN Reviews rv ON c.customer_id = rv.customer_id
JOIN Products p ON rv.product_id = p.product_id
ORDER BY rv.review_date DESC;

-- 4. UPDATE and DELETE
-- Edit a review
UPDATE Reviews SET review_text = 'Updated review text.' WHERE review_id = 1;
-- Remove inappropriate review
DELETE FROM Reviews WHERE review_id = 2;

-- 5. Transactions
START TRANSACTION;
UPDATE Ratings SET rating = 4 WHERE rating_id = 2;
UPDATE Reviews SET review_text = 'Updated for consistency.' WHERE review_id = 2;
COMMIT;

-- 6. JOINs
SELECT p.name, rv.review_text, r.rating
FROM Products p
JOIN Reviews rv ON p.product_id = rv.product_id
JOIN Ratings r ON p.product_id = r.product_id AND rv.customer_id = r.customer_id;

-- 7. GROUP BY and ROLLUP
SELECT category, AVG(rating) AS avg_rating
FROM Products p
JOIN Ratings r ON p.product_id = r.product_id
GROUP BY category WITH ROLLUP;

-- 8. Indexes
CREATE INDEX idx_product_name ON Products(name);
CREATE INDEX idx_customer_id ON Customers(customer_id);

-- 9. Stored Procedures
DELIMITER //
CREATE PROCEDURE AddReview(IN prod_id INT, IN cust_id INT, IN txt TEXT, IN rate INT)
BEGIN
    INSERT INTO Reviews (product_id, customer_id, review_text) VALUES (prod_id, cust_id, txt);
    INSERT INTO Ratings (product_id, customer_id, rating) VALUES (prod_id, cust_id, rate);
    CALL UpdateAvgRating(prod_id);
END;//

CREATE PROCEDURE UpdateAvgRating(IN prod_id INT)
BEGIN
    UPDATE Products
    SET avg_rating = (SELECT AVG(rating) FROM Ratings WHERE product_id = prod_id)
    WHERE product_id = prod_id;
END;//
DELIMITER ;

-- 10. Triggers
DELIMITER //
CREATE TRIGGER trg_update_avg_rating_after_insert
AFTER INSERT ON Ratings
FOR EACH ROW
BEGIN
    CALL UpdateAvgRating(NEW.product_id);
END;//

CREATE TRIGGER trg_update_avg_rating_after_delete
AFTER DELETE ON Ratings
FOR EACH ROW
BEGIN
    CALL UpdateAvgRating(OLD.product_id);
END;//
DELIMITER ;

-- 11. Wildcards and ORDER BY
SELECT * FROM Reviews WHERE review_text LIKE '%great%' ORDER BY review_date DESC;

-- 12. Subqueries
SELECT name FROM Products WHERE product_id IN (
    SELECT product_id FROM Ratings GROUP BY product_id HAVING AVG(rating) > 4
);

-- 13. UNION
SELECT rv.review_text, p.category FROM Reviews rv JOIN Products p ON rv.product_id = p.product_id WHERE p.category = 'Electronics'
UNION
SELECT rv.review_text, p.category FROM Reviews rv JOIN Products p ON rv.product_id = p.product_id WHERE p.category = 'Fashion';

-- 14. AND, OR, NOT
SELECT * FROM Reviews WHERE (review_text LIKE '%good%' OR review_text LIKE '%great%') AND NOT review_text LIKE '%bad%';

-- 15. Self-join: Customers who reviewed the same products
SELECT a.name AS customer1, b.name AS customer2, r1.product_id
FROM Customers a
JOIN Reviews r1 ON a.customer_id = r1.customer_id
JOIN Reviews r2 ON r1.product_id = r2.product_id AND r1.customer_id <> r2.customer_id
JOIN Customers b ON r2.customer_id = b.customer_id
ORDER BY r1.product_id;
