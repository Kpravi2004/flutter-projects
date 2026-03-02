class WaiterModel {
  final String id;
  String name;
  String code;
  String? phone;
  bool isActive;
  String? imageUrl;

  WaiterModel({
    required this.id,
    required this.name,
    required this.code,
    this.phone,
    this.isActive = true,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phone': phone,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  factory WaiterModel.fromJson(Map<String, dynamic> json) {
    return WaiterModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      imageUrl: json['imageUrl'],
    );
  }

  WaiterModel copyWith({
    String? name,
    String? code,
    String? phone,
    bool? isActive,
    String? imageUrl,
  }) {
    return WaiterModel(
      id: this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}