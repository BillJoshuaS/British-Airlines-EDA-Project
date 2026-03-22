-- Cleaning the Customer_Comment table:
USE Airline;

-- Handling the empty values in Loyalty program levels adding placeholders for those spots as guest access:
SELECT COUNT(*) FROM customer_comment_stagedv1 WHERE loyalty_program_level IS NULL OR loyalty_program_level = '';

UPDATE customer_comment_stagedv1 SET loyalty_program_level = 'guest' WHERE loyalty_program_level = '' OR loyalty_program_level IS NULL;

SELECT COUNT(*) FROM customer_comment_stagedv1;
SELECT loyalty_program_level FROM customer_comment_stagedv1;