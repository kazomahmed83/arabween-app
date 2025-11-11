import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arabween/config/api_config.dart';
import 'package:arabween/service/unified_api_service.dart';
import 'package:arabween/models/business_model.dart';

enum SyncStatus { pending, syncing, completed, failed }
enum SyncDirection { appToCloud, cloudToApp, bidirectional }
enum DataSource { app, website, backend, deepagent }

class SyncOperation {
  final String id;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final SyncDirection direction;
  final DataSource source;
  final DataSource target;
  final int priority;
  final DateTime timestamp;
  SyncStatus status;
  int retryCount;
  String? error;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.direction,
    required this.source,
    required this.target,
    this.priority = ApiConfig.Priority.medium,
    DateTime? timestamp,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.error,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'entityType': entityType,
        'entityId': entityId,
        'data': data,
        'direction': direction.toString(),
        'source': source.toString(),
        'target': target.toString(),
        'priority': priority,
        'timestamp': timestamp.toIso8601String(),
        'status': status.toString(),
        'retryCount': retryCount,
        'error': error,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'],
        entityType: json['entityType'],
        entityId: json['entityId'],
        data: json['data'],
        direction: SyncDirection.values.firstWhere((e) => e.toString() == json['direction']),
        source: DataSource.values.firstWhere((e) => e.toString() == json['source']),
        target: DataSource.values.firstWhere((e) => e.toString() == json['target']),
        priority: json['priority'] ?? ApiConfig.Priority.medium,
        timestamp: DateTime.parse(json['timestamp']),
        status: SyncStatus.values.firstWhere((e) => e.toString() == json['status']),
        retryCount: json['retryCount'] ?? 0,
        error: json['error'],
      );
}

class BidirectionalSyncService {
  static final BidirectionalSyncService _instance = BidirectionalSyncService._internal();
  factory BidirectionalSyncService() => _instance;
  BidirectionalSyncService._internal();

  final List<SyncOperation> _syncQueue = [];
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  Future<void> initialize() async {
    await _loadSyncQueue();
    await _loadLastSyncTime();
    
    if (ApiConfig.SyncConfig.enableAutoSync) {
      _startAutoSync();
    }
  }

