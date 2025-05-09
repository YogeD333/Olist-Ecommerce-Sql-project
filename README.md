# Olist-Ecommerce-Sql-project

--- Global E-commerce Sales & Customer Analytics (SQL Project)

Welcome! This is a SQL-only data analytics project where I explored a real-world Brazilian e-commerce dataset (by Olist) to generate deep business insights across customers, sales, deliveries, reviews, and payment patterns.

The entire project was built using pure SQL – no Python, no Power BI – just advanced SQL queries to simulate how a data analyst would work inside a database-driven company.

---About the Dataset

This dataset was sourced from Kaggle and includes over 100,000+ orders across multiple tables, such as:

orders – order details with status and delivery dates

order_items – products in each order

customers – customer location and IDs

order_payments – payment methods and values

order_reviews – customer feedback

products, sellers, geolocation – supporting data for richer insights

--- What I Did (Project Summary)

Cleaned and joined messy relational tables using CTEs and advanced joins

Used window functions like RANK(), ROW_NUMBER(), LAG(), LEAD() to track trends and order behaviors

Answered real business questions around customer value, seller performance, top product categories, delayed deliveries, and more

Wrote modular SQL scripts that can easily be reused or plugged into dashboards

---Sample Business Questions Answered

✅ Which product categories generate the highest revenue?
✅ What’s the average customer lifetime value (CLV)?
✅ Which cities and states spend the most?
✅ How does delivery delay affect review ratings?
✅ Who are the top-performing sellers by volume and review quality?
✅ What’s the refund risk by payment method?

--- Skills Demonstrated

Advanced SQL querying (MySQL / PostgreSQL syntax)

Real-world data modeling from raw CSVs

Writing clean, modular, and efficient SQL scripts

Business-first thinking with a data analyst mindset

--- Project Structure

bash
Copy
Edit
📦 global-ecommerce-sql/
├── README.md
├── ERD.png
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   └── ...
├── scripts/
│   ├── cleaned_tables.sql
│   ├── customer_ltv.sql
│   ├── revenue_by_category.sql
│   └── ...

--- How to Use This

Import the .csv files into your SQL database (MySQL/PostgreSQL recommended)

Run the scripts from /scripts to clean and prepare the tables

Run each analysis query separately to generate insights

📈 A Few Insights
📍 São Paulo and Rio de Janeiro dominate total sales.
🕒 Delayed deliveries correlate with lower review scores.
💳 Credit card payments account for ~75% of all orders.
🎯 A small % of sellers drive most of the revenue.

👋 About Me
YOGESHWARAN P
Aspiring Data Analyst | SQL Specialist | Focused on Business-Driven Insights
yoged333@gmail.com
