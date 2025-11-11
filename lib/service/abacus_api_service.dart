import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AbacusApiService {
  static const String baseUrl = 'https://arabwen.abacusai.app';
  static const Duration timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>?> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? jsonEncode(body) : null).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return {'success': true};
        return jsonDecode(response.body);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error making request to $endpoint: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> sendMessage({
    required String message,
    String? conversationId,
    Map<String, dynamic>? context,
  }) async {
    return await _makeRequest(
      method: 'POST',
      endpoint: '/api/chat',
      body: {
        'message': message,
        if (conversationId != null) 'conversation_id': conversationId,
        if (context != null) 'context': context,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getAIRecommendations({
    required String userId,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: '/api/recommendations',
      body: {
        'user_id': userId,
        if (category != null) 'category': category,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    if (response != null && response['recommendations'] != null) {
      return List<Map<String, dynamic>>.from(response['recommendations']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> searchBusinesses({
    required String query,
    double? latitude,
    double? longitude,
    String? category,
    int? limit,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: '/api/search',
      body: {
        'query': query,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (category != null) 'category': category,
        if (limit != null) 'limit': limit,
      },
    );

    if (response != null && response['results'] != null) {
      return List<Map<String, dynamic>>.from(response['results']);
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getBusinesses({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (latitude != null) queryParams['latitude'] = latitude.toString();
    if (longitude != null) queryParams['longitude'] = longitude.toString();
    if (radius != null) queryParams['radius'] = radius.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest(
      method: 'GET',
      endpoint: '/api/businesses',
      queryParams: queryParams,
    );

    if (response != null && response['businesses'] != null) {
      return List<Map<String, dynamic>>.from(response['businesses']);
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getBusinessDetails(String businessId) async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/api/businesses/$businessId',
    );
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/api/users/$userId',
    );
  }

  static Future<bool> updateUserData(String userId, Map<String, dynamic> userData) async {
    final response = await _makeRequest(
      method: 'PUT',
      endpoint: '/api/users/$userId',
      body: userData,
    );
    return response != null;
  }

  static Future<List<Map<String, dynamic>>> getReviews(String businessId) async {
    final response = await _makeRequest(
      method: 'GET',
      endpoint: '/api/businesses/$businessId/reviews',
    );

    if (response != null && response['reviews'] != null) {
      return List<Map<String, dynamic>>.from(response['reviews']);
    }
    return [];
  }

  static Future<bool> addReview(String businessId, Map<String, dynamic> reviewData) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: '/api/businesses/$businessId/reviews',
      body: reviewData,
    );
    return response != null;
  }

  static Future<Map<String, dynamic>?> getAIInsights(String businessId) async {
    return await _makeRequest(
      method: 'GET',
      endpoint: '/api/businesses/$businessId/insights',
    );
  }

  static Future<List<Map<String, dynamic>>> getTrendingBusinesses({
    String? category,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest(
      method: 'GET',
      endpoint: '/api/trending',
      queryParams: queryParams,
    );

    if (response != null && response['trending'] != null) {
      return List<Map<String, dynamic>>.from(response['trending']);
    }
    return [];
  }

  static Future<bool> syncBusinessData(String businessId, Map<String, dynamic> businessData) async {
    final response = await _makeRequest(
      method: 'POST',
      endpoint: '/api/sync/business',
      body: {
        'business_id': businessId,
        'data': businessData,
      },
    );
    return response != null;
  }
}
