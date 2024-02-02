1. CREATE VIEW sales_revenue_by_category_qtr AS
SELECT
    c.name AS category,
    SUM(p.amount) AS total_sales_revenue
FROM
    payment p
JOIN
    rental r ON p.rental_id = r.rental_id
JOIN
    inventory i ON r.inventory_id = i.inventory_id
JOIN
    film_category fc ON i.film_id = fc.film_id
JOIN
    category c ON fc.category_id = c.category_id
WHERE
    DATE_TRUNC('quarter', p.payment_date) = DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY
    c.name;

2. CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(target_quarter DATE)
RETURNS TABLE (category text, total_sales_revenue numeric)
AS $$
    SELECT
        c.name AS category,
        SUM(p.amount) AS total_sales_revenue
    FROM
        payment p
    JOIN
        rental r ON p.rental_id = r.rental_id
    JOIN
        inventory i ON r.inventory_id = i.inventory_id
    JOIN
        film_category fc ON i.film_id = fc.film_id
    JOIN
        category c ON fc.category_id = c.category_id
    WHERE
        DATE_TRUNC('quarter', p.payment_date) = DATE_TRUNC('quarter', target_quarter)
    GROUP BY
        c.name;
$$ LANGUAGE sql;

3. CREATE OR REPLACE FUNCTION new_movie(IN new_title TEXT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    new_film_id INT;
    new_language_id INT;
BEGIN
    SELECT language_id INTO new_language_id FROM public.language WHERE name = 'Klingon';

    IF new_language_id IS NULL THEN
        INSERT INTO language (name)
    	VALUES ('Klingon')
		RETURNING language_id INTO new_language_id;
    END IF;

    -- Insert new movie into the film table
    INSERT INTO film (title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), new_language_id)
	RETURNING film_id INTO new_film_id;
	
	RETURN new_film_id;
END;
$$;
