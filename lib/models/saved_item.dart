class SavedItem {
  final String id;
  final String text;
  final double fontSize;
  final String fontFamily;
  final int textColorValue;
  final int backgroundColorValue;
  final DateTime createdAt;

  SavedItem({
    required this.id,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    required this.textColorValue,
    required this.backgroundColorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'fontSize': fontSize,
    'fontFamily': fontFamily,
    'textColorValue': textColorValue,
    'backgroundColorValue': backgroundColorValue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
    id: json['id'],
    text: json['text'],
    fontSize: json['fontSize'],
    fontFamily: json['fontFamily'],
    textColorValue: json['textColorValue'],
    backgroundColorValue: json['backgroundColorValue'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
