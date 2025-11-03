# Short Commit Message (for git commit)

```
feat: Add unified PR status display system with prioritized status indicators

Implement comprehensive status display system showing single prioritized status
per PR in menu bar. Integrates with Azure DevOps APIs for real-time status
updates with color-coded indicators.

Key Features:
- Status precedence: Build expired/failed → Unresolved comments → Checks running 
  → Waiting for approval/reapproval → Ready for completion
- Build failure reason detection (e.g., "Branch behind check")
- Color-coded indicators (RED/BLUE/ORANGE/GREEN)
- Dynamic async status updates via Policy Evaluations and Status Checks APIs
- PRMenuItemViewModel pattern for managing mutable UI state
- Resilient JSON parsing for Azure DevOps API variations

Status positioned after PR name with real-time updates as data is fetched.
```

