class FrameModel {
  final int id;
  final String name;
  final String layoutType;
  final String? thumbnailPath;
  final bool isActive;

  FrameModel({
    required this.id,
    required this.name,
    required this.layoutType,
    this.thumbnailPath,
    this.isActive = true,
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['id'],
      name: json['name'],
      layoutType: json['layout_type'] ?? '4-cut',
      thumbnailPath: json['thumbnail_path'],
      isActive: (json['is_active'] ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'layout_type': layoutType,
        'thumbnail_path': thumbnailPath,
      };
}
