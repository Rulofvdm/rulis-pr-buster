# AGENTS.md

This document describes the AI agents and their roles in the PRBuster project. Each agent is responsible for specific aspects of the application's functionality and can be used to understand, modify, or extend the codebase.

## Core Application Agents

### 1. AppDelegate Agent
**Role**: Main application coordinator and state manager
**Responsibilities**:
- Application lifecycle management
- Status bar item management
- PR data state management (assigned and authored PRs)
- Error state handling
- Menu bar display updates
- Auto-refresh timer management
- Notification permission requests

**Key Capabilities**:
- Coordinates between all other components
- Manages application state and data flow
- Handles error states and recovery
- Controls refresh timing and data fetching
- Updates UI based on data changes

**Integration Points**:
- SettingsManager (for configuration)
- NotificationManager (for notifications)
- PullRequestService (for data fetching)
- MenuBuilder (for UI updates)

### 2. SettingsManager Agent
**Role**: Centralized configuration and persistence manager
**Responsibilities**:
- Settings storage and retrieval from UserDefaults
- Configuration validation and defaults
- Reactive updates to dependent components
- Backward compatibility with legacy settings
- Credential management and validation

**Key Capabilities**:
- Persistent settings storage
- Real-time configuration updates
- Settings validation and error handling
- Default value management
- Component integration through reactive updates

**Configuration Categories**:
- Azure DevOps credentials (email, PAT, organization, project)
- Display preferences (show authored/assigned PRs, auto-refresh, show short titles, show target branch)
- Notification settings (enabled, types, timing, smart features)

### 3. PullRequestService Agent
**Role**: Azure DevOps API integration specialist
**Responsibilities**:
- API authentication and request handling
- Data fetching for assigned and authored PRs
- Comment count retrieval for authored PRs
- Error handling for network and API failures
- JSON parsing and model conversion

**Key Capabilities**:
- Azure DevOps API integration
- Concurrent data fetching
- Error recovery and graceful degradation
- Data filtering and processing
- Authentication management

**API Endpoints**:
- Assigned PRs: `/git/pullrequests?searchCriteria.reviewerId=me&status=active`
- Authored PRs: `/git/pullrequests?searchCriteria.creatorId=me&status=active`
- Comment counts: `/git/repositories/{repoId}/pullRequests/{prId}/threads`

### 4. NotificationManager Agent
**Role**: Smart notification system coordinator
**Responsibilities**:
- Notification permission management
- Smart notification scheduling and delivery
- Context-aware notification logic
- User preference integration
- Action handling for notification interactions

**Key Capabilities**:
- Permission request and management
- Smart scheduling based on PR state
- Multiple notification types (new PR, daily, interval)
- Context awareness (only notify when relevant)
- Action button integration

**Notification Types**:
- New PR notifications (immediate)
- Daily reminders (scheduled)
- Interval reminders (periodic)
- Smart notifications (context-aware)

### 5. MenuBuilder Agent
**Role**: Dynamic menu construction specialist
**Responsibilities**:
- Dynamic menu bar menu construction
- PR display formatting and organization
- Batch operation handling
- Error message integration
- User preference-based menu customization

**Key Capabilities**:
- Dynamic menu construction based on current state
- Batch operations (open all assigned/authored PRs)
- Error state handling and display
- User preference integration
- URL extraction and browser opening

**Menu Sections**:
- Error messages and setup prompts
- Assigned PRs section with approval status
- Authored PRs section with comment counts
- Action items (settings, refresh, quit)

### 6. SettingsWindowController Agent
**Role**: User interface and settings management
**Responsibilities**:
- Settings window UI management
- User input handling and validation
- Real-time settings updates
- Control dependencies and state management
- Accessibility and user experience

**Key Capabilities**:
- Responsive UI layout management
- Bidirectional settings binding
- Real-time validation and updates
- Control dependency management
- Accessibility support

## Specialized Component Agents

### 7. PRMenuItemView Agent
**Role**: Individual PR menu item display specialist
**Responsibilities**:
- Individual PR item formatting
- Status indication and color coding
- Click handling and URL opening
- Visual state management
- Conditional target branch display based on user preferences
- Dynamic status label updates from view model

### 8. PRMenuItemViewModel Agent
**Role**: Dynamic PR status state manager
**Responsibilities**:
- Manages mutable UI state for PR menu items
- Status precedence logic and unified status determination
- Aggregates data from multiple async API sources
- Tracks build state, comment counts, policy states, expiration, and failure reasons
- Provides single source of truth for status display

**Key Capabilities**:
- Status precedence ordering (build failed > unresolved comments > checks running > waiting states > ready)
- Real-time status updates as async data arrives
- Build failure reason extraction and display
- Reviewer policy state tracking
- Centralized status computation logic

