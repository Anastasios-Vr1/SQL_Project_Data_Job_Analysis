/*
Question: What are the most optimal skills to learn (high demand and high-paying skill)?
- Identifies skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why? Targets skills that offer job security(high demand) and financial benefits (high salaries),
  offering strategic insights for career development in data analysis
*/

---Identifies skills in high demand for Data Analyst roles

WITH skills_demand AS ( 
    SELECT
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT (*) AS skill_demand_count
    FROM 
        job_postings_fact
    JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE  
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL AND
        job_work_from_home = TRUE
    GROUP BY 
        skills_dim.skill_id
), 
--- Identifies skills with high average salaries for Data Analyst roles

average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        ROUND(AVG(salary_year_avg),0) AS average_salary
    FROM 
        job_postings_fact
    JOIN skills_job_dim 
        ON job_postings_fact.job_id = skills_job_dim.job_id
    JOIN skills_dim 
        ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE  
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL AND 
        job_work_from_home = TRUE
    GROUP BY skills_job_dim.skill_id
)
--- Returns high demand skills with high salaries having (count) skill_demand >10 
SELECT
   skills_demand.skill_id,
   skills_demand.skills,
   skill_demand_count,
   average_salary
FROM
    skills_demand
JOIN average_salary
    ON skills_demand.skill_id = average_salary.skill_id
WHERE skill_demand_count > 10 
  AND job_work_from_home = TRUE
ORDER BY 
    skill_demand_count DESC,
    average_salary DESC
LIMIT 25;

---Rewriting the same query more concisely (Optimization)

SELECT
    skills_dim.skill_id,
    skills,
    count(*) AS skill_demand_count,
    ROUND(AVG(salary_year_avg),0) AS average_salary
FROM 
    job_postings_fact
JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE 
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL AND 
    job_work_from_home = TRUE
GROUP BY skills_dim.skill_id
HAVING  count(*) > 10
ORDER BY 
    skill_demand_count DESC,
    average_salary DESC
LIMIT 25;

/*
Here's a breakdown of the most optimal skills for Data Analysts in 2023: 
-Database Technologies: SQL and Excel continue to be foundational skills, with demand counts of 398 and 256 respectively. Moreover, proficiency in cloud-based platforms like Snowflake, Azure, and AWS is increasingly valued, reflecting the industry's shift towards cloud-based data management solutions. The average salaries for these technologies range from $82,576 to $97,431, indicating their enduring importance in facilitating data storage and analysis tasks.
- Business Intelligence and Visualization Tools: Tableau and Power BI are indispensable tools in the data analyst arsenal, with demand counts of 230 and 110 respectively. These tools empower analysts to transform complex datasets into actionable insights through intuitive visualizations. With average salaries around $99,288 and $97,431 respectively, Tableau and Power BI are pivotal in aiding decision-making processes and driving business intelligence initiatives forward.
- Programming Languages: Python and R remain highly sought after, boasting demand counts of 236 and 148 respectively. While their popularity underscores their versatility in data analysis tasks, competitive markets yield average salaries of $101,397 and $100,499, reflecting the abundance of skilled professionals proficient in these languages.
*/
