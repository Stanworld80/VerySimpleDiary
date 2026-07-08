## 2024-05-18 - [Add TableIndex on Drift]
**Learning:** In Drift SQLite, foreign key columns are not automatically indexed.
**Action:** Use `@TableIndex` annotations on frequently queried foreign key relationships to prevent full table scans.
