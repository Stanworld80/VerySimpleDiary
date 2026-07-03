## 2024-05-18 - Drift SQLite Foreign Key Indexing
**Learning:** In Drift SQLite, foreign key columns are not automatically indexed. This can lead to performance bottlenecks (full table scans) when querying child tables by their parent's ID.
**Action:** Use `@TableIndex` annotations on frequently queried foreign key relationships (e.g., `diary_day_id` in `DiaryResponses`). When writing Drift migrations for new indexes, bump the `schemaVersion` and use the generated index object from the `.g.dart` file (e.g., `await migrator.createIndex(diaryResponsesDiaryDayIdIdx);`).
