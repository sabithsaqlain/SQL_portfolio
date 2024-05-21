-- Exploratory Data Analysis

-- Dataset - https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- In this project we're going to explore the data and find trends or patterns or anything interesting like outliers


-- Maximum layoff till_date

SELECT
	MAX(total_laid_off)
FROM
	layoffs_staging2;


-- Percentage of maximum and minimum layoff

SELECT
	MAX(percentage_laid_off) Max_layoff_percent,  MIN(percentage_laid_off) Min_layoff_percent
FROM
	layoffs_staging2
WHERE
	percentage_laid_off IS NOT NULL;



-- Companies which laid_off 100 percent of their workforce

SELECT *
FROM
	layoffs_staging2
WHERE
	percentage_laid_off = 1;


-- If we order by funds_raised_in_millions we can see how big some of these companies were

SELECT *
FROM 
	layoffs_staging2
WHERE
	percentage_laid_off = 1
ORDER BY 
	funds_raised_in_millions DESC;


-- Companies with the biggest single Layoff

SELECT
	company, total_laid_off
FROM
	layoffs_staging
ORDER BY 2 DESC
LIMIT 5;


-- Companies with the most Total Layoffs

SELECT
	company, SUM(total_laid_off)
FROM 
	layoffs_staging2
GROUP BY 
	company
ORDER BY 2 DESC
LIMIT 10;


-- Total_layoffs by city

SELECT
	Location, SUM(total_laid_off) Total_layoffs
FROM 
	layoffs_staging2
GROUP BY 
	location
ORDER BY 2 DESC
LIMIT 10;


-- Total_layoffs by country

SELECT
	Country, SUM(total_laid_off) Total_layoffs
FROM 
	layoffs_staging2
GROUP BY 
	country
ORDER BY 2 DESC;


-- Total_layoffs by years

SELECT 
	year(date) Years, SUM(total_laid_off) Total_layoffs
FROM
	layoffs_staging2
GROUP BY
	Years
ORDER BY 1 ASC;


-- Total_layoffs by industry

SELECT 
	Industry, SUM(total_laid_off) Total_layoffs
FROM
	layoffs_staging2
GROUP BY
	industry
ORDER BY 2 DESC;


-- Total_layoffs by stage

SELECT 
	Stage, SUM(total_laid_off) Total_layoffs
FROM
	layoffs_staging2
GROUP BY
	stage
ORDER BY 2 DESC;




-- Advanced queries
------------------------------------------------------------------------------------------------------------------------------------

-- Top 3 companies each year ranked by most layoffs

WITH layoff_year AS 
(
  SELECT 
	company, YEAR(date) AS years, SUM(total_laid_off) AS Total_layoffs
  FROM
	layoffs_staging2
  GROUP BY
	company, years
)
, layoff_year_rank AS
 (
  SELECT 
	company, years, Total_layoffs, DENSE_RANK() OVER (PARTITION BY years ORDER BY Total_layoffs DESC) AS ranking
  FROM
	layoff_year
)
SELECT 
	company, years, Total_layoffs, ranking
FROM
	layoff_year_rank
WHERE
	ranking <= 3
AND 
	years IS NOT NULL
ORDER BY
	years ASC, Total_layoffs DESC;



-- Rolling Total of Layoffs Per Month

SELECT
	SUBSTRING(date,1,7) as Months, SUM(total_laid_off) AS Total_layoffs
FROM 
	layoffs_staging2
GROUP BY
	Months
ORDER BY
	Months ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT
	SUBSTRING(date,1,7) as Months, SUM(total_laid_off) AS Total_layoffs
FROM
	layoffs_staging2
GROUP BY
	Months
ORDER BY 
	Months ASC
)
SELECT
	Months,Total_layoffs, SUM(Total_layoffs) OVER (ORDER BY Months ASC) as Rolling_total_layoffs
FROM
	DATE_CTE
ORDER BY
	Months ASC;


