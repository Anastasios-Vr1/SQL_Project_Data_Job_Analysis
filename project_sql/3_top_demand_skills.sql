/* 
Question: What are the most in-demand skills for Data Analysts?
- Joined job postings to inner join table similar to query 2
- Identifies the top 5 in-demand skills for a data analyst.
- Focuses on all job postings.
Why? Retrieves the top 5 skills with the highest demand in the job market,
    providing insights into the most valuable skills for job seekers.
    */

SELECT 
    skills,
    COUNT (*) AS skill_count
FROM 
    job_postings_fact
JOIN skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE  
    job_title_short = 'Data Analyst' AND 
    job_work_from_home = TRUE
GROUP BY skills
ORDER BY 
    skill_count DESC
LIMIT 5;

/*
Here's the breakdown of the most demanded skills for data analysts in 2023
SQL and Excel remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
Programming and Visualization Tools like Python, Tableau, and Power BI are essential, pointing towards the increasing importance of technical skills in data storytelling and decision support.
*/