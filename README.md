# Superstore Sales Analysis

SQL-based business analysis of a US retail superstore dataset (9,994 orders, 2014–2017).

## Objective

Identify profitability drivers, loss-making products and customers, and discount strategy inefficiencies to derive actionable business recommendations.

## Tools & Technologies

- PostgreSQL
- DBeaver
- Docker

## Dataset

Superstore Sales Dataset — originally published by Tableau.  
Source: [Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

## Key Findings

**Profitability by Category**
- Technology is the most profitable category (margin: 17%)
- Furniture generates high revenue but only a 2% profit margin — critically underperforming
- Office Supplies matches Technology in margin (17%) but at lower total volume

**Loss-Making Products**
- The top 10 loss-making products are concentrated in expensive electronics and large furniture items
- The Cubify CubeX 3D Printer alone generated a loss of -$8,879

**Discount Strategy**
- Profits turn negative at discounts above 30%
- Discounts of 70% were applied to individual high-value orders, causing significant losses
- Recommendation: Cap discounts at 20%

**Customer Segments**
- Consumer segment generates the highest total profit due to volume (409 customers, 17,539 orders)
- Corporate customers are the most profitable per capita ($1,323 profit/customer)
- Recommendation: Prioritize Corporate and Home Office acquisition

**Seasonality**
- November and December are the strongest months by revenue
- November shows higher revenue than December but lower profit — driven by lower Technology margins

**Logistics**
- Standard Class shipping averages 5 days
- Same Day delivery averages 0.04 days

## Business Recommendations

1. **Furniture**: Investigate cost structure — 2% margin is not sustainable
2. **Discounts**: Enforce a hard cap at 20% — discounts above 30% consistently destroy profit
3. **Customer strategy**: Shift acquisition focus toward Corporate and Home Office segments
4. **Seasonality**: Reduce aggressive discounting in November to protect margins during peak season

## Project Structure

```
superstore-analysis/
│
├── superstore_analysis.sql   # Full SQL analysis with comments
└── README.md                 # Project documentation
```