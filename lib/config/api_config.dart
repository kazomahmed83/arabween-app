class ApiConfig {
  static const String deepAgentUrl = 'https://arabwen.abacusai.app';

  static String? _websiteApiUrl;
  static String? _backendApiUrl;

  static String get websiteApiUrl => _websiteApiUrl ?? 'https://your-website.com/api';
  static String get backendApiUrl => _backendApiUrl ?? 'https://your-backend.com/api';

  static void setWebsiteApiUrl(String url) {
    _websiteApiUrl = url;
  }

  static void setBackendApiUrl(String url) {
    _backendApiUrl = url;
  }

  static const Duration timeout = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String? token) {
    return {
      ...defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class Endpoints {
  static const String businesses = '/api/businesses';
  static const String search = '/api/search';
  static const String recommendations = '/api/recommendations';
  static const String trending = '/api/trending';
  static const String reviews = '/api/reviews';
  static const String users = '/api/users';
  static const String categories = '/api/categories';
  static const String chat = '/api/chat';
  static const String insights = '/api/insights';

  static const String sync = '/api/sync';
  static const String syncBusiness = '/api/sync/business';
  static const String syncReview = '/api/sync/review';
  static const String syncUser = '/api/sync/user';
  static const String syncCategory = '/api/sync/category';

  static const String webhook = '/api/webhook';
  static const String webhookBusiness = '/api/webhook/business';
  static const String webhookReview = '/api/webhook/review';
  static const String webhookUser = '/api/webhook/user';

  static const String health = '/api/health';
  static const String status = '/api/status';
}

class SyncConfig {
  static const bool enableAutoSync = true;
  static const bool enableRealtimeSync = true;
  static const bool enableConflictResolution = true;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  static const String lastSyncKey = 'last_sync_timestamp';
  static const String syncQueueKey = 'sync_queue';
  static const String conflictLogKey = 'conflict_log';
}

class Priority {
  static const int high = 1;
  static const int medium = 2;
  static const int low = 3;
}