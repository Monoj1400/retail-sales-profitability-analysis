# Retail Sales & Profitability Analysis

An end-to-end data analytics project using **MySQL, Power BI, DAX, and Power Query** to investigate retail sales performance, profitability, discount patterns, product losses, and regional differences.

The goal is to move beyond sales reporting and identify where the business generates profit, where losses occur, and which areas deserve further investigation.

**Dataset:** Tableau Sample Superstore — a fictitious retail dataset.

## Dashboard Preview

### 1. Sales Overview
<img width="1220" height="683" alt="sales_overview" src="https://github.com/user-attachments/assets/e2e18dc4-5d8c-44c6-bf4c-90f928f48195" />

This dashboard provides a high-level view of business performance through key metrics, category comparisons, monthly sales patterns, discount analysis, and regional profitability.

**Key metrics**
- Total Sales: approximately $2.33 million
- Total Profit: approximately $292,296.81
- Total Orders: 5,111
- Total Customers: 804
- Profit Margin: 12.56%

### 2. Profitability Deep Dive

<img width="1220" height="683" alt="profitability_deep_dive" src="https://github.com/user-attachments/assets/c272a13b-59a8-4998-bce3-5718b6fa004d" />
This dashboard investigates profitability at a more detailed level, highlighting differences between product subcategories, loss-making products, and profit margins.

## Business Questions

This project investigates the following questions:

1. What are the overall sales, profit, order, and customer metrics?
2. How do sales vary by calendar month?
3. Which product categories and subcategories contribute most to profit?
4. Which individual products have the largest aggregate losses?
5. How does profitability differ across regions?
6. Which discount levels and product groups are associated with weaker profitability?
7. Which areas warrant further business investigation?

## Tools & Technologies

| Tool | Purpose |
|---|---|
| MySQL | Data validation, aggregation, and business analysis |
| Power BI | Interactive dashboards and visual reporting |
| DAX | KPI and profitability measures |
| Power Query | Data preparation and type conversion |
| GitHub | Project documentation and version control |

## Key Findings

- **Overall performance:** The dataset contains approximately $2.33 million in sales and $292,296.81 in profit, with an overall profit margin of 12.56%.
- **Category profitability:** Technology contributes the highest category-level profit in the current dashboard.
- **Furniture profitability:** Furniture has comparatively weak overall profitability, with Tables standing out as a loss-making subcategory.
- **Discount patterns:** Transactions with discounts above 30% show substantial aggregate losses in the SQL analysis.
- **Regional differences:** West has the highest total regional profit and the strongest profit margin among the four regions. Central remains profitable but has a comparatively lower margin.
- **Product-level losses:** Product-level analysis identifies individual products that warrant closer investigation of discounting, pricing, and costs.

These are descriptive findings from the sample dataset. Associations between discount levels and losses do not establish that discounts alone caused the losses.

## SQL Analysis

The SQL script includes queries for:

- Data validation and duplicate-import checks
- Overall business KPIs
- Category and subcategory profitability
- Profitability by discount band
- Loss-making product identification
- Product-level discount analysis
- Regional sales and profitability
- Furniture profitability by region and discount group

The queries include comments explaining their purpose and the business questions they address.

## Business Findings & Recommendations

The accompanying report documents the metrics, supporting evidence, business implications, and recommended areas for further investigation.

**Report:** [`Business Findings & Recommendations`](docs/Business%20Findings%20%26%20Recommendations.pdf)

*Confirm that the PDF filename and capitalization match the actual file in your repository. Update the link if the filename differs.*

## Repository Structure

```text
retail-sales-profitability-analysis/
├── README.md
├── sql/
│   └── analysis.sql
├── powerbi/
│   └── retail_sales.pbix
├── screenshots/
│   ├── sales_overview.png
│   └── profitability_deep_dive.png
├── docs/
│   └── Business Findings & Recommendations.pdf
└── data/
    └── README.md
```

## How to Explore the Project

1. View the dashboard previews above.
2. Browse `sql/analysis.sql` to review the queries.
3. Read the business findings and recommendations report.
4. Open the `.pbix` file in Power BI Desktop to explore the report interactively.
5. If Power BI requests a data source, connect to an authorized local copy of the dataset and update the source path as needed.

## Data Source & Disclaimer

This project uses the Tableau Sample Superstore dataset for educational and portfolio purposes. The dataset represents a fictitious retail business and should not be interpreted as the financial performance of an actual company.

The analysis identifies patterns and areas for investigation; the recommendations are not guaranteed to improve profitability without further testing.

## Skills Demonstrated

- SQL querying, aggregation, and data validation
- Business KPI calculation
- DAX measures and Power BI visualization
- Product and regional profitability analysis
- Discount-pattern investigation
- Business findings and recommendation writing
- Data storytelling and dashboard design

## Author

**Manoj Kumar B K**

Data Analytics | SQL | Power BI | DAX

