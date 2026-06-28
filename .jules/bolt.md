## 2024-05-30 - [Drift SQLite Foreign Key Indexes]
**Learning:** Drift SQLite does not automatically index foreign key columns, causing full table scans on relational lookups (like querying DiaryResponses by diaryDayId).
**Action:** Always use `@TableIndex` annotations and create indexes during schema migrations when adding foreign key relationships.
