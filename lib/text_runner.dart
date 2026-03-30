
class TextRunner {
  final String text;
  final Duration speed;
  
  TextRunner({
    required this.text,
    this.speed = const Duration(milliseconds: 100),
  });
  
  Stream<String> run() async* {
    for (int i = 0; i <= text.length; i++) {
      await Future.delayed(speed);
      yield text.substring(0, i);
    }
  }
}
