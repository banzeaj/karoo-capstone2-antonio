# Karoo Organics Supplier Auditor

## Overview

This project automates supplier compliance monitoring for Karoo Organics.

The solution identifies suppliers that may present operational,
regulatory, or reputational risk and automatically flags them for review.

## Files

- auditor_views.sql
  - Creates the supplier health monitoring view
  - Contains the risk-identification query

- audit_suppliers.py
  - Executes the risk query
  - Updates supplier status to 'Review'
  - Commits changes to the database

- test_data.sql
  - Sample data for testing the solution

## Risk Logic

A supplier is flagged when any of the following conditions are met:

1. Certification expires within 30 days.
2. No orders have been placed in the last 90 days.
3. Latest harvest yield is less than 80% of the rolling average of the last three harvests.

## Compliance Considerations

The automated audit process helps:

- Maintain supplier certification compliance.
- Detect disengaged suppliers.
- Identify declining agricultural performance.
- Reduce operational and regulatory risk.
- Provide an auditable review process.

## Error Handling

The Python script:

- Uses parameterised SQL updates.
- Commits successful transactions.
- Rolls back changes when errors occur.
- Handles database connection failures gracefully.
