import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:arabween/config/api_config.dart';

class UnifiedApiService {
  static Future<Map<String, dynamic>?> makeRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    String? token,
    String? targetApi,
  }) async {
    try {
      final baseUrl = _getBaseUrl(targetApi);
      Uri uri = Uri.parse('$baseUrl$endpoint');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      final headers = ApiConfig.getAuthHeaders(token);

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(ApiConfig.timeout);
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(ApiConfig.timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'success': true};
        return jsonDecode(response.body);
      } else {
        log('API Error [$targetApi]: ${response.statusCode} - ${response.body}');
        return {'error': true, 'statusCode': response.statusCode, 'message': response.body};
      }
    } catch (e) {
      log('API Exception [$targetApi]: $e');
      return {'error': true, 'message': e.toString()};
    }
  }

  static String _getBaseUrl(String? targetApi) {
    switch (targetApi?.toLowerCase()) {
      case 'website':
        return ApiConfig.websiteApiUrl;
      case 'backend':
        return ApiConfig.backendApiUrl;
      case 'deepagent':
      default:
        return ApiConfig.deepAgentUrl;
    }
  }

  static Future<List<Map<String, dynamic>?>> makeParallelRequests({
    required List<Map<String, dynamic>> requests,
  }) async {
    final futures = requests.map((request) {
      return makeRequest(
        endpoint: request['endpoint'],
        method: request['method'] ?? 'GET',
        body: request['body'],
        queryParams: request['queryParams'],
        token: request['token'],
        targetApi: request['targetApi'],
      );
    }).toList();

    return await Future.wait(futures);
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    final results = await makeParallelRequests(requests: [
      {'endpoint': Endpoints.health, 'targetApi': 'deepagent'},
      {'endpoint': Endpoints.health, 'targetApi': 'website'},
      {'endpoint': Endpoints.health, 'targetApi': 'backend'},
    ]);

    return {
      'deepagent': results[0]?['error'] != true,
      'website': results[1]?['error'] != true,
      'backend': results[2]?['error'] != true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
