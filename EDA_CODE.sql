 
 -- EXPLORATORY DATA ANALYSIS
 
 SELECT *
 FROM layoffs_staging2;


-- 1. MAX TOTAL LAID OFF AND MAX PERCENTAGE
 
SELECT MAX(TOTAL_LAID_OFF), MAX(PERCENTAGE_LAID_OFF)
FROM practice_staging2;

-- 2. COMPANIES WITH 100% LAID_OFFS
SELECT *
FROM practice_staging2
WHERE percentage_laid_off=1
ORDER BY funds_raised_millions DESC;  

-- 3. TOTAL LAYOFFS BY COMPANY

SELECT 
COMPANY, SUM(TOTAL_LAID_OFF) AS TOTAL_LAYOFFS
FROM practice_staging2
GROUP BY COMPANY
ORDER BY TOTAL_LAYOFFS DESC; 

-- 4. TOTAL LAYOFFS BY INDUSTRY 
SELECT industry,
SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;  


-- 5. Total layoffs by country
SELECT country,
SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

select min(`date`), max(`date`)
from practice_staging2;


-- 6. Total layoff by stage 
SELECT stage,
SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- 7.  Total layoffs by Year
SELECT YEAR(date) AS year,
SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
WHERE date IS NOT NULL
GROUP BY YEAR(date)
ORDER BY year;

-- 8. Layoffs by month
SELECT DATE_FORMAT(date,'%Y-%m') AS month_,
       SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
GROUP BY month_
ORDER BY month_;

-- 9. layoffs by date

SELECT `date` AS date,
SUM(total_laid_off) AS total_layoffs
FROM practice_staging2
GROUP BY `date`
ORDER BY 1 desc;


-- 	10. Rolling total layoffs

WITH monthly_total AS
(
    SELECT DATE_FORMAT(date,'%Y-%m') AS month_,
           SUM(total_laid_off) AS total_layoffs
    FROM practice_staging2
    GROUP BY month_
)
SELECT month_,
       total_layoffs,
       SUM(total_layoffs) OVER(ORDER BY month_) AS rolling_total
FROM monthly_total;


-- 11 Top companies by year
WITH company_year AS
(
    SELECT company,
           YEAR(date) AS year_,
           SUM(total_laid_off) AS total_layoffs
    FROM practice_staging2
    GROUP BY company, YEAR(date)
),
company_rank AS
(
    SELECT *,
           DENSE_RANK() OVER(
               PARTITION BY year_
               ORDER BY total_layoffs DESC
           ) AS ranking
    FROM company_year
)
SELECT *
FROM company_rank
WHERE ranking <= 5; 
