# Domino's Pizza SQL Analysis — Technical Validation Notes

## 1. Project Overview & Audit Objective
This document records the data verification, schema validation, and SQL execution results for the Domino's Pizza sales analytics project. The objective is to ensure 100% data fidelity between the raw transactional records, the analytical queries in `Dominos_Query.sql`, and the final portfolio presentation deliverables.

---

## 2. Database Schema & Relational Integrity Audit

### 2.1 Table Record Counts
| Table Name | Primary Key | Foreign Keys | Row Count | Status |
| :--- | :--- | :--- | :--- | :--- |
| `pizza_types` | `pizza_type_id` | None | **32** | Verified |
| `pizzas` | `pizza_id` | `pizza_type_id` -> `pizza_types` | **96** | Verified |
| `orders` | `order_id` | None | **21,350** | Verified |
| `order_details` | `order_details_id` | `order_id` -> `orders`, `pizza_id` -> `pizzas` | **48,620** | Verified |

### 2.2 Foreign Key Referential Integrity Check
- **`order_details.order_id` -> `orders.order_id`**: 0 orphaned records. Every line item matches an existing order.
- **`order_details.pizza_id` -> `pizzas.pizza_id`**: 0 orphaned records. Every line item matches a valid pizza SKU and size.
- **`pizzas.pizza_type_id` -> `pizza_types.pizza_type_id`**: 0 orphaned records. Every pizza SKU links to an authentic pizza type.

### 2.3 Date Range & Temporal Completeness
- **Start Date:** `2015-01-01`
- **End Date:** `2015-12-31`
- **Operating Days:** 358 unique dates recorded across the calendar year 2015.
- **Time Range:** Orders span from `09:52:21` to `23:23:10`.

---

## 3. Comprehensive SQL Query Validation & Senior Analyst Review

### Query 1: Total Number of Orders Placed
- **Original SQL:**
  ```sql
  SELECT COUNT(order_id) AS Total_orders FROM orders;
  ```
- **Execution Result:** `21,350`
- **Analyst Note:** Correctly counts distinct transaction IDs from the master `orders` table.

---

### Query 2: Total Revenue Generated from Overall Pizza Sales
- **Original SQL:**
  ```sql
  SELECT ROUND(SUM(o.quantity * p.price), 2) AS Total_revenue 
  FROM order_details o 
  LEFT JOIN pizzas p ON o.pizza_id = p.pizza_id;
  ```
- **Execution Result:** `$817,860.05`
- **Analyst Note:** Total revenue is calculated at the transaction line-item level (`quantity * price`). The total volume of pizzas sold across all orders is `49,574` units. Average Order Value (AOV) is `$38.31` (`$817,860.05 / 21,350`). Average items per order is `2.32` pizzas.

---

### Query 3: Highest-Priced Pizza
- **Original SQL:**
  ```sql
  SELECT pt.name, p.price 
  FROM pizzas p 
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id 
  ORDER BY p.price DESC LIMIT 1;
  ```
- **Execution Result:** `The Greek Pizza` — `$35.95`
- **Analyst Note:** This price corresponds to the `XXL` size of The Greek Pizza (`greek_xxl`). While it is the highest menu price point, XXL pizzas only account for 28 total purchases all year, representing a niche product rather than a primary revenue driver.

---

### Query 4: Most Common Pizza Size Ordered
- **Original SQL:**
  ```sql
  SELECT p.size, COUNT(od.order_id) AS TotaL_Order 
  FROM pizzas p 
  JOIN order_details od ON p.pizza_id = od.pizza_id 
  GROUP BY p.size
  ORDER BY TotaL_Order DESC;
  ```
- **Execution Result:**
  | Size | Order Line Items (`COUNT(od.order_id)`) | Actual Units Sold (`SUM(quantity)`) |
  | :--- | :--- | :--- |
  | **L** | **18,526** (38.10%) | **18,956** (38.24%) |
  | **M** | **15,385** (31.64%) | **15,635** (31.54%) |
  | **S** | **14,137** (29.08%) | **14,403** (29.05%) |
  | **XL** | **544** (1.12%) | **552** (1.11%) |
  | **XXL** | **28** (0.06%) | **28** (0.06%) |
