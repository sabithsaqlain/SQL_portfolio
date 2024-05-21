-- SQL Project - Data Cleaning

-- Dataset - https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Data cleaning steps that we'll follow in this project

-- 1. Check and remove duplicates
-- 2. standardize data and fix errors
-- 3. Examine null and blank values  
-- 4. Remove unnecessary columns and rows


-- First We will create a staging table to keep the raw data safe

CREATE TABLE 
	layoffs_staging AS 
SELECT * FROM
	layoffs;


-- 1. Check and Remove Duplicates


SELECT *
FROM (
	SELECT 
		company, location, industry, total_laid_off,percentage_laid_off,date, stage, country, funds_raised_in_millions,
		ROW_NUMBER() OVER (
		PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,date, stage, country, funds_raised_in_millions
		) AS row_num
	FROM 
		layoffs_staging
) duplicates
WHERE 
	row_num > 1;
    
-- Let's cross check if row number 2 is a duplicate row   

SELECT *
FROM 
	layoffs_staging
WHERE
	company = 'Beyond Meat';

-- It is clear from the above result that there is a duplicate row for Beyondmeat company


-- We will create a new table and filter rows where row numbers > 1 , then delete that column

CREATE TABLE 
	layoffs_staging2 AS 
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_in_millions) row_num	
FROM layoffs_staging;


DELETE FROM 
	layoffs_staging2
WHERE 
	row_num >= 2;


-------------------------------------------------------------------------------------------------------------------------


-- 2. Standardize Data


-- Crypto has multiple variations. We need to standardize that

SELECT DISTINCT 
	industry
FROM 
	layoffs_staging2
ORDER BY 
	industry;

UPDATE 
	layoffs_staging2
SET 
	industry = 'Crypto'
WHERE
	industry IN ('Crypto Currency', 'CryptoCurrency');



-- we have some "United States." with a period at the end. Let's standardize this.

SELECT DISTINCT 
	country
FROM 
	layoffs_staging2
ORDER BY 
	country;

UPDATE 
	layoffs_staging2
SET 
	country = TRIM(TRAILING '.' FROM country);


-- Fixing date data type from text to date:

-- We can use str to date to update this field

UPDATE 
layoffs_staging2
SET
date = STR_TO_DATE(date, '%d/%m/%Y');


-- Now we can convert the data type properly

ALTER TABLE layoffs_staging2
MODIFY COLUMN date DATE;

SELECT *
FROM layoffs_staging2;

-------------------------------------------------------------------------------------------------------------------------


-- 3. Examine null and blank value

-- We have some NULL and blank values in industry column

SELECT *
FROM 
	layoffs_staging2
WHERE
	industry IS NULL 
	OR industry = ''
ORDER BY 
	industry;

-- let's take a look at these

SELECT *
FROM 
	layoffs_staging2
WHERE
	company LIKE 'airbnb%';

-- Here airbnb belongs to travel industry, we can populate it by writing the following query

-- Setting blanks to null for consistency
UPDATE 
	layoffs_staging2
SET 
	industry = NULL
WHERE 
	industry = '';

-- Populating null values 
UPDATE 
	layoffs_staging2 t1
JOIN 
	layoffs_staging2 t2 ON 
	t1.company = t2.company
SET 
	t1.industry = t2.industry
WHERE 
	t1.industry IS NULL  AND 
	t2.industry IS NOT NULL;


SELECT *
FROM 
	layoffs_staging2
WHERE
	industry IS NULL 
ORDER BY
	industry;
    
    
-------------------------------------------------------------------------------------------------------------------------


-- 4. Remove unnecessary columns and rows

SELECT *
FROM 
	layoffs_staging2
WHERE
	total_laid_off IS NULL
AND 
	percentage_laid_off IS NULL;


DELETE FROM 
	layoffs_staging2
WHERE
	total_laid_off IS NULL
AND 
	percentage_laid_off IS NULL;


ALTER TABLE
	layoffs_staging2
DROP COLUMN 
	row_num;


SELECT * 
FROM 
	layoffs_staging2;
    
    