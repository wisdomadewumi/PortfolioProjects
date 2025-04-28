/*

Emergency Room Dataset provided by Real World Fake Data
Data spans from April 2023 to October 2024

*/

USE PortfolioProject;


SELECT *
FROM dbo.hospital_er_dataset
;


/*
==========================
 🏥 Patient Flow & Volume
==========================
*/

-- 1. How many patients visited the ER?
SELECT
	COUNT(DISTINCT patient_id) AS no_of_patients
FROM dbo.hospital_er_dataset
; -- 9216 patients visited the ER between April 2023 and October 2024


-- 2. What is the monthly breakdown of ER visits over the past year?
SELECT
	DATETRUNC(MONTH, date) AS month_digit,
	DATENAME(MONTH, date) AS month_name,
	DATENAME(YEAR, date) AS year_digit,
	COUNT(DISTINCT patient_id) AS no_of_patients
FROM dbo.hospital_er_dataset
GROUP BY DATETRUNC(MONTH, date), DATENAME(MONTH, date), DATENAME(YEAR, date)
ORDER BY year_digit, month_digit
; -- August 2024 had the highest number of patients (530) while February 2024 had the lowest influx of patients (431)


--3. What is the overall number of patients present in the ER each hour?
SELECT
	DATEPART(HOUR, date) AS hour_digit,
	COUNT(DISTINCT patient_id) AS no_of_patients
FROM dbo.hospital_er_dataset
GROUP BY DATEPART(HOUR, date)
ORDER BY hour_digit
;


--4. What is the overall number of patients present in the ER daily?
SELECT
	DATEPART(WEEKDAY, date) AS day_of_week_digit,
	DATENAME(WEEKDAY, date) AS day_of_week,
	COUNT(DISTINCT patient_id) AS no_of_patients
FROM dbo.hospital_er_dataset
GROUP BY DATEPART(WEEKDAY, date), DATENAME(WEEKDAY, date)
ORDER BY day_of_week_digit
; --Day of the week with the most patients is Saturday, then Thursday and Sunday


/*
==========================
⏱️ Wait Times & Service Efficiency
==========================
*/

--5. What is the average time patients wait before being seen by a healthcare provider?
SELECT
	AVG(CAST(patient_waittime AS FLOAT)) AS avg_wait_time
FROM dbo.hospital_er_dataset
; -- Average wait time is 35.26 minutes


--6. What percentage of ER patients are attended to within 30 minutes of arrival?
WITH optimal_wait_time AS (
	SELECT
		SUM(CASE
			WHEN patient_waittime <= 30 THEN 1
			ELSE 0
		END) AS within_30_minutes,
		COUNT(patient_id) AS no_of_patients
	FROM dbo.hospital_er_dataset
)

SELECT
	100 * (within_30_minutes / CAST(no_of_patients AS FLOAT)) AS percentage_optimal_wait_time
FROM optimal_wait_time
; -- 40.68% of ER patients are attended to within 30 minutes of arrival


-- 7. How do average wait times vary across different age groups?
WITH age_group_cte AS (
	SELECT
		CASE
			WHEN patient_age <= 18 THEN '0—18'
			WHEN patient_age >= 19 AND patient_age <= 34 THEN '19—34'
			WHEN patient_age >= 35 AND patient_age <= 50 THEN '35—50'
			WHEN patient_age >= 51 AND patient_age <= 65 THEN '51—65'
			ELSE 'Above 66'
		END AS age_group,
		patient_waittime
	FROM hospital_er_dataset
)
SELECT
	age_group,
	AVG(CAST(patient_waittime AS FLOAT)) AS avg_wait_time
FROM age_group_cte
GROUP BY age_group
ORDER BY avg_wait_time
; -- Patients within 51-65 age range and above 66 have the least wait time on average.


--8. During which hours do patients experience the longest wait times?
SELECT
	DATEPART(HOUR, date) AS hour_digit,
	AVG(CAST(patient_waittime AS FLOAT)) AS avg_wait_time
FROM dbo.hospital_er_dataset
GROUP BY DATEPART(HOUR, date)
ORDER BY avg_wait_time DESC
; --3am, 10pm and 11am are the top 3 busiest hours


--9. During which days do patients experience the longest wait times?
SELECT
	DATEPART(WEEKDAY, date) AS day_of_week_digit,
	DATENAME(WEEKDAY, date) AS day_of_week,
	AVG(CAST(patient_waittime AS FLOAT)) AS avg_wait_time
FROM dbo.hospital_er_dataset
GROUP BY DATEPART(WEEKDAY, date), DATENAME(WEEKDAY, date)
ORDER BY avg_wait_time DESC
; -- While Monday, Saturday and Sunday are the top 3 busiest days


/*
====================================
😊 Patient Satisfaction & Outcomes
====================================
*/

--10. What is the average satisfaction score reported by ER patients?
SELECT
	AVG(CAST(patient_sat_score AS FLOAT)) AS avg_satisfaction_score,
	COUNT(patient_sat_score) AS patients_who_reviewed,
	COUNT(*) AS total_patients
FROM dbo.hospital_er_dataset
; -- The average satisfaction score is 4.99 stars from the 2517 patients who left a rating


--11. How do patient satisfaction scores vary by age, gender, and race?
	/*
	======
	Age
	======
	*/
