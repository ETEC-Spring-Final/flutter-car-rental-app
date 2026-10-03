class BrandModel {
  final int id;
  final String name;
  final String imageUrl;

  const BrandModel({required this.id, required this.name, this.imageUrl = ''});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
  };
}