**Integration Points**:
- PullRequestService (receives API data)
- MenuBuilder (updates state, queries status)
- PRMenuItemView (displays unified status)

### 9. PasteableSecureTextField Agent
**Role**: Secure credential input specialist
**Responsibilities**:
- Secure text input for credentials
- Paste handling for sensitive data
- Security-focused input validation
- User experience for credential entry

## Data Flow Agents

### 10. Data Flow Coordinator Agent
**Role**: Manages data flow between components
**Responsibilities**:
- Coordinates data fetching operations
- Manages data state transitions
- Handles error propagation
- Ensures data consistency

**Data Flow Patterns**:
- Settings changes → Component updates
- PR data fetching → State updates → UI updates
- Error states → User feedback → Recovery options

### 11. Error Handling Agent
**Role**: Centralized error management and recovery
**Responsibilities**:
- Error detection and classification
- Error state management
- User feedback and error messages
- Recovery strategy coordination

**Error Types**:
- Network errors (API failures, timeouts)
- Authentication errors (invalid credentials)
- Parse errors (malformed JSON)
- Configuration errors (missing settings)

## Integration Agents

### 12. Azure DevOps Integration Agent
**Role**: External API integration specialist
**Responsibilities**:
- Azure DevOps API communication
- Authentication and authorization
- Data format conversion
- API version management

### 13. macOS Integration Agent
**Role**: macOS system integration specialist
**Responsibilities**:
- Status bar integration
- Notification system integration
- Browser opening and URL handling
- System permission management

## Agent Interaction Patterns

### Primary Interaction Flow
```
AppDelegate Agent
    ↓
SettingsManager Agent ← → NotificationManager Agent
    ↓                           ↓
PullRequestService Agent → MenuBuilder Agent
    ↓                           ↓
Azure DevOps API          macOS Integration Agent
```

### Settings Update Flow
```
SettingsWindowController Agent
    ↓
SettingsManager Agent
    ↓
[AppDelegate, NotificationManager, MenuBuilder] Agents
```

### Data Fetching Flow
```
AppDelegate Agent
    ↓
PullRequestService Agent
    ↓
Azure DevOps API
    ↓
AppDelegate Agent (state update)
    ↓
MenuBuilder Agent (UI update)
```

## Agent Responsibilities Matrix

| Agent | Configuration | Data Fetching | UI Updates | Notifications | Error Handling |
|-------|---------------|---------------|------------|---------------|----------------|
| AppDelegate | ✓ | ✓ | ✓ | ✓ | ✓ |
| SettingsManager | ✓ | - | - | - | ✓ |
| PullRequestService | - | ✓ | - | - | ✓ |
| NotificationManager | - | - | - | ✓ | ✓ |
| MenuBuilder | - | - | ✓ | - | ✓ |
| SettingsWindowController | ✓ | - | ✓ | - | ✓ |
| PRMenuItemViewModel | - | - | - | - | - |

## Usage Guidelines

### For Understanding the Codebase
- Start with **AppDelegate Agent** to understand the main application flow
- Use **SettingsManager Agent** to understand configuration and persistence
- Follow **PullRequestService Agent** to understand API integration
- Use **MenuBuilder Agent** to understand UI construction

### For Modifying Functionality
- **Settings changes**: Work with SettingsManager Agent
- **API integration**: Work with PullRequestService Agent
- **UI updates**: Work with MenuBuilder Agent
- **Notifications**: Work with NotificationManager Agent
- **Core logic**: Work with AppDelegate Agent

### For Adding New Features
- **New settings**: Extend SettingsManager Agent (e.g., showTargetBranch toggle)
- **New API endpoints**: Extend PullRequestService Agent (e.g., fetchStatusChecks, fetchPolicyEvaluationsSummary)
- **New UI elements**: Extend MenuBuilder Agent or PRMenuItemView Agent
- **New status types**: Extend PRMenuItemViewModel Agent
- **New notifications**: Extend NotificationManager Agent
- **New core functionality**: Extend AppDelegate Agent

## Agent Communication Protocols

### Settings Updates
- SettingsManager → AppDelegate (configuration changes)
- SettingsManager → NotificationManager (notification settings)
- SettingsManager → MenuBuilder (display preferences)

### Data Updates
- PullRequestService → AppDelegate (new PR data)
- AppDelegate → MenuBuilder (UI updates)
- AppDelegate → NotificationManager (schedule updates)

### Error Propagation
- Any Agent → AppDelegate (error state)
- AppDelegate → MenuBuilder (error display)
- AppDelegate → User (error feedback)

This agent-based architecture provides clear separation of concerns, making the codebase maintainable, testable, and extensible. Each agent has well-defined responsibilities and interaction patterns, enabling efficient development and debugging.

