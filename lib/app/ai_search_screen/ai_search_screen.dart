import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arabween/controller/ai_search_controller.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/themes/app_them_data.dart';
import 'package:arabween/widgets/network_image_widget.dart';
import 'package:arabween/app/business_details_screen/business_details_screen.dart';

class AISearchScreen extends StatelessWidget {
  const AISearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<AISearchController>(
      init: AISearchController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('AI Search', style: TextStyle(fontFamily: AppThemeData.semibold)),
            backgroundColor: AppThemeData.primary300,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search with AI...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: controller.isSearching.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : controller.searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length > 2) {
                      controller.searchWithAI(value);
                    }
                  },
                ),
              ),
              
              if (controller.searchResults.isEmpty && !controller.isSearching.value)
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'AI Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: AppThemeData.semibold,
                              ),
                            ),
                            TextButton(
                              onPressed: controller.loadAIRecommendations,
                              child: Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: controller.isLoading.value
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                itemCount: controller.aiRecommendations.length,
                                itemBuilder: (context, index) {
                                  final business = controller.aiRecommendations[index];
                                  return _buildBusinessCard(context, business);
                                },
                              ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      final business = controller.searchResults[index];
                      return _buildBusinessCard(context, business);
                    },
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAIChatDialog(context, controller),
            icon: Icon(Icons.chat_bubble_outline),
            label: Text('AI Assistant'),
            backgroundColor: AppThemeData.primary300,
          ),
        );
      },
    );
  }

  Widget _buildBusinessCard(BuildContext context, BusinessModel business) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageWidget(
            imageUrl: business.photo ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          business.businessName ?? '',
          style: TextStyle(fontFamily: AppThemeData.semibold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business.categoryTitle != null)
              Text(business.categoryTitle!),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text('${business.reviewCount ?? 0} reviews'),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Get.to(() => BusinessDetailsScreen(businessId: business.id ?? ''));
        },
      ),
    );
  }

  void _showAIChatDialog(BuildContext context, AISearchController controller) {
    final messageController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: AppThemeData.semibold,
                ),
              ),
              Divider(),
              Expanded(
                child: Obx(() => ListView.builder(
                  controller: scrollController,
                  itemCount: controller.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = controller.chatMessages[index];
                    final isUser = message['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? AppThemeData.primary300 : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask AI anything...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: AppThemeData.primary300,
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          controller.chatWithAI(messageController.text);
                          messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
