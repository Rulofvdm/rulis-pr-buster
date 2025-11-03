# Changelog Entry

## Added

### Unified PR Status Display System
- **Single prioritized status indicator** displayed after each PR name in the menu
- **Status precedence order** ensures the most important status is shown:
  1. Build validation expired (RED)
  2. Build validation failed (RED) - with specific failure reasons
  3. Unresolved comments (RED) - shows count
  4. Checks running (BLUE)
  5. Waiting for reapproval (ORANGE)
  6. Waiting for approval (ORANGE)
  7. Ready for completion (GREEN)

### Azure DevOps API Integrations
- **Status Checks API** integration for real-time check states
- **Policy Evaluations API** integration for build and reviewer policies
  - Build validation state tracking (approved/rejected/queued/running)
  - Reviewers policy state tracking
  - Build expiration detection
  - Build failure reason extraction
- **Unresolved Comments API** integration for active comment thread counts

### Build Failure Reason Detection
- Automatic detection of "Branch behind check" build failures
- Displays user-friendly message: "Build validation failed: branch behind check"
- Parses failure reasons from build output preview data

### Architecture Improvements
- **PRMenuItemViewModel** pattern for managing dynamic UI state
  - Separates immutable PR data from mutable status information
  - Centralized status precedence logic
  - Tracks build state, comment counts, policy states, and failure reasons

### UI Enhancements
- **Color-coded status indicators**:
  - 🔴 RED: Failures, errors, unresolved items
  - 🔵 BLUE: In-progress operations
  - 🟠 ORANGE: Waiting for user action
  - 🟢 GREEN: Ready state
- **Dynamic status updates** as async API data arrives
- **Status positioning** after PR title for better visibility

## Technical Details

- Resilient JSON parsing handles varying Azure DevOps API response formats
- Graceful error handling for missing API fields
- Debug logging for troubleshooting API integration issues
- Async status fetching with proper main thread UI updates
- No breaking changes - pure feature addition

