## 2024-06-13 - Drift SQLite Foreign Key Performance

**Learning:** Drift does not automatically index foreign keys, leading to full table scans when performing joins or looking up related rows. Our typical query pattern uses `diary_day_id` extensively to group responses.
**Action:** Always add `@TableIndex(name: 'table_col_idx', columns: {#colName})` on foreign key columns that are frequently queried to prevent O(N) full table scans and improve lookup to O(log N). Bump `schemaVersion` and add an `onUpgrade` step using `migrator.createIndex(generatedIndexObject)` when adding indexes to existing tables.
