-- PART 1 — Subqueries

-- Type 1 — Subquery in WHERE clause
-- Find all patients whose billing is above hospital average
SELECT p.full_name,
       p.diagnosis,
       a.billing_amt
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id
WHERE a.billing_amt > (
    SELECT AVG(billing_amt)
    FROM appointments
);

-- Type 2 — Subquery in SELECT clause
-- Show each patient's billing vs hospital average
SELECT p.full_name,
       a.billing_amt,
       (SELECT AVG(billing_amt) FROM appointments) AS hospital_avg,
       a.billing_amt - (SELECT AVG(billing_amt) FROM appointments) AS difference
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id;


-- Type 3 — Subquery in FROM clause
-- Use a subquery as a temporary table
SELECT department_summary.department,
       department_summary.total_billing
FROM (
    SELECT d.department,
           SUM(a.billing_amt) AS total_billing
    FROM doctors d
    INNER JOIN appointments a ON d.doctor_id = a.doctor_id
    GROUP BY d.department
) AS department_summary
WHERE department_summary.total_billing > 500000;

-- PART 2 — CTEs (Common Table Expressions)

-- CTE Example 1 — Basic CTE
-- Find patients above average billing using CTE
WITH avg_billing AS (
    SELECT AVG(billing_amt) AS avg_amt
    FROM appointments
)
SELECT p.full_name,
       p.diagnosis,
       a.billing_amt
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id
CROSS JOIN avg_billing
WHERE a.billing_amt > avg_billing.avg_amt;

-- CTE Example 2 — Multiple CTEs
-- Hospital performance report using multiple CTEs
WITH 

-- CTE 1: Calculate average billing per department
dept_billing AS (
    SELECT d.department,
           AVG(a.billing_amt) AS avg_billing,
           COUNT(a.appt_id)   AS total_appointments
    FROM doctors d
    INNER JOIN appointments a ON d.doctor_id = a.doctor_id
    GROUP BY d.department
),

-- CTE 2: Find high risk patients (above 60, serious diagnosis)
high_risk_patients AS (
    SELECT patient_id,
           full_name,
           age,
           diagnosis
    FROM patients
    WHERE age > 60
    AND diagnosis IN ('Diabetes', 'Hypertension', 'Cancer')
),

-- CTE 3: Their appointment details
patient_appointments AS (
    SELECT h.full_name,
           h.age,
           h.diagnosis,
           a.appt_date,
           a.status,
           a.billing_amt
    FROM high_risk_patients h
    INNER JOIN appointments a ON h.patient_id = a.patient_id
)

-- Final query uses all 3 CTEs
SELECT pa.full_name,
       pa.age,
       pa.diagnosis,
       pa.appt_date,
       pa.billing_amt,
       db.avg_billing AS dept_avg_billing
FROM patient_appointments pa
CROSS JOIN dept_billing db
WHERE pa.status = 'Completed'
ORDER BY pa.billing_amt DESC;

-- Real World Medical Example — The Power of CTEs
-- Monthly hospital report:
-- High risk elderly patients who haven't had 
-- a follow-up appointment in the last 30 days

WITH 

-- Step 1: Identify high risk patients
high_risk AS (
    SELECT patient_id,
           full_name,
           age,
           diagnosis,
           ward
    FROM patients
    WHERE age > 65
    AND diagnosis IN ('Diabetes', 'Hypertension', 'Cancer', 'Heart Disease')
),

-- Step 2: Find their most recent appointment
last_appointments AS (
    SELECT patient_id,
           MAX(appt_date) AS last_appt_date
    FROM appointments
    GROUP BY patient_id
),

-- Step 3: Combine and find those needing follow-up
needs_followup AS (
    SELECT h.full_name,
           h.age,
           h.diagnosis,
           h.ward,
           l.last_appt_date
    FROM high_risk h
    LEFT JOIN last_appointments l ON h.patient_id = l.patient_id
    WHERE l.last_appt_date < DATEADD(day, -30, GETDATE())
    OR l.last_appt_date IS NULL
)

-- Final: Show the report
SELECT full_name,
       age,
       diagnosis,
       ward,
       last_appt_date,
       'Needs immediate follow-up' AS action_required
FROM needs_followup
ORDER BY age DESC;
