# Business Logic Documentation

## Core Business Rules

### PR Status Determination
- **Assigned PRs**: PRs where the user is listed as a reviewer
- **Authored PRs**: PRs where the user is the creator
- **Approved Status**: PR is approved when it has 2+ approvals
- **Overdue Status**: PR is overdue if it's older than 24 hours AND not approved by the user

### Menu Bar Display Logic
- **Format**: `{unapproved}/{total assigned} {approved}/{total authored}`
- **Color Coding**: Red text when user has overdue, unapproved PRs
- **Real-time Updates**: Updates immediately when PR data changes
- **Error States**: Shows error messages when API calls fail
- **PAT Expiration**: Shows detailed error message with renewal link and required permissions

### Notification Business Rules
- **New PR Notifications**: Only shown when new PRs are assigned to the user
- **Smart Notifications**: Only shown when there are pending PRs (if enabled)
- **Daily Reminders**: Scheduled at user-specified time
- **Interval Reminders**: Scheduled every X hours (user-configurable)
- **Permission Respect**: All notifications respect user permission settings

## Component Business Logic

### AppDelegate Business Logic

#### Initialization Rules
1. **Credential Check**: Only start app logic if credentials are configured
2. **Permission Request**: Request notification permissions if notifications enabled
3. **Status Bar Setup**: Initialize status bar item with default display
4. **Error Handling**: Show setup message if credentials missing

#### Data Management Rules
1. **PR State Tracking**: Maintain separate arrays for assigned and authored PRs
2. **Change Detection**: Track previous PR IDs to detect new assignments
3. **Error State Management**: Clear errors when data loads successfully
4. **Menu Updates**: Rebuild menu whenever data changes

#### Refresh Logic
1. **Auto-refresh**: Only enabled when user has configured credentials
2. **Manual Refresh**: Always available through menu action
3. **Timer Management**: Start/stop timer based on settings
4. **Error Recovery**: Retry failed operations on manual refresh

### SettingsManager Business Logic

#### Configuration Rules
1. **Required Fields**: Email and PAT are required for app functionality
2. **Default Values**: Provide sensible defaults for all settings
3. **Persistence**: Automatically save changes to UserDefaults
4. **Backward Compatibility**: Support migration from old settings format

#### Validation Rules
1. **Credential Validation**: Check that email and PAT are not empty
2. **Numeric Validation**: Ensure refresh interval and interval hours are positive
3. **Date Validation**: Ensure daily reminder time is valid
4. **Dependency Validation**: Ensure dependent settings are valid

#### Update Rules
1. **Immediate Effect**: Settings changes take effect immediately
2. **Cascade Updates**: Related components update when settings change
3. **Error Handling**: Graceful handling of invalid settings
4. **User Feedback**: Clear indication of setting changes

### PullRequestService Business Logic

#### API Integration Rules
1. **Authentication**: Use PAT with Basic authentication (empty username, PAT as password)
2. **Endpoint Construction**: Build URLs dynamically from organization and project settings
3. **Error Handling**: Return empty arrays on API failures
4. **Data Filtering**: Filter assigned PRs by user email on client side

#### Data Processing Rules
1. **JSON Parsing**: Use strongly-typed models for data parsing
2. **Error Recovery**: Handle malformed JSON gracefully
3. **Empty Response Handling**: Return empty arrays for empty responses
4. **Async Operations**: Use completion handlers for all API calls

#### Performance Rules
1. **Concurrent Requests**: Fetch assigned and authored PRs in parallel
2. **Minimal Data**: Only fetch necessary fields from API
3. **Efficient Filtering**: Use client-side filtering for assigned PRs
4. **Error Recovery**: Quick failure for invalid requests

### NotificationManager Business Logic

#### Permission Rules
1. **Opt-in Notifications**: Notifications are disabled by default
2. **Permission Request**: Only request permissions when user enables notifications
3. **Graceful Degradation**: Continue operation if permissions denied
4. **User Control**: User can disable all notifications at any time

#### Scheduling Rules
1. **Daily Reminders**: Schedule at user-specified time
2. **Interval Reminders**: Schedule every X hours (user-configurable)
3. **Smart Logic**: Only schedule when there are pending PRs (if enabled)
4. **Update Logic**: Reschedule when PR data changes

#### Content Rules
1. **PR Count Integration**: Include PR count in notifications (if enabled)
2. **Context Awareness**: Only show notifications when relevant
3. **Action Integration**: Include "Open PR" action for new PR notifications
4. **User Preferences**: Respect all notification settings

