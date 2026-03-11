class TableModel {
  final String id;
  final String name;
  final bool isDefault;
  final String? locationId;
  final String? locationName;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;
  final String statusText;

  TableModel({
    required this.id,
    required this.name,
    required this.isDefault,
    this.locationId,
    this.locationName,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.statusText,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isDefault: json['isDefault'] ?? false,
      locationId: json['locationId']?['_id'] ?? json['locationId'],
      locationName: json['locationName'],
      createdBy: json['createdBy'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      statusText: json['statusText'] ?? (json['isDefault'] ? 'Available' : 'Unavailable'),
    );
  }
}