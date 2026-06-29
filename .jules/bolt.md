## 2024-05-24 - Foreign Key Indexes in Drift
**Learning:** In Drift SQLite, foreign key columns are not automatically indexed. This can lead to full table scans when querying child tables by their parent's ID.
**Action:** Use `@TableIndex` annotations on frequently queried foreign key relationships and bump the `schemaVersion` in `LocalDatabase`. Always use the generated index object from the `.g.dart` file (e.g., `await migrator.createIndex(diaryResponsesDiaryDayIdIdx);`) during migrations rather than passing strings.
