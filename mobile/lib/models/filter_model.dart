class FilterModel {
  final int id;
  final String name;
  final String type; // color | vibe_lighting | beauty
  final String? thumbnailPath;
  final double intensityDefault;

  FilterModel({
    required this.id,
    required this.name,
    required this.type,
    this.thumbnailPath,
    this.intensityDefault = 0.5,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? 'color',
      thumbnailPath: json['thumbnail_path'],
      intensityDefault: (json['intensity_default'] ?? 0.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'thumbnail_path': thumbnailPath,
        'intensity_default': intensityDefault,
      };
}
