-- Creating a database
CREATE DATABASE project;

USE project;
-- Uploaded table using csv option
SELECT * FROM hr LIMIT 5;
-- Chnage column name
ALTER TABLE hr
	CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;
-- Checking data types
DESCRIBE hr;
-- For updating
SET sql_safe_updates = 0;
-- Cleaing birthdate 
UPDATE hr
	SET birthdate =  CASE
		WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
        END;
-- Changing datatype
ALTER TABLE hr
	MODIFY column birthdate DATE;
   -- Cleaning hiredate 
UPDATE hr
	SET hire_date =  CASE
		WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
        END;
-- Changing datatype
ALTER TABLE hr
	MODIFY column hire_date DATE;
-- Cleaning termdate
UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true;

SELECT termdate from hr;
-- Using this for allowing few exceptions of date such as 0000-00-00
SET sql_mode = 'ALLOW_INVALID_DATES';
-- Changing datatype
ALTER TABLE hr
MODIFY COLUMN termdate DATE;


-- Adding age column

ALTER TABLE hr ADD COLUMN age INT;

UPDATE hr
	SET age = timestampdiff(YEAR, birthdate, CURDATE());
SELECT birthdate, age FROM hr;

-- Observing ages

SELECT MIN(age) as youngest, MAX(age) as oldest FROM hr;

SELECT COUNT(*) FROM hr 
	WHERE age <18;
    
-- QUESTIONS / ANALYSIS:

-- 1. What is the gender breakdown of the employees in the company?

SELECT gender, COUNT(gender) FROM hr
	WHERE age >= 18 AND termdate = 0000-00-00
	GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of the employees in the company?

SELECT race, COUNT(race) FROM hr
	WHERE age >= 18 AND termdate = 0000-00-00
	GROUP BY race
    ORDER BY COUNT(race) DESC;
    

-- 3. What is the age distribution of the employees in the company?

SELECT min(age) as youngest, max(age) as oldest
	FROM hr
		WHERE age >= 18 AND termdate = 0000-00-00;

SELECT CASE
	WHEN age >= 18 AND age<=24 THEN '18-24'
    WHEN age >= 25 AND age<=35 THEN '25-35'
	WHEN age >= 36 AND age<=44 THEN '36-44'
    WHEN age >= 45 AND age<=50 THEN '45-50'
    WHEN age >= 51 AND age<=60 THEN '51-60'
    ELSE '65+'
    END as age_group, COUNT(*) as count
    FROM hr
    WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY age_group
    ORDER BY count DESC;
    
SELECT CASE
	WHEN age >= 18 AND age<=24 THEN '18-24'
    WHEN age >= 25 AND age<=35 THEN '25-35'
	WHEN age >= 36 AND age<=44 THEN '36-44'
    WHEN age >= 45 AND age<=50 THEN '45-50'
    WHEN age >= 51 AND age<=60 THEN '51-60'
    ELSE '65+'
    END as age_group, gender, Count(gender) as count
    FROM hr
    WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY age_group, gender
    ORDER BY age_group,gender;
    
-- 4. How many employees work at HQ vs Remote?

SELECT location, Count(location) as count
	FROM hr
    WHERE age >= 18 AND termdate = 0000-00-00
	GROUP BY location
    ORDER BY location;
    
SELECT location, gender,Count(location) as count
	FROM hr
    WHERE age >= 18 AND termdate = 0000-00-00
	GROUP BY location, gender
    ORDER BY location, gender;
    
-- 5. Average length of employment of employees who have terminated.

SELECT round(avg(datediff(termdate, hire_date))/365,0) as avg_length_of_emp
	FROM hr
    WHERE age >= 18 AND termdate != 0000-00-00 AND termdate < curdate();
    
-- 6. Gender distribution across dept and job titles.

SELECT department,gender, Count(gender)
	FROM hr
	WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY department ,gender
    ORDER BY department ,gender;

-- 7. Job title distrbution by gender
SELECT jobtitle ,gender, Count(gender)
	FROM hr
	WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY jobtitle ,gender
    ORDER BY jobtitle ,gender;

SELECT jobtitle , Count(jobtitle)
	FROM hr
	WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY jobtitle 
    ORDER BY Count(jobtitle) DESC ;
    
-- 8. Which dept has highest turnover rate?

SELECT department, total_count,terminated_count, terminated_count/total_count as termination_rate
	FROM (
		SELECT department,
			Count(*) as total_count,
            SUM(CASE WHEN termdate<> 0000-00-00 AND termdate <=curdate() THEN 1 ELSE 0 END) as terminated_count
            FROM hr
            group by department
			) AS subquery
	ORDER BY termination_rate DESC;
    
-- 9. Distribution of Employees across Cities and states

SELECT location_state ,  COUNT(location_state) as count_state
	FROM hr
    WHERE age >= 18 AND termdate = 0000-00-00
    GROUP BY location_state
    ORDER BY count_state DESC;
    
-- 10. How has the company's employee count changed over time based hire and term dates?

SELECT year, hires, terminations, 
	hires - terminations as net_change,
    ROUND(((hires - terminations)/hires)*100,2) as net_change_percentage
    FROM (
    SELECT YEAR(hire_date) as year,
    COUNT(*) as hires,
    SUM(CASE WHEN termdate <> 0000-00-00 AND termdate <= curdate() THEN 1 ELSE 0 END) as terminations
    FROM hr
    WHERE age>=18
    GROUP BY year 
    ) as subquery
ORDER BY year;

-- 10. What is the tenure distribution for each dept?

SELECT department, ROUND(avg(datediff(termdate, hire_date)/365),0) as tenure
FROM hr
WHERE termdate<=curdate() AND termdate<>0000-00-00 AND age<=18
GROUP BY department
ORDER BY tenure DESC;