-- Show patient name AND their doctor's name for each appointment
SELECT p.full_name AS patient_name,
       d.full_name AS doctor_name,
       d.specialization,
       a.appt_date,
       a.status
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id
INNER JOIN doctors d  ON a.doctor_id  = d.doctor_id;

-- Show ALL patients and their appointments
-- Even patients who haven't had any appointment yet
SELECT p.full_name AS patient_name,
       p.diagnosis,
       a.appt_date,
       a.status
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id;

-- Find patients who have NEVER had an appointment
-- These are patients who might need follow-up!
SELECT p.full_name,
       p.diagnosis,
       p.admission_date
FROM patients p
LEFT JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.appt_id IS NULL;

-- Show ALL doctors and their appointments
-- Even doctors who have no appointments scheduled yet
SELECT d.full_name AS doctor_name,
       d.specialization,
       a.appt_date,
       a.status
FROM appointments a
RIGHT JOIN doctors d ON a.doctor_id = d.doctor_id;

-- Complete picture of all patients and all doctors
-- Whether they have appointments or not
SELECT p.full_name AS patient_name,
       d.full_name AS doctor_name,
       a.appt_date
FROM appointments a
FULL OUTER JOIN patients p ON a.patient_id = p.patient_id
FULL OUTER JOIN doctors d  ON a.doctor_id  = d.doctor_id;

-- Complete hospital appointment report:
-- Patient name, age, diagnosis,
-- Doctor name, specialization,
-- Appointment date, status, billing amount
-- Only completed appointments
-- Sorted by billing amount highest first

SELECT p.full_name      AS patient_name,
       p.age,
       p.diagnosis,
       d.full_name      AS doctor_name,
       d.specialization,
       a.appt_date,
       a.status,
       a.billing_amt
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id
INNER JOIN doctors d  ON a.doctor_id  = d.doctor_id
WHERE a.status = 'Completed'
ORDER BY a.billing_amt DESC;
