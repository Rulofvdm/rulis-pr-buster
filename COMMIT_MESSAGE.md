# Commit Message

```
feat: Add unified PR status display system with prioritized status indicators

Implement a comprehensive status display system that shows a single, prioritized
status for each Pull Request in the menu bar application. The system integrates
with Azure DevOps APIs to fetch real-time status information and displays
color-coded indicators based on PR state.

## Features Added

### 1. Unified Status Display System
- Display single prioritized status per PR after the PR name
- Status updates dynamically as data is fetched asynchronously
- Status positioned inline with PR title for better visibility

### 2. Status Precedence Logic (Highest to Lowest)
1. **Build validation expired** (RED) - When build policy is expired
2. **Build validation failed** (RED) - With specific failure reason support
   - Special handling for "Branch behind check" failures
   - Displays detailed message: "Build validation failed: branch behind check"
3. **Unresolved comments** (RED) - Shows count of active comment threads
4. **Checks running** (BLUE) - When build/status checks are in progress
5. **Waiting for reapproval** (ORANGE) - When reviewers policy rejected or 
   any reviewer vote is waitingForAuthor/rejected
6. **Waiting for approval** (ORANGE) - When reviewers policy queued or 
   approval count < 2
7. **Ready for completion** (GREEN) - Build succeeded, 2+ approvals, 
   no unresolved comments

### 3. Azure DevOps API Integrations
- **Status Checks API**: Fetch real-time status check states
  - Resilient JSON parsing for varying API response formats
  - Handles missing/optional fields gracefully
  
- **Policy Evaluations API**: Comprehensive build and reviewer policy status
  - Extracts build validation state (approved/rejected/queued/running)
  - Tracks reviewers policy state (queued/approved/rejected)
  - Detects build expiration status
  - Parses build failure reasons from buildOutputPreview
  
- **Unresolved Comments API**: Count active comment threads
  - Real-time comment count updates
  - Integrated into status precedence logic

### 4. Build Failure Reason Detection
- Parses `buildOutputPreview` from Build policy evaluations
- Detects "Branch behind check" failures by checking:
  - `jobName` field
  - `taskName` field
  - Error messages in `errors` array
- Only extracted when build status is "rejected"
- Displays user-friendly message: "Build validation failed: branch behind check"

### 5. Architecture Improvements
- **PRMenuItemViewModel**: Introduced view model pattern for managing mutable
  UI state per PR menu item
  - Separates immutable PullRequest struct from dynamic UI state
  - Centralized status precedence logic in `unifiedStatus` computed property
  - Tracks: build state, comment counts, policy states, expiration, failure reasons

### 6. UI Enhancements
- Color-coded status indicators:
  - RED: Failures and errors (build failed, expired, unresolved comments)
  - BLUE: In-progress checks
  - ORANGE: Waiting states (approval/reapproval needed)
  - GREEN: Ready for completion
- Dynamic status label updates as async data arrives
- Status text formatted with proper prefixes ("Build validation failed: ...")

## Technical Details

### New Files
- `PRBuster/PullRequests/PRMenuItemViewModel.swift`: View model for PR menu items

### Modified Files
- `PRBuster/PullRequests/Networking/PullRequestService.swift`:
  - Added `fetchStatusChecks()` for status check API
  - Added `fetchPolicyEvaluationsSummary()` for policy evaluation API
  - Enhanced JSON parsing with resilient error handling
  - Added debug logging for API responses
  
- `PRBuster/PullRequests/MenuBuilder.swift`:
  - Integrated async status fetching and updates
  - Orchestrates multiple API calls per PR
  - Updates UI on main thread after each async completion
  
- `PRBuster/PullRequests/PullRequestModels.swift`:
  - Added `PRUnifiedStatus` enum with all status types
  - Added `ReviewersPolicyState` enum
  - Added `PolicySummary` struct for aggregated policy data
  
- `PRBuster/PRMenuItemView.swift`:
  - Added `updateStatus(text:color:)` method for dynamic updates
  - Added support for orange color in status display
  - Status label positioned after PR title

### API Integration Details
- Uses Azure DevOps REST API v7.1-preview for policy evaluations
- Handles both wrapped `{value: [...]}` and top-level array JSON formats
- Graceful degradation when API responses have missing fields
- Debug logging for troubleshooting API response issues

## Testing Recommendations
- Verify status precedence order is correct
- Test "Branch behind check" failure detection
- Verify async status updates don't cause race conditions
- Test all color states display correctly
- Verify expired build detection works

## Breaking Changes
None - this is a feature addition that enhances existing functionality.
```

