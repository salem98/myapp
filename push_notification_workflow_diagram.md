# Push Notification Workflow Diagram (Test-Based)

```mermaid
sequenceDiagram
    participant Dev as Developer (You)
    participant CLI as Command Line (curl)
    participant Supabase as Supabase Backend
    participant OneSignal as OneSignal Push Service
    participant FlutterApp as Flutter Mobile App

    Dev->>CLI: Run curl command to send notification
    CLI->>OneSignal: POST notification request with device IDs
    OneSignal-->>CLI: Notification accepted response
    OneSignal->>FlutterApp: Push notification delivered to device
    FlutterApp-->>Dev: Notification received and displayed
    FlutterApp->>Supabase: Register device token on app start
    Supabase-->>FlutterApp: Store device token confirmation