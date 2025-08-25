import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:arabween/app/business_details_screen/business_details_screen.dart';
import 'package:arabween/app/chat_screen/user_chat_screen.dart';
import 'package:arabween/app/other_people_screen/other_people_screen.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/user_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  NotificationService.redirectScreen(message);
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized || request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iosInitializationSettings);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (payload) {});
      setupInteractedMessage();
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage((message) => firebaseMessageBackgroundHandle(message));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        log(message.notification.toString());
        // display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        log(message.notification.toString());
        redirectScreen(message);
      }
    });
    await FirebaseMessaging.instance.subscribeToTopic("QuicklAI");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  static redirectScreen(RemoteMessage message) async {
    Map<String, dynamic> data = message.data;
    if (data['type'] == "user_chat") {
      String senderId = data['senderId'];
      String receiverId = data['receiverId'];

      ShowToastDialog.showLoader("Please wait".tr);
      UserModel? senderUserModel = await FireStoreUtils.getUserProfile(senderId);
      UserModel? receiverUserModel = await FireStoreUtils.getUserProfile(receiverId);
      ShowToastDialog.closeLoader();
      bool isMe = senderUserModel!.id == senderId;
      Get.to(const UserChatScreen(), arguments: {"receiverModel": isMe ? senderUserModel : receiverUserModel});
    }
    // else if (data['type'] == "project_chat") {
    //   String isSender = data['isSender'];
    //   String businessId = data['businessId'];
    //   String projectId = data['projectId'];

    //   ShowToastDialog.showLoader("Please wait".tr);
    //   PricingRequestModel? pricingRequestModel = await FireStoreUtils.getPricingRequestById(projectId);
    //   BusinessModel? businessModel = await FireStoreUtils.getBusinessById(businessId);
    //   UserModel? userModel = await FireStoreUtils.getUserProfile(pricingRequestModel!.userId.toString());
    //   ShowToastDialog.closeLoader();
    //   Get.to(ChatScreen(), arguments: {
    //     "userModel": userModel!,
    //     "businessModel": businessModel!,
    //     "projectModel": pricingRequestModel,
    //     "isSender": isSender == "business" ? "user" : "business",
    //   });
    // }
    // else if (data['type'] == "project_request") {
    //   String businessId = data['businessId'];
    //   // ignore: unused_local_variable
    //   String projectId = data['projectId'];
    //   BusinessModel? businessModel = await FireStoreUtils.getBusinessById(businessId);
    //   Get.to(BusinessProjectListScreen(), arguments: {"businessModel": businessModel});
    // }
    else if (data['type'] == "review") {
      String businessId = data['businessId'];
      BusinessModel? businessModel = await FireStoreUtils.getBusinessById(businessId);
      Get.to(BusinessDetailsScreen(), arguments: {"businessModel": businessModel});
    } else if (data['type'] == "user_follow") {
      String userId = data['userId'];
      ShowToastDialog.showLoader("Please wait");
      UserModel? userModel0 = await FireStoreUtils.getUserProfile(userId.toString());
      ShowToastDialog.closeLoader();
      Get.to(OtherPeopleScreen(), arguments: {"userModel": userModel0});
    }
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        '0',
        'arabween',
        description: 'Show arabween Notification',
        importance: Importance.max,
      );
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(channel.id, channel.name, channelDescription: 'your channel Description', importance: Importance.high, priority: Priority.high, ticker: 'ticker');
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
      NotificationDetails notificationDetailsBoth = NotificationDetails(android: notificationDetails, iOS: darwinNotificationDetails);
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
