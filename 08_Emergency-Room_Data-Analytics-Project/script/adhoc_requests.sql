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


--8. During which days and hours do patients experience the longest wait times?

---

### 😊 Patient Satisfaction & Outcomes

9. **Average Patient Satisfaction Score:**
   - *"What is the average satisfaction score reported by ER patients?"*

10. **Satisfaction Scores by Demographics:**
    - *"How do patient satisfaction scores vary by age, gender, and race?"*

11. **Admission vs. Discharge Rates:**
    - *"What percentage of ER visits result in hospital admission versus discharge?"*

12. **Average Length of Stay for Admitted Patients:**
    - *"What is the average duration of hospital stay for patients admitted through the ER?"*

---

### 📊 Demographics & Patient Profiles

13. **Patient Demographics Overview:**
    - *"What is the demographic breakdown (age, gender, race) of ER patients?"*

14. **Common Diagnoses by Demographic Group:**
    - *"What are the most frequent diagnoses among different demographic groups?"*

15. **Insurance Coverage Distribution:**
    - *"What types of insurance coverage do ER patients have?"*

---

### 🏢 Departmental & Referral Analysis

16. **Top Referring Departments:**
    - *"Which hospital departments refer the most patients to the ER?"*

17. **Referral Patterns Over Time:**
    - *"How have referral patterns to the ER changed over the past year?"*

18. **Admission Rates by Referring Department:**
    - *"What are the admission rates for patients referred from each department?"*

---

### 🛠️ Operational Metrics

19. **ER Occupancy Rates:**
    - *"What is the average occupancy rate of the ER during different times of the day?"*

20. **Resource Utilization Rates:**
    - *"How are ER resources (e.g., beds, staff) utilized during peak and off-peak hours?"*

21. **Time to Triage Completion:**
    - *"What is the average time taken to complete triage for incoming patients?"*

---

These questions can be translated into SQL queries to analyze your ER data effectively. For instance, to determine the average wait time:

```sql
SELECT AVG(TIMESTAMPDIFF(MINUTE, arrival_time, first_seen_time)) AS average_wait_time
FROM er_visits
WHERE arrival_time BETWEEN '2025-01-01' AND '2025-01-31';
```

To identify peak hours:

```sql
SELECT HOUR(arrival_time) AS hour, COUNT(*) AS visit_count
FROM er_visits
GROUP BY HOUR(arrival_time)
ORDER BY visit_count DESC;
```

By systematically addressing these questions, you can gain comprehensive insights into ER operations, patient experiences, and areas for improvement.

If you need assistance crafting specific SQL queries based on your database schema, feel free to provide more details, and I'd be glad to help! 