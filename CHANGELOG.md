# Changelog

All notable changes to the **Very Simple Diary** project will be documented in this file.

---

## [1.2.0] - 2026-06-18

### Added
- **History and Modifications Screen (`HistoryScreen`)**: 
  - Decoupled the modification and deletion flow from the main dashboard into a dedicated screen.
  - Includes quick-filter chips for status (`All`, `Drafts`, `Finalized`).
  - Added horizontal carousel to inspect responses and comments for a highlighted day.
  - Confirmation popups for editing (reverts to `draft`, updates Firestore, and opens questionnaire) and deleting (cascades database deletes and removes Firestore document).
- **Explorer Screen Enhancements**:
  - Integrated three horizontally scrollable carousels for trend analysis over a custom date range:
    1. **Theme Stats**: Trend indicators for the 6 primary categories (Health, Diet, Mental, etc.).
    2. **Sub-Theme / Question Stats**: Score evolution for all 24 individual questions.
    3. **Time of Day Stats**: Breakdown by periods (Nuit, Matin, Après-midi, Soir).
  - Toggles between **Mean** and **Median** calculations dynamically.
  - Combined filters for status and level.
- **Horizontal Swipe Navigation**: Added swipe gestures in `DiaryScreen` (Swipe Left to go to next question/recap, Swipe Right to return to previous question) to ease one-handed usage.

### Fixed
- **E2E Integration Tests**:
  - Resolved headless Chrome testing failures by ensuring the "Valider la journée" button is scrolled into view (`tester.ensureVisible`) before clicking.
  - Aligned all selectors and expected text labels to match the renamed buttons (e.g. `'Exploration'`) and periods (e.g. `'Nuit (00h-05h)'`).
- **Dart Analyzer Cleanliness**: Removed an unnecessary non-null assertion (`!`) on `_firestore` reference within `SyncRepository.deleteDay` which was causing CI lint stage failures.
