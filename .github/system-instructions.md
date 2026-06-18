# System Instructions for AI Agents (Vibe Coding Guide)

This document contains standard instructions, architectural patterns, and development guidelines for AI coding assistants working on **Very Simple Diary**. Always adhere to these principles when modifying the codebase.

---

## 1. Dual-Engine Architecture & Shared Context

Very Simple Diary operates under a **Dual-Engine** architecture that shares a local-first context between a human UI and an agentic protocol.

```
       [ Human IHM (Flutter UI) ]          [ Agentic IHM (MCP Server) ]
                   \                                    /
                    \                                  /
                     v                                v
                 [ Shared SQLite Database (diary.db) ]
                                 |
                                 v
                     [ Firestore Async Sync ]
```

### 1.1 Presentation Engine (Human UI)
* Built using **Flutter** (Web & Android).
* Uses **Riverpod** for state management under a **Feature-First** structure:
  * `/lib/features/auth/` - Authentication screens and credentials repository.
  * `/lib/features/diary/` - Questionnaire flow (Q1-Q24), History list, and Explorer dashboard.
  * `/lib/core/` - Theme tokens, database setup, and common UI elements.
* Relies on **Drift** for the SQLite database abstraction.

### 1.2 Agentic Engine (CaaS via MCP)
* Built using **TypeScript/Node.js** in `/mcp_server`.
* Exposes resources, tools, and prompts using Anthropic's **Model Context Protocol (MCP)**.
* **Shared Database Pattern**: Both the Node.js MCP server and the Flutter app read and write directly to the same local SQLite database file (`diary.db`). Changes made by one engine are immediately visible to the other.

---

## 2. Context Exploitation (Finding Data & Structures)

* **Question Definitions**: The 24 questions are loaded dynamically from `assets/questions.yaml`. Do not hardcode questions in the Dart codebase.
* **Database Schema**: Defined in `lib/core/db/local_database.dart` (tables: `DiaryDays` and `DiaryResponses`).
  * If the schema is modified, run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`.
* **Sync Layer**: Controlled by `SyncRepository` (`lib/features/diary/repository/sync_repository.dart`). It handles two-way background synchronization between local SQLite and Firebase Firestore.
  * Firestore document path: `/users/{userId}/diary_days/{date}`.

---

## 3. Styling & UX Design Guidelines

Always maintain the premium, modern aesthetic of the application:
* **Theme System**: Custom dark mode defined in [app_theme.dart](file:///d:/development/VerySimpleDiary/lib/core/theme/app_theme.dart).
  * Card backgrounds: `AppTheme.darkCard` (`Color(0xFF1E2030)`).
  * Borders: `Color(0xFF2E3047)`, width `1.5`.
  * Grid selection circles use `AppTheme.primary.withValues(alpha: 0.2)` when active.
* **Version Footer**: Every main screen must display the version and deploy metadata at the bottom using the `VersionFooter()` widget.
* **Header & Profile**: Include the `ProfileMenuButton()` in AppBars or user profile areas.
* **Animations**: All transitions and state changes (such as selecting a rating or swiping questions) must use subtle, smooth animations (e.g. `AnimatedContainer` with `150ms` duration).

---

## 4. Testing & CI/CD Strategy

### 4.1 Pyramide of Tests
* **Flutter Unit & Widget Tests** (`test/`): Validates math utilities (ScoreCalculator limits, bounds), controllers, and state notifications. Run via `flutter test`.
* **Firestore Rules Tests** (`test/firestore_rules_test/`): Runs security rules tests against Firestore Local Emulator. Run via `npm run test` inside the rules directory.
* **MCP Server Contract Tests** (`mcp_server/test/`): Validates schema and tool contract compliance. Run via `npm run test` inside the mcp_server directory.
* **Web E2E Integration Tests** (`integration_test/`): Simulates complete user journey in headless Chrome. Run via:
  `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_e2e_test.dart -d web-server`

### 4.2 Critical E2E Test Gotchas
* **Scroll Visibility**: Because E2E tests run in a headless browser with a restricted viewport height (800x600), widgets inside scroll views (like the "Valider la journée" button in `SummaryScreen`) may render off-screen. **Always scroll widgets into view using `tester.ensureVisible()` before tapping them.**
* **Swipe Navigation**: The E2E tests support horizontal drag gestures. Use `tester.fling(finder, offset, speed)` to simulate swipes for page navigation.

---

## 5. MCP Server Protocol Reference

### 5.1 Resources
* `diary://daily/{date}`: Returns markdown content of the day's answers and insights.
* `diary://themes/trends?days={N}`: Returns theme score trends over the last $N$ days.
* `diary://schema/questions`: Returns list of the 24 questions.

### 5.2 Tools
* `get_diary_insights`: Parameters: `startDate`, `endDate`. Analyzes correlations.
* `save_draft_response`: Parameters: `date`, `questionId`, `period`, `ratings`.
* `finalize_diary_day`: Parameters: `date`. Locks the daily entry.
