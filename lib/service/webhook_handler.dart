import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:arabween/service/integrated_data_service.dart';

class WebhookHandler {
  static Future<void> handleIncomingWebhook({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final eventType = payload['event_type'] ?? payload['type'];
      final entityType = payload['entity_type'] ?? payload['resource'];
      final entityId = payload['entity_id'] ?? payload['id'];
      final data = payload['data'] ?? payload;
      final source = payload['source'] ?? 'unknown';

      log('Processing webhook: $eventType for $entityType/$entityId from $source');

      switch (eventType?.toLowerCase()) {
        case 'business.created':
        case 'business.updated':
        case 'business.deleted':
          await IntegratedDataService.handleWebhook(
            entityType: 'business',
            entityId: entityId,
            data: data,
            source: source,
          );
          break;

        case 'review.created':
        case 'review.updated':
        case 'review.deleted':
          await IntegratedDataService.handleWebhook(
            entityType: 'review',
            entityId: entityId,
            data: data,
            source: source,
          );
          break;

        case 'user.created':
        case 'user.updated':
        case 'user.deleted':
          await IntegratedDataService.handleWebhook(
            entityType: 'user',
            entityId: entityId,
            data: data,
            source: source,
          );
          break;

        case 'category.created':
        case 'category.updated':
        case 'category.deleted':
          await IntegratedDataService.handleWebhook(
            entityType: 'category',
            entityId: entityId,
            data: data,
            source: source,
          );
          break;

        default:
          log('Unknown webhook event type: $eventType');
      }
    } catch (e) {
      log('Error handling webhook: $e');
    }
  }

  static Future<void> registerWebhookEndpoints({
    required String appWebhookUrl,
  }) async {
    log('Registering webhook endpoints: $appWebhookUrl');
  }

  static Map<String, dynamic> createWebhookPayload({
    required String eventType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) {
    return {
      'event_type': eventType,
      'entity_type': entityType,
      'entity_id': entityId,
      'data': data,
      'source': 'app',
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }
}

class WebhookListener extends StatefulWidget {
  final Widget child;
  
  const WebhookListener({super.key, required this.child});

  @override
  State<WebhookListener> createState() => _WebhookListenerState();
}

class _WebhookListenerState extends State<WebhookListener> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForPendingWebhooks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForPendingWebhooks();
    }
  }

  Future<void> _checkForPendingWebhooks() async {
    await IntegratedDataService.syncNow();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
