# restaurant-database-plsql
A comprehensive Oracle PL/SQL Relational Database for restaurant management, featuring automated order tracking, inventory optimization, and state-wide financial reporting structures.

# Restaurant Management & Business Intelligence Database System

A enterprise-grade relational database architecture engineered from scratch using Oracle PL/SQL. The system optimizes end-to-end restaurant operations, including cross-restaurant inventory control, dynamic waitstaff performance auditing, automated customer recommendation engines, and analytical multi-state revenue calculations.

## Tech Stack & Language Dialect
* **Database Engine:** Oracle Database (SQL & PL/SQL)
* **Core Concepts:** Relational Schema Design, Integrity Constraints, Sequences, Stored Procedures, Aggregations, Window Functions, Cursor Loops, and Exception Handling.

---

## Database Schema Architecture

The relational structure consists of 9 normalized, interconnected tables to maintain strict data integrity:

* **CuisineTypes & Restaurants:** Core foundation establishing locations and regional food categorization.
* **Waiters & Customers:** Tracking human resource allocation and user profiles.
* **MenuItems & Inventory:** Connecting products to available quantities across distinct restaurant locations with safety constraints preventing negative stock counts.
* **Orders, Reviews, & Recommendations:** High-transaction entities logging active business performance and analytical data metrics.

---

## Key Feature Implementations & Business Logic

The system moves beyond basic CRUD operations by leveraging advanced stored PL/SQL procedures to handle complex workflows:

### 1. Automated Transaction Processing (`PLACE_ORDER`)
Coordinates multiple sub-systems simultaneously when an order occurs:
* Dynamically fetches current item pricing.
* Calculates a standard 20% waitstaff tip using numeric rounding math.
* Automatically verifies stock limits and passes execution downstream to securely decrement inventory counts via internal program hooks.

### 2. State-by-State Analytics Engine (`BEST_RESTAURANTS`)
An analytical reporting feature utilizing specialized **Analytical Window Functions** (`ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ... DESC)`) to instantly partition and rank the top 3 highest-grossing restaurant establishments across every represented state.

### 3. Predictive Personalization Engine (`Recommend_To_Customer`)
An analytical suggestion query that matches a customer's requested cuisine profile against highly-rated restaurants in the local database, filtered via isolation criteria to completely exclude any restaurants the specific client has previously ordered from.

---

## 📂 Codebase File Directory
* `restaurant_schema.sql`: Complete comprehensive script containing drops, table declarations, foreign-key constraint mapping, sequential indexing, custom functions, and modular reporting procedures.

---
*Developed as a collaborative engineering project by Team 8.*
