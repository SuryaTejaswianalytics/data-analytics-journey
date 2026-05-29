-- PART 1 — Ranking Functions
-- ROW_NUMBER
-- Number each patient within their ward
-- by billing amount highest first
SELECT p.full_name,
       p.ward,
       a.billing_amt,
       ROW_NUMBER() OVER (
           PARTITION BY p.ward
           ORDER BY a.billing_amt DESC
       ) AS row_num
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id;

-- Most asked interview question pattern!
WITH ranked_patients AS (
    SELECT p.full_name,
           p.ward,
           a.billing_amt,
           ROW_NUMBER() OVER (
               PARTITION BY p.ward
               ORDER BY a.billing_amt DESC
           ) AS row_num
    FROM patients p
    INNER JOIN appointments a ON p.patient_id = a.patient_id
)
SELECT full_name,
       ward,
       billing_amt,
       row_num
FROM ranked_patients
WHERE row_num <= 3;


-- RANK() vs DENSE_RANK() 
SELECT p.full_name,
       a.billing_amt,
       RANK()       OVER (ORDER BY a.billing_amt DESC) AS rank_num,
       DENSE_RANK() OVER (ORDER BY a.billing_amt DESC) AS dense_rank_num,
       ROW_NUMBER() OVER (ORDER BY a.billing_amt DESC) AS row_num
FROM patients p
INNER JOIN appointments a ON p.patient_id = a.patient_id;

-- PART 2 — Aggregate Window Functions
-- Show each patient's billing AND ward average AND ward total
-- ALL on the same row!
SELECT p.full_name,
       p.ward,
       a.billing_amt,
       AVG(a.billing_amt) OVER (PARTITION BY p.ward) AS ward_avg_billing,
       SUM(a.billing_amt) OVER (PARTITION BY p.ward) AS ward_total_billing,
       COUNT(*)            OVER (PARTITION BY p.ward) AS ward_patient_count,
       MAX(a.billing_amt) OVER (PARTITION BY p.ward) AS ward_max_billing
FROM patients 
INNER JOIN appointments a ON p.patient_id = a.patient_id;
-- Running total of billing by appointment date
-- Like a hospital's daily revenue tracker!
SELECT a.appt_date,
       p.full_name,
       a.billing_amt,
       SUM(a.billing_amt) OVER (
           ORDER BY a.appt_date
       ) AS running_total
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id
ORDER BY a.appt_date;

-- PART 3 — Navigation Functions
-- LAG() 
-- Compare each appointment's billing to the previous appointment
-- Track if billing is going up or down over time
SELECT p.full_name,
       a.appt_date,
       a.billing_amt,
       LAG(a.billing_amt) OVER (
           PARTITION BY p.patient_id
           ORDER BY a.appt_date
       ) AS previous_billing,
       a.billing_amt - LAG(a.billing_amt) OVER (
           PARTITION BY p.patient_id
           ORDER BY a.appt_date
       ) AS billing_change
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id;
-- LEAD() 
-- Find days between each appointment and the next one
-- Identify patients with long gaps between visits
SELECT p.full_name,
       a.appt_date,
       LEAD(a.appt_date) OVER (
           PARTITION BY p.patient_id
           ORDER BY a.appt_date
       ) AS next_appointment,
       DATEDIFF(day,
           a.appt_date,
           LEAD(a.appt_date) OVER (
               PARTITION BY p.patient_id
               ORDER BY a.appt_date
           )
       ) AS days_until_next
FROM appointments a
INNER JOIN patients p ON a.patient_id = p.patient_id;

-- Complete patient billing analysis report
-- Using ALL window function types together!

WITH patient_billing AS (
    SELECT p.full_name,
           p.ward,
           p.diagnosis,
           a.appt_date,
           a.billing_amt,

           -- Ranking within ward
           ROW_NUMBER() OVER (
               PARTITION BY p.ward
               ORDER BY a.billing_amt DESC
           ) AS ward_billing_rank,

           -- Compare to ward average
           AVG(a.billing_amt) OVER (
               PARTITION BY p.ward
           ) AS ward_avg_billing,

           -- Running hospital total
           SUM(a.billing_amt) OVER (
               ORDER BY a.appt_date
           ) AS running_total,

           -- Previous appointment billing
           LAG(a.billing_amt) OVER (
               PARTITION BY p.patient_id
               ORDER BY a.appt_date
           ) AS prev_billing

    FROM appointments a
    INNER JOIN patients p ON a.patient_id = p.patient_id
)

SELECT full_name,
       ward,
       diagnosis,
       billing_amt,
       ward_billing_rank,
       ward_avg_billing,
       billing_amt - ward_avg_billing AS vs_ward_avg,
       running_total,
       prev_billing,
       billing_amt - prev_billing     AS change_from_last
FROM patient_billing
WHERE ward_billing_rank <= 5
ORDER BY ward, ward_billing_rank;
