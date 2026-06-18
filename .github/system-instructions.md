# System Instructions for AI Agents (Vibe Coding Guide)

This document contains standard instructions, architectural patterns, and development guidelines for AI coding assistants working on **Very Simple Diary**. Always adhere to these principles when modifying the codebase.

---

## 1. Vibe Coding Philosophy & Core Principles

Vibe coding on this project requires high speed, autonomous decision-making, and strong reliance on tests for verification.
* **TDD (Red-Green-Refactor)**: When adding/altering logic, write a test first, verify failure, write the minimal code to pass, and refactor.
* **Zero Disruption / Premium Aesthetic**: Avoid basic, unstyled elements. Use curated dark mode components and glassmorphism.
* **No Interactivity Blocks**: All command executions must run non-interactively.

---

## 2. Context Exploitation (Finding Data & Structures)

Use the following guidelines to quickly locate relevant definitions, schemas, and specifications:

### 2.1 Documentation & Specification Index
* **Functional & Technical Specs**: Detailed in [specifications.md](file:///d:/development/VerySimpleDiary/doc/specifications.md). Contains screen-by-screen layouts, scoring rules, and swipe logic.
* **Testing Guidelines**: Described in [TESTING.md](file:///d:/development/VerySimpleDiary/doc/TESTING.md) and [SYSTEM_INSTRUCTIONS.md](file:///d:/development/VerySimpleDiary/doc/SYSTEM_INSTRUCTIONS.md).
* **Changelog**: Documented in [CHANGELOG.md](file:///d:/development/VerySimpleDiary/CHANGELOG.md).

### 2.2 Question Configuration
* **Dynamic Questions**: Grouped into 6 categories (24 questions total), defined in [questions.yaml](file:///d:/development/VerySimpleDiary/assets/questions.yaml).
  * **Themes**:
    1. *Santé, Sport & Sommeil* (Q1-Q4)
    2. *Alimentation* (Q5-Q8)
    3. *Psychisme* (Q9-Q12)
    4. *Hygiène & Ménage* (Q13-Q16)
    5. *Admin & Finances* (Q17-Q20)
    6. *Relations & Famille* (Q21-Q24)
* **Rule**: Do not hardcode question text or order in Dart files. Load dynamically via YAML.

### 2.3 Database Schema & Persistence
* **Drift Local Database**: Schema is defined in [local_database.dart](file:///d:/development/VerySimpleDiary/lib/core/db/local_database.dart).
  * `DiaryDays` table maps to SQLite table `diary_days` (stores status, scores, stats, insights).
  * `DiaryResponses` table maps to SQLite table `diary_responses` (stores question ratings and comments).
* **Schema Upgrade / Build Runner**:
  * Run build runner when schema changes: `flutter pub run build_runner build --delete-conflicting-outputs`.
* **Database Locations**:
  * **Flutter Native (Android/Windows)**: Stores database in standard app documents directory: `diary.db`.
  * **MCP Server**: Can be configured using the `DIARY_DB_PATH` environment variable. Defaults to `../db/diary.db` (usually matched to a shared SQLite location).

### 2.4 State Management & Controllers
* **Diary Controller**: Located in [diary_controller.dart](file:///d:/development/VerySimpleDiary/lib/features/diary/controller/diary_controller.dart). Uses Riverpod state notifiers to cache draft answers, calculate scores using `ScoreCalculator`, and invoke `SyncRepository`.
* **Sync Repository**: Located in [sync_repository.dart](file:///d:/development/VerySimpleDiary/lib/features/diary/repository/sync_repository.dart). Handshakes local SQLite changes with Firestore document paths under `/users/{userId}/diary_days/{date}`.

---

## 3. Styling & UX Design Guidelines

Always maintain the premium, modern aesthetic of the application:
* **Theme System**: Custom dark mode defined in [app_theme.dart](file:///d:/development/VerySimpleDiary/lib/core/theme/app_theme.dart).
  * Card backgrounds: `AppTheme.darkCard` (`Color(0xFF1E2030)`).
  * Card Borders: `Color(0xFF2E3047)`, width `1.5`.
  * Grid selection circles use `AppTheme.primary.withValues(alpha: 0.2)` when active.
* **Standard Page Elements**:
  * **Version Footer**: Every main screen must display the version and deploy metadata at the bottom using the `VersionFooter()` widget.
  * **Header & Profile**: Include the `ProfileMenuButton()` in AppBars or user profile areas.
* **Micro-Animations**: All transitions and state changes (such as selecting a rating or swiping questions) must use subtle, smooth animations (e.g. `AnimatedContainer` with `150ms` duration).
* **Text Length Validation**: Period comments are capped at **64 characters**. The notifier must truncate any comment beyond this:
  `comment.length > 64 ? comment.substring(0, 64) : comment`.

---

## 4. Tools & MCP Server Architecture (Model Context Protocol)

The project includes an **Agentic Engine** built as a local MCP server that shares the SQLite database with the Flutter app.

### 4.1 MCP Server Location & Setup
* **Source Directory**: `/mcp_server`. Written in TypeScript.
* **Shared Database Pattern**: Both the Node.js MCP server and the Flutter app read and write directly to the same local SQLite database file (`diary.db`). Changes made by one engine are immediately visible to the other.

### 4.2 Resource Definitions
Agents query the following standard resources:
* `diary://daily/{date}`: Returns markdown content of the day's answers, scores, and insights.
* `diary://themes/trends?days={N}`: Returns theme score trends over the last $N$ days.
* `diary://schema/questions`: Returns the list of the 24 questions in JSON.

### 4.3 Tool Protocol
Agents use these tools to inspect or assist the user:
* `get_diary_insights`: Analyzes correlations between sleep (Q1), physical activity (Q2), late screens (Q20), and mood (Q10).
* `save_draft_response`: Saves ratings and comments dynamically (assisting via audio or conversational chat).
* `finalize_diary_day`: Finalizes the scores and locks the day.

---

## 5. Testing & CI/CD Strategy

### 5.1 Pyramide of Tests
1. **Flutter Unit & Widget Tests** (`test/`): Validates math utilities (ScoreCalculator limits, bounds), controllers, and state notifications. Run via `flutter test`.
2. **Firestore Rules Tests** (`test/firestore_rules_test/`): Runs security rules tests against Firestore Local Emulator. Run via `npm run test` inside the rules directory.
3. **MCP Server Contract Tests** (`mcp_server/test/`): Validates schema and tool contract compliance. Run via `npm run test` inside the mcp_server directory.
4. **Web E2E Integration Tests** (`integration_test/`): Simulates complete user journey in headless Chrome. Run via:
   `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_e2e_test.dart -d web-server`

### 5.2 Critical E2E Test Gotchas
* **Scroll Visibility (Mandatory)**: Because E2E tests run in a headless browser with a restricted viewport height (800x600), widgets inside scroll views (like the "Valider la journée" button in `SummaryScreen`) may render off-screen. **Always scroll widgets into view using `tester.ensureVisible()` before tapping them.**
* **Swipe Navigation**: The E2E tests support horizontal drag gestures. Use `tester.fling(finder, offset, speed)` to simulate swipes for page navigation:
  * Swipe Left (Next): `tester.fling(finder, const Offset(-200, 0), 1000)`
  * Swipe Right (Prev): `tester.fling(finder, const Offset(200, 0), 1000)`

### 5.3 CI/CD Structure
To prevent slow pipeline feedback, workflows are split:
1. **Job 1 (test-mcp-server)**: TypeScript linting and unit tests.
2. **Job 2 (test-firestore-rules)**: Security rules testing against local emulator.
3. **Job 3 (test-flutter-unit-widget)**: Flutter analyze and unit testing.
4. **Job 4 (build-and-deploy-web)**: Runs only if Jobs 1, 2, and 3 pass. Deploys to Firebase Hosting.
5. **Job 5 (build-android)**: Compiles Android APK in parallel.
6. **Job 6 (integration-test-e2e)**: Runs headless Chrome E2E test against the deployed web-server.
7. **Job 7 (post-deploy-smoke-test)**: Runs a final curl status check.