### MenuBuilder Business Logic

#### Menu Construction Rules
1. **Dynamic Content**: Build menu based on current PR state
2. **User Preferences**: Respect display settings for authored/assigned PRs
3. **Error Handling**: Show appropriate messages for error states
4. **Batch Operations**: Provide "Open all" functionality for efficiency

#### PR Display Rules
1. **Assigned PRs**: Show approval status, overdue indication, click to open
2. **Authored PRs**: Show approval count, reviewer status, comment counts
3. **Color Coding**: Green for approved, red for not approved
4. **Overdue Highlighting**: Special handling for overdue PRs

#### Batch Operation Rules
1. **URL Extraction**: Parse menu items to extract PR URLs
2. **Fallback Logic**: Use AppDelegate data if menu parsing fails
3. **Browser Opening**: Open all URLs in default browser
4. **User Experience**: Immediate response to batch actions

### SettingsWindowController Business Logic

#### UI Construction Rules
1. **Responsive Layout**: Use NSStackView for flexible layout
2. **Control Dependencies**: Enable/disable controls based on dependencies
3. **Real-time Updates**: Update app behavior immediately on changes
4. **Validation**: Ensure settings are valid before saving

#### Settings Management Rules
1. **Bidirectional Binding**: Read from and write to SettingsManager
2. **Immediate Effect**: Changes take effect immediately
3. **Persistence**: Settings automatically saved to UserDefaults
4. **Error Handling**: Graceful handling of invalid input

#### User Experience Rules
1. **Clear Labels**: Descriptive labels for all controls
2. **Logical Grouping**: Group related settings together
3. **Dependency Indication**: Clear indication of control dependencies
4. **Accessibility**: Full keyboard navigation and screen reader support

## Data Flow Business Rules

### PR Data Flow
1. **Fetch Trigger**: Manual refresh or auto-refresh timer
2. **Credential Check**: Only fetch if credentials are configured
3. **API Calls**: Fetch assigned and authored PRs in parallel
4. **Data Processing**: Parse JSON and filter by user email
5. **State Update**: Update AppDelegate arrays with new data
6. **UI Update**: Rebuild menu and update menu bar display
7. **Notification Update**: Update notification schedules

### Settings Flow
1. **User Input**: User changes setting in settings window
2. **Validation**: Validate input and check dependencies
3. **Update SettingsManager**: Write changes to SettingsManager
4. **Persistence**: Save changes to UserDefaults
5. **Cascade Updates**: Trigger updates in related components
6. **UI Update**: Update menu and notification schedules

### Error Handling Flow
1. **Error Detection**: Detect API failures, network errors, parse errors
2. **Error State**: Set error message in AppDelegate
3. **UI Update**: Show error message in menu
4. **User Feedback**: Clear indication of what went wrong
5. **Recovery**: User can retry through manual refresh

## Performance Business Rules

### Data Fetching
1. **Efficient Requests**: Only fetch active PRs
2. **Concurrent Operations**: Fetch assigned and authored PRs in parallel
3. **Minimal Data**: Only fetch necessary fields from API
4. **Caching**: Rely on Azure DevOps API caching

### UI Updates
1. **Batched Updates**: Group related UI updates together
2. **Minimal Rebuilds**: Only rebuild necessary components
3. **Async Operations**: Handle comment counts asynchronously
4. **Memory Management**: Proper cleanup of UI components

### Notification Performance
1. **Smart Scheduling**: Only schedule when necessary
2. **Efficient Updates**: Update schedules only when needed
3. **Context Awareness**: Avoid unnecessary notifications
4. **User Control**: Respect user preferences for performance

## Security Business Rules

### Credential Handling
1. **Secure Storage**: Store credentials in UserDefaults (not in code)
2. **No Logging**: Never log or expose credentials
3. **HTTPS Only**: Use HTTPS for all API calls
4. **User Control**: User manages their own credentials

### Data Privacy
1. **Local Processing**: All data processing happens locally
2. **No Analytics**: No telemetry or analytics collection
3. **Minimal Permissions**: Only request necessary permissions
4. **User Control**: User controls all data sharing

### Network Security
1. **API Only**: Only communicate with Azure DevOps API
2. **Authentication**: Use PAT for all API calls
3. **Error Handling**: Don't expose sensitive information in errors
4. **Validation**: Validate all network responses
