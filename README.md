# FinTech Credit Risk & Loan Portfolio Analytics

## Executive Overview
This portfolio project models core financial risk and credit analytics metrics—including portfolio default rates, borrower risk tier segmentation, debt-to-income (DTI) exposure, and loan performance tracking. Designed using a relational Star Schema in SQL Server, it addresses lending risk and capital allocation decisions for digital finance platforms.

## Data Model Architecture
The database is structured around core operational entities:
- **Fact Tables:** `Fact_Loans`
- **Dimension Tables:** `Dim_Borrowers`, `Dim_LoanProducts`

## Key Business Insights & Analytical Output

### 1. Portfolio Default Exposure
- **Quick Cash Advance and Growth Loans** display elevated default rates due to aggressive interest structures or high-leverage profiles.
- Tracking total capital lent against active defaults isolates high-risk credit products.

### 2. Borrower Risk Tier Segmentation
- Combining credit scores with **Debt-to-Income (DTI)** ratios categorizes borrowers into actionable risk tiers (`Low Risk`, `Medium Risk`, `High Risk / Subprime`).
- Identifies vulnerable portfolios before repayment friction occurs.

### 3. Capital Ranking via Window Functions
- Utilizing partitioned window functions (`DENSE_RANK() OVER (PARTITION BY ...)`), loans are ranked by size within employment groups to monitor credit exposure across customer cohorts.

## Strategic Business Recommendations
1. **Underwriting Tightening:** Implement stricter automated DTI caps (under 0.35) for short-term high-interest credit lines.
2. **Tiered Pricing Models:** Adjust interest rates dynamically based on segmented borrower risk tiers to offset projected default loss provisions.