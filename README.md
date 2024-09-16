# Introduction
📊Embark on a journey into the dynamic data job market! Centered around data analyst roles, this project delves into 💰 top-paying jobs, 🔥 in-demand skills, and the intersection where high demand 📈 aligns with generous salaries in the realm of data analytics.

🔍 SQL queries? Check them out here: [project_sql folder](/project_sql/)

### The questions I aimed to address through my SQL queries were:

1. What are the top-paying data analyst jobs?
2. What skills are required for these top-paying jobs?
3. What skills are most in demand for data analysts?
4. Which skills are associated with higher salaries?
5. What are the most optimal skills to learn?

# Tools I used
For my deep dive into the data analyst job market, I harnessed the power of several key tools:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights.
- **PostgreSQL:** The chosen database management system, ideal for handling the job posting data.
- **Visual Studio Code:** My go-to for database management and executing SQL queries.
- **Git & GitHub:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking.
- **Excel:** Useful for data analysis, data cleaning, removing duplicates, table creation and generation of basic & informative charts and graphs.

# The Data

The dataset used for this project was sourced during 2023 from job postings collected daily from Google’s search results, totaling approximately 6,500 jobs per day. These postings primarily focused on data science-type roles from around the globe. The inception and creation of the accompanying app stemmed from Luke Barrouse. In the [live app](https://datanerd.tech/About), the job postings were sent through an NLP pipeline and then aggregated daily to identify top skills and median salaries. [Luke Barrouse](https://datanerd.tech/About) was the mastermind behind this very useful tool for Data Science Nerds. For a sample of the data, you can [check out Kaggle.](https://www.kaggle.com/datasets/lukebarousse/data-analyst-job-postings-google-search)

### The ERD
The Entity-Relationship Diagram (ERD) helps us visualize the structure and relationships between the differet tables in this database. You can see below that we have 4 major tables of which "job_postings_fact" is a fact table and the other 3 "skills_job_dim", "skills_dim", "company_dim" are dimentional tables that will help in filtering and grouping data down the road.

![alt text](<assets/Data model schema.png>)

# The Analysis
Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:

## 1. Top Paying Data Analyst Jobs
To identify the highest-paying roles, I filtered data analyst positions by average yearly salary and location, focusing on remote jobs. This query highlights the high paying opportunities in the field.

```sql
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM 
    job_postings_fact
LEFT JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_location = 'Anywhere' AND
    job_title_short = 'Data Analyst' AND
    salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10;
````
Here's the breakdown of the top data analyst jobs in 2023:
- **Wide Salary Range:** Top 10 paying data analyst roles span from $184,000 to $650,000, indicating significant salary potential in the field.
- **Diverse Employers:** Companies like SmartAsset, Meta, and AT&T are among those offering high salaries, showing a broad interest across different industries.
- **Job Title Variety:** There's a high diversity in job titles, from Data Analyst to Director of Analytics, reflecting varied roles and specializations within data analytics.

![Top Paying Roles](/assets/Barchart1.png)
*Bar graph visualizing the salary for the top 10 salaries for data analysts; I created this graph in Excel by importing data from a CSV file generated from the results of my SQL query.*

## 2. Skills for Top Paying Jobs
To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.
```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM 
        job_postings_fact
    LEFT JOIN company_dim
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_location = 'Anywhere' AND
        job_title_short = 'Data Analyst' AND
        salary_year_avg IS NOT NULL
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)

SELECT 
    top_paying_jobs.*,
    skills AS skill_name,
    COUNT(*) OVER (PARTITION BY skills ) AS skill_count
FROM 
    top_paying_jobs
JOIN skills_job_dim
    ON top_paying_jobs.job_id = skills_job_dim.job_id
JOIN skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY 
    salary_year_avg DESC;
```
Here's the breakdown of the most demanded skills for data analysts in 2023, based on job postings:
- **SQL** is leading with a bold count of 8.
- **Python** follows closely with a bold count of 7.
- **Tableau** is also highly sought after, with a bold count of 6. Other skills like R, Snowflake, Pandas, and Excel show varying degrees of demand.

![Top Paying Skills](/assets/barchart2.png)
*Bar graph visualizing the count of skills for the top 10 paying jobs for data analysts; I created this graph in Excel by importing data from a CSV file generated from the results of my SQL query.*

## 3. In-Demand Skills for Data Analysts
This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

```sql
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
```	
Here's the breakdown of the most demanded skills for data analysts in 2023
- **SQL** and **Excel** remain fundamental, emphasizing the need for strong foundational skills in data processing and spreadsheet manipulation.
- **Programming** and **Visualization Tools** like **Python**, **Tableau**, and **Power BI** are essential, pointing towards the increasing importance of technical skills in data storytelling and decision support.


| Skills   | Skill Count |
|----------|-------------|
| SQL      | 7,291       |
| Excel    | 4,611       |
| Python   | 4,330       |
| Tableau  | 3,745       |
| Power BI | 2,609       |

*Table of the demand for the top 5 skills in data analyst job postings*

## 4. Skills Based on Salary
Exploring the average salaries associated with different skills revealed which skills are the highest paying.
```sql
SELECT 
    skills,
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
    job_work_from_home = True 
GROUP BY skills
ORDER BY 
    average_salary DESC
