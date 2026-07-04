## 2024-05-24 - Drift SQLite Foreign Key Indexing
**Learning:** In Drift SQLite, foreign key columns are not indexed automatically. Omitting indexes on frequently queried foreign key fields (like `diaryDayId` in `DiaryResponses`) can cause full table scans.
**Action:** When defining Drift tables, always remember to add `@TableIndex` annotations for frequently queried foreign keys, bump the `schemaVersion`, and add `migrator.createIndex` in the `onUpgrade` block.
