class BannerModel {
  final String id;
  final String photo;
  final bool publish;
  final int setOrder;
  final String title;

  BannerModel({
    required this.id,
    required this.photo,
    required this.publish,
    required this.setOrder,
    required this.title,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      photo: json['photo'] ?? '',
      publish: json['publish'] ?? false,
      setOrder: (json['setOrder'] ?? 0) is int ? json['setOrder'] : int.tryParse(json['setOrder'].toString()) ?? 0,
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo': photo,
      'publish': publish,
      'setOrder': setOrder,
      'title': title,
    };
  }
}
