import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:arabween/constant/constant.dart';
import 'package:arabween/models/business_model.dart';
import 'package:arabween/models/category_model.dart';
import 'package:arabween/utils/fire_store_utils.dart';
import 'package:arabween/widgets/geoflutterfire/src/geoflutterfire.dart';
import 'package:arabween/widgets/geoflutterfire/src/models/point.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constant/show_toast_dialog.dart';

class CreateBusinessController extends GetxController {
  Rx<GlobalKey<FormState>> formKey = GlobalKey<FormState>().obs;
  Rx<TextEditingController> countryNameTextFieldController = TextEditingController(text: "United state of America").obs;
  Rx<TextEditingController> countryCodeController = TextEditingController(text: "+1").obs;
  Rx<TextEditingController> nameTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> arabicNameTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> businessUrlTextFieldController = TextEditingController().obs;
  RxString businessSlug = ''.obs;
  Rx<TextEditingController> descriptionTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> metaKeywordsController = TextEditingController().obs;
  RxList<dynamic> metaKeywordsList = <dynamic>[].obs;
  Rx<TextEditingController> addressTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> serviceAreaTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> categoryTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> websiteTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> bookingLinkTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> notesOfTheYelpTeamTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> fbLinkTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> instaLinkTextFieldController = TextEditingController().obs;
  Rx<TextEditingController> tagLineTextFieldController = TextEditingController().obs;

  //HightLight
  Rx<TextEditingController> highlightTextFieldController = TextEditingController().obs;
  RxList<dynamic> highLightsList = [].obs;

  //Working hours
  RxBool isOpenBusinessAllTime = false.obs;
  RxMap<String, DayHours> businessWeek = {
    'monday': DayHours(isOpen: false, timeRanges: []),
    'tuesday': DayHours(isOpen: false, timeRanges: []),
    'wednesday': DayHours(isOpen: false, timeRanges: []),
    'thursday': DayHours(isOpen: false, timeRanges: []),
    'friday': DayHours(isOpen: false, timeRanges: []),
    'saturday': DayHours(isOpen: false, timeRanges: []),
    'sunday': DayHours(isOpen: false, timeRanges: []),
  }.obs;

  Rx<AddressModel> address = AddressModel().obs;
  Rx<LatLngModel> location = LatLngModel().obs;

  RxList<CategoryModel> selectedCategory = <CategoryModel>[].obs;
  RxList<dynamic> selectedServiceArea = [].obs;

  RxBool asCustomerOrWorkAtBusiness = true.obs;
  RxBool isPermanentClosed = false.obs;

  RxString profileImage = "".obs;
  RxString coverImage = "".obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  String generateSlugAndUrl({required String input}) {
    if (input.trim().isEmpty) {
      businessSlug.value = '';
      return '';
    }

    final invalidChars = RegExp(r'[^a-zA-Z0-9\- ]');
    if (invalidChars.hasMatch(input)) {
      final cleaned = input.replaceAll(invalidChars, '');
      businessSlug.value = '';
      ShowToastDialog.showToast("Invalid characters in slug.");
      return cleaned;
    }
    String slug = input.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-');

    businessSlug.value = slug;
    businessUrlTextFieldController.value.text = businessSlug.value;
    return businessSlug.value;
  }

  Rx<BusinessModel> businessModel = BusinessModel().obs;
  RxList<String> businessTypeList = ['Local Business', 'Service Business'].obs;
  RxString selectedBusinessType = ''.obs;

  getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      if (argumentData['businessModel'] != null) {
        businessModel.value = argumentData['businessModel'];

        isPermanentClosed.value = businessModel.value.isPermanentClosed ?? false;
        countryNameTextFieldController.value.text = businessModel.value.countryName ?? '';
        countryCodeController.value.text = businessModel.value.countryCode ?? '';
        selectedBusinessType.value = businessModel.value.businessType ?? '';
        nameTextFieldController.value.text = businessModel.value.businessName ?? '';
        arabicNameTextFieldController.value.text = businessModel.value.businessNameArabic ?? '';
        descriptionTextFieldController.value.text = businessModel.value.description ?? '';
        address.value = businessModel.value.address!;
        address.value.postalCode = businessModel.value.zipCode;
        location.value = businessModel.value.location!;
        selectedCategory.value = businessModel.value.category ?? [];
        phoneNumberTextFieldController.value.text = businessModel.value.phoneNumber ?? '';
        websiteTextFieldController.value.text = businessModel.value.website ?? '';
        bookingLinkTextFieldController.value.text = businessModel.value.bookingWebsite ?? '';
        fbLinkTextFieldController.value.text = businessModel.value.fbLink ?? '';
        instaLinkTextFieldController.value.text = businessModel.value.instaLink ?? '';
        tagLineTextFieldController.value.text = businessModel.value.tagLine ?? '';
        notesOfTheYelpTeamTextFieldController.value.text = businessModel.value.noteForYelpTeam ?? '';
        addressTextFieldController.value.text = Constant.getFullAddressModel(address.value);
        categoryTextFieldController.value.text = selectedCategory.map((e) => e.name).join(", ");
        profileImage.value = businessModel.value.profilePhoto ?? '';
        coverImage.value = businessModel.value.coverPhoto ?? '';
        highLightsList.value = businessModel.value.highLights ?? [];
        isOpenBusinessAllTime.value = businessModel.value.isBusinessOpenAllTime ?? false;
        if (businessModel.value.businessType == 'Service Business') {
          selectedServiceArea.value = businessModel.value.serviceArea?.isEmpty == true ? [] : businessModel.value.serviceArea!;
          serviceAreaTextFieldController.value.text = selectedServiceArea.map((e) => e).join(", ");
        }
        final existingHours = businessModel.value.businessHours;
        if (existingHours != null) {
          businessWeek.value = {
            'monday': _fromStrings(existingHours.monday),
            'tuesday': _fromStrings(existingHours.tuesday),
            'wednesday': _fromStrings(existingHours.wednesday),
            'thursday': _fromStrings(existingHours.thursday),
            'friday': _fromStrings(existingHours.friday),
            'saturday': _fromStrings(existingHours.saturday),
            'sunday': _fromStrings(existingHours.sunday),
          };
        }
        if (businessModel.value.slug != null) {
          businessUrlTextFieldController.value.text = businessModel.value.slug!.substring(4);
          String slug = businessModel.value.slug!.substring(4);
          businessSlug.value = generateSlugAndUrl(input: slug);
        }
        if (businessModel.value.metaKeywords != null) {
          metaKeywordsList.value = businessModel.value.metaKeywords!;
          metaKeywordsController.value.text = metaKeywordsList.join(', ');
        }
        update();
      } else {
        asCustomerOrWorkAtBusiness.value = argumentData['asCustomerOrWorkAtBusiness'];
      }
    }
    update();
  }

  BusinessHours generateBusinessHours() {
    if (isOpenBusinessAllTime.value == true) {
      final fullDay = [TimeRange(open: TimeOfDay(hour: 0, minute: 0), close: TimeOfDay(hour: 23, minute: 59))];
      return BusinessHours(
        monday: fullDay.map((e) => e.toRangeString()).toList(),
        tuesday: fullDay.map((e) => e.toRangeString()).toList(),
        wednesday: fullDay.map((e) => e.toRangeString()).toList(),
        thursday: fullDay.map((e) => e.toRangeString()).toList(),
        friday: fullDay.map((e) => e.toRangeString()).toList(),
        saturday: fullDay.map((e) => e.toRangeString()).toList(),
        sunday: fullDay.map((e) => e.toRangeString()).toList(),
      );
    } else {
      return BusinessHours(
        monday: businessWeek['monday']!.isOpen ? businessWeek['monday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        tuesday: businessWeek['tuesday']!.isOpen ? businessWeek['tuesday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        wednesday: businessWeek['wednesday']!.isOpen ? businessWeek['wednesday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        thursday: businessWeek['thursday']!.isOpen ? businessWeek['thursday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        friday: businessWeek['friday']!.isOpen ? businessWeek['friday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        saturday: businessWeek['saturday']!.isOpen ? businessWeek['saturday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
        sunday: businessWeek['sunday']!.isOpen ? businessWeek['sunday']!.timeRanges.map((e) => e.toRangeString()).toList() : [],
      );
    }
  }

  saveBusiness() async {
    ShowToastDialog.showLoader("Please wait");
    if (profileImage.value.isNotEmpty && Constant().hasValidUrl(profileImage.value) == false) {
      profileImage.value = await Constant.uploadUserImageToFireStorage(
        File(profileImage.value),
        "${businessModel.value.id}",
        File(profileImage.value).path.split('/').last,
      );
    }

    if (coverImage.value.isNotEmpty && Constant().hasValidUrl(coverImage.value) == false) {
      coverImage.value = await Constant.uploadUserImageToFireStorage(
        File(coverImage.value),
        "${businessModel.value.id}",
        File(coverImage.value).path.split('/').last,
      );
    }

    if (businessModel.value.id == null || businessModel.value.id!.isEmpty) {
      businessModel.value.id = Constant.getUuid();
      businessModel.value.createdAt = Timestamp.now();
      businessModel.value.updatedAt = Timestamp.now();
      businessModel.value.publish = false;
      businessModel.value.isVerified = false;
    }

    businessModel.value.createdBy = FireStoreUtils.getCurrentUid();
    businessModel.value.businessType = selectedBusinessType.value;
    businessModel.value.countryName = countryNameTextFieldController.value.text;
    businessModel.value.description = descriptionTextFieldController.value.text;
    businessModel.value.countryCode = countryCodeController.value.text;
    businessModel.value.businessName = nameTextFieldController.value.text;
    businessModel.value.businessNameArabic = arabicNameTextFieldController.value.text;
    businessModel.value.address = address.value;
    businessModel.value.zipCode = address.value.postalCode;
    businessModel.value.location = location.value;
    GeoFirePoint position = Geoflutterfire().point(latitude: double.parse(location.value.latitude.toString()), longitude: double.parse(location.value.longitude.toString()));
    businessModel.value.position = Positions(geoPoint: position.geoPoint, geoHash: position.hash);
    businessModel.value.category = selectedCategory;
    businessModel.value.phoneNumber = phoneNumberTextFieldController.value.text;
    businessModel.value.website = websiteTextFieldController.value.text;
    businessModel.value.bookingWebsite = bookingLinkTextFieldController.value.text;
    businessModel.value.fbLink = fbLinkTextFieldController.value.text;
    businessModel.value.instaLink = instaLinkTextFieldController.value.text;
    businessModel.value.tagLine = tagLineTextFieldController.value.text;
    businessModel.value.noteForYelpTeam = notesOfTheYelpTeamTextFieldController.value.text;
    businessModel.value.searchKeyword = Constant.generateSearchKeywords(nameTextFieldController.value.text);
    businessModel.value.asCustomerOrWorkAtBusiness = asCustomerOrWorkAtBusiness.value;
    businessModel.value.profilePhoto = profileImage.value;
    businessModel.value.coverPhoto = coverImage.value;
    businessModel.value.isPermanentClosed = false;
    String prefix = businessModel.value.id!.toLowerCase().substring(0, 3);
    businessModel.value.slug = "$prefix-${businessSlug.value}";
    businessModel.value.metaKeywords = metaKeywordsList;
    businessModel.value.isBusinessOpenAllTime = true;
    businessModel.value.highLights = highLightsList;
    businessModel.value.businessHours = generateBusinessHours();
    businessModel.value.showWorkingHours = true;
    businessModel.value.isBusinessOpenAllTime = isOpenBusinessAllTime.value;
    businessModel.value.serviceArea = selectedServiceArea;
    log("Service Area :: ${businessModel.value.serviceArea?.join(', ')}");
    // businessModel.value.ownerId = FireStoreUtils.getCurrentUid();
    await FireStoreUtils.addBusiness(businessModel.value).then(
      (value) {
        ShowToastDialog.closeLoader();
        Get.back(result: true);
      },
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<String?> pickFile({required ImageSource source, String? imageType}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: source);

      if (image == null || image.path.isEmpty) {
        return null;
      }

      final int sizeInBytes = await image.length();
      final double sizeInMB = sizeInBytes / (1024 * 1024);
      final double maxAllowedSize = double.tryParse(imageType == 'cover' ? Constant.coverImageSizeMb : Constant.profileCoverImageSizeMb.toString()) ?? 2.0;

      // print("Orignal SizeInMB :: $sizeInMB");
      if (sizeInMB > maxAllowedSize) {
        return 'Image is too large. Please select an image under ${maxAllowedSize.toStringAsFixed(1)}MB.';
      }

      final dir = await getTemporaryDirectory();
      final String targetPath = path.join(dir.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 80,
      );

      if (compressedFile == null) {
        return 'Failed to compress the image. Please try again.';
      }
      // int comSizeInBytes = await compressedFile.length();
      // final double comSizeInMB = comSizeInBytes / (1024 * 1024);
      // print("CompressedFile SizeInMB :: $comSizeInMB");

      if (imageType == 'profile') {
        profileImage.value = compressedFile.path;
      } else {
        coverImage.value = compressedFile.path;
      }

      Get.back();
      return null;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("Failed to pick image: $e");
      return 'Image picking failed.';
    } catch (e) {
      ShowToastDialog.showToast("Unexpected error: $e");
      return 'Unexpected error occurred.';
    }
  }

  DayHours _fromStrings(List<dynamic>? times) {
    if (times == null || times.isEmpty) {
      return DayHours(isOpen: false, timeRanges: []);
    }
    List<TimeRange> ranges = times.map((str) {
      final parts = str.split('-');
      final openParts = parts[0].split(':');
      final closeParts = parts[1].split(':');

      return TimeRange(
        open: TimeOfDay(hour: int.parse(openParts[0]), minute: int.parse(openParts[1])),
        close: TimeOfDay(hour: int.parse(closeParts[0]), minute: int.parse(closeParts[1])),
      );
    }).toList();
    return DayHours(isOpen: true, timeRanges: ranges);
  }
}
