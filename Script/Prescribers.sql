-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi
ORDER BY sum_total_claim_count DESC
LIMIT 10;
--ANSWER=1881634483 and 99707

SELECT npi, nppes_provider_last_org_name, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_last_org_name
ORDER BY sum_total_claim_count DESC
LIMIT 10;
=Pendley
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT npi, nppes_provider_last_org_name,nppes_provider_first_name, specialty_description, SUM(total_claim_count) AS sum_total_claim_count
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY npi, nppes_provider_last_org_name,nppes_provider_first_name, specialty_description
ORDER BY sum_total_claim_count DESC
LIMIT 10;
-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS claims 
FROM prescriber
INNER JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY claims DESC;

--answer= FAMILY PRACTICE=9,752,347

--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description, SUM(total_claim_count) AS claims
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
USING(drug_name)
WHERE opioid_drug_flag='Y'
GROUP BY specialty_description
ORDER BY claims DESC;
--ANSWER= Nurse Practitioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT
pr.specialty_description AS specialty,
COUNT (pn. drug_name) As drug_count
FROM prescriber AS pr
LEFT JOIN prescription AS pn
USING(прі)
GROUP BY pr. specialty_description
HAVING COUNT (pn.drug_name) =0

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name, SUM(total_drug_cost) AS total_drug_cost
FROM drug
LEFT JOIN prescription
	USING (drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generiC_name
ORDER BY total_drug_cost DESC;



--ANSWER=INSULIN GLARGINE, 

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name, 
	ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS daily_cost
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC;
--ANSWER= C1 ESTERASE INHIBITOR
-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
	CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT CAST(SUM(total_drug_cost) AS money),
	CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug
INNER JOIN prescription
USING (drug_name)
WHERE
CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END<>'neither'
GROUP BY CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END

--ANSWER= opiod
-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT (cbsaname)
FROM CBSA
WHERE cbsaname LIKE '%TN%'

--ANSWER=10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT DISTINCT (cbsaname) AS distinct_cbsaname, SUM(population) AS sum_population
FROM CBSA
INNER JOIN fips_county
USING (fipscounty)
INNER JOIN population
USING (fipscounty)
GROUP BY distinct_cbsaname
order BY distinct_cbsaname DESC

SELECT cbsaname, SUM(population) AS sum_population
FROM CBSA
INNER JOIN fips_county
USING (fipscounty)
INNER JOIN population
USING (fipscounty)
GROUP BY cbsaname
ORDER BY sum_population DESC;


SELECT *
FROM fips_county



--ANSWER=MORRISTOWN 116352 smallest
Nashville-Davidson--Murfreesboro--Franklin, TN 1830410 highest


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county, SUM(population) AS sum_population
FROM population
INNER JOIN fips_county
USING (fipscounty)
LEFT JOIN cbsa
USING (fipscounty)
WHERE cbsa IS NULL
GROUP BY county
ORDER BY sum_population DESC
LIMIT 1

--ANSWER= SEVIER 95523


-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT total_claim_count, drug_name
from prescription
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

--Answer Oxcodone 4538

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT total_claim_count, drug_name, opioid_drug_flag
from prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000 
ORDER BY total_claim_count DESC;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT total_claim_count, drug_name, opioid_drug_flag, nppes_provider_first_name, nppes_provider_last_org_name
from prescription
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, total_claim_count, opioid_drug_flag
from prescription
INNER JOIN drug
USING (drug_name)
INNER JOIN prescriber
USING (npi)
WHERE nppes_provider_city ILIKE '%Nashville%' AND 
	 opioid_drug_flag='Y'
GROUP BY opioid_drug_flag

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT prescriber.npi, drug_name
FROM prescriber
CROSS JOIN drug
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT
p.npi,
d. drug_name,
SUM (p2. total_claim_count)
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
USING (drug_name, npi)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY d.drug_name, p.npi;
    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT p.npi, d. drug_name,
COALESCE (p2. total_claim_count,0) 
FROM prescriber AS p
CROSS JOIN drug AS d
FULL JOIN prescription AS p2
USING (drug_name, npi)
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'


