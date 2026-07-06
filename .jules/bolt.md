## 2024-05-18 - Missing Foreign Key Indexes in Drift
**Learning:** In Drift SQLite, foreign key columns are not automatically indexed. Queries and cascading deletes relying on unindexed foreign keys (like `diaryDayId` in `DiaryResponses`) result in full table scans, becoming a performance bottleneck as the table grows.
**Action:** Always add `@TableIndex` annotations to frequently queried foreign key relationships to prevent full table scans and remember to run `build_runner` and bump `schemaVersion` with a create index migration.
