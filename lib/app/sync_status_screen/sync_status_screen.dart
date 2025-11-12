import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/service/integrated_data_service.dart';
import 'package:arabween/themes/app_them_data.dart';

class SyncStatusController extends GetxController {
  final RxBool isSyncing = false.obs;
  final RxInt queueLength = 0.obs;
  final RxString lastSync = ''.obs;
  final RxInt pendingOperations = 0.obs;
  final RxInt failedOperations = 0.obs;
  final RxMap<String, bool> systemHealth = <String, bool>{}.obs;
  final RxList<Map<String, dynamic>> conflicts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSyncStatus();
    _startStatusMonitoring();
  }

  void _startStatusMonitoring() {
    Future.delayed(Duration(seconds: 10), () async {
      await loadSyncStatus();
      _startStatusMonitoring();
    });
  }

  Future<void> loadSyncStatus() async {
    try {
      final status = await IntegratedDataService.getSyncStatus();
      isSyncing.value = status['is_syncing'] ?? false;
      queueLength.value = status['queue_length'] ?? 0;
      lastSync.value = status['last_sync'] ?? 'Never';
      pendingOperations.value = status['pending_operations'] ?? 0;
      failedOperations.value = status['failed_operations'] ?? 0;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sync status');
    }
  }

  Future<void> checkSystemHealth() async {
    try {
      final health = await IntegratedDataService.checkSystemHealth();
      systemHealth.value = {
        'deepagent': health['deepagent'] ?? false,
        'website': health['website'] ?? false,
        'backend': health['backend'] ?? false,
      };
    } catch (e) {
      Get.snackbar('Error', 'Failed to check system health');
    }
  }

  Future<void> loadConflicts() async {
    try {
      conflicts.value = await IntegratedDataService.getConflicts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load conflicts');
    }
  }

  Future<void> syncNow() async {
    try {
      isSyncing.value = true;
      await IntegratedDataService.syncNow();
      await loadSyncStatus();
      Get.snackbar('Success', 'Sync completed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Sync failed');
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> retryFailed() async {
    try {
      await IntegratedDataService.retryFailedSync();
      await loadSyncStatus();
      Get.snackbar('Success', 'Retrying failed operations');
    } catch (e) {
      Get.snackbar('Error', 'Failed to retry operations');
    }
  }
}

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<SyncStatusController>(
      init: SyncStatusController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Sync Status', style: TextStyle(fontFamily: AppThemeData.semibold)),
            backgroundColor: AppThemeData.blue01,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: controller.loadSyncStatus,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.loadSyncStatus,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                _buildStatusCard(
                  title: 'Sync Status',
                  icon: controller.isSyncing.value ? Icons.sync : Icons.check_circle,
                  iconColor: controller.isSyncing.value ? Colors.blue : Colors.green,
                  children: [
                    _buildInfoRow('Status', controller.isSyncing.value ? 'Syncing...' : 'Idle'),
                    _buildInfoRow('Queue Length', '${controller.queueLength.value}'),
                    _buildInfoRow('Last Sync', controller.lastSync.value),
                    _buildInfoRow('Pending', '${controller.pendingOperations.value}'),
                    _buildInfoRow('Failed', '${controller.failedOperations.value}', 
                      valueColor: controller.failedOperations.value > 0 ? Colors.red : null),
                  ],
                ),
                
                SizedBox(height: 16),
                
                _buildStatusCard(
                  title: 'System Health',
                  icon: Icons.health_and_safety,
                  iconColor: Colors.blue,
                  children: [
                    _buildHealthRow('Deep Agent', controller.systemHealth['deepagent'] ?? false),
                    _buildHealthRow('Website', controller.systemHealth['website'] ?? false),
                    _buildHealthRow('Backend', controller.systemHealth['backend'] ?? false),
                  ],
                  trailing: TextButton(
                    onPressed: controller.checkSystemHealth,
                    child: Text('Check'),
                  ),
                ),
                
                SizedBox(height: 16),
                
                if (controller.failedOperations.value > 0)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.error, color: Colors.red),
                      title: Text('Failed Operations', style: TextStyle(fontFamily: AppThemeData.semibold)),
                      subtitle: Text('${controller.failedOperations.value} operations failed'),
                      trailing: ElevatedButton(
                        onPressed: controller.retryFailed,
                        style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.blue01),
                        child: Text('Retry'),
                      ),
                    ),
                  ),
                
                SizedBox(height: 16),
                
                Card(
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text('Conflicts', style: TextStyle(fontFamily: AppThemeData.semibold)),
                    subtitle: Text('View and resolve sync conflicts'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await controller.loadConflicts();
                      _showConflictsDialog(context, controller);
                    },
                  ),
                ),
                
                SizedBox(height: 24),
                
                ElevatedButton.icon(
                  onPressed: controller.isSyncing.value ? null : controller.syncNow,
                  icon: Icon(Icons.sync),
                  label: Text('Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeData.blue01,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 18, fontFamily: AppThemeData.semibold)),
                Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: AppThemeData.medium)),
          Text(value, style: TextStyle(fontFamily: AppThemeData.semibold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String service, bool isHealthy) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(service, style: TextStyle(fontFamily: AppThemeData.medium)),
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.cancel,
                color: isHealthy ? Colors.green : Colors.red,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                isHealthy ? 'Online' : 'Offline',
                style: TextStyle(
                  fontFamily: AppThemeData.semibold,
                  color: isHealthy ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConflictsDialog(BuildContext context, SyncStatusController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sync Conflicts', style: TextStyle(fontFamily: AppThemeData.semibold)),
        content: Container(
          width: double.maxFinite,
          child: controller.conflicts.isEmpty
              ? Text('No conflicts found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.conflicts.length,
                  itemBuilder: (context, index) {
                    final conflict = controller.conflicts[index];
                    final operation = conflict['operation'];
                    return Card(
                      child: ListTile(
                        title: Text('${operation['entityType']}/${operation['entityId']}'),
                        subtitle: Text(operation['error'] ?? 'Unknown error'),
                        trailing: Text(operation['retryCount'].toString()),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
