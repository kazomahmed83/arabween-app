# Unified API Integration Architecture

This document explains how the app, website, and backend are connected through a unified API system with bidirectional synchronization.

## Architecture Overview

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Flutter App   │◄───────►│  Deep Agent API  │◄───────►│  Admin Panel    │
│                 │         │  (arabwen.ai)    │         │  (Website)      │
└────────┬────────┘         └────────┬─────────┘         └────────┬────────┘
         │                           │                            │
         │                           │                            │
         └───────────────────────────┴────────────────────────────┘
                                     │
                          ┌──────────▼──────────┐
                          │  Backend Database   │
                          │  (Your Backend)     │
                          └─────────────────────┘
```

## Key Components

### 1. API Configuration (`lib/config/api_config.dart`)
- Centralized configuration for all API endpoints
- Manages URLs for Deep Agent, Website, and Backend
- Defines sync settings and priorities

### 2. Unified API Service (`lib/service/unified_api_service.dart`)
- Single interface to communicate with all three systems
- Handles parallel requests for better performance
- Automatic error handling and retry logic

### 3. Bidirectional Sync Service (`lib/service/bidirectional_sync_service.dart`)
- **Queue-based synchronization**: Operations are queued and processed in order
- **Priority system**: High-priority changes sync first
- **Conflict resolution**: Automatically handles data conflicts
- **Retry mechanism**: Failed operations retry up to 3 times
- **Offline support**: Queues changes when offline, syncs when online

### 4. Integrated Data Service (`lib/service/integrated_data_service.dart`)
- High-level API for app features
- Automatically syncs data across all platforms
- Deduplicates data from multiple sources
- Handles CRUD operations with automatic sync

### 5. Webhook Handler (`lib/service/webhook_handler.dart`)
- Receives updates from admin panel and website
- Processes incoming changes in real-time
- Triggers sync operations for external changes

## How It Works

### Creating/Updating Data (App → Cloud)

1. User creates/updates business in the app
2. Data is saved to Firebase immediately
3. Sync operations are queued for all three systems:
   - Deep Agent API
   - Website API
   - Backend API
4. Operations are processed based on priority
5. If any sync fails, it's retried automatically

### Receiving Updates (Cloud → App)

1. Admin updates business in admin panel
2. Webhook is sent to the app
3. App receives webhook and queues sync operation
4. Data is pulled from the source
5. Local Firebase data is updated
6. UI refreshes automatically

### Bidirectional Sync

- Runs automatically every 5 minutes
- Pulls updates from all sources since last sync
- Compares timestamps to avoid conflicts
- Applies only newer changes
- Logs conflicts for manual resolution

## Data Flow Examples

### Example 1: Creating a Business

```dart
// In your app code
final business = BusinessModel(...);
await IntegratedDataService.createBusiness(business);

// What happens:
// 1. Saved to Firebase
// 2. Queued for sync to Deep Agent
// 3. Queued for sync to Website
// 4. Queued for sync to Backend
// 5. All syncs happen in background
```

### Example 2: Admin Panel Update

```
1. Admin updates business in website
2. Website sends webhook to app
3. App receives webhook
4. App pulls latest data from website
5. App updates Firebase
6. App syncs to Deep Agent and Backend
7. UI updates automatically
```

## Configuration

### Setting API URLs

In `lib/main.dart`, update the initialization:

```dart
await IntegratedDataService.initialize(
  websiteApiUrl: 'https://your-website.com/api',
  backendApiUrl: 'https://your-backend.com/api',
);
```

### Sync Settings

In `lib/config/api_config.dart`:

```dart
static const bool enableAutoSync = true;        // Auto-sync every 5 minutes
static const bool enableRealtimeSync = true;    // Sync immediately on changes
static const bool enableConflictResolution = true;
static const int maxRetries = 3;                // Retry failed operations
```

## API Endpoints Required

Your website and backend should implement these endpoints:

### Business Endpoints
- `GET /api/businesses` - List businesses
- `GET /api/businesses/:id` - Get business details
- `PUT /api/businesses/:id` - Update business
- `POST /api/businesses` - Create business
- `DELETE /api/businesses/:id` - Delete business

### Sync Endpoints
- `GET /api/sync?since=<timestamp>` - Get updates since timestamp
- `PUT /api/sync/business/:id` - Sync business data
- `PUT /api/sync/review/:id` - Sync review data
- `PUT /api/sync/user/:id` - Sync user data

### Webhook Endpoints
- `POST /api/webhook/business` - Business change webhook
- `POST /api/webhook/review` - Review change webhook
- `POST /api/webhook/user` - User change webhook

### Health Check
- `GET /api/health` - Check if API is online

## Webhook Payload Format

When your admin panel or website makes changes, send this webhook:

```json
{
  "event_type": "business.updated",
  "entity_type": "business",
  "entity_id": "business_123",
  "source": "website",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": {
    "id": "business_123",
    "businessName": "Updated Name",
    ...
  }
}
```

## Monitoring Sync Status

Users can view sync status in the app:
1. Go to More → Sync Status
2. View:
   - Current sync status
   - Queue length
   - Last sync time
   - Failed operations
   - System health (all APIs)
   - Conflicts

## Conflict Resolution

When conflicts occur:
1. Logged in conflict log
2. Visible in Sync Status screen
3. Can be manually resolved
4. Or retry automatically

## Benefits

✅ **No Data Duplication**: Automatic deduplication by ID
✅ **Always In Sync**: Changes propagate to all systems
✅ **Offline Support**: Works offline, syncs when online
✅ **Conflict Resolution**: Handles conflicts automatically
✅ **Real-time Updates**: Webhook support for instant updates
✅ **Reliable**: Retry mechanism for failed operations
✅ **Transparent**: Full visibility into sync status

## Usage in Your Code

### Get Businesses (from all sources)
```dart
final businesses = await IntegratedDataService.getBusinesses();
```

### Create Business (syncs to all)
```dart
await IntegratedDataService.createBusiness(business);
```

### Update Business (syncs to all)
```dart
await IntegratedDataService.updateBusiness(business);
```

### Manual Sync
```dart
await IntegratedDataService.syncNow();
```

### Check System Health
```dart
final health = await IntegratedDataService.checkSystemHealth();
// Returns: {deepagent: true, website: true, backend: true}
```

## Troubleshooting

### Sync Not Working
1. Check API URLs in initialization
2. Verify endpoints are accessible
3. Check Sync Status screen for errors
4. Review conflict log

### Data Not Updating
1. Check system health
2. Verify webhooks are configured
3. Check last sync time
3. Retry failed operations

### Conflicts
1. View conflicts in Sync Status
2. Check timestamps
3. Manually resolve if needed
4. Or retry sync

## Security

- All API calls use HTTPS
- Bearer token authentication supported
- Webhook signature verification (implement in your backend)
- Data validation on all endpoints
