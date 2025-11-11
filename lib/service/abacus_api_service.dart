import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class AbacusApiService {
  static const String baseUrl = 'https://arabwen.abacusai.app';
  
  static Future<Map<String, dynamic>?> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          if (conversationId != null) 'conversation_id': conversationId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error sending message to Abacus AI: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>?> getBusinesses({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final uri = Uri.parse('$baseUrl/api/businesses').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['businesses'] ?? []);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error fetching businesses from Abacus AI: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error fetching user data from Abacus AI: $e');
      return null;
    }
  }

  static Future<bool> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      log('Error updating user data in Abacus AI: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>?> getReviews(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/businesses/$businessId/reviews'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['reviews'] ?? []);
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      log('Error fetching reviews from Abacus AI: $e');
      return null;
    }
  }

  static Future<bool> addReview(String businessId, Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/businesses/$businessId/reviews'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reviewData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log('Error adding review to Abacus AI: $e');
      return false;
    }
  }
}
