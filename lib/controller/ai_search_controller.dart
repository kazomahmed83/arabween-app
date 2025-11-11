import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/service/hybrid_data_service.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/constant/constant.dart';

class AISearchController extends GetxController {
  final searchController = TextEditingController();
  final RxList<BusinessModel> searchResults = <BusinessModel>[].obs;
  final RxList<BusinessModel> aiRecommendations = <BusinessModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString conversationId = ''.obs;
  final RxList<Map<String, dynamic>> chatMessages = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAIRecommendations();
  }

  Future<void> loadAIRecommendations() async {
    isLoading.value = true;
    try {
      final recommendations = await HybridDataService.getAIRecommendations(
        latitude: Constant.currentLocation?.latitude,
        longitude: Constant.currentLocation?.longitude,
      );
      aiRecommendations.value = recommendations;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recommendations');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchWithAI(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    try {
      final results = await HybridDataService.searchBusinesses(
        query: query,
        latitude: Constant.currentLocation?.latitude,
        longitude: Constant.currentLocation?.longitude,
      );
      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> chatWithAI(String message) async {
    if (message.isEmpty) return;

    chatMessages.add({
      'role': 'user',
      'message': message,
      'timestamp': DateTime.now(),
    });

    try {
      final response = await HybridDataService.chatWithAI(
        message: message,
        conversationId: conversationId.value.isEmpty ? null : conversationId.value,
        context: {
          'user_location': {
            'latitude': Constant.currentLocation?.latitude,
            'longitude': Constant.currentLocation?.longitude,
          },
          'user_id': Constant.userModel?.id,
        },
      );

      if (response != null) {
        if (response['conversation_id'] != null) {
          conversationId.value = response['conversation_id'];
        }

        chatMessages.add({
          'role': 'assistant',
          'message': response['response'] ?? response['message'] ?? 'No response',
          'timestamp': DateTime.now(),
          'data': response['data'],
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'AI chat failed');
    }
  }

  Future<void> getTrendingBusinesses({String? category}) async {
    isLoading.value = true;
    try {
      final trending = await HybridDataService.getTrendingBusinesses(
        category: category,
        limit: 10,
      );
      searchResults.value = trending;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load trending businesses');
    } finally {
      isLoading.value = false;
    }
  }

  void clearSearch() {
    searchController.clear();
    searchResults.clear();
    isSearching.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