  Future<void> _loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(ApiConfig.SyncConfig.syncQueueKey);
      if (queueJson != null) {
        final List<dynamic> queueList = jsonDecode(queueJson);
        _syncQueue.clear();
        _syncQueue.addAll(queueList.map((item) => SyncOperation.fromJson(item)));
        log('Loaded ${_syncQueue.length} pending sync operations');
      }
    } catch (e) {
      log('Error loading sync queue: $e');
    }
  }

  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(_syncQueue.map((op) => op.toJson()).toList());
      await prefs.setString(ApiConfig.SyncConfig.syncQueueKey, queueJson);
    } catch (e) {
      log('Error saving sync queue: $e');
    }
  }

  Future<void> _loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(ApiConfig.SyncConfig.lastSyncKey);
      if (timestamp != null) {
        _lastSyncTime = DateTime.parse(timestamp);
      }
    } catch (e) {
      log('Error loading last sync time: $e');
    }
  }

  Future<void> _saveLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSyncTime = DateTime.now();
      await prefs.setString(ApiConfig.SyncConfig.lastSyncKey, _lastSyncTime!.toIso8601String());
    } catch (e) {
      log('Error saving last sync time: $e');
    }
  }

  void _startAutoSync() {
    Future.delayed(ApiConfig.SyncConfig.syncInterval, () async {
      await syncAll();
      _startAutoSync();
    });
  }

  Future<void> queueSync({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
    required SyncDirection direction,
    required DataSource source,
    required DataSource target,
    int priority = ApiConfig.Priority.medium,
  }) async {
    final operation = SyncOperation(
      id: '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
      entityType: entityType,
      entityId: entityId,
      data: data,
      direction: direction,
      source: source,
      target: target,
      priority: priority,
    );

    _syncQueue.add(operation);
    _syncQueue.sort((a, b) => a.priority.compareTo(b.priority));
    
    await _saveSyncQueue();
    log('Queued sync operation: ${operation.id}');

    if (ApiConfig.SyncConfig.enableRealtimeSync && !_isSyncing) {
      await _processSyncQueue();
    }
  }

  Future<void> syncAll() async {
    if (_isSyncing) {
      log('Sync already in progress');
      return;
    }

    log('Starting full sync...');
    await _processSyncQueue();
    await _pullUpdatesFromAllSources();
    await _saveLastSyncTime();
    log('Full sync completed');
  }

  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    _isSyncing = true;
    final operations = List<SyncOperation>.from(_syncQueue);

    for (final operation in operations) {
      if (operation.status == SyncStatus.completed) continue;

      try {
        operation.status = SyncStatus.syncing;
        await _saveSyncQueue();

        final success = await _executeSyncOperation(operation);

        if (success) {
          operation.status = SyncStatus.completed;
          _syncQueue.remove(operation);
          log('Sync operation completed: ${operation.id}');
        } else {
          operation.status = SyncStatus.failed;
          operation.retryCount++;
          
          if (operation.retryCount >= ApiConfig.SyncConfig.maxRetries) {
            _syncQueue.remove(operation);
            await _logConflict(operation);
            log('Sync operation failed after ${operation.retryCount} retries: ${operation.id}');
          } else {
            log('Sync operation failed, will retry: ${operation.id}');
          }
        }

        await _saveSyncQueue();
      } catch (e) {
        operation.status = SyncStatus.failed;
        operation.error = e.toString();
        log('Error executing sync operation ${operation.id}: $e');
      }
    }

    _isSyncing = false;
  }

  Future<bool> _executeSyncOperation(SyncOperation operation) async {
    try {
      final targetApi = _getTargetApiName(operation.target);
      final endpoint = _getEndpointForEntity(operation.entityType);

      final response = await UnifiedApiService.makeRequest(
        endpoint: '$endpoint/${operation.entityId}',
        method: 'PUT',
        body: {
          ...operation.data,
          'source': operation.source.toString(),
          'sync_timestamp': operation.timestamp.toIso8601String(),
        },
        targetApi: targetApi,
      );

      return response != null && response['error'] != true;
    } catch (e) {
      log('Error in _executeSyncOperation: $e');
      return false;
    }
  }

  Future<void> _pullUpdatesFromAllSources() async {
    try {
      final lastSync = _lastSyncTime?.toIso8601String() ?? DateTime.now().subtract(Duration(days: 30)).toIso8601String();

      final responses = await UnifiedApiService.makeParallelRequests(requests: [
        {
          'endpoint': '${ApiConfig.Endpoints.sync}?since=$lastSync',
          'method': 'GET',
          'targetApi': 'website',
        },
        {
          'endpoint': '${ApiConfig.Endpoints.sync}?since=$lastSync',
          'method': 'GET',
          'targetApi': 'backend',
        },
        {
          'endpoint': '${ApiConfig.Endpoints.sync}?since=$lastSync',
          'method': 'GET',
          'targetApi': 'deepagent',
        },
      ]);

      for (var i = 0; i < responses.length; i++) {
        final response = responses[i];
        if (response != null && response['error'] != true) {
          final updates = response['updates'] as List<dynamic>?;
          if (updates != null) {
            await _applyUpdates(updates, DataSource.values[i + 1]);
          }
        }
      }
    } catch (e) {
      log('Error pulling updates: $e');
    }
  }

  Future<void> _applyUpdates(List<dynamic> updates, DataSource source) async {
    for (final update in updates) {
      try {
        final entityType = update['entity_type'];
        final entityId = update['entity_id'];
        final data = update['data'];
        final timestamp = DateTime.parse(update['timestamp']);

        if (await _shouldApplyUpdate(entityType, entityId, timestamp)) {
          await _applyUpdateToLocalStorage(entityType, entityId, data);
          log('Applied update from $source: $entityType/$entityId');
        } else {
          log('Skipped outdated update from $source: $entityType/$entityId');
        }
      } catch (e) {
        log('Error applying update: $e');
      }
    }
  }

  Future<bool> _shouldApplyUpdate(String entityType, String entityId, DateTime timestamp) async {
    return true;
  }

  Future<void> _applyUpdateToLocalStorage(String entityType, String entityId, Map<String, dynamic> data) async {
  }

  Future<void> _logConflict(SyncOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conflictLog = prefs.getString(ApiConfig.SyncConfig.conflictLogKey) ?? '[]';
      final conflicts = jsonDecode(conflictLog) as List<dynamic>;
      
      conflicts.add({
        'operation': operation.toJson(),
        'logged_at': DateTime.now().toIso8601String(),
      });

      await prefs.setString(ApiConfig.SyncConfig.conflictLogKey, jsonEncode(conflicts));
    } catch (e) {
      log('Error logging conflict: $e');
    }
  }

  String _getTargetApiName(DataSource target) {
    switch (target) {
      case DataSource.website:
        return 'website';
      case DataSource.backend:
        return 'backend';
      case DataSource.deepagent:
        return 'deepagent';
      default:
        return 'deepagent';
    }
  }

  String _getEndpointForEntity(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'business':
        return ApiConfig.Endpoints.syncBusiness;
      case 'review':
        return ApiConfig.Endpoints.syncReview;
      case 'user':
        return ApiConfig.Endpoints.syncUser;
      case 'category':
        return ApiConfig.Endpoints.syncCategory;
      default:
        return ApiConfig.Endpoints.sync;
    }
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    return {
      'is_syncing': _isSyncing,
      'queue_length': _syncQueue.length,
      'last_sync': _lastSyncTime?.toIso8601String(),
      'pending_operations': _syncQueue.where((op) => op.status == SyncStatus.pending).length,
      'failed_operations': _syncQueue.where((op) => op.status == SyncStatus.failed).length,
    };
  }

  Future<List<Map<String, dynamic>>> getConflicts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conflictLog = prefs.getString(ApiConfig.SyncConfig.conflictLogKey) ?? '[]';
      return List<Map<String, dynamic>>.from(jsonDecode(conflictLog));
    } catch (e) {
      log('Error getting conflicts: $e');
      return [];
    }
  }

  Future<void> clearConflicts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ApiConfig.SyncConfig.conflictLogKey);
    } catch (e) {
      log('Error clearing conflicts: $e');
    }
  }

  Future<void> retryFailedOperations() async {
    final failedOps = _syncQueue.where((op) => op.status == SyncStatus.failed).toList();
    for (final op in failedOps) {
      op.status = SyncStatus.pending;
      op.retryCount = 0;
    }
    await _saveSyncQueue();
    await _processSyncQueue();
  }
}
