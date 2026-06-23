## 2024-05-24 - [SQLite Foreign Key Performance Bottleneck]
**Learning:** Found that Drift relational queries involving foreign keys without explicit indices (like `diaryDayId` in `DiaryResponses`) result in table scans. While fine for small datasets, this impacts querying history over time for frequent components like the Explorer screen charts.
**Action:** When adding foreign key relationships in Drift (`.references()`), always add a matching `@TableIndex` to prevent O(n) table scans on related data retrieval.
