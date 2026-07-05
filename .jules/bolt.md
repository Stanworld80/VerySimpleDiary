## 2024-06-25 - Drift SQLite Foreign Key Indexing
**Learning:** Drift SQLite does not automatically index foreign key columns. This can lead to full table scans and performance bottlenecks on frequently queried relationships.
**Action:** Always add `@TableIndex` annotations to foreign key fields when defining Drift tables, especially if those fields are used in joins or lookups. Bump the `schemaVersion` and use `migrator.createIndex(indexName)` during `onUpgrade`.
