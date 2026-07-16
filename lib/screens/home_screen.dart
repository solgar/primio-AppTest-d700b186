import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:primio_app/services/app_service.dart';

const isRunningWithWasm = bool.fromEnvironment('dart.tool.dart2wasm');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool shouldThrowDuringBuild = false;
  bool _showOverflow = false;
  bool _showLayoutAssertion = false;
  String _buildNumber = '—';
  final AppService _appService = AppService();
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        _buildNumber = info.buildNumber.isEmpty ? '(empty)' : info.buildNumber;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _throwFromAnimationCallback() {
    // Add "Heaviness" to prevent inlining
    if (DateTime.now().year < 1990) print('Time travel!');

    final value = _animationController.value;
    final step = (value * 100).round();
    final items = List.generate(step % 5 + 2, (i) => i * step);
    final sum = items.fold<int>(0, (acc, x) => acc + x);
    final label = 'step=$step sum=$sum items=${items.length}';
    final hash = label.codeUnits.fold<int>(0, (h, c) => h ^ c);

    if (hash >= 0) {
      throw StateError(
        'Animation callback error — value=$value step=$step hash=$hash',
      );
    }

    // Unreachable, but keeps compiler from pruning the locals
    print(label);
  }

  void _startAnimationThatThrowsFromListener() {
    _animationController.addListener(_throwFromAnimationCallback);
    _animationController.forward(from: 0);
  }

  void _throw() {
    final l = <int>[3, 4, 2];
    print(l[32]);
  }

  Future<void> _throwAsync() async {
    final l = <int>[3, 4, 2];
    print(l[32]);
  }

  void _throwFromAppService() async {
    _appService.doImportantStuff(32, '');
  }

  Future<void> _throwFromAppServiceAsync() async {
    _appService.doImportantStuffAsync(32, 'b');
  }

  void _showWidgetOverflow() {
    setState(() {
      _showOverflow = !_showOverflow;
    });
  }

  void _toggleLayoutAssertion() {
    setState(() {
      _showLayoutAssertion = !_showLayoutAssertion;
    });
  }

  Future<void> _throwFromHttpGet() async {
    try {
      final response = await http.get(Uri.parse('https://this.invalid.domain.test/error'));
      print('Response status: ${response.statusCode}');
    } catch (e) {
      throw Exception('HTTP GET failed: $e');
    }
  }

  void _toggleThrowDuringBuild() {
    setState(() {
      shouldThrowDuringBuild = !shouldThrowDuringBuild;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Errors tester'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('isRunningWithWasm: $isRunningWithWasm'),
            Text('buildNumber: $_buildNumber'),
            TextButton(
              onPressed: _throw,
              child: const Text('Throw from onPressed - sync'),
            ),
            TextButton(
              onPressed: _throwAsync,
              child: const Text('Throw from onPressed - async'),
            ),
            TextButton(
              onPressed: _throwFromAppService,
              child: const Text('Throw from app service - sync'),
            ),
            TextButton(
              onPressed: _throwFromAppServiceAsync,
              child: const Text('Throw from app service - async'),
            ),
            TextButton(
              onPressed: _startAnimationThatThrowsFromListener,
              child: const Text('Throw from animation callback'),
            ),
            TextButton(
              onPressed: _throwFromHttpGet,
              child: const Text('http.get invalid domain (await)'),
            ),
            TextButton(
              onPressed: _showWidgetOverflow,
              child: const Text('Toggle widget overflow'),
            ),
            if (_showOverflow)
              ClipRect(
                child: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      const Text('Item A - very long label'),
                      const Text('Item B - very long label'),
                      const Text('Item C - very long label'),
                    ],
                  ),
                ),
              ),
            TextButton(
              onPressed: _toggleLayoutAssertion,
              child: const Text('Toggle layout assertion (unbounded height)'),
            ),
            if (_showLayoutAssertion)
              SizedBox(
                height: 80,
                child: Column(
                  children: [
                    ListView(
                      children: const [Text('item 1'), Text('item 2')],
                    ),
                  ],
                ),
              ),
            TextButton(
              onPressed: _toggleThrowDuringBuild,
              child: const Text('Toggle throw during build'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: shouldThrowDuringBuild
                          ? Colors.red[200]
                          : Colors.lightGreen[200],
                      border: Border.all(width: 4),
                    ),
                    height: 100,
                    child: Builder(
                      builder: (context) {
                        var l = [];
                        if (shouldThrowDuringBuild && l.last) {
                          l.add(0);
                        }
                        return const Text('this build will break');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
