import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/constant/send_notification.dart';
import 'package:arabween/constant/show_toast_dialog.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/email_template_model.dart';
import 'package:arabween/models/photo_model.dart';
import 'package:arabween/models/review_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';

class AddReviewController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<BusinessModel> businessModel = BusinessModel().obs;
  Rx<TextEditingController> reviewDescriptionController = TextEditingController().obs;

  RxList images = <dynamic>[].obs;

  RxDouble rating = 0.0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      businessModel.value = argumentData['businessModel'];
    }
    isLoading.value = false;
    update();
  }

  uploadReview() async {
    ShowToastDialog.showLoader("Please wait");
    ReviewModel reviewModel = ReviewModel();
    reviewModel.id = Constant.getUuid();
    reviewModel.review = rating.value.toString();
    reviewModel.comment = reviewDescriptionController.value.text.toString();
    reviewModel.createdAt = Timestamp.now();
    reviewModel.businessId = businessModel.value.id;
    reviewModel.userId = FireStoreUtils.getCurrentUid();
    await FireStoreUtils.addReview(reviewModel);

    for (int i = 0; i < images.length; i++) {
      if (images[i].runtimeType == XFile) {
        String url = await Constant.uploadUserImageToFireStorage(
          File(images[i].path),
          "${businessModel.value.id}/${Constant.reviewPhotos}",
          File(images[i].path).path.split('/').last,
        );
        PhotoModel photoModel = PhotoModel();
        photoModel.id = Constant.getUuid();
        photoModel.businessId = businessModel.value.id;
        photoModel.userId = FireStoreUtils.getCurrentUid();
        photoModel.imageUrl = url;
        photoModel.createdAt = Timestamp.now();
        photoModel.type = "review";
        photoModel.reviewId = reviewModel.id;
        await FireStoreUtils.addPhotos(photoModel);
      }
    }

    businessModel.value.reviewCount = (double.parse(businessModel.value.reviewCount.toString()) + 1).toString();
    businessModel.value.reviewSum = (double.parse(businessModel.value.reviewSum.toString()) + rating.value).toString();
    await FireStoreUtils.addBusiness(businessModel.value);

    await FireStoreUtils.getUserProfile(businessModel.value.ownerId.toString()).then(
      (value) {
        if (value != null) {
          Map<String, dynamic> playLoad = <String, dynamic>{
            "type": "review",
            "businessId": businessModel.value.id,
          };

          SendNotification.sendOneNotification(
              token: value.fcmToken.toString(),
              title: 'You’ve got a new review! ${businessModel.value.businessName}',
              body: 'Check out what they said about your business',
              payload: playLoad);

          sendReviewEmail(
            recipientEmail: value.email.toString(),
            username: value.fullName(),
            businessName: businessModel.value.businessName.toString(),
            reviewText: reviewModel.comment.toString(),
            rating: reviewModel.review.toString(),
            reviewerName: Constant.userModel!.fullName(),
            date: Constant.formatTimestampToDateTime(reviewModel.createdAt!),
          );
        }
      },
    );
    ShowToastDialog.closeLoader();
    ShowToastDialog.showToast("Review Post Successfully");

    Get.back(result: true);
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }

  Future<void> sendReviewEmail(
      {required String recipientEmail,
      required String username,
      required String businessName,
      required String reviewText,
      required String rating,
      required String reviewerName,
      required String date}) async {
    // Replace the placeholders in the HTML
    EmailTemplateModel? emailTemplateModel = await FireStoreUtils.getEmailTemplates('new_business_review');

    final emailBody = Constant.replacePlaceholders(emailTemplateModel!.message.toString(), {
      'username': username,
      'businessName': businessName,
      'reviewText': reviewText,
      'rating': rating,
      'reviewerName': reviewerName,
      'date': date,
    });

    // Configure SMTP server
    final smtpServer = SmtpServer(
      '${Constant.mailSettings!.host}',
      username: '${Constant.mailSettings!.userName}',
      password: '${Constant.mailSettings!.password}', // Use App Password if 2FA is enabled
      port: int.parse(Constant.mailSettings!.port.toString()),
      ssl: true,
    );

    print(Constant.mailSettings!.userName);
    print(recipientEmail);
    // Create the email message
    final message = Message()
      ..from = Address('${Constant.mailSettings!.userName}', 'arabween')
      ..recipients = emailTemplateModel.isSendToAdmin == true && emailTemplateModel.isSendToBusiness == true
          ? [recipientEmail, Constant.adminEmail]
          : emailTemplateModel.isSendToAdmin == true
              ? [Constant.adminEmail]
              : [recipientEmail]
      ..subject = '${emailTemplateModel.subject}'
      ..html = emailBody;

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: $sendReport');
    } catch (e) {
      print('Email failed: $e');
    }
  }
}
