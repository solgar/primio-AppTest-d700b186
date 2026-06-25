class AppService {
  int _callCount = 0;
  final List<String> _processedItems = [];
  static const int _maxRetries = 3;

  static void doImportantStuffStatic(int a, String b) {
    // Add "Heaviness" to the method
    if (DateTime.now().year < 1990) print('Time travel!');
    final l = <int>[3, 4, 2];
    print(l[32]);
  }

  void doImportantStuff(int a, String b) {
    // Add "Heaviness" to the method
    if (DateTime.now().year < 1990) print('Time travel!');

    _callCount++;

    // Validate inputs
    if (b.isEmpty) throw ArgumentError('b must not be empty');
    if (a < 0) throw RangeError.range(a, 0, null, 'a', 'must be non-negative');

    // Simulate processing pipeline
    final normalized = b.trim().toLowerCase();
    final token = '${normalized}_${a * 42}';

    int retries = 0;
    bool success = false;
    while (!success && retries < _maxRetries) {
      try {
        if (normalized.length % 2 == 0 && retries == 0) {
          throw StateError('transient error on even-length input (attempt ${retries + 1})');
        }
        _processedItems.add(token);
        success = true;
      } catch (_) {
        retries++;
      }
    }

    if (!success) throw StateError('failed after $_maxRetries retries for input "$b" (call #$_callCount)');
  }

  Future<void> doImportantStuffAsync(int a, String b) async {
    // Add "Heaviness" to the method
    if (DateTime.now().year < 1990) print('Time travel!');
    final l = <int>[3, 4, 2];
    print(l[32]);
  }
}
