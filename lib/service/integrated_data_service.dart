import 'dart:developer';
import 'package:arabween/service/unified_api_service.dart';
import 'package:arabween/service/bidirectional_sync_service.dart';
import 'package:arabween/config/api_config.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class IntegratedDataService {
  static final _syncService = BidirectionalSyncService();

  static Future<void> initialize({
    String? websiteApiUrl,
    String? backendApiUrl,
  }) async {
    if (websiteApiUrl != null) {
      ApiConfig.setWebsiteApiUrl(websiteApiUrl);
    }
    if (backendApiUrl != null) {
      ApiConfig.setBackendApiUrl(backendApiUrl);
    }
    
    await _syncService.initialize();
    log('IntegratedDataService initialized');
  }

  static Future<List<BusinessModel>> getBusinesses({
    String? categoryId,
    double? latitude,
    double? longitude,
    int? limit,
  }) async {
    try {
      final responses = await UnifiedApiService.makeParallelRequests(requests: [
        {
          'endpoint': Endpoints.businesses,
          'method': 'GET',
          'queryParams': {
            if (categoryId != null) 'category_id': categoryId,
            if (latitude != null) 'latitude': latitude.toString(),
            if (longitude != null) 'longitude': longitude.toString(),
            if (limit != null) 'limit': limit.toString(),
          },
          'targetApi': 'deepagent',
        },
        {
          'endpoint': Endpoints.businesses,
          'method': 'GET',
          'queryParams': {
            if (categoryId != null) 'category_id': categoryId,
            if (latitude != null) 'latitude': latitude.toString(),
            if (longitude != null) 'longitude': longitude.toString(),
            if (limit != null) 'limit': limit.toString(),
          },
          'targetApi': 'website',
        },
      ]);

      final businesses = <BusinessModel>[];
      final seenIds = <String>{};

      for (final response in responses) {
        if (response != null && response['error'] != true) {
          final data = response['data'] ?? response['businesses'] ?? [];
          for (final item in data) {
            try {
              final business = BusinessModel.fromJson(item);
              if (business.id != null && !seenIds.contains(business.id)) {
                businesses.add(business);
                seenIds.add(business.id!);
              }
            } catch (e) {
              log('Error parsing business: $e');
            }
          }
        }
      }

      return businesses;
    } catch (e) {
      log('Error in getBusinesses: $e');
      return await FireStoreUtils.getBusinessList();
    }
  }

  static Future<BusinessModel?> getBusinessDetails(String businessId) async {
    try {
      final responses = await UnifiedApiService.makeParallelRequests(requests: [
        {
          'endpoint': '${Endpoints.businesses}/$businessId',
          'method': 'GET',
          'targetApi': 'deepagent',
        },
        {
          'endpoint': '${Endpoints.businesses}/$businessId',
          'method': 'GET',
          'targetApi': 'website',
        },
        {
          'endpoint': '${Endpoints.businesses}/$businessId',
          'method': 'GET',
          'targetApi': 'backend',
        },
      ]);

      for (final response in responses) {
        if (response != null && response['error'] != true) {
          final data = response['data'] ?? response['business'];
          if (data != null) {
            return BusinessModel.fromJson(data);
          }
        }
      }

      return null;
    } catch (e) {
      log('Error in getBusinessDetails: $e');
      return null;
    }
  }

  static Future<bool> createBusiness(BusinessModel business) async {
    try {
      final businessData = business.toJson();

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.appToCloud,
        source: DataSource.app,
        target: DataSource.website,
        priority: Priority.high,
      );

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.appToCloud,
        source: DataSource.app,
        target: DataSource.backend,
        priority: Priority.high,
      );

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.appToCloud,
        source: DataSource.app,
        target: DataSource.deepagent,
        priority: Priority.high,
      );

      await FireStoreUtils.setBusinessData(business);

      return true;
    } catch (e) {
      log('Error in createBusiness: $e');
      return false;
    }
  }

  static Future<bool> updateBusiness(BusinessModel business) async {
    try {
      final businessData = business.toJson();

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.bidirectional,
        source: DataSource.app,
        target: DataSource.website,
        priority: Priority.high,
      );

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.bidirectional,
        source: DataSource.app,
        target: DataSource.backend,
        priority: Priority.high,
      );

      await _syncService.queueSync(
        entityType: 'business',
        entityId: business.id ?? '',
        data: businessData,
        direction: SyncDirection.bidirectional,
        source: DataSource.app,
        target: DataSource.deepagent,
        priority: Priority.high,
      );

      await FireStoreUtils.updateBusinessData(business);

      return true;
    } catch (e) {
      log('Error in updateBusiness: $e');
      return false;
    }
  }

  static Future<bool> deleteBusiness(String businessId) async {
    try {
      await _syncService.queueSync(
        entityType: 'business',
        entityId: businessId,
        data: {'deleted': true, 'deleted_at': DateTime.now().toIso8601String()},
        direction: SyncDirection.appToCloud,
        source: DataSource.app,
        target: DataSource.website,
        priority: Priority.high,
      );

      await _syncService.queueSync(
        entityType: 'business',
        entityId: businessId,
        data: {'deleted': true, 'deleted_at': DateTime.now().toIso8601String()},
        direction: SyncDirection.appToCloud,
        source: DataSource.app,
        target: DataSource.backend,
        priority: Priority.high,
      );

      return true;
    } catch (e) {
      log('Error in deleteBusiness: $e');
      return false;
    }
  }

  static Future<List<BusinessModel>> searchBusinesses({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final responses = await UnifiedApiService.makeParallelRequests(requests: [
        {
          'endpoint': Endpoints.search,
          'method': 'POST',
          'body': {
            'query': query,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          },
          'targetApi': 'deepagent',
        },
        {
          'endpoint': Endpoints.search,
          'method': 'POST',
          'body': {
            'query': query,
            if (latitude != null) 'latitude': latitude,
            if (longitude != null) 'longitude': longitude,
          },
          'targetApi': 'website',
        },
      ]);

      final businesses = <BusinessModel>[];
      final seenIds = <String>{};

      for (final response in responses) {
        if (response != null && response['error'] != true) {
          final data = response['results'] ?? response['data'] ?? [];
          for (final item in data) {
            try {
              final business = BusinessModel.fromJson(item);
              if (business.id != null && !seenIds.contains(business.id)) {
                businesses.add(business);
                seenIds.add(business.id!);
              }
            } catch (e) {
              log('Error parsing search result: $e');
            }
          }
        }
      }

      return businesses;
    } catch (e) {
      log('Error in searchBusinesses: $e');
      return [];
    }
  }

  static Future<void> syncNow() async {
    await _syncService.syncAll();
  }

  static Future<Map<String, dynamic>> getSyncStatus() async {
    return await _syncService.getSyncStatus();
  }

  static Future<List<Map<String, dynamic>>> getConflicts() async {
    return await _syncService.getConflicts();
  }

  static Future<void> retryFailedSync() async {
    await _syncService.retryFailedOperations();
  }

  static Future<Map<String, dynamic>> checkSystemHealth() async {
    return await UnifiedApiService.checkHealth();
  }

  static Future<void> handleWebhook({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required String source,
  }) async {
    log('Received webhook: $entityType/$entityId from $source');

    DataSource dataSource;
    switch (source.toLowerCase()) {
      case 'website':
        dataSource = DataSource.website;
        break;
      case 'backend':
        dataSource = DataSource.backend;
        break;
      case 'admin':
        dataSource = DataSource.website;
        break;
      default:
        dataSource = DataSource.deepagent;
    }

    await _syncService.queueSync(
      entityType: entityType,
      entityId: entityId,
      data: data,
      direction: SyncDirection.cloudToApp,
      source: dataSource,
      target: DataSource.app,
      priority: Priority.high,
    );

    if (entityType.toLowerCase() == 'business') {
      try {
        final business = BusinessModel.fromJson(data);
        await FireStoreUtils.updateBusinessData(business);
      } catch (e) {
        log('Error updating business from webhook: $e');
      }
    }
  }
}
