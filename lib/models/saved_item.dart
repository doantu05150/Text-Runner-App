class SavedItem {
  final String id;
  final String text;
  final double fontSize;
  final String fontFamily;
  final int fontWeightValue;
  final int textColorValue;
  final int backgroundColorValue;
  final double speed;
  final String displayStyle; // 'normal' or 'led'
  final bool blinkText;
  final double blinkSpeed;
  final DateTime createdAt;

  SavedItem({
    required this.id,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    this.fontWeightValue = 400,
    required this.textColorValue,
    required this.backgroundColorValue,
    this.speed = 150.0,
    this.displayStyle = 'normal',
    this.blinkText = false,
    this.blinkSpeed = 500.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'fontSize': fontSize,
    'fontFamily': fontFamily,
    'fontWeightValue': fontWeightValue,
    'textColorValue': textColorValue,
    'backgroundColorValue': backgroundColorValue,
    'speed': speed,
    'displayStyle': displayStyle,
    'blinkText': blinkText,
    'blinkSpeed': blinkSpeed,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
    id: json['id'],
    text: json['text'],
    fontSize: (json['fontSize'] as num).toDouble(),
    fontFamily: json['fontFamily'],
    fontWeightValue: json['fontWeightValue'] ?? 400,
    textColorValue: json['textColorValue'],
    backgroundColorValue: json['backgroundColorValue'],
    speed: (json['speed'] as num?)?.toDouble() ?? 150.0,
    displayStyle: json['displayStyle'] as String? ?? 'normal',
    blinkText: json['blinkText'] as bool? ?? false,
    blinkSpeed: (json['blinkSpeed'] as num?)?.toDouble() ?? 500.0,
    createdAt: DateTime.parse(json['createdAt']),
  );
}
