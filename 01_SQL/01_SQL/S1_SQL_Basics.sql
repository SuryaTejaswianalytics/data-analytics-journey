-- Show all patients
SELECT *
FROM patients;

-- Show only patient names and their diagnosis
SELECT full_name, diagnosis
FROM patients;

-- Show all doctors and their specialization
SELECT full_name, specialization, department
FROM doctors;

-- Find all patients aged above 60
SELECT full_name, age, diagnosis
FROM patients
WHERE age > 60;

-- Find all patients diagnosed with Diabetes
SELECT full_name, age, ward
FROM patients
WHERE diagnosis = 'Diabetes';

-- Find appointments that are still pending
SELECT appt_id, appt_date, status
FROM appointments
WHERE status = 'Pending';

-- Show patients sorted by age, oldest first
SELECT full_name, age, diagnosis
FROM patients
ORDER BY age DESC;

-- Show doctors sorted alphabetically by name
SELECT full_name, specialization
FROM doctors
ORDER BY full_name ASC;

-- Show only the 5 youngest patients
SELECT full_name, age, diagnosis
FROM patients
ORDER BY age ASC
LIMIT 5;

-- Find elderly diabetic patients admitted recently,
-- sorted by age, show top 10
SELECT full_name,
       age,
       diagnosis,
       admission_date,
       ward
FROM patients
WHERE age > 55
  AND diagnosis = 'Diabetes'
ORDER BY age DESC
LIMIT 10;
