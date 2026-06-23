-- CLEANING DATA

-- REMOVING DUPLICATES
-- STANDARDIZING THE DATA
-- NULL OR BLANK VALUES
-- REMOVING ANY ROW/ COLUMN     


-- CREATING COPY OF ORIGINAL DATA SO THAT IN CASE OF ERROR/PROBLEM, OUR REAL DATA SET WILL NOT LOST

CREATE TABLE Practice_staging
LIKE layoffs_staging; 

-- checking if our table is created or not
select * 
from practice_staging;

INSERT INTO practice_staging
SELECT * 
FROM layoffs_staging;


-- CREATING NEW COLUMN OF ROW_NUMBER TO CHECK DUPLICATES

WITH CTE AS 
(
SELECT *,row_number() over 
(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from practice_staging
)
SELECT * 
FROM CTE
WHERE row_num>1;

-- CREATE NEW TABLE THAT IS USED FOR ACTUAL WORK
CREATE TABLE `practice_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO practice_staging2
SELECT *,row_number() over 
(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from practice_staging;

-- DELETING THE DUPLICATE  ONES
delete
FROM practice_staging2
WHERE row_num>1;

-- CONFIRMING IF DUPLICATE EXISTS 
SELECT * 
FROM practice_staging2
WHERE ROW_NUM>1;


-- STEP 1 COMPLETED

					-- STEP-2  STANDARDIZING THE DATA
        
SELECT * 
FROM practice_staging2;
        
SELECT DISTINCT(COMPANY)
FROM practice_staging2
order by 1;

update practice_staging2
SET COMPANY=TRIM(COMPANY);

SELECT DISTINCT(LOCATION)
FROM practice_staging2;

update practice_staging2
SET LOCATION=TRIM(LOCATION);

SELECT DISTINCT(INDUSTRy)
FROM practice_staging2;

SELECT *
FROM practice_staging2
WHERE INDUSTRY LIKE 'Crypto%';

UPDATE practice_staging2
SET INDUSTRY = 'Crypto'
where INDUSTRY LIKE 'CRYPTO%';


update practice_staging2
SET INDUSTRY=TRIM(INDUSTRY);

SELECT DISTINCT(COUNTRY)
FROM practice_staging2
ORDER BY 1;

-- HERE WE HAVE DUPLICATE  WITH DIFFERENCE OF .  , SO

UPDATE practice_staging2
SET Country = 'United States'
where country like 'United State%';

update practice_staging2
SET COMPANY=TRIM(COMPANY);


select `date`
from practice_staging2;

Update practice_staging2
SET `date` = str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE practice_staging2
MODIFY COLUMN `date` DATE;

select * from practice_staging2;

-- STEP-2 COMPLETED 

-- STEP-3  DELAING WITH NULL AND BLANK VALUES

SELECT DISTINCT INDUSTRY
FROM practice_staging2
ORDER BY 1;
 
UPDATE practice_staging2
SET INDUSTRY=NULL
WHERE INDUSTRY = '';
 
 --   WHERE BOTH TOTAL_LAID_OFF AND PERCENTAGE_LAID_OFF ARE NULL THAT DATA ISN'T NECESSARY FOR US 
 SELECT *
 FROM practice_staging2
 WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
 
DELETE 
FROM practice_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- NOW WE CHECK WHERE INDUSTRY IS NULL/BLANK
SELECT *
FROM practice_staging2
WHERE INDUSTRY IS NULL
OR INDUSTRY = '' ;

-- CHECKING FROM OTHER DATA OF COMPANY AND LOCATION 
SELECT T1.industry,T2.industry
FROM practice_staging2 AS T1
JOIN PRACTICE_staging2 AS T2
	ON T1.COMPANY = T2.company
WHERE ( T1.INDUSTRY IS NULL OR T1.INDUSTRY = '' ) AND T2.INDUSTRY IS NOT NULL;
;

-- NOW PUTTING DATA FROM OTHER ROWS AS THER ARE NOT NULL AND ALSO THEY HAVE SAME SPECS

UPDATE practice_staging2 AS T1
JOIN PRACTICE_staging2 AS T2
	ON T1.COMPANY = T2.company
    SET T1.INDUSTRY=T2.INDUSTRY
WHERE ( T1.INDUSTRY IS NULL OR T1.INDUSTRY = '' ) AND T2.INDUSTRY IS NOT NULL;
;

--  CHECKING IF MORE NULL/BLANKS EXISTS
select COUNT(*)
FROM practice_staging2;

-- AS EVERYTHING WORKS PERFECTLY FINE SO,

ALTER table practice_staging2
DROP COLUMN row_num;
 
 

