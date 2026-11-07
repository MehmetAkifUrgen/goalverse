import 'dart:async';

class GameTimer {
  final int totalSeconds;
  Timer? _timer;
  int _remainingSeconds = 0;
  final StreamController<int> _tickController =
      StreamController<int>.broadcast();
  final StreamController<void> _expiredController =
      StreamController<void>.broadcast();
  bool _isDisposed = false;

  GameTimer({this.totalSeconds = 30});

  Stream<int> get tickStream => _tickController.stream;
  Stream<void> get expiredStream => _expiredController.stream;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _timer?.isActive ?? false;
  bool get isExpired => _remainingSeconds <= 0 && !isRunning;

  void start() {
    if (_isDisposed) return;
    _remainingSeconds = totalSeconds;
    _tickController.add(_remainingSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _remainingSeconds = 0;
        _tickController.add(0);
        _expiredController.add(null);
        stop();
      } else {
        _tickController.add(_remainingSeconds);
      }
    });
  }

  void reset() {
    stop();
    _remainingSeconds = totalSeconds;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _isDisposed = true;
    stop();
    _tickController.close();
    _expiredController.close();
  }
}
