-- How many patients do we have total?
SELECT COUNT(*) AS total_patients
FROM patients;

-- What is the total billing amount across all appointments?
SELECT SUM(billing_amt) AS total_revenue
FROM appointments;

-- What is the average age of all patients?
SELECT AVG(age) AS average_age
FROM patients;

-- Who is the oldest patient?
SELECT MAX(age) AS oldest_patient_age
FROM patients;

-- Who is the youngest patient?
SELECT MIN(age) AS youngest_patient_age
FROM patients;

-- How many patients are in each ward?
SELECT ward,
       COUNT(*) AS patient_count
FROM patients
GROUP BY ward;

-- How many patients have each diagnosis?
SELECT diagnosis,
       COUNT(*) AS patient_count
FROM patients
GROUP BY diagnosis;

-- Average age of patients per diagnosis
SELECT diagnosis,
       AVG(age) AS avg_age,
       COUNT(*) AS total_patients
FROM patients
GROUP BY diagnosis;

-- Total billing amount per doctor
SELECT doctor_id,
       SUM(billing_amt) AS total_billed,
       COUNT(*) AS total_appointments
FROM appointments
GROUP BY doctor_id;

-- Appointment status breakdown
SELECT status,
       COUNT(*) AS count
FROM appointments
GROUP BY status;

-- WHERE filters individual patients BEFORE counting
-- HAVING filters the GROUP RESULTS after counting

-- Find wards with MORE than 20 patients
SELECT ward,
       COUNT(*) AS patient_count
FROM patients
GROUP BY ward
HAVING COUNT(*) > 20;

-- Find diagnoses that affect more than 15 patients
SELECT diagnosis,
       COUNT(*) AS patient_count
FROM patients
GROUP BY diagnosis
HAVING COUNT(*) > 15;

-- Find doctors with total billing above 50000
SELECT doctor_id,
       SUM(billing_amt) AS total_billed
FROM appointments
GROUP BY doctor_id
HAVING SUM(billing_amt) > 50000;

-- Find diagnoses where average patient age is above 50
SELECT diagnosis,
       AVG(age) AS avg_age
FROM patients
GROUP BY diagnosis
HAVING AVG(age) > 50;

-- Hospital management report:
-- Which diagnoses have more than 10 patients,
-- what is their average age,
-- and how many patients have each diagnosis?
-- Show only adult patients (age > 18)
-- Sort by most common diagnosis first

SELECT diagnosis,
       COUNT(*) AS total_patients,
       AVG(age) AS average_age,
       MAX(age) AS oldest,
       MIN(age) AS youngest
FROM patients
WHERE age > 18
GROUP BY diagnosis
HAVING COUNT(*) > 10
ORDER BY total_patients DESC;