- **Senior Analyst Nuance:**
  The query uses `COUNT(od.order_id)`, which represents the number of order-detail records (line items) where a given size was selected. If evaluating actual physical units sold, `SUM(od.quantity)` should be referenced. In both metrics, the rank order remains identical (`L > M > S > XL > XXL`). Large (`L`) represents the overwhelming consumer preference.

---

### Query 5: Top 5 Most Ordered Pizza Names Along with Their Quantity
- **Original SQL:**
  ```sql
  SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity
  FROM pizza_types
  JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
  GROUP BY pizza_types.name 
  ORDER BY total_quantity DESC LIMIT 5;
  ```
- **Execution Result:**
  1. `The Classic Deluxe Pizza`: **2,453** units
  2. `The Barbecue Chicken Pizza`: **2,432** units
  3. `The Hawaiian Pizza`: **2,422** units
  4. `The Pepperoni Pizza`: **2,418** units
  5. `The Thai Chicken Pizza`: **2,371** units
- **Analyst Note:** High concentration among classic family favorites and specialty chicken items. The top 5 pizzas alone account for 12,096 pizzas (~24.4% of all pizzas sold).

---

### Query 6: Distribution of Orders by Hour of the Day
- **Original SQL:**
  ```sql
  SELECT HOUR(time) AS hour, COUNT(order_id) AS order_count 
  FROM orders
  GROUP BY hour
  ORDER BY hour;
  ```
- **Execution Result:**
  - `09:00`: 1 order
  - `10:00`: 8 orders
  - `11:00`: 1,231 orders
  - `12:00`: **2,520 orders** (Lunch Peak - 11.8% of daily total)
  - `13:00`: 2,455 orders (Lunch Rush continued)
  - `14:00`: 1,472 orders
  - `15:00`: 1,468 orders
  - `16:00`: 1,920 orders
  - `17:00`: 2,336 orders (Dinner Rush begins)
  - `18:00`: **2,399 orders** (Dinner Peak - 11.2% of daily total)
  - `19:00`: 2,009 orders
  - `20:00`: 1,642 orders
  - `21:00`: 1,198 orders
  - `22:00`: 663 orders
  - `23:00`: 28 orders
- **Analyst Note:** Demonstrates a distinct bi-modal demand curve. 45.4% of all daily transactions occur during two 2-hour windows (12-2 PM and 5-7 PM). Staffing, dough prepping, and oven staging must align around these operational peaks.

---

### Query 7: Top 3 Most Ordered Pizza Names Based on Total Revenue
- **Original SQL:**
  ```sql
  SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_revenue
  FROM pizza_types 
  JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
  GROUP BY pizza_types.name 
  ORDER BY total_revenue DESC LIMIT 3;
  ```
- **Execution Result:**
  1. `The Thai Chicken Pizza`: **$43,434.25**
  2. `The Barbecue Chicken Pizza`: **$42,768.00**
  3. `The California Chicken Pizza`: **$41,409.50**
- **Analyst Note:** All 3 revenue leaders belong to the **Chicken** category. Even though Classic pizzas sell more aggregate units, Chicken pizzas command higher average price points ($20.75 for L), allowing them to generate the highest dollar turnover.

---

### Query 8: Percentage Contribution of Each Pizza Category to Total Revenue
- **Original SQL:**
  ```sql
  WITH ppp AS (
    SELECT pizza_types.category, ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_revenue 
    FROM pizza_types 
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizza_types.category
    ORDER BY total_revenue DESC
  )
  SELECT category, CONCAT(ROUND((total_revenue / (SELECT SUM(total_revenue) FROM ppp)) * 100, 2), '%') AS Percentage
  FROM ppp;
  ```
- **Execution Result:**
  - `Classic`: **$220,053.10** (**26.91%**)
  - `Supreme`: **$208,197.00** (**25.46%**)
  - `Chicken`: **$195,919.50** (**23.96%**)
  - `Veggie`: **$193,690.45** (**23.68%**)
- **Analyst Note:** The revenue distribution is remarkably balanced across categories, each contributing between 23.7% and 26.9%. This indicates a diversified customer preference base with no single category dominating or creating vulnerability.

---

