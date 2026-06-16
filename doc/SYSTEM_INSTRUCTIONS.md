# SYSTEM INSTRUCTIONS FOR AI CODING ASSISTANTS

You are an expert AI agent assisting in the development and maintenance of **Very Simple Diary**. You must strictly adhere to the following development, testing, and CI/CD strategy.

---

## 1. Principles of Test-Driven Development (TDD)
When implementing any new feature, bug fix, or business logic, follow the **Red-Green-Refactor** cycle:
1. **RED**: Write a failing test in the appropriate test suite (Flutter unit/widget tests, Firestore rules tests, or MCP server tests). Run it and verify it fails.
2. **GREEN**: Write the minimal code required to make the test pass.
3. **REFACTOR**: Clean up the code, improve styling, remove duplication, and optimize while keeping all tests passing.

---

## 2. Testing Strategy & Scope

### 2.1. Flutter Unit & Limit Tests
* **Location**: `test/`
* **Command**: `flutter test`
* **Requirements**:
  - Test boundary values (minimum `-2`, maximum `+2`).
  - Test performance boundaries with large datasets (at least 10,000 to 100,000 entries) to prevent CPU bottlenecks on slow devices.
  - Test edge cases: empty list, invalid values, null inputs.
  - Test Riverpod controllers using mocks for external services/repositories.

### 2.2. Firestore Security Rules Tests
* **Location**: `test/firestore_rules_test/`
* **Command**: `npm run test` (inside directory, requires Firestore Emulator running)
* **Requirements**:
  - Unauthenticated reads and writes to user data must be rejected.
  - Authenticated users must be able to read and write only their own documents under `/users/{userId}/...`.
  - Authenticated users must be blocked from reading or writing to other users' directories.

### 2.3. MCP Server Tests
* **Location**: `mcp_server/test/`
* **Command**: `npm run test` (inside `mcp_server/`)
* **Requirements**:
  - Validate that resources (`diary://daily/{date}`, `diary://themes/trends`, `diary://schema/questions`) return the exact correct JSON or Markdown schema.
  - Test tools (`get_diary_insights`, etc.) with valid/invalid parameters to ensure correct output and proper error handling.

### 2.4. Integration / E2E Tests
* **Location**: `integration_test/`
* **Command**: `flutter test integration_test/app_e2e_test.dart`
* **Requirements**:
  - Simulate the full human user journey: Login -> Question loop (24 steps) -> Summary/Validation -> Verification of scores and levels.
  - Integration tests must run in headless Chrome mode in CI/CD.

---

## 3. CI/CD Architecture Guidelines
Do not bundle everything into a single monolith CI/CD job. You must separate the jobs into parallel, dependent stages to fail fast:
1. **Parallel Test Stage**:
   - `test-mcp-server` (Compiles TypeScript & runs Mocha tests).
   - `test-firestore-rules` (Runs firebase rules tests against the emulator).
   - `test-flutter-unit-widget` (Runs `flutter analyze` and `flutter test`).
2. **Dependent Build & Deploy Stage**:
   - `build-and-deploy-web` (Compiles Flutter web and deploys to Firebase Hosting, runs *only* if all tests pass).
   - `build-android` (Compiles Android release build, runs if Flutter unit tests pass).
3. **E2E Integration Test Stage**:
   - `integration-test-e2e` (Runs after `build-and-deploy-web` finishes successfully).
4. **Smoke Test Stage**:
   - `post-deploy-smoke-test` (Performs HTTP status checks on the deployed app).
