import 'dart:developer';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/review_model.dart';
import 'package:arabween/service/abacus_api_service.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HybridDataService {
  static bool useDeepAgent = true;
  
  static Future<List<BusinessModel>> getBusinesses({
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    if (useDeepAgent) {
      try {
        final deepAgentData = await AbacusApiService.getBusinesses(
          category: category,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        
        if (deepAgentData.isNotEmpty) {
          return deepAgentData.map((data) => BusinessModel.fromJson(data)).toList();
        }
      } catch (e) {
        log('Deep Agent failed, falling back to Firebase: $e');
      }
    }
    
    return await FireStoreUtils.getBusinessList();
  }

  static Future<List<BusinessModel>> getAIRecommendations({
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final recommendations = await AbacusApiService.getAIRecommendations(
        userId: userId,
        category: category,
        latitude: latitude,
        longitude: longitude,
      );
      
      if (recommendations.isNotEmpty) {
        return recommendations.map((data) => BusinessModel.fromJson(data)).toList();
      }
    } catch (e) {
      log('AI Recommendations failed: $e');
    }
    
    return await FireStoreUtils.getBusinessList();
  }

  static Future<List<BusinessModel>> searchBusinesses({
    required String query,
    double? latitude,
    double? longitude,
    String? category,
  }) async {
    if (useDeepAgent) {
      try {
        final results = await AbacusApiService.searchBusinesses(
          query: query,
          latitude: latitude,
          longitude: longitude,
          category: category,
        );
        
        if (results.isNotEmpty) {
          return results.map((data) => BusinessModel.fromJson(data)).toList();
        }
      } catch (e) {
        log('Deep Agent search failed, falling back to Firebase: $e');
      }
    }
    
    return await FireStoreUtils.searchBusinesses(query);
  }

  static Future<BusinessModel?> getBusinessDetails(String businessId) async {
    if (useDeepAgent) {
      try {
        final details = await AbacusApiService.getBusinessDetails(businessId);
        if (details != null) {
          return BusinessModel.fromJson(details);
        }
      } catch (e) {
        log('Deep Agent business details failed: $e');
      }
    }
    
    return await FireStoreUtils.getBusinessById(businessId);
  }

  static Future<List<ReviewModel>> getReviews(String businessId) async {
    if (useDeepAgent) {
      try {
        final reviews = await AbacusApiService.getReviews(businessId);
        if (reviews.isNotEmpty) {
          return reviews.map((data) => ReviewModel.fromJson(data)).toList();
        }
      } catch (e) {
        log('Deep Agent reviews failed: $e');
      }
    }
    
    return await FireStoreUtils.getReviews(businessId);
  }

  static Future<bool> addReview(String businessId, ReviewModel review) async {
    bool firebaseSuccess = await FireStoreUtils.addReview(review);
    
    if (useDeepAgent && firebaseSuccess) {
      try {
        await AbacusApiService.addReview(businessId, review.toJson());
      } catch (e) {
        log('Failed to sync review to Deep Agent: $e');
      }
    }
    
    return firebaseSuccess;
  }

  static Future<List<BusinessModel>> getTrendingBusinesses({
    String? category,
    int? limit,
  }) async {
    if (useDeepAgent) {
      try {
        final trending = await AbacusApiService.getTrendingBusinesses(
          category: category,
          limit: limit,
        );
        
        if (trending.isNotEmpty) {
          return trending.map((data) => BusinessModel.fromJson(data)).toList();
        }
      } catch (e) {
        log('Deep Agent trending failed: $e');
      }
    }
    
    return await FireStoreUtils.getBusinessList();
  }

  static Future<Map<String, dynamic>?> getAIInsights(String businessId) async {
    try {
      return await AbacusApiService.getAIInsights(businessId);
    } catch (e) {
      log('Failed to get AI insights: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> chatWithAI({
    required String message,
    String? conversationId,
    Map<String, dynamic>? context,
  }) async {
    try {
      return await AbacusApiService.sendMessage(
        message: message,
        conversationId: conversationId,
        context: context,
      );
    } catch (e) {
      log('AI Chat failed: $e');
      return null;
    }
  }

  static Future<void> syncBusinessToDeepAgent(BusinessModel business) async {
    if (useDeepAgent) {
      try {
        await AbacusApiService.syncBusinessData(
          business.id ?? '',
          business.toJson(),
        );
      } catch (e) {
        log('Failed to sync business to Deep Agent: $e');
      }
    }
  }
}