### Query 9: Total Quantity of Each Pizza Category Ordered
- **Original SQL:**
  ```sql
  SELECT pizza_types.category, SUM(order_details.quantity) AS total_quantity
  FROM pizza_types
  JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
  JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
  GROUP BY pizza_types.category
  ORDER BY total_quantity DESC LIMIT 5;
  ```
- **Execution Result:**
  - `Classic`: **14,888** units
  - `Supreme`: **11,987** units
  - `Veggie`: **11,649** units
  - `Chicken`: **11,050** units
- **Analyst Note:** Classic leads aggregate volume by a significant margin (+2,901 units over Supreme), driven by high-frequency purchases of Pepperoni and Hawaiian.

---

### Query 10: Number of Pizzas in Each Category
- **Original SQL:**
  ```sql
  SELECT category, COUNT(name) AS Total_pizza 
  FROM pizza_types 
  GROUP BY category 
  ORDER BY Total_pizza DESC;
  ```
- **Execution Result:**
  - `Veggie`: **9** pizza types
  - `Supreme`: **9** pizza types
  - `Classic`: **8** pizza types
  - `Chicken`: **6** pizza types
- **Senior Portfolio Insight (SKU Productivity):**
  - **Chicken:** Generates **$32,653.25 revenue per menu item** ($195.9K / 6 items) — the most efficient category.
  - **Classic:** Generates **$27,506.64 revenue per menu item** ($220.1K / 8 items).
  - **Supreme:** Generates **$23,133.00 revenue per menu item** ($208.2K / 9 items).
  - **Veggie:** Generates **$21,521.16 revenue per menu item** ($193.7K / 9 items).
  Veggie and Supreme carry larger menu footprints with lower revenue efficiency per SKU, suggesting opportunities for menu rationalization.

---

### Query 11: Total Revenue Month-Wise
- **Original SQL:**
  ```sql
  SELECT MONTHNAME(orders.date) AS month, ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_revenue 
  FROM orders 
  JOIN order_details ON orders.order_id = order_details.order_id
  JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
  GROUP BY month;
  ```
- **Execution Result (Engine Default Order):**
  | Month | Total Revenue |
  | :--- | :--- |
  | April | $68,736.80 |
  | August | $68,278.25 |
  | December | $64,701.15 |
  | February | $65,159.60 |
  | January | $69,793.30 |
  | July | $72,557.90 |
  | June | $68,230.20 |
  | March | $70,397.10 |
  | May | $71,402.75 |
  | November | $70,395.35 |
  | October | $64,027.60 |
  | September | $64,180.05 |
- **Senior Analyst Observation & Chronological Enhancement:**
  Because the original query grouped solely by `monthname(date)` without ordering by month integer, the output is sorted non-chronologically. In professional business reporting, time-series data should follow true chronological progression:
  ```sql
  -- Senior Analyst Recommended Chronological Query:
  SELECT 
      MONTH(orders.date) AS month_num,
      MONTHNAME(orders.date) AS month,
      ROUND(SUM(pizzas.price * order_details.quantity), 2) AS Total_revenue
  FROM orders 
  JOIN order_details ON orders.order_id = order_details.order_id
  JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
  GROUP BY month_num, month
  ORDER BY month_num ASC;
  ```
- **Chronological Revenue Progression:**
  - January: $69,793.30
  - February: $65,159.60 (shortest month)
  - March: $70,397.10
  - April: $68,736.80
  - May: $71,402.75
  - June: $68,230.20
  - **July: $72,557.90 (Annual Peak)**
  - August: $68,278.25
  - September: $64,180.05
  - **October: $64,027.60 (Annual Trough)**
  - November: $70,395.35
  - December: $64,701.15
- **Business Interpretation:**
  Sales remain exceptionally stable throughout the entire year, fluctuating within a tight band between $64,000 and $72,500 per month (standard deviation ~$2,900, ~4% coefficient of variation). July experiences peak summer demand, while late autumn (October) experiences a minor lull before bouncing back in November.

---

## 4. SQL Engine Compatibility Notes
- In MySQL 8.0+, `HOUR()`, `MONTH()`, `MONTHNAME()`, and `CONCAT()` are native functions.
- In SQLite, temporal functions are implemented via `strftime('%H', time)` and `strftime('%m', date)`. For full cross-engine testing, Python's SQLite wrapper was augmented with registered helper functions to execute the exact MySQL queries without modification.
