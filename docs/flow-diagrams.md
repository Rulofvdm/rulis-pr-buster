# Flow Diagrams

## Application Startup Flow

```mermaid
graph TD
    A[App Launch] --> B[Initialize AppDelegate]
    B --> C[Setup Status Bar Item]
    C --> D[Setup Notification Delegate]
    D --> E{Credentials Configured?}
    
    E -->|No| F[Show Setup Menu]
    E -->|Yes| G[Request Notification Permissions]
    
    G --> H[Start App Logic]
    H --> I[Fetch Assigned PRs]
    I --> J[Fetch Authored PRs]
    J --> K[Update Menu Bar]
    K --> L[Build Menu]
    L --> M[Start Refresh Timer]
    M --> N[Schedule Notifications]
    
    F --> O[Show Settings Option]
    O --> P[Wait for User Configuration]
```

## Data Fetching Flow

```mermaid
graph TD
    A[Refresh Triggered] --> B[Check Credentials]
    B --> C{Credentials Valid?}
    
    C -->|No| D[Show Error Message]
    C -->|Yes| E[Fetch Assigned PRs]
    
    E --> F[Parse JSON Response]
    F --> G[Filter by User Email]
    G --> H[Update Assigned PRs Array]
    
    H --> I[Fetch Authored PRs]
    I --> J[Parse JSON Response]
    J --> K[Update Authored PRs Array]
    
    K --> L[Calculate Statistics]
    L --> M[Update Menu Bar Display]
    M --> N[Build Dynamic Menu]
    N --> O[Check for New PRs]
    O --> P[Update Notification Schedules]
```

## Menu Construction Flow

```mermaid
graph TD
    A[Build Menu Request] --> B{Error Message?}
    B -->|Yes| C[Add Error Item]
    B -->|No| D{Credentials Configured?}
    
    D -->|No| E[Add Setup Message]
    D -->|Yes| F[Build PR Sections]
    
    F --> G{Show Assigned PRs?}
    G -->|Yes| H[Add Assigned Section]
    G -->|No| I[Skip Assigned]
    
    H --> J[Add Batch Action]
    J --> K[Add Individual PR Items]
    
    K --> L{Show Authored PRs?}
    L -->|Yes| M[Add Authored Section]
    L -->|No| N[Skip Authored]
    
    M --> O[Add Batch Action]
    O --> P[Add Individual PR Items]
    P --> Q[Fetch Comment Counts]
    
    Q --> R[Add Action Items]
    R --> S[Return Complete Menu]
    
    I --> L
    N --> R
    E --> R
    C --> R
```

## Notification Flow

```mermaid
graph TD
    A[Settings Change] --> B{Notifications Enabled?}
    B -->|No| C[Clear All Notifications]
    B -->|Yes| D[Request Permissions]
    
    D --> E{Permissions Granted?}
    E -->|No| F[Skip Notifications]
    E -->|Yes| G[Schedule Notifications]
    
    G --> H{Daily Reminders?}
    H -->|Yes| I[Schedule Daily Reminder]
    H -->|No| J[Skip Daily]
    
    I --> K{Interval Reminders?}
    K -->|Yes| L[Schedule Interval Reminder]
    K -->|No| M[Skip Interval]
    
    L --> N[New PR Detection]
    M --> N
    J --> N
    
    N --> O{New PRs Found?}
    O -->|Yes| P[Show New PR Notification]
    O -->|No| Q[No Notification]
    
    P --> R[User Clicks Notification]
    R --> S[Open PR in Browser]
```

## Settings Update Flow

```mermaid
graph TD
    A[User Changes Setting] --> B[Update SettingsManager]
    B --> C[Save to UserDefaults]
    C --> D[Trigger App Updates]
    
    D --> E{Display Setting?}
    E -->|Yes| F[Rebuild Menu]
    E -->|No| G[Check Other Settings]
    
    G --> H{Notification Setting?}
    H -->|Yes| I[Update Notification Schedules]
    H -->|No| J[Check Other Settings]
    
    J --> K{Refresh Setting?}
    K -->|Yes| L[Start/Stop Refresh Timer]
    K -->|No| M[Check Other Settings]
    
    M --> N{Credential Setting?}
    N -->|Yes| O[Validate Credentials]
    N -->|No| P[Settings Updated]
    
    O --> Q{Credentials Valid?}
    Q -->|Yes| R[Start App Logic]
    Q -->|No| S[Show Setup Message]
    
    R --> T[Fetch PR Data]
    T --> U[Update Menu]
    U --> P
    
    F --> P
    I --> P
    L --> P
    S --> P
```

## Error Handling Flow

```mermaid
graph TD
    A[API Call] --> B{Network Success?}
    B -->|No| C[Set Error Message]
    B -->|Yes| D{Valid Response?}
    
    D -->|No| E[Set Parse Error]
    D -->|Yes| F{Empty Data?}
    
    F -->|Yes| G[Set No Data Error]
    F -->|No| H[Process Data]
    
    C --> I[Show Error in Menu]
    E --> I
    G --> I
    
    I --> J[User Sees Error]
    J --> K[User Can Retry]
    K --> L[Manual Refresh]
    L --> A
    
    H --> M[Update Menu]
    M --> N[Clear Errors]
    N --> O[Show Success State]
```

## Batch Operation Flow

```mermaid
graph TD
    A[User Clicks Open All] --> B[Parse Menu Items]
    B --> C[Extract PR URLs]
    C --> D{URLs Found?}
    
    D -->|No| E[Use AppDelegate Data]
    D -->|Yes| F[Open URLs in Browser]
    
    E --> G[Get PRs from AppDelegate]
    G --> H[Extract URLs from PRs]
    H --> I[Open URLs in Browser]
    
    F --> J[All PRs Opened]
    I --> J
    
    J --> K[User Sees PRs in Browser]
    K --> L[User Can Review PRs]
```

## Component Interaction Flow

```mermaid
graph TB
    subgraph "Core Components"
        AD[AppDelegate]
        SM[SettingsManager]
        NM[NotificationManager]
        PS[PullRequestService]
        MB[MenuBuilder]
    end
    
    subgraph "UI Components"
        SWC[SettingsWindowController]
        PMV[PRMenuItemView]
    end
    
    subgraph "External Systems"
        ADO[Azure DevOps API]
        UN[UserNotifications]
        NS[NSWorkspace]
    end
    
    AD --> SM
    AD --> NM
    AD --> PS
    AD --> MB
    
    SM --> AD
    SM --> NM
    SM --> MB
    
    PS --> ADO
    PS --> AD
    
    NM --> UN
    NM --> AD
    
    MB --> PS
    MB --> AD
    
    SWC --> SM
    SWC --> AD
    SWC --> NM
    
    MB --> NS
    NM --> NS
```

## Data Flow Architecture

```mermaid
graph LR
    subgraph "Data Sources"
        ADO[Azure DevOps API]
        UD[UserDefaults]
    end
    
    subgraph "Data Processing"
        PS[PullRequestService]
        SM[SettingsManager]
    end
    
    subgraph "Data Storage"
        AD[AppDelegate Arrays]
        SM2[SettingsManager State]
    end
    
    subgraph "Data Presentation"
        MB[MenuBuilder]
        NM[NotificationManager]
        SWC[SettingsWindowController]
    end
    
    ADO --> PS
    PS --> AD
    UD --> SM
    SM --> SM2
    
    AD --> MB
    AD --> NM
    SM2 --> SWC
    SM2 --> AD
    SM2 --> NM
    SM2 --> MB
```
