# Superstore Sales Analysis

SQL-based business analysis of a US retail superstore dataset — 9,994 orders across 4 years (2014–2017).

## Objective

Identify profitability drivers, loss-making products and customers, and discount strategy inefficiencies to derive actionable business recommendations.

## Tools & Technologies

- **PostgreSQL** — all queries and table creation
- **DBeaver** — query execution and result inspection
- **Docker** — containerised database environment

## Dataset

Superstore Sales Dataset — originally published by Tableau.  
Source: [Kaggle – Superstore Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)

---

## Analysis Structure

The analysis is split into five thematic blocks:

| Block | Focus |
|---|---|
| 1. Profitability | Category margins, regional breakdown |
| 2. Loss products & customers | Top loss-making SKUs, customer-level drill-down |
| 3. Discount strategy | Profit/discount correlation, threshold analysis |
| 4. Customer segments | JOIN analysis across Consumer, Corporate, Home Office |
| 5. Time & logistics | Year-over-year trends, seasonality, shipping speed |

---

## Key Findings

### Profitability by Category

| Category | Total Sales | Total Profit | Margin |
|---|---|---|---|
| Technology | High | Highest | ~17% |
| Office Supplies | Medium | Medium | ~17% |
| Furniture | High | Very low | ~2% |

Furniture generates high revenue but critically low margins — likely driven by high purchase costs or structural underpricing, not discounts alone.

### Regional Profit

The **West** region leads in total profit, followed by the **East**. The **Central** region is the weakest performer.

### Loss-Making Products

The top 10 loss-making products are concentrated in **expensive electronics and large furniture items**.  
Notable: the *Cubify CubeX 3D Printer* alone generated a loss of **–$8,879**.

### Loss-Making Customers — Case Study: Cindy Stewart

An investigation into customers with negative total profit revealed that the largest loss was caused by two high-value orders sold at a **70% discount**, wiping out all margin. This is a systemic risk, not an isolated case.

### Discount Strategy

```sql
-- Profits turn negative at discounts above 30%
SELECT discount * 100 AS "discount in %", ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore
GROUP BY discount
ORDER BY "discount in %" DESC;
```

| Discount Range | Effect on Profit |
|---|---|
| 0–20% | Positive |
| 20–30% | Diminishing |
| > 30% | Consistently negative |

**Recommendation:** Hard cap discounts at 20%.

### Customer Segments (JOIN Analysis)

Two derived tables (`customers`, `orders`) were created and joined to analyse segments:

| Segment | Customers | Orders | Total Profit | Profit/Customer |
|---|---|---|---|---|
| Consumer | 409 | 17,539 | Highest | Medium |
| Corporate | ~200 | ~7,000 | Medium | **Highest** |
| Home Office | ~150 | ~5,000 | Lowest | Second highest |

The Consumer segment leads in total profit purely due to volume. **Corporate customers are the most valuable per capita.**  
**Recommendation:** Prioritise Corporate and Home Office acquisition while keeping the Consumer segment stable.

### Year-over-Year Revenue

Annual revenue grew consistently from 2014 to 2017, with one exception: a decline from 2014 to 2015 caused by drops in **Office Supplies and Technology** sales. Furniture grew throughout despite its poor margin structure.

### Seasonality

**November and December** are the strongest months by revenue, driven by the holiday season.  
Notable: November shows *higher* revenue than December but *lower* profit — not primarily due to discounts (only 1% difference), but because November skews heavily toward **Technology purchases at lower margins**.

### Logistics

| Ship Mode | Avg. Delivery Time |
|---|---|
| Standard Class | ~5 days |
| Second Class | ~3 days |
| First Class | ~2 days |
| Same Day | ~0.04 days |

All shipping modes perform within reasonable expectations.

---

## Business Recommendations

1. **Furniture** — Investigate cost structure. A 2% margin is not sustainable at current sales volume.
2. **Discounts** — Enforce a hard cap at 20%. Discounts above 30% consistently destroy profit.
3. **Customer strategy** — Shift acquisition focus toward Corporate and Home Office segments.
4. **Seasonality** — Reduce aggressive discounting in November to protect margins during peak season.
5. **Loss customers** — Flag high-discount single orders for approval before processing.

---

## Project Structure

```
superstore-analysis/
│
├── superstore_analysis.sql   # Full SQL analysis with inline comments (219 lines)
├── superstore_analysis.pdf   # Exported results and findings
└── README.md                 # Project documentation
```

---

## How to Run

1. Start a PostgreSQL instance (e.g. via Docker)
2. Import the Superstore dataset as a table named `superstore`
3. Run `superstore_analysis.sql` in DBeaver or any PostgreSQL client