WITH age_group_cte AS (
	SELECT
		CASE
			WHEN patient_age <= 18 THEN '0—18'
			WHEN patient_age >= 19 AND patient_age <= 34 THEN '19—34'
			WHEN patient_age >= 35 AND patient_age <= 50 THEN '35—50'
			WHEN patient_age >= 51 AND patient_age <= 65 THEN '51—65'
			ELSE 'Above 66'
		END AS age_group,
		patient_sat_score
	FROM hospital_er_dataset
)
SELECT
	age_group,
	AVG(CAST(patient_sat_score AS FLOAT)) AS avg_satisfaction_score,
	COUNT(patient_sat_score) AS patients_who_reviewed
FROM age_group_cte
GROUP BY age_group
ORDER BY avg_satisfaction_score DESC
; -- Middle-aged patients tend to give higher satisfaction ratings than other groups even though the overall rating is just below average

	/*
	======
	Gender
	======
	*/
SELECT
	patient_gender,
	ROUND(AVG(CAST(patient_sat_score AS FLOAT)), 2) AS avg_satisfaction_score
FROM hospital_er_dataset
GROUP BY patient_gender
; -- Male patients seem to give higher ratings on average

	/*
	======
	Race
	======
	*/
SELECT
	patient_race,
	ROUND(AVG(CAST(patient_sat_score AS FLOAT)), 2) AS avg_satisfaction_score,
	COUNT(patient_sat_score) AS total_patients_who_reviewed,
	ROUND(100 * (COUNT(patient_sat_score) / CAST(COUNT(*) AS FLOAT)), 2) AS percentage_who_reviewed
FROM hospital_er_dataset
GROUP BY patient_race
ORDER BY avg_satisfaction_score DESC
; --Pacific Islanders tend to give higher ratings but have 5 times less reviewers than the race with the highest review


-- 12. What percentage of ER visits result in hospital admission versus discharge?
SELECT
	ROUND(100 * (total_admissions / total_patients), 2)
FROM(
	SELECT
		SUM(CASE
				WHEN patient_admin_flag = 'TRUE' THEN 1
				ELSE 0
			END) AS total_admissions,
		CAST(COUNT(*) AS FLOAT) AS total_patients
	FROM dbo.hospital_er_dataset
) admin_subquery
; -- About half of all patients are admitted to the hospital


/*
==========================
📊 Demographics & Patient Profiles
==========================
*/

-- 13. What is the demographic breakdown (age, gender, race) of ER patients?
	/*
	======
	Age
	======
	*/
WITH age_group_cte AS (
	SELECT
		CASE
			WHEN patient_age <= 18 THEN '0—18'
			WHEN patient_age >= 19 AND patient_age <= 34 THEN '19—34'
			WHEN patient_age >= 35 AND patient_age <= 50 THEN '35—50'
			WHEN patient_age >= 51 AND patient_age <= 65 THEN '51—65'
			ELSE 'Above 66'
		END AS age_group,
		patient_id
	FROM hospital_er_dataset
)
SELECT
	age_group,
	COUNT(patient_id) AS total_patients,
	ROUND(100 * COUNT(patient_id) / SUM(CAST(COUNT(patient_id) AS FLOAT)) OVER (), 2) AS percentage_total_patients
FROM age_group_cte
GROUP BY age_group
ORDER BY total_patients DESC
; -- Patients under the age of 18 visit the ER the most (22.89%).

	/*
	======
	Gender
	======
	*/
SELECT
	patient_gender,
	COUNT(patient_id) AS total_patients,
	ROUND(100 * COUNT(patient_id) / SUM(CAST(COUNT(patient_id) AS FLOAT)) OVER (), 2) AS percentage_total_patients
FROM hospital_er_dataset
GROUP BY patient_gender
ORDER BY total_patients DESC
; -- Male patients have the most (51.05%) visits to the ER

	/*
	======
	Race
	======
	*/
SELECT
	patient_race,
	COUNT(patient_id) AS total_patients,
	ROUND(100 * COUNT(patient_id) / SUM(CAST(COUNT(patient_id) AS FLOAT)) OVER (), 2) AS percentage_total_patients
FROM hospital_er_dataset
GROUP BY patient_race
ORDER BY total_patients DESC
; -- White patients (27.90%) visit the ER the most followed by African American patients (21.17%)


/*
==========================
🏢 Departmental & Referral Analysis
==========================
*/

-- 14. Which hospital departments refer the most patients to the ER?
SELECT
	department_referral,
	COUNT(patient_id) AS total_patients,
	ROUND(100 * COUNT(patient_id) / SUM(CAST(COUNT(patient_id) AS FLOAT)) OVER (), 2) AS percentage_total_patients
FROM dbo.hospital_er_dataset
WHERE department_referral != 'None' -- To filter out patients who were NOT referred
GROUP BY department_referral
ORDER BY total_patients DESC
; -- General Practice refers almost half (48.22%) of all patients to the ER















-- 15. How have referral patterns to the ER changed over the past year?
WITH referral AS (
	SELECT
		department_referral,
		YEAR(date) AS year,
		COUNT(patient_id) AS total_patients_cy,
		LAG(COUNT(patient_id)) OVER (PARTITION BY department_referral ORDER BY YEAR(date)) AS total_patients_py
	FROM dbo.hospital_er_dataset
	WHERE department_referral != 'None'
	GROUP BY department_referral, YEAR(date)
)
SELECT
	department_referral,
	year,
	total_patients_cy,
	total_patients_py,
	ROUND(100 * ((total_patients_cy - total_patients_py) / CAST(total_patients_py AS FLOAT)), 2) AS percent_change
FROM referral
WHERE year != 2023
;


18. **Admission Rates by Referring Department:**
    - *"What are the admission rates for patients referred from each department?"*
