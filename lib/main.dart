import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_runner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Runner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TextRunnerPage(),
    );
  }
}

class TextRunnerPage extends StatefulWidget {
  const TextRunnerPage({super.key});

  @override
  State<TextRunnerPage> createState() => _TextRunnerPageState();
}

class _TextRunnerPageState extends State<TextRunnerPage> {
  String _displayText = '';
  bool _isRunning = false;
  final TextEditingController _controller = TextEditingController(
    text: 'Hello, TextRunner!',
  );

  void _startTextRunner() async {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _displayText = '';
    });
    
    final runner = TextRunner(
      text: _controller.text,
      speed: const Duration(milliseconds: 50),
    );
    
    await for (final text in runner.run()) {
      if (mounted) {
        setState(() {
          _displayText = text;
        });
      }
    }
    
    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Runner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text to run',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _displayText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isRunning ? null : _startTextRunner,
              child: const Text('Run Text'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
