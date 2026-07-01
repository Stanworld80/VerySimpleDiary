## 2024-05-18 - Unindexed Foreign Keys in Drift SQLite
**Learning:** In Drift SQLite, foreign keys (like `references()`) are not automatically indexed. This leads to full table scans during joins or cascade deletes on relationships.
**Action:** Use the `@TableIndex` annotation on frequently queried foreign key columns, then bump `schemaVersion` and add `await migrator.createIndex(...)` in the `onUpgrade` step of `MigrationStrategy`.
