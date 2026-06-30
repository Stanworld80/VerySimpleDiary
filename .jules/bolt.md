## 2024-11-28 - Drift SQLite Foreign Key Indexing
**Learning:** In Drift SQLite, foreign key columns are not automatically indexed. This leads to full table scans when querying child records (like diary responses) by their parent ID.
**Action:** Always add `@TableIndex` annotations on frequently queried foreign key relationships in Drift models to ensure efficient lookups as the database size grows.
