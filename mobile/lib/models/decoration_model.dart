class DecorationModel {
  final int id;
  final int sessionId;
  final String type; // sticker | text | emoji
  final String content;
  final double posX;
  final double posY;
  final double scale;
  final double rotation;

  DecorationModel({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.content,
    this.posX = 0,
    this.posY = 0,
    this.scale = 1,
    this.rotation = 0,
  });

  factory DecorationModel.fromJson(Map<String, dynamic> json) {
    return DecorationModel(
      id: json['id'],
      sessionId: json['session_id'],
      type: json['type'] ?? 'sticker',
      content: json['content'],
      posX: (json['pos_x'] ?? 0).toDouble(),
      posY: (json['pos_y'] ?? 0).toDouble(),
      scale: (json['scale'] ?? 1).toDouble(),
      rotation: (json['rotation'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
        'pos_x': posX,
        'pos_y': posY,
        'scale': scale,
        'rotation': rotation,
      };
}