LIMIT 25;
```
Here's a breakdown of the results for top paying skills for Data Analysts:
- **High Demand for Big Data & ML Skills:** Top salaries are commanded by analysts skilled in big data technologies (PySpark, Couchbase), machine learning tools (DataRobot, Jupyter), and Python libraries (Pandas, NumPy), reflecting the industry's high valuation of data processing and predictive modeling capabilities.
- **Software Development & Deployment Proficiency:** Knowledge in development and deployment tools (GitLab, Kubernetes, Airflow) indicates a lucrative crossover between data analysis and engineering, with a premium on skills that facilitate automation and efficient data pipeline management.
- **Cloud Computing Expertise:** Familiarity with cloud and data engineering tools (Elasticsearch, Databricks, GCP) underscores the growing importance of cloud-based analytics environments, suggesting that cloud proficiency significantly boosts earning potential in data analytics.

| Skills         | Average Salary |
|----------------|----------------|
| pyspark        | $208,172.25    |
| bitbucket      | $189,154.50    |
| couchbase      | $160,515.00    |
| watson         | $160,515.00    |
| datarobot      | $155,485.50    |
| gitlab         | $154,500.00    |
| swift          | $153,750.00    |
| jupyter        | $152,776.50    |
| pandas         | $151,821.33    |
| elasticsearch  | $145,000.00    |

*Table of the average salary for the top 10 paying skills for data analysts.*

### 5. Most Optimal Skills to Learn

This query aimed to strategically identify skills that are not only in high demand but also command high salaries, by combining insights from both demand and salary data, thus providing a targeted direction for skill development.

```sql
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
```

| Skills      | Skill Demand Count | Average Salary |
|-------------|--------------------|----------------|
| SQL         | 398                | $97,237        |
| Excel       | 256                | $87,288        |
| Python      | 236                | $101,397       |
| Tableau     | 230                | $99,288        |
| R           | 148                | $100,499       |
| Power BI    | 110                | $97,431        |
| SAS         | 63                 | $98,902        |
| PowerPoint  | 58                 | $88,701        |
| Looker      | 49                 | $103,795       |
| Word        | 48                 | $82,576        |

*Table of the most optimal skills for data analyst sorted by skill demand and salary.*

Here's a breakdown of the most optimal skills for Data Analysts in 2023: 
- **Database Technologies:** SQL and Excel continue to be foundational skills, with demand counts of 398 and 256 respectively. Moreover, proficiency in cloud-based platforms like Snowflake, Azure, and AWS is increasingly valued, reflecting the industry's shift towards cloud-based data management solutions. The average salaries for these technologies range from $82,576 to $97,431, indicating their enduring importance in facilitating data storage and analysis tasks.
- **Business Intelligence and Visualization Tools:** Tableau and Power BI are indispensable tools in the data analyst arsenal, with demand counts of 230 and 110 respectively. These tools empower analysts to transform complex datasets into actionable insights through intuitive visualizations. With average salaries around $99,288 and $97,431 respectively, Tableau and Power BI are pivotal in aiding decision-making processes and driving business intelligence initiatives forward.
- **Programming Languages:** Python and R remain highly sought after, boasting demand counts of 236 and 148 respectively. While their popularity underscores their versatility in data analysis tasks, competitive markets yield average salaries of $101,397 and $100,499, reflecting the abundance of skilled professionals proficient in these languages.

In summary, the optimal skill set for Data Analysts encompasses a diverse range of abilities, from database management and visualization tools to programming languages. Data Analysts equipped with these skills are well-positioned to navigate the complexities of modern data analysis and drive impactful insights for their organizations.

# Conclusions

### Insights
From the analysis, several general insights emerged:

1. **Top-Paying Data Analyst Jobs**: The highest-paying jobs for data analysts that allow remote work offer a wide range of salaries, the highest at $650,000!
2. **Skills for Top-Paying Jobs**: High-paying data analyst jobs require advanced proficiency in SQL, suggesting it’s a critical skill for earning a top salary.
3. **Most In-Demand Skills**: SQL is also the most demanded skill in the data analyst job market, thus making it essential for job seekers.
4. **Skills with Higher Salaries**: Specialized skills, such as SVN and Solidity, are associated with the highest average salaries, indicating a premium on niche expertise.
5. **Optimal Skills for Job Market Value**: SQL leads in demand and offers a high average salary, positioning it as one of the most optimal skills for data analysts to learn to maximize their market value. Additionally, solid knowledge of Tableau or Power BI and Python, with their significant demand and competitive salaries, further enhances a data analyst's market worth in today's job landscape.

### Final Remarks

This project enhanced my SQL skills while offering invaluable insights into the data analyst job landscape. The conclusions drawn from this analysis offer actionable guidance for prioritizing skill development and job search strategies. By concentrating on skills that are both in high demand and offer competitive salaries, aspiring data analysts can effectively position themselves in a competitive job market. This exploration underscores the significance of continuous learning and adaptation to evolving trends within the realm of data analytics.

#### Acknowledgements & Inspiration
Drawing inspiration from [Luke Barrouse's pioneering work](https://www.lukebarousse.com/), this project is a testament to his invaluable contributions to the field of data analysis. Luke's meticulous groundwork has provided Data Analysts with a solid foundation for learning and practice. In crafting my version of this project, I pay homage to Luke's expertise while presenting a nuanced approach that reflects my own perspective and insights drawn. It is with deep gratitude and admiration for [Luke's work](https://www.lukebarousse.com/) that I keep rocking on this journey, building upon his legacy & contributions to further explore the intricacies of data analysis while always staying motivated & ready to help others embark on their own majestic data science journey. Respect.
