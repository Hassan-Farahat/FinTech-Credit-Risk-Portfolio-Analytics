--Database Schema Creation

-- Create the FinTech Risk Database
CREATE DATABASE FinTechRiskAnalytics;
GO

USE FinTechRiskAnalytics;
GO

-- Borrowers Dimension
CREATE TABLE Dim_Borrowers (
    borrower_id INT PRIMARY KEY,
    borrower_name VARCHAR(100),
    employment_status VARCHAR(50),
    annual_income DECIMAL(12,2),
    credit_score INT
);

-- Loan Products Dimension
CREATE TABLE Dim_LoanProducts (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    interest_rate DECIMAL(5,2),
    max_loan_amount DECIMAL(12,2)
);

-- Loan Applications & Performance Fact Table
CREATE TABLE Fact_Loans (
    loan_id INT PRIMARY KEY,
    borrower_id INT FOREIGN KEY REFERENCES Dim_Borrowers(borrower_id),
    product_id INT FOREIGN KEY REFERENCES Dim_LoanProducts(product_id),
    loan_amount DECIMAL(12,2),
    issue_date DATE,
    loan_status VARCHAR(30), -- 'Current', 'Defaulted', 'Paid Off'
    debt_to_income_ratio DECIMAL(5,2)
);


--Data Ingestion

-- Insert Loan Products
INSERT INTO Dim_LoanProducts VALUES 
(1, 'Personal Loan - Standard', 11.50, 25000.00),
(2, 'Business Growth Loan', 8.25, 100000.00),
(3, 'Quick Cash Advance', 18.00, 5000.00);

-- Insert Borrowers
INSERT INTO Dim_Borrowers VALUES 
(101, 'David Miller', 'Employed', 75000.00, 710),
(102, 'Amanda White', 'Self-Employed', 120000.00, 650),
(103, 'James Wilson', 'Employed', 48000.00, 590),
(104, 'Jessica Taylor', 'Employed', 95000.00, 740),
(105, 'Brian Martinez', 'Unemployed', 32000.00, 540);

-- Insert Loan Records
INSERT INTO Fact_Loans VALUES 
(5001, 101, 1, 15000.00, '2025-03-10', 'Current', 0.22),
(5002, 102, 2, 50000.00, '2025-05-15', 'Defaulted', 0.45),
(5003, 103, 3, 4000.00, '2025-08-01', 'Defaulted', 0.52),
(5004, 104, 1, 20000.00, '2025-10-12', 'Paid Off', 0.18),
(5005, 105, 3, 3000.00, '2026-01-20', 'Defaulted', 0.60),
(5006, 101, 2, 80000.00, '2026-02-14', 'Current', 0.25);


--FinTech Credit Risk & Portfolio Queries

-- ============================================================================
-- QUERY 1: Portfolio Exposure & Default Rate by Loan Product
-- Business Goal: Measure total capital lent and default exposure per credit product.
-- ============================================================================

SELECT 
    p.product_name,
    p.interest_rate,
    COUNT(l.loan_id) AS total_loans_issued,
    SUM(l.loan_amount) AS total_capital_lent,
    -- Calculate Default Count
    SUM(CASE WHEN l.loan_status = 'Defaulted' THEN 1 ELSE 0 END) AS total_defaults,
    -- Calculate Portfolio Default Rate Percentage
    ROUND((SUM(CASE WHEN l.loan_status = 'Defaulted' THEN 1.0 ELSE 0.0 END) / COUNT(l.loan_id)) * 100, 2) AS default_rate_pct
FROM Fact_Loans l
JOIN Dim_LoanProducts p ON l.product_id = p.product_id
GROUP BY p.product_name, p.interest_rate
ORDER BY total_capital_lent DESC;


-- ============================================================================
-- QUERY 2: Borrower Risk Tier Segmentation based on Credit Score & DTI
-- Business Goal: Classify borrowers into risk categories to establish automated lending thresholds.
-- ============================================================================

SELECT 
    b.borrower_name,
    b.credit_score,
    l.debt_to_income_ratio,
    l.loan_amount,
    l.loan_status,
    -- Define dynamic risk category using conditional logic
    CASE 
        WHEN b.credit_score >= 700 AND l.debt_to_income_ratio <= 0.30 THEN 'Low Risk'
        WHEN b.credit_score BETWEEN 600 AND 699 AND l.debt_to_income_ratio <= 0.45 THEN 'Medium Risk'
        ELSE 'High Risk / Subprime'
    END AS risk_tier
FROM Fact_Loans l
JOIN Dim_Borrowers b ON l.borrower_id = b.borrower_id
ORDER BY b.credit_score DESC;


-- ============================================================================
-- QUERY 3: High-Value Loan Ranking by Borrower Income & Risk (Window Functions)
-- Business Goal: Rank loans within each employment category by capital amount using window functions.
-- ============================================================================

WITH Borrower_Risk_Profile AS (
    SELECT 
        b.borrower_id,
        b.borrower_name,
        b.employment_status,
        b.annual_income,
        l.loan_amount,
        l.loan_status,
        l.debt_to_income_ratio
    FROM Dim_Borrowers b
    JOIN Fact_Loans l ON b.borrower_id = l.borrower_id
)
SELECT 
    borrower_name,
    employment_status,
    annual_income,
    loan_amount,
    loan_status,
    debt_to_income_ratio,
    -- Rank loan amounts partitioned by employment status using a window function
    DENSE_RANK() OVER (PARTITION BY employment_status ORDER BY loan_amount DESC) AS loan_size_rank_per_employment
FROM Borrower_Risk_Profile
ORDER BY employment_status, loan_size_rank_per_employment;